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

  virtual task body();
      
    // 0s
    Item item = Item::type_id::create("item0");

    start_item(item);

    item.fp_X = 0;
    item.fp_Y = 0;
    item.r_mode = 0;
    
    `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
    
    finish_item(item);

    // Fs
    Item item = Item::type_id::create("itemF");

    start_item(item);

    item.fp_X = 32'hFFFFFFFF;
    item.fp_Y = 32'hFFFFFFFF;
    item.r_mode = 1;
    
    `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
    
    finish_item(item);

    // 5s
    Item item = Item::type_id::create("item5");

    start_item(item);

    item.fp_X = 32'h55555555;
    item.fp_Y = 32'h55555555;
    item.r_mode = 0;
    
    `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
    
    finish_item(item);

    // As
    Item item = Item::type_id::create("item5");

    start_item(item);

    item.fp_X = 32'hAAAAAAAA;
    item.fp_Y = 32'hAAAAAAAA;
    item.r_mode = 1;
    
    `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
    
    finish_item(item);

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask

endclass

// Secuencia que genere overflow


// Secuencia que genere underflow


// Secuencia que genere NaN