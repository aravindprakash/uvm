//-----------------------------------------------------------------------------
// Copyright (c) 2015, ChipVerify
//-----------------------------------------------------------------------------
// Author         :  Admin
// Email          :  info@chipverify.com
// Description    :  An example of TLM and how modules are connected  
//-----------------------------------------------------------------------------

`include "uvm_macros.svh"

import uvm_pkg::*;
//-----------------------------------------------------------------------------
//                            simple_packet
//-----------------------------------------------------------------------------

// This is a transaction class in TLM, whose object will float around the env
class simple_packet extends uvm_object;
	
	rand bit [7:0] addr;
	rand bit [7:0] data;
		 bit 		rwb;
	
   `uvm_object_utils_begin (simple_packet)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
      `uvm_field_int (rwb, UVM_ALL_ON)
   `uvm_object_utils_end

	constraint c_addr { addr > 8'h2a; }
	constraint c_data { data inside {[8'h14:8'he9]}; }
	
endclass

//-----------------------------------------------------------------------------
//                            componentA
//-----------------------------------------------------------------------------

class componentA extends uvm_component;
   `uvm_component_utils (componentA)

   // We are creating a put_port which will accept a "simple_packet" type of data
   uvm_blocking_put_port #(simple_packet) put_port;
   simple_packet  pkt;

   function new (string name = "componentA", uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      put_port = new ("put_port", this);
   endfunction

   virtual task run_phase (uvm_phase phase);
      // Let us generate 5 packets and send it via the put_port
      repeat (5) begin
         pkt = simple_packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
         put_port.put (pkt);
         `uvm_info ("COMPA", "Packet sent to CompB", UVM_LOW)
         pkt.print (uvm_default_line_printer);
      end
   endtask
endclass

//-----------------------------------------------------------------------------
//                            componentB
//-----------------------------------------------------------------------------

class componentB extends uvm_component;
   `uvm_component_utils (componentB)
   
   // Mention type of transaction, and type of class that implements the put ()
   uvm_blocking_get_port #(simple_packet) get_port;

   function new (string name = "componentB", uvm_component parent = null);
      super.new (name, parent);
   endfunction
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      get_port = new ("get_port", this);
   endfunction

   virtual task run_phase (uvm_phase phase);
      simple_packet pkt;
      phase.raise_objection (this);
      repeat (5) begin
         #10;
         get_port.get (pkt);
         `uvm_info ("COMPB", "ComponentA just gave me the packet", UVM_LOW)
         pkt.print ();
      end
      phase.drop_objection (this);
   endtask

endclass

//-----------------------------------------------------------------------------
//                            my_env
//-----------------------------------------------------------------------------

class my_env extends uvm_env;
   `uvm_component_utils (my_env)

   componentA compA;
   componentB compB;
   uvm_tlm_fifo #(simple_packet)    tlm_fifo;

   function new (string name = "my_env", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      compA = componentA::type_id::create ("compA", this);
      compB = componentB::type_id::create ("compB", this);
      // Create a FIFO with depth 2
      tlm_fifo = new ("tlm_fifo", this, 2);
   endfunction

   virtual function void connect_phase (uvm_phase phase);
      compA.put_port.connect (tlm_fifo.put_export);
      compB.get_port.connect (tlm_fifo.get_export);
   endfunction

   virtual task run_phase (uvm_phase phase);
      forever begin
         #10 if (tlm_fifo.is_full ()) 
               `uvm_info ("TLMFIFO", "Fifo is now FULL !", UVM_MEDIUM)
      end
   endtask

endclass

//-----------------------------------------------------------------------------
