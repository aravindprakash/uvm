//-----------------------------------------------------------------------------
// Copyright (c) 2015, ChipVerify
//-----------------------------------------------------------------------------
// Author         :  Admin
// Email          :  info@chipverify.com
// Description    :  An example of how componentA requests information from 
//                   componentB. 
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

   // Create an export to send data to componentB
   uvm_blocking_get_imp #(simple_packet, componentA) get_export;
   simple_packet  pkt;

   function new (string name = "componentA", uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Remember that put_port is a class object and it will have to be 
      // created with new ()
      get_export = new ("put_port", this);
   endfunction

   // This task will output a new packet 
   virtual task get (output simple_packet pkt);
      // Create a new packet
      pkt = new();
      assert (pkt.randomize());
      `uvm_info ("COMPA", "ComponentB has requested for a packet, give the following packet to componentB", UVM_LOW)
      pkt.print (uvm_default_line_printer);
   endtask
endclass

//-----------------------------------------------------------------------------
//                            componentB
//-----------------------------------------------------------------------------

class componentB extends uvm_component;
   `uvm_component_utils (componentB)
   
   uvm_blocking_get_port #(simple_packet) get_port;

   function new (string name = "componentB", uvm_component parent = null);
      super.new (name, parent);
   endfunction
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      get_port = new ("put_export", this);
   endfunction

   virtual task run_phase (uvm_phase phase);
      simple_packet pkt;
      repeat (5) begin
         get_port.get (pkt);
         `uvm_info ("COMPB", "ComponentA just gave me the packet", UVM_LOW)
         pkt.print ();
      end
   endtask
endclass

//-----------------------------------------------------------------------------
//                            my_env
//-----------------------------------------------------------------------------

class my_env extends uvm_env;
   `uvm_component_utils (my_env)

   componentA compA;
   componentB compB;

   function new (string name = "my_env", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      compA = componentA::type_id::create ("compA", this);
      compB = componentB::type_id::create ("compB", this);
   endfunction

   virtual function void connect_phase (uvm_phase phase);
      compB.get_port.connect (compA.get_export);  
   endfunction
endclass

//-----------------------------------------------------------------------------
