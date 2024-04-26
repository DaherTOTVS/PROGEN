#Include "PROTHEUS.CH"
#Include "TopConn.ch"

User Function XSERSTOCK()

	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local oReport
	Local xAuxTerc
	Local cAliasQry 	:= GetNextAlias()
	Local cAliasQryBF 	:= GetNextAlias()

	U_ACD166DH()


	oReport := TReport():New("XSERSTOCK","Balance Stock - Seriales ","XSERSTOCK", {|oReport| ReportPrint(oReport,cAliasQry,cAliasQryBF,xAuxTerc)},"Balance Stock - Seriales")
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

	xuserStock := TRSection():New(oReport,'Balance Stock - Seriales',{"SB2","SBF","SDC"},/*{Array com as ordens do relatСrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	xuserStock:SetTotalInLine(.F.)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDefine celulas da secao                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRCell():New(xuserStock,"CODIGO"	  	,/*Tabela*/	,'CODIGO',PesqPict("SB2","B2_COD")		,TamSx3("B2_COD")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"BODEGA"	  	,/*Tabela*/	,'BODEGA',PesqPict("SB2","B2_LOCAL")		,TamSx3("B2_LOCAL")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"ACTUAL"	  	,/*Tabela*/	,'SLD. ACTUAL',PesqPict("SB2","B2_QATU")		,TamSx3("B2_QATU")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"RESERVA"	  	,/*Tabela*/	,'SLD. RESERVA',PesqPict("SB2","B2_RESERVA")		,TamSx3("B2_RESERVA")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"UBICAR"	  	,/*Tabela*/	,'SLD. UBICAR',PesqPict("SB2","B2_QACLASS")		,TamSx3("B2_QACLASS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"DISPONIBLE"	  	,/*Tabela*/	,'SLD. DISPONIBLE',PesqPict("SB2","B2_QATU")		,TamSx3("B2_QATU")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"TOT_SERIALES"	  	,/*Tabela*/	,'TOT SERIALES',PesqPict("SB2","B2_RESERVA")		,TamSx3("B2_RESERVA")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"TOT_RESERVA"	  	,/*Tabela*/	,'SERI RESERVADOS',PesqPict("SB2","B2_QACLASS")		,TamSx3("B2_QACLASS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"TOT_DISPONIBLES"	  	,/*Tabela*/	,'SERI DISPONIBLES',PesqPict("SB2","B2_QACLASS")		,TamSx3("B2_QACLASS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"SERI_RESER"	  	,/*Tabela*/	,'RESER/PED_VEN',PesqPict("SB2","B2_QACLASS")		,TamSx3("B2_QACLASS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)


	oSection2 := TRSection():New(oReport,'Seriales',{"SBF"},/*{Array com as ordens do relatСrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection2:SetTotalInLine(.F.)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDefine celulas da secao                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	TRCell():New(oSection2,"PRODUTO"	  	,/*Tabela*/	,'PRODUTO',PesqPict("SBF","BF_PRODUTO")		,TamSx3("BF_PRODUTO")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection2,"ALMACEN"	  	,/*Tabela*/	,'ALMACEN',PesqPict("SBF","BF_LOCAL")		,TamSx3("BF_LOCAL")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection2,"NUMSERI"	  	,/*Tabela*/	,'NUMSERI',PesqPict("SBF","BF_NUMSERI")		,TamSx3("BF_NUMSERI")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection2,"EMPENHO"	  	,/*Tabela*/	,'EMPENHO',PesqPict("SBF","BF_EMPENHO")		,TamSx3("BF_EMPENHO")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)


Return(oReport)

Static Function ReportPrint(oReport,cAliasQry,cAliasQryBF,xuserStock)

	Local oSection2	:= oReport:Section(2)
	Local cSql := ""
	// Local Upd :=""

	oReport:Section(1):Cell("CODIGO" ):SetBlock({|| (cAliasQry)->B2_COD})
	oReport:Section(1):Cell("BODEGA" ):SetBlock({|| (cAliasQry)->B2_LOCAL})
	oReport:Section(1):Cell("ACTUAL" ):SetBlock({|| (cAliasQry)->ACTU})
	oReport:Section(1):Cell("RESERVA" ):SetBlock({|| (cAliasQry)->RESERVA})
	oReport:Section(1):Cell("UBICAR" ):SetBlock({|| (cAliasQry)->X_UBICAR})
	oReport:Section(1):Cell("DISPONIBLE" ):SetBlock({|| (cAliasQry)->DISPO})
	oReport:Section(1):Cell("TOT_SERIALES" ):SetBlock({|| (cAliasQry)->BF_TOT})
	oReport:Section(1):Cell("TOT_RESERVA" ):SetBlock({|| (cAliasQry)->BF_RESERVA})
	oReport:Section(1):Cell("TOT_DISPONIBLES" ):SetBlock({|| (cAliasQry)->BF_DISPO})
	oReport:Section(1):Cell("SERI_RESER" ):SetBlock({|| (cAliasQry)->DC_TOT})

	IF mv_par08=1
		oSection2:Cell("PRODUTO" ):SetBlock({|| (cAliasQryBF)->BF_PRODUTO})
		oSection2:Cell("ALMACEN" ):SetBlock({|| (cAliasQryBF)->BF_LOCAL})
		oSection2:Cell("NUMSERI" ):SetBlock({|| (cAliasQryBF)->BF_NUMSERI})
		oSection2:Cell("EMPENHO" ):SetBlock({|| (cAliasQryBF)->BF_EMPENHO})
	ENDIF

	// oReport:Section(2):Cell("PRODUTO" ):SetBlock({|| (cAliasQry)->B2_COD})
	// oReport:Section(2):Cell("ALAMCEN" ):SetBlock({|| (cAliasQry)->ACTU})


	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁTransforma parametros Range em expressao SQL                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MakeSqlExpr(oReport:uParam)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFiltragem do relatСrio                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SB2")
	// dbSetOrder(2)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuery do relatСrio da secao 1                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oReport:Section(1):BeginQuery()




	// Upd := " UPDATE "+RetSqlName("SB2")+" "
	// Upd += " SET B2_RESERVA=COUNT(B2_COD) "
	// Upd += " FROM "+RetSqlName("SB2")+" SB2 "
	// Upd += " INNER JOIN "+RetSqlName("SBF")+" BF1 "
	// Upd += " ON SB2.B2_COD=BF1.BF_PRODUTO "
	// Upd += " AND SB2.B2_LOCAL=BF1.BF_LOCAL "
	// Upd += " AND BF1.D_E_L_E_T_ <>'*' "
	// Upd += " AND BF_EMPENHO=1 "
	// Upd += " WHERE "
	// Upd += " SB2.D_E_L_E_T_ <>'*' "
	// Upd +=" 	AND B2_COD >= '"+mv_par01+"' "
	// Upd +=" 	AND B2_COD <= '"+mv_par02+"' "
	// Upd +=" 	AND B2_LOCAL >= '"+mv_par03+"' "
	// Upd +=" 	AND B2_LOCAL <= '"+mv_par04+"' "
	// n1Statud :=TCSqlExec(Upd)


	// Upd := " UPDATE "+RetSqlName("SB2")+" "
	// Upd += " SET B2_QATU= (SELECT COUNT(*) "
	// Upd += " FROM "+RetSqlName("SB2")+" SB2 "
	// Upd += " INNER JOIN "+RetSqlName("SBF")+" BF1 "
	// Upd += " ON SB2.B2_COD=BF1.BF_PRODUTO "
	// Upd += " AND SB2.B2_LOCAL=BF1.BF_LOCAL "
	// Upd += " AND SB2.D_E_L_E_T_ <>'*' "
	// Upd += " AND BF1.D_E_L_E_T_ <>'*' )"
	// Upd += " WHERE "
	// Upd += " D_E_L_E_T_ <>'*' "
	// Upd +=" 	AND B2_COD >= '"+mv_par01+"' "
	// Upd +=" 	AND B2_COD <= '"+mv_par02+"' "
	// Upd +=" 	AND B2_LOCAL >= '"+mv_par03+"' "
	// Upd +=" 	AND B2_LOCAL <= '"+mv_par04+"' "

	// n1Statud :=TCSqlExec(Upd)








	cSql +=" SELECT "
	cSql +=" 	B2_COD, "
	cSql +=" 	B2_LOCAL, "
	cSql +=" 	B2_QATU ACTU, "
	cSql +=" 	B2_RESERVA RESERVA, "
	cSql +=" 	B2_QACLASS X_UBICAR, "
	cSql +=" 	(B2_QATU - B2_RESERVA - B2_QACLASS) DISPO, "
	cSql +=" 	( "
	cSql +=" 		SELECT "
	cSql +=" 			COUNT(*) "
	cSql +=" 		FROM "
	cSql +=" 			" + RetSqlName("SBF") + " SBF "
	cSql +=" 		WHERE "
	cSql +=" 			B2_COD = BF_PRODUTO "
	cSql +=" 			AND B2_LOCAL = BF_LOCAL "
	cSql +=" 			AND BF_QUANT >0 "
	cSql +=" 			AND SBF.D_E_L_E_T_ <> '*' "
	cSql +=" 	) BF_TOT, "
	cSql +=" 	( "
	cSql +=" 		SELECT "
	cSql +=" 			COUNT(*) "
	cSql +=" 		FROM "
	cSql +=" 			" + RetSqlName("SBF") + " SBF "
	cSql +=" 		WHERE "
	cSql +=" 			B2_COD = BF_PRODUTO "
	cSql +=" 			AND B2_LOCAL = BF_LOCAL "
	cSql +=" 			AND BF_QUANT >0 "
	cSql +=" 			AND SBF.D_E_L_E_T_ <> '*' "
	cSql +=" 			AND BF_EMPENHO = 1 "
	cSql +=" 	) BF_RESERVA, "
	cSql +=" 	( "
	cSql +=" 		SELECT "
	cSql +=" 			COUNT(*) "
	cSql +=" 		FROM "
	cSql +=" 			" + RetSqlName("SBF") + " SBF "
	cSql +=" 		WHERE "
	cSql +=" 			B2_COD = BF_PRODUTO "
	cSql +=" 			AND B2_LOCAL = BF_LOCAL "
	cSql +=" 			AND SBF.D_E_L_E_T_ <> '*' "
	cSql +=" 			AND BF_QUANT >0 "
	cSql +=" 			AND BF_EMPENHO = 0 "
	cSql +=" 	) BF_DISPO, "
	cSql +=" 	( "
	cSql +=" 		SELECT "
	cSql +=" 			COUNT(*) "
	cSql +=" 		FROM "
	cSql +=" 			" + RetSqlName("SDC") + " SDC "
	cSql +=" 		WHERE "
	cSql +=" 			B2_COD = DC_PRODUTO "
	cSql +=" 			AND B2_LOCAL = DC_LOCAL "
	cSql +=" 			AND SDC.D_E_L_E_T_ <> '*' "
	cSql +=" 	) DC_TOT "
	cSql +=" FROM "
	cSql +=" 	" + RetSqlName("SB2") + " SB2 INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD=B2_COD  AND SB1.D_E_L_E_T_ <>'*' AND B1_LOCALIZ='S' "
	cSql +=" WHERE "
	cSql +=" 	SB2.D_E_L_E_T_ <> '*' "
	cSql +=" 	AND B2_COD >= '"+mv_par01+"' "
	cSql +=" 	AND B2_COD <= '"+mv_par02+"' "
	cSql +=" 	AND B2_LOCAL >= '"+mv_par03+"' "
	cSql +=" 	AND B2_LOCAL <= '"+mv_par04+"' "
	IF mv_par07<3
		IF mv_par07=1
			cSql+= " AND B2_RESERVA <> ( "
		ENDIF
		IF mv_par07=2
			cSql += " AND B2_RESERVA = ( "
		ENDIF
		cSql +=" 	SELECT "
		cSql +=" 		COUNT(*) "
		cSql +=" 	FROM "
		cSql +=" 		" + RetSqlName("SBF") + " SBF "
		cSql +=" 	WHERE "
		cSql +=" 		B2_COD = BF_PRODUTO "
		cSql +=" 		AND B2_LOCAL = BF_LOCAL "
		cSql +=" 		AND D_E_L_E_T_ <> '*' "
		cSql +=" 		AND BF_QUANT >0 "
		cSql +=" 		AND BF_EMPENHO = 1 "
		cSql +=" ) "
	ENDIF


	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)


	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicio da impressao do fluxo do relatСrio                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	// dbSelectArea(cAliasQry)
	// dbGoTop()
	TCQUERY cSql NEW ALIAS &cAliasQry
	DbSelectArea((cAliasQry))
	(cAliasQry)->(DbGoTop())

	oReport:SetMeter((cAliasQry)->(LastRec()))
	oReport:Section(1):Init()



	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())


		oReport:Section(1):PrintLine()
		IF mv_par08=1
			Xproduto := (cAliasQry)->B2_COD
			Xlocal := (cAliasQry)->B2_LOCAL

			oReport:Section(2):BeginQuery()
			BeginSql Alias cAliasQryBF
			SELECT BF_PRODUTO,BF_LOCAL,BF_NUMSERI,BF_EMPENHO
			FROM %Table:SBF% SBF
					WHERE
						BF_PRODUTO = %Exp:Xproduto%
						AND BF_LOCAL = %Exp:Xlocal%
						AND BF_QUANT > 0
						AND D_E_L_E_T_ <> '*'
			EndSql
			oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)

			dbSelectArea(cAliasQryBF)
			dbGoTop()
			oReport:SetMeter((cAliasQryBF)->(LastRec()))
			oReport:Section(2):Init()

			While !oReport:Cancel() .And. !(cAliasQryBF)->(Eof())

				oReport:Section(2):PrintLine()

				dbSelectArea(cAliasQryBF)
				dbSkip()
			EndDo





		ENDIF

		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo
	oReport:Section(1):Finish()
	oReport:Section(2):Finish()




Return


