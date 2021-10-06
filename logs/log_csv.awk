awk '
 BEGIN  {       OFS = ","      #Output Field Separator
                my_tab = ","   #coma separated value. It could be ","
		############ Flag_Print_SQL = 0 imprime separado por comas ##################
		Flag_Print_SQL = 1   # Flag_Print_SQL = 1 imprime en formato para subir a SQL
		#############################################################################
		if (Flag_Print_SQL == 1) { print "Imprimiendo registros SQL para subir a Base de Datos" | "cat 1>&2"}
		if (Flag_Print_SQL != 1) { print "Imprimiendo archivo separado por comas para analisis en Excel" | "cat 1>&2"}
        }
{ #Inicio de programa	
#if ((length($1) == 84) && (length($0) == 511)) {
		for (j=1; j <= (length($0)); j++)  {
			if ( j <  (length($0)-1)) printf("%s%s", substr($0,j,1), ",")
			if ( j == (length($0)-1)) printf("%s", substr($0,j,1))
			if ( j == (length($0)  )) printf("%s","\n")
		}	
	}
#}
END     {
	


}' $*

