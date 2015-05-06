//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------

`include "uvm_macros.svh"

package my_pkg;
   // If you don't use this, it'll complain that it doesn't recognize uvm components
   import uvm_pkg::*;

   typedef class my_driver;               
   typedef class my_monitor;
   typedef class my_data;
   typedef class base_sequence;
   typedef class my_agent;
   typedef class my_cfg;
   typedef class my_scoreboard;

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_env   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_env extends uvm_env ;
   
      `uvm_component_utils (my_env)

      my_agent             m_agnt0;
      my_scoreboard        m_scbd0;
   
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
   
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_agnt0 = my_agent::type_id::create ("my_agent", this);
         m_scbd0 = my_scoreboard::type_id::create ("my_scoreboard", this);
      endfunction : build_phase

      virtual function void connect_phase (uvm_phase phase);
         // Connect the scoreboard with the agent
        m_agnt0.m_mon0.item_collected_port.connect (m_scbd0.data_export); 
      endfunction

   endclass : my_env

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_data  {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_data extends uvm_sequence_item;
         
      rand bit [7:0]   data;
      rand bit [7:0]   addr;

      constraint c_addr { addr > 0; addr < 8;}

      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_object_utils_end
      
   endclass   

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_driver   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_driver extends uvm_driver #(my_data);
      `uvm_component_utils (my_driver)

      my_data           data_obj;
      virtual  dut_if   vif;
      
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
      endfunction

      task reset_phase (uvm_phase phase);
         super.reset_phase (phase);
         phase.raise_objection (phase);
         `uvm_info (get_type_name (), $sformatf ("Applying initial reset"), UVM_MEDIUM)
         this.vif.rstn = 0;
         repeat (20) @ (posedge vif.clk);
         this.vif.rstn = 1;
         `uvm_info (get_type_name (), $sformatf ("DUT is now out of reset"), UVM_MEDIUM)
         phase.drop_objection (phase);
      endtask

      task main_phase (uvm_phase phase);
         forever begin
            `uvm_info (get_type_name (), $sformatf ("Waiting for data from sequencer"), UVM_DEBUG)
            seq_item_port.get_next_item (data_obj);
            drive_item (data_obj);
            seq_item_port.item_done ();
         end
      endtask

      virtual task drive_item (my_data data_obj);
         @(posedge vif.clk);
         this.vif.en    = 1;
         this.vif.wr    = 1;
         this.vif.addr  = data_obj.addr;
         this.vif.wdata = data_obj.data;
         `uvm_info ("DRV", $sformatf ("Driving data item across DUT interface"), UVM_HIGH)
         //data_obj.print (uvm_default_line_printer);
      endtask

      task shutdown_phase (uvm_phase phase);
         super.shutdown_phase (phase);
         `uvm_info (get_type_name(), "Finished DUT simulation", UVM_LOW)
      endtask

   endclass

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_monitor {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_monitor extends uvm_monitor;
      `uvm_component_utils (my_monitor)

      uvm_analysis_port #(my_data)  item_collected_port;
      
      virtual dut_if    vif;   
      my_data           data_obj;
   
      function new (string name, uvm_component parent= null);
         super.new (name, parent);
         item_collected_port = new ("item_collected_port", this);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
      endfunction

      task main_phase (uvm_phase phase);
         fork 
            collect_transaction ();
         join_none
      endtask

      virtual task collect_transaction ();
         data_obj = my_data::type_id::create ("data_obj", this);
         forever @(posedge vif.clk) begin
            if (vif.en & vif.rstn) begin
               if (vif.wr) begin
                  `uvm_info ("MON", $sformatf ("Monitor received data for WR operation"), UVM_HIGH)
                  data_obj.addr = vif.addr;
                  data_obj.data = vif.wdata;
               end else begin
                  `uvm_info ("MON", $sformatf ("Monitor received data for RD operation"), UVM_HIGH)
                  data_obj.addr = vif.addr;
                  data_obj.data = vif.rdata;
               end
               data_obj.print (uvm_default_table_printer);
               item_collected_port.write (data_obj);
            end
         end
      endtask
   endclass

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_sequence   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class base_sequence extends uvm_sequence #(my_data);
      `uvm_object_utils (base_sequence)

      my_data  data_obj;

      function new (string name = "base_sequence");
         super.new (name);
      endfunction

      // Raise an objection if started as the root sequence
      virtual task pre_body ();
         if (starting_phase != null)
            starting_phase.raise_objection (this);
      endtask

      virtual task body ();
         `uvm_info ("BASE_SEQ", $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)
         data_obj = my_data::type_id::create ("data_obj");
         
         repeat (3) begin
            start_item (data_obj);
            assert (data_obj.randomize ());
            finish_item (data_obj);
         end
         #100;             // Wait for transactions to finish
         `uvm_info (get_type_name (), $sformatf ("Sequence %s is over", this.get_name()), UVM_MEDIUM)
      endtask
      
      // Drop objection if started as the root sequence
      virtual task post_body ();
         if (starting_phase != null) 
            starting_phase.drop_objection (this);
      endtask
   endclass

   //---------------------------------------------------------------------------------------------------------------------
   //                                                    my_agent {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_agent extends uvm_agent;
      `uvm_component_utils (my_agent)

      my_cfg                     m_cfg0; 
      my_driver                  m_drv0;
      my_monitor                 m_mon0;
      uvm_sequencer #(my_data)   m_seqr0;
      
      function new (string name = "my_agent", uvm_component parent=null);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);

         // Get CFG obj from top to configure the agent
         if (! uvm_config_db #(my_cfg) :: get (this, "", "m_cfg0", m_cfg0)) begin
            `uvm_fatal (get_type_name (), "Didn't get CFG object ! Can't configure agent")
         end
        
         // If the agent is ACTIVE, then create monitor and sequencer, else create only monitor
         if (m_cfg0.active == UVM_ACTIVE) begin
            m_seqr0 = uvm_sequencer#(my_data)::type_id::create ("m_seqr0", this);
            m_drv0 = my_driver::type_id::create ("m_drv0", this);
         end
         m_mon0 = my_monitor::type_id::create ("m_mon0", this);
      endfunction

      virtual function void connect_phase (uvm_phase phase);
         // Assign interface handle in CFG bject to Driver and Monitor, if active
         if (m_cfg0.active == UVM_ACTIVE) 
            m_drv0.vif = m_cfg0.vif;
         m_mon0.vif = m_cfg0.vif;

         // Connect analysis port of monitor to the agent

         // Connect Sequencer to Driver, if the agent is active
         if (m_cfg0.active == UVM_ACTIVE) begin
            m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
         end
      endfunction

   endclass

   //-----------------------------------------------------------------------------------------------------------------------
   //                                                    my_cfg {{{1
   //-----------------------------------------------------------------------------------------------------------------------

   // This is the configuration object that can be passed down into the environment
   class my_cfg extends uvm_object;
      `uvm_object_utils (my_cfg)

      virtual dut_if             vif;                          // Handle to interface
      uvm_active_passive_enum    active = UVM_ACTIVE;          // Configure Agent to be active

      uvm_verbosity m_verbosity = UVM_LOW;
      // Put in other agent parameters if required - functional coverage, 

      function new (string name = "my_cfg");
         super.new (name);
      endfunction
   endclass

   //-----------------------------------------------------------------------------------------------------------------------
   //                                                    my_scoreboard {{{1
   //-----------------------------------------------------------------------------------------------------------------------
   class my_scoreboard extends uvm_scoreboard;
      `uvm_component_utils (my_scoreboard)
      
      `uvm_analysis_imp_decl (_data)

      uvm_analysis_imp_data    #(my_data, my_scoreboard)                 data_export;    // Receive data from monitor

      function new (string name ="my_scoreboard", uvm_component parent=null);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         data_export   = new ("data_export", this);
      endfunction

      function void write_data (my_data data_obj);
         `uvm_info ("SCBD", "Received data item", UVM_HIGH)
         data_obj.print (uvm_default_line_printer);
      endfunction
   endclass

   

endpackage

