source synopsys_tools.sh;
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh"`;

vcs -Mupdate top.sv  -o salida -full64 -debug_all -sverilog -l log_test -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH;

./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=base_test +ntb_random_seed=1 > deleteme_log_1

for seed in {1..5}
do
	./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_01 +ntb_random_seed=seed > deleteme_log_2
	echo "Seed $seed seed"
done

./salida -cm line+tgl+cond+fsm+branch+assert;

# Para visualizar la covertura
#dve -full64 -covdir salida.vdb &

# Para visualizar las formas de onda
#./salida -gui&