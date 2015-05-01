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
//---------------------------------------------------------------------------------------------------------------------
//                                                 my_env  {{{1
//---------------------------------------------------------------------------------------------------------------------
   class my_env extends uvm_env ;
   
      `uvm_component_utils (my_env)

      my_driver   m_drv0;

      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
   
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
      endfunction : build_phase
   
      virtual task run_phase (uvm_phase phase);
         super.run_phase (phase);
         tweak_report_handler();

         // If you set the verbosity here, you won't see the 2 INFO messages below
         // set_report_verbosity_level (UVM_NONE);
         uvm_report_info      (get_type_name(), $sformatf ("Hello UVM ! Simulation has started."), UVM_MEDIUM, `__FILE__, `__LINE__);
         `uvm_info   (get_type_name(), $sformatf("Finishing up with run_phase ... "), UVM_LOW)
      endtask : run_phase

      virtual function void tweak_report_handler ();
         uvm_report_handler my_handler;
         my_handler = get_report_handler ();
         `uvm_info ("REPORT", $sformatf ("get_report_verbosity_level = %0d", get_report_verbosity_level()), UVM_MEDIUM)
//         `uvm_info ("REPORT", $sformatf ("get_report_max_verbosity_level = %0d", get_report_max_verbosity_level()), UVM_MEDIUM)
//         `uvm_info ("REPORT", $sformatf ("get_report_action = %0d", get_report_action(UVM_HIGH)), UVM_MEDIUM)
      endfunction
   
   endclass : my_env

//---------------------------------------------------------------------------------------------------------------------
//                                                 my_driver  {{{1
//---------------------------------------------------------------------------------------------------------------------
   class my_driver extends uvm_driver;
      `uvm_component_utils (my_driver)

      bit fatal;

      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction

      virtual function void build_phase (uvm_phase phase);
         //if (! uvm_config_db #(bit) :: set (this, "", "fatal", fatal)) begin
         //   fatal = 0;
         //end
      endfunction

      virtual task run_phase (uvm_phase phase);
         super.run_phase (phase);
         report_old_style ();
         $display ("========================================================================================");
         report_new_style ();
      endtask

//-------------------------------------------------------------------------------------
//                                  report_old_style 
//-------------------------------------------------------------------------------------
      virtual function void report_old_style ();
         bit [7:0]  data = 8'he7;
         string     name = "Old Style";
         real       volt = 2.3745;
         
         //-------------------------------------------------------------------------------------
         // Display data values
         //-------------------------------------------------------------------------------------
         uvm_report_info ("DRV", $sformatf ("data = 0x%0h, name = %s, volt = %f", data, name, volt), UVM_MEDIUM);
         uvm_report_info (get_name (), $sformatf ("data = 0x%0d, name = %s, volt = %0f", data, name, volt), UVM_MEDIUM);
         uvm_report_info (get_type_name (), $sformatf ("data = 0x%0b, name = %s, volt = %0.1f", data, name, volt), UVM_MEDIUM);
         uvm_report_info (get_full_name (), $sformatf ("data = %h, name = %s, volt = %0.2f", data, name, volt), UVM_MEDIUM);
         $display ("........................................................................................");

         //-------------------------------------------------------------------------------------
         // Display with different verbosity levels
         //-------------------------------------------------------------------------------------
         uvm_report_info (get_type_name (), $sformatf ("None level message"), UVM_NONE);
         uvm_report_info (get_type_name (), $sformatf ("Low level message"), UVM_LOW);
         uvm_report_info (get_type_name (), $sformatf ("Medium level message"), UVM_MEDIUM);
         uvm_report_info (get_type_name (), $sformatf ("High level message"), UVM_HIGH);
         uvm_report_info (get_type_name (), $sformatf ("Full level message"), UVM_FULL);
         uvm_report_info (get_type_name (), $sformatf ("Debug level message"), UVM_DEBUG);

         uvm_report_warning (get_type_name (), $sformatf ("Warning level message"));
         uvm_report_error (get_type_name (), $sformatf ("Error level message"));
         if (fatal)
            uvm_report_fatal (get_type_name (), $sformatf ("Fatal level message"));

         //-------------------------------------------------------------------------------------
         // Display File and Line Numbers
         //-------------------------------------------------------------------------------------
         uvm_report_info (get_type_name (), $sformatf ("None level message - Display File/Line"), UVM_NONE, `__FILE__, `__LINE__);
      endfunction

//-------------------------------------------------------------------------------------
//                                  report_new_style - with macro wrapper 
//-------------------------------------------------------------------------------------
      virtual function void report_new_style ();
         bit [7:0]  data = 8'ha4;
         string     name = "New Style";
         real       volt = 0.045;
         
         //-------------------------------------------------------------------------------------
         // Display data values
         //-------------------------------------------------------------------------------------
         `uvm_info ("DRV", $sformatf ("[Driver] data = 0x%0h, name = %s, volt = %f", data, name, volt), UVM_MEDIUM)
         `uvm_info (get_inst_id (), $sformatf ("[Driver] data = 0x%0d, name = %s, volt = %0f", data, name, volt), UVM_MEDIUM)
         `uvm_info (get_type_name (), $sformatf ("[Driver] data = 0x%0b, name = %s, volt = %0.1f", data, name, volt), UVM_MEDIUM)
         `uvm_info (get_full_name (), $sformatf ("[Driver] data = %h, name = %s, volt = %0.2f", data, name, volt), UVM_MEDIUM)
         $display ("........................................................................................");

         //-------------------------------------------------------------------------------------
         // Display with different verbosity levels
         //-------------------------------------------------------------------------------------
         `uvm_info (get_type_name (), $sformatf ("[Driver] None level message"), UVM_NONE)
         `uvm_info (get_type_name (), $sformatf ("[Driver] Low level message"), UVM_LOW)
         `uvm_info (get_type_name (), $sformatf ("[Driver] Medium level message"), UVM_MEDIUM)
         `uvm_info (get_type_name (), $sformatf ("[Driver] High level message"), UVM_HIGH)
         `uvm_info (get_type_name (), $sformatf ("[Driver] Full level message"), UVM_FULL)
         `uvm_info (get_type_name (), $sformatf ("[Driver] Debug level message"), UVM_DEBUG)

         `uvm_warning (get_type_name (), $sformatf ("[Driver] Warning level message"))
         `uvm_error (get_type_name (), $sformatf ("[Driver] Error level message"))
         if (fatal)
            `uvm_fatal (get_type_name (), $sformatf ("[Driver] Fatal level message"))

         // NOTE: File and Line numbers are automatically added, if you use the new style  
 
      endfunction
   endclass

endpackage

