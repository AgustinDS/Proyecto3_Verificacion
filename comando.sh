source synopsys_tools.sh;
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh"`;

vcs -Mupdate test_bench.sv  -o salida -full64 -debug_all -sverilog -l log_test -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH;

./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_1011 +ntb_random_seed=1 > deleteme_log_1
./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_1011 +ntb_random_seed=2 > deleteme_log_2

#./salida -cm line+tgl+cond+fsm+branch+assert;

# Para visualizar la covertura
#dve -full64 -covdir salida.vdb &

# Para visualizar las formas de onda
#./salida -gui&