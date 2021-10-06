#v27 03-oct-2021. Se agrega condicion para descontar promociones de items ya agregados (index_a[m,3]==index_a[n,3])

#v26 12-Sep-2021. Se agrega condicion de fin de correcion de ticket aun cuando el ticket ya se ha cobrado (064-018). Se agrega condicion length(boleta)>1 && length(hora_fin)==6 antes de imprimir el ticket

#v25 22-Ago-2021. Se agrega condicion de fin de transaccion para procesar archivo log parcial (tpa). Se lee el valor de getline para salir de while o for si el archivo finaliza. Se agrega condicion ticket_actual == "00000000" posterior a reinicio de POS

#v24 23-Jun-2021. Se agrega evento de reinicio de POS (050-018) para limpiar variables en caso de interrupcion de ticket anterior

#v22 5-Jun-2021. Se corrige error en decremento (005) de item cuando este se procesaba 2 a mas veces. 
# item_a_tot_item_canc[item] = item_a_tot_item_canc[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)

#v21 14-May-2021. Se agregó la instrucción if (tipo != "venta") {iva = 0} en el ciclo de impresión pra evitar iva en ordenes canceladas, promo, comida de empleado.

#v20. 13-May-2021. Se agregó impresion de lectura de cierre cuando se entra en loop 510 e innediatamente se encuanta un 091 (exit). 
#Se comenta la instrucción print "Consec_1= " substr($0,5,4); print "Consec_1= " substr($0,5,4) | "cat 1>&2"} Esto hacía que se originara una
#línea de 1 campo (se esperan 28 campos); sin embargo, el script filtro.awk debió de haber bloqueado esta línea y dejar pasar las que estaban bien.
#Platicar con Clarks para mejorar el filtro.

#v19. 21-Abr-2021. Para una POS tomadora no se imprimia la lectura de cierre si las POS se reiniciba al cierre. Probado en Ref, 2021-04-01 POS 4.
#La soución fue imprimir el cierre si dentro de ciclo 510 se alcanza 091 (lectura de cierre). 

#V18. 20-Abr-2021. Corrección en  cancelacion. Se regresa a un indice para resumir el arreglo final de solo dos elementos, es decir
#item_a_id_producto[k] item_a_extra_char[k] en vez de item_a_id_producto[k] item_a_extra_char[k] item_a_tipo[k] Esto causaba que en las ordenes canceladas
#los items tipo "venta" no se restaran de los items tipo "orden_cancelada" dando error en el total de la suma de los items cancelados.

#v16. 15_abr-2021 9:56 PM. Se incluyo la condición if((ticket_a[NR-1] == ticket_a[NR]) && key_a[NR-1]=="044" && key_a[NR]=="000") Flag =1
#Esto forza a una orden cancelada a no abortar aun cuando el ticket haya sido previamente cancelado. Provar con mismo archivo de v14 de macroplaza.

#Version 14. Se arreglo fallo en ordenes canceladas: Las llaves estaban en el orden invertido.
#Probado con /home/mcd_gpomonse/rest/00684/logs/pos2/2021-02/20210210.log tickets  18291 (orden cancelada) y 18292 (venta siguiente)  generados correctamente.

#Version 13. Encontrar clave de iva en substr($0,229,4)

#log_ticket.awk Version 12 corregida el 8 de Abril 2021
# Soluciona error con log del 29 Mar      /home/mcd_gpomonse/rest/00902/logs/pos2/20210329.log
# No procesaba los tickets 713277  y  713429 debido a que orden_cancelada sucuedia con 510 - 004 - 095 - 000
# Solución: orden_cancelada es 510 - 004 - 095 (000 estaba de mas)


