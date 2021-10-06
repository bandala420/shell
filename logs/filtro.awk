awk '
 BEGIN  {       FS = ","      #Output Field Separator
		error=0
       		error_documento=0
       		error_campo=0
		conteo_errores=1

        }

{
	re=/^[0-9]+$/
	if ((NF != 28)) {error_documento=1}
        if ((length ($1) == 7))
		{restaurante[NR]=$1}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 1 restaurante =" $1; 
		conteo_errores=conteo_errores+1}
	if ((length ($2) == 8)) {
		anio = substr( $2,1,4 )
		mes = substr( $2,5,2 )
		dia = substr( $2,7,2 )
		fecha[NR] = anio"-"mes"-"dia
		}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 2 fecha = "$2;
		conteo_errores=conteo_errores+1}

	if ((length ($3) == 6)) 
		{
		h_in=substr($3,1,2)
                m_in= substr($3,3,2)
                s_in=substr($3,5,2)
		hora_ini[NR]=h_in":"m_in":"s_in
		}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 3 hora_ini = "$3;
		 conteo_errores=conteo_errores+1}

	if ((length ($4) == 6)) 
		{
		 h_fi=substr($4,1,2)
                 m_fi= substr($4,3,2)
                 s_fi=substr($4,5,2)
		 hora_fin[NR]=h_fi":"m_fi":"s_fi
	}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 4 hora_fin = " $4;
		conteo_errores=conteo_errores+1}

	if ((length ($5) == 6)){
		r_estado=0
		for ( i=1 ; i<=6; ++i){
			r_actual=substr($5,i,1)
			if  ( r_actual!=0 && r_estado==0){
				total=7-i
				pos[NR]=substr($5,i,total)
				r_estado=1
			}
		}
	}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 5 POS = " $5; conteo_errores=conteo_errores+1}


	if (( $6~re || $6~" " )) {
                r_estado=0
                for ( i=1 ; i<=9; ++i){
                        r_actual=substr($6,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=9-i
                                num_gerente[NR]=substr($6,i,total)
                                r_estado=1
                        }
			if ( i==5 && r_estado==0 && r_actual=" ") {
                                num_gerente[NR]=0
                        }
                }
        }
        else    {num_gerente[NR]=$6}

	if ((length ($7) == 30)){
		r_estado=0
		for ( i=1 ; i<=30; ++i){
                        r_actual=substr($7,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=31-i
                                nombre_gerente[NR]=substr($7,i,total)
                                r_estado=1
                        }
                        if ( i==30 && r_estado==0 && r_actual==" ") {
                                nombre_gerente[NR]=" "
                        }
                }
	}
	else    {nombre_gerente[NR]=$7}

	if ((length ($8) == 8)) {
		r_estado=0
                for ( i=1 ; i<=8; ++i){
                        r_actual=substr($8,i,1)
                        if  ( r_actual!=0 && r_estado==0){
                                total=9-i
                                cajero[NR]=substr($8,i,total)
                                r_estado=1
                        }
                }

	}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 8"; conteo_errores=conteo_errores+1}

	if ((length ($9) == 8)) {
		r_estado=0
                for ( i=1 ; i<=8; ++i){
                        r_actual=substr($9,i,1)
                        if  ( r_actual!=0 && r_estado==0){
                                total=9-i
                                ticket[NR]=substr($9,i,total)
                                r_estado=1
                        }
                }

	}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 9"; conteo_errores=conteo_errores+1}

	if (( $10~re || $10~" " )) {
		r_estado=0
                for ( i=1 ; i<=3; ++i){
                        r_actual=substr($10,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=4-i
                                num_item[NR]=substr($10,i,total)
                                r_estado=1
                        }
                }

	}
	else	{error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 10"; conteo_errores=conteo_errores+1}


	if ((length ($11) == 4)) {
                r_estado=0
                for ( i=1 ; i<=4; ++i){
                        r_actual=substr($11,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=5-i
                                extra_caracter[NR]=substr($11,i,total)
                                r_estado=1
                        }
			if ( i==4 && r_estado==0 ) {
                                extra_caracter[NR]=" "
                        }
                }
        }
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 11"; conteo_errores=conteo_errores+1}



	if (( $12~re || $12~" " )) {
		r_estado=0
		for ( i=1 ; i<=7; ++i){
                        r_actual=substr($12,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=8-i
                                num_articulo[NR]=substr($12,i,total)
                                r_estado=1
                        }
                }

	}
        else   {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 12"; conteo_errores=conteo_errores+1}

	if (( $13~re || $13~" " )) {
		r_estado=0
                for ( i=1 ; i<=7; ++i){
                        r_actual=substr($13,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=8-i
                                id_articulo[NR]=substr($13,i,total)
                                r_estado=1
                        }
                }

	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 1"; conteo_errores=conteo_errores+1}


	if ((length ($14) == 30)){
                r_estado=0
		adicional=0
                for ( i=1 ; i<=30; ++i){
                        r_actual=substr($14,i,1)
                        if  ( r_actual!=" " && r_estado==0 && adicional==0){
                                total=31-i
				for ( j=i ; j<=30; ++j){
					conteo=substr($14,j,1)
					sig=substr($14,j+1,1)
					if ( conteo == " " && adicional==0 && sig==" " ){
						final=j-1
						adicional=1
					}
				}
                                articulo[NR]=substr($14,i,final)
                                r_estado=1
                        }
                        if ( i==30 && r_estado==0 && r_actual==" ") {
                                articulo[NR]=" "
                        }
                }
        }
	else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 14"; conteo_errores=conteo_errores+1}


	if (( $15 ~ re || $15 ~ " ")) {
		r_estado=0
                for ( i=1 ; i<=8; ++i){
                        r_actual=substr($15,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=9-i
                                total_cancelacion[NR]=substr($15,i,total)
                                r_estado=1
                        }
			if ( i==8 && r_estado==0 && r_actual=" ") {
				total_cancelacion[NR]=0
			}
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 15"; conteo_errores=conteo_errores+1}

	if (( $16 ~ re || $16 ~ " ")) {
		 r_estado=0
                for ( i=1 ; i<=8; ++i){
                        r_actual=substr($16,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=9-i
                                total_item[NR]=substr($16,i,total)
                                r_estado=1
                        }
                        if ( i==8 && r_estado==0 && r_actual=" ") {
                                total_item[NR]=0
                        }
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 16"; conteo_errores=conteo_errores+1}
##____________

      if ((length ($17) == 4)){
                r_estado=0
                for ( i=1 ; i<=4; ++i){
                        r_actual=substr($17,i,1)
                        if  ( r_actual!=0 && r_estado==0){
                                total=5-i
                                tax_index[NR]=substr($17,i,total)
                                r_estado=1
                        }
                }
        }
	else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 17"; conteo_errores=conteo_errores+1}
##------------------
	if (( $18 ~ re || $18 ~ " " || $18 ~ ".")) {
		r_estado=0
                for ( i=1 ; i<=11; ++i){
                        r_actual=substr($18,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=12-i
                                total_ticket[NR]=substr($18,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                total_ticket[NR]=0
                        }
                }

		}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 18"; conteo_errores=conteo_errores+1}


	if ((length ($19) == 7)){
                r_estado=0
                for ( i=1 ; i<=7; ++i){
                        r_actual=substr($19,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=8-i
                                comida_llevar[NR]=substr($19,i,total)
                                r_estado=1
                        }
                        if ( i==7 && r_estado==0 && r_actual==" ") {
                                comida_llevar[NR]=" "
                        }
                }
        }
	else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 19"; conteo_errores=conteo_errores+1}


	if (( $20 ~ re || $20 ~ " ")) {
		r_estado=0
                for ( i=1 ; i<=10; ++i){
                        r_actual=substr($20,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=11-i
                                efectivo[NR]=substr($20,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                efectivo[NR]=0
                        }
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 20"; conteo_errores=conteo_errores+1}

	if (( $21~re || $21~" ")) {
		r_estado=0
                for ( i=1 ; i<=10; ++i){
                        r_actual=substr($21,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=11-i
                                cambio[NR]=substr($21,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                cambio[NR]=0
                        }
                }

	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 21"; conteo_errores=conteo_errores+1}

	if (( $22~re || $22~" ")) {
		r_estado=0
                for ( i=1 ; i<=6; ++i){
                        r_actual=substr($22,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=7-i
                                dolares[NR]=substr($22,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                dolares[NR]=0
                        }
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 22"; conteo_errores=conteo_errores+1}

	if (( $23~re || $23~" ")) {
		r_estado=0
                for ( i=1 ; i<=10; ++i){
                        r_actual=substr($23,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=11-i
                                total_tarjeta[NR]=substr($23,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                total_tarjeta[NR]=0
                        }
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 23"; conteo_errores=conteo_errores+1}


	if ((length ($24) == 16)){
                r_estado=0
                for ( i=1 ; i<=16; ++i){
                        r_actual=substr($24,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=17-i
                                tipo_tarjeta[NR]=substr($24,i,total)
                                r_estado=1
                        }
                        if ( i==16 && r_estado==0 && r_actual==" ") {
                                tipo_tarjeta[NR]=" "
                        }
                }
        }


	if (( $25~re || $25~" ")) {
		 r_estado=0
                for ( i=1 ; i<=10; ++i){
                        r_actual=substr($25,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=11-i
                                iva[NR]=substr($25,i,total)
                                r_estado=1
                        }
                        if ( i==10 && r_estado==0 && r_actual=" ") {
                                iva[NR]=0
                        }
                }
	}
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 25"; conteo_errores=conteo_errores+1}


	if ((length ($26) == 16)){
                r_estado=0
                for ( i=1 ; i<=16; ++i){
                        r_actual=substr($26,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=17-i
                                tipo_venta[NR]=substr($26,i,total)
                                r_estado=1
                        }
                        if ( i==16 && r_estado==0 && r_actual==" ") {
                                tipo_venta[NR]=" "
                        }
                }
        }
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 26"; conteo_errores=conteo_errores+1}

	if (( length($27)>=0 )){
                r_estado=0
		long_cadena=length($27)
		aumento=long_cadena+1
                for ( i=1 ; i<=long_cadena; ++i){
                        r_actual=substr($27,i,1)
                        if  ( r_actual!=" " && r_estado==0){
                                total=aumento-i
                                boleta[NR]=substr($27,i,total)
                                r_estado=1
                        }
                        if ( i==long_cadena && r_estado==0 && r_actual==" ") {
                                boleta[NR]=" "
                        }
                }
        }
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 27 boleta"; conteo_errores=conteo_errores+1}
	##Daclark@ 03 2021  conteo para business date
	if ((length ($28) == 10)) {
                business_date[NR] = $28
                }
        else    {error_campo=1; errores[conteo_errores]= "Error en renglon " NR " campo 28 business_date"; conteo_errores=conteo_errores+1}


}
END     {
		if ( error_campo==0 && error_documento==0 ) {
			for ( i=1 ; i<=NR; ++i){
				if ( i!=2){
				print restaurante[i]","fecha[i]","hora_ini[i]","hora_fin[i]","pos[i]","num_gerente[i]","nombre_gerente[i]","cajero[i]","ticket[i]","num_item[i]","extra_caracter[i]","num_articulo[i]","id_articulo[i]","articulo[i]","total_cancelacion[i]","total_item[i]","tax_index[i]","total_ticket[i]","comida_llevar[i]","efectivo[i]","cambio[i]","dolares[i]","total_tarjeta[i]","tipo_tarjeta[i]","iva[i]","tipo_venta[i]","boleta[i]","business_date[i]
				}

			}
		}
		if ( error_campo==1 ){
			print "Errores campos" | "cat 1>>/root/logs/filtro_logs_globales.log"
			for ( i=1; i<=conteo_errores-1; ++i ){
					print errores[i] | "cat 1>>/root/logs/filtro_logs_globales.log"
			}
		}

		# daclark@ 2021 03 redirigido a log de erroes en lugar de stdout
		 if ( error_documento==1 ){
			print "Error de formato (No contiene las  columnas esperadas)" | "cat 1>>/root/logs/filtro_logs_globales.log"
                }


}' $*
