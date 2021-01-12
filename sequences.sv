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

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Randomize failed")
      
      `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask

endclass

// Secuencia específica (0s, Fs, 5s, As)
class esp_seq extends uvm_sequence;
  
  `uvm_object_utils(esp_seq);
  
  function new(string name="esp_seq");
    super.new(name);
  endfunction

  // Posibles valores de X y Y
  bit [4] seq_values = {32'h0, 32'hFFFFFFFF, 32'h55555555, 32'hAAAAAAAA};

  virtual task body();
    
    foreach(seq_values[i]) begin
      foreach(seq_values[j]) begin
        Item item = Item::type_id::create("item");
        
        start_item(item);

        // Se usa randomize para aleatorizar el modo de redondeo
        if( !item.randomize() )
          `uvm_error("SEQ", "Randomize failed")

        item.fp_X = seq_values[i];
        item.fp_Y = seq_values[j];

        `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
        finish_item(item);
      end
    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", 4),UVM_LOW);
  endtask

endclass

// Secuencia que genere overflow


// Secuencia que genere underflow


// Secuencia que genere NaN
