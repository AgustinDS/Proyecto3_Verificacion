class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  
  function new(string name = "base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  env e0;
  base_seq  seq;
  virtual dut_if  vif;

  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    e0 = env::type_id::create("e0",this);

    if(!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif",vif))
      `uvm_fatal("TEST","Did not get vif")
    uvm_config_db#(virtual dut_if)::set(this, "e0.a0.*","dut_vif",vif);
    
    seq = base_seq::type_id::create("seq");
    seq.randomize();

  endfunction

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);
    // apply_reset();
    seq.start(e0.a0.s0);
    #200;
    phase.drop_objection(this);

  endtask

  
endclass

class test_01 extends base_test;
  `uvm_component_utils(test_01)
  
  function new(string name="test_01",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  //env e0;
  seq_esc1 seq;
  //virtual dut_if  vif;

  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    seq = seq_esc1::type_id::create("seq");
    seq.randomize();
  endfunction

  virtual task run_phase(uvm_phase phase);

    `uvm_info("TEST_01", "Starting test execution", UVM_HIGH)
    super.run_phase(phase);

  endtask

endclass

// class test_10 extends  base_test;
// Test del escenario 2: Comportamiento del DUT en casos de error
// Se generan secuencias que causen overflow, underflow y NaN

//   `uvm_component_utils(base_test)
  
//   function new(string name = "base_test",uvm_component parent=null);
//     super.new(name,parent);
//   endfunction
  
//   seq_esc2 seq;

//   virtual function void build_phase(uvm_phase phase);
    
//     super.build_phase(phase);

//     seq = seq_esc2::type_id::create("seq");
//     seq.randomize();
//   endfunction

//   virtual task run_phase(uvm_phase phase);

//     `uvm_info("TEST_10", "Starting test execution", UVM_HIGH)
//     super.run_phase(phase);

//   endtask

// endclass : test_10