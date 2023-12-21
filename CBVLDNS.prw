#INCLUDE "AcdXFun.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"


User Function CBVLDNS(cNumSer,cSerie,aEtiqueta)
Local aSvAlias 	:= GetArea()
Local aSvSC9   	:= SC9->( GetArea() )
Local aSvCB9   	:= CB9->( GetArea() )
Local lRet 		:= .T.
Local cQuery	:= " "
Local cFinalQuery := " "
Local cAlias1	  := " "
Local oStatement



Private cPENumSer:= cNumSer
Default cSerie := Space(Len(CB8->CB8_NUMSER))
Default lEstorno := .F.

oStatement := FWPreparedStatement():New()

cQuery := " SELECT CB9.R_E_C_N_O_ AS REG FROM "+RetSqlName("CB9")+" CB9"
cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9 ON "
cQuery += " SC9.C9_FILIAL = ? AND "
cQuery += " SC9.C9_PEDIDO = CB9.CB9_PEDIDO AND "
cQuery += " SC9.C9_PRODUTO = CB9.CB9_PROD AND "
cQuery += " SC9.C9_LOCAL = CB9.CB9_LOCAL AND "
cQuery += " SC9.C9_ORDSEP = CB9.CB9_ORDSEP AND "
cQuery += " SC9.C9_REMITO = ' ' AND "
cQuery += " SC9.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CB9.CB9_FILIAL = ? AND "
cQuery += " CB9.CB9_PROD = ? AND "
cQuery += " CB9.CB9_LOCAL = ? AND "
cQuery += " CB9.CB9_LCALIZ = ? AND "
cQuery += " CB9.CB9_NUMSER = ? AND "
cQuery += " CB9.D_E_L_E_T_ = ' ' "
cQuery    := ChangeQuery(cQuery)
oStatement:SetQuery(cQuery)
oStatement:SetString(1, xFilial("SC9"))
oStatement:SetString(2, xFilial("CB9"))
oStatement:SetString(3,CB8->CB8_PROD)
oStatement:SetString(4,CB8->CB8_LOCAL)
oStatement:SetString(5,CB8->CB8_LCALIZ)
oStatement:SetString(6,cNumSer)

cFinalQuery := oStatement:GetFixQuery()
cAlias1 := MpSysOpenQuery(cFinalQuery)
If (cAlias1)->(!Eof()) .AND. (cAlias1)->REG > 0
		IF !lApp
			VTAlert(STR0071,STR0004,.T.,3000) //### "O numero de serie selecionado pertence a outra ordem de separacao, selecione outro numero de serie"
		EndIf
    lRet := .F.
EndIf
(cAlias1)->(dbCloseArea())


If	lRet
	If	Empty(cNumSer)
		aSave:= VTSAVE()
		VTClear()
		If VTModelo()=="RF"
			@ 0,0 VTSay STR0022 //"Leitura do Numero"
			@ 1,0 VTSay STR0023 //"de Serie"
			@ 3,0 VTGet cNumSer pict '@!' Valid VldNumSer(cNumSer,cSerie,lEstorno)
		Else
			@ 0,0 VTSay STR0024 //"Numero de Serie"
			@ 1,0 VTGet cNumSer pict '@!' Valid VldNumSer(cNumSer,cSerie,lEstorno)
		EndIf
		VtRestore(,,,,aSave)
		If VTLastKey() == 27
			VTAlert(STR0025,STR0011,.t.,3000) //"Numero de Serie invalido"###"Aviso"
			lRet := .F.
		EndIf
		
	ElseIf !VldNumSer(cNumSer,cSerie,lEstorno)
		lRet:= .F.
	EndIf
EndIf



    
RestArea( aSvCB9 )
RestArea( aSvSC9 )
RestArea( aSvAlias )
FWFreeArray( aSvCB9 )
FWFreeArray( aSvSC9 )
FWFreeArray( aSvAlias )
FreeObj(oStatement)

Return lRet
