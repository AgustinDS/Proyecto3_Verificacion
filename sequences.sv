// Secuencia aleatoria básica
class base_seq extends uvm_sequence;
  
  `uvm_object_utils(base_seq);
  
  function new(string name="base_seq");
    super.new(name);
  endfunction

  // Cantidad de transacciones generadas en la secuencia
  rand int n;

  // Limite de la cantidad aleatoria de transacciones generadas
  constraint c_n {soft n inside {[5:10]};}

  virtual task body();
    for(int i = 0; i < n; i++)begin
      
      Item item = Item::type_id::create("item");

      start_item(m_item);

      if( !m_item.randomize() )
        `uvm_error("SEQ", "Randomize failed")
      
      `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end
    
    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask

endclass