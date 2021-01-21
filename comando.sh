source synopsys_tools.sh;
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh\|.*\.md"`;

vcs -Mupdate top.sv  -o salida -full64 -debug_all -sverilog -l log_test -ntb_opts uvm-1.2 +lint=TFIPC-L -cm line+tgl+cond+fsm+branch+assert -cm_tgl assign+portsonly+fullintf+mda+count+structarr -lca;

echo 'Muestra, fp_X, fp_Y, fp_Z (Recibido), fp_Z (Checker), Modo de redondeo, Overflow, Underflow' > sb_transaction_report.csv
echo 'Muestra, fp_X, fp_Y, fp_Z (Recibido), fp_Z (Checker), Modo de redondeo, Overflow, Underflow' > sb_ERROR_transaction_report.csv
echo 'Muestra, fp_X, fp_Y, fp_Z (Recibido), fp_Z (Checker), Modo de redondeo, Overflow, Underflow' > sb_PASS_transaction_report.csv

#./salida -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_10 +ntb_random_seed=1 > debug_log

echo "[COMANDO] Escenario 1: Uso común del dispositivo" > deleteme_log_1
for seed in {1..50}
do
	./salida -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_01 +ntb_random_seed_automatic >> deleteme_log_1
	echo -e "\n[COMANDO] Finalizado: Escenario 1, semilla $seed \n" >> deleteme_log_1
	echo "Done test_01 seed $seed"
done

echo "[COMANDO] Escenario 2: Comportamiento del DUT en casos de error" > deleteme_log_2
for seed in {1..50}
do
	./salida -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=test_10 +ntb_random_seed_automatic >> deleteme_log_2
	echo -e "\n[COMANDO] Finalizado: Escenario 2, semilla $seed \n" >> deleteme_log_2
	echo "Done test_10 seed $seed"
done

# Para visualizar la covertura
dve -full64 -covdir salida.vdb &

# Para visualizar las formas de onda
#./salida -gui&