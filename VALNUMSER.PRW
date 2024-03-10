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
	Local cBodega := ""
    Local cProducto := ""
    Local cNumser := ""
    Local cLocaliz := ""
    Local cLote := ""
    Local cNLote := ""
	Local lRet := .T.

	If(Funname()=="MATA265")
		cBodega := M->DA_LOCAL
		cProducto := M->DA_PRODUTO
		cNumser := M->DB_NUMSERI
		cLocaliz := gdFieldGet("DB_LOCALIZ")
		cLote := M->DA_LOTECTL
		cNLote := M->DA_NUMLOTE

		// Verificar si el campo B1_XALM esta Vacio
		dbSelectArea( "SDB " )
		SDB ->(dbSetOrder(2))
		IF SDB->(DBSEEK(xfilial("SDB")+cProducto+cBodega+cLote+cNLote+cNumser+cLocaliz))
			IF SDB->(DB_TM) <='499'
				MSGALERT( "Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en el documento "+ALLTRIM(SDB->(DB_DOC)), "Entrada duplicada" )
				lRet := .F.
			EndIf
		EndIf
		("SDB")->(DBCloseArea())	

	EndIf
	RestArea(aArea)    
RETURN lRet
