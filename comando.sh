source synopsys_tools.sh;
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh"`;

vcs -Mupdate top.sv  -o salida -full64 -debug_all -sverilog -l log_test -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert -cm_tgl assign+portsonly+fullintf+mda+count+structarr -lca;

#./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=base_test +ntb_random_seed=1 > deleteme_log_0

echo "[COMANDO] Escenario 1: Uso común del dispositivo" > deleteme_log_1
for seed in {1..3}
do
	./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_01 +ntb_random_seed=seed >> deleteme_log_1
	echo -e "\n[COMANDO] Finalizado: Escenario 1, semilla $seed \n" >> deleteme_log_1
done

# echo "[COMANDO] Escenario 2: Comportamiento del DUT en casos de error" > deleteme_log_2
# for seed in {1..5}
# do
# 	./salida +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_10 +ntb_random_seed=seed >> deleteme_log_2
# 	echo -e "\n[COMANDO] Finalizado: Escenario 2, semilla $seed \n" >> deleteme_log_1
# done

./salida -cm line+tgl+cond+fsm+branch+assert;

# Para visualizar la covertura
# dve -full64 -covdir salida.vdb &

# Para visualizar las formas de onda
#./salida -gui&