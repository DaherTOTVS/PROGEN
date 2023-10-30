#Include "Protheus.ch"
#Include "TopConn.ch"



User Function USQLSBF()

	Local UserActua:=RetCodUsr()
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := "Nombre_hhhhhhhhh                              "
	Local oGroup1
	Local oMultiGe1
	Local cMultiGe1 := "0                         "
	Local oMultiGe2
	Local cMultiGe2 := "       "
	Local oMultiGe3
	Local cMultiGe3 := "       "
	Local oMultiGe4
	Local cMultiGe4 := "       "
	Local oMultiGe5
	Local cMultiGe5 := "N"
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Static oDlg


	if UserActua<>"000027" .AND. UserActua<>"000036" //TOTVSADM //TIC02 FENEY
		Return
	EndIF


	DEFINE MSDIALOG oDlg TITLE "Rehacer Historico de Seriales - Orden de Separación" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL
	@ 009, 007 GROUP oGroup1 TO 239, 290 PROMPT "Historico de Seriales" OF oDlg COLOR 0, 16777215 PIXEL
	@ 022, 013 SAY oSay1 PROMPT "Indique por favor los parametros para realizar la busqueda" SIZE 211, 009 OF oDlg COLORS 0, 16777215 PIXEL

	@ 217, 021 BUTTON oButton1 PROMPT "Generar" SIZE 048, 014 action processa({|| fProcessa(cMultiGe1,cMultiGe2,cMultiGe3,cMultiGe4, cGet1,cMultiGe5) }, "Processando...") OF oDlg PIXEL
	@ 215, 230 BUTTON oButton2 PROMPT "Salir" SIZE 044, 016 ACTION   oDlg:End() OF oDlg PIXEL

	@ 037, 017 SAY oSay5 PROMPT "Titulo de la Consulta:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 071 MSGET oGet1 VAR cGet1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL


	@ 061, 017 SAY oSay1 PROMPT "Producto:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 061, 071 MSGET oMultiGe1 VAR cMultiGe1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 075, 017 SAY oSay2 PROMPT "Orden de Separación:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 071 MSGET oMultiGe2 VAR cMultiGe2 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 089, 017 SAY oSay3 PROMPT "Pedido:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 089, 071 MSGET oMultiGe3 VAR cMultiGe3 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 0103, 017 SAY oSay4 PROMPT "# Serie:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 0103, 071 MSGET oMultiGe4 VAR cMultiGe4 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 0122, 017 SAY oSay6 PROMPT "ACTUALIZA S/N:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 0122, 071 MSGET oMultiGe5 VAR cMultiGe5 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL


	ACTIVATE MSDIALOG oDlg CENTERED
Return




Return




