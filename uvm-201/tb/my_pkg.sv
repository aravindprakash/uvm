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
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_env
   //---------------------------------------------------------------------------------------------------------------------
   class my_env extends uvm_env ;
   
      `uvm_component_utils (my_env)

      my_driver   m_drv0;
   
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
   
      function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
      endfunction : build_phase
   
   endclass : my_env

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_data
   //---------------------------------------------------------------------------------------------------------------------
   class my_data extends uvm_sequence_item;
      `uvm_object_utils (my_data)
         
      rand bit [7:0]   data;
      rand bit [7:0]   addr;

      constraint c_addr { addr > 0; addr < 8;}
      
      virtual function void display ();
         `uvm_info (get_type_name (), $sformatf ("addr = 0x%0h, data = 0x%0h", addr, data), UVM_MEDIUM);
      endfunction
      
   endclass   

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_driver
   //---------------------------------------------------------------------------------------------------------------------
   class my_driver extends uvm_driver;
      `uvm_component_utils (my_driver)

      int unsigned      n_times;
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
         `uvm_info (get_type_name (), $sformatf ("Applying initial reset"), UVM_MEDIUM)
         this.vif.rstn = 0;
         repeat (20) @ (posedge vif.clk);
         this.vif.rstn = 1;
         `uvm_info (get_type_name (), $sformatf ("DUT is now out of reset"), UVM_MEDIUM)
      endtask

      task main_phase (uvm_phase phase);
         super.main_phase (phase);
         phase.raise_objection (phase);
         `uvm_info (get_type_name (), $sformatf ("Inside Main phase"), UVM_MEDIUM)

         // Let's create a data object, randomize it and send it to the DUT
         n_times = 5;
         repeat (n_times) begin
            `uvm_info (get_type_name (), $sformatf ("Generate and randomize data packet"), UVM_DEBUG)
            data_obj = my_data::type_id::create ("data_obj", this);
            assert(data_obj.randomize ());
            @(posedge vif.clk);
            `uvm_info (get_type_name (), $sformatf ("Drive data packet to DUT"), UVM_DEBUG)
            this.vif.en    = 1;
            this.vif.wr    = 1;
            this.vif.addr  = data_obj.addr;
            this.vif.wdata = data_obj.data;
            data_obj.display ();
         end
         phase.drop_objection (phase);
      endtask

      task shutdown_phase (uvm_phase phase);
         super.shutdown_phase (phase);
         `uvm_info (get_type_name(), "Finished DUT simulation", UVM_LOW)
      endtask

   endclass
endpackage

