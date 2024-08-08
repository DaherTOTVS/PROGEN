#Include "Topconn.ch"
#Include"Protheus.ch"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: AjustaSX1      ||Data: 04/01/2023 ||Empresa: PROGEN       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Stock         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para mostrar la leyenda en el browser       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SC2Status

Local cNombStatus :=""
Local aAreaSC2    := SC2->(GetArea())
Local cAliasSD3   := GetNextAlias()
Local cAliasSH6   := GetNextAlias()
Local cAliasExi   := GetNextAlias()
Local cFilSC2     := xFilial("SC2")
Local cFilSH6     := xFilial("SH6")
Local cNumOp      := ""
Local cQuery 	  := ""
Local dEmissao	  := dDatabase
Local dEmissaoH6  := dDatabase 
Local dEmissaoD3  := dDatabase
Local nRegSD3	  := 0						//Contador da tabela SD3
Local nRegSH6	  := 0                      //Contador da tabela SH6

Static cCacheD3
Static cCacheH6
Static cOPAnt
Static cRegSH6
Static dEmiAntH6   
Static dEmiAntD3   
Static nRegD3Ant
Static nRegH6Ant

	If cRegSH6 == Nil
		cQuery	  := "  SELECT 1 "
		cQuery	  += "   FROM " + RetSqlName('SH6')
		cQuery	  += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
		cQuery	  += "     AND D_E_L_E_T_  = ' '"
		cQuery    := ChangeQuery(cQuery)
		dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasExi, .F., .T.)

		If !(cAliasExi)->(Eof())
			cRegSH6 := 'S'
		Else
			cRegSH6 := 'N'
		EndIf

		(cAliasExi)->(DbCloseArea())
	EndIf

	cNumOp := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	
	oPrepSD3 := cCacheD3

	If  oPrepSD3 == NIL	
		cQuery	  := "  SELECT COUNT(1) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
		cQuery	  += "   FROM " + RetSqlName('SD3')
		cQuery	  += "   WHERE D3_FILIAL   = ? "
		cQuery	  += "     AND D3_OP 	   = ? "
		cQuery	  += "     AND D3_ESTORNO  = ' ' "
		cQuery	  += "     AND D_E_L_E_T_  = ' ' "

		cQuery    := ChangeQuery(cQuery)
		oPrepSD3 := FWPreparedStatement():New(cQuery) //Construtor da carga.
		cCacheD3 := oPrepSD3
	EndIf 	
	
	If cOPAnt == Nil .Or. cOPAnt != cNumOp
		oPrepSD3:SetString(01, cFilSC2) //Seta um par?etro na query via String.
		oPrepSD3:SetString(02, cNumOp)
		
		cQuery := oPrepSD3:GetFixQuery() //Retorna a query com os par?etros j?tratados e substitu?os.
		cAliasSD3 := MPSysOpenQuery(cQuery, cAliasSD3) //Abre um alias com a query informada.

		If !(cAliasSD3)->(Eof())
			dEmissaoD3 := STOD((cAliasSD3)->EMISSAO)
			nRegSD3 := (cAliasSD3)->RegSD3		
    	EndIf
		
		dEmiAntD3 := dEmissaoD3
		nRegD3Ant := nRegSD3

		(cAliasSD3)->(DbCloseArea())
	Else
		dEmissaoD3 := dEmiAntD3
		nRegSD3 := nRegD3Ant
	EndIf 

	If cRegSH6 == 'S' 
		oPrepSH6 := cCacheH6

		If  oPrepSH6 == NIL	
			cQuery	  := "  SELECT COUNT(1) AS RegSH6, MAX(H6_DTAPONT) AS EMISSAO  "
			cQuery	  += "   FROM " + RetSqlName('SH6')
			cQuery	  += "   WHERE H6_FILIAL   = ? "
			cQuery	  += "     AND H6_OP 	   = ? "
			cQuery	  += "     AND D_E_L_E_T_  = ' ' "
		
			cQuery    := ChangeQuery(cQuery)
			oPrepSH6 := FWPreparedStatement():New(cQuery) //Construtor da carga.
			cCacheH6 := oPrepSH6
		EndIf 

		If cOPAnt == Nil .Or. cOPAnt != cNumOp

			oPrepSH6:SetString(01, cFilSH6) //Seta um par?etro na query via String.
			oPrepSH6:SetString(02, cNumOp)

			cQuery := oPrepSH6:GetFixQuery() //Retorna a query com os par?etros j?tratados e substitu?os.
			cAliasSH6 := MPSysOpenQuery(cQuery, cAliasSH6) //Abre um alias com a query informada.

			If !(cAliasSH6)->(Eof())
				dEmissaoH6 := STOD((cAliasSH6)->EMISSAO)
				nRegSH6  := (cAliasSH6)->RegSH6
			EndIf
			
			dEmiAntH6 := dEmissaoH6
			nRegH6Ant := nRegSH6

			(cAliasSH6)->(DbCloseArea())
		Else
			dEmissaoH6 := dEmiAntH6
			nRegSH6 := nRegH6Ant 
		EndIf 
	EndIf
	
	dEmissao := Max(dEmissaoH6,dEmissaoD3)
	cOPAnt   := cNumOp


if  SC2->C2_TPOP == "P" //Prevista
    cNombStatus:= "Prevista"
elseif SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (p < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI==0,1,SC2->C2_DIASOCI)) //Em aberto
    cNombStatus:= "Pendiente"
Elseif SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((ddatabase - SC2->C2_EMISSAO),0) < If(SC2->C2_DIASOCI==0,1,SC2->C2_DIASOCI)) //Iniciada
    cNombStatus:= "Iniciada"
Elseif SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max((ddatabase - SC2->C2_EMISSAO),0) > SC2->C2_DIASOCI .Or. Max((ddatabase - SC2->C2_DATPRI),0) >= SC2->C2_DIASOCI)   //Ociosa
    cNombStatus:= "Inactiva"
Elseif SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE < C2_QUANT)  //Enc.Parcialmente
	cNombStatus:= "Encerrada Parcial"
Elseif SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE >= C2_QUANT) //Enc.Totalmente
    cNombStatus:= "Encerrada Total"
EndIF

RestArea(aAreaSC2)

Return cNombStatus
