// Way to pass an interface handle to TB components without using uvm_config_db or uvm_resource_db

`include "uvm_macros.svh"
import uvm_pkg::*;

// Create a sample interface to play around with. Let it have a variable and a way to print 
// it when it is changed externally
interface my_if;
   logic [31:0] addr;

   always @ (addr)
      $display ("Check: addr=0x%0h", addr);
endinterface

// Create a UVM test class to run and test if a virtual interface can be assigned via a
// hierarchical statement
class my_test extends uvm_test;
   `uvm_component_utils (my_test)
   function new (string name = "my_test", uvm_component parent);
      super.new (name, parent);
   endfunction
   
   virtual my_if  if0;

   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      if0 = tb._if;
   endfunction

   virtual task run_phase (uvm_phase phase);
      phase.raise_objection (this);
      #10 if0.addr = 32'h0000_1111;
      #10 if0.addr = 32'hfade_fade;
      #10 if0.addr = 32'hcafe_cafe;
      phase.drop_objection (this);
   endtask
endclass

// Main testbench module to hold the main interface object and to kick off "my_test" 
module tb;
   my_if _if();

   initial 
      run_test ("my_test");
endmodule


/* Simulation Log

run -all;
# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test my_test...
# KERNEL: Check: addr=0x1111
# KERNEL: Check: addr=0xfadefade
# KERNEL: Check: addr=0xcafecafe
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 30: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(855) @ 30: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    3
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [TEST_DONE]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
# KERNEL: Time: 30 ns,  Iteration: 56,  Instance: /tb,  Process: @INITIAL#45_0@.
# KERNEL: stopped at time: 30 ns
# VSIM: Simulation has finished. There are no more test vectors to simulate.

*/
