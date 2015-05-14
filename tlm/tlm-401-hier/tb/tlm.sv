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
//                            subComponent1
//-----------------------------------------------------------------------------

class subComponent1 extends uvm_component;
   `uvm_component_utils (subComponent1)

   // We are creating a put_port which will accept a "simple_packet" type of data
   uvm_blocking_put_port #(simple_packet) put_port;
   simple_packet  pkt;

   function new (string name = "subComponent1", uvm_component parent= null);
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
         `uvm_info ("SCOMP1", "Packet sent to SCOMP2", UVM_LOW)
         pkt.print (uvm_default_line_printer);
      end
   endtask
endclass

//-----------------------------------------------------------------------------
//                            subComponent2
//-----------------------------------------------------------------------------

class subComponent2 extends uvm_component;
   `uvm_component_utils (subComponent2)
   
   // Mention type of transaction, and type of class that implements the put ()
   uvm_blocking_get_port #(simple_packet) get_port;
   uvm_put_port #(simple_packet)          put_portA;

   function new (string name = "subComponent2", uvm_component parent = null);
      super.new (name, parent);
   endfunction
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      get_port = new ("get_port", this);
      put_portA = new ("put_portA", this);
   endfunction

   virtual task run_phase (uvm_phase phase);
      simple_packet pkt;
      phase.raise_objection (this);
      repeat (5) begin
         #10;
         get_port.get (pkt);
         `uvm_info ("SCOMP2", "subComponent1 just gave me the packet", UVM_LOW)
         pkt.print ();
         `uvm_info ("SCOMP2", "Send this to subComponent3", UVM_LOW)
         put_portA.put (pkt);
      end
      phase.drop_objection (this);
   endtask

endclass

//-----------------------------------------------------------------------------
//                               componentA 
//-----------------------------------------------------------------------------

class componentA extends uvm_component;
   `uvm_component_utils (componentA)

   subComponent1 subComp1;
   subComponent2 subComp2;
   uvm_tlm_fifo #(simple_packet)    tlm_fifo;
   uvm_put_port #(simple_packet)  put_portA;

   function new (string name = "componentA", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      subComp1 = subComponent1::type_id::create ("subComp1", this);
      subComp2 = subComponent2::type_id::create ("subComp2", this);
      // Create a FIFO with depth 2
      tlm_fifo = new ("tlm_fifo", this, 2);
      put_portA = new ("put_portA", this);
   endfunction

   virtual function void connect_phase (uvm_phase phase);
      subComp1.put_port.connect (tlm_fifo.put_export);
      subComp2.get_port.connect (tlm_fifo.get_export);

      // Connect put_portA of componentA with subComponent2
      subComp2.put_portA.connect (this.put_portA);
   endfunction

   virtual task run_phase (uvm_phase phase);
      forever begin
         #10 if (tlm_fifo.is_full ()) 
               `uvm_info ("TLMFIFO1", "Fifo is now FULL !", UVM_MEDIUM)
      end
   endtask

endclass    

//-----------------------------------------------------------------------------
//                            subComponent3
//-----------------------------------------------------------------------------

class subComponent3 extends uvm_component;
   `uvm_component_utils (subComponent3)
   
   // Mention type of transaction, and type of class that implements the put ()
   uvm_blocking_get_port #(simple_packet) get_port;

   function new (string name = "subComponent3", uvm_component parent = null);
      super.new (name, parent);
   endfunction
   
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      get_port = new ("get_port", this);
   endfunction

   virtual task run_phase (uvm_phase phase);
      simple_packet pkt;
      repeat (5) begin
         get_port.get (pkt);
         `uvm_info ("SCOMP3", "Got a packet from subComponent2", UVM_LOW)
         pkt.print ();
      end
   endtask

endclass

//-----------------------------------------------------------------------------
//                               componentB 
//-----------------------------------------------------------------------------

class componentB extends uvm_component;
   `uvm_component_utils (componentB)

   subComponent3 subComp3;
   uvm_tlm_fifo #(simple_packet)    tlm_fifo;
   uvm_put_export #(simple_packet)  put_export;

   function new (string name = "componentB", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      subComp3 = subComponent3::type_id::create ("subComp3", this);
      // Create a FIFO with depth 2
      tlm_fifo = new ("tlm_fifo", this, 2);
      put_export = new ("put_export", this);
   endfunction

   virtual function void connect_phase (uvm_phase phase);
      // Connect from componentB export to FIFO export
      put_export.connect (tlm_fifo.put_export);
      // Connect from FIFO export to subComponent3 port 
      subComp3.get_port.connect (tlm_fifo.get_export);
   endfunction

   virtual task run_phase (uvm_phase phase);
      forever begin
         #10 if (tlm_fifo.is_full ()) 
               `uvm_info ("TLMFIFO2", "Fifo is now FULL !", UVM_MEDIUM)
      end
   endtask

endclass 

//-----------------------------------------------------------------------------
//                               my_env
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
      compA = componentA::type_id::create ("compA", this);
      compB = componentB::type_id::create ("compB", this);
   endfunction
   
   virtual function void connect_phase (uvm_phase phase);
      compA.put_portA.connect (compB.put_export);
   endfunction

endclass


//-----------------------------------------------------------------------------
