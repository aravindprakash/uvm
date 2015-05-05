//-----------------------------------------------------------------------------
// Author      :  Admin @ www.chipverify.com
// Email       :  contact@chipverify.com
// Description :  Wrapper module to simplify DUT instantiation at top level.
//-----------------------------------------------------------------------------

`include "timescale.v"

module dut_wrapper (dut_if _if);

   // Instantiate the design module and connect interface signals to DUT
   dut   dsn0     (  .clk     (_if.clk),
                     .rstn    (_if.rstn),
                     .wr      (_if.wr),
                     .en      (_if.en),
                     .wdata   (_if.wdata),
                     .addr    (_if.addr),
                     .rdata   (_if.rdata));

endmodule
 
