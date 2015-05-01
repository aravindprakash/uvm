-incdir $UVM_HOME
-incdir ./tb
+UVM_NO_RELNOTES
+UVM_VERBOSITY=HIGH
+UVM_REPORT_DISABLE_FILE_LINE
-uvm -sv
./rtl/dut.sv
./tb/dut_if.sv
./tb/dut_wrapper.sv
./tb/my_pkg.sv
./tb/test_pkg.sv
./tb/tb_top.sv
