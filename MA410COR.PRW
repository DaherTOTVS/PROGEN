#Include "Protheus.Ch"
#Include "Rwmake.ch"
#Include "TopConn.ch"

/*------------------------------------------------------------!
!            CAMBIAR LA LEYENDA EN PEDIDOS DE VENTA           !
!                       Duvan Hernandez                       !
!                         16/01/2025                          !
-------------------------------------------------------------*/

User Function MA410COR()

    Local aArea     :=  getArea()
    Local aCoresNew    :=  PARAMIXB // PARAMIXB traz a estrutura do array padrão

    aAdd(aCoresNew,{})
	Ains(aCoresNew,1)
	aCoresNew[1] := {"U_EstadoPed(C5_NUM,'1',C5_NOTA)","BR_PINK","Pedido de venta(Remito de devolucion)"} //Remito

    RestArea(aArea)
Return aCoresNew

User Function MA410LEG()
    Local aArea     :=  getArea()
    Local aLegenda := PARAMIXB

    aAdd(aLegenda,{})
	Ains(aLegenda,4)
	aLegenda[4] := {"BR_PINK" ,"Pedido (Remito de devolucion)"}
    RestArea(aArea)
Return(aLegenda)

user Function EstadoPed(cNumPed,valid,Nota) // 1-> remision parcial 2-> remito de devolucion 3-> factura parcial
 	Local aArea     :=  getArea()
    Local aAreaSC9	:= SC9->(GetArea())
    Local aAreaSD1	:= SD1->(GetArea())
	Local lRet := .F.

    If valid == "1" .AND. AllTrim(Nota)=="REMITO"
        Qryped := " SELECT  DISTINCT C9_REMITO,C9_CLIENTE,C9_LOJA  FROM   "+RetSQLName('SC9')+" 
        Qryped += " WHERE C9_FILIAL =  '"+xFilial("SC9")+"' "
        Qryped += " AND C9_PEDIDO = '"+cNumPed+"' "
        Qryped += " AND C9_REMITO    != ' ' "
	    Qryped += " AND C9_NFISCAL = ' '"
        Qryped += " AND D_E_L_E_T_  != '*'"
        TcQuery Qryped New Alias "_QRYPED"
        dbSelectArea("_QRYPED")
        While !_QRYPED->(EOF())
            lRet := .T.
            _cAQuery := " SELECT D1_DOC,D1_SERIE,D1_QUANT FROM  "+RetSQLName('SD1')+"  SD1 "
            _cAQuery += " WHERE D_E_L_E_T_ <> '*' "
            _cAQuery += " AND D1_FILIAL =  '"+xFilial("SD1")+"' "
            _cAQuery += " AND D1_NFORI =  '"+_QRYPED->(C9_REMITO)+"' "
            _cAQuery += " AND D1_SERIORI =  'R' "
            _cAQuery += " AND D1_FORNECE =  '"+_QRYPED->(C9_CLIENTE)+"' "
            _cAQuery += " AND D1_LOJA =  '"+_QRYPED->(C9_LOJA)+"' "
            _cAQuery += " AND D1_SERIE =  'RDV' "
            TcQuery _cAQuery New Alias "_aQRY"
            dbSelectArea("_aQRY")
            If _aQRY->(EOF())
                lRet := .F.  
            EndIf
            _aQRY->(dbCloseArea())

            IF !lRet
                Exit
            EndIf
            _QRYPED->(DbSkip())     
        EndDo
        ("_QRYPED")->(DBCloseArea())
    EndIf

    RestArea(aAreaSD1)
    RestArea(aAreaSC9)
    RestArea(aArea)
Return lRet 
