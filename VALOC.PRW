#Include "Protheus.Ch"
#Include "Rwmake.ch"
#Include "TopConn.ch"

User Function VALOC(XORCOMP,CLIENTE)
 Local cAQuery := ""
 Local lRet := .T.
 
    

    cAQuery := " SELECT C5_NUM FROM  SC5010  SC5 "
	cAQuery += " WHERE D_E_L_E_T_ <> '*' "
	cAQuery += " AND TRIM(C5_XORCOMP) =  '"+ALLTRIM(XORCOMP)+"' "
	cAQuery += " AND TRIM(C5_CLIENTE) =  '"+ALLTRIM(CLIENTE)+"' "
	TcQuery cAQuery New Alias "_aQRY"
	dbSelectArea("_aQRY")
	IF !_aQRY->(EOF())

        msgAlert("El número de orden de compra "+ALLTRIM(XORCOMP)+" ingresado ya existe en el pedido de venta "+_aQRY->C5_NUM+" de este cliente")

	EndIf
	_aQRY->(dbCloseArea())

Return lRet
                                                                                                       
