#INCLUDE "Acda100.ch" 
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACD100VG()
 Local aArea    := GetArea()
 Local aSvSC9	:= SC9->(GetArea())
 Local aSvSDC	:= SDC->(GetArea())
 Local lREt     := .T.


    _cAQuer := " SELECT C9_PRODUTO,C9_LOCAL,C9_SEQUEN,C9_PEDIDO,C9_QTDLIB FROM  "+RetSQLName('SC9')+" SC9 "
    _cAQuer += " WHERE SC9.D_E_L_E_T_ <> '*' "
    _cAQuer += " AND SC9.C9_OK='"+SC9->C9_OK+"' "
    _cAQuer += " AND SC9.C9_OK != '' "

    TcQuery _cAQuer New Alias "_aQR"
    dbSelectArea("_aQR")
    While !_aQR->(EOF())


        _cAQuery := " SELECT COUNT(*) AS DATO FROM  "+RetSQLName('SDC')+" SDC INNER JOIN "+RetSQLName('SB1')+" SB1 "
        _cAQuery += " ON B1_COD='"+_aQR->C9_PRODUTO+"' AND B1_LOCALIZ='S' AND SB1.D_E_L_E_T_ <> '*'"
        _cAQuery += " WHERE SDC.D_E_L_E_T_ <> '*' "
        _cAQuery += " AND DC_PRODUTO='"+_aQR->C9_PRODUTO+"' "
        _cAQuery += " AND DC_LOCAL='"+_aQR->C9_LOCAL+"' "
        _cAQuery += " AND DC_SEQ='"+_aQR->C9_SEQUEN+"' "
        _cAQuery += " AND DC_PEDIDO= '"+_aQR->C9_PEDIDO+"' "

        TcQuery _cAQuery New Alias "_aQRY"
        dbSelectArea("_aQRY")
        If !_aQRY->(EOF())
            If _aQRY->DATO != _aQR->C9_QTDLIB .AND. _aQRY->DATO > 0
                MsgAlert("Se encontro inconsistencia en la cantidad reservada vs Liberada pedido "+ALLTRIM(_aQR->C9_PEDIDO)+", producto "+ALLTRIM(_aQR->C9_PRODUTO)+ ", Se recomienda anular y rehacer la liberación. Si el problema persiste por favor validar con el administrador.","Error de generación")
                lREt := .F.
                _aQR->(dbSkip())
                _aQRY->(dbCloseArea())
                loop      
            Endif
        EndIf
        _aQRY->(dbCloseArea())
        _aQR->(dbSkip())

    EndDo
    _aQR->(dbCloseArea())


    RestArea(aSvSC9)
    RestArea(aSvSDC)    
    RestArea(aArea)

Return lREt