Static Function fProcessa(cProd,cOrdesep,Cpedido,cNumseri, cTitAux,Actualiza)
	Local aArea       := GetArea()
	Local aAreaX3     := SX3->(GetArea())
	Local nAux        := 0
	Local oFWMsExcel
	Local oExcel
	Local cDiretorio  := GetTempPath()
	// Local cArquivo    := 'zQry2Excel.xml'
	Local dData := DTOC(DATE())
	Local dtime := Time()
	Local cArquivo    := alltrim(cTitAux) +"_"+ dData +"_"+ dtime+".xml"
	cArquivo := replace(cArquivo,"/","")
	cArquivo := replace(cArquivo,":","")
	Local cArqFull    := cDiretorio + cArquivo
	Local cWorkSheet  := "SBF ANTES"
	Local cTable      := ""
	Local aColunas    := {}
	Local aEstrut     := {}
	Local aLinhaAux   := {}
	Local cTitulo     := ""
	Local nTotal      := 0
	Local nAtual      := 0
	Local Upd :=""
	Default cQryAux   := ""
	Default cTitAux   := "Tutulo de la consulta"

	cTable := cTitAux

	cQryAuxSDC:=" SELECT  * FROM "+RetSqlName("SDC")+" WHERE D_E_L_E_T_ <> '*' AND  NOT EXISTS (SELECT 1 FROM "+RetSqlName("SBF")+" WHERE D_E_L_E_T_ <> '*' AND DC_NUMSERI = BF_NUMSERI  AND DC_LOCAL=BF_LOCAL)"
	if (Len(AllTrim(cProd))>0)
		cQryAuxSDC += " AND DC_PRODUTO='" + AllTrim(cProd)+"'"
	endif
	if (Len(AllTrim(cNumseri))>0)
		cQryAuxSDC += " AND DC_NUMSERI='" + AllTrim(cNumseri) +"'"
	endif

	cQryAux := " SELECT * FROM "+RetSqlName("SBF")+" WHERE D_E_L_E_T_ <> '*' "

	if (Len(AllTrim(cProd))>0)
		cQryAux += " AND BF_PRODUTO='" + AllTrim(cProd) +"'"
	endif
	if (Len(AllTrim(cOrdesep))>0)
		cQryAux += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
	endif
	if (Len(AllTrim(Cpedido))>0)
		cQryAux += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
	endif
	if (Len(AllTrim(cNumseri))>0)
		cQryAux += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
	endif




	cWorkSheet  := "SBF ANTES"
	n1Statu :=TCSqlExec(cQryAux)
	if (n1Statu < 0)
		MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
	Else

		//Se tiver a consulta
		If !Empty(cQryAux)
			TCQuery cQryAux New Alias "QRY_AUX"
			DbSelectArea('SX3')
			SX3->(DbSetOrder(2)) //X3_CAMPO
			//Percorrendo a estrutura
			aEstrut := QRY_AUX->(DbStruct())
			ProcRegua(Len(aEstrut))
			For nAux := 1 To Len(aEstrut)
				IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
				cTitulo := ""
				If SX3->(DbSeek(aEstrut[nAux][1]))
					cTitulo := Alltrim(SX3->X3_TITULO)
					If SX3->X3_TIPO == 'D'
						TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
					EndIf
				Else
					cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
				EndIf

				aAdd(aColunas, cTitulo)
			Next
			oFWMsExcel := FWMSExcel():New()
			oFWMsExcel:AddworkSheet(cWorkSheet)
			oFWMsExcel:AddTable(cWorkSheet, cTable)
			For nAux := 1 To Len(aColunas)
				oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
			Next
			DbSelectArea("QRY_AUX")
			QRY_AUX->(DbGoTop())
			Count To nTotal
			ProcRegua(nTotal)
			nAtual := 0
			QRY_AUX->(DbGoTop())
			While !QRY_AUX->(EoF())
				nAtual++
				IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

				aLinhaAux := Array(Len(aColunas))
				For nAux := 1 To Len(aEstrut)
					aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
				Next
				oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
				QRY_AUX->(DbSkip())
			EndDo


			QRY_AUX->(DbCloseArea())



		EndIf
	EndIf


	aColunas    := {}
	aEstrut     := {}
	aLinhaAux   := {}
	cTitulo     := ""
	nTotal      := 0
	nAtual      := 0


	cWorkSheet  := "SDC ANTES"
	n1Statu :=TCSqlExec(cQryAuxSDC)
	if (n1Statu < 0)
		MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
	Else

		//Se tiver a consulta
		If !Empty(cQryAuxSDC)
			TCQuery cQryAuxSDC New Alias "QRY_AUX"
			DbSelectArea('SX3')
			SX3->(DbSetOrder(2)) //X3_CAMPO
			//Percorrendo a estrutura
			aEstrut := QRY_AUX->(DbStruct())
			ProcRegua(Len(aEstrut))
			For nAux := 1 To Len(aEstrut)
				IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
				cTitulo := ""
				If SX3->(DbSeek(aEstrut[nAux][1]))
					cTitulo := Alltrim(SX3->X3_TITULO)
					If SX3->X3_TIPO == 'D'
						TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
					EndIf
				Else
					cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
				EndIf

				aAdd(aColunas, cTitulo)
			Next
			oFWMsExcel:AddworkSheet(cWorkSheet)
			oFWMsExcel:AddTable(cWorkSheet, cTable)
			For nAux := 1 To Len(aColunas)
				oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
			Next
			DbSelectArea("QRY_AUX")
			QRY_AUX->(DbGoTop())
			Count To nTotal
			ProcRegua(nTotal)
			nAtual := 0
			QRY_AUX->(DbGoTop())
			While !QRY_AUX->(EoF())
				nAtual++
				IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

				aLinhaAux := Array(Len(aColunas))
				For nAux := 1 To Len(aEstrut)
					aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
				Next
				oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
				QRY_AUX->(DbSkip())
			EndDo


			QRY_AUX->(DbCloseArea())



		EndIf
	EndIf


	cQryAuxSBF:=" SELECT * FROM "+RetSqlName("SBF")+" WHERE D_E_L_E_T_ <> '*' "
	cQryAuxSBF +=" AND BF_QUANT<0 "

	if (Len(AllTrim(cProd))>0)
		cQryAuxSBF += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
	endif

	cWorkSheet  := "SBF NEGATIVOS ELIMINADOS"
	n1Statu :=TCSqlExec(cQryAuxSBF)
	if (n1Statu < 0)
		MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
	Else

		//Se tiver a consulta
		If !Empty(cQryAuxSBF)
			TCQuery cQryAuxSBF New Alias "QRY_AUX"
			DbSelectArea('SX3')
			SX3->(DbSetOrder(2)) //X3_CAMPO
			//Percorrendo a estrutura
			aEstrut := QRY_AUX->(DbStruct())
			ProcRegua(Len(aEstrut))
			For nAux := 1 To Len(aEstrut)
				IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
				cTitulo := ""
				If SX3->(DbSeek(aEstrut[nAux][1]))
					cTitulo := Alltrim(SX3->X3_TITULO)
					If SX3->X3_TIPO == 'D'
						TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
					EndIf
				Else
					cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
				EndIf

				aAdd(aColunas, cTitulo)
			Next
			oFWMsExcel:AddworkSheet(cWorkSheet)
			oFWMsExcel:AddTable(cWorkSheet, cTable)
			For nAux := 1 To Len(aColunas)
				oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
			Next
			DbSelectArea("QRY_AUX")
			QRY_AUX->(DbGoTop())
			Count To nTotal
			ProcRegua(nTotal)
			nAtual := 0
			QRY_AUX->(DbGoTop())
			While !QRY_AUX->(EoF())
				nAtual++
				IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

				aLinhaAux := Array(Len(aColunas))
				For nAux := 1 To Len(aEstrut)
					aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
				Next
				oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
				QRY_AUX->(DbSkip())
			EndDo


			QRY_AUX->(DbCloseArea())



		EndIf
	EndIf


	// Upd := " UPDATE SDC010 SET  D_E_L_E_T_='*'  WHERE D_E_L_E_T_ <> '*' AND DC_PRODUTO='TR01M_CO-004' AND DC_PEDIDO='002783' "
	// n1Statud :=TCSqlExec(Upd)


	Upd := " UPDATE SBF010 SET BF_EMPENHO='1' WHERE D_E_L_E_T_ <>'*'  AND BF_NUMSERI IN (SELECT CB9_NUMSER FROM CB9010 WHERE D_E_L_E_T_ <>'*' AND CB9_PROD=BF_PRODUTO AND CB9_LOCAL=BF_LOCAL  AND CB9_ORDSEP IN (SELECT CB7_ORDSEP FROM CB7010 WHERE D_E_L_E_T_ <>'*' )) AND BF_EMPENHO='0' "
	n1Statud :=TCSqlExec(Upd)

	Upd := " UPDATE SBF020 SET BF_EMPENHO='1' WHERE D_E_L_E_T_ <>'*'  AND BF_NUMSERI IN (SELECT CB9_NUMSER FROM CB9020 WHERE D_E_L_E_T_ <>'*' AND CB9_PROD=BF_PRODUTO AND CB9_LOCAL=BF_LOCAL  AND CB9_ORDSEP IN (SELECT CB7_ORDSEP FROM CB7020 WHERE D_E_L_E_T_ <>'*' )) AND BF_EMPENHO='0' "
	n1Statud :=TCSqlExec(Upd)




// Upd := " DROP TABLE IF EXISTS TTSC6 "
// n1Statud :=TCSqlExec(Upd)

// Upd := "  SELECT DISTINCT ROW_NUMBER() OVER( ORDER BY D2_PEDIDO )N_ITEMS,C6_ITEM,D2_COD,D2_PEDIDO,C6_QTDVEN,C6_QTDENT,SUM(D2_QUANT)D2_QUANT "
// Upd += "  INTO TTSC6 FROM SD2010 D2 "
// Upd += "  INNER JOIN SC6010 C6 "
// Upd += "  ON D2_PEDIDO=C6_NUM AND C6_ITEM=D2_ITEMPV AND C6_PRODUTO=D2_COD AND D2_LOCAL=C6_LOCAL AND C6.D_E_L_E_T_ <>'*' AND D2.D_E_L_E_T_ <>'*' "
// Upd += "  WHERE D2_SERIE='R' GROUP BY  C6_ITEM,D2_COD,D2_PEDIDO,C6_QTDVEN,C6_QTDENT HAVING SUM(D2_QUANT) <> C6_QTDENT and SUM(D2_QUANT)=C6_QTDVEN ORDER BY 4  DESC "
// n1Statud :=TCSqlExec(Upd)


// Upd := " UPDATE SC6010 SET C6_QTDENT=SC6010.C6_QTDVEN FROM TTSC6 TT WHERE SC6010.C6_NUM = TT.D2_PEDIDO AND SC6010.C6_ITEM=TT.C6_ITEM AND SC6010.C6_PRODUTO=TT.D2_COD "
// n1Statud :=TCSqlExec(Upd)


