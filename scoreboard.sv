class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [31:0] crrt_Z;
    bit [32:0] fract_Z_unR; // fracZ without rounding.
    bit und,over,nan_X,nan_Y,nan_Z;
    real fracZ; //fracZ as decimal point data
    
    bit sign_field_Z;
    bit [7:0] exp_field_Z;
    bit [22:0] fract_field_Z;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

    virtual function write(Item item);

        ///////GOLDEN REFERENCE////////
        
        sign_field_Z=item.fp_X[31]^item.fp_Y[31];

        exp_field_Z=item.fp_X[30:23]+item.fp_Y[30:23]-127;

        fracZ=item.fp_X[22:0]+(item.fp_X[22:0]*item.fp_Y[22:0])/8388608+item.fp_Y[22:0];

        fract_Z_unR=fracZ*2; // shift the decimal point one time

        
        //Now fract_field_Z should have a lentght of 23 +1 but if it is greater then the result is NaN

        if (fract_Z_unR>=2**24) begin

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
                        //truncate the result (already truncated)
                    end
                endcase
                
            end

        else begin
            nan_Z=1;
        end



        und  =( !(item.fp_X[30:23] || item.fp_Y[30:23]) && !(item.fp_X[22:0] || item.fp_Y[22:0]))? 1 : 0;
        over =(condition )? 1 : 0;
        nan  =(condition )? 1 : 0;

        crrt_Z={sign_field_Z,exp_field_Z,fract_field_Z}; 

        //////////////////////////////


        `uvm_info("SCBD", $sformatf("Mode=%0b Op_x=%0b Op_y=%0b Result=%0b Correct=%0b Overflow=%0b 
        Underflow=%0b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,crrt_Z,item.ovrf,item.udrf), UVM_LOW)
        
        if(item.fp_Z != exp_Z) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result=%0b Correct=%0b", item.fp_Z,crrt_Z))
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result=%0b Correct=%0b",item.fp_Z,crrt_Z), UVM_HIGH)
        end

    endfunction

endclass

