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
	Local csaldo := ""
	Local cQuant := ""
	Local lRet := .T.

	If(Funname()=="MATA265")
		cBodega := M->DA_LOCAL
		cProducto := M->DA_PRODUTO
		cNumser := M->DB_NUMSER
		cLocaliz := gdFieldGet("DB_LOCALIZ")
		cLote := M->DA_LOTECTL
		cNLote := M->DA_NUMLOTE
		csaldo := M->DA_SALDO
		cQuant	:= M->DA_QTDORI

		// Verificar si el campo B1_XALM esta Vacio
		dbSelectArea( "SDB " )
		SDB ->(dbSetOrder(2))
		IF SDB->(DBSEEK(xfilial("SDB")+cProducto+cBodega+cLote+cNLote+cNumser+cLocaliz))
			IF SDB->(DB_TM) <='499'
				IF csaldo == cQuant
					MSGALERT( "Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en el documento "+ALLTRIM(SDB->(DB_DOC)), "Entrada duplicada" )
					lRet := .F.
				EndIF
			EndIf
		EndIf
		("SDB")->(DBCloseArea())	

	EndIf
	RestArea(aArea)    
RETURN lRet
