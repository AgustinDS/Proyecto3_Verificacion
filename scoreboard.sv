class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [31:0] crrt_Z;
    int n;
    bit [32:0] fract_Z_unR; // fracZ without rounding.
    bit und_X,over_X,nan_X,und_Y,over_Y,nan_Y,und_Z,over_Z,nan_Z;
    real expZ,fracZ,de_fracZ; //fracZ as decimal point data
    
    bit sign_field_Z;
    bit [7:0] exp_field_X, exp_field_Y, exp_field_Z;
  	bit [22:0] fract_field_X, fract_field_Y, r_fract_field_Z;
  	bit [24:0] fract_field_Z;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

    virtual function void write(Item item);

        ///////GOLDEN REFERENCE////////

        nan_Z=0;

        exp_field_X=item.fp_X[30:23];

        fract_field_X=item.fp_X[22:0];


        exp_field_Y=item.fp_Y[30:23];

        fract_field_Y=item.fp_Y[22:0];

        
        sign_field_Z=item.fp_X[31]^item.fp_Y[31];

        expZ=exp_field_X+exp_field_Y-127; //This value could be negative

        fracZ=fract_field_X+(($itor(fract_field_X))*($itor(fract_field_Y)))/8388608+fract_field_Y+8388608; //This value has decimal point
        
        
        fract_Z_unR=fracZ;

        de_fracZ=(fracZ-$itor(fract_Z_unR)); //decimal part of the exact value 
		
        for (int i=32; i>=0; --i) begin  
            if (fract_Z_unR[i]) begin
                n=i;
                break;
            end
        end

      	expZ=expZ+n-23;
           
      	$display("n %g",n);
        fract_Z_unR=fracZ*(2**(32-n));

        // This is the amount of bits of the fract
     
        fract_field_Z=fract_Z_unR[32:9];//first the result is truncated
      
        $display("Same bits %b %b %b %f",fract_Z_unR,fracZ,fract_field_Z,de_fracZ);

        if (de_fracZ!=0) begin  //It needs rounding because it isn't a exact result
            $display("Rounding...");
            case (item.r_mode)

                3'b000:begin  //last bit 0
                    
                  	if (fract_Z_unR[8]) begin
                      	if (fract_Z_unR[7:0]!=0) begin
                            fract_field_Z+=1;
                        end else begin
                            if (fract_Z_unR[10]) begin
                                fract_field_Z+=1;
                            end
                        end
                    end
                end

                3'b001:begin  //last bit doesnt change (truncate)
                    
                    //Nothing to do (already truncated)

                end

                3'b010:begin  //last bit depends on the sign of the result (Down)
                    
                    if (sign_field_Z) begin
                        fract_field_Z+=1;
                    end

                end

                3'b011:begin  //last bit depends on the sign of the result (Up)

                    if (!sign_field_Z) begin
                        fract_field_Z+=1;
                    end

                end

                3'b100:begin  //add 1 to the fraction field
                    if (fract_Z_unR[8]) begin
                        fract_field_Z+=1;
                    end
                end

                default: begin
                    //truncate (already truncated)
                end
            endcase
            
        end 
        
      	if (fract_field_Z[24]) begin
            r_fract_field_Z=fract_field_Z[23:1];
            expZ+=1; 
        end else begin
           r_fract_field_Z=fract_field_Z[22:0];
        end
      	
        $display("Fract z field %b %b",fract_field_Z,r_fract_field_Z);
       
        if ($rtoi(expZ)<=0) begin
            exp_field_Z=8'b0; //Underflow
        end 
        else if ($rtoi(expZ)>=255) begin
            exp_field_Z=8'b11111111; //Overflow
        end
        else begin
            exp_field_Z=expZ; //Normal
        end
      
      


        und_X  =!(|exp_field_X)?1 : 0; //If exp is 0 then underflow
        over_X =(&exp_field_X)? 1 : 0; //If exp field is 'd255 then overflow

        und_Y  =!(|exp_field_Y)?1 : 0; //If exp is 0 then underflow
        over_Y =(&exp_field_Y)? 1 : 0; //If exp field is 'd255 then overflow
        
        und_Z  =!(|exp_field_Z)?1 : 0; //If exp is 0 then underflow
        und_Z= und_Z|und_Y|und_X;

        over_Z =(&exp_field_Z)? 1 : 0; //If exp field is 'd255 then overflow
        over_Z = over_X|over_Y|over_Z;

       
        nan_X = &exp_field_X & |fract_field_X; //NaN definition
        nan_Y = &exp_field_Y & |fract_field_Y;

        nan_Z = {und_X & over_Y} | {over_X & und_Y} | nan_Z; //Infinity*0 or 0*Infinity
        nan_Z = nan_X | nan_Y | nan_Z; //Nan propagation


        if (und_Z) begin
            crrt_Z={sign_field_Z,8'b0,23'b0};  //correct result
        end 
        else if (over_Z) begin
            crrt_Z={sign_field_Z,8'hFF,23'b0};  //correct result
        end
        else if (nan_Z) begin
            crrt_Z={sign_field_Z,8'hFF,1'b1,22'b0};  //correct result
        end
        else begin
            crrt_Z={sign_field_Z,exp_field_Z,r_fract_field_Z};  //correct result
        end

        //////////////////////////////

        `uvm_info("SCBD", $sformatf("Mode=%b Op_x=%b Op_y=%b Result=%b Correct=%b Overflow=%b Underflow=%b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,crrt_Z,item.ovrf,item.udrf), UVM_LOW)
        
        if(item.fp_Z !=crrt_Z ) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result=%b Correct=%b", item.fp_Z,crrt_Z))
            newRowOut_e(item, crrt_Z);
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result=%b Correct=%b",item.fp_Z,crrt_Z), UVM_HIGH)
            newRowOut_p(item, crrt_Z);
        end

        newRowOut(item, crrt_Z);

    endfunction

    virtual function void newRowOut(const ref Item item, bit [31:0] crrt_Z);
        $system($sformatf("echo '%b, %b, %b, %b, %b, %b, %b' >> sb_transaction_report.csv", item.fp_X, item.fp_Y, item.fp_Z, crrt_Z, item.r_mode, item.ovrf, item.udrf));
    endfunction

    virtual function void newRowOut_p(const ref Item item, bit [31:0] crrt_Z);
        $system($sformatf("echo '%b, %b, %b, %b, %b, %b, %b' >> sb_PASS_transaction_report.csv", item.fp_X, item.fp_Y, item.fp_Z, crrt_Z, item.r_mode, item.ovrf, item.udrf));
    endfunction

    virtual function void newRowOut_e(const ref Item item, bit [31:0] crrt_Z);
        $system($sformatf("echo '%b, %b, %b, %b, %b, %b, %b' >> sb_ERROR_transaction_report.csv", item.fp_X, item.fp_Y, item.fp_Z, crrt_Z, item.r_mode, item.ovrf, item.udrf));
    endfunction
endclass

