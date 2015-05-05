//-----------------------------------------------------------------------------
// Author      :  Admin @ www.chipverify.com
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------

`include "timescale.v"

interface dut_if (input clk);

   logic          rstn;
   logic [7:0]    wdata;
   logic [7:0]    rdata;
   logic [7:0]    addr;
   logic          wr;
   logic          en;

endinterface  