awk '
BEGIN	{      
	OFS = ","      #Output Field Separator
	my_tab = ","   #coma separated value. It could be ","
	#my_command = "rm -f " my_file
	#print "Archivo bop_file disponible para consulta en " my_file | "cat 1>&2"
	#system(my_command)
	#bop_file = "cat 1>" my_file
}
{ #Inicio de programa
rest = "MX" substr($0,69,5)
fecha = substr($0, 17,8)
hora_ini = substr($0,25,6)
hora_fin = substr($0,25,6)
POS = substr($0, 11,6)
cajero_num = substr($0,31,8)
gte_num = substr($0,38,8) + 0
counter = 0
ticket_largo = substr($0,276,8)
fin_transaccion = 0

if (ticket_largo == "00000001") { ticket_largo = substr($0, 47, 8)}
if(substr($0,55,3) == "090") {
	tipo = "lectura_apertura"
	date_aux = substr($0,17,8)
	my_file = date_aux".log"
	yyyy = substr(date_aux,1,4)
	mm = substr(date_aux,5,2)
	dd = substr(date_aux,7,2)
	business_date = yyyy"-"mm"-"dd
	lectura_apertura = (substr($0, 151, 10) + 0)/100
	printf("%7s%s", rest, ",")                              #1  mysql rest char(7)
	printf("%8s%s", fecha, ",")                             #2  mysql fecha date yyyymmdd
	printf("%6s%s", hora_ini, ",")                          #3  mysql hora_ini time hhmmss
	printf("%6s%s", hora_fin, ",")                          #4  mysql hora_fin time hhmmss
	printf("%6s%s", POS,",")                                #5  mysql POS smallint(6)
	printf("%8s%s", gte_num, ",")                           #6  mysql gerente_num smallint(5)
	printf("%30s%s", "", ",")                               #7  mysql gerente_name char(30)
	printf("%8s%s", cajero_num,",")                         #8  mysql cajero_num smallint(5)
	printf("%8s%s", ticket_largo, ",")                      #9  mysql ticket_num int(8)
	printf("%3s%s", 1, ",")					#10 mysql item samllint(3)
	printf("%4s%s", " ", ",")                               #11 mysql extra_char char(4)
	printf("%7s%s", 0, ",")                                 #12 mysql qty int(7)
	printf("%7s%s", " ",",")                                #13 mysql id_producto int(7)
	printf("%30s%s"," ", ",")                               #14 mysql articulo char(30)
	printf("%8s%s", "", ",")                                #15 mysql cancelacion_AT decimal(9,2)
	printf("%8s%s", 0, ",")                                 #16 mysql tot_item decimal(9,2)
	printf("%4s%s", " ", ",")				##### SE ACABA DE AGREGAR 
	printf("%10.2f%s", lectura_apertura, ",")                 #17 tot_ticket (10,2)
	printf("%7s%s", " ",",")                                #18 mysql comer_llevar char(7)
	printf("%10s%s", 0 , ",")                               #19 mysql efectivo decimal(10,2)
	printf("%10s%s", 0, ",")                                #20 mysql cambio decimal(10,2)
	printf("%6s%s", 0, ",")                                 #21 mysql dolares decimal(5,2)
	printf("%10s%s", 0,",")                                 #22 mysql tot_tarjet decimal(9,2)
	printf("%9s%s", " ", ",")                               #23 mysql tipo_tarjeta char(9)
	printf("%10s%s", 0,",")                                 #24 iva decimal (9,2)
	printf("%16s%s", tipo,",")                              #25 tipo char(16)
	printf("%16s%s", my_file, ",")                             #Boleta
	printf("%8s%s", business_date, "\n")
}

if(substr($0,55,3) == "051" || substr($0,55,3) == "091") {
	if (substr($0,55,3) == "051") {tipo = "apertura_dia"; lectura_cierre = ""}
	if (substr($0,55,3) == "091") { tipo = "lectura_cierre"; lectura_cierre = (substr($0, 151, 10) + 0)/100}
	printf("%7s%s", rest, ",")                              #1  mysql rest char(7)
	printf("%8s%s", fecha, ",")                             #2  mysql fecha date yyyymmdd
	printf("%6s%s", hora_ini, ",")                          #3  mysql hora_ini time hhmmss
	printf("%6s%s", hora_fin, ",")                          #4  mysql hora_fin time hhmmss
	printf("%6s%s", POS,",")                                #5  mysql POS smallint(6)
	printf("%8s%s", gte_num, ",")                   	#6  mysql gerente_num smallint(5)
	printf("%30s%s", "", ",")               	        #7  mysql gerente_name char(30)
	printf("%8s%s", cajero_num,",")                         #8  mysql cajero_num smallint(5)
	printf("%8s%s", ticket_largo, ",")                      #9  mysql ticket_num int(8)
	printf("%3s%s", 1, ",")  				#10 mysql item samllint(3)
	printf("%4s%s", " ", ",")		                #11 mysql extra_char char(4)
	printf("%7s%s", 0, ",")      				#12 mysql qty int(7)
	printf("%7s%s", " ",",")		                #13 mysql id_producto int(7)
	printf("%30s%s"," ", ",")		                #14 mysql articulo char(30)
	printf("%8s%s", "", ",")                                #15 mysql cancelacion_AT decimal(9,2)
	printf("%8s%s", 0, ",")          			#16 mysql tot_item decimal(9,2)
	printf("%4s%s", " ", ",")                               ##### SE ACABA DE AGREGAR
	printf("%10.2f%s", lectura_cierre, ",") 	        #17 tot_ticket (10,2)
	printf("%7s%s", " ",",")	                        #18 mysql comer_llevar char(7)
	printf("%10s%s", 0 , ",")                         	#19 mysql efectivo decimal(10,2)
	printf("%10s%s", 0, ",")	                        #20 mysql cambio decimal(10,2)
	printf("%6s%s", 0, ",")		                        #21 mysql dolares decimal(5,2)
	printf("%10s%s", 0,",")		                        #22 mysql tot_tarjet decimal(9,2)
	printf("%9s%s", " ", ",")                      		#23 mysql tipo_tarjeta char(9)
	printf("%10s%s", 0,",")	                                #24 iva decimal (9,2)
	printf("%16s%s", tipo,",")				#25 tipo char(16)
	printf("%16s%s", my_file, ",")				#Boleta
	printf("%8s%s", business_date, "\n")
}
#daclark@ 2020-03-05 esta linea de abajo parece pasar los filtros y es la genera errores al imprimit la cadena: Consec_1
if (substr($0,55,3) == "010"  && substr($0,165,15) == "To Store screen") {tipo = "pos_tomadora"; Flag = 0}
if (substr($0,55,3) == "091") { exit } #exit termina el programa y se ejecuta lo que haya en END
Flag = 0
ticket_a[NR] = substr($0,47,8)
key_a[NR] = substr($0,55,3)
if ((length($1) == 84) && (length($0) == 511)) {
	event_key = "Key" substr($0, 55, 3)
	if ((ticket_a[NR-1] != ticket_a[NR]) && (substr($0,55,3) == "000" ) ) # 000 indica SaleStart
		Flag = 1  #Dentro del ticket
	if((ticket_a[NR-1] == ticket_a[NR]) && key_a[NR-1]=="052" && key_a[NR]=="000")
	 	Flag = 1  #Dentro del ticket
	if((ticket_a[NR-1] == ticket_a[NR]) && key_a[NR-1]=="093" && key_a[NR]=="000")
        Flag = 1  #Inicio de correccion del ticket. No salirse de LOOP 
	if((ticket_a[NR-1] == ticket_a[NR]) && key_a[NR-1]=="044" && key_a[NR]=="000")
		Flag = 1  #Inicio de correccion del ticket. No salirse de LOOP
} #(NR == xxxx)
while (Flag == 1) {
	ticket_num = substr($0,47,8)
	ticket_a[NR] = ticket_num
	event_key = "Key" substr($0, 55, 3)
	#if (ticket_a[NR-1] != ticket_a[NR] && event_key ~ /Key000/)
	#	Flag = 0
	if (event_key ~ /Key000/) {
		Flag = 1
		Max_Item = 0
		boleta = ""
		cajero_num = ""
		cambio = ""
		comer_llevar = ""
		consecutivo = ""
		dolares = 0
		efectivo = 0
		fecha = ""
		gte_num = ""
		gte_name = ""
		hora_ini = ""
		hora_fin = ""
		pago = 0
		POS = 0
		qty = 0
		rest = ""
		ticket_num = 0
		tipo = "venta"
		tipo_tarjeta = ""
		tot_ticket_canc = 0
		tot_tarjeta = 0                     #importe pagado con tarjeta
		tot_ticket = 0
		tot_ticket_str = 0
		delete item_a_event;		delete item_r_event;		delete item_s_event;
		delete item_a_consecutivo; 	delete item_r_consecutivo;	delete item_s_consecutivo;
		delete item_a_id_producto; 	delete item_r_id_producto;	delete item_s_id_producto;
		delete item_a_extra_char; 	delete item_r_extra_char;	delete item_s_extra_char;
		delete item_a_s_desc;		delete item_r_s_desc;		delete item_s_s_desc;
		delete item_a_l_desc;		delete item_r_l_desc;		delete item_s_l_desc;
		delete item_a_qty;		delete item_r_qty;		delete item_s_qty;
		delete item_a_tot_item;		delete item_r_tot_item;		delete item_s_tot_item;
		delete item_a_qty_canc;		delete item_r_qty_canc;		delete item_s_qty_canc;
		delete item_a_tot_item_canc;	delete item_r_tot_item_canc;	delete item_s_tot_item_canc;
		delete item_a_accion;		delete item_r_accion;		delete item_s_accion;
		delete item_a_tipo;
		delete item_a_clave_iva;
		consecutivo = substr($0,1,8)
		POS = substr($0, 11,6)
		fecha = substr($0, 17,8)
		hora_ini = substr($0,25,6)
		cajero_num = substr($0,31,8)
		ticket_num = substr($0, 47, 8)
		event_key = "Key" substr($0,55,3)
		rest = "MX" substr($0,69,5)
		event_key = "Key" substr($0,55,3)
		ticket_largo = substr($0,276,8)
		if (ticket_largo == "00000001") { ticket_largo = substr($0, 47, 8)}
	} # Termina if (event_key  ~ /Key000/)

	# Ingreso producto, decremento producto y promocion
	if ((event_key ~ /Key001/ || event_key ~ /Key005/ || event_key ~ /Key049/) && Flag == 1) {
		consecutivo = substr($0,1,8)
		item = substr($0,216,3) + 0
		item_a_key[item] = item_index
		item_a_event[item] = event_key
		item_a_consecutivo[item] = substr($0,3,6)
		item_a_id_producto[item] = substr($0,139,8) + 0   #Se hace numerico para comparar en do_summary
		item_a_extra_char[item] = substr($0,147,1)
		item_a_s_desc[item] = substr($0,183,16)
		item_a_l_desc[item] = substr($0,296,30)
		item_a_tipo[item] = "venta"
		if (substr($0,139,8) !~ "00000000") { item_a_clave_iva[item] = substr($0,229,4) }
		if (event_key ~ /Key001/) {
			item_a_qty[item] = item_a_qty[item] + (substr($0, 148, 7) + 0)
			item_a_tot_item[item] = item_a_tot_item[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)
		}else if (event_key ~ /Key005/) {
			item_a_qty_canc[item] = item_a_qty_canc[item] + substr($0, 148, 7) + 0
			item_a_tot_item_canc[item] = item_a_tot_item_canc[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)

		}else if ( event_key ~ /Key049/) {
			item_a_qty[item] =  item_a_qty[item] + substr($0, 148, 7) + 0
			item_a_tot_item[item] = item_a_tot_item[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)
			item_a_tipo[item] = "promocion"
			#x1 = "ticket= "substr($0, 47, 8) "\t"
			#x2 = "consec= "substr($0,1,8) "\t"
			#x3 = "qty_promo = " item_a_qty[item] "\t"
			#x4 = "tot_promo = " item_a_tot_item[item] "\t"
			#x5 = "articulo= " item_a_s_desc[item]
			#print x1 x2 x3 x4  x5 | "cat 1>&2"
		}
		if (item > Max_Item) {Max_Item = item}
	} #Termina if ((event_key == /Key001/) || (event_key ~ /Key005/)) "")
	
	# Pago recibido y tipo de pago
	if (event_key ~ /Key002/ && Flag == 1) {
		tipo_tarjeta = "desconocido"
		if (substr($0,175,1) == "$") { efectivo = (substr($0, 139, 10) + 0)/100; tipo_tarjeta = "EFECTIVO"}
		else{
			tipo_tarjeta = toupper(substr($0,175,16))
			gsub(" ","",tipo_tarjeta)
			tot_tarjeta = substr($0, 139,10)/100
			if (tipo_tarjeta ~ /TARJ\./ ){
				split(substr($0,175,16),tarjeta_tipo_a, ".")
				tipo_tarjeta = toupper(tarjeta_tipo_a[2])
				gsub(" ","",tipo_tarjeta)
			}
		}
	} #Termina (event_key ~ /Key002/)

	# Subtotal con iva
	if (event_key ~ /Key003/)
		tot_ticket_str = (substr($0,139,10) +0)/100

	# Orden cancelada
	if (event_key ~ /Key004/) {
		tipo = "orden_cancelada"
		hora_fin = substr($0,25,6)
		boleta_cancelada = substr($0,47,8)  "."  substr($0,139,10) + 0  ".bop"
	}

	# Take-out eat-in
	if (event_key ~ /Key006/) {
		if ($0 ~ /TAKE-OUT/) {comer_llevar = "Llevar"}
		if ($0 ~ /EAT-IN/) {comer_llevar = "Comedor"}
	}

	# Cambio
	if (event_key ~ /Key007/)
		cambio = substr($0,139,10)/100

	# POS tomadora
	if (event_key ~/Key010/ && substr($0,165,15) == "To Store screen") {tipo = "pos_tomadora"; Flag = 0}

	# Comida de empleado o desperdicio
	if (event_key == "Key015" ) {
			str_tipo = substr($0,151,17)
			split($2,arr_x,"|")
			split(arr_x[2], arr_y, ";")
			if (str_tipo ~ /Waste/) {tipo = "desperdicio"; hora_fin = substr($0,25,6); boleta = substr($0,47,8)  "." arr_y[2] ".bop"}
			if (str_tipo ~ /Crew Meal/) {
				tipo = "comida_empleado"
				hora_fin = substr($0,25,6)
				boleta = substr($0,47,8)  "."  substr($0,139,10) + 0  ".bop"
			}
			if (str_tipo ~ /Refund/) {tipo = "devolucion"; hora_fin = substr($0,25,6); boleta = substr($0,47,8)  "." arr_y[2] ".bop"}
	}

	# Hora terminacion
	if (event_key ~ /Key045/ )
        hora_fin = substr($0,25,6)

	# Ticket se hace cero, transaccion continua
	if (event_key ~ /Key054/ ) {
		#POS Operator Close. El número de ticket cambia aunque aun no se ha salido. Forzar a permanecer en ticket.
		ticket_a[NR] = substr($0,47,8) - 1
		ticket_num = substr($0,47,8) - 1
		Flag = 1
	}

	# Fin de transaccion
	if (event_key ~ /Key095/) {
		iva = 0
		tot_boleta = 0
		split($2,arr_x,"=")
		y = split(arr_x[2], arr_y, "|")
		for(i=1; i<y; i++){
			z = split(arr_y[i], arr_z, ";")
			if (z == 3) { iva = (iva + arr_z[3])/100; tot_boleta = tot_boleta + arr_z[2] }
		}
        hh = substr($0,25,2)
		mm = substr($0,27,2)
		ss = substr($0,29,2)
		hora = hh ":" mm ":" ss
		if (tipo != "comida_empleado") { boleta = substr($0,47,8)  "." tot_boleta ".bop"}
		if (tipo == "promocion") { boleta = substr($0,47,8)  ".0.bop" }
		while (Flag == 1) {
			if (getline!=1){break;}
			if (substr($0,55,3) == "010" && substr($0,165,15) == "To Store screen") {tipo = "pos_tomadora"; Flag = 0; break } #print "Consec= " substr($0,5,4) | "cat 1>&2"; break}
			if (substr($0,55,3) == "050" && substr($0,47,8) == "00000000") {
				if (getline!=1){break;}
				if (substr($0,55,3) == "018" && substr($0,47,8) == "00000000") {
					Flag = 1
					break
				}
			}
			if (substr($0,55,3) == "000" && (substr($0,47,8)+0) > 0) {
				Flag = 0
				break
			}
			if (substr($0,55,3) == "510") {
				for (k=133; k<=(length($0)-133); k++){
					if (substr($0,k,1) == "}")
						break
				}
				str_tarjeta = substr($0,133, (k-133))
				if (str_tarjeta ~ /Modo Lab/) {
					gte_name = "Modo_Lab_Soporte"
					gte_num = 12345
				}else{
					split(str_tarjeta, num_a, "|")
					gte_name = num_a[3]
					gte_num = num_a[2]
				}
				Flag = 0
				break
			}
			if (substr($0,55,3)=="044"){
				if (getline!=1){break;}
				if (substr($0,55,3) == "050" && substr($0,47,8) == "00000000") {
					if (getline!=1){break;}
					if (substr($0,55,3) == "018" && substr($0,47,8) == "00000000") {
						Flag = 1
						break
					}
				}
				Flag = 0
				break			
			}
			if(substr($0,55,3) == "018") {
				Flag = 0
				break
			}
		} #Termina while (Flag == 1)
		if (Flag == 0){fin_transaccion = 1}
	} #Termina if (event_key ~ /Key095/ )

	# Cancelacion de producto
    if ( event_key ~ /Key092/) {
		# 092 es cancelación de producto. El producto se cancela en TODO el ticket
		ticket_a[NR] = ticket_a[NR-1]
		Flag = 1
	} # Termina if (event_key ~ /Key092/)

	# Tarjeta gerente
	if (event_key ~ /Key510/) {
		for (k=133; k<=(length($0)-133); k++){
			if (substr($0,k,1) == "}")
				break
		}
		str_tarjeta = substr($0,133, (k-133))
		if (str_tarjeta ~ /Modo Lab/) {
			gte_name = "Modo_Lab_Soporte"
			gte_num = 12345
		} else {
			split(str_tarjeta, num_a, "|")
			gte_name = num_a[3]
			gte_num = num_a[2]
		}
		if (tipo == "venta") {
			while ((event_key !~ /Key040/) && (event_key !~ /Key070/) && (event_key !~ /Key012/) && (event_key !~ /Key018/) && event_key !~ /Key091/) {
				if (getline!=1){break;}
				event_key = "Key" substr($0, 55, 3)
				if (event_key ~ /Key010/ && substr($0,165,15) == "To Store screen") {tipo = "pos_tomadora"; Flag = 0} #; print "Consec= " substr($0,5,4) | "cat 1>&2"}
				if (event_key ~ /Key091/) { 
					tipo = "lectura_cierre"; lectura_cierre = (substr($0, 151, 10) + 0)/100
					printf("%7s%s", rest, ",")                              #1  mysql rest char(7)
					printf("%8s%s", fecha, ",")                             #2  mysql fecha date yyyymmdd
					printf("%6s%s", hora_ini, ",")                          #3  mysql hora_ini time hhmmss
					printf("%6s%s", hora_fin, ",")                          #4  mysql hora_fin time hhmmss
					printf("%6s%s", POS,",")                                #5  mysql POS smallint(6)
					printf("%8s%s", gte_num, ",")                           #6  mysql gerente_num smallint(5)
					printf("%30s%s", "", ",")                               #7  mysql gerente_name char(30)
					printf("%8s%s", cajero_num,",")                         #8  mysql cajero_num smallint(5)
					printf("%8s%s", ticket_largo, ",")                      #9  mysql ticket_num int(8)
					printf("%3s%s", 1, ",")                                 #10 mysql item samllint(3)
					printf("%4s%s", " ", ",")                               #11 mysql extra_char char(4)
					printf("%7s%s", 0, ",")                                 #12 mysql qty int(7)
					printf("%7s%s", " ",",")                                #13 mysql id_producto int(7)
					printf("%30s%s"," ", ",")                               #14 mysql articulo char(30)
					printf("%8s%s", "", ",")                                #15 mysql cancelacion_AT decimal(9,2)
					printf("%8s%s", 0, ",")                                 #16 mysql tot_item decimal(9,2)
					printf("%4s%s", " ", ",")                               ##### SE ACABA DE AGREGAR
					printf("%10.2f%s", lectura_cierre, ",")                 #17 tot_ticket (10,2)
					printf("%7s%s", " ",",")                                #18 mysql comer_llevar char(7)
					printf("%10s%s", 0 , ",")                               #19 mysql efectivo decimal(10,2)
					printf("%10s%s", 0, ",")                                #20 mysql cambio decimal(10,2)
					printf("%6s%s", 0, ",")                                 #21 mysql dolares decimal(5,2)
					printf("%10s%s", 0,",")                                 #22 mysql tot_tarjet decimal(9,2)
					printf("%9s%s", " ", ",")                               #23 mysql tipo_tarjeta char(9)
					printf("%10s%s", 0,",")                                 #24 iva decimal (9,2)
					printf("%16s%s", tipo,",")                              #25 tipo char(16)
					printf("%16s%s", my_file, ",")                          #Boleta
					printf("%8s%s", business_date, "\n")
					exit
				} # End if if (substr($0,55,3) == "091")
				ticket_a[NR] = substr($0,47,8)
				if (event_key ~ /Key000/ && (ticket_a[NR] !~ ticket_a[NR-1])) {Flag = 0; break}
				if(event_key ~ /Key092/) {
					Flag = 1
					ticket_a[NR] = ticket_a[NR-1]
				}
				if (event_key ~ /Key004/) {#orden cancelada
					tipo = "orden_cancelada"
					iva = 0
					boleta = substr($0,47,8)  "."  substr($0,139,10) + 0  ".bop"
					ticket_num = substr($0,47,8)
					hora_fin = substr($0,25,6)
					if (getline!=1){break;}
                    if (substr($0,55,3)=="095"){
                        if (getline!=1){break;}
						if(substr($0,47,8)==ticket_num){
							if(substr($0,55,3)=="000" ){ 
								ticket_largo = ticket_largo = substr($0,276,8)
								if (ticket_largo == "00000001") { ticket_largo = substr($0, 47, 8) } #Cancelacion de todos los productos anteriores pero se continua dentro del ticket
								event_key="000"
								tipo="venta"
								Flag = 1
								Max_Item = 0
								pago = 0
								qty = 0
								tot_ticket_canc = 0
								tot_tarjeta = 0                     #importe pagado con tarjeta
								tot_ticket = 0
								tot_ticket_str = 0

								delete item_a_event;            delete item_r_event;            delete item_s_event;
								delete item_a_consecutivo;      delete item_r_consecutivo;      delete item_s_consecutivo;
								delete item_a_id_producto;      delete item_r_id_producto;      delete item_s_id_producto;
								delete item_a_extra_char;       delete item_r_extra_char;       delete item_s_extra_char;
								delete item_a_s_desc;           delete item_r_s_desc;           delete item_s_s_desc;
								delete item_a_l_desc;           delete item_r_l_desc;           delete item_s_l_desc;
								delete item_a_qty;              delete item_r_qty;              delete item_s_qty;
								delete item_a_tot_item;         delete item_r_tot_item;         delete item_s_tot_item;
								delete item_a_qty_canc;         delete item_r_qty_canc;         delete item_s_qty_canc;
								delete item_a_tot_item_canc;    delete item_r_tot_item_canc;    delete item_s_tot_item_canc;
								delete item_a_accion;           delete item_r_accion;           delete item_s_accion;
								delete item_a_tipo;
								break
							} #if(substr($0,55,3)=="000" && substr($0,47,8)==ticket_num)

							if (event_key ~ /Key004/) {
							    item_a_tipo[item] = "orden_cancelada"
								fin_transaccion = 1
								Flag = 0
								break
							}
						} # if(substr($0,47,8)==ticket_num){
                	} #if (substr($0,55,3)=="095") 
				} # if (event_key ~ /Key004/) orden cancelada
				if ((event_key ~ /Key001/) || (event_key ~ /Key005/) ||(event_key ~ /Key049/) ) { #Key049 =  promo
					event_key = "Key" substr($0, 55, 3)
					Flag = 1
					consecutivo = substr($0,1,8)
					item = substr($0,216,3) + 0
					item_a_key[item] = item_index
					item_a_event[item] = event_key
					item_a_consecutivo[item] = substr($0,3,6)
					item_a_id_producto[item] = substr($0,139,8) + 0   #Se hace numerico para comparar en do_summary
					item_a_extra_char[item] = substr($0,147,1)
					item_a_s_desc[item] = substr($0,183,16)
					item_a_l_desc[item] = substr($0,296,30)
					item_a_tipo[item] = "venta"
					if(substr($0,139,8) !~ "00000000") {item_a_clave_iva[item] = substr($0,229,4)}
					if (event_key ~ /Key001/) {
						item_a_qty[item] = item_a_qty[item] + (substr($0, 148, 7) + 0)
						item_a_tot_item[item] = item_a_tot_item[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)
					}else if (event_key ~ /Key005/) {
						item_a_qty_canc[item] = item_a_qty_canc[item] + substr($0, 148, 7) + 0
						item_a_tot_item_canc[item] = item_a_tot_item_canc[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)
					}else if ( event_key ~ /Key049/) {
						item_a_qty[item] =  item_a_qty[item] + substr($0, 148, 7) + 0
						item_a_tot_item[item] = item_a_tot_item[item] + (substr($0, 161, 8) + 0) * (substr($0, 148, 7) + 0)
						item_a_tipo[item] = "promocion"
						#x1 = "ticket= "substr($0, 47, 8) "\t"
						#x2 = "consec= "substr($0,1,8) "\t"
						#x3 = "qty_promo = " item_a_qty[item] "\t"
						#x4 = "tot_promo = " item_a_tot_item[item] "\t"
						#x5 = "articulo= " item_a_s_desc[item]
						#print x1 x2 x3 x4  x5 | "cat 1>&2"
					}
                	if (item > Max_Item) {Max_Item = item}
				} #Termina if ((event_key ~ /Key001/) || (event_key ~ /Key005/))
			} # Termina while ((event_key !~ /Key040/) && (event_key !~ /Key070/))
		} #Termina if (tipo = "venta")
		if (tipo == "comida_empleado") {
		}
		if (tipo == "orden_cancelada") {
		}
		event_key = "Key" substr($0, 55, 3)
		ticket_a[NR] = substr($0,47,8)
		# Cierre del dia
		if (event_key ~ /Key091/) {
			Flag = 0
		}

	} # Termina if (event_key ~ /Key510/)

	#Pago con tarjeta credito/debito
	if (event_key ~ /Key511/) {
		cta_num = ""; aut_num = ""
		split($2,tarjeta_a,"|")
		cta_num = substr(tarjeta_a[6], length(tarjeta_a[6]) -3, 4)
		aut_num = substr(tarjeta_a[4], 1, 6)	
	}

	#Pago con tarjeta credito/debito
	if (event_key ~ /Key512/) {
		split(substr($0,134,50), proveedor_tarjeta_a, "|")
		prosa = proveedor_tarjeta_a[3]
	}

	# Reinicio de POS
	event_key = "Key" substr($0, 55, 3)
	if (event_key ~ /Key050/ && substr($0,47,8) == "00000000") {
		if (getline!=1){break;}
		event_key = "Key" substr($0, 55, 3)
		# Detecta evento de reinicio
		if (event_key ~ /Key018/ && substr($0,47,8) == "00000000") {
			ticket_rec = ticket_a[NR-2]
			if (getline!=1){break;}
			ticket_actual = substr($0,47,8)
			event_key = "Key" substr($0, 55, 3)
			# Proceso de restauracion
			while (event_key ~ /Key071/ || ticket_actual == "00000000"){
				if (getline!=1){break;}
				ticket_actual = substr($0,47,8)
				event_key = "Key" substr($0, 55, 3)
			}
			# Borrar registro si no se restaura ticket
			if (ticket_actual!=ticket_rec){
				Max_Item = 0
				boleta = ""
				cajero_num = ""
				cambio = ""
				comer_llevar = ""
				consecutivo = ""
				dolares = 0
				efectivo = 0
				fecha = ""
				gte_num = ""
				gte_name = ""
				hora_ini = ""
				hora_fin = ""
				pago = 0
				POS = 0
				qty = 0
				rest = ""
				ticket_num = 0
				tipo = "venta"
				tipo_tarjeta = ""
				tot_ticket_canc = 0
				tot_tarjeta = 0                     #importe pagado con tarjeta
				tot_ticket = 0
				tot_ticket_str = 0
				delete item_a_event;		delete item_r_event;		delete item_s_event;
				delete item_a_consecutivo; 	delete item_r_consecutivo;	delete item_s_consecutivo;
				delete item_a_id_producto; 	delete item_r_id_producto;	delete item_s_id_producto;
				delete item_a_extra_char; 	delete item_r_extra_char;	delete item_s_extra_char;
				delete item_a_s_desc;		delete item_r_s_desc;		delete item_s_s_desc;
				delete item_a_l_desc;		delete item_r_l_desc;		delete item_s_l_desc;
				delete item_a_qty;		delete item_r_qty;		delete item_s_qty;
				delete item_a_tot_item;		delete item_r_tot_item;		delete item_s_tot_item;
				delete item_a_qty_canc;		delete item_r_qty_canc;		delete item_s_qty_canc;
				delete item_a_tot_item_canc;	delete item_r_tot_item_canc;	delete item_s_tot_item_canc;
				delete item_a_accion;		delete item_r_accion;		delete item_s_accion;
				delete item_a_tipo;
				delete item_a_clave_iva;
				break
			}
		}
		continue
	}

	# Finaliza correccion de ticket despues de cobro
	if (event_key ~ /Key064/ && ticket_a[NR]==ticket_a[NR-1] && length(boleta)>1 && length(hora_fin)==6){
		if (getline!=1){break;}
		event_key = "Key" substr($0, 55, 3)
		if (event_key ~ /Key018/){
			fin_transaccion = 1;
			break;
		}
	}

	if (Flag == 1 ) { if (getline!=1){break;} }
	event_key = "Key" substr($0, 55, 3)

	# Cierre del dia
    if (event_key ~ /Key091/) {
        boleta = substr($0,47,8)  ".x.bop"
		Flag = 0
		tipo = "lectura_cierre"; lectura_cierre = (substr($0, 151, 10) + 0)/100
		printf("%7s%s", rest, ",")                              #1  mysql rest char(7)
		printf("%8s%s", fecha, ",")                             #2  mysql fecha date yyyymmdd
		printf("%6s%s", hora_ini, ",")                          #3  mysql hora_ini time hhmmss
		printf("%6s%s", hora_ini, ",")                          #4  mysql hora_fin time hhmmss
		printf("%6s%s", POS,",")                                #5  mysql POS smallint(6)
		printf("%8s%s", gte_num, ",")                           #6  mysql gerente_num smallint(5)
		printf("%30s%s", "", ",")                               #7  mysql gerente_name char(30)
		printf("%8s%s", cajero_num,",")                         #8  mysql cajero_num smallint(5)
		printf("%8s%s", ticket_largo, ",")                      #9  mysql ticket_num int(8)
		printf("%3s%s", 1, ",")                                 #10 mysql item samllint(3)
		printf("%4s%s", " ", ",")                               #11 mysql extra_char char(4)
		printf("%7s%s", 0, ",")                                 #12 mysql qty int(7)
		printf("%7s%s", " ",",")                                #13 mysql id_producto int(7)
		printf("%30s%s"," ", ",")                               #14 mysql articulo char(30)
		printf("%8s%s", "", ",")                                #15 mysql cancelacion_AT decimal(9,2)
		printf("%8s%s", 0, ",")                                 #16 mysql tot_item decimal(9,2)
		printf("%4s%s", " ", ",")                               ##### SE ACABA DE AGREGAR
		printf("%10.2f%s", lectura_cierre, ",")                 #17 tot_ticket (10,2)
		printf("%7s%s", " ",",")                                #18 mysql comer_llevar char(7)
		printf("%10s%s", 0 , ",")                               #19 mysql efectivo decimal(10,2)
		printf("%10s%s", 0, ",")                                #20 mysql cambio decimal(10,2)
		printf("%6s%s", 0, ",")                                 #21 mysql dolares decimal(5,2)
		printf("%10s%s", 0,",")                                 #22 mysql tot_tarjet decimal(9,2)
		printf("%9s%s", " ", ",")                               #23 mysql tipo_tarjeta char(9)
		printf("%10s%s", 0,",")                                 #24 iva decimal (9,2)
		printf("%16s%s", tipo,",")                              #25 tipo char(16)
		printf("%16s%s", my_file, ",")                          #Boleta
		printf("%8s%s", business_date, "\n")
		exit
    } #
} #Termina while (Flag == 1)
if (fin_transaccion==0){next}
######## Inicia nuevo index #####################################################################################
delete index_a
delete new_index_a
delete item_r_id_producto
delete item_r_extra_char
delete item_r_s_desc
delete item_r_l_desc
delete item_r_qty
delete item_r_tot_item
delete item_r_qty_canc
delete item_r_tot_item_canc
delete item_r_tipo
delete item_r_clave_iva

#Debug arreglo original	
# r1 = 93354 
# r2 = 93354
# if(int(ticket_largo) >= r1 && int(ticket_largo) <= r2){ # If Debug condition
# print "\nAnalizando renglones de consecutivo "  r1 " - " r2 | "cat 1>&2"
#        for(k=1; k<= Max_Item; k++) {
#                if(k == 1) {
#                        print "\nArreglo original. Consecutivo = " ticket_largo | "cat 1>&2";
#                        h1 = "consec\t\titem\titem_id\text_cha\tqty\ttot_item\t"
#                        h2 = "qty_can\t\ttot_can\t\tarticulo\ttot_ticket\ttipo"
#                        print h1 h2| "cat 1>&2"
#                }
#                x1 = substr($0,1,8) "\t" k "\t" item_a_id_producto[k] "\t"
#                x2 = item_a_extra_char[k] "\t" item_a_qty[k] "\t" item_a_tot_item[k] "\t\t"
#                x3 = item_a_qty_canc[k] "\t\t" item_a_tot_item_canc[k] "\t\t"
#                x4 = item_a_s_desc[k] "\t" tot_ticket_str "\t" item_a_tipo[k]
#                print x1 x2 x3 x4 | "cat 1>&2"
#        }
# } # End if Debug condition

#Se genera el indice
for (k=1; k<= Max_Item; k++){
	index_a[k,1] = item_a_id_producto[k] item_a_extra_char[k]
	index_a[k,2] = 0
	index_a[k,3] = item_a_tipo[k]
	#index_a[k,1] = item_a_id_producto[k] item_a_extra_char[k] item_a_tipo[k]
	#if (substr($0,5,4) >= r1 && (substr($0,5,4) <= r2)){print "index_a[" k ",1]= " index_a[k,1] | "cat 1>&2"}
}
# Se cuentan las currencias de cada indice
counter = 0
if (Max_Item > 0) {
	for (m =1; m <= Max_Item; m++){
		counter = 0
		if (length(index_a[m,1]) > 0 ) {
			for (n = m ; n<= Max_Item; n++) {
				if (length(index_a[n,1]) > 0) {
					if(index_a[m,1] == index_a[n,1] && index_a[m,3]==index_a[n,3]) {
						counter++
						index_a[m,2] = counter
						#if (substr($0,5,4) >= r1 && (substr($0,5,4) <= r2)) {
						#print "index_a[" m ",1]= " index_a[m,1] "\t" "index_a[" m ",2]= " index_a[m,2]| "cat 1>&2"}
					}
				}
			}
		}
	}
}
# Se genera un arreglo sin repeticiones del indice, es decir, se identicfica solo la primera ocurrencia del indice.
index_counter = 0
for (i=1; i <= Max_Item; i++) {
	if (index_a[i,2] == 1) {
		index_counter++
		new_index_a[index_counter] = index_a[i,1] index_a[i,3]
		#if (substr($0,5,4) >= r1 && (substr($0,5,4) <= r2)) {print "new_index_a[" index_counter"]=\t"new_index_a[index_counter] | "cat 1>&2"}
	}	
}
# Se suman las eventos donde se encuentre el indice en cuestion en el arreglo item_r_xxx (arreglo de resumen de tamaño index_counter)
for (m=1; m<= index_counter; m++) {
	for (k=1; k<= Max_Item; k++) {
		my_index = item_a_id_producto[k] item_a_extra_char[k] item_a_tipo[k]
		if(new_index_a[m] == my_index) {
			item_r_id_producto[m]	= item_a_id_producto[k]
			item_r_extra_char[m]    = item_a_extra_char[k]
			item_r_s_desc[m]        = item_a_s_desc[k]
			item_r_l_desc[m]        = item_a_l_desc[k]
			item_r_tipo[m]		= item_a_tipo[k]
			item_r_tot_item[m]      = item_r_tot_item[m] + item_a_tot_item[k]
			item_r_qty[m]           = item_r_qty[m] + item_a_qty[k]
			item_r_qty_canc[m]      = item_r_qty_canc[m] + item_a_qty_canc[k]
			item_r_tot_item_canc[m] = item_r_tot_item_canc[m] + item_a_tot_item_canc[k]
			item_r_clave_iva[m]	= item_a_clave_iva[k]
		}
	}
}

# Debug arreglo resumen
# if(int(ticket_largo) >= r1 && int(ticket_largo) <= r2){ # If Debug condition
#        for(k=1; k<= index_counter; k++) {
#                if(k == 1) {
#                        print "\nArreglo resumido ANTES del ajuste de promo. Consecutivo = " substr($0,5,4) | "cat 1>&2";
#                        h1 = "consec\t\titem\titem_id\text_cha\tqty\ttot_item\t"
#                        h2 = "qty_can\t\ttot_can\t\tarticulo\ttot_ticket\ttipo"
#                        print h1 h2| "cat 1>&2"
#                }
#                x1 = substr($0,1,8) "\t" k "\t" item_r_id_producto[k] "\t"
#                x2 = item_r_extra_char[k] "\t" item_r_qty[k] "\t" item_r_tot_item[k] "\t\t"
#                x3 = item_r_qty_canc[k] "\t\t" item_r_tot_item_canc[k] "\t\t"
#                x4 = item_r_s_desc[k] "\t" tot_ticket_str "\t" item_r_tipo[k]
#                print x1 x2 x3 x4 | "cat 1>&2" } #for(k=1; k<= index_counter; k++)
# } # End if Debug condition

# Se resta el promo del pool del arreglo
descuento_promo = 0
numero_promo = 0
for (m=1; m<= index_counter; m++) {
	if (item_r_tipo[m] == "promocion" ) {
		numero_promo++	#Se cuenta si existen promos
		index_promo = item_r_id_producto[m] item_r_extra_char[m]
		#print item_r_tipo[m] " " index_promo | "cat 1>&2"
		for(n = 1; n <= index_counter; n++) {
			if ( (index_promo == item_r_id_producto[n] item_r_extra_char[n])  && item_r_tipo[n] "venta" ) {
				descuento_promo++ #Se descuenta de la venta para eliminar venta duplicada.
				item_r_tot_item[n] = item_r_tot_item[n] - item_r_tot_item[m]
				item_r_qty[n] = item_r_qty[n]  - item_r_qty[m]
				item_r_tot_item[m] = 0
				break
			}#if ( index_promo == item_a_id_producto[n] item_a_extra_char[n]  && item_r_tipo[n] "venta" )
		}# for(n = 1; n <= index_counter; n++)
	} #if (item_r_tipo[m] == "promocion" )
} #for (m=1; m<= index_counter; m++)
if (numero_promo > 0 && descuento_promo == 0) {
	print "En consecutivo " substr($0,1,8) " no se pudo descontar promo de venta,"
	print "En consecutivo " substr($0,1,8) " no se pudo descontar promo de venta," | "cat 1>&2"
}

# #Debug. Impreso de comprobacion para un ticket determinado
# if(int(ticket_largo) >= r1 && int(ticket_largo) <= r2){ # If Debug condition
# 	for(k=1; k<= index_counter; k++) {
# 		if(k == 1) {
# 			print "\nArreglo DESPUES del ajuste de promo. Consecutivo = " substr($0,5,4) | "cat 1>&2";
#                	h1 = "consec\t\titem\titem_id\text_cha\tqty\ttot_item\t"
#                 	h2 = "qty_can\t\ttot_can\t\tarticulo\ttot_ticket\ttipo"
#                	print h1 h2| "cat 1>&2"
#                }
#       		x1 = substr($0,1,8) "\t" k "\t" item_r_id_producto[k] "\t"
#       		x2 = item_r_extra_char[k] "\t" item_r_qty[k] "\t" item_r_tot_item[k] "\t\t"
#       		x3 = item_r_qty_canc[k] "\t\t" item_r_tot_item_canc[k] "\t\t"
#                x4 = item_r_s_desc[k] "\t" tot_ticket_str "\t" item_r_tipo[k]
#                print x1 x2 x3 x4 | "cat 1>&2"
#        }
# } #End if debug condition

######## Termina nuevo index ################################################################################
if (Max_Item > 0 && length(boleta)>1 && length(hora_fin)==6) {
	tot_ticket = 0
	counter = 0
	if (tipo != "venta") {iva = 0}
	if(tipo != "pos_tomadora") {
		for (i=1; i<= index_counter; i++){
			tot_ticket = tot_ticket + item_r_tot_item[i]/100
			if (item_r_extra_char[i] = "0") {(item_r_extra_char[i] ="") }
			for(j=1; j<=2; j++) { #procesar venta y cancelaciones
				#Primero las ventas. Solo casos donde ventas y cancelaciones sean diferentes.
				#Si ventas = cancelaciones, no imprimir
				#if( ( j == 1 ) && (item_r_qty[i] > 0) && ((item_r_qty[i] - item_r_qty_canc[i]) != 0) ){
				if(  j == 1  && (item_r_qty[i] - item_r_qty_canc[i]) > 0 ){
					counter++
					printf("%7s%s", rest, ",")				#1  mysql rest char(7)
					printf("%8s%s", fecha, ",")				#2  mysql fecha date yyyymmdd
					printf("%6s%s",	hora_ini, ",")				#3  mysql hora_ini time hhmmss
					printf("%6s%s", hora_fin, ",")				#4  mysql hora_fin time hhmmss
					printf("%6s%s", POS,",")				#5  mysql POS smallint(6)
					if(tipo != "venta" || gte_num>0) {
						printf("%8s%s", gte_num, ",")			#6  mysql gerente_num smallint(5)
						printf("%30s%s", gte_name, ",")			#7  mysql gerente_name char(30)
					}else{
						printf("%8s%s", "", ",")			#6  mysql gerente_num smallint(5)
						printf("%30s%s", "", ",")			#7  mysql gerente_name char(30)
					}
					printf("%8s%s", cajero_num,",")				#8  mysql cajero_num smallint(5)
					printf("%8s%s", ticket_largo, ",")			#9  mysql ticket_num int(8)
					printf("%3s%s", counter, ",")				#10 mysql item samllint(3)
					printf("%4s%s", item_r_extra_char[i],",")		#11 mysql extra_char char(4)
					printf("%7s%s", abs(item_r_qty[i] - item_r_qty_canc[i]), ",")	#12 mysql qty int(7)
					printf("%7s%s", item_r_id_producto[i],",")		#13 mysql id_producto int(7)
					if (item_r_s_desc[i] ~ /Sin  / || item_r_s_desc[i] ~ /Extra/ )
						printf("%-30s%s",item_r_s_desc[i], ",")		#14 mysql articulo char(30)
					else
						printf("%30s%s",item_r_l_desc[i], ",")
					printf("%8s%s", "", ",")				#15 mysql cancelacion_AT decimal(9,2)
					printf("%8s%s", (item_r_tot_item[i]-item_r_tot_item_canc[i])/100, ",")		#16 mysql tot_item decimal(9,2)
					printf("%4s%s", item_r_clave_iva[i],",")		# COLUMNA NUEVA!!!! ###		
					printf("%11s%s", tot_ticket_str, ",")			#17 tot_ticket (10,2)
					printf("%7s%s", comer_llevar,",")			#18 mysql comer_llevar char(7)
					printf("%10s%s", efectivo, ",")				#19 mysql efectivo decimal(10,2)
					printf("%10s%s", cambio, ",")                         	#20 mysql cambio decimal(10,2)	
					printf("%6s%s", dolares, ",")				#21 mysql dolares decimal(5,2)
					printf("%10s%s", tot_tarjeta,",")			#22 mysql tot_tarjet decimal(9,2)
					printf("%16s%s", tipo_tarjeta, ",")			#23 mysql tipo_tarjeta char (12)
					printf("%10s%s", iva,",")				#24 iva decimal (9,2)

					if (tipo == "venta")
						printf("%16s%s", item_r_tipo[i],",")		#25 "venta" incluye venta o promo para que
					if (tipo != "venta")
						printf("%16s%s", tipo,",")			#tipo se refiere a comida de empleado, desperdicio (etc)
					printf("%16s%s", boleta, ",")				#26 boleta
					printf("%8s%s", business_date, "\n")                    
				} # Termina if( ( j == 1 ) && (item_r_qty[i] > 0) && ((item_r_qty[i] - item_r_qty_canc[i]) > 0)
				
				#
				#Segundo: Cancelaciones. Imprimir gte numero y nombre.
				#Hacer item_r_tot_item[i] = ""
				#
				
				if ( j == 2 && (item_r_qty_canc[i] > 100 )) {
					counter++
					printf("%7s%s", rest, ",")                              #1  mysql rest char(7)
					printf("%8s%s", fecha, ",")                             #2  mysql fecha date yyyymmdd
					printf("%6s%s", hora_ini, ",")                          #3  mysql hora_ini time hhmmss
					printf("%6s%s", hora_fin, ",")                          #4  mysql hora_fin time hhmmss
					printf("%6s%s", POS,",")                                #5  mysql POS smallint(6)
					printf("%8s%s", gte_num, ",")                           #6  mysql gerente_num smallint(5)
					printf("%30s%s", gte_name, ",")                         #7  mysql gerente_name char(30)
					printf("%8s%s", cajero_num,",")                         #8  mysql cajero_num smallint(5)
					printf("%8s%s", ticket_largo, ",")                      #9  mysql ticket_num int(8)
					printf("%3s%s", counter, ",")                           #10 mysql item samllint(3)
					printf("%4s%s", item_r_extra_char[i],",")               #11 mysql extra_char char(4)
					printf("%7s%s", item_r_qty_canc[i], ",")                #12 mysql qty int(7)
					printf("%7s%s", item_r_id_producto[i],",")              #13 mysql id_producto int(7)
					if (item_r_s_desc[i] ~ /Sin  / || item_r_s_desc[i] ~ /Extra/ )
						printf("%-30s%s",item_r_s_desc[i], ",")		#14 mysql articulo char(30)
					else
						printf("%30s%s",item_r_l_desc[i], ",")
					printf("%8s%s", item_r_tot_item_canc[i]/100,",")	#15 mysql cancelacion_AT decimal(9,2)
					printf("%8s%s", "", ",")            			#16 mysql tot_item decimal(9,2)
					printf("%4s%s", item_r_clave_iva[i],",")                # COLUMNA NUEVA!!!! ###
					printf("%11s%s", tot_ticket_str, ",")                   #17 tot_ticket (10,2)
					printf("%7s%s", comer_llevar,",")                       #18 mysql comer_llevar char(7)
					printf("%10s%s", efectivo, ",")                         #19 mysql efectivo decimal(10,2)
					printf("%10s%s", cambio, ",")                           #20 mysql cambio decimal(10,2)
					printf("%6s%s", dolares, ",")                           #21 mysql dolares decimal(5,2)
					printf("%10s%s", tot_tarjeta,",")                       #22 mysql tot_tarjet decimal(9,2)
					printf("%16s%s", tipo_tarjeta, ",")			#23 mysql tipo_tarjeta char (12)
					printf("%10s%s", iva,",")                               #24 iva decimal (9,2)
					if (tipo == "venta")
						printf("%16s%s", item_r_tipo[i],",")            #25 "venta" incluye venta o promo para que
					if (tipo != "venta")
						printf("%16s%s", tipo,",")                      #tipo se refiere a comida de empleado, desperdicio (etc)
					printf("%21s%s", boleta, ",")
					printf("%8s%s", business_date, "\n")
				} # if ( j == 2 && (item_r_qty_canc[i] > 0 )
			} #for(j=1; j<=2; j++)
		}#for (i=1; i<= Max_Item; i++)
	}#if(tipo != "pos_tomadora") {
	if ( (tot_ticket_str - tot_ticket) > 0.01)
		print " rest=" rest  " fecha=" fecha " POS=" POS  " NR=" NR " Ticket=" ticket_num " Err. tot_ticket_str=" tot_ticket_str " tot_ticket=" tot_ticket |"cat 1>&2"
	Max_Item = 0
} #Termina if (Max_Item > 0)
} # Fin del programa

#function restar_promo (index_counter, consec,item_r_id_producto) {
#	for (k = 1; k<= index_counter; k++) {
#		x1 =  substr($0,1,8) "\t" k "\t" item_r_id_producto[k] "\t"
#		print x1 | "cat 1>&2"
#	}
#return 
#}

function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
}
function abs(v) {return v < 0 ? -v : v}
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

' $*