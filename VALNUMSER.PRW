#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} VALNUMSER
 si genero una orden de producción el sistema registre el campo C2_LOCAL con la información del campo B1_XALM pero si ese campo es VACIO 
 tome el campo de la bodega default del producto o el B1_LOCPAD. 
@type function
@version 
@author Samuel Avila
@since 29/08/2023

/*/
User function VALNUMSER()
	Local aArea := getArea()
	Local cBodega
    Local cProducto
    Local cNumser
    Local cLocaliz
    Local cLote
    Local cNLote

	// Verificar si el campo B1_XALM esta Vacio
	dbSelectArea( "SDB " )
	SDB ->(dbSetOrder(2))
	IF SDB->(DBSEEK(xfilial("SB1")+cProducto))
		IF Empty(B1_XALM)
			cBodega := B1_LOCPAD // Usar el valor del campo B1_LOCPAD  o la bodega default del Pto
		else
			cBodega := B1_XALM // Usar el valor del campo B1_XALM  o Almacen de Produccion
        End If
    End If
	("SB1")->(DBCloseArea())
	RestArea(aArea)    
RETURN cBodega
