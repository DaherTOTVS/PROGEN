#INCLUDE "Acda100.ch" 
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACD100VG()
 Local aArea    := GetArea()
 Local aSvSC9	:= SC9->(GetArea())
 Local aSvSDC	:= SDC->(GetArea())
 Local nCont    := 0
 Local lVal     := .T.
 Local cQRYUPD  :=""
 Local cFinalQuery := ""
 Local cAlias1	  := ""
 Local _aQRY      := ""
 Local QryBF      := ""
 Local cFinalBF      := ""
 Local oStatement

    Upd := "UPDATE "+RetSqlName("SBF")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
	Upd += " AND BF_QUANT<=0 "
    n1Statud :=TCSqlExec(Upd)


    _cAQuer := " SELECT C9_PRODUTO,C9_LOCAL,C9_SEQUEN,C9_PEDIDO,C9_QTDLIB,C9_ITEM FROM  "+RetSQLName('SC9')+" SC9 "
    _cAQuer += " WHERE SC9.D_E_L_E_T_ <> '*' "
    _cAQuer += " AND SC9.C9_OK='"+SC9->C9_OK+"' "
    _cAQuer += " AND SC9.C9_OK != '' "

    TcQuery _cAQuer New Alias "_aQR"
    dbSelectArea("_aQR")
    While !_aQR->(EOF())

        oStatement := FWPreparedStatement():New()

        _cAQuery := " SELECT COUNT(*) AS DATO FROM  "+RetSQLName('SDC')+" SDC INNER JOIN "+RetSQLName('SB1')+" SB1 "
        _cAQuery += " ON B1_COD= ? AND B1_LOCALIZ='S' AND SB1.D_E_L_E_T_ <> '*'"
        _cAQuery += " WHERE SDC.D_E_L_E_T_ <> '*' "
        _cAQuery += " AND DC_PRODUTO= ? "
        _cAQuery += " AND DC_LOCAL= ? "
        _cAQuery += " AND DC_SEQ= ? "
        _cAQuery += " AND DC_ITEM= ? "
        _cAQuery += " AND DC_PEDIDO= ? "

        _cAQuery    := ChangeQuery(_cAQuery)
        oStatement:SetQuery(_cAQuery)
        oStatement:SetString(1,_aQR->C9_PRODUTO)
        oStatement:SetString(2,_aQR->C9_PRODUTO)
        oStatement:SetString(3,_aQR->C9_LOCAL)
        oStatement:SetString(4,_aQR->C9_SEQUEN)
        oStatement:SetString(5,_aQR->C9_ITEM)
        oStatement:SetString(6,_aQR->C9_PEDIDO)
        
        _cAQuery := oStatement:GetFixQuery()
        _aQRY := MpSysOpenQuery(_cAQuery)


        If (_aQRY)->(!Eof())
            If (_aQRY)->DATO != _aQR->C9_QTDLIB .AND. (_aQRY)->DATO > 0

                nCont := _aQR->C9_QTDLIB - (_aQRY)->DATO

                If nCont < 0
                    lVal := .F.
                    nCont :=  (_aQRY)->DATO - _aQR->C9_QTDLIB

                    cQRYUPD := " SELECT TOP ? SDC.R_E_C_N_O_ AS DATO, SDC.DC_NUMSERI FROM  "+RetSQLName('SDC')+" SDC INNER JOIN "+RetSQLName('SB1')+" SB1 "
                    cQRYUPD += " ON B1_COD= ? AND B1_LOCALIZ='S' AND SB1.D_E_L_E_T_ <> '*'"
                    cQRYUPD += " WHERE SDC.D_E_L_E_T_ <> '*' "
                    cQRYUPD += " AND DC_PRODUTO= ? "
                    cQRYUPD += " AND DC_LOCAL= ? "
                    cQRYUPD += " AND DC_SEQ = ? "
                    cQRYUPD += " AND DC_ITEM= ? "
                    cQRYUPD += " AND DC_PEDIDO= ? "
                    cQRYUPD += " ORDER BY 1 ASC "
                else

                    cQRYUPD := " SELECT TOP ? SDC.R_E_C_N_O_ AS DATO, SDC.DC_NUMSERI FROM  "+RetSQLName('SDC')+" SDC INNER JOIN "+RetSQLName('SB1')+" SB1 "
                    cQRYUPD += " ON B1_COD= ? AND B1_LOCALIZ='S' AND SB1.D_E_L_E_T_ <> '*'"
                    cQRYUPD += " WHERE SDC.D_E_L_E_T_ <> '*' "
                    cQRYUPD += " AND DC_PRODUTO= ? "
                    cQRYUPD += " AND DC_LOCAL= ? "
                    cQRYUPD += " AND DC_SEQ > ? "
                    cQRYUPD += " AND DC_ITEM= ? "
                    cQRYUPD += " AND DC_PEDIDO= ? "
                    cQRYUPD += " ORDER BY 1 ASC "    
                Endif 
                    oStatement := FWPreparedStatement():New()
                    aQRYUPD    := ChangeQuery(cQRYUPD)
                    oStatement:SetQuery(aQRYUPD)
                    oStatement:setNumeric(1, nCont)
                    oStatement:SetString(2, _aQR->C9_PRODUTO)
                    oStatement:SetString(3,_aQR->C9_PRODUTO)
                    oStatement:SetString(4,_aQR->C9_LOCAL)
                    oStatement:SetString(5,_aQR->C9_SEQUEN)
                    oStatement:SetString(6,_aQR->C9_ITEM)
                    oStatement:SetString(7,_aQR->C9_PEDIDO)
                
                    cFinalQuery := oStatement:GetFixQuery()
                    cAlias1 := MpSysOpenQuery(cFinalQuery)

                    While (cAlias1)->(!Eof())
                        If lVal
                            Upd ="UPDATE "+RetSQLName('SDC')+" SET DC_SEQ='"+_aQR->C9_SEQUEN+"',DC_TRT='"+_aQR->C9_SEQUEN+"'   WHERE D_E_L_E_T_ ='' AND R_E_C_N_O_ ='"+cValToChar((cAlias1)->DATO)+"'"
                            n1Statud :=TCSqlExec(Upd)
                        Else
                            Upd ="UPDATE "+RetSQLName('SDC')+" SET D_E_L_E_T_='*'  WHERE D_E_L_E_T_ ='' AND R_E_C_N_O_ ='"+cValToChar((cAlias1)->DATO)+"'"
                            n1Statud :=TCSqlExec(Upd)

                            Upd := "UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=0 WHERE D_E_L_E_T_ <> '*' "
                            Upd += " AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("SDC")+" WHERE D_E_L_E_T_ <>'*' AND DC_PRODUTO=BF_PRODUTO AND BF_LOCAL=DC_LOCAL AND BF_NUMSERI=DC_NUMSERI) "
                            n1Statud :=TCSqlExec(Upd)

                            Upd := "UPDATE "+RetSqlName("SBF")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		                    Upd += " AND BF_QUANT<=0 "
                            n1Statud :=TCSqlExec(Upd)
                        EndIf
                        (cAlias1)->(dbSkip())
                    EndDo
                    (cAlias1)->(dbCloseArea())

                    _aQRY := MpSysOpenQuery(_cAQuery)
                    If (_aQRY)->(!Eof()) .AND.(_aQRY)->DATO < _aQR->C9_QTDLIB .AND. (_aQRY)->DATO > 0


                        nCont := _aQR->C9_QTDLIB - (_aQRY)->DATO

                        QryBF := " SELECT TOP ? BF_NUMSERI,BF_PRODUTO,BF_LOCAL,BF_QUANT,BF_QTSEGUM,BF_LOTECTL,BF_NUMLOTE,BF_LOCALIZ FROM  "+RetSQLName('SBF')+" SBF 
                        QryBF += " WHERE SBF.D_E_L_E_T_ <> '*' "
                        QryBF += " AND BF_PRODUTO = ? "
                        QryBF += " AND BF_LOCAL= ? "
                        QryBF += " AND BF_QUANT > 0 "
                        QryBF += " AND BF_EMPENHO = 0 "
                        oStatement := FWPreparedStatement():New()
                        QryBF    := ChangeQuery(QryBF)
                        oStatement:SetQuery(QryBF)
                        oStatement:setNumeric(1, nCont)
                        oStatement:SetString(2,_aQR->C9_PRODUTO)
                        oStatement:SetString(3,_aQR->C9_LOCAL)
                        
                        QryBF := oStatement:GetFixQuery()
                        cFinalBF := MpSysOpenQuery(QryBF)

                        While (cFinalBF)->(!Eof())

                            (cFinalBF)->( GravaEmp( BF_PRODUTO,;  //-- 01.Codigo do Produto
									BF_LOCAL,;    	//-- 02.Local
									BF_QUANT,;   	//-- 03.Quantidade
									BF_QTSEGUM,;  //-- 04.Quantidade
									BF_LOTECTL,;  //-- 05.Lote
									BF_NUMLOTE,;  //-- 06.SubLote
									BF_LOCALIZ,;  //-- 07.Localiza‡Æo
									BF_NUMSERI,; //-- 08.Numero de S‚rie
									Nil,;         	//-- 09.OP
									_aQR->C9_SEQUEN,;        	//-- 10.Seq. do Empenho/Libera‡Æo do PV (Pedido de Venda)
									_aQR->C9_PEDIDO,;  	//-- 11.PV
									_aQR->C9_ITEM,;     	//-- 12.Item do PV
									'SC6',;       	//-- 13.Origem do Empenho
									Nil,;        	//-- 14.OP Original
									Nil,;			//-- 15.Data da Entrega do Empenho
									NIL,;			//-- 16.Array para Travamento de arquivos
									.F.,;     	   	//-- 17.Estorna Empenho?
									.F.,;         	//-- 18.? chamada da Proje‡Æo de Estoques?
									.T.,;         	//-- 19.Empenha no SB2?
									.F.,;         	//-- 20.Grava SD4?
									.T.,;         	//-- 21.Considera Lotes Vencidos?
									.T.,;         //-- 22.Empenha no SB8/SBF?
									.T.) )         //-- 23.Cria SDC?
                       

                            (cFinalBF)->(dbSkip())
                        EndDo
                        (cFinalBF)->(dbCloseArea())

                    Endif
                _aQR->(dbSkip())
                (_aQRY)->(dbCloseArea())
                loop      
            Endif

        EndIf
        (_aQRY)->(dbCloseArea())
        _aQR->(dbSkip())

    EndDo
    _aQR->(dbCloseArea())


    RestArea(aSvSC9)
    RestArea(aSvSDC)    
    RestArea(aArea)
Return .T.
