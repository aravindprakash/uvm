-incdir $UVM_HOME
-incdir ./tb
+UVM_NO_RELNOTES
+UVM_VERBOSITY=UVM_HIGH
-uvm -sv
./tb/tlm.sv
./tb/test.sv
./tb/tb_top.sv
