-incdir $UVM_HOME
-incdir ./tb
+UVM_NO_RELNOTES
+UVM_VERBOSITY=UVM_HIGH
#+UVM_CONFIG_DB_TRACE
#+UVM_PHASE_TRACE
#+UVM_OBJECTION_TRACE
-uvm -sv
./rtl/dut.sv
./tb/dut_if.sv
./tb/dut_wrapper.sv
./tb/my_pkg.sv
./tb/test_pkg.sv
./tb/tb_top.sv
