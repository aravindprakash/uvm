`include "uvm_macros.svh"

package test_pkg;
   import uvm_pkg::*;
   import my_pkg::*;

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 base_test   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   
   class base_test extends uvm_test;
   
      `uvm_component_utils (base_test)

      my_env   m_top_env;
      virtual  dut_if vif;
      int      n_times;
      
      function new (string name, uvm_component parent = null);
         super.new (name, parent);
      endfunction : new
      
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);

         m_top_env  = my_env::type_id::create ("m_top_env", this);
      
         // Get DUT interface from top module
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "dut_if", vif)) begin
            `uvm_error (get_type_name (), "DUT Interface not found !")
         end

         // Pass DUT interface to all components
         uvm_config_db #(virtual dut_if) :: set (this, "m_top_env.*", "vif", vif);

      endfunction : build_phase

      virtual function void end_of_elaboration_phase (uvm_phase phase);
         uvm_top.print_topology ();
      endfunction

      function void start_of_simulation_phase (uvm_phase phase);
         super.start_of_simulation_phase (phase);
         uvm_config_db#(uvm_object_wrapper)::set(this,"m_top_env.m_seqr0.main_phase",
                                          "default_sequence", base_sequence::type_id::get());

      endfunction

   endclass 

   //---------------------------------------------------------------------------------------------------------------------
   //                                                 reg_test   {{{1
   //---------------------------------------------------------------------------------------------------------------------

   class reg_test extends base_test;
      `uvm_component_utils (reg_test)

      function new (string name, uvm_component parent = null);
         super.new (name, parent);
      endfunction

      // Enter your test for register access here
   endclass
   
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 feature_test   {{{1
   //---------------------------------------------------------------------------------------------------------------------

   class feature_test extends base_test;
      `uvm_component_utils (feature_test)

      function new (string name, uvm_component parent = null);
         super.new (name, parent);
      endfunction 
      // Enter test code for feature here
   endclass

endpackage : test_pkg
