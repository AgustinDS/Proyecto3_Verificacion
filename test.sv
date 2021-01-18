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

class test_1011 extends base_test;
  `uvm_component_utils(test_1011)
  
  function new(string name="test_1011",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
  endfunction
  /*
  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);
    // apply_reset();
    seq.start(e0.a0.s0);
    #200;
    phase.drop_objection(this);

  endtask
  */
endclass
