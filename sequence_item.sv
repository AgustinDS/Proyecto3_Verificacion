class Item extends uvm_sequence_item;
  `uvm_object_utils(Item)
  rand bit [31:0]fp_X, fp_Y;
  rand bit [2:0] r_mode;
  bit [31:0] fp_Z; 
  bit ovrf;
  bit udrf;

  rand bit sgn_X;
  rand bit sgn_Y;

  rand bit [7:0] exp_X;
  rand bit [7:0] exp_Y;

  rand bit [22:0] frac_X;
  rand bit [22:0] frac_Y;

  // Constraints
  constraint c_rndm_item  {
    exp_X <= 8'h8F;
    exp_Y <= 8'h8f;
  }

  constraint c_ovrflw {
    //
  }

  constraint c_undrflw {
    
  }

  constraint c_NaN {
    
  }
  
  virtual function string convert2str();
    return $sformatf("fp_X=%0b, fp_Y=%0b, fp_Z=%0b, r_mode=%0b, ovrf=%0b, udrf=%0b",fp_X, fp_Y, fp_Z, r_mode, ovrf, udrf);
  endfunction
 
  function new(string name = "Item");
    super.new(name);
  endfunction

endclass

