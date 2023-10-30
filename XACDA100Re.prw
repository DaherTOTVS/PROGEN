#INCLUDE "TOTVS.CH"
#INCLUDE "Acda100x.ch"
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function xACD10Re()
	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return NIL

Static Function ReportDef()
	Local oReport
	Local oSection1, oSection2, oSection3
	Local cAliasQry 	:= GetNextAlias()

	oReport := TReport():New("ACDA100RE","Orden de Separación","ACD100", {|oReport| ReportPrint(oReport,cAliasQry)},"Generación de informe de Ordenes de Separación")

	// oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
	oReport:SetLandscape()
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	// oReport:nMarginBottom(40)
	oReport:nFontBody	:= 10  // Define o tamanho da fonte.

	Pergunte(oReport:uParam,.F.)

	oSection1 := TRSection():New(oReport,'Report OS',{"CB7"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSection1,"NUMERO"	  	,/*Tabela*/	,'Orden de Separacion',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"PV"	  	,/*Tabela*/	,'Pedido de Venta',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"OC"	  	,/*Tabela*/	,'Orden de Compra',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"ESTADO"	  	,/*Tabela*/	,'Estatus',,25,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"CLIENTE"	  	,/*Tabela*/	,'Cliente',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	// TRCell():New(oSection1,"DIR_ENT"	  	,/*Tabela*/	,'Direccion Entreg',,60,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)

	oSection1:Cell('ESTADO'):SetCellBreak()

	oSection2 := TRSection():New(oReport,'Report OS',{"CB7","CB8","SC9"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection2:SetHeaderBreak()
	oSection2:SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSection2,"Producto"	,'CB8','Producto',PesqPict('CB8','CB8_PROD')    ,35/*nSize*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Descripcion"  ,'CB7','Descripcion',PesqPict('SB1','B1_DESC')   ,100 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Almacen"  ,'CB7','Almacen',PesqPict('CB8','CB8_LOCAL')   ,8 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"UM"     ,'SB1','UM',PesqPict('CB8','B1_UM')   ,5 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Ctd_Original"	,'SC9','Ctd_Original',"@E 9,999,999",10 ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",.T./*lLineBreak*/,,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Ctd_Separar"	,'SC9','Ctd_Separar',"@E 9,999,999",10 ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Ubic_1"	,'SB1','Ubic_1',PesqPict('SB1','B1_XUBICA1')   ,30 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection2,"Ubic_2"	,'SB1','Ubic_2',PesqPict('SB1','B1_XUBICA2')   ,30 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

	oSection3 := TRSection():New(oReport,,,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	 oSection3:SetLineStyle() //Define a impressao da secao em linha
	 oSection3:SetReadOnly()
	TRCell():New(oSection3,"OBS"	,,'',,200,/*lPixel*/,/*{|| "OBS:" }*/,/*cAlign*/,.F./*lLineBreak*/ ,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

	oSection2:SetPageBreak(.T.)
	oSection3:SetPageBreak(.T.)
	oSection1:SetNoFilter({"CB7"})	
	oSection2:SetNoFilter({"CB7","CB8","SC9"})
Return(oReport)


Static Function ReportPrint(oReport,cAliasQry)

	Local _cAliOS  := GetNextAlias()
	Local  aSvAlias     := GetArea()
	Local  aSvCB7       := CB7->(GetArea())
	Local  aSvCB8       := CB8->(GetArea())
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	Local oSection3	:= oReport:Section(3)
	Local cQueryOS := ""
	Local cOrdSep 	 := ""
	Local cPedido 	 := ""
	Local cPedidoEnc := ""
	Local cCliente	 := ""
	Local cLoja   	 := ""
	Local cNota   	 := ""
	Local cOP     	 := ""
	Local cStatus 	 := ""
	Local lCon       := .T.

	oSection2:Cell("Producto"):SetSize(40)
	oSection2:Cell("Descripcion"):SetSize(75)
	oSection2:Cell("Almacen"):SetSize(13)
	oSection2:Cell("UM"):SetSize(04)
	oSection2:Cell("Ctd_Original"):SetSize(18)
	oSection2:Cell("Ctd_Separar"):SetSize(18)
	oSection2:Cell("Ubic_1"):SetSize(25)
	oSection2:Cell("Ubic_2"):SetSize(15)

	
	oReport:nLineHeight	:= 40 // Define a altura da linha.

	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtragem do relatório                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CB7")
	// dbSetOrder(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// oReport:Section(1):BeginQuery()
	oSection1:BeginQuery()
	BeginSql Alias cAliasQry
		SELECT
			CB7_ORDSEP,
			CB7_STATUS,
			CB7_PEDIDO,
			CB7_CLIENT,
			CB7_LOJA,
			CB7_NOTA,
			CB7_OP
		FROM
			%Table:CB7% CB7
		WHERE
			CB7.D_E_L_E_T_ = ''
			AND CB7_ORDSEP >= %Exp:mv_par01%
			AND CB7_ORDSEP <= %Exp:mv_par02%

			AND CB7_DTEMIS >= %Exp:mv_par03%
			AND CB7_DTEMIS <= %Exp:mv_par04%
		
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

	TRPosition():New(oSection1,"CB7",1,{|| xFilial("CB7")+(cAliasQry)->CB7_ORDSEP })


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasQry)
	

	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

		If mv_par05 == 2 .and. (cAliasQry)->CB7_STATUS $ "2|4|9" // Nao Considera as Ordens ja encerradas
			(cAliasQry)->(DbSkip())
			Loop
		Endif

		oReport:SetMeter(CB7->(LastRec()))
		oSection1:Init()
		oSection2:Init()
		oSection3:Init()

		cOrdSep 	 := Alltrim((cAliasQry)->CB7_ORDSEP)
		cPedido 	 := Alltrim((cAliasQry)->CB7_PEDIDO)
		cPedidoEnc   := Alltrim((cAliasQry)->CB7_PEDIDO)
		cCliente	 := Alltrim((cAliasQry)->CB7_CLIENT)
		cLoja   	 := Alltrim((cAliasQry)->CB7_LOJA)
		cNota   	 := Alltrim((cAliasQry)->CB7_NOTA)
		cOP     	 := Alltrim((cAliasQry)->CB7_OP)
		cStatus 	 := RetStatus((cAliasQry)->CB7_STATUS)

		If Len(Alltrim(cPedido))<1

			CB8->(DbSetOrder(1))
			CB8->(DbSeek(xFilial("CB8")+cOrdSep))			
			cPedido := Alltrim(CB8->CB8_PEDIDO)
			cPedidoEnc := cPedido

		Endif


		cCliEntr := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_CLIENT")
		cCliLoj  := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_LOJAENT")
		cCliName := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XNOME"))
		cClidrec := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XENDENT"))
		cCliDepa := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XESTNOM"))
		cCliMunc := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMUN"))
		cOrdenC := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XORCOMP"))
		


		oSection1:Cell("NUMERO"):SetValue("   "+cOrdSep)
		oSection1:Cell("ESTADO"):SetValue(RetStatus(cStatus))
		oSection1:Cell("CLIENTE"):SetValue(Alltrim(cCliEntr)+" - "+"Tienda: "+Alltrim(cCliLoj)+" - "+cCliName+"   Direccion Entrega: "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc))
		oSection1:Cell("PV"):SetValue("   "+cPedido)
		oSection1:Cell("OC"):SetValue("   "+cOrdenC)
		// oSection1:Cell("DIR_ENT"):SetValue("   "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc))

		oReport:oPage:SetPageNumber(1)
		oReport:SetTitle('Orden de separacion Nro '+cOrdSep)
		oSection1:PrintLine()
		oReport:IncMeter()

		oReport:nLineHeight	:= 50 // Define a altura da linha. 
		


		cQueryOS := " SELECT CB8_FILIAL, CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_DESC, B1_UM, B1_XUBICA1, B1_XUBICA2, CB8_LOCAL, CB8_LCALIZ,CB8_LOTECT, CB8_NUMLOT,"
		cQueryOS += " SUM(CB8_QTDORI) AS CB8_QTDORI, SUM(CB8_SALDOS) AS CB8_SALDOS, SUM(CB8_SALDOE) AS CB8_SALDOE FROM "+ RetSqlName("CB8") +" CB8"
		cQueryOS += " INNER JOIN "+ RetSqlName("SB1") + " SB1 ON CB8_PROD = B1_COD AND SB1.D_E_L_E_T_ <> '*' "
		cQueryOS += " WHERE CB8_ORDSEP = '" + cOrdSep + "' AND CB8.D_E_L_E_T_ <>'*' "
		cQueryOS += " GROUP BY CB8_FILIAL, CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_DESC, B1_UM, B1_XUBICA1, B1_XUBICA2, CB8_LOCAL, CB8_LCALIZ, CB8_LOTECT, CB8_NUMLOT, "
		cQueryOS += " CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_XUBICA1, B1_XUBICA2"
		cQueryOS += " ORDER BY CB8_FILIAL, B1_XUBICA1, B1_XUBICA2
		cQueryOS := ChangeQuery(cQueryOS)
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQueryOS), _cAliOS, .F., .T.)

		While ! (_cAliOS)->(EOF())


			oSection2:Cell("Producto"    ):SetValue((_cAliOS)->CB8_PROD)
			oSection2:Cell("Descripcion"   ):SetValue((_cAliOS)->B1_DESC)
			oSection2:Cell("Almacen"    ):SetValue((_cAliOS)->CB8_LOCAL)
			oSection2:Cell("UM"    ):SetValue((_cAliOS)->B1_UM)
			oSection2:Cell("Ctd_Original"    ):SetValue((_cAliOS)->CB8_QTDORI)
			oSection2:Cell("Ctd_Separar"    ):SetValue((_cAliOS)->CB8_SALDOS)
			oSection2:Cell("Ubic_1"    ):SetValue((_cAliOS)->B1_XUBICA1)
			oSection2:Cell("Ubic_2"    ):SetValue((_cAliOS)->B1_XUBICA2)

			oSection2:PrintLine()
			If lCon 
				oSection3:Cell("OBS"):SetValue("OBS:_____________________________________________________________________________________________________________________________________________")
				lCon := .F.
			else
				 oReport:SkipLine()
				oSection3:Cell("OBS"):SetValue("OBS:_____________________________________________________________________________________________________________________________________________")
			EndIf
			oSection3:PrintLine()
			(_cAliOS)->(DbSkip())
		EndDo


		lCon := .T.
		oReport:EndPage() //-- Salta Pagina
		(_cAliOS)->(dbCloseArea())
		(cAliasQry)->(dbSkip())

		oSection3:Finish()
		oSection2:Finish()
		oSection1:Finish()
	
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea( aSvCB7 )
	RestArea( aSvCB8 )
	RestArea( aSvAlias )
Return



Static Function RetStatus(cStatus)
	Local cDescri:= cStatus

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
