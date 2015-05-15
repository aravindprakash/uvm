//-----------------------------------------------------------------------------
// Copyright (c) 2015, ChipVerify
//-----------------------------------------------------------------------------
// Author         :  Admin
// Email          :  info@chipverify.com
// Description    :  An example of TLM 2.0 sockets & how modules are connected  
//-----------------------------------------------------------------------------

`include "uvm_macros.svh"

import uvm_pkg::*;
//-----------------------------------------------------------------------------
//                            simple_packet
//-----------------------------------------------------------------------------

// This is a transaction class in TLM, whose object will float around the env
class simple_packet extends uvm_sequence_item;
	
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
//                            initiator
//-----------------------------------------------------------------------------

class initiator extends uvm_component;
   `uvm_component_utils (initiator)

   // Create a blocking transport socket
   uvm_tlm_b_initiator_socket #(simple_packet) initSocket;
   uvm_tlm_time   delay;
   simple_packet  pkt;

   function new (string name = "initiator", uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      initSocket = new ("initSocket", this);
      delay = new ();
   endfunction

   virtual task run_phase (uvm_phase phase);
      // Let us generate 5 packets and send it via the put_port
      repeat (5) begin
         pkt = simple_packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
         `uvm_info ("INIT", "Packet sent to target", UVM_LOW)
         pkt.print (uvm_default_line_printer);
         initSocket.b_transport (pkt, delay);
      end
   endtask
endclass

//-----------------------------------------------------------------------------
//                            target
//-----------------------------------------------------------------------------

class target extends uvm_component;
   `uvm_component_utils (target)

   // Create a blocking target socket
   uvm_tlm_b_target_socket #(target, simple_packet) targetSocket;

   function new (string name = "target", uvm_component parent = null);
      super.new (name, parent);
   endfunction
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      targetSocket = new ("targetSocket", this);
   endfunction

   task b_transport (simple_packet pkt, uvm_tlm_time delay);
      `uvm_info ("TGT", "Packet received from Initiator", UVM_MEDIUM)
      pkt.print (uvm_default_line_printer);
   endtask
endclass

//-----------------------------------------------------------------------------
//                            my_env
//-----------------------------------------------------------------------------

class my_env extends uvm_env;
   `uvm_component_utils (my_env)

   initiator   init;
   target      tgt;

   function new (string name = "my_env", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      init = initiator::type_id::create ("init", this);
      tgt = target::type_id::create ("tgt", this);
   endfunction

   virtual function void connect_phase (uvm_phase phase);
      init.initSocket.connect (tgt.targetSocket);  
   endfunction
endclass

//-----------------------------------------------------------------------------
