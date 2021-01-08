class Item extends uvm_sequence_item;
  `uvm_object_utils(Item)
  rand bit [31:0]fp_X, fp_Y;
  rand bit [2:0] r_mode;
  bit [31:0] fp_Z; 
  bit ovrf;
  bit udrf;
  

  virtual function string convert2str();
    return $sformatf("fp_X=%0b, fp_Y=%0b, fp_Z=%0b, r_mode=%0b, ovrf=%0b, udrf=%0b",fp_X, fp_Y, fp_Z, r_mode, ovrf, udrf);
  endfunction
 
  function new(string name = "Item");
    super.new(name);
  endfunction

endclass

