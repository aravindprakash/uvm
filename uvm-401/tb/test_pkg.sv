`include "uvm_macros.svh"

package test_pkg;
   import uvm_pkg::*;
   import my_pkg::*;

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 base_test   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   
   class base_test extends uvm_test;
   
      `uvm_component_utils (base_test)

      my_env   m_top_env;              // Testbench environment
      my_cfg   m_cfg0;                 // Configuration object

      //------------------------------------------------------------------------------------------
      //                                  new ()
      //------------------------------------------------------------------------------------------
      
      function new (string name, uvm_component parent = null);
         super.new (name, parent);
      endfunction : new
      
      //------------------------------------------------------------------------------------------
      //                                  build_phase ()
      //------------------------------------------------------------------------------------------
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);

         m_top_env  = my_env::type_id::create ("m_top_env", this);
         m_cfg0     = my_cfg::type_id::create ("m_cfg0", this);
      
         // Configure the object
         set_cfg_params ();

         // Make the cfg object available to all components in agent
         uvm_config_db #(my_cfg) :: set (this, "m_top_env.my_agent", "m_cfg0", m_cfg0);

      endfunction : build_phase

      //------------------------------------------------------------------------------------------
      //                                  set_cfg ()
      //------------------------------------------------------------------------------------------
      virtual function void set_cfg_params ();
         
         // Get DUT interface from top module into the cfg object
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "dut_if", m_cfg0.vif)) begin
            `uvm_error (get_type_name (), "DUT Interface not found !")
         end
         
         m_cfg0.m_verbosity    = UVM_HIGH;
         m_cfg0.active         = UVM_ACTIVE;
      endfunction

      //------------------------------------------------------------------------------------------
      //                                  end_of_elaboration_phase ()
      //------------------------------------------------------------------------------------------
      virtual function void end_of_elaboration_phase (uvm_phase phase);
         // By now, the environment is all set up, just print the topology for debug
         uvm_top.print_topology ();
      endfunction

      //------------------------------------------------------------------------------------------
      //                                  start_of_simulation_phase ()
      //------------------------------------------------------------------------------------------
      function void start_of_simulation_phase (uvm_phase phase);
         super.start_of_simulation_phase (phase);
         
         // Assign a default sequence to be executed by the sequencer
         uvm_config_db#(uvm_object_wrapper)::set(this,"m_top_env.my_agent.m_seqr0.main_phase",
                                          "default_sequence", base_sequence::type_id::get());

      endfunction

   endclass 

endpackage : test_pkg
