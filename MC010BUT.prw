#Include "Totvs.Ch"
#INCLUDE "MATC010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBrowse.ch"

User Function MC010BUT()

Local oDlg        := ParamIxb[1]  // Obj da planilha
LOCAL oBtnA, oBtnD, oBtnE, oBtnF, oBtnG
Local aPosObj     := ParamIxb[2]  // Obj das posicoes p/ os botões na tela
Local aProd       := ParamIxb[3]  // Estrutura utilizada p/ a Planilha
Local aFormulas   := ParamIxb[4]  // Array das Formulas da Planilha
Local aTot        := ParamIxb[5]  // Array dos Totais da Planilh
Local lRet        := .F.          // Define se desabilita o botão 'PLANILHA'

DEFINE SBUTTON  FROM aPosObj[1,4] +80,aPosObj[1,3]-39 TYPE 3  ENABLE OF oDlg Action PlanRev(oBtnD,oBtnE,oBtnF)//-- No ex.acima, o botão IMPRIME ('TYPE 6') foi criado p/ a Impressão da planilha, utilizando função de usuário customizada U_IMPRIME(), por exemplo.//-- Obs.: OUTRO USO PARA O PONTO DE ENTRADA://--       Ao retornar .T. o botão 'PLANILHA' será DESABILITADO.



// DEFINE SBUTTON 	FROM aPosObj[1,4]-20,aPosObj[1,3]-33 TYPE 13 ENABLE OF oDlg Action (MC010GRVEX(.T.),GeraRev(nMatPrima,aFormulas,oDlg))

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PlanRev  ³ Autor ³ Turibio Miranda       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Le planilhas e revisoes gravadas na tabela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlanRev(oBtnD,oBtnE,oBtnF)
LOCAL aPlanilhas,nX,oPlan, oDlg, oBtnA
LOCAL aArea:= GetArea()
LOCAL cQuery:=cAliasTRB:=""
LOCAL lRet:=.F.
Local lTop:=.F.

	cAliasTRB := GetNextAlias()
	cQuery:="SELECT Distinct CO_CODIGO, CO_REVISAO, CO_NOME, CO_DATA, R_E_C_N_O_ RECNO FROM "+RetSqlName("SCO")+" "+(cAliasTRB)+" "
	cQuery+="WHERE CO_FILIAL='"+xFilial("SCO")+"'  AND D_E_L_E_T_=' ' "
	cQuery+= "ORDER BY CO_CODIGO DESC, CO_REVISAO DESC, CO_DATA DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasTRB),.F.,.T.)
	ltop:=.T.


If (cAliasTRB)->(!Eof())
	aPlanilhas := {}
	While (cAliasTRB)->(!Eof())
		AADD(aPlanilhas,{(cAliasTRB)->CO_CODIGO,(cAliasTRB)->CO_REVISAO,(cAliasTRB)->CO_NOME,iif(lTop,(cAliasTRB)->CO_DATA ,DTOC((cAliasTRB)->CO_DATA)),})
		(cAliasTRB)->(DbSkip())
	EndDo

	DEFINE MSDIALOG oDlg FROM 15,6 TO 240,500 TITLE STR0023 PIXEL	//"Selecione Planilha"
		@ 11,12 LISTBOX oPlan FIELDS HEADER  '',STR0046,STR0047,STR0048,STR0049  SIZE 231, 75 OF oDlg PIXEL; // Código/ Revisão / Nome , Data
			  ON CHANGE (nX := oPlan:nAt) ON DBLCLICK (Eval(oBtnA:bAction))
		oPlan:SetArray(aPlanilhas)
		oPlan:bLine := { || { aPlanilhas[oPlan:nAT,1],;
							  aPlanilhas[oPlan:nAT,2],;
  							  aPlanilhas[oPlan:nAT,3],;
							  aPlanilhas[oPlan:nAT,4]} }
		DEFINE SBUTTON oBtnA FROM 93, 188 TYPE 3 ENABLE OF oDlg Action(lRet := .T.,oDlg:End())
		DEFINE SBUTTON FROM 93, 215 TYPE 2 ENABLE OF oDlg Action (lRet:= .F.,ODlg:End())
	ACTIVATE MSDIALOG oDlg CENTER
	cCodPlan := AllTrim(aPlanilhas[nX,1])
	cCodRev  := AllTrim(aPlanilhas[nX,2])
	cArqMemo := AllTrim(aPlanilhas[nX,3])
	lPesqRev:= .T.
Else
	Planilha(oBtnD,oBtnE,oBtnF)
	lRet:= .T.
EndIf

(cAliasTRB)->(DbCloseArea())
RestArea(aArea)

RETURN lRet

