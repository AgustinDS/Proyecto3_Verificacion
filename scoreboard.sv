class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    
    function new(string name="scoreboard",uvm_component parent=null);
        super.new(name, parent);
    endfunction

    bit [31:0] crrt_Z;

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_analysis_imp = new("m_analysis_imp",this);

    endfunction

    virtual function write(Item item);

        crrt_Z={item.fp_X[31]^item.fp_Y[31],item.fp_X[30:23]+item.fp_Y[30:23]-127
        ,item.fp_X[22:0]+item.fp_X[22:0]*item.fp_Y[22:0]+item.fp_Y[22:0]}; //Checker

        `uvm_info("SCBD", $sformatf("Mode=%0b Op_x=%0b Op_y=%0b Result=%0b Correct=%0b Overflow=%0b 
        Underflow=%0b", item.r_mode,item.fp_X,item.fp_Y,item.fp_Z,crrt_Z,item.ovrf,item.udrf), UVM_LOW)
        
        if(item.fp_Z != exp_Z) begin
            `uvm_error("SCBD",$sformatf("ERROR ! Result=%0b Correct=%0b", item.fp_Z,crrt_Z))
        end else begin
            `uvm_info("SCBD",$sformatf("PASS ! Result=%0b Correct=%0b",item.fp_Z,crrt_Z), UVM_HIGH)
        end

        //UNDERFLOW
        //OVERFLOW
        //NAN

    endfunction

endclass

