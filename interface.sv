interface dut_if (input bit clk);
  logic [2:0]   r_mode;
  logic [31:0] fp_X, fp_Y;
  logic [31:0] fp_Z;
  logic ovrf, udrf;

  clocking cb @(posedge clk);
    default input #1step output #3ns;
        input fp_Z;
        input ovrf;
        input udrf;
        output r_mode;
        output fp_X;
        output fp_Y;
     endclocking 
     
endinterface