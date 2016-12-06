//-----------------------------------------------------------------------------
// Author      :  Aravind Prakash
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------

`timescale 1ns/1ns

`include "uvm_macros.svh"
import uvm_pkg::*;

class my_env extends uvm_env;
   `uvm_component_utils (my_env)
   function new (string name = "my_env", uvm_component parent);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      int cnt = 1;
      super.build_phase (phase);

`ifdef RESOURCE       
      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s", cnt, phase.get_name()), UVM_MEDIUM)
`else
      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s", cnt, phase.get_name()), UVM_MEDIUM)
`endif
   endfunction
endclass

class base_test extends uvm_test;
   `uvm_component_utils (base_test)
   function new (string name, uvm_component parent = null);
      super.new (name, parent);
   endfunction : new

   my_env m_env;
   
   virtual function void build_phase (uvm_phase phase);
      int cnt = 4;
      super.build_phase (phase);

      m_env = my_env::type_id::create ("m_env", this);

`ifdef RESOURCE 
      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
`else
      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
`endif
   endfunction

   virtual function void start_of_simulation_phase (uvm_phase phase);
      int rt,  cnt;
      uvm_config_db #(int)::get (null, "uvm_test_top", "count", rt);
      `uvm_info ("PRINT", $sformatf ("Got cnt=%0d using uvm_config_db in %s phase", rt, phase.get_name()), UVM_MEDIUM)

      cnt = 123;
`ifdef RESOURCE
      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
`else
      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
`endif
   endfunction

   virtual task main_phase (uvm_phase phase);
      int rt2;
      super.main_phase (phase);
      
      uvm_config_db #(int)::get (null, "uvm_test_top", "count", rt2);
      `uvm_info ("PRINT", $sformatf ("Got cnt=%0d using config_db in %s phase", rt2, phase.get_name()), UVM_MEDIUM)
   endtask
endclass 


module top;
   import uvm_pkg::*;
   
   initial 
      run_test ("base_test");
endmodule
