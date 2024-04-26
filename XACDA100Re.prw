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
	Local oSection1, oSection3, oSection4
	Local cAliasQry 	:= GetNextAlias()

	oReport := TReport():New("ACDA100RE_"+Time(),"Orden de Separación","ACD100", {|oReport| ReportPrint(oReport,cAliasQry)},"Generación de informe de Ordenes de Separación")

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

	oSection1 := TRSection():New(oReport,'Report OS',{"CB7"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSection1,"NUMERO"	  	,/*Tabela*/	,'Orden de Separacion',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"PV"	  	,/*Tabela*/	,'Pedido de Venta',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"OC"	  	,/*Tabela*/	,'Orden de Compra',,30,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"ESTADO"	  	,/*Tabela*/	,'Estatus',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(oSection1,"CLIENTE"	  	,/*Tabela*/	,'Direccion Entrega',,200,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	// TRCell():New(oSection1,"DIR_ENT"	  	,/*Tabela*/	,'Direccion Entreg',,60,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)

	oSection1:Cell('ESTADO'):SetCellBreak()

	oSection2 := TRSection():New(oReport,,,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection2:SetLineStyle() //Define a impressao da secao em linha
	oSection2:SetReadOnly()
	TRCell():New(oSection2,"MENSAJE"	,,'',,200,/*lPixel*/,/*{|| "OBS:" }*/,/*cAlign*/,.F./*lLineBreak*/ ,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)


	oSection3 := TRSection():New(oReport,'Report OS',{"CB7","CB8","SC9"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection3:SetHeaderBreak()
	oSection3:SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRCell():New(oSection3,"Producto"	,'CB8','Product',PesqPict('CB8','CB8_PROD')    ,35/*nSize*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Descripcion"  ,'CB7','Descripcion',PesqPict('SB1','B1_DESC')   ,100 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Almacen"  ,'CB7','Almacen',PesqPict('CB8','CB8_LOCAL')   ,8 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"UM"     ,'SB1','UM',PesqPict('CB8','B1_UM')   ,5 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Ctd_Original"	,'SC9','Ctd_Original',"@E 9,999,999",10 ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",.T./*lLineBreak*/,,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Ctd_Separar"	,'SC9','Ctd_Separar',"@E 9,999,999",10 ,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Ubic_1"	,'SB1','Ubic_1',PesqPict('SB1','B1_XUBICA1')   ,30 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
	TRCell():New(oSection3,"Ubic_2"	,'SB1','Ubic_2',PesqPict('SB1','B1_XUBICA2')   ,30 ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

	oSection4 := TRSection():New(oReport,,,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection4:SetLineStyle() //Define a impressao da secao em linha
	oSection4:SetReadOnly()
	TRCell():New(oSection4,"OBS"	,,'',,200,/*lPixel*/,/*{|| "OBS:" }*/,/*cAlign*/,.F./*lLineBreak*/ ,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

	oSection3:SetPageBreak(.T.)
	oSection4:SetPageBreak(.T.)
	oSection1:SetNoFilter({"CB7"})	
	oSection3:SetNoFilter({"CB7","CB8","SC9"})
Return(oReport)


Static Function ReportPrint(oReport,cAliasQry)

	Local _cAliOS  := GetNextAlias()
	Local  aSvAlias     := GetArea()
	Local  aSvCB7       := CB7->(GetArea())
	Local  aSvCB8       := CB8->(GetArea())
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	Local oSection3	:= oReport:Section(3)
	Local oSection4	:= oReport:Section(4)
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
	Local cMensaje	 := "" 
	Local cMennint	 := "" 
	Local i 		:= 0
	Local lValSer := SuperGetMV("MV_VALSER",.F.,.F.)

	oSection3:Cell("Producto"):SetSize(40)
	oSection3:Cell("Descripcion"):SetSize(75)
	oSection3:Cell("Almacen"):SetSize(13)
	oSection3:Cell("UM"):SetSize(04)
	oSection3:Cell("Ctd_Original"):SetSize(18)
	oSection3:Cell("Ctd_Separar"):SetSize(18)
	oSection3:Cell("Ubic_1"):SetSize(25)
	oSection3:Cell("Ubic_2"):SetSize(15)

	
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

		//validara que la cantidad de la orden sea igual a la de la liberación
		If !validSald(lValSer,(cAliasQry)->CB7_ORDSEP)

			MSGALERT("Se encontro inconsistencia en la orden de separación "+ (cAliasQry)->CB7_ORDSEP+", Informe al administrador.", "IMPRESIÓN ORDEN DE SEPARACIÓN" )
			(cAliasQry)->(DbSkip())
			Loop
		EndIf

		If mv_par05 == 2 .and. (cAliasQry)->CB7_STATUS $ "2|4|9" // Nao Considera as Ordens ja encerradas
			(cAliasQry)->(DbSkip())
			Loop
		Endif

		oReport:SetMeter(CB7->(LastRec()))
		oSection1:Init()
		oSection2:Init()
		oSection3:Init()
		oSection4:Init()

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
		cOrdenC  := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XORCOMP"))
		cMensaje := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMENINT"))
		cMennint := ""

		cMennint = zMemoToA(cMensaje,70)
		


		oSection1:Cell("NUMERO"):SetValue("   "+cOrdSep)
		oSection1:Cell("ESTADO"):SetValue(RetStatus(cStatus)+"                     Cliente: "+Alltrim(cCliEntr)+" - "+"Tienda: "+Alltrim(cCliLoj)+" - "+cCliName)
		oSection1:Cell("CLIENTE"):SetValue("   "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc))
		oSection1:Cell("PV"):SetValue("   "+cPedido)
		oSection1:Cell("OC"):SetValue("   "+cOrdenC)


		// oSection1:Cell("DIR_ENT"):SetValue("   "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc))

		oReport:oPage:SetPageNumber(1)
		oReport:SetTitle('Orden de separacion Nro '+cOrdSep)
		oSection1:PrintLine()

		

		if (LEN(cMennint)<>0)

			oReport:nLineHeight	:= 23 // Define a altura da linha. 
			// oSection2:Cell("MENSAJE"):SetValue(AllTrim(cMensaje))
			// 		// oReport:SkipLine()	
			// oSection2:PrintLine()
			for i := 1 to Len(cMennint)
				if(Len(AllTrim(cMennint[i])))>0
					oSection2:Cell("MENSAJE"):SetValue(AllTrim(cMennint[i]))
					// oReport:SkipLine()	
					oSection2:PrintLine()
				EndIf
			next

		EndIf

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


			oSection3:Cell("Producto"    ):SetValue((_cAliOS)->CB8_PROD)
			oSection3:Cell("Descripcion"   ):SetValue((_cAliOS)->B1_DESC)
			oSection3:Cell("Almacen"    ):SetValue((_cAliOS)->CB8_LOCAL)
			oSection3:Cell("UM"    ):SetValue((_cAliOS)->B1_UM)
			oSection3:Cell("Ctd_Original"    ):SetValue((_cAliOS)->CB8_QTDORI)
			oSection3:Cell("Ctd_Separar"    ):SetValue((_cAliOS)->CB8_SALDOS)
			oSection3:Cell("Ubic_1"    ):SetValue((_cAliOS)->B1_XUBICA1)
			oSection3:Cell("Ubic_2"    ):SetValue((_cAliOS)->B1_XUBICA2)

			oSection3:PrintLine()
			If lCon 
				oSection4:Cell("OBS"):SetValue("OBS:_____________________________________________________________________________________________________________________________________________")
				lCon := .F.
			else
				 oReport:SkipLine()
				oSection4:Cell("OBS"):SetValue("OBS:_____________________________________________________________________________________________________________________________________________")
			EndIf
			oSection4:PrintLine()
			(_cAliOS)->(DbSkip())
		EndDo


		lCon := .T.
		oReport:EndPage() //-- Salta Pagina
		(_cAliOS)->(dbCloseArea())
		(cAliasQry)->(dbSkip())

		oSection4:Finish()
		oSection3:Finish()
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


Static Function zMemoToA(cTexto, nMaxCol, cQuebra, lTiraBra)
	Local aTexto    := {}
	Local aAux      := {}
	Local nAtu      := 0
	Default cTexto  := ''
	Default nMaxCol := 60
	Default cQuebra := ';'
	Default lTiraBra:= .T.

	//Quebrando o Array, conforme -Enter-
	aAux:= StrTokArr(cTexto,Chr(13))

	//Correndo o Array e retirando o tabulamento
	For nAtu:=1 TO Len(aAux)
		aAux[nAtu]:=StrTran(aAux[nAtu],Chr(10),'')
	Next

	//Correndo as linhas quebradas
	For nAtu:=1 To Len(aAux)

		//Se o tamanho de Texto, for maior que o número de colunas
		If (Len(aAux[nAtu]) > nMaxCol)

			//Enquanto o Tamanho for Maior
			While (Len(aAux[nAtu]) > nMaxCol)
				//Pegando a quebra conforme texto por parâmetro
				nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))

				//Caso não tenha, a última posição será o último espaço em branco encontrado
				If nUltPos == 0
					nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
				EndIf

				//Se não encontrar espaço em branco, a última posição será a coluna máxima
				If(nUltPos==0)
					nUltPos:=nMaxCol
				EndIf

				//Adicionando Parte da Sring (de 1 até a Úlima posição válida)
				aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))

				//Quebrando o resto da String
				aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
			EndDo

			//Adicionando o que sobrou
			aAdd(aTexto,aAux[nAtu])
		Else
			//Se for menor que o Máximo de colunas, adiciona o texto
			aAdd(aTexto,aAux[nAtu])
		EndIf
	Next

	//Se for para tirar os brancos
	If lTiraBra
		//Percorrendo as linhas do texto e aplica o AllTrim
		For nAtu:=1 To Len(aTexto)
			aTexto[nAtu] := Alltrim(aTexto[nAtu])
		Next
	EndIf
Return aTexto

static function validSald(lValSer,cOrdSep)
Local _cAliOS  := GetNextAlias()
Local aArea    := GetArea()
Local aSvSC9	:= SC9->(GetArea())
Local aSvCB8	:= CB8->(GetArea())
Local lRet := .T.
Local cQueryOS := ""

	If lValSer
	
		cQueryOS := " SELECT CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, CB8_LOCAL, CB8_LCALIZ, CB8_SEQUEN, CB8_ITEM,"
		cQueryOS += " SUM(CB8_QTDORI) AS CB8_QTDORI FROM "+ RetSqlName("CB8") +" CB8"
		cQueryOS += " INNER JOIN "+ RetSqlName("SB1") + " SB1 ON CB8_PROD = B1_COD AND SB1.D_E_L_E_T_ <> '*' "
		cQueryOS += " WHERE CB8_ORDSEP = '" + cOrdSep + "' AND CB8.D_E_L_E_T_ <>'*' "
		cQueryOS += " GROUP BY CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, CB8_LOCAL, CB8_LCALIZ, CB8_SEQUEN, CB8_ITEM"
		cQueryOS := ChangeQuery(cQueryOS)
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQueryOS), _cAliOS, .F., .T.)

		While ! (_cAliOS)->(EOF())

			_cAQuer := " SELECT C9_QTDLIB FROM  "+RetSQLName('SC9')+" SC9 "
			_cAQuer += " WHERE SC9.D_E_L_E_T_ <> '*' "
			_cAQuer += " AND SC9.C9_ORDSEP='"+(_cAliOS)->CB8_ORDSEP+"' "
			_cAQuer += " AND SC9.C9_PEDIDO='"+(_cAliOS)->CB8_PEDIDO+"' "
			_cAQuer += " AND SC9.C9_PRODUTO='"+(_cAliOS)->CB8_PROD+"' "
			_cAQuer += " AND SC9.C9_LOCAL='"+(_cAliOS)->CB8_LOCAL+"' "
			_cAQuer += " AND SC9.C9_ITEM='"+(_cAliOS)->CB8_ITEM+"' "
			_cAQuer += " AND SC9.C9_SEQUEN='"+(_cAliOS)->CB8_SEQUEN+"' "
			_cAQuer += " AND SC9.C9_REMITO=' ' "

			TcQuery _cAQuer New Alias "_aQR"
			dbSelectArea("_aQR")
			While !_aQR->(EOF())

			    If (_cAliOS)->CB8_QTDORI != _aQR->C9_QTDLIB
					lRet := .F.
				EndIf

				_aQR->(dbSkip())
			EndDo
			_aQR->(dbCloseArea())


			(_cAliOS)->(DbSkip())
		EndDo
		(_cAliOS)->(dbCloseArea())

		U_ACD166DH()

	EndIf

RestArea(aSvSC9)
RestArea(aSvCB8)    
RestArea(aArea)
return lRet
