`include "uvm_macros.svh"

//---------------------------------------------------------------------------------------------------------------------
//                                                 base_test   
//---------------------------------------------------------------------------------------------------------------------

class base_test extends uvm_test;

   `uvm_component_utils (base_test)

   my_env   m_top_env;              // Testbench environment

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
   endfunction : build_phase

   //------------------------------------------------------------------------------------------
   //                                  end_of_elaboration_phase ()
   //------------------------------------------------------------------------------------------
   virtual function void end_of_elaboration_phase (uvm_phase phase);
      // By now, the environment is all set up, just print the topology for debug
      uvm_top.print_topology ();
   endfunction

endclass 
