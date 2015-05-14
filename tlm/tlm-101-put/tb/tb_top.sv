//-----------------------------------------------------------------------------
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------

`include "timescale.v"

module tb_top;
   import uvm_pkg::*;
   
//-----------------------------------------------------------------------------
// At start of simulation, set the interface handle as a config object in UVM 
// database. This IF handle can be retrieved in the test using the get() method
// run_test () accepts the test name as argument. In this case, base_test will
// be run for simulation
//-----------------------------------------------------------------------------
   initial begin
      run_test ("base_test");
   end

endmodule
