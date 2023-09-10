#INCLUDE "Acda100.ch" 
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACD100VG()
 Local aArea    := GetArea()
 Local lREt     := .T.

SC9->(dbGoTop())
While !SC9->(Eof())
    _cAQuery := " SELECT COUNT(*) AS DATO FROM  "+RetSQLName('SDC')+" SDC INNER JOIN "+RetSQLName('SB1')+" SB1 "
    _cAQuery += " ON B1_COD='"+SC9->C9_PRODUTO+"' AND B1_LOCALIZ='S' AND SB1.D_E_L_E_T_ <> '*'"
    _cAQuery += " WHERE SDC.D_E_L_E_T_ <> '*' "
    _cAQuery += " AND DC_PRODUTO='"+SC9->C9_PRODUTO+"' "
    _cAQuery += " AND DC_LOCAL='"+SC9->C9_LOCAL+"' "
    _cAQuery += " AND DC_SEQ='"+SC9->C9_SEQUEN+"' "
    _cAQuery += " AND DC_PEDIDO= '"+SC9->C9_PEDIDO+"' "

    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    If !_aQRY->(EOF())
        If _aQRY->DATO != SC9->C9_QTDLIB
            MsgAlert("Se encontro inconsistencia en la cantidad reservada vs Liberada pedido "+ALLTRIM(SC9->C9_PEDIDO)+", producto "+ALLTRIM(SC9->C9_PRODUTO)+ ", Se recomienda anular y rehacer la liberación. Si el problema persiste por favor validar con el administrador.","Error de generación")
            lREt := .F.
            SC9->(dbSkip())
            _aQRY->(dbCloseArea())
            loop
        Endif
    EndIf
    _aQRY->(dbCloseArea())
	SC9->(dbSkip())
EndDo
    RestArea(aArea)

Return lREt
