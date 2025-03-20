#Include "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "Acda100.ch"

User Function XSEGSERI()

	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local oReport

	oReport := TReport():New("XSEGSERI","Seguimiento serial","XSEGSERI", {|oReport| ReportPrint(oReport)},"Seguimiento serial")
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

	xuserStock := TRSection():New(oReport,'Seguimiento serial',{"SB2","CB8","CB9","SC5","SDB","SD2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	xuserStock:SetTotalInLine(.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(xuserStock,"CB8_PROD"	  	,/*Tabela*/	,'CODIGO',PesqPict("SB2","B2_COD")		,TamSx3("B2_COD")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB8_LOCAL"	  	,/*Tabela*/	,'ALMACEN',PesqPict("SB2","B2_LOCAL")		,TamSx3("B2_LOCAL")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB8_NUMSER"	  	,/*Tabela*/	,'SERIAL SUGERIDO',PesqPict("CB8","CB8_NUMSER")		,TamSx3("CB8_NUMSER")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB9_NUMSER"	  	,/*Tabela*/	,'SERIAL LEIDO',PesqPict("CB9","CB9_NUMSER")		,TamSx3("CB9_NUMSER")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"DB_NUMSERI"	  	,/*Tabela*/	,'SERIAL DESPACHADO',PesqPict("SDB","DB_NUMSERI")		,TamSx3("DB_NUMSERI")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_CLIENTE"	  	,/*Tabela*/	,'CLIENTE',PesqPict("SC5","C5_CLIENTE")		,TamSx3("C5_CLIENTE")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_NOMCLIE"	  	,/*Tabela*/	,'NOMBRE',PesqPict("SC5","C5_XNCLIEN")		,TamSx3("C5_XNCLIEN")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_LOJACLI"	  	,/*Tabela*/	,'TIENDA',PesqPict("SC5","C5_LOJACLI")		,TamSx3("C5_LOJACLI")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB8_PEDIDO"	  	,/*Tabela*/	,'PEDIDO',PesqPict("CB8","CB8_PEDIDO")		,TamSx3("CB8_PEDIDO")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_EMISSAO"	  	,/*Tabela*/	,'FECHA PEDIDO',PesqPict("SC5","C5_EMISSAO")		,TamSx3("C5_EMISSAO")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_XMUN"	  	,/*Tabela*/	,'MUN ENTREGA',PesqPict("SC5","C5_XMUN")		,TamSx3("C5_XMUN")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"C5_XESTNOM"	  	,/*Tabela*/	,'DEP ENTREGA',PesqPict("SC5","C5_XESTNOM")		,TamSx3("C5_XESTNOM")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB8_ORDSEP"	  	,/*Tabela*/	,'ORDEN SEPARA',PesqPict("CB8","CB8_ORDSEP")		,TamSx3("CB8_ORDSEP")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB7_STATUS"	  	,/*Tabela*/	,'ESTATUS',PesqPict("CB7","CB7_STATUS")		,TamSx3("CB7_STATUS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"CB7_DTEMIS"	  	,/*Tabela*/	,'FECHA ORD SEP',PesqPict("CB7","CB7_DTEMIS")		,TamSx3("CB7_DTEMIS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"DB_DOC"	  	,/*Tabela*/	,'REMITO',PesqPict("SDB","DB_DOC")		,TamSx3("DB_DOC")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xuserStock,"D2_DOC"	  	,/*Tabela*/	,'FACTURA',PesqPict("SD2","D2_DOC")		,TamSx3("D2_DOC")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)


Return(oReport)

Static Function ReportPrint(oReport)

	Local cAliasQry 	:= GetNextAlias()
	Local cSql := ""
	Local DatIni :=""
	Local DatFin :=""

	oReport:Section(1):Cell("CB8_PROD" ):SetBlock({|| (cAliasQry)->PRODUCTO})
	oReport:Section(1):Cell("CB8_LOCAL" ):SetBlock({|| (cAliasQry)->ALMACEN})
	oReport:Section(1):Cell("CB8_NUMSER" ):SetBlock({|| (cAliasQry)->SERIAL_CB8})
	oReport:Section(1):Cell("CB9_NUMSER" ):SetBlock({|| (cAliasQry)->SERIAL_CB9})
	oReport:Section(1):Cell("DB_NUMSERI" ):SetBlock({|| (cAliasQry)->SERIAL_DB})
	oReport:Section(1):Cell("C5_CLIENTE" ):SetBlock({|| (cAliasQry)->C5_CLIENT})
	oReport:Section(1):Cell("C5_NOMCLIE" ):SetBlock({|| (cAliasQry)->C5_XNCLIEN})
	oReport:Section(1):Cell("C5_LOJACLI" ):SetBlock({|| (cAliasQry)->C5_LOJAENT})
	oReport:Section(1):Cell("CB8_PEDIDO" ):SetBlock({|| (cAliasQry)->PEDIDO})
	oReport:Section(1):Cell("C5_EMISSAO" ):SetBlock({|| (cAliasQry)->C5_EMISSAO})
	oReport:Section(1):Cell("C5_XMUN" ):SetBlock({|| (cAliasQry)->C5_XMUN})
	oReport:Section(1):Cell("C5_XESTNOM" ):SetBlock({|| (cAliasQry)->C5_XESTNOM})
	oReport:Section(1):Cell("CB8_ORDSEP" ):SetBlock({|| (cAliasQry)->ORD_SEPARACION})
	oReport:Section(1):Cell("CB7_STATUS" ):SetBlock({|| TrdEstatus((cAliasQry)->ESTADO)})
	oReport:Section(1):Cell("CB7_DTEMIS" ):SetBlock({|| (cAliasQry)->CB7_DTEMIS})
	oReport:Section(1):Cell("DB_DOC" ):SetBlock({|| (cAliasQry)->REMITO})
	oReport:Section(1):Cell("D2_DOC" ):SetBlock({|| (cAliasQry)->FACTURA})

	


	MakeSqlExpr(oReport:uParam)

	// dbSelectArea("SB2")

	oReport:Section(1):BeginQuery()

	DatIni:=DTOS(mv_par05)
	DatFin:=DTOS(mv_par06)


	cSql :=" SELECT "
	cSql +="         C9_PRODUTO PRODUCTO,  "
	cSql +="         C9_LOCAL ALMACEN,  "
	cSql +="         CB9_NSERSU SERIAL_CB8,  "
	cSql +="         CB9_NUMSER SERIAL_CB9,  "
	cSql +="         DB_NUMSERI SERIAL_DB,  "
	cSql +="         C5_CLIENT,  "
	cSql +="         C9_PEDIDO PEDIDO,  "
	cSql +="         C5_EMISSAO,  "
	cSql +="         C9_ORDSEP ORD_SEPARACION,  "
	cSql +="         CB7_STATUS ESTADO,  "
	cSql +="         CB7_DTEMIS,  "
	cSql +="         C5_XMUN,  "
	cSql +="         C5_XESTNOM,  "
	cSql +="         C5_LOJAENT,  "
	cSql +="         DB_DOC REMITO,  "
	cSql +="         D2_DOC FACTURA,  "
	cSql +="         C5_XNCLIEN, DB_ESTORNO  "
	cSql +="     FROM " + RetSqlName("SC9") + "  SC9 "

	cSql +="     	INNER JOIN  " + RetSqlName("SC5") + "   SC5 ON C5_NUM = C9_PEDIDO  "
	cSql +="             AND C9_CLIENTE = C5_CLIENTE  "
	cSql +="             AND SC5.D_E_L_E_T_ <> '*'  "
	
	cSql +="     	LEFT JOIN  " + RetSqlName("CB7") + "   CB7 ON CB7_ORDSEP = C9_ORDSEP  "
	cSql +="             AND CB7_PEDIDO = C9_PEDIDO  "
	cSql +="             AND CB7.D_E_L_E_T_ <> '*'  "
	cSql +="     	LEFT JOIN  " + RetSqlName("CB9") + "   CB9 ON CB9_PROD = C9_PRODUTO  "
	cSql +="             AND C9_LOCAL = CB9_LOCAL  "
	cSql +="             AND C9_ORDSEP = CB9_ORDSEP  "
	cSql +="             AND C9_PEDIDO = CB9_PEDIDO  "
	cSql +="             AND C9_ITEM = CB9_ITESEP "
	cSql +="             AND C9_SEQUEN = CB9_SEQUEN "
	cSql +="             AND CB9.D_E_L_E_T_ <> '*' "
	cSql +="     	LEFT JOIN  " + RetSqlName("SDB") + "   SDB ON C9_PRODUTO = DB_PRODUTO  "
	cSql +="             AND C9_LOCAL = DB_LOCAL  "
	cSql +="             AND C9_CLIENTE = DB_CLIFOR  "
	cSql +="             AND C9_REMITO = DB_DOC "
	cSql +="             AND SDB.D_E_L_E_T_ <> '*'  "
	cSql +="             AND SDB.DB_SERIE = 'R'  "
	cSql +="             AND SDB.DB_DOC >= '"+mv_par11+"'  "
	cSql +="             AND SDB.DB_DOC <= '"+mv_par12+"'  "
	cSql +="     	LEFT JOIN  " + RetSqlName("SD2") + "   SD2 ON C9_PRODUTO = D2_COD  "
	cSql +="             AND C9_LOCAL = D2_LOCAL  "
	cSql +="             AND DB_DOC = D2_REMITO  "
	cSql +="             AND SD2.D_E_L_E_T_ <> '*'  "
	cSql +="             AND SD2.D2_DOC >= '"+mv_par13+"'  "
	cSql +="             AND SD2.D2_DOC <= '"+mv_par14+"'  "
	cSql +="     WHERE  "
	cSql +="     	SC9.D_E_L_E_T_ <> '*'  "
	cSql +="     	AND C9_PRODUTO >= '"+mv_par01+"'  "
	cSql +="     	AND C9_PRODUTO <= '"+mv_par02+"'  "
	cSql +="     	AND C9_LOCAL >= '"+mv_par03+"'  "
	cSql +="     	AND C9_LOCAL <= '"+mv_par04+"'  "
	cSql +="     	AND C5_EMISSAO >= '"+DatIni+"'  "
	cSql +="     	AND C5_EMISSAO <= '"+DatFin+"'  "
	cSql +="     	AND C5_CLIENTE >= '"+mv_par07+"'  "
	cSql +="     	AND C5_CLIENTE <= '"+mv_par08+"'  "
	cSql +="     	AND C5_NUM >= '"+mv_par09+"'  "
	cSql +="     	AND C5_NUM <= '"+mv_par10+"'  "




	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// dbSelectArea(cAliasQry)
	// dbGoTop()
	TCQUERY cSql NEW ALIAS &cAliasQry
	DbSelectArea((cAliasQry))
	(cAliasQry)->(DbGoTop())

	oReport:SetMeter((cAliasQry)->(LastRec()))
	oReport:Section(1):Init()



	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		If Empty((cAliasQry)->DB_ESTORNO)
			oReport:Section(1):PrintLine()
		EndIf
		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo
	oReport:Section(1):Finish()



Return


Static Function TrdEstatus(cStatus)
	Local cDescri:= " "

	If Empty(cStatus) .or. cStatus == "0"
		cDescri:= STR0073 //"Nao iniciado"
	ElseIf cStatus == "1"
		cDescri:= STR0074 //"Em separacao"
	ElseIf cStatus == "2"
		cDescri:= STR0075 //"Separacao finalizada"
	ElseIf cStatus == "3"
		cDescri:= STR0076 //"Em processo de embalagem"
	ElseIf cStatus == "4"
		cDescri:= STR0077 //"Embalagem Finalizada"
	ElseIf cStatus == "5"
		cDescri:= STR0078 //"Nota gerada"
	ElseIf cStatus == "6"
		cDescri:= STR0079 //"Nota impressa"
	ElseIf cStatus == "7"
		cDescri:= STR0080 //"Volume impresso"
	ElseIf cStatus == "8"
		cDescri:= STR0081 //"Em processo de embarque"
	ElseIf cStatus == "9"
		cDescri:=  STR0082 //"Finalizado"
	EndIf

Return(cDescri)


