BEGIN{ 	
	OFS = FS
	MONTHS["ENE"] = "01"
    MONTHS["FEB"] = "02"
    MONTHS["MAR"] = "03"
    MONTHS["ABR"] = "04"
    MONTHS["MAY"] = "05"
    MONTHS["JUN"] = "06"
    MONTHS["JUL"] = "07"
    MONTHS["AGO"] = "08"
    MONTHS["SEP"] = "09"
    MONTHS["OCT"] = "10"
    MONTHS["NOV"] = "11"
    MONTHS["DIC"] = "12"
	nombre = ""
	fecha = ""
	hora_entrada = ""
	hora_salida = ""
	area = ""
	tiempo_total = ""
	tiempo_break = ""
}
{
	if (($0 ~ /LUN,|MAR,|MIE,|JUE,|VIE,|SAB,|DOM,/ || $0 ~ /==>/) && $0 !~ /SIN SCHEDULE/){
		endName = 0
		# Get name for schedule group
		if ($1 !~ /LUN,|MAR,|MIE,|JUE,|VIE,|SAB,|DOM,/ && $0 !~ /==>/){
			nombre = ""
			endName = NF-8
            for ( fieldCounter = 1; fieldCounter <= endName; fieldCounter++ )
                ( nombre == "" ) ? nombre = $fieldCounter : nombre = nombre" "$fieldCounter
		}
		# Continuous schedule
		if ($1 !~ /==>/){
			# Get schedule date
			split($(endName+3), restDate, "/" )
			tempDate = "20" restDate[2] " " MONTHS[$(endName+2)] " " restDate[1]
			fecha = strftime( "%Y-%m-%d", mktime( tempDate " 0 0 0"))
		}else
			endName = -2
		# Get schedule hours and work place
		split($(endName+5), restHour, "[-:]")
		hora_entrada = createDate( tempDate, restHour[1], restHour[2])
		hora_salida = createDate( tempDate, restHour[3], restHour[4])
		area = $(endName+6)
		tiempo_total = $(endName+7)
		tiempo_break = substr($(endName+8),0,length($(endName+8))-1)
		if (length(tiempo_break)==0)
			tiempo_break = 0
		# Print structured data
		print nombre","fecha","rest","hora_entrada","hora_salida","area","tiempo_total","tiempo_break
	}
}

function createDate(spacedDate,HH,MM,DATETIME) {
    if ( HH == "00" )
        DATETIME = strftime ( "%Y-%m-%d %H:%M:%S", mktime ( spacedDate " +24 " MM " 0" ) )
    else if ( HH == "01" )
        DATETIME = strftime ( "%Y-%m-%d %H:%M:%S", mktime ( spacedDate " +25 " MM " 0" ) )
    else
        DATETIME = strftime ( "%Y-%m-%d %H:%M:%S", mktime ( spacedDate " " HH " " MM " 0" ) )
    return DATETIME
}