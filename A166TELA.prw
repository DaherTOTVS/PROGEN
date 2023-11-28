#Include "Protheus.ch"
#INCLUDE "APVT100.CH"

User Function A166TELA()

	CONOUT("INI A166TELA",TIME())
	Local aTotais := TotSep(CB8->CB8_ORDSEP,CB8->CB8_PROD)

   	VtClear()
	@ 0,0 VTSay CB8->CB8_PROD
	@ 1,0 VTSay Left(SB1->B1_DESC,20)

	IF !Empty(CB8->CB8_NUMSER)
		@ 2,0 VTSay CB8->CB8_NUMSER
	ENDIF

	@ 3,0 VTSay "Total:"+Alltrim(Str(aTotais[1]))
	@ 4,0 VTSay "Lidos:"+Alltrim(Str(aTotais[3]))
	// @ 5,0 VTSay "  Faltam:"+Alltrim(Str(aTotais[2]))
	CONOUT("FIN A166TELA",TIME())
	
Return Nil


Static Function TotSep(cOdSep,cProd)
	Local  aSvAlias     := GetArea()
	Local  aSvCB8       := CB8->(GetArea())
	Local aTotal :={}
	Local cQuery  :=""
	Local cFinalQuery := " "
	Local cAlias1	  := " "
	Local nLidos	  := " "
	Local oStatement

	oStatement := FWPreparedStatement():New()
	cQuery := " SELECT SUM(CB8_QTDORI) AS CB8_QTDORI,SUM(CB8_SALDOS ) AS CB8_SALDOS"
	cQuery += " FROM "+RetSqlName("CB8")+"  "
	cQuery += " WHERE CB8_FILIAL  = ? "	
	cQuery += "	  AND CB8_ORDSEP  = ? " 
	cQuery += "	  AND CB8_PROD    = ? "
	cQuery += "   AND D_E_L_E_T_  <> '*'                 "
	cQuery := ChangeQuery(cQuery)
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1,xFilial("CB8"))
    oStatement:SetString(2,cOdSep)
    oStatement:SetString(3,cProd)
    
    cFinalQuery := oStatement:GetFixQuery()
    cAlias1 := MpSysOpenQuery(cFinalQuery)

    While (cAlias1)->(!Eof())
		nLidos := ((cAlias1)->CB8_QTDORI - (cAlias1)->CB8_SALDOS)
        aTotal := {(cAlias1)->CB8_QTDORI,(cAlias1)->CB8_SALDOS ,nLidos}
        (cAlias1)->(dbSkip())
    EndDo
    (cAlias1)->(dbCloseArea())

	RestArea( aSvCB8 )
	RestArea( aSvAlias )
	FWFreeArray( aSvCB8 )
	FWFreeArray( aSvAlias ) 

Return aTotal
