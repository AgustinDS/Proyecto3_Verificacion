class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  function new(string name="monitor",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(Item) mon_analysis_port;
  virtual dut_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","des_vif",vif))
      `uvm_fatal("MON","Could not get vif")
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever @(vif.cb) begin
      
      Item item = Item::type_id::create("item");

      //El monitor toma tanto las entradas como las salidas de una operación ya ejecutada [anterior]

      //toma el valor de todas las salidas que había justo antes del posedge del reloj [anterior]
      item.fp_Z = vif.cb.fp_Z;   //Salida
      item.ovrf = vif.cb.ovrf;   // overflow
      item.udrf = vif.cb.udrf;   //underflow

      //antes de que pasen 3nS se toma el valor del item en las entradas del dut [anterior]
      item.r_mode = vif.r_mode;  //mode
      item.fp_X = vif.fp_X;      //A
      item.fp_Y = vif.fp_Y;      //B
      mon_analysis_port.write(item);
      `uvm_info("MON",$sformatf("SAW item %s", item.convert2str()),UVM_HIGH)
    
    end
  endtask
endclass