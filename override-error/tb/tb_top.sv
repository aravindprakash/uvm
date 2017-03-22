`timescale 1ns/1ns

`include "uvm_macros.svh"
import uvm_pkg::*;

// Original Environment
class base_env extends uvm_env;
   `uvm_component_utils (base_env)
   function new (string name = "base_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction
endclass

// Original test that uses the env
class base_test extends uvm_test;
   `uvm_component_utils (base_test)
   function new (string name = "base_test", uvm_component parent=null);
      super.new (name, parent);
   endfunction

   base_env    m_base_env;

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_base_env = base_env::type_id::create ("m_base_env", this); 
   endfunction
endclass

module top;
   import uvm_pkg::*;
   
   initial 
      run_test ("base_test");
endmodule