// Upd := " UPDATE SBF010 SET D_E_L_E_T_ = '*' WHERE BF_NUMSERI IN (SELECT BF_NUMSERI FROM SBF010 WHERE BF_PRODUTO='TR01M_US-005' AND BF_QUANT <0 AND D_E_L_E_T_ <>'*') AND D_E_L_E_T_ <>'*'
//  "
// n1Statud :=TCSqlExec(Upd)



 Upd := " UPDATE SDC010 SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM SDC010 WHERE D_E_L_E_T_ <>'*' AND DC_SEQ NOT IN ( "
 Upd +=" SELECT C9_SEQUEN FROM SC9010 WHERE D_E_L_E_T_ <>'*' AND C9_PEDIDO=DC_PEDIDO "
 Upd +=" AND DC_PRODUTO=C9_PRODUTO "
 Upd +=" AND C9_ITEM =DC_ITEM "
 Upd +=" AND C9_NFISCAL='' "
 Upd +=" )ORDER BY DC_PEDIDO DESC) AND D_E_L_E_T_ <>'*' "
 n1Statud :=TCSqlExec(Upd)




















	

	if (UPPER(Actualiza)=='S')
		// PONE RESERVADOS TODOS LOS SERIALES QUE ESTAN EN UNA ORDEN DE SEPARACIÓN PERO APARECEN DISPONIBLES
		Upd := " UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=1 WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND EXISTS (SELECT 1 FROM "+RetSqlName("CB8")+" WHERE  D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PROD=BF_PRODUTO ) "
		Upd += " AND BF_EMPENHO=0 "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND BF_PRODUTO='" + AllTrim(cProd) +"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upd += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND CB8_PROD=BF_PRODUTO AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upd += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND CB8_PROD=BF_PRODUTO AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif



		n1Statud :=TCSqlExec(Upd)


		// Upd := " UPDATE DBC020 SET DBC_XVILOT='28/05/2000'  WHERE D_E_L_E_T_ <> '*' "
		// n1Statud :=TCSqlExec(Upd)


		// PONE DISPONIBLE TODOS LOS SERIALES QUE NO ESTAN EN UNA ORDEN DE SEPARACIÓN PERO APARECEN RESERVADOS
		Upd := "UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=0 WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("CB8")+" WHERE  D_E_L_E_T_ <> '*' AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PROD=BF_PRODUTO) "

		Upd += " AND BF_EMPENHO=1 "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND BF_PRODUTO='" + AllTrim(cProd) +"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upd += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_PROD=BF_PRODUTO AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upd += " AND EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_PROD=BF_PRODUTO AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif

		n1Statud :=TCSqlExec(Upd)



		// PONE RESERVADOS TODOS LOS SERIALES QUE ESTAN LEIDOS POR ACD DIFERENTES A LOS ASIGANADOS EN LA ORDEN DE SEPARACIÓN
		Upd := "UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=1 WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND EXISTS (SELECT 1 FROM "+RetSqlName("CB9")+" WHERE  D_E_L_E_T_ <> '*' AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_PROD=BF_PRODUTO AND CB9_ORDSEP IN (SELECT CB7_ORDSEP FROM "+RetSqlName("CB7")+" WHERE  D_E_L_E_T_ <> '*' AND CB7_ORDSEP=CB9_ORDSEP)) "
		Upd += " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("CB8")+" WHERE  D_E_L_E_T_ <> '*'  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PROD=BF_PRODUTO) "
		Upd += " AND BF_EMPENHO=0 "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upd += " AND (  EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*' AND CB8_PROD=BF_PRODUTO AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
			Upd += " OR  EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*'  AND CB9_PROD=BF_PRODUTO AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_ORDSEP='" + AllTrim(cOrdesep) +"') )"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upd += " AND ( EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
			Upd += " OR EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*'  AND CB9_PROD=BF_PRODUTO  AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_PEDIDO='" + AllTrim(Cpedido) +"') )"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upd)


		



		// ELIMINA SERIALES DE LA TABLA SDC CUANDO NO EXISTA HISOTRICO REAL DEL SERIAL (NO CONCUERDA CON EL PEDIDO, NI EXISTE EN LA SBF)
		Upd := "UPDATE "+RetSqlName("SDC")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND NOT EXISTS (SELECT 1  FROM "+RetSqlName("SBF")+" WHERE D_E_L_E_T_ <> '*' AND DC_NUMSERI = BF_NUMSERI  AND DC_LOCAL=BF_LOCAL  AND DC_PRODUTO=BF_PRODUTO ) "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND DC_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND DC_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upd)


		// PONE RESERVADOS TODOS LOS SERIALES QUE ASIGANADOS POR UN PEDIDO
		Upd := "UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=1 WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND EXISTS (SELECT 1 FROM "+RetSqlName("SDC")+" WHERE  D_E_L_E_T_ <> '*' AND DC_NUMSERI=BF_NUMSERI AND BF_LOCAL=DC_LOCAL  AND DC_PRODUTO=BF_PRODUTO ) "
		Upd += " AND BF_EMPENHO=0 "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upd += " AND (  EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
			Upd += " OR  EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*'  AND CB9_PROD=BF_PRODUTO AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_ORDSEP='" + AllTrim(cOrdesep) +"') )"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upd += " AND ( EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
			Upd += " OR EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*' AND CB9_PROD=BF_PRODUTO  AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_PEDIDO='" + AllTrim(Cpedido) +"') )"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upd)



		Upds := "UPDATE "+RetSqlName("SBF")+" SET BF_EMPENHO=0 WHERE D_E_L_E_T_ <> '*' "
		Upds += " AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("SDC")+" WHERE D_E_L_E_T_ <>'*' AND DC_PRODUTO=BF_PRODUTO AND BF_LOCAL=DC_LOCAL AND BF_NUMSERI=DC_NUMSERI) "
		Upds += " AND BF_EMPENHO=1 "
		Upds += " AND ((SELECT  TOP 1 DB_ORIGEM FROM "+RetSqlName("SDB")+" WHERE D_E_L_E_T_ <>'*' AND BF_PRODUTO=DB_PRODUTO AND DB_LOCAL=BF_LOCAL AND BF_NUMSERI=DB_NUMSERI ORDER BY DB_DATA DESC)='SD3' "
		Upds += " OR ((SELECT  TOP 1 DB_ORIGEM FROM "+RetSqlName("SDB")+" WHERE D_E_L_E_T_ <>'*' AND BF_PRODUTO=DB_PRODUTO AND DB_LOCAL=BF_LOCAL AND BF_NUMSERI=DB_NUMSERI ORDER BY DB_DATA DESC)='SD1' "
		Upds += " AND (SELECT  TOP 1 DB_SERIE FROM "+RetSqlName("SDB")+" WHERE D_E_L_E_T_ <>'*' AND BF_PRODUTO=DB_PRODUTO AND DB_LOCAL=BF_LOCAL AND BF_NUMSERI=DB_NUMSERI ORDER BY DB_DATA DESC)='NCC' "

		Upds += " ))"
		if (Len(AllTrim(cProd))>0)
			Upds += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upds += " AND (  EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
			Upds += " OR  EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*'  AND CB9_PROD=BF_PRODUTO AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_ORDSEP='" + AllTrim(cOrdesep) +"') )"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upds += " AND ( EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
			Upds += " OR EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*' AND CB9_PROD=BF_PRODUTO  AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_PEDIDO='" + AllTrim(Cpedido) +"') )"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upds += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upds)





		Upd := "UPDATE "+RetSqlName("SBF")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND BF_QUANT<0 "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		n1Statud :=TCSqlExec(Upd)


		Upds := "UPDATE "+RetSqlName("SBF")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		Upds += " AND ((SELECT  TOP 1 DB_ORIGEM FROM "+RetSqlName("SDB")+" WHERE D_E_L_E_T_ <>'*' AND BF_PRODUTO=DB_PRODUTO AND DB_LOCAL=BF_LOCAL AND BF_NUMSERI=DB_NUMSERI ORDER BY DB_DATA DESC)='SC6' "
		Upds += " AND (SELECT  TOP 1 DB_SERIE FROM "+RetSqlName("SDB")+" WHERE D_E_L_E_T_ <>'*' AND BF_PRODUTO=DB_PRODUTO AND DB_LOCAL=BF_LOCAL AND BF_NUMSERI=DB_NUMSERI ORDER BY DB_DATA DESC)='R' "

		Upds += " )"
		if (Len(AllTrim(cProd))>0)
			Upds += " AND BF_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cOrdesep))>0)
			Upds += " AND (  EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_ORDSEP='" + AllTrim(cOrdesep) +"')"
			Upds += " OR  EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*'  AND CB9_PROD=BF_PRODUTO AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_ORDSEP='" + AllTrim(cOrdesep) +"') )"
		endif
		if (Len(AllTrim(Cpedido))>0)
			Upds += " AND ( EXISTS ( SELECT 1 FROM "+RetSqlName("CB8")+" WHERE D_E_L_E_T_ <> '*'  AND CB8_PROD=BF_PRODUTO  AND CB8_NUMSER=BF_NUMSERI AND BF_LOCAL=CB8_LOCAL AND CB8_PEDIDO='" + AllTrim(Cpedido) +"')"
			Upds += " OR EXISTS ( SELECT 1 FROM "+RetSqlName("CB9")+" WHERE D_E_L_E_T_ <> '*' AND CB9_PROD=BF_PRODUTO  AND CB9_NUMSER=BF_NUMSERI AND BF_LOCAL=CB9_LOCAL AND CB9_PEDIDO='" + AllTrim(Cpedido) +"') )"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upds += " AND BF_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upds)


		Upd := "UPDATE "+RetSqlName("SDC")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		Upd += " AND NOT EXISTS (SELECT 1  FROM "+RetSqlName("SBF")+" WHERE D_E_L_E_T_ <> '*' AND DC_NUMSERI = BF_NUMSERI  AND DC_LOCAL=BF_LOCAL  AND DC_PRODUTO=BF_PRODUTO ) "
		if (Len(AllTrim(cProd))>0)
			Upd += " AND DC_PRODUTO='" + AllTrim(cProd)+"'"
		endif
		if (Len(AllTrim(cNumseri))>0)
			Upd += " AND DC_NUMSERI='" + AllTrim(cNumseri) +"'"
		endif
		n1Statud :=TCSqlExec(Upd)





		Upds := "UPDATE "+RetSqlName("CB9")+" SET D_E_L_E_T_='*' WHERE D_E_L_E_T_ <> '*' "
		Upds += " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("CB7")+" WHERE D_E_L_E_T_ <>'*' AND CB9_ORDSEP=CB7_ORDSEP) "
		
		n1Statud :=TCSqlExec(Upds)


		// Upd := " UPDATE "+RetSqlName("SB2")+" "
		// Upd += " SET B2_RESERVA=(SELECT COUNT(*) "
		// Upd += " FROM  "+RetSqlName("SBF")+" BF1 "
		// Upd += " WHERE B2_COD=BF1.BF_PRODUTO "
		// Upd += " AND B2_LOCAL=BF1.BF_LOCAL "
		// Upd += " AND BF1.D_E_L_E_T_ <>'*' "
		// Upd += " AND BF_EMPENHO=1 )"
		// Upd += " WHERE "
		// Upd += " D_E_L_E_T_ <>'*' "
		// if (Len(AllTrim(cProd))>0)
		// 	Upd += " AND B2_COD='" + AllTrim(cProd)+"'"
		// endif
		// n1Statud :=TCSqlExec(Upd)


		// Upd := " UPDATE "+RetSqlName("SB2")+" "
		// Upd += " SET B2_QATU=B2_QACLASS+(SELECT COUNT(*) "
		// Upd += " FROM  "+RetSqlName("SBF")+" BF1 "
		// Upd += " WHERE B2_COD=BF1.BF_PRODUTO "
		// Upd += " AND B2_LOCAL=BF1.BF_LOCAL "
		// Upd += " AND BF1.D_E_L_E_T_ <>'*' )"
		// Upd += " WHERE "
		// Upd += " D_E_L_E_T_ <>'*' "
		// if (Len(AllTrim(cProd))>0)
		// 	Upd += " AND B2_COD='" + AllTrim(cProd)+"'"
		// endif
		// n1Statud :=TCSqlExec(Upd)












		aColunas    := {}
		aEstrut     := {}
		aLinhaAux   := {}
		cTitulo     := ""
		nTotal      := 0
		nAtual      := 0


		cWorkSheet  := "SBF DESPUES"
		n1Statu :=TCSqlExec(cQryAux)
		if (n1Statu < 0)
			MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
		Else

			//Se tiver a consulta
			If !Empty(cQryAux)
				TCQuery cQryAux New Alias "QRY_AUX"
				DbSelectArea('SX3')
				SX3->(DbSetOrder(2)) //X3_CAMPO
				//Percorrendo a estrutura
				aEstrut := QRY_AUX->(DbStruct())
				ProcRegua(Len(aEstrut))
				For nAux := 1 To Len(aEstrut)
					IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
					cTitulo := ""
					If SX3->(DbSeek(aEstrut[nAux][1]))
						cTitulo := Alltrim(SX3->X3_TITULO)
						If SX3->X3_TIPO == 'D'
							TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
						EndIf
					Else
						cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
					EndIf

					aAdd(aColunas, cTitulo)
				Next
				oFWMsExcel:AddworkSheet(cWorkSheet)
				oFWMsExcel:AddTable(cWorkSheet, cTable)
				For nAux := 1 To Len(aColunas)
					oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
				Next
				DbSelectArea("QRY_AUX")
				QRY_AUX->(DbGoTop())
				Count To nTotal
				ProcRegua(nTotal)
				nAtual := 0
				QRY_AUX->(DbGoTop())
				While !QRY_AUX->(EoF())
					nAtual++
					IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

					aLinhaAux := Array(Len(aColunas))
					For nAux := 1 To Len(aEstrut)
						aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
					Next
					oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
					QRY_AUX->(DbSkip())
				EndDo


				QRY_AUX->(DbCloseArea())

			EndIf
		EndIf



		aColunas    := {}
		aEstrut     := {}
		aLinhaAux   := {}
		cTitulo     := ""
		nTotal      := 0
		nAtual      := 0


		cWorkSheet  := "SDC DESPUES"
		n1Statu :=TCSqlExec(cQryAuxSDC)
		if (n1Statu < 0)
			MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
		Else

			//Se tiver a consulta
			If !Empty(cQryAuxSDC)
				TCQuery cQryAuxSDC New Alias "QRY_AUX"
				DbSelectArea('SX3')
				SX3->(DbSetOrder(2)) //X3_CAMPO
				//Percorrendo a estrutura
				aEstrut := QRY_AUX->(DbStruct())
				ProcRegua(Len(aEstrut))
				For nAux := 1 To Len(aEstrut)
					IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
					cTitulo := ""
					If SX3->(DbSeek(aEstrut[nAux][1]))
						cTitulo := Alltrim(SX3->X3_TITULO)
						If SX3->X3_TIPO == 'D'
							TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
						EndIf
					Else
						cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
					EndIf

					aAdd(aColunas, cTitulo)
				Next
				oFWMsExcel:AddworkSheet(cWorkSheet)
				oFWMsExcel:AddTable(cWorkSheet, cTable)
				For nAux := 1 To Len(aColunas)
					oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
				Next
				DbSelectArea("QRY_AUX")
				QRY_AUX->(DbGoTop())
				Count To nTotal
				ProcRegua(nTotal)
				nAtual := 0
				QRY_AUX->(DbGoTop())
				While !QRY_AUX->(EoF())
					nAtual++
					IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

					aLinhaAux := Array(Len(aColunas))
					For nAux := 1 To Len(aEstrut)
						aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
					Next
					oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
					QRY_AUX->(DbSkip())
				EndDo


				QRY_AUX->(DbCloseArea())

			EndIf
		EndIf
	ENDIF
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArqFull)
	If ApOleClient("msexcel")
		oExcel := MsExcel():New()
		oExcel:WorkBooks:Open(cArqFull)
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	Else
		If ExistDir("C:\Program Files (x86)\LibreOffice 5")
			WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 1)

			//Senão, abre o XML pelo programa padrão
		Else
			ShellExecute("open", cArquivo, "", cDiretorio, 1)
		EndIf
	EndIf

	RestArea(aAreaX3)
	RestArea(aArea)
Return



