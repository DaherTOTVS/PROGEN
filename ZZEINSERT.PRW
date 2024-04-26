#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"


User function ZZEINSERT()
Local aSvAlias     := GetArea()
Local aSvZZE   := ZZE->(GetArea())
Local cQuery  :=""
Local cFinalQuery := " "
Local cAlias1	  := " "
Local cCli := ""
Local cLoj := ""
Local cNom := ""
Local cDir := ""
Local cEst := ""
Local cMun := ""
Local oStatement

	oStatement := FWPreparedStatement():New()
	cQuery := " SELECT A1_COD, A1_LOJA, A1_NREDUZ, A1_ENDENT, A1_XESTENT, A1_XCDMUEN"
	cQuery += " FROM "+RetSqlName("SA1")+"  "
	cQuery += " WHERE A1_FILIAL  = ? "	
	cQuery += "   AND D_E_L_E_T_  <> '*' "
	cQuery := ChangeQuery(cQuery)
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1,xFilial("SA1"))
    
    cFinalQuery := oStatement:GetFixQuery()
    cAlias1 := MpSysOpenQuery(cFinalQuery)
	dbSelectArea( "ZZE" )

    While (cAlias1)->(!Eof())

		cCli  := PADR((cAlias1)->A1_COD,TAMSX3("ZZE_CODCL")[1])
		cLoj  := PADR((cAlias1)->A1_LOJA,TAMSX3("ZZE_LOJC")[1])
		cNom  := PADR((cAlias1)->A1_NREDUZ,TAMSX3("ZZE_NOMCL")[1])
		cDir  := PADR((cAlias1)->A1_ENDENT,TAMSX3("ZZE_DIRECC")[1])
		cEst  := PADR((cAlias1)->A1_XESTENT,TAMSX3("ZZE_EST")[1])
		cMun  := PADR((cAlias1)->A1_XCDMUEN,TAMSX3("ZZE_MUN")[1])
		
		If !EMPTY(ALLTRIM(cEst)) .AND. !EMPTY(ALLTRIM(cDir)) .AND. !EMPTY(ALLTRIM(cMun))
			ZZE->(dbSetOrder(1))
			IF !(ZZE->(DBSEEK(cCli+cLoj+cEst+cMun+cDir)))

				Reclock("ZZE",.T.)
					Replace ZZE_FILIAL    With xFilial('ZZE')
					Replace ZZE_COD   With GETSXENUM("ZZE","ZZE_COD")
					Replace ZZE_CODCL With cCli
					Replace ZZE_LOJC With cLoj
					Replace ZZE_NOMCL With cNom
					Replace ZZE_EST With cEst
					Replace ZZE_NOMEST With Posicione('SX5',1,xFilial('SX5')+"12"+cEst,'X5DESCRI()')
					Replace ZZE_MUN With cMun
					Replace ZZE_NOMMUN With POSICIONE("CC2",1,xfilial("CC2")+PADR(cEst,TAMSX3("CC2_EST")[1])+PADR(cMun,TAMSX3("CC2_MUN")[1]),"CC2_MUN")
					Replace ZZE_DIRECC With cDir
				ZZE->(MsUnlock())
			EndIf
		EndIf
        (cAlias1)->(dbSkip())
    EndDo
	("ZZE")->(DBCloseArea())
    (cAlias1)->(dbCloseArea())

RestArea( aSvZZE )
RestArea( aSvAlias )
FWFreeArray( aSvZZE )
FWFreeArray( aSvAlias ) 

RETURN .T.
