#include 'totvs.ch'
#include 'rptdef.ch'
#include 'rwmake.ch'
#include 'FWPrintSetup.ch'
#include 'FWMVCDEF.CH'
#include 'AcmeDef.ch'
#include 'TOPCONN.CH'

/*
+---------------------------------------------------------------------------+
| Programa  #    ACMRP1A       |Autor  |                |Fecha |  |
+---------------------------------------------------------------------------+
| Desc.     #  Función  Remision de salida de Productos DESPACHO A CLIENTES |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # u_ACMRP2A()                                                   |
+---------------------------------------------------------------------------+
*/
User Function PRGRMTO()
	//Local cQryBw, cArqTrb			:= ""
	Local cAliasTMP					:= GetNextAlias()
	Local oTempTable 
	Local aStrut					:= {}
	Local aCampos					:= {}
	
	//Local aSeek						:= {}
	Local aIndexSF2					:= {}
	Private opcionmark				:= 0
	Private cMarca					:= cValToChar(Randomize(10,99))
	Private cFiltro					:= ""
	Private cRealNames				:= ""
	fFilAcm2(@cFiltro)
	Private cCadastro 				:= ""
	if MV_PAR01 ==1
		cCadastro 				:= "Generación de PDF de Remisiones de Salida"
	elseif MV_PAR01 ==2
		cCadastro 				:= "Generación de PDF de Remisiones de Salida con Total"
	endif
	
	
	
	If EMPTY(cFiltro)
		Return
	EndIf

	//--------------------------
	//Crear Campos Temporales
	//--------------------------

	AAdd( aStrut,{ "F2OK"			,"C",02						,0	} ) //01
	AAdd( aStrut,{ "F2CLIENTE"		,"C",TamSX3("F2_CLIENTE")[1],0	} ) //02
	AAdd( aStrut,{ "F2LOJA"			,"C",TamSX3("F2_LOJA")[1]	,0	} ) //03
	AAdd( aStrut,{ "F2NOME"			,"C",TamSX3("A1_NOME")[1]	,0	} ) //04
	AAdd( aStrut,{ "F2SERIE"		,"C",TamSX3("F2_SERIE")[1]	,0	} ) //05
	AAdd( aStrut,{ "F2DOC"			,"C",TamSX3("F2_DOC")[1]	,2	} ) //06
	AAdd( aStrut,{ "F2DTDIGIT"		,"D",TamSX3("F2_DTDIGIT")[1],0	} ) //07
	AAdd( aStrut,{ "F2EMISSAO"		,"D",TamSX3("F2_EMISSAO")[1],0	} ) //07
	
	oTempTable := FWTemporaryTable():New( cAliasTMP )
	oTemptable:SetFields( aStrut )
	oTempTable:AddIndex("indice1", {"F2CLIENTE"} ) 
	oTempTable:AddIndex("indice2", {"F2SERIE", "F2DOC"} ) 
	oTempTable:Create()

	//------------------------------------
	//Executa query para RELLENADO da tabla temporal
	//------------------------------------
	
	//alert(oTempTable:GetRealName())
	
	cQryBw  := " INSERT INTO "+ oTempTable:GetRealName()
	cQryBw  += " (F2CLIENTE, F2LOJA, F2NOME, F2SERIE, "
	cQryBw  += " F2DOC, F2DTDIGIT, F2EMISSAO ) "
	cQryBw	+= " SELECT "
	cQryBw	+= " F2_CLIENTE AS F2CLIENTE,"
	cQryBw	+= " F2_LOJA  AS F2LOJA, "
	cQryBw	+= " A1_NOME  AS F2NOME, "
	cQryBw	+= " F2_SERIE AS F2SERIE,"
	cQryBw	+= " F2_DOC AS F2DOC, "
	cQryBw	+= " F2_DTDIGIT AS  F2DTDIGIT,"
	cQryBw	+= " F2_EMISSAO AS F2EMISSAO" 												+ CRLF
	cQryBw	+= " FROM "			+ InitSqlName("SF2") +" SF2 " 							+ CRLF
	cQryBw	+= " INNER JOIN "				+ InitSqlName("SA1") +" SA1 ON " 			+ CRLF
	cQryBw	+= " SA1.D_E_L_E_T_<>'*' AND SA1.A1_LOJA = SF2.F2_LOJA AND "  				+ CRLF 
	cQryBw	+= " A1_FILIAL='"				+xFilial("SA1")+"' AND  " 					+ CRLF
	cQryBw	+= " A1_COD=F2_CLIENTE "													+ CRLF
	cQryBw	+= " WHERE " 																+ CRLF
	If MV_PAR01==1 .OR. MV_PAR01==2
		cQryBw	+= " (SF2.F2_ESPECIE='RFN ' OR SF2.F2_ESPECIE='RTF ' ) AND  "			+ CRLF
	EndIf
	cQryBw	+= " (F2_DOC     between '"+MV_PAR05+"' AND '"+MV_PAR06+"') AND "			+ CRLF
	// cQryBw	+= " (F2_SERIE   between '"+MV_PAR05+"' AND '"+MV_PAR06+"') AND " 			+ CRLF
	cQryBw	+= " (F2_CLIENTE between '"+MV_PAR07+"' AND '"+MV_PAR08+"') AND "			+ CRLF
	cQryBw	+= " (F2_LOJA    between '"+MV_PAR09+"' AND '"+MV_PAR10+"') AND " 			+ CRLF
	cQryBw	+= " (F2_DTDIGIT between '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' ) AND " + CRLF
	cQryBw	+= " SF2.D_E_L_E_T_<>'*' AND " 												+ CRLF
	cQryBw	+= " SF2.F2_DOC IN (SELECT C9_REMITO FROM "+ InitSqlName("SC9") +" WHERE D_E_L_E_T_<> '*' AND C9_REMITO=F2_DOC) AND " + CRLF
	cQryBw	+= " F2_FILIAL='"+xFilial("SF2")+"' " 										+ CRLF

	TcSqlExec(cQryBw)
	
	aCampos := {}
	AAdd( aCampos,{ "F2CLIENTE"		,"C","Cliente"		    ,"@!S"+cValToChar(TamSX3("F2_CLIENTE")[1])		,"0"	} )
	AAdd( aCampos,{ "F2LOJA"		,"C","No.Tienda"		,"@!S"+cValToChar(TamSX3("F2_LOJA")[1])			,"0"	} )
	AAdd( aCampos,{ "F2NOME"		,"C","Nombre"			,"@!S"+cValToChar(TamSX3("A1_NOME")[1])			,"0"	} )
	AAdd( aCampos,{ "F2SERIE"		,"C","Serie"			,"@!S"+cValToChar(TamSX3("F2_SERIE")[1])		,"0"	} )
	AAdd( aCampos,{ "F2DOC"			,"C","Documento"		,"@!S"+cValToChar(TamSX3("F2_DOC")[1]	)		,"0"	} )
	AAdd( aCampos,{ "F2DTDIGIT"		,"D","Digitacion"		,"@!S"+cValToChar(TamSX3("F2_DTDIGIT")[1])		,"0"	} )
	AAdd( aCampos,{ "F2EMISSAO"		,"D","Emisión"			,"@!S"+cValToChar(TamSX3("F2_EMISSAO")[1])		,"0"	} )

	aRotina := {{"Genera PDFs "		, 	'U_ACMRP2B()',	0,3}}
	AADD( aRotina,{"[Marcar/Desmarcar todo", 	'U_fmarkall()',	0,3})
	//AAdd(aRotina,{"[Descarmar todo", 	'U_fdesmarkall()',	0,3})



	cRealAlias:=oTempTable:GetAlias()
	cRealNames:=oTempTable:GetRealName()
	dbSelectArea(cRealAlias)
	dbSetOrder(1)
	cMarca:=GETMARK(,cRealAlias,"F2OK")
	cFiltroSF2 	:= ''
	bFiltraBrw	:=	{|| FilBrowse(cRealAlias,@aIndexSF2,cFiltroSF2)}
	Eval( bFiltraBrw )
	MarkBrow(cRealAlias,"F2OK",,aCampos,.F.,cMarca)
	EndFilBrw(cRealAlias,@aIndexSF2)
	dbCloseArea(cRealAlias)
	oTempTable:Delete()
	
Return 

// Funciones para seleccionar o desmarcar todos los items 
User Function fmarkall()
	Local cant_mark_all     := 0
	Local cant_desmark_all  := 0
	Local count_item 	:= 0

	(cRealAlias)->(DbGoTop())
	While (cRealAlias)->(!EOF())
		count_item++
		If EMPTY((cRealAlias)->F2OK)
			cant_desmark_all++
		elseif !EMPTY((cRealAlias)->F2OK)
			cant_mark_all++
		EndIf
		(cRealAlias)->(DbSkip())
	End

	If count_item == cant_desmark_all   // Todos desmarcados
		opcionmark = 0  
	ElseIf count_item == cant_mark_all // Todos marcados
		opcionmark = 1
	EndIf
	
	// reinicio conteo
	cant_mark_all     	= 0
	cant_desmark_all 	= 0
	count_item 		= 0
		
	If opcionmark == 0
		(cRealAlias)->(DbGoTop())
		While (cRealAlias)->(!EOF())
			If EMPTY((cRealAlias)->F2OK)
				(cRealAlias)->F2OK :=cMarca
			EndIf
			(cRealAlias)->(DbSkip())
		End	
		opcionmark := 1
	elseif opcionmark == 1
		(cRealAlias)->(DbGoTop())
		While (cRealAlias)->(!EOF())
			If !EMPTY((cRealAlias)->F2OK)
				(cRealAlias)->F2OK :=''
			EndIf
			(cRealAlias)->(DbSkip())
		End
		opcionmark := 0
	EndIf
Return 
/* User Function fdesmarkall()
	//Local nRecno := (cRealAlias)->(Recno())
	//Local lbandera := .T.
	(cRealAlias)->(DbGoTop())
	While (cRealAlias)->(!EOF())
		If !EMPTY((cRealAlias)->F2OK)
			(cRealAlias)->F2OK :=''
		EndIf
   		(cRealAlias)->(DbSkip())
	End
Return  */


/*
+---------------------------------------------------------------------------+
| Programa  #   ACMRP2B       |Autor  |                 |Fecha |  |
+---------------------------------------------------------------------------+
| Desc.     #  Función que busca los marcados pata generar           |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # AP                                                            |
+---------------------------------------------------------------------------+
*/
User Function ACMRP2B()
	Local cAliasImp	:= GetNextAlias()

	Local cQueryMarca := " SELECT F2CLIENTE, F2LOJA, F2SERIE,  F2DOC  FROM  " + cRealNames + " F2TMP  WHERE F2OK='"+cMarca+"'"
	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQueryMarca) ,cAliasImp,.T.,.T.)
	DbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())
	While (cAliasImp)->(!EOF())
		u_ACMRP3N((cAliasImp)->F2DOC,(cAliasImp)->F2SERIE,(cAliasImp)->F2CLIENTE,(cAliasImp)->F2LOJA)
		(cAliasImp)->(DbSkip())
	EndDO
Return
/*
+---------------------------------------------------------------------------+
| Programa  #   fFilAcm2       |Autor  |       |Fecha |  |
+---------------------------------------------------------------------------+
| Desc.     #  Función que muestra grupo de preguntas al ingresar          |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # AP                                                            |
+---------------------------------------------------------------------------+
*/
Static Function fFilAcm2(cFiltro)
	Local cPerg := "ACMRP3U"
	ACMPREG1(cPerg)			// Inicializa SX1 para preguntas	
	If Pergunte(cPerg)
		cFiltro := "F2->F2_DTDIGI >='"+DTOS(MV_PAR03)+"' .AND. "
		cFiltro += "F2->F2_DTDIGI <='"+DTOS(MV_PAR04)+"' .AND. "
		// cFiltro += "F2->F2_SERIE >='"+MV_PAR05+"' .AND. "
		// cFiltro += "F2->F2_SERIE <='"+MV_PAR06+"' .AND. "
		cFiltro += "F2->F2_DOC >='"+MV_PAR05+"' .AND. "
		cFiltro += "F2->F2_DOC <='"+MV_PAR06+"' .AND."
		cFiltro += "F2->F2_CLIENTE >='"+MV_PAR07+"' .AND."	
		cFiltro += "F2->F2_CLIENTE <='"+MV_PAR08+"' .AND."	
		cFiltro += "F2->F2_LOJA >='"+MV_PAR09+"' .AND."	
		cFiltro += "F2->F2_LOJA <='"+MV_PAR10+"' "	
	Else
		cFiltro := ""
	EndIf	
Return ()
/*
+===========================================================================+
| Programa  # ACMRP3N    |Autor  |        |Fecha |   |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones                         |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_ACMRP2()                                                  |
+===========================================================================+
*/
User Function ACMRP3N(cDoc,cSerie,cCliente,cLoja)
	Local cFilName 			:= UPPER(AllTrim(cSerie)) + '_' + UPPER(AllTrim(cDoc))
	Local cQry				:= ""
	Local cPath				:= ALLTRIM(MV_PAR11)  // antes era 12
	Local nPixelX 			:= 0
	Local nPixelY 			:= 0
	Local nHPage 			:= 0
	Local nVPage 			:= 0
	Local cpedidoqry		:= ""
	Local cdocuqry 			:= ""
	Local cserieqry 		:= ""


	Private cRem			:= GetNextAlias()
	Private nFontAlto		:= 44
	Private oPrinter
	Private nLineasPag		:= 53			// <----- cantidad de lineas en el GRID
	Private nPagNum			:= 0
	Private nItemRegistro	:= 0			// Item del Registro
	Private oCouNew10		:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	Private oCouNew10N		:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	Private oArial10 		:= TFont():New("Arial"		,10,10,,.F.,,,,.T.,.F.)
	Private oArial12 		:= TFont():New("Arial"		,12,12,,.F.,,,,.T.,.F.)
	Private oArial12N		:= TFont():New("Arial"      ,12,12,,.T.,,,,.F.,.F.)
	Private oArial14N		:= TFont():New("Arial"      ,14,14,,.T.,,,,.F.,.F.)
	Private VarCliente		:= cCliente
	Private cF2_MOEDA 		:= 0
	Private cE99formato		:= ""

	Default cDoc			:= '0000000000000'
	Default cSerie			:= 'AAA'
	Default cCliente		:= '0000000000001'
	Default cLoja			:= '01'
	
	cQry			:= 	TipoQuery(MV_PAR01,cDoc,cSerie, cCliente,cLoja )
	//cQry		:= RQuery(cDoc,cSerie,cCliente,cLoja)

	

	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQry) ,cRem,.T.,.T.)
	DbSelectArea(cRem)
	(cRem)->(DbGoTop())




	If Empty((cRem)->F2_DOC)
		MsgAlert("La remision seleccionada no puede ser Impresa, dado que algunos datos relacionados fueron eliminados, Revise la existencia de los Producto, del Cliente, de los maestros.")
		Return
	EndIf
	
	if MV_PAR01==2
		cFilName 			:= UPPER(AllTrim(cSerie)) + '-vlr_' + UPPER(AllTrim(cDoc))
	endif
	// FWMsPrinter(): New( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
	oPrinter:= FWMsPrinter():New(cFilName+".PDF",IMP_PDF,.T.,cPath,.T.,.T.,,,.T.,,,.T.,)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_LETTER)
	oPrinter:cPathPDF:= cPath
	//oPrinter:SetPaperSize(0,133.993,203.08) // Mitad tamaÃ±o carta

	nPixelX := oPrinter:nLogPixelX()
	nPixelY := oPrinter:nLogPixelY()

	nHPage := oPrinter:nHorzRes()
	nHPage *= (300/nPixelX)
	nVPage := oPrinter:nVertRes()
	nVPage *= (300/nPixelY)

	nPagNum	:= 0
	oPrinter:StartPage()

	cpedidoqry	:= Alltrim((cRem)->D2_PEDIDO)
	cdocuqry 	:= AllTrim((cRem)->F2_DOC)
	cserieqry 	:= AllTrim((cRem)->F2_SERIE)
	cF2_MOEDA 	:= (cRem)->F2_MOEDA




	Private qryclientre  := "qryclientre"
	Private VW_OTRR := "VW_OTRR"

	QueryclienteN(cCliente)  // query para cliente factura
	Qclie(cCliente,cpedidoqry)   // query para clientre entrega

	AcmHeadPR() //[cabecero]

	
	VW_OTRR->(DbCloseArea())
	
	QryLotSer(cpedidoqry,cdocuqry,cserieqry) // query para serie y lote
	

	Private cQueryx 		:= "cQueryx"
	(cQueryx)->(DbGoTop())

	AcmDtaiPR() // [detalle]

	cQueryx->(DbCloseArea())
	

	AcmFootPR() // [pie de pagina]
	qryclientre->(DbCloseArea())

	oPrinter:EndPage()
	oPrinter:Print()
	FreeObj(oPrinter)
	(cRem)->(DbCloseArea())

Return
/*
+===========================================================================+
| Programa  # AcmHeadPR    |Autor  |       |Fecha |      |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones EMCABEZADO              |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_AcmHeadPR()                                               |
+===========================================================================+
*/
Static Function AcmHeadPR()

	Local cEmisor	   	:= Alltrim(SM0->M0_NOMECOM)
	Local cRfc			:= Alltrim(SM0->M0_CGC)

	//Local cCalle		:= Alltrim(SM0->M0_ENDENT)
	//Local cTelf			:= Alltrim(SM0->M0_TEL)
	Local cFileLogo		:= GetSrvProfString("Startpath","") + "xlogox.bmp"
	Local n1Linea		:= 10
	local nMargIqz		:= 10
	local nLinea		:= 1
	Local nMargDer		:= 2400-10
	//Local cSerIMP		:= (cRem)->F2_SERIE   // 
	Local cDocIMP		:= (cRem)->F2_DOC
	//Local cDT_IMP		:= (cRem)->F2_DTDIGIT
	
	//Local cHorIMP		:= ""
	
	Local dfecha 		:= Date()
	Local cfecha 		:= DTOC(dfecha)
 	//Local cResIMP		:= ""
	//Local cTipoRem		:= AcmeTitRemS

	Private cDir_entreg 	:= (cRem)->C5_XENDENT
	Private cCod_dpto_entre := (cRem)->C5_XEST
	Private cCod_mun_entreg := ""//(cRem)->C5_XCOD_MU
	Private cDpto_entrega 	:= ""
	Private cMun_entrega	:= (cRem)->C5_XMUN

	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial()+'12'+cCod_dpto_entre)

	cDpto_entrega 	= SX5->X5_DESCSPA

	// dbSelectArea("CC2")
	// dbSetOrder(1)
	// dbSeek(xFilial()+cCod_dpto_entre+cCod_mun_entreg)

	// cMun_entrega	= CC2->CC2_MUN
	

	nPagNum++
	cRfc := substr(cRfc,1,3)+"."+substr(cRfc,4,3)+"."+substr(cRfc,7,3)+"-"+substr(cRfc,10,1)
				oPrinter:SayBitmap(-10,10,cFileLogo,500,200)  // Logo
				//oPrinter:SayBitmap(-80,10,"C:\TOTVS\PROGEN\Facturacion\Formatos\logoprogen.png",400,400)  // Logo
	            oPrinter:Say(n1Linea					,2140			, AcmePagina + STRZERO(nPagNum,3)	,	oArial12,,,,2)
				oPrinter:Box(n1Linea+(nFontAlto*nLinea)-5,nMargIqz+1490,(n1Linea+(nFontAlto*nLinea))*6.7,1840,"-8")
				oPrinter:Box(n1Linea+(nFontAlto*nLinea)-5,1840,(n1Linea+(nFontAlto*nLinea))*6.7,2250,"-8")
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, "REMISION   "						,	oArial14N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, cDocIMP						    ,	oArial14N,,,,2)					
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, "Num. orden" 					    ,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, (cRem)->C5_XORCOMP				,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, AcmeFechaEla 						,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, fecha((cRem)->D2_EMISSAO," ")		,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, "Fecha actual:" 					,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, cfecha							,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, "Metodo transporte "				,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, "Terrestre"						,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, AcmePEDIDO						,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1900	, (cRem)->D2_PEDIDO					,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	// DIRECCIONES DE CLIENTES FACTURA
	nLinea ++
	nLinea ++ 	
	nLinea ++;	oPrinter:Box(n1Linea+(nFontAlto*nLinea)-10,1150,(n1Linea+(nFontAlto*nLinea))+250,2250,"-8")
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1150	, "DIR DE FACTURA"									,	oArial12N,,,,2)		
	//nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1150	, Alltrim(VW_OTRR->A1_NOME)							,	oArial12,,,,2)
	//nLinea+=0.5
	nLinea+=ImpMemo(oPrinter,zMemoToA(Alltrim(Alltrim(VW_OTRR->A1_NOME)), 55)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+1150, 2200  	, nFontAlto	, oArial12	, 0			,0)
	//nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1150	, Alltrim(VW_OTRR->A1_END)							,	oArial12,,,,2)
	nLinea+=ImpMemo(oPrinter,zMemoToA(Alltrim(VW_OTRR->A1_END), 65)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+1150, 2250  	, nFontAlto	, oArial12	, 0			,0)
	nLinea-=0.5
	//nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1150	, Alltrim(VW_OTRR->A1_BAIRRO)						,	oArial12,,,,2)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1150	, Alltrim(VW_OTRR->A1_ESTADO)+" - "+Alltrim(VW_OTRR->A1_MUN),	oArial12,,,,2)
	
	nLinea :=1;

	nLinea +=3;

	nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , cEmisor							                ,	oArial12,,,,2)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , "Carrera 3 No 56-07" 	  				            ,	oArial12,,,,2)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , "Zona Industrial Cazuca Entrada No. 2" 	  	    ,	oArial12,,,,2)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , "PBX: 730 6100 DIRECTO VENTAS: 7306111" 		 	,	oArial12,,,,2)

	//DIRECCIONES DE CLIENTS ENTREGA
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , "Cliente entrega"						 	    ,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+280	    , Alltrim(qryclientre->C5_CLIENT) 	    		,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	    , "Cliente Factura" 				    		,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1730	    , (cRem)->C5_CLIENTE	    					,	oArial12,,,,2)

	nLinea ++;	oPrinter:Box(n1Linea+(nFontAlto*nLinea)-10,30,(n1Linea+(nFontAlto*nLinea))+250,1150,"-8")			
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , "DIR. ENTREGA" 		 						,	oArial12N,,,,2)
	//nLinea ++	//oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , Alltrim(qryclientre->A1_NOME) 		 		,	oArial12,,,,2) 
	//nLinea+=0.5
	nLinea+=ImpMemo(oPrinter,zMemoToA(Alltrim(qryclientre->A1_NOME), 55)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+50, 1450 	, nFontAlto	, oArial12	, 0			,0)
	nLinea+=ImpMemo(oPrinter,zMemoToA(cDir_entreg, 65)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+50, 1100  	, nFontAlto	, oArial12	, 0			,0)
	nLinea-=0.5
	//nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , cDir_entreg				 		 			,	oArial12,,,,2)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    ,AllTrim(cDpto_entrega) +" - "+ Alltrim(cMun_entrega),	oArial12,,,,2)
	//nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	    , cDpto_entrega									,	oArial12,,,,2)
	

	nLinea =	15

	if (MV_PAR01 == 1)
				oPrinter:Box((nFontAlto*16)-5	,nMargIqz+20,(nFontAlto*17),2250,"-8")
	nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "CODIGO"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1580	, "LOTE"										    ,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1830	, "DEPOSITO"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2050	, "CANTIDAD"										,	oArial12n,,,,2)
	nLinea ++;	oPrinter:Line(n1Linea+(nFontAlto*nLinea),0,n1Linea+(nFontAlto*nLinea), nMargDer,,"-8")
	nLinea +=	0.5;

	elseif MV_PAR01 ==2
				oPrinter:Box((nFontAlto*16)-5	,nMargIqz+20,(nFontAlto*17),2250,"-8")
	nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "CODIGO"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1300	, "LOTE"										    ,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1450	, "DEPOSITO"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1700	, "CANTIDAD"										,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1940	, "VALOR TOTAL"										,	oArial12n,,,,2)
	nLinea ++;	oPrinter:Line(n1Linea+(nFontAlto*nLinea),0,n1Linea+(nFontAlto*nLinea), nMargDer,,)
	nLinea +=	0.5;

	ENDIF

	
Return
/*
+===========================================================================+
| Programa  # AcmDtaiPR    |Autor  |       |Fecha |      |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones DETALLE                 |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_AcmDtaiPR()                                               |
+===========================================================================+
*/
Static Function AcmDtaiPR()
	Local n1Linea		:= 10
	local nMargIqz		:= 10
	local nLinea		:= 10
	local nLineax 		:=300
	Local Ncontador 	:= 0
	Local nCantSD2		:= 0
	Local nPrecioSC6	:= 0
	Local nPrecioTotal  := 0

	Local condPedido 	:= ""
	Local condProduto 	:= ""
	Local Cproducto 	:= ""
	Local Cresultlook 	:= ""
	Local Cremito 		:= ""
	Local Ctienda 		:= ""
	Local Cclientex 	:= ""	
	Local cflagserie	:= ""
	Local codinf 		:= ""
	Local cRemision 	:= ""
	Local texto_infad 	:= {}
	Local tex_ok		:= ""
	Local atex			:= ""

	Private aliaslookserie 		:= "aliaslookserie"
	Private AliasQcodcli		:= "AliasQcodcli"
	Private aliasmemoqry 		:= "aliasmemoqry"
	Private prodstruct 			:= "prodstruct"

	nLinea += 6.5
	if MV_PAR01 == 1 .AND. MV_PAR02==1
		While (!((cQueryx)->(EOF())) .and. MV_PAR01 == 1)

			condPedido		= (cQueryx)->D2_PEDIDO
			condProduto		= (cQueryx)->D2_COD
			Cremito			= (cQueryx)->D2_DOC
			Ctienda 		= (cQueryx)->D2_LOJA
			Cclientex 		= (cQueryx)->C6_CLI
			cRemision 		= (cQueryx)->D2_DOC

			LokforQry(condPedido,condProduto)
			Cresultlook = lokforQ->C6_NUMOP
			lokforQ->(DbCloseArea())

			//Si el resultado es vacio, es decir que no hay op, el codigo muestra los productos normales o sin estructura
			if Empty(Cresultlook)  
				cCanIMP	:= cValToChar((cQueryx)->D2_QUANT)  //change
				nLinea += 0.5;

				nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->D2_COD						,	oArial12N,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1590	, AllTrim(cQueryx->C6_LOTECTL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1880	, AllTrim(cQueryx->C6_LOCAL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2090	, 	cCanIMP								,	oArial12,,,,2)
				nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((cQueryx)->C6_DESCRI)	,	oArial12,,,,2)
				 			
				// Muestro la descripción personalizada, si el producto no tiene, no se muestra nada
				if Alltrim(cQueryx->XDESCRI) <>"" 
				//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
				nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
				nLinea += ImpMemo(oPrinter,zMemoToA("> "+Alltrim(cQueryx->XDESCRI), 80)	,(n1Linea-5)+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
				endif

				// Observacion de pieza, campo sc6 c6_vdobs
				if AllTrim((cQueryx)->C6VDOBS) <>""

					If nLinea > nLineasPag
							AcmFootPR()
							oPrinter:EndPage()
							oPrinter:StartPage()
							QueryclienteN(VarCliente)
							AcmHeadPR()
							(VW_OTRR)->(DBCLOSEAREA())
							nLinea:=17
						EndIf
				nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ cQueryx->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
				endif			

				QryCodClie(Cclientex,condProduto,Ctienda)
				// Si existe un codigo cliente se muestra por item, si no, no
				if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "							,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
					AliasQcodcli->(DBCLOSEAREA())	
				endif


				LookSerLot(condProduto,"A",cRemision)
				cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)
				//Si existen series, se imprimen para los productos que las tengan. Esto depende de la cantidad de productos del pedido
				if cflagserie <> ""
					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
						
					while (!((aliaslookserie)->(EOF())))
						Ncontador++;

						if (Ncontador>4)
							
							nLinea ++;

							Ncontador = 0
							nLineax = 300
						endif
						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
						nLineax = nLineax+250
						(aliaslookserie)->(dbSkip())

						

						If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
							AcmFootPR()
							oPrinter:EndPage()
							oPrinter:StartPage()
							QueryclienteN(VarCliente)
							AcmHeadPR()
							(VW_OTRR)->(DBCLOSEAREA())
							nLinea:=17
						EndIf	
					EndDo
				endif
				
				Ncontador = 0
				nLineax = 300
				aliaslookserie->(DBCLOSEAREA())

				(cQueryx)->(dbSkip())

				If !((cQueryx)->(EOF())) .and. nLinea > nLineasPag
					AcmFootPR()
					oPrinter:EndPage()
					oPrinter:StartPage()
					QueryclienteN(VarCliente)
					AcmHeadPR()
					(VW_OTRR)->(DBCLOSEAREA())
					nLinea:=17
				EndIf
			else   // Es un producto tipo estructura o un producto compuesto

				QryStruc(condPedido,condProduto,Cremito)
				
				//MsgAlert("Existe producto compuesto. Presion finalizar para continuar la impresion", "AVISO")
				While (!((prodstruct)->(EOF())))
					
					cCanProd		:= cValToChar((prodstruct)->QTD_PROD)
					nLinea 			+= 0.5
					Cproducto		:= AllTrim((prodstruct)->D4_COD)
					Ccodigoop		:= AllTrim((prodstruct)->D4_OP)

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (prodstruct)->D4_COD					,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1590	, AllTrim(prodstruct->C6_LOTECTL)		,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1880	, AllTrim(prodstruct->C6_LOCAL)			,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2090	, 	cCanProd							,	oArial12,,,,2)
					nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((prodstruct)->B1_DESC),	oArial12,,,,2)
					
					if Alltrim(prodstruct->XDESCRI) <>"" 
					//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
					nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/	
					nLinea += ImpMemo(oPrinter,zMemoToA("> "+ prodstruct->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)
					endif

					// Observacion de pieza, campo sc6 c6_vdobs
					if AllTrim((prodstruct)->C6VDOBS) <>""

						If nLinea > nLineasPag
									AcmFootPR()
									oPrinter:EndPage()
									oPrinter:StartPage()
									QueryclienteN(VarCliente)
									AcmHeadPR()
									(VW_OTRR)->(DBCLOSEAREA())
									nLinea:=17
						EndIf

						nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ prodstruct->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
					endif
				
					QryCodClie(Cclientex,Cproducto,Ctienda)
					
					if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "					,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
					AliasQcodcli->(DBCLOSEAREA())

					endif
						
					
					LookSerLot(Cproducto,Ccodigoop,"B")
					cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)

					if cflagserie <> ""
						nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
					
						while (!((aliaslookserie)->(EOF())))
								Ncontador++;

								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
								nLineax = nLineax+250
								(aliaslookserie)->(dbSkip())

								if (Ncontador>=4)
									
									nLinea ++;

									Ncontador = 0
									nLineax = 300

								endif

								If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
									AcmFootPR()
									oPrinter:EndPage()
									oPrinter:StartPage()
									QueryclienteN(VarCliente)
									AcmHeadPR()
									(VW_OTRR)->(DBCLOSEAREA())
									nLinea:=17
								EndIf	
						EndDo
					endif

					Ncontador = 0
					nLineax = 300

					aliaslookserie->(DBCLOSEAREA())

					(prodstruct)->(dbSkip())

					If !((prodstruct)->(EOF())) .and. nLinea > nLineasPag
						AcmFootPR()
						oPrinter:EndPage()
						oPrinter:StartPage()
						QueryclienteN(VarCliente)
						AcmHeadPR()
						(VW_OTRR)->(DBCLOSEAREA())
						nLinea:=17
					EndIf	

				EndDo
				prodstruct->(DBCLOSEAREA())
				(cQueryx)->(dbSkip())
			

			endif		

		EndDo
	elseif MV_PAR01 == 2 .AND. MV_PAR02==1
		// Cuando la opcion seleccionada, en los parámetros o preguntas iniciales, es 2; (Remision con valores) se ejecuta este código 
		While (!((cQueryx)->(EOF())) .and. MV_PAR01 == 2)

			condPedido		= (cQueryx)->D2_PEDIDO
			condProduto		= (cQueryx)->D2_COD
			Cremito			= (cQueryx)->D2_DOC
			Ctienda 		= (cQueryx)->D2_LOJA
			Cclientex 		= (cQueryx)->C6_CLI
			cRemision 		= (cQueryx)->D2_DOC

			LokforQry(condPedido,condProduto)
			Cresultlook = lokforQ->C6_NUMOP
			lokforQ->(DbCloseArea())

			//Si el resultado es vacio, es decir que no hay op, el codigo muestra los productos normales o sin estructura
			if Empty(Cresultlook)  
				cCanIMP	:= cValToChar((cQueryx)->D2_QUANT)
				nPrecioTotal = nPrecioTotal + (cQueryx)->D2_TOTAL
				nLinea += 0.5;

				nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->D2_COD						,	oArial12N,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1280	, AllTrim(cQueryx->C6_LOTECTL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1530	, AllTrim(cQueryx->C6_LOCAL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1740	, 	cCanIMP								,	oArial12,,,,2)
							if cF2_MOEDA ==1
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, AllTrim(TRANSFORM((cQueryx)->D2_TOTAL,"@E 999,999,999,999"))		,	oArial12,,,,2)
							else
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, AllTrim(TRANSFORM((cQueryx)->D2_TOTAL,"@E 999,999,999,999.99"))		,	oArial12,,,,2)
							endif
				nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((cQueryx)->C6_DESCRI),	oArial12,,,,2)

				// Muestro la descripción personalizada, si el producto no tiene, no se muestra nada
				if Alltrim(cQueryx->XDESCRI) <>"" 
				//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
				nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
				nLinea += ImpMemo(oPrinter,zMemoToA("> "+ cQueryx->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
				endif

				// Observacion de pieza, campo sc6 c6_vdobs
				if AllTrim((cQueryx)->C6VDOBS) <>""

					If  nLinea > nLineasPag
								AcmFootPR()
								oPrinter:EndPage()
								oPrinter:StartPage()
								QueryclienteN(VarCliente)
								AcmHeadPR()
								(VW_OTRR)->(DBCLOSEAREA())
								nLinea:=17
					EndIf
					nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ cQueryx->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
				endif			

				QryCodClie(Cclientex,condProduto,Ctienda)
				// Si existe un codigo cliente se muestra por item, si no, no
				if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "							,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
					AliasQcodcli->(DBCLOSEAREA())	
				endif


				LookSerLot(condProduto,"A",cRemision)
				cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)
				//Si existen series, se imprimen para los productos que las tengan. Esto depende de la cantidad de productos del pedido
				if cflagserie <> ""
					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
						
					while (!((aliaslookserie)->(EOF())))
						Ncontador++;

						if (Ncontador>4)
							
							nLinea ++;

							Ncontador = 0
							nLineax = 300
						endif

						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
						nLineax = nLineax+250
						(aliaslookserie)->(dbSkip())

						If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
							AcmFootPR()
							oPrinter:EndPage()
							oPrinter:StartPage()
							QueryclienteN(VarCliente)
							AcmHeadPR()
							(VW_OTRR)->(DBCLOSEAREA())
							nLinea:=17
						EndIf	
					EndDo
				endif
				
				Ncontador = 0
				nLineax = 300
				aliaslookserie->(DBCLOSEAREA())

				(cQueryx)->(dbSkip())

				If !((cQueryx)->(EOF())) .and. nLinea > nLineasPag
					AcmFootPR()
					oPrinter:EndPage()
					oPrinter:StartPage()
					QueryclienteN(VarCliente)
					AcmHeadPR()
					(VW_OTRR)->(DBCLOSEAREA())
					nLinea:=17
				EndIf
			else   // Es un producto tipo estructura o un producto compuesto

				QryStruc(condPedido,condProduto,Cremito)
				//MsgAlert("Existe producto compuesto. Presion finalizar para continuar la impresion", "AVISO")
				While (!((prodstruct)->(EOF())))
					
					cCanProd		:= cValToChar((prodstruct)->QTD_PROD)
					nLinea 			+= 0.5
					Cproducto		:= AllTrim((prodstruct)->D4_COD)
					Ccodigoop		:= AllTrim((prodstruct)->D4_OP)
					nCantSD2		= (prodstruct)->D2_QUANT
					nPrecioSC6		= (prodstruct)->C6_PRCVEN
					nPrecioTotal 	= nPrecioTotal + (nCantSD2*nPrecioSC6)


					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (prodstruct)->D4_COD					,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1280	, AllTrim(prodstruct->C6_LOTECTL)		,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1530	, AllTrim(prodstruct->C6_LOCAL)			,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1740	, 	cCanProd							,	oArial12,,,,2)
								if cF2_MOEDA ==1
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, 	AllTrim(TRANSFORM((nCantSD2*nPrecioSC6),"@E 999,999,999,999"))	,	oArial12,,,,2)
								else
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, 	AllTrim(TRANSFORM((nCantSD2*nPrecioSC6),"@E 999,999,999,999.99"))	,	oArial12,,,,2)
								endif 		
					nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((prodstruct)->B1_DESC),	oArial12,,,,2)
					
					if Alltrim(prodstruct->XDESCRI) <>"" 
					//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
					nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
					nLinea += ImpMemo(oPrinter,zMemoToA( "> "+prodstruct->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
					endif

					// Observacion de pieza, campo sc6 c6_vdobs
					if AllTrim((prodstruct)->C6VDOBS) <>""

						If nLinea > nLineasPag
								AcmFootPR()
								oPrinter:EndPage()
								oPrinter:StartPage()
								QueryclienteN(VarCliente)
								AcmHeadPR()
								(VW_OTRR)->(DBCLOSEAREA())
								nLinea:=17
						EndIf
						nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ prodstruct->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
					endif
					
					QryCodClie(Cclientex,Cproducto,Ctienda)
					
					if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "					,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
					AliasQcodcli->(DBCLOSEAREA())

					endif
						
					
					LookSerLot(Cproducto,Ccodigoop,"B")
					cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)

					if cflagserie <> ""
						nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
					
						while (!((aliaslookserie)->(EOF())))
								Ncontador++;

								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
								nLineax = nLineax+250
								(aliaslookserie)->(dbSkip())

								if (Ncontador>=4)
									
									nLinea ++;

									Ncontador = 0
									nLineax = 300

								endif

								If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
									AcmFootPR()
									oPrinter:EndPage()
									oPrinter:StartPage()
									QueryclienteN(VarCliente)
									AcmHeadPR()
									(VW_OTRR)->(DBCLOSEAREA())
									nLinea:=17
								EndIf	
						EndDo
					endif

					Ncontador = 0
					nLineax = 300

					aliaslookserie->(DBCLOSEAREA())

					(prodstruct)->(dbSkip())

					If !((prodstruct)->(EOF())) .and. nLinea > nLineasPag
						AcmFootPR()
						oPrinter:EndPage()
						oPrinter:StartPage()
						QueryclienteN(VarCliente)
						AcmHeadPR()
						(VW_OTRR)->(DBCLOSEAREA())
						nLinea:=17
					EndIf	

				EndDo
				prodstruct->(DBCLOSEAREA())
				(cQueryx)->(dbSkip())
			
			endif		
			if ((cQueryx)->(EOF()))
				nLinea++
				nLinea++
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1200	, "LINEA TOTAL ORDEN: "		,	oArial14N,,,,2)
					if cF2_MOEDA ==1
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980, AllTrim(TRANSFORM((nPrecioTotal),"@E 999,999,999,999")),	oArial12n,,,,2)
					else
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980, AllTrim(TRANSFORM((nPrecioTotal),"@E 999,999,999,999.99")),	oArial12n,,,,2)
					endif
				endif
		EndDo
		
	elseif MV_PAR01==1 .AND. MV_PAR02==2
		While (!((cQueryx)->(EOF())) .and. MV_PAR01==1)

			condPedido		= (cQueryx)->D2_PEDIDO
			condProduto		= (cQueryx)->D2_COD
			Cremito			= (cQueryx)->D2_DOC
			Ctienda 		= (cQueryx)->D2_LOJA
			Cclientex 		= (cQueryx)->C6_CLI
			cRemision 		= (cQueryx)->D2_DOC

			//Si el resultado es vacio, es decir que no hay op, el codigo muestra los productos normales o sin estructura
			// if Empty(Cresultlook)  
			cCanIMP	:= cValToChar((cQueryx)->D2_QUANT)
			nLinea += 0.5;

			nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->D2_COD						,	oArial12N,,,,2)
						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1590	, AllTrim(cQueryx->C6_LOTECTL)			,	oArial12,,,,2)
						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1850	, AllTrim(cQueryx->C6_LOCAL)			,	oArial12,,,,2)
						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2090	, 	cCanIMP								,	oArial12,,,,2)
			nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((cQueryx)->C6_DESCRI),	oArial12,,,,2)
			
			// Muestro la descripción personalizada, si el producto no tiene, no se muestra nada
			if Alltrim(cQueryx->XDESCRI) <>"" 
			//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
			nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
			nLinea += ImpMemo(oPrinter,zMemoToA("> "+ cQueryx->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
			endif

			// Observacion de pieza, campo sc6 c6_vdobs
			if AllTrim((cQueryx)->C6VDOBS) <>""

				If nLinea > nLineasPag
								AcmFootPR()
								oPrinter:EndPage()
								oPrinter:StartPage()
								QueryclienteN(VarCliente)
								AcmHeadPR()
								(VW_OTRR)->(DBCLOSEAREA())
								nLinea:=17
				EndIf
				nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ cQueryx->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
			endif

			QryCodClie(Cclientex,condProduto,Ctienda)
			// Si existe un codigo cliente se muestra por item, si no, no
			if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

				nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "							,	oArial12N,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
				AliasQcodcli->(DBCLOSEAREA())	
			endif


			LookSerLot(condProduto,"A",cRemision)
			cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)
			//Si existen series, se imprimen para los productos que las tengan. Esto depende de la cantidad de productos del pedido
			if cflagserie <> ""
				nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
					
				while (!((aliaslookserie)->(EOF())))
					Ncontador++;

					if (Ncontador>4)
						
						nLinea ++;

						Ncontador = 0
						nLineax = 300
					endif

					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
					nLineax = nLineax+250
					(aliaslookserie)->(dbSkip())

					If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
						AcmFootPR()
						oPrinter:EndPage()
						oPrinter:StartPage()
						QueryclienteN(VarCliente)
						AcmHeadPR()
						(VW_OTRR)->(DBCLOSEAREA())
						nLinea:=17
					EndIf	
				EndDo
			endif
			
			Ncontador = 0
			nLineax = 300
			aliaslookserie->(DBCLOSEAREA())

			(cQueryx)->(dbSkip())

			If !((cQueryx)->(EOF())) .and. nLinea > nLineasPag
				AcmFootPR()
				oPrinter:EndPage()
				oPrinter:StartPage()
				QueryclienteN(VarCliente)
				AcmHeadPR()
				(VW_OTRR)->(DBCLOSEAREA())
				nLinea:=17
			EndIf
				
		EndDo

	elseif MV_PAR01==2 .AND. MV_PAR02==2
		While (!((cQueryx)->(EOF())) .and. MV_PAR01 == 2)

			condPedido		= (cQueryx)->D2_PEDIDO
			condProduto		= (cQueryx)->D2_COD
			Cremito			= (cQueryx)->D2_DOC
			Ctienda 		= (cQueryx)->D2_LOJA
			Cclientex 		= (cQueryx)->C6_CLI
			cRemision 		= (cQueryx)->D2_DOC

 
				cCanIMP	:= cValToChar((cQueryx)->D2_QUANT)
				nPrecioTotal = nPrecioTotal + (cQueryx)->D2_TOTAL
				nLinea += 0.5;

				nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->D2_COD						,	oArial12N,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1280	, AllTrim(cQueryx->C6_LOTECTL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, AllTrim(cQueryx->C6_LOCAL)			,	oArial12,,,,2)
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1740	, 	cCanIMP								,	oArial12,,,,2)
							if cF2_MOEDA ==1
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, AllTrim(TRANSFORM((cQueryx)->D2_TOTAL,"@E 999,999,999,999"))		,	oArial12,,,,2)
							else
							oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980	, AllTrim(TRANSFORM((cQueryx)->D2_TOTAL,"@E 999,999,999,999.99"))		,	oArial12,,,,2)
							endif 
				nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	,"-->  "+ AllTrim((cQueryx)->C6_DESCRI),	oArial12,,,,2)

				// Muestro la descripción personalizada, si el producto no tiene, no se muestra nada
				if Alltrim(cQueryx->XDESCRI) <>"" 
				//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
				nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
				nLinea +=ImpMemo(oPrinter,zMemoToA( "> "+cQueryx->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)
				endif
				
				// Observacion de pieza, campo sc6 c6_vdobs
				if AllTrim((cQueryx)->C6VDOBS) <>""

					If nLinea > nLineasPag
								AcmFootPR()
								oPrinter:EndPage()
								oPrinter:StartPage()
								QueryclienteN(VarCliente)
								AcmHeadPR()
								(VW_OTRR)->(DBCLOSEAREA())
								nLinea:=17
					EndIf
					nLinea += ImpMemo(oPrinter,zMemoToA("+ "+ cQueryx->C6VDOBS, 60)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)	
				endif				

				QryCodClie(Cclientex,condProduto,Ctienda)
				// Si existe un codigo cliente se muestra por item, si no, no
				if Alltrim(AliasQcodcli->A7_CODCLI) <>"" .OR. Alltrim(AliasQcodcli->A7_DESCCLI) <> ""

					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "SU ITEM... "							,	oArial12N,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQcodcli->A7_CODCLI				,	oArial12,,,,2)
								oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+600	, AliasQcodcli->A7_DESCCLI				,	oArial12,,,,2)
					AliasQcodcli->(DBCLOSEAREA())	
				endif


				LookSerLot(condProduto,"A",cRemision)
				cflagserie = Alltrim(aliaslookserie->DB_NUMSERI)
				//Si existen series, se imprimen para los productos que las tengan. Esto depende de la cantidad de productos del pedido
				if cflagserie <> ""
					nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Nums. de serie:"						,	oArial12N,,,,2)
						
					while (!((aliaslookserie)->(EOF())))
						Ncontador++;

						if (Ncontador>4)
							
							nLinea ++;

							Ncontador = 0
							nLineax = 300
						endif

						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+nLineax, (aliaslookserie)->DB_NUMSERI			,	oArial12,,,,2)
						nLineax = nLineax+250
						(aliaslookserie)->(dbSkip())

						If !((aliaslookserie)->(EOF())) .and. nLinea > nLineasPag
							AcmFootPR()
							oPrinter:EndPage()
							oPrinter:StartPage()
							QueryclienteN(VarCliente)
							AcmHeadPR()
							(VW_OTRR)->(DBCLOSEAREA())
							nLinea:=17
						EndIf	
					EndDo
				endif
				
				Ncontador = 0
				nLineax = 300
				aliaslookserie->(DBCLOSEAREA())

				(cQueryx)->(dbSkip())

				If !((cQueryx)->(EOF())) .and. nLinea > nLineasPag
					AcmFootPR()
					oPrinter:EndPage()
					oPrinter:StartPage()
					QueryclienteN(VarCliente)
					AcmHeadPR()
					(VW_OTRR)->(DBCLOSEAREA())
					nLinea:=17
				EndIf
				
			if ((cQueryx)->(EOF()))
				nLinea++
				nLinea++
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1200	, "LINEA TOTAL ORDEN:"		,	oArial14N,,,,2)
					if cF2_MOEDA ==1
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980, AllTrim(TRANSFORM(nPrecioTotal,"@E 999,999,999,999"))			,	oArial12n,,,,2)
					else 
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1980, AllTrim(TRANSFORM(nPrecioTotal,"@E 999,999,999,999.99"))			,	oArial12n,,,,2)
					endif 
				endif
		EndDo

	endif
	



Return
/*
+===========================================================================+
| Programa  # AcmFootPR    |Autor  |    |Fecha |     |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones PIE DE PAGINA          |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_AcmFootPR()                                               |
+===========================================================================+
*/
Static Function AcmFootPR(lSaltoPagina)
	Local n1Linea		:= 10
	local nMargIqz		:= 10
	local nLinea		:= 55
	Local nMargDer		:= 2400-10
	Default lSaltoPagina:=.F.
	

	IF !lSaltoPagina
		(cRem)->(DbGoTop())
	EndIf
	cRespon	:= ALLTRIM("")

				oPrinter:Line(n1Linea+(nFontAlto*nLinea),0,n1Linea+(nFontAlto*nLinea), nMargDer,,"-8")
	nLinea += 0.5	
				ImpMemo(oPrinter,zMemoToA("OBSERVACION:  "+ (qryclientre)->C5_MENNOTA, 150)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+50, 2400  	, nFontAlto	, oArial12	, 0			,0)
					// (oPrinter,aTexto                                              		,nLinMemo					, nColumna   , nAncho	, nAlto 	, oFont1   	, nAlinV 	, nAlinH, lSaltoObl, nLCorteObl)
	nLinea+= 2; 	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, (qryclientre)->C5_INCOTER 				,	oArial12,,,,2)
	nLinea += 3				
	nLinea ++;	oPrinter:Line(n1Linea+(nFontAlto*nLinea),nMargIqz,n1Linea+(nFontAlto*nLinea), nMargDer,,"-6")
	nLinea += 0.5
	nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "Elaborado:________________________"				,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+700	, "Revisado: ________________________"				,	oArial12,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1700	, "Aprobado: ________________________"				,	oArial12,,,,2)

Return
/*
+===========================================================================+
| Programa  # RQuery    |Autor  |     |Fecha |        |
+===========================================================================+
| Desc.     #  Función para GENERAR EL SQL DE BUSQUEDA                      |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   RQuery()                                                    |
+===========================================================================+
*/
Static Function RQuery(cDoc,cSerie,cCliente,cLoja)
	
	
	Local cQry	:= ""


	cQry:=" SELECT  " + CRLF
	cQry+=" NNR_DESCRI, " + CRLF
	cQry+=" A1_NOME, A1_CGC, A1_PFISICA,  " + CRLF
	cQry+=" B1_DESC,  " + CRLF
	cQry+=" D2_ITEM, D2_COD, D2_UM, D2_SEGUM, D2_QUANT, D2_QTSEGUM, D2_NUMSEQ, D2_PEDIDO, " + CRLF
	cQry+=" F2_DOC, F2_SERIE, F2_EMISSAO, F2_TIPOREM, F2_SERIE2, F2_SDOCMAN, F2_DTDIGIT " + CRLF
	cQry+=" FROM "+ InitSqlName("SF2") +" SF2  " + CRLF
	cQry+=" INNER JOIN "+ InitSqlName("SD2") +" SD2 ON  " + CRLF
	cQry+=" SD2.D_E_L_E_T_=' ' AND " + CRLF
	cQry+=" D2_FILIAL='"+xFilial("SD2")+"' AND " + CRLF
	cQry+=" F2_DOC=D2_DOC AND " + CRLF
	cQry+=" F2_SERIE=D2_SERIE AND   " + CRLF
	cQry+=" F2_CLIENTE=D2_CLIENTE AND  " + CRLF
	cQry+=" F2_LOJA=D2_LOJA " + CRLF
	cQry+=" INNER JOIN "+ InitSqlName("SB1") +" SB1 ON  " + CRLF
	cQry+=" SB1.D_E_L_E_T_='' AND " + CRLF
	cQry+=" B1_FILIAL='"+xFilial("SB1")+"' AND  " + CRLF
	cQry+=" B1_COD=D2_COD " + CRLF
	cQry+=" INNER JOIN "+ InitSqlName("SA1") +" SA1 ON " + CRLF
	cQry+=" SA1.D_E_L_E_T_=' ' AND " + CRLF
	cQry+=" A1_FILIAL='"+xFilial("SA1")+"' AND  " + CRLF
	cQry+=" A1_COD=F2_CLIENTE " + CRLF
	cQry+=" LEFT JOIN "+ InitSqlName("NNR") +" NNR ON  " + CRLF
	cQry+=" NNR.D_E_L_E_T_=' ' AND " + CRLF
	cQry+=" NNR_FILIAL='"+xFilial("NNR")+"' AND  " + CRLF
	cQry+=" D2_LOCAL=NNR_CODIGO " + CRLF
	cQry+=" WHERE  " + CRLF
	cQry+=" SF2.D_E_L_E_T_=' ' AND  " + CRLF
	cQry+=" F2_FILIAL='"+xFilial("SF2")+"' AND  " + CRLF
	cQry+=" F2_DOC='"+cDoc+"' AND " + CRLF
	cQry+=" F2_SERIE='"+cSerie+"' AND  " + CRLF
	cQry+=" F2_CLIENTE='"+cCliente+"' AND " + CRLF
	cQry+=" F2_LOJA='"+cLoja+"' " + CRLF
	cQry+=" ORDER BY D2_ITEM " + CRLF

Return cQry

Static Function QueryclienteN(cCliente)

	// Quuery trae datos de cliente de factura
	Local cQrycliente := ""

	If Select("VW_OTRR") > 0
		dbSelectArea("VW_OTRR")
		dbCloseArea()
	Endif

	cQrycliente:=" SELECT  " + CRLF
	cQrycliente+=" A1_END, A1_ESTADO, A1_MUN, A1_BAIRRO, A1_NOME, A1_OBS  " + CRLF
	cQrycliente+=" FROM "+ InitSqlName("SA1") +" SA1  " + CRLF
	cQrycliente+=" WHERE" + CRLF
	cQrycliente+=" SA1.D_E_L_E_T_<>'*' AND A1_COD='" +cCliente+ "' "+ CRLF

	TCQuery cQrycliente New Alias "VW_OTRR"


return 

Static Function Qclie(cCliente,zpedido)

	Local cQryclient := ""
		// Query trae datos del cliente de entrega
	If Select("qryclientre") > 0
		dbSelectArea("qryclientre")
		dbCloseArea()
	Endif
	cQryclient:=" SELECT  " + CRLF
	cQryclient+=" C5_CLIENT, C5_NUM, C5_MENNOTA, C5_INCOTER, " + CRLF
	cQryclient+=" A1_END, A1_ESTADO, A1_MUN, A1_BAIRRO, A1_NOME  " + CRLF
	cQryclient+=" FROM "+ InitSqlName("SC5") +" SC5  " + CRLF
	cQryclient+=" INNER JOIN "+ InitSqlName("SA1") +" SA1 ON  " + CRLF
	cQryclient+=" SA1.D_E_L_E_T_=' ' AND C5_CLIENT = A1_COD" + CRLF
	cQryclient+=" WHERE" + CRLF
	cQryclient+=" SC5.D_E_L_E_T_= ' ' AND C5_CLIENTE='" +cCliente+ "' AND C5_NUM='"+zpedido+"' "+ CRLF   

	TCQuery cQryclient New Alias "qryclientre"
return 

/*/{Protheus.doc} QryCodClie
	@param cliente,producto,tienda
	En este query busco en la tabla sa7 el codigo de producto-cliente y la descripción, para ponerlos 
	como información adicional en el detalle del remito de venta
/*/
Static Function QryCodClie(cliente,producto,tienda)

	Local cQrycodclie	:= ""

	If Select("AliasQcodcli") > 0
		dbSelectArea("AliasQcodcli")
		dbCloseArea()
	Endif
	cQrycodclie:=" SELECT  " + CRLF
	cQrycodclie+=" A7_CLIENTE, A7_LOJA, A7_PRODUTO, A7_CODCLI, A7_DESCCLI " + CRLF
	cQrycodclie+=" FROM "+ InitSqlName("SA7") +" SA7  " + CRLF
	cQrycodclie+=" WHERE" + CRLF
	cQrycodclie+=" SA7.D_E_L_E_T_='' AND A7_CLIENTE='" +cliente+ "' AND A7_PRODUTO='"+producto+"' AND A7_LOJA='"+tienda+"' "+ CRLF 
	
	TCQuery cQrycodclie New Alias "AliasQcodcli"

Return

Static Function QryLotSer (pedido,documentox, seriex)
Local cQrylotser := ""
	
	If Select("cQueryx") > 0
		dbSelectArea("cQueryx")
		dbCloseArea()
	Endif

		cQrylotser:=" SELECT  " + CRLF
		cQrylotser+=" D2_PEDIDO, D2_COD, B1_DESC, D2_QUANT, D2_SERIE, D2_LOTECTL, D2_DOC, C6_SERIE, C6_LOCAL, C6_CLI, C6_NUMSERI, C6_LOTECTL, D2_NUMLOTE, D2_NUMSERI, D2_LOJA, " + CRLF
		cQrylotser+=" ISNULL(CAST(CAST(B1_XDESCRI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS XDESCRI, C6_CODINF, D2_TOTAL, C6_DESCRI, " + CRLF
		cQrylotser+=" ISNULL(CAST(CAST(C6_VDOBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C6VDOBS " + CRLF
		//cQrylotser+=" ISNULL(CAST(CAST(B.C6_INFAD AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS INFAD " + CRLF
		cQrylotser+=" FROM "+ InitSqlName("SD2") +" SD2 " + CRLF
		cQrylotser+=" INNER JOIN "+ InitSqlName("SB1") +" SB1 ON  " + CRLF
		cQrylotser+=" D2_COD = B1_COD  AND SB1.D_E_L_E_T_='' " + CRLF
		cQrylotser+=" INNER JOIN "+ InitSqlName("SC6") +" B ON  " + CRLF
		cQrylotser+=" B.C6_NUM = D2_PEDIDO AND B.C6_PRODUTO = D2_COD  AND  B.D_E_L_E_T_<>'*' AND B.C6_ITEM = D2_ITEMPV " + CRLF
		//cQrylotser+=" INNER JOIN "+ InitSqlName("SDC") +" SDC ON  " + CRLF
		//cQrylotser+=" SDC.D_E_L_E_T_=' ' AND DC_PEDIDO = D2_PEDIDO " + CRLF
		cQrylotser+=" WHERE" + CRLF
		cQrylotser+=" SD2.D_E_L_E_T_<>'*' AND D2_PEDIDO='" +pedido+ "' AND D2_DOC= '"+documentox+"' "+ CRLF
		cQrylotser+=" AND D2_SERIE='"+seriex+ "' " + CRLF

		
	TCQuery cQrylotser New Alias "cQueryx"

Return

Static Function QryStruc (pedidoy,produtoy,remitoy)
Local cQestructura	:= ""

	If Select("prodstruct") > 0
		dbSelectArea("prodstruct")
		dbCloseArea()
	Endif

		cQestructura:=" SELECT  " + CRLF
		cQestructura+=" A.D2_SERIE, D2_DOC, D2_COD, B.C6_NUMOP, B.C6_ITEMOP,C2_TPOP, C2_NUM, C2_ITEM, B.C6_SERIE, B.C6_NUMSERI, B.C6_LOTECTL, B.C6_LOCAL, B.C6_VALOR, B.C6_DESCRI, " + CRLF
		cQestructura+=" C2_SEQUEN, C2_PRODUTO, D.D4_COD, (D4_QTDEORI- D4_QUANT) QTD_ANTERIOR, E.B1_DESC, D.D4_LOTECTL, D.D4_OP, B.C6_CODINF, A.D2_QUANT, B.C6_PRCVEN, A.D2_TOTAL,  " + CRLF
		cQestructura+=" G.BH_CODCOMP, G.BH_QUANT, (A.D2_QUANT*G.BH_QUANT)  QTD_PROD,  " + CRLF
		cQestructura+=" ISNULL(CAST(CAST(E.B1_XDESCRI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS XDESCRI, " + CRLF
		cQestructura+=" ISNULL(CAST(CAST(B.C6_VDOBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C6VDOBS " + CRLF
		//cQestructura+=" ISNULL(CAST(CAST(B.C6_INFAD AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS INFAD " + CRLF
		cQestructura+=" FROM "+ InitSqlName("SD2") +" A " + CRLF
		cQestructura+=" INNER JOIN "+ InitSqlName("SC6") +" B ON  " + CRLF
		cQestructura+=" B.C6_NUM = A.D2_PEDIDO AND B.D_E_L_E_T_ = '' AND B.C6_OP <> '' AND B.C6_PRODUTO = A.D2_COD AND B.C6_ITEM = A.D2_ITEMPV " + CRLF
		cQestructura+=" INNER JOIN "+ InitSqlName("SC2") +" C ON  " + CRLF
		cQestructura+=" (B.C6_NUMOP+B.C6_ITEMOP) = (C.C2_NUM+C.C2_ITEM) AND C.C2_PRODUTO = B.C6_PRODUTO AND C.D_E_L_E_T_ <>'*' " + CRLF
		cQestructura+=" INNER JOIN "+ InitSqlName("SD4") +" D ON  " + CRLF
		cQestructura+=" D.D4_OP =  (C.C2_NUM+C.C2_ITEM+C.C2_SEQUEN) AND D.D_E_L_E_T_ <>'*' " + CRLF
		cQestructura+=" INNER JOIN "+ InitSqlName("SB1") +" E ON  " + CRLF
		cQestructura+=" D.D4_COD=E.B1_COD AND E.D_E_L_E_T_='' " + CRLF
		cQestructura+=" LEFT JOIN "+InitSqlName("SBG")+" F ON D.D4_PRODUTO = F.BG_PRODUTO AND F.D_E_L_E_T_<>'*' " + CRLF
		cQestructura+=" LEFT JOIN "+InitSqlName("SBH")+" G ON F.BG_PRODUTO=G.BH_PRODUTO AND G.D_E_L_E_T_<>'*' AND D.D4_COD = G.BH_CODCOMP " + CRLF
		cQestructura+=" WHERE" + CRLF
		cQestructura+=" D2_PEDIDO='"+pedidoy+"' AND D2_COD='"+produtoy+"' AND A.D_E_L_E_T_ <>'*' AND D2_DOC='"+remitoy+"'" + CRLF

	TCQuery cQestructura New Alias "prodstruct"

Return

/*/{CASE} LokforQry
Query de busqueda de pedido en la SC2 para descartar un producto compuesto

/*/
Static Function LokforQry(pedido,nomeproduc)

Local Clookfor := ""

if select("lokforQ")>0

	DbSelectArea("lokforQ")
	DBCLOSEAREA()
endif

		Clookfor:=" SELECT  " + CRLF
		Clookfor+=" C6_NUM, C6_PRODUTO, C6_NUMOP, C6_ITEMOP " + CRLF
		Clookfor+=" FROM "+ InitSqlName("SC6") +" SC6 " + CRLF
		Clookfor+=" WHERE" + CRLF
		Clookfor+=" SC6.D_E_L_E_T_ <>'*' AND C6_NUM='"+pedido+"' AND C6_PRODUTO='"+nomeproduc+"' " + CRLF

TcQuery cLookFor New Alias "lokforQ" 
	
Return 
/*/{CASE} LookSerLot
Comprueba si existe el lote y la serie del producto, y trae la serie principalmente
/*/
Static Function LookSerLot(producto,nuop,remision)
	Local Clookserie		:=""

	if SELECT("aliaslookserie")>0
		DbSelectArea("aliaslookserie")
		DBCLOSEAREA()
	endif

	if (nuop="A")

	Clookserie:=" SELECT  " + CRLF
	Clookserie+=" DB_NUMSERI, DB_PRODUTO, DB_NUMLOTE, DB_LOTECTL " + CRLF
	Clookserie+=" FROM "+ InitSqlName("SDB") +" A " + CRLF
	Clookserie+=" WHERE"+ CRLF
	Clookserie+=" A.DB_PRODUTO='"+producto+"' AND A.DB_DOC='"+remision+"' AND A.D_E_L_E_T_ <> '*' "  + CRLF
	Clookserie+=" ORDER BY DB_NUMSERI DESC"  + CRLF
	//Clookserie+=" DC_PRODUTO='"+producto+"' AND DC_PEDIDO='"+ped+"' AND DC_NUMSERI <> '' "  + CRLF
	
	//
	elseif (Remision="B")

	Clookserie:=" SELECT  " + CRLF
	Clookserie+=" DB_NUMSERI, DB_PRODUTO, DB_NUMLOTE, DB_LOTECTL " + CRLF
	Clookserie+=" FROM "+ InitSqlName("SDB") +" A " + CRLF
	Clookserie+=" WHERE"+ CRLF
	Clookserie+=" A.DB_PRODUTO='"+producto+"' AND A.DB_DOC='"+nuop+"' AND A.D_E_L_E_T_ <> '*' "  + CRLF
	//SDC.D_E_L_E_T_ <>'*' 
	endif
	

	TCQuery Clookserie New Alias aliaslookserie

Return 


// query para buscar los campo INFAD de cada producto
Static Function Qrymemovirtual(chave)
	Local memoquery		:=""

	if SELECT("aliasmemoqry")>0
		DbSelectArea("aliasmemoqry")
		DBCLOSEAREA()
	endif

	memoquery:=" SELECT  " + CRLF
	memoquery+=" YP_TEXTO, YP_SEQ " + CRLF
	memoquery+=" FROM "+ InitSqlName("SYP") +" A " + CRLF
	memoquery+=" WHERE"+ CRLF
	memoquery+=" A.D_E_L_E_T_ <>'*' AND A.YP_CHAVE='"+chave+"' AND A.YP_CAMPO='C6_CODINF' " + CRLF

	TCQuery memoquery New Alias aliasmemoqry

Return 

/*
+===========================================================================+
| Programa  # FECHA     |Autor  | ===============================+
| Desc.     #  Función para GENERAR FECHA                                   |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   FECHA()                                                    |
+===========================================================================+
*/
Static Function fecha(cFecha,cTime)
	Local aMes	:= {'Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'}
	Local cAno	:= ""
	Local cMes	:= ""
	Local cDia	:= ""
	Local cFullFecha := "  /  /  "
	If !EMPTY(AllTrim(cFecha))
		cAno	:= SUBSTR(cFecha,1,4)
		cMes	:= aMes[VAL(SUBSTR(cFecha,5,2))]
		cDia	:= SUBSTR(cFecha,7,2)
		cFullFecha := cDia+"/"+cMes+"/"+cAno+" "+cTime
	EndIf
Return cFullFecha

/*
+---------------------------------------------------------------------------+
|  Programa  |AjustaSX1            |Autor    |
+---------------------------------------------------------------------------+
|  Uso       | Grupo de prerguntas al entrar                                |
+---------------------------------------------------------------------------+
*/
Static Function ACMPREG1(cPregunta)
	Local aRegs := {}
	Local cPerg := PADR(cPregunta,10)
	Local nI 	:= 0
	Local nJ	:= 0
	Local nLarDoc:= 0
	Local nLarSer:= 0
	Local nLarFor:= 0
	Local nLarLoj:= 0
	// Local aHelpSpa:= {}
	DBSelectArea("SX3")
	DBSetOrder(2)
	dbSeek("F2_DOC")
	nLarDoc:=SX3->X3_TAMANHO
	dbSeek("F2_SERIE")
	nLarSer:=SX3->X3_TAMANHO
	dbSeek("F2_CLIENTE")
	nLarFor:=SX3->X3_TAMANHO
	dbSeek("F2_LOJA")
	nLarLoj:=SX3->X3_TAMANHO
	dbCloseArea("SX3")

aAdd(aRegs,{cPerg,"01","Remision"		,"Remision"			,"Remision"			,"MV_CH01"	,"C"	, 08 		,0,2	,"C"	,"" 															,"MV_CH01","Remision Salida"	,"Remision Salida" ,"Remision Salida",""							,"","Remision+Valor","Remision+Valor","Remision+Valor","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Modo impresión"	,"Modo impresión"	,"Modo impresión"	,"MV_CH02"	,"C"	, 08 		,0,2	,"C"	,"" 															,"MV_CH02","Ver Componentes"	,"Ver Componentes" ,"Ver Componentes",""							,"","Sin Componentes","Sin Componentes","Sin Componentes","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03",DEFECHA			,DEFECHA			,DEFECHA			,"MV_CH03"	,"D"	, 08 		,0,2	,"G"	,"" 															,"MV_CH03","" 					,"" 				,"" 			,"'01/01/20'"					,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04",AFECHA			,AFECHA				,AFECHA				,"MV_CH04"	,"D"	, 08 		,0,2	,"G"	,"!Empty(MV_PAR04) .And. MV_PAR03<=MV_PAR04" 					,"MV_CH04","" 					,"" 				,"" 			,"'31/12/20'"					,"","","","","","","","","","","","","","","","","","","","","",""})
// aAdd(aRegs,{cPerg,"04",DESERIE		,DESERIE			,DESERIE			,"MV_CH04"	,"C"	, nLarSer	,0,2	,"G"	,"" 															,"MV_CH04","" 					,"" 				,"" 			,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
// aAdd(aRegs,{cPerg,"05",ASERIE		,ASERIE				,ASERIE				,"MV_CH05"	,"C"	, nLarSer	,0,2	,"G"	,"!Empty(MV_PAR06) .And. MV_PAR05<=MV_PAR06"	 				,"MV_CH05","" 					,"" 				,"" 			,REPLICATE("Z",nLarSer) 		,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","De Remito"		,"De Remito"		,"De Remito"		,"MV_CH05"	,"C"	, nLarDoc	,0,2	,"G"	,"" 															,"MV_CH05","" 					,"" 				,"" 			,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","A Remito"		,"A Remito"			,"A Remito"			,"MV_CH06"	,"C"	, nLarDoc	,0,2	,"G"	,"!Empty(MV_PAR06) .And. MV_PAR05<=MV_PAR06" 					,"MV_CH06","" 					,"" 				,"" 			,REPLICATE("Z",nLarDoc) 		,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07",DECLIENTE		,DECLIENTE			,DECLIENTE			,"MV_CH07"	,"C"	, nLarFor	,0,2	,"G"	,"" 															,"MV_CH07","" 					,"" 				,"" 			,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08",ACLIENTE			,ACLIENTE			,ACLIENTE			,"MV_CH08"	,"C"	, nLarFor	,0,2	,"G"	,"!Empty(MV_PAR08) .And. MV_PAR07<=MV_PAR08" 					,"MV_CH08","" 					,"" 				,"" 			,REPLICATE("Z",nLarFor) 		,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09",DETIENDA			,DETIENDA			,DETIENDA			,"MV_CH09"	,"C"	, nLarLoj	,0,2	,"G"	,"" 															,"MV_CH09","" 					,"" 				,"" 			,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10",ATIENDA			,ATIENDA			,ATIENDA			,"MV_CH10"	,"C"	, nLarLoj	,0,2	,"G"	,"!Empty(MV_PAR10) .And. MV_PAR09<=MV_PAR10" 					,"MV_CH10","" 					,"" 				,"" 			,REPLICATE("Z",nLarLoj) 		,"","","","","","","","","","","","","","","","","","","","","",""})		
aAdd(aRegs,{cPerg,"11",DIRDESTINO		,DIRDESTINO			,DIRDESTINO			,"MV_CH11"	,"C"	, 99		,0,2	,"G"	,"!Vazio().or.(MV_PAR11:=cGetFile('PDFs |*.*','',,,,176,.F.))" 	,"MV_CH11","" 					,"" 				,"" 			,"C:\SPOOL\"					,"","","","","","","","","","","","","","","","","","","","","",""})
	dbSelectArea("SX1")		
	dbSetOrder(1)
	For nI:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[nI,2])
			RecLock("SX1",.T.)
			For nJ:=1 to FCount()
				If nJ <= Len(aRegs[nI])
					FieldPut(nJ,aRegs[nI,nJ])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return

/*
+===========================================================================+
|  Programa  Tipoquery Autor                     |
|                                                                           |
|  Uso       | Signature                                                    |
+===========================================================================+
*/
Static function TipoQuery(cDocQuery,cDocumento,cSerie, cCliente,cLoja )
	Local cQueryRem	:=''
	Local cPedido	:=''
	dbSelectArea("SF2")
	dbSetOrder(2)
	dbGoTop()
	DbSeek( xFilial("SF2") + cCliente + cLoja + cDocumento + cSerie )
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2") + cDocumento + cSerie + cCliente + cLoja)
	cPedido:=SD2->D2_PEDIDO
	If cDocQuery==1
		cQueryRem	:= " SELECT DISTINCT "
		cQueryRem	+= " F2_CLIENTE, D2_ITEM, F2_DOC,F2_SERIE,F2_EMISSAO, F2_VALBRUT, F2_MOEDA, F2_DESCONT, F2_VALMERC, " + CRLF
		cQueryRem	+= " F2_VALIMP1, F2_VALIMP2, F2_VALIMP3, F2_VALIMP4, F2_VALIMP5, F2_VALIMP6, F2_VALIMP7, F2_VALIMP8,  F2_VALIMP9, " + CRLF
		//cQueryRem	+= " F2_FRETE, F2_ESPECIE, F2_USERLGI, F2_TIPREF, F2_DTDIGIT, " + CRLF
		cQueryRem	+= " F2_FRETE, F2_ESPECIE, F2_TIPREF, F2_DTDIGIT, " + CRLF
		cQueryRem	+= " D2_DESCON, D2_VALBRUT, D2_PEDIDO, " + CRLF
		cQueryRem	+= " D2_PRCVEN, D2_TOTAL, D2_COD, D2_ITEM, D2_UM, D2_EMISSAO, " + CRLF
		cQueryRem	+= " D2_VALIMP1, D2_VALIMP2, D2_VALIMP3, D2_VALIMP4, D2_VALIMP5, D2_VALIMP6, D2_VALIMP7, D2_VALIMP8, D2_VALIMP9, " + CRLF
		cQueryRem	+= " B1_DESC, B1_CODBAR,  " + CRLF
		cQueryRem	+= " D2_QTSEGUM,  " + CRLF
		cQueryRem	+= " A1_END, A1_COD_MUN, A1_BAIRRO, A1_ESTADO, A1_PAIS, A1_NOME, A1_CGC, A1_PFISICA, " + CRLF
		cQueryRem	+= " J1_BAIRRO, J1_COD_MUN, J1_END, J1_ESTADO,  J1_NOME,  J1_PAIS, " + CRLF
		cQueryRem	+= " CC2_MUN, D2_QUANT, "  + CRLF
		cQueryRem	+= " C5_NUM, C5_EMISSAO, C5_CLIENT, C5_LOJAENT, C5_CLIENTE, C5_LOJACLI, C6_DESCRI, C5_XENDENT, C5_XEST, C5_XMUN, C5_XORCOMP, " + CRLF
		cQueryRem	+= " FP_NUMINI, FP_NUMFIM, FP_CAI, FP_DTRESOL, A7_CODCLI, A7_DESCCLI, " + CRLF
		cQueryRem	+= " AH_DESCES, " + CRLF
	//	cQueryRem	+= " SUBSTRING((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XOBS))),1,LEN((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XOBS))))) AS C5_XOBS, "  + CRLF
		cQueryRem	+= " SUBSTRING((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),F2_XOBS))),1,LEN((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),F2_XOBS))))) AS F2_XOBS " + CRLF
		cQueryRem	+= " FROM "+ InitSqlName("SF2") +" SF2  " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SA1") +" SA1 ON (SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ') "  + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SD2") +" SD2 ON (SD2.D2_DOC = SF2.F2_DOC  AND  SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SB1") +" SB1 ON (SB1.B1_COD = SD2.D2_COD AND SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("CC2") +" CC2 ON (CC2.CC2_CODMUN = SA1.A1_COD_MUN AND CC2.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SC5") +" SC5 ON (SC5.C5_NUM=SD2.D2_PEDIDO AND SC5.C5_FILIAL='"+xFilial("SC5")+"' AND SC5.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SC6") +" SC6 ON (SC6.C6_NUM=SC5.C5_NUM AND SC6.C6_FILIAL='"+xFilial("SC6")+"' AND SC6.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SA7") +" SA7 ON (SA7.A7_CLIENTE = SF2.F2_CLIENTE AND SA7.A7_PRODUTO = SD2.D2_COD AND SA7.A7_FILIAL='"+xFilial("SA7")+"' AND SA7.D_E_L_E_T_=' ') "  + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SFP") +" SFP ON "  + CRLF
		cQueryRem	+= "  (SFP.FP_SERIE=SF2.F2_SERIE AND ( "+cValToChar(VAL(cDocumento))+" BETWEEN CAST(FP_NUMINI as BIGINT) AND CAST(FP_NUMFIM as BIGINT) )  AND SFP.FP_FILIAL='"+xFilial("SFP")+"' AND SFP.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT  JOIN ( SELECT A1_BAIRRO AS J1_BAIRRO,  A1_COD_MUN AS J1_COD_MUN, A1_END AS J1_END, A1_ESTADO AS J1_ESTADO, A1_NOME AS J1_NOME, A1_PAIS AS J1_PAIS, A1_COD AS J1_COD, A1_LOJA AS J1_LOJA, A1_FILIAL AS J1_FILIAL, D_E_L_E_T_ AS JD_E_L_E_T_ FROM "+ InitSqlName("SA1")+" SA1 )" + CRLF
		cQueryRem	+= "   XX1 ON (XX1.J1_COD = SC5.C5_CLIENT  AND XX1.J1_LOJA=SC5.C5_LOJAENT AND XX1.J1_FILIAL='"+xFilial("SA1")+"' AND XX1.JD_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SAH") +" SAH ON (SB1.B1_UM=SAH.AH_UNIMED AND SAH.D_E_L_E_T_=' '  )" + CRLF
		cQueryRem	+= " WHERE (SF2.F2_ESPECIE='RFN ' OR SF2.F2_ESPECIE='RTF ' ) AND F2_DOC='"+cDocumento+"' AND F2_FILIAL='"+xFilial('SF2')+"'AND F2_SERIE='"+cSerie+"' AND SF2.D_E_L_E_T_=' '" + CRLF
	elseIf cDocQuery==2  // Remito con valor
		cQueryRem	:= " SELECT DISTINCT "
		cQueryRem	+= " F2_CLIENTE, D2_ITEM, F2_DOC,F2_SERIE,F2_EMISSAO, F2_VALBRUT, F2_MOEDA, F2_DESCONT, F2_VALMERC, " + CRLF
		cQueryRem	+= " F2_VALIMP1, F2_VALIMP2, F2_VALIMP3, F2_VALIMP4, F2_VALIMP5, F2_VALIMP6, F2_VALIMP7, F2_VALIMP8,  F2_VALIMP9, " + CRLF
		//cQueryRem	+= " F2_FRETE, F2_ESPECIE, F2_USERLGI, F2_TIPREF, F2_DTDIGIT, " + CRLF
		cQueryRem	+= " F2_FRETE, F2_ESPECIE, F2_TIPREF, F2_DTDIGIT, " + CRLF
		cQueryRem	+= " D2_DESCON, D2_VALBRUT, D2_PEDIDO, " + CRLF
		cQueryRem	+= " D2_PRCVEN, D2_TOTAL, D2_COD, D2_ITEM, D2_UM, D2_EMISSAO, " + CRLF
		cQueryRem	+= " D2_VALIMP1, D2_VALIMP2, D2_VALIMP3, D2_VALIMP4, D2_VALIMP5, D2_VALIMP6, D2_VALIMP7, D2_VALIMP8, D2_VALIMP9, " + CRLF
		cQueryRem	+= " B1_DESC, B1_CODBAR,  " + CRLF
		cQueryRem	+= " D2_QTSEGUM,  " + CRLF
		cQueryRem	+= " A1_END, A1_COD_MUN, A1_BAIRRO, A1_ESTADO, A1_PAIS, A1_NOME, A1_CGC, A1_PFISICA, " + CRLF
		cQueryRem	+= " J1_BAIRRO, J1_COD_MUN, J1_END, J1_ESTADO,  J1_NOME,  J1_PAIS, " + CRLF
		cQueryRem	+= " CC2_MUN, D2_QUANT, "  + CRLF
		cQueryRem	+= " C5_NUM, C5_EMISSAO, C5_CLIENT, C5_LOJAENT, C5_CLIENTE, C5_LOJACLI, C6_DESCRI, C5_XENDENT, C5_XEST, C5_XMUN, C5_XORCOMP, " + CRLF
		cQueryRem	+= " FP_NUMINI, FP_NUMFIM, FP_CAI, FP_DTRESOL, A7_CODCLI, A7_DESCCLI, " + CRLF
		cQueryRem	+= " AH_DESCES, " + CRLF
	//	cQueryRem	+= " SUBSTRING((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XOBS))),1,LEN((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XOBS))))) AS C5_XOBS, "  + CRLF
		cQueryRem	+= " SUBSTRING((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),F2_XOBS))),1,LEN((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),F2_XOBS))))) AS F2_XOBS " + CRLF
		cQueryRem	+= " FROM "+ InitSqlName("SF2") +" SF2  " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SA1") +" SA1 ON (SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ') "  + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SD2") +" SD2 ON (SD2.D2_DOC = SF2.F2_DOC  AND  SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("SB1") +" SB1 ON (SB1.B1_COD = SD2.D2_COD AND SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= " INNER JOIN "+ InitSqlName("CC2") +" CC2 ON (CC2.CC2_CODMUN = SA1.A1_COD_MUN AND CC2.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SC5") +" SC5 ON (SC5.C5_NUM=SD2.D2_PEDIDO AND SC5.C5_FILIAL='"+xFilial("SC5")+"' AND SC5.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SC6") +" SC6 ON (SC6.C6_NUM=SC5.C5_NUM AND SC6.C6_FILIAL='"+xFilial("SC6")+"' AND SC6.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SA7") +" SA7 ON (SA7.A7_CLIENTE = SF2.F2_CLIENTE AND SA7.A7_PRODUTO = SD2.D2_COD AND SA7.A7_FILIAL='"+xFilial("SA7")+"' AND SA7.D_E_L_E_T_=' ') "  + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SFP") +" SFP ON "  + CRLF
		cQueryRem	+= "  (SFP.FP_SERIE=SF2.F2_SERIE AND ( "+cValToChar(VAL(cDocumento))+" BETWEEN CAST(FP_NUMINI as BIGINT) AND CAST(FP_NUMFIM as BIGINT) )  AND SFP.FP_FILIAL='"+xFilial("SFP")+"' AND SFP.D_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT  JOIN ( SELECT A1_BAIRRO AS J1_BAIRRO,  A1_COD_MUN AS J1_COD_MUN, A1_END AS J1_END, A1_ESTADO AS J1_ESTADO, A1_NOME AS J1_NOME, A1_PAIS AS J1_PAIS, A1_COD AS J1_COD, A1_LOJA AS J1_LOJA, A1_FILIAL AS J1_FILIAL, D_E_L_E_T_ AS JD_E_L_E_T_ FROM "+ InitSqlName("SA1")+" SA1 )" + CRLF
		cQueryRem	+= "   XX1 ON (XX1.J1_COD = SC5.C5_CLIENT  AND XX1.J1_LOJA=SC5.C5_LOJAENT AND XX1.J1_FILIAL='"+xFilial("SA1")+"' AND XX1.JD_E_L_E_T_=' ') " + CRLF
		cQueryRem	+= "  LEFT JOIN "+ InitSqlName("SAH") +" SAH ON (SB1.B1_UM=SAH.AH_UNIMED AND SAH.D_E_L_E_T_=' '  )" + CRLF
		cQueryRem	+= " WHERE (SF2.F2_ESPECIE='RFN ' OR SF2.F2_ESPECIE='RTF ' ) AND F2_DOC='"+cDocumento+"' AND F2_FILIAL='"+xFilial('SF2')+"'AND F2_SERIE='"+cSerie+"' AND SF2.D_E_L_E_T_=' '" + CRLF

	EndIf
	/*
	DEFINE MSDIALOG oDlg TITLE "QUERY" FROM 0,0 TO 555,650 PIXEL
	     @ 005, 005 GET oMemo VAR cqueryRem MEMO SIZE 315, 250 OF oDlg PIXEL
	     @ 260, 230 Button "CANCELAR" Size 035, 015 PIXEL OF oDlg Action oDlg:End()	     
	ACTIVATE MSDIALOG oDlg CENTERED
	*/
Return cQueryRem


/*/{Protheus.doc} zMemoToA
Função Memo To Array, que quebra um texto em um array conforme número de colunas
@author Atilio
@since 15/08/2014
@version 1.0
    @param cTexto, Caracter, Texto que será quebrado (campo MEMO)
    @param nMaxCol, Numérico, Coluna máxima permitida de caracteres por linha
    @param cQuebra, Caracter, Quebra adicional, forçando a quebra de linha além do enter (por exemplo '<br>')
    @param lTiraBra, Lógico, Define se em toda linha será retirado os espaços em branco (Alltrim)
    @return nMaxLin, Número de linhas do array
    @example
    cCampoMemo := SB1->B1_X_TST
    nCol        := 200
    aDados      := u_zMemoToA(cCampoMemo, nCol)
    @obs Difere da MemoLine(), pois já retorna um Array pronto para impressão
/*/
 
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


Static Function ImpMemo(oPrinter,aTexto, nLinMemo, nColumna, nAncho, nAlto, oFont1, nAlinV, nAlinH, lSaltoObl, nLCorteObl)
	Local nActual	:= 0
	Local nLinLoc	:= 0
	//Local lSalto	:= .F.
	Local nLinTmp	:= 0
	Default lSaltoObl := .T.
	Default nLCorteObl := 200
    For nActual := 1 To Len(aTexto)
		if aTexto[nActual]==""
			EXIT
		endif
    	nLinLoc += 1
    	nLinTmp := nLinMemo+(nLinLoc*nAlto)-nAlto
    	oPrinter:SayAlign(nLinTmp, nColumna, aTexto[nActual], oFont1, nAncho, nAlto,CLR_BLACK, nAlinV, nAlinH )
    Next
Return nLinLoc
