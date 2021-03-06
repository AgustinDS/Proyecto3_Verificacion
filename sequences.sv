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
    `uvm_info("SEQ", "Start of basic random sequence", UVM_HIGH)
    for(int i = 0; i < n; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_rndm_item.constraint_mode(1);
      item.c_r_mode.constraint_mode(1);
      item.c_ovrflw.constraint_mode(0);
      item.c_undrflw.constraint_mode(0);
      item.c_NaN.constraint_mode(0);

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
  bit [31:0] seq_values[4] = {32'h0, 32'hFFFFFFFF, 32'h55555555, 32'hAAAAAAAA};

  int n = 0;

  virtual task body();
    `uvm_info("SEQ", "Start of basic specific sequence", UVM_HIGH)
    foreach(seq_values[i]) begin
      foreach(seq_values[j]) begin
        Item item = Item::type_id::create("item");
        
        start_item(item);

        // Configuración de constraints
        item.c_rndm_item.constraint_mode(0);
        item.c_r_mode.constraint_mode(0);
        item.c_ovrflw.constraint_mode(0);
        item.c_undrflw.constraint_mode(0);
        item.c_NaN.constraint_mode(0);

        // Se usa randomize para aleatorizar el modo de redondeo
        if( !item.randomize() )
          `uvm_error("SEQ", "Randomize failed")

        item.fp_X = seq_values[i];
        item.fp_Y = seq_values[j];

        n++;

        `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
        finish_item(item);
      end
    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n), UVM_LOW);
  endtask

endclass

// Secuencia que genere overflow
class seq_ovrflw extends uvm_sequence;
  `uvm_object_utils(seq_ovrflw);
  
  function new(string name="seq_ovrflw");
    super.new(name);
  endfunction

  // Cantidad de transacciones generadas en la secuencia
  rand int n;

  // Limite de la cantidad aleatoria de transacciones generadas
  constraint c_n {soft n inside {[5:10]};}

  virtual task body();
    for(int i = 0; i < n; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);

      item.c_rndm_item.constraint_mode(0);
      item.c_ovrflw.constraint_mode(1);
      item.c_undrflw.constraint_mode(0);
      item.c_NaN.constraint_mode(0);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Randomize failed")
      
      `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask
endclass


// Secuencia que genere underflow
class seq_undrflw extends uvm_sequence;
  `uvm_object_utils(seq_undrflw);
  
  function new(string name="seq_undrflw");
    super.new(name);
  endfunction

  // Cantidad de transacciones generadas en la secuencia
  rand int n;

  // Limite de la cantidad aleatoria de transacciones generadas
  constraint c_n {soft n inside {[5:10]};}

  virtual task body();
    for(int i = 0; i < n; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);

      item.c_rndm_item.constraint_mode(0);
      item.c_ovrflw.constraint_mode(0);
      item.c_undrflw.constraint_mode(1);
      item.c_NaN.constraint_mode(0);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Randomize failed")
      
      `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask
endclass

// Secuencia que genere NaN
class seq_NaN extends uvm_sequence;
  `uvm_object_utils(seq_NaN);
  
  function new(string name="seq_NaN");
    super.new(name);
  endfunction

  // Cantidad de transacciones generadas en la secuencia
  rand int n;

  // Limite de la cantidad aleatoria de transacciones generadas
  constraint c_n {soft n inside {[5:10]};}

  virtual task body();
    for(int i = 0; i < n; i++)begin
      
      Item item = Item::type_id::create("item");

      // Configuración de constraints
      item.c_r_mode.constraint_mode(1);

      item.c_rndm_item.constraint_mode(0);
      item.c_ovrflw.constraint_mode(0);
      item.c_undrflw.constraint_mode(0);
      item.c_NaN.constraint_mode(1);

      start_item(item);

      if( !item.randomize() )
        `uvm_error("SEQ", "Randomize failed")
      
      `uvm_info("SEQ",$sformatf("New item: %s", item.convert2str()), UVM_HIGH);
      
      finish_item(item);

    end

    `uvm_info("SEQ",$sformatf("Done generation of %0d items", n),UVM_LOW);
  endtask
endclass

class seq_esc1 extends  uvm_sequence;
  // Escenario 1, dos tipos de secuencias:
  // Aleatorio
  // Alternancia

  `uvm_object_utils(seq_esc1);
  
  function new(string name="seq_esc1");
    super.new(name);
  endfunction

  base_seq seq_aleat;
  esp_seq seq_alt;

  task body();
    `uvm_do(seq_alt);
    `uvm_do(seq_aleat);
  endtask : body


endclass : seq_esc1

class seq_esc2 extends  uvm_sequence;
  // Escenario 2, tres tipos de secuencias:
  // Overflow
  // Underflow
  // NaN

  `uvm_object_utils(seq_esc2);
  
  function new(string name="seq_esc2");
    super.new(name);
  endfunction

  seq_ovrflw of_seq;
  seq_undrflw uf_seq;
  seq_NaN NaN_seq;

  task body();
    `uvm_do(of_seq);
    `uvm_do(uf_seq);
    `uvm_do(NaN_seq);
  endtask : body


endclass : seq_esc2