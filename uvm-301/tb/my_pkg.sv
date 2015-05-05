//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------

`include "uvm_macros.svh"

package my_pkg;
   // If you don't use this, it'll complain that it doesn't recognize uvm components
   import uvm_pkg::*;

   typedef class my_driver;               
   typedef class my_monitor;
   typedef class my_data;
   typedef class base_sequence;

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_env   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_env extends uvm_env ;
   
      `uvm_component_utils (my_env)

      my_driver   m_drv0;
      my_monitor  m_mon0;
      uvm_sequencer #(my_data) m_seqr0;
   
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
   
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
         m_mon0 = my_monitor::type_id::create ("m_mon0", this);
         m_seqr0 = uvm_sequencer#(my_data)::type_id::create ("m_seqr0", this);
      endfunction : build_phase

      virtual function void connect_phase (uvm_phase phase);
         super.connect_phase (phase);
         m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
      endfunction
   
   endclass : my_env

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_data  {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_data extends uvm_sequence_item;
         
      rand bit [7:0]   data;
      rand bit [7:0]   addr;

      constraint c_addr { addr > 0; addr < 8;}

      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_object_utils_end
      
   endclass   

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_driver   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_driver extends uvm_driver #(my_data);
      `uvm_component_utils (my_driver)

      my_data           data_obj;
      virtual  dut_if   vif;
      
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "vif", vif)) begin
            `uvm_fatal (get_type_name (), "Didn't get handle to virtual interface dut_if")
         end

      endfunction

      task reset_phase (uvm_phase phase);
         super.reset_phase (phase);
         phase.raise_objection (phase);
         `uvm_info (get_type_name (), $sformatf ("Applying initial reset"), UVM_MEDIUM)
         this.vif.rstn = 0;
         repeat (20) @ (posedge vif.clk);
         this.vif.rstn = 1;
         `uvm_info (get_type_name (), $sformatf ("DUT is now out of reset"), UVM_MEDIUM)
         phase.drop_objection (phase);
      endtask

      task main_phase (uvm_phase phase);
         super.main_phase (phase);
         forever begin
            `uvm_info (get_type_name (), $sformatf ("Waiting for data from sequencer"), UVM_MEDIUM)
            seq_item_port.get_next_item (data_obj);
            drive_item (data_obj);
            seq_item_port.item_done ();
         end
      endtask

      virtual task drive_item (my_data data_obj);
         @(posedge vif.clk);
         this.vif.en    = 1;
         this.vif.wr    = 1;
         this.vif.addr  = data_obj.addr;
         this.vif.wdata = data_obj.data;
         `uvm_info ("DRV", $sformatf ("Driving data item across DUT interface"), UVM_HIGH)
         data_obj.print (uvm_default_tree_printer);
      endtask

      task shutdown_phase (uvm_phase phase);
         super.shutdown_phase (phase);
         `uvm_info (get_type_name(), "Finished DUT simulation", UVM_LOW)
      endtask

   endclass

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_monitor {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_monitor extends uvm_monitor;
      `uvm_component_utils (my_monitor)
      
      virtual dut_if vif;   
      my_data        data_obj;
   
      function new (string name, uvm_component parent= null);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "vif", vif)) begin
            `uvm_error (get_type_name (), "DUT interface not found")
         end
      endfunction

      task main_phase (uvm_phase phase);
         super.main_phase (phase);
         data_obj = my_data::type_id::create ("data_obj", this);

         forever begin
            @(posedge vif.clk);
            if (vif.wr & vif.en & vif.rstn) begin
               `uvm_info ("MON", $sformatf ("Monitor received data for WR operation"), UVM_HIGH)
               data_obj.addr = vif.addr;
               data_obj.data = vif.wdata;
               data_obj.print (uvm_default_table_printer);
            end
            if (!vif.wr & vif.en & vif.rstn) begin
               `uvm_info ("MON", $sformatf ("Monitor received data for RD operation"), UVM_HIGH)
               data_obj.addr = vif.addr;
               data_obj.data = vif.rdata;
               data_obj.print (uvm_default_table_printer);
            end
            // What to do with this data will be in next session
         end
      endtask
   endclass

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_sequence   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class base_sequence extends uvm_sequence;
      `uvm_object_utils (base_sequence)

      my_data  data_obj;
      int unsigned      n_times;

      function new (string name = "base_sequence");
         super.new (name);
      endfunction

      // Raise an objection if started as the root sequence
      virtual task pre_body ();
         if (starting_phase != null)
            starting_phase.raise_objection (this);
      endtask

      virtual task body ();
         `uvm_info ("BASE_SEQ", $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)
         data_obj = my_data::type_id::create ("data_obj");

         repeat (n_times) begin
            start_item (data_obj);
            assert (data_obj.randomize ());
            finish_item (data_obj);
         end
         `uvm_info (get_type_name (), $sformatf ("Sequence %s is over", this.get_name()), UVM_MEDIUM)
      endtask
      
      // Drop objection if started as the root sequence
      virtual task post_body ();
         if (starting_phase != null) 
            starting_phase.drop_objection (this);
      endtask
   endclass

endpackage

