#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function XDIFERENCIA()
	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return NIL

Static Function ReportDef()
	Local oReport
	Local oSection1, oSection3, oSection4
	Local cAliasQry 	:= GetNextAlias()

	oReport := TReport():New("DIF_D5-D3"+Time(),"Diferencias","	XDIF", {|oReport| ReportPrint(oReport,cAliasQry)},"Generación de informe de diferencias")

	// oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
	oReport:SetLandscape()
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	// oReport:nMarginBottom(40)
	oReport:nFontBody	:= 10  // Define o tamanho da fonte.
	// oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:oPage:SetPaperSize(1) //Carta
	oReport:NDEVICE := 6 // PDF
	oReport:NENVIRONMENT := 2
	oReport:cPathPDF := "C:\tmp\" // Caso seja utilizada impressão em IMP_PDF
	oReport:lParamPage := .F. //Desabilita a Pagina Inicial de Parametros

	Pergunte(oReport:uParam,.F.)

	oSection1 := TRSection():New(oReport,'Report Dif',{"SD5"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSection1,"TABLA"	  	,/*Tabela*/	,'Tabla',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"PRODUTO"	  	,/*Tabela*/	,'Producto',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"ALMACEN"	  	,/*Tabela*/	,'Almacen',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"TM"	  	,/*Tabela*/	,'Tipo de movimiento',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"DOC"	  	,/*Tabela*/	,'Documento',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"ESTORNO"	  	,/*Tabela*/	,'Estorno',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"SEQ"	  	,/*Tabela*/	,'Sequencia',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"EMISSAO"	  	,/*Tabela*/	,'Fecha de Generación',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)

	oSection1:SetNoFilter({"SD5","SD3"})	
Return(oReport)


Static Function ReportPrint(oReport,cAliasQry)

	Local  aSvAlias     := GetArea()
	Local  aSvSD5       := SD5->(GetArea())
	Local  aSvSD3       := SD3->(GetArea())
	Local oSection1	:= oReport:Section(1)
	
	oReport:nLineHeight	:= 40 // Define a altura da linha.

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtragem do relatório                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// dbSetOrder(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// oReport:Section(1):BeginQuery()
	oSection1:BeginQuery()
	BeginSql Alias cAliasQry

	SELECT * FROM (
SELECT
	'SD3' TABLA, 
	D3_COD PROD,
	D3_LOCAL ARMAZEN,
	D3_TM TM,
	D3_DOC DOC,
	D3_ESTORNO ESTORNO,
	D3_NUMSEQ SEQ,
	D3_EMISSAO EMISSAO
	FROM %Table:SD3% D3
	INNER JOIN %Table:SD5% D5
	ON D5_DOC=D3_DOC
	AND D5_FILIAL=D3_FILIAL
	AND D5.D_E_L_E_T_ ='' 
	AND D3_COD=D5_PRODUTO
	AND D3_LOCAL=D5_LOCAL
	AND D3_TM=D5_ORIGLAN
	AND D3_NUMSEQ=D5_NUMSEQ
	AND D5_ESTORNO='S'
	WHERE D3.D_E_L_E_T_ ='' AND D3_ESTORNO=''
	UNION
	SELECT 
	'SD5' TABLA, 
	D5_PRODUTO PROD,
	D5_LOCAL ARMAZEN,
	D5_ORIGLAN TM,
	D5_DOC DOC,
	D5_ESTORNO ESTORNO,
	D5_NUMSEQ SEQ,
	D5_DATA EMISSAO
	FROM %Table:SD3% D3
	INNER JOIN %Table:SD5% D5
	ON D5_DOC=D3_DOC
	AND D5_FILIAL=D3_FILIAL
	AND D5.D_E_L_E_T_ ='' 
	AND D3_COD=D5_PRODUTO
	AND D3_LOCAL=D5_LOCAL
	AND D3_TM=D5_ORIGLAN
	AND D3_NUMSEQ=D5_NUMSEQ
	AND D5_ESTORNO='S'
	WHERE D3.D_E_L_E_T_ ='' AND D3_ESTORNO=''
	UNION
	SELECT 
	'SD5' TABLA, 
	D5_PRODUTO PROD,
	D5_LOCAL ARMAZEN,
	D5_ORIGLAN TM,
	D5_DOC DOC,
	D5_ESTORNO ESTORNO,
	D5_NUMSEQ SEQ,
	D5_DATA EMISSAO
	FROM %Table:SD3% D3
	INNER JOIN %Table:SD5% D5
	ON D5_DOC=D3_DOC
	AND D5_FILIAL=D3_FILIAL
	AND D5.D_E_L_E_T_ ='' 
	AND D3_COD=D5_PRODUTO
	AND D3_LOCAL=D5_LOCAL
	AND D3_NUMSEQ=D5_NUMSEQ
	AND D5_ESTORNO='S'
	WHERE D3.D_E_L_E_T_ ='' AND D3_ESTORNO=''
	) DATOS
	// WHERE EMISSAO LIKE '202310%'
	// 		AND EMISSAO >= %Exp:mv_par03%
	// 		AND EMISSAO <= %Exp:mv_par04%
	ORDER BY DOC,SEQ,TABLA	


		
	EndSql
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
	oSection1:EndQuery()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasQry)
	

	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

	
		oSection1:Init()

		oSection1:Cell("TABLA"):SetValue((cAliasQry)->TABLA)
		oSection1:Cell("PRODUTO"):SetValue((cAliasQry)->PROD)
		oSection1:Cell("ALMACEN"):SetValue((cAliasQry)->ARMAZEN)
		oSection1:Cell("TM"):SetValue((cAliasQry)->TM)
		oSection1:Cell("DOC"):SetValue((cAliasQry)->DOC)
		oSection1:Cell("ESTORNO"):SetValue((cAliasQry)->ESTORNO)
		oSection1:Cell("SEQ"):SetValue((cAliasQry)->SEQ)
		oSection1:Cell("EMISSAO"):SetValue((cAliasQry)->EMISSAO)


		oSection1:PrintLine()



		oReport:IncMeter()

		
		oSection1:Finish()
	
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea( aSvSD3 )
	RestArea( aSvSD5 )
	RestArea( aSvAlias )
Return

