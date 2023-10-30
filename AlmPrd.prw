#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#DEFINE CRLF chr(13)+chr(10)
#DEFINE LF chr(10)

/*/{Protheus.doc} AlmPrd
 si genero una orden de producción el sistema registre el campo C2_LOCAL con la información del campo B1_XALM pero si ese campo es VACIO 
 tome el campo de la bodega default del producto o el B1_LOCPAD. 
@type function
@version 
@author Samuel Avila
@since 29/08/2023

/*/
User function AlmPrd(cProducto)
	Local aArea := getArea()
	Local cBodega

	// Verificar si el campo B1_XALM esta Vacio
	DBSELECTAREA( "SB1" )
	SB1 ->(DBSETORDER(1))
	IF SB1->(DBSEEK(xfilial("SB1")+cProducto))
		IF Empty(B1_XALM)
			cBodega := B1_LOCPAD // Usar el valor del campo B1_LOCPAD  o la bodega default del Pto
		else
			cBodega := B1_XALM // Usar el valor del campo B1_XALM  o Almacen de Produccion
        End If
    End If
	("SB1")->(DBCloseArea())
	RestArea(aArea)    
RETURN cBodega
