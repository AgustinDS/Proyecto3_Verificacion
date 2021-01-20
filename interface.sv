interface dut_if (input bit clk);
  logic [2:0]   r_mode;
  logic [31:0] fp_X, fp_Y;
  logic [31:0] fp_Z;
  logic ovrf, udrf;

  clocking cb @(posedge clk);
    default input #1step output #3ns;
        input fp_Z;  //Salida
        input ovrf;  // overflow
        input udrf;  //underflow
        output r_mode;  //mode
        output fp_X; //A
        output fp_Y; //B
  endclocking 


  property und;
    @(cb) ~|cb.fp_Z[30:23] |-> cb.udrf;
  endproperty

  property ovr;
    @(cb) &cb.fp_Z[30:23] |-> cb.ovrf;
  endproperty

   a_und: assert property (und) else $display("Underflow Flag Error");
   c_und: cover property (und) $display("Underflow Flag Pass");


   a_ovr: assert property (ovr) else $display("Overflow Flag Error");
   c_ovr: cover property (ovr) $display("Overflow Flag Pass");


endinterface