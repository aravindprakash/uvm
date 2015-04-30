//-----------------------------------------------------------------------------
// Author      :  Admin @ www.chipverify.com
// Email       :  contact@chipverify.com
// Description :  Top Level Design Module - This is what we have to verify.
//                This simple design accepts data into the memory upon write
//                request and provides data from memory on read request.
//                addr acts as the index to the memory space.
//-----------------------------------------------------------------------------

`include "timescale.v"

module dut (   
               input    clk,                 // Clock at some freq
               input    rstn,                // Active Low  Sync Reset
               input    wr,                  // Active High Write
               input    en,                  // Module Enable
               input    wdata,               // Write Data
               input    addr,                // Address

               output   rdata                // Read Data
            );

   parameter DEPTH = 8;                      // Depth of Memory Element

   reg [7:0]   rdata_syn;                    // rdata synced with clock
   reg [7:0]   mem [DEPTH];                  // Memory element

   //--------------------------------------------------------------------------
   // Write data into the memory space
   //--------------------------------------------------------------------------

   always @ (posedge clk) begin
      if (!rstn) begin
         for (int i = 0; i < $size(mem); i++) begin
            mem[i] <= 0;
         end
      end else begin
         if (en & wr) begin
            mem [addr] <= wdata;
         end
      end
   end

   //--------------------------------------------------------------------------
   // Read data from memory space
   //--------------------------------------------------------------------------

   always @ (posedge clk) begin
      if (!rstn) begin
         rdata_syn <= 0;
      end else begin
         if (!wr & en) begin
            rdata_syn <= mem [addr];
         end
      end
   end

   //--------------------------------------------------------------------------
   // Assign rdata_syn to output 
   //--------------------------------------------------------------------------
   assign rdata = rdata_syn;

endmodule 
