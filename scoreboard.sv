class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [31:0] crrt_Z;
    bit [32:0] fract_Z_unR; // fracZ without rounding.
    bit und_X,over_X,nan_X,und_Y,over_Y,nan_Y,und_Z,over_Z,nan_Z;
    real expZ,fracZ; //fracZ as decimal point data
    
    bit sign_field_Z;
  	bit [7:0] exp_field_X, exp_field_Y, exp_field_Z;
  	bit [22:0] fract_field_X, fract_field_Y, fract_field_Z;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        
      	super.build_phase(phase);
      
        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

    virtual function void write(Item item);

        ///////GOLDEN REFERENCE////////

        exp_field_X=item.fp_X[30:23];

        fract_field_X=item.fp_X[22:0];


        exp_field_Y=item.fp_Y[30:23];

        fract_field_Y=item.fp_Y[22:0];

        
        sign_field_Z=item.fp_X[31]^item.fp_Y[31];

        expZ=exp_field_X+exp_field_Y-127; //This value could be negative

        fracZ=fract_field_X+(fract_field_X*fract_field_Y)/8388608+fract_field_Y; //This value has decimal point

      $display("expz %g ",$rtoi(expZ));

      	if ($rtoi(expZ)<=0) begin
            exp_field_Z=8'b0;
        end
        else begin
            exp_field_Z=expZ;
        end
        
        fract_Z_unR=fracZ*2; // shift the decimal point one time

        //Now fract_field_Z should have a lentght of 23 +1 but if it is greater then the result is NaN

        if (fract_Z_unR>=2**24) begin
            
            nan_Z=0;

            fract_field_Z=fract_Z_unR/2; //First the fraction field is truncated
            
            if (fract_Z_unR[0]) begin  //It needs rounding 

                case (item.r_mode)

                    3'b000:begin  //last bit 0
                        
                        if (fract_field_Z[0]) begin
                            fract_field_Z+=1;
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

                        fract_field_Z+=1;

                    end

                    default: begin
                        //truncate (already truncated)
                    end
                endcase
                
            end
        end
        else begin
          	$display("Exp_z %g",exp_field_Z);
            if (exp_field_Z>=2**8) begin
                exp_field_Z=8'b11111111;
            end
            else begin
                nan_Z=1;
            end 
        end


        und_X  =!(|exp_field_X)?1 : 0; //If exp is 0 then underflow
        over_X =(&exp_field_X)? 1 : 0; //If exp field is 'd255 then overflow

        und_Y  =!(|exp_field_Y)?1 : 0; //If exp is 0 then underflow
        over_Y =(&exp_field_Y)? 1 : 0; //If exp field is 'd255 then overflow
        
        und_Z  =!(|exp_field_Z)?1 : 0; //If exp is 0 then underflow
        over_Z =(&exp_field_Z)? 1 : 0; //If exp field is 'd255 then overflow

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
            crrt_Z={sign_field_Z,exp_field_Z,fract_field_Z};  //correct result
        end

        //////////////////////////////

        `uvm_info("SCBD", $sformatf("Mode=%0b Op_x=%0b Op_y=%0b Result=%0b Correct=%0b Overflow=%0b Underflow=%0b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,crrt_Z,item.ovrf,item.udrf), UVM_LOW)
        
        if(item.fp_Z !=crrt_Z ) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result=%0b Correct=%0b", item.fp_Z,crrt_Z))
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result=%0b Correct=%0b",item.fp_Z,crrt_Z), UVM_HIGH)
        end

    endfunction

endclass
