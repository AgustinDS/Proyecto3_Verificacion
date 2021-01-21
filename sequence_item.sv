class Item extends uvm_sequence_item;
  `uvm_object_utils(Item)
  rand bit [31:0]fp_X, fp_Y;
  rand bit [2:0] r_mode;
  bit [31:0] fp_Z; 
  bit ovrf;
  bit udrf;

  // Constraints
  constraint c_rndm_item  {
    // Exponente
    fp_X[30:23] <= 8'hFE;
    fp_Y[30:23] <= 8'hFE;

    // Fraccion
    //fp_X[22:0] <= 23'h8F;
    //fp_Y[22:0] <= 23'h8F;

  }

  constraint c_r_mode {r_mode<=3'b100;}

  constraint c_ovrflw {
    ((fp_X[30:23]+fp_Y[30:23]-127)==8'hFF)|( (&fp_X[30:23] & ~|fp_X[22:0]) & |fp_Y[30:23] )|( (&fp_Y[30:23] & ~|fp_X[22:0]) & |fp_X[30:23] );
  }

  constraint c_undrflw {
    (fp_X[30:23] + fp_Y[30:23] - 127 <= 0)|(~|fp_X[30:23])|(~|fp_Y[30:23]); 
  }

  constraint c_NaN {
    // Entradas NaN
    // Inf*0
    // 0*Inf
    (&fp_X[30:23] & |fp_X[22:0])|(&fp_Y[30:23] & |fp_Y[22:0])|((&fp_X[30:23] & ~|fp_X[22:0]) & ~|fp_Y[23:0])|((&fp_Y[30:23] & ~|fp_Y[22:0]) & ~|fp_X[23:0]);
  }
  
  virtual function string convert2str();
    return $sformatf("fp_X=%0b, fp_Y=%0b, fp_Z=%0b, r_mode=%0b, ovrf=%0b, udrf=%0b",fp_X, fp_Y, fp_Z, r_mode, ovrf, udrf);
  endfunction
 
  function new(string name = "Item");
    super.new(name);
  endfunction

endclass

