#include 'totvs.ch'
#include 'rptdef.ch'
#include 'rwmake.ch'
#include 'FWPrintSetup.ch'
#include 'FWMVCDEF.CH'
#include 'AcmeDef.ch'
#include 'TOPCONN.CH'

/*
+---------------------------------------------------------------------------+
| Programa  #    ACMRP1A       |Autor  |                |Fecha |  10/12/2019|
+---------------------------------------------------------------------------+
| Desc.     #  Función  Remision de salida de Productos DESPACHO A CLIENTES |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # u_ACMRP2X()                                                   |
+---------------------------------------------------------------------------+
*/
User Function PRGPVTA()

	Local cAliasTMP					:= GetNextAlias()
	Local oTempTable 
	Local aStrut					:= {}
	Local aCampos					:= {}
	Local aIndexSF2					:= {}
	Private cMarca					:= cValToChar(Randomize(10,99))
	Private cFiltro					:= ""
	Private cRealNames				:= ""
	Private cCadastro 				:= "Generación de PDF Proforma Pedido de Venta"
	fFilAcm2(@cFiltro)
	
	If EMPTY(cFiltro)
		Return
	EndIf

	// Crear campos temporeales nuevo 
	AAdd( aStrut, {"C5OK"			,"C",02							,0})
	AAdd( aStrut, {"C5PEDIDO"		,"C",TamSX3("C5_NUM")[1]		,2})
	AAdd( aStrut, {"C5CLIENTE"		,"C",TamSX3("C5_CLIENTE")[1]	,0})
	AAdd( aStrut, {"C5TIENDA"		,"C",TamSX3("C5_LOJACLI")[1]	,0})
	AAdd( aStrut, {"C5NATUREZ"		,"C",TamSX3("C5_NATUREZ")[1]	,0})
	AAdd( aStrut, {"C5TIPOPE"		,"C",TamSX3("C5_TIPOPE")[1]		,0})

	oTempTable 	:= FWTemporaryTable():New( cAliasTMP )
	oTempTable:SetFields( aStrut )
	oTempTable:AddIndex("indice1",{"C5PEDIDO"})
	oTempTable:AddIndex("indice2",{"C5CLIENTE"},{"C5TIENDA"})
	oTempTable:Create()

	// Query para llenado de tabla temporal nuevo
	cQryBw	:= "INSERT INTO "+ oTempTable:GetRealName()
	cQryBw	+= " (C5PEDIDO, C5CLIENTE, C5TIENDA, C5NATUREZ, C5TIPOPE) "
	cQryBw	+= " SELECT "
	cQryBw	+= " C5_NUM AS C5PEDIDO, C5_CLIENTE AS C5CLIENTE, C5_LOJACLI AS C5TIENDA, C5_NATUREZ AS C5NATUREZ, "
	cQryBw	+= " C5_TIPOPE AS C5TIPOPE " + CRLF
	cQryBw	+= " FROM " + InitSqlName("SC5") +" SC5 " + CRLF
	cQryBw	+= " WHERE " + CRLF 
	cQryBw 	+= " (C5_EMISSAO 	between '"+ DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"') AND "  +CRLF
	cQryBw 	+= " (C5_NUM 		between '"+ MV_PAR04+"' AND '"+MV_PAR05+"') AND "  +CRLF
	cQryBw 	+= " (C5_CLIENTE 	between '"+ MV_PAR06+"' AND '"+MV_PAR07+"') AND "  +CRLF
	cQryBw 	+= " (C5_LOJACLI 	between '"+ MV_PAR08+"' AND '"+MV_PAR09+"') AND "  +CRLF
	cQryBw 	+= " SC5.D_E_L_E_T_<>'*' AND C5_FILIAL = '"+xFilial("SC5")+"' "  +CRLF

	TcSqlExec(cQryBw)
	
	aCampos := {}
	AAdd( aCampos,{"C5PEDIDO"		,"C","Num. Pedido"		,"@!S"+cValToChar(TamSX3("C5_NUM")[1])			,"0"})
	AAdd( aCampos,{"C5CLIENTE"		,"C","Cliente"		    ,"@!S"+cValToChar(TamSX3("C5_CLIENTE")[1])		,"0"})
	AAdd( aCampos,{"C5TIENDA"		,"C","Tienda"		    ,"@!S"+cValToChar(TamSX3("C5_LOJACLI")[1])		,"0"})
	AAdd( aCampos,{"C5NATUREZ"		,"C","Modalidad"		,"@!S"+cValToChar(TamSX3("C5_NATUREZ")[1])		,"0"})
	AAdd( aCampos,{"C5TIPOPE"		,"C","Tipo Operacion"   ,"@!S"+cValToChar(TamSX3("C5_TIPOPE")[1])		,"0"})


	aRotina := {{"Genera PDFs "		, 	'U_ACMRP2X()',	0,3}}

	cRealAlias:=oTempTable:GetAlias()
	cRealNames:=oTempTable:GetRealName()
	dbSelectArea(cRealAlias)
	dbSetOrder(1)
	cMarca:=GETMARK(,cRealAlias,"C5OK")
	cFiltroSF2 	:= ''
	bFiltraBrw	:=	{|| FilBrowse(cRealAlias,@aIndexSF2,cFiltroSF2)}
	Eval( bFiltraBrw )
	MarkBrow(cRealAlias,"C5OK",,aCampos,.F.,cMarca)
	EndFilBrw(cRealAlias,@aIndexSF2)
	dbCloseArea(cRealAlias)
	oTempTable:Delete()


	
Return 

/*
+---------------------------------------------------------------------------+
| Programa  #   ACMRP2X       |Autor  |                 |Fecha |  10/12/2019|
+---------------------------------------------------------------------------+
| Desc.     #  Función que busca los marcados pata generar           |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # AP                                                            |
+---------------------------------------------------------------------------+
*/
User Function ACMRP2X()
	Local cAliasImp	:= GetNextAlias()

	Local cQueryMarca := " SELECT C5PEDIDO, C5CLIENTE, C5TIENDA, C5NATUREZ  FROM  " + cRealNames + " C5TMP  WHERE C5OK='"+cMarca+"'"
	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQueryMarca) ,cAliasImp,.T.,.T.)
	DbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())
	While (cAliasImp)->(!EOF())
		u_ACMRP2K((cAliasImp)->C5PEDIDO,(cAliasImp)->C5CLIENTE,(cAliasImp)->C5TIENDA,(cAliasImp)->C5NATUREZ)
		(cAliasImp)->(DbSkip())
	EndDO
Return

/*
+---------------------------------------------------------------------------+
| Programa  #   fFilAcm2       |Autor  | Axel Diaz      |Fecha |  10/12/2019|
+---------------------------------------------------------------------------+
| Desc.     #  Función que muestra grupo de preguntas al ingresar          |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # AP                                                            |
+---------------------------------------------------------------------------+
*/
Static Function fFilAcm2(cFiltro)
	Local cPerg := "ACMRP2N"
	ACMPREG1(cPerg)			// Inicializa SX1 para preguntas	
	If Pergunte(cPerg)
		cFiltro := "C5->C5_EMISSAO >='"+DTOS(MV_PAR02)+"' .AND. "
		cFiltro += "C5->C5_EMISSAO <='"+DTOS(MV_PAR03)+"' .AND. "
		cFiltro += "C5->C5_NUM >='"+MV_PAR04+"' .AND. "
		cFiltro += "C5->C5_NUM <='"+MV_PAR05+"' .AND."
		cFiltro += "C5->C5_CLIENTE >='"+MV_PAR06+"' .AND."	
		cFiltro += "C5->C5_CLIENTE <='"+MV_PAR07+"' .AND."	
		cFiltro += "C5->C5_LOJACLI >='"+MV_PAR08+"' .AND."	
		cFiltro += "C5->C5_LOJACLI >='"+MV_PAR09+"' "	
	Else
		cFiltro := ""
	EndIf	
Return ()
/*
+===========================================================================+
| Programa  # ACMRP2    |Autor  | Axel Diaz         |Fecha |  10/12/2019    |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones                         |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_ACMRP2K()                                                  |
+===========================================================================+
*/
User Function ACMRP2K(cPedido, cCliente, cTienda, cModalidad)
	Local cFilName 			:= 'Proforma_' + UPPER(AllTrim(cPedido))
	Local cQry				:= ""
	Local cPath				:= ALLTRIM(MV_PAR10)
	Local nPixelX 			:= 0
	Local nPixelY 			:= 0
	Local nHPage 			:= 0
	Local nVPage 			:= 0
	Private cpedidoqry		:= ""
	Private ctiendaqry 		:= ""
	Private cclienteqry 		:= ""


	Private cRem			:= GetNextAlias()
	Private nFontAlto		:= 44
	Private oPrinter
	Private nLineasPag		:= 56			// <----- cantidad de lineas en el GRID
	Private nPagNum			:= 0
	Private nItemRegistro	:= 0			// Item del Registro
	Private oCouNew10		:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	Private oCouNew11		:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)
	Private oCouNew10N		:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	Private oCouNew11N		:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)
	Private oArial10 		:= TFont():New("Arial"		,10,10,,.F.,,,,.T.,.F.)
	Private oArial11 		:= TFont():New("Arial"		,11,11,,.F.,,,,.T.,.F.)
	Private oArial12 		:= TFont():New("Arial"		,12,12,,.F.,,,,.T.,.F.)
	Private oArial10N		:= TFont():New("Arial"      ,10,10,,.T.,,,,.F.,.F.)
	Private oArial12N		:= TFont():New("Arial"      ,12,12,,.T.,,,,.F.,.F.)
	Private oArial14N		:= TFont():New("Arial"      ,14,14,,.T.,,,,.F.,.F.)
	Private oArial11N		:= TFont():New("Arial"      ,11,11,,.T.,,,,.F.,.F.)

	Default cPedido			:= '000000'
	Default cCliente		:= '000000000000001'
	Default cLoja			:= '01'

	
	cQry			:= 	TipoQuery(MV_PAR01,cPedido,cCliente, cLoja)

	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQry) ,cRem,.T.,.T.)
	DbSelectArea(cRem)
	(cRem)->(DbGoTop())


	If Empty((cRem)->C5_NUM)
		MsgAlert("El pedido seleccionado no puede ser Impreso, dado que algunos datos relacionados fueron eliminados, Revise la existencia de los Producto, del Cliente, de los maestros.")
		Return
	EndIf
	
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

	cpedidoqry	= Alltrim((cRem)->C5_NUM)
	cclienteqry = AllTrim((cRem)->C5_CLIENTE)
	ctiendaqry 	= AllTrim((cRem)->C5_LOJACLI)

	AcmHeadPR() //[cabecero]

	Private AliasQDetail  := "AliasQDetail"
	QryDetalle(cpedidoqry, cclienteqry, ctiendaqry)

	AcmDtaiPR() // [detalle]

	AliasQDetail->(DbCloseArea())

	AcmFootPR() // [pie de pagina]

	oPrinter:EndPage()
	oPrinter:Print()
	FreeObj(oPrinter)
	(cRem)->(DbCloseArea())

Return
/*
+===========================================================================+
| Programa  # AcmHeadPR    |Autor  | Axel Diaz      |Fecha |  10/12/2019    |
+===========================================================================+
| Desc.     #  Función para Impresion de Remisiones EMCABEZADO              |
|           #                                                               |
+===========================================================================+
| Uso       # 	@example                                                    |
|           #   u_AcmHeadPR()                                               |
+===========================================================================+
*/
Static Function AcmHeadPR()


	Local cRfc			:= Alltrim(SM0->M0_CGC)
	Local i 			:= 0
	Local nspace 		:= 0
	Local tamtexto 		:= 0
	Local cFileLogo		:= GetSrvProfString("Startpath","") +"xlogox"+cEmpAnt+".bmp"
	Local n1Linea		:= 10
	local nMargIqz		:= 10
	local nLinea		:= 1
	Local nLinebox1		:= 0
	Local nLinebox2		:= 0
	Local nLinebox3		:= 0
	Local cPedIMP		:= (cRem)->C5_NUM
	//Local dfecha 		:= Date()
	//Local cfecha 		:= DTOC(dfecha)
	Private aliasmemoqry	:= "aliasmemoqry"
	
	QueryclienteN(cclienteqry)

		cNomeCliente	:= Alltrim(VW_OTRR->A1_NOME)
		cEndCliente		:= Alltrim(VW_OTRR->A1_END)
		cBarrio			:= Alltrim(VW_OTRR->A1_BAIRRO)
		cEstado 		:= Alltrim(VW_OTRR->A1_ESTADO)
		cA1cod			:=  Alltrim(VW_OTRR->A1_OBS)

	VW_OTRR->(DBCLOSEAREA())

	nPagNum++
	cRfc := substr(cRfc,1,3)+"."+substr(cRfc,4,3)+"."+substr(cRfc,7,3)+"-"+substr(cRfc,10,1)
	IF "01" $ cEmpAnt
		oPrinter:SayBitmap(-10,10,cFileLogo,500,200)  // Logo
	Else
		oPrinter:SayBitmap(50,10,cFileLogo,500,200)  // Logo
	EndIf
				//oPrinter:SayBitmap(-80,10,"C:\TOTVS\PROGEN\Facturacion\Formatos\logoprogen.png",400,400)  // Logo
	            oPrinter:Say(n1Linea							,2140			, AcmePagina + STRZERO(nPagNum,3)	,	oArial12,,,,2)
				oPrinter:Box(n1Linea+(nFontAlto*nLinea)-5		,nMargIqz+1490,nFontAlto*3,2250,"-8")
				//oPrinter:Box(n1Linea+(nFontAlto*nLinea)-5		,1840,nFontAlto*3,2250,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)-8		,nMargIqz+1500	, "PRO-FORMA "  					,	oArial14N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)-8		,nMargIqz+1900	, cPedIMP						    ,	oArial14N,,,,2)

	
	IF "01" $ cEmpAnt

		nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)+10		,nMargIqz+1500	, "AGENTE RETENEDOR DE IVA GRAN CONTRIBUYENTE"  		,	oArial11N,,,,2)					
		nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)+10		,nMargIqz+1500	, "Resolución 41 de Enero 30/2014"  					,	oArial11,,,,2)					
		nLinea ++
		nLinea ++; oPrinter:Say(n1Linea+(nFontAlto*nLinea)-8		,nMargIqz+1700	, "www.progen.com.co"  					,	oArial12,,,,2)
		nLinea ++; oPrinter:Say(n1Linea+(nFontAlto*nLinea)-8		,nMargIqz+1698	, "www.royalcondor.com"  					,	oArial12,,,,2)
	else
		nLinea +=5
	EndIf
	
	nLinea = nLinea+1
				oPrinter:Box(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1490,nFontAlto*13,1800,)
				oPrinter:Box(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1790,nFontAlto*13,2250,)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1500	, "Fecha" 					    ,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1810	, fecha((cRem)->C5_EMISSAO," ")	    			,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
				
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1500	, "Su N° de orden" 						,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1810	, AllTrim((cRem)->C5_XORCOMP)			,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1500	, "Terminos de pago" 					,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1810	, AllTrim((cRem)->E4_COND) +" DIAS" 	,	oArial12,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1500	, "Nuestra Referencia"				,	oArial12N,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1810	, substr(AllTrim((cRem)->A3_NOME),1,26),	oArial11,,,,2)
				oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10		,nMargIqz+1490,n1Linea+(nFontAlto*nLinea)-10,2250,,)
				// If len(AllTrim((cRem)->A3_NOME))>24
				// 	nLinea ++
				// 	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1820	, substr(AllTrim((cRem)->A3_NOME),25,50),	oArial11,,,,2)
				// 	nLinea --
				// EndIf

	nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1810	, substr(AllTrim((cRem)->A3_EMAIL),1,33),	oArial11,,,,2)

				// If len(AllTrim((cRem)->A3_EMAIL))>24
				// 	nLinea ++
				// 	oPrinter:Say(n1Linea+(nFontAlto*nLinea)			,nMargIqz+1820	, substr(AllTrim((cRem)->A3_EMAIL),31,60),	oArial11,,,,2)
				// 	nLinea --
				// EndIf

	 nLinea --			


	IF "01" $ cEmpAnt

		nLinebox2 = 5
						
		nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2,nMargIqz+50,"NIT: 8600163109",	oArial11N,,,,2)
		nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2,nMargIqz+50,"PRODUCTOR - IMPORTADOR",	oArial11N,,,,2)
		nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2,nMargIqz+50,"RESPONSABLE I.V.A. - REGIMEN COMUN",	oArial11N,,,,2)
		nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2,nMargIqz+50,"REGISTRO 993-040",	oArial11N,,,,2)
	else
		nLinebox2 +=9
	EndIf


					oPrinter:Box(nFontAlto*10	,nMargIqz+30,nFontAlto*11,800,"-8")
					oPrinter:Box(nFontAlto*11	,nMargIqz+30,nFontAlto*15,1450,"-8")
	nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+50,"CODIGO CLIENTE",	oArial12n,,,,2)
					Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+350,(cRem)->C5_CLIENTE,	oArial12n,,,,2)
	nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+50,cNomeCliente,	oArial12,,,,2)
	//nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+50,cEndCliente,	oArial12,,,,2)
	nLinebox2+=0.3
	nLinebox2+=ImpMemo(oPrinter,zMemoToA(cEndCliente,70)	,nFontAlto*nLinebox2+7 , nMargIqz+50, 1400 	, nFontAlto-5	, oArial12	, 0			,0)
	nLinebox2+=0.3;	Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+50,cBarrio+" - "+cEstado,	oArial12,,,,2)
	// nLinebox2 ++;	Oprinter:Say(nFontAlto*nLinebox2+15,nMargIqz+50,cEstado,	oArial12,,,,2)

	
	nLinebox2 = 2
	IF "01" $ cEmpAnt

		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"PROGEN S.A"							,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"Carrera 3 No.56-07"					,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"Zona Industrial Cazuca Entrada No.2" ,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"Soacha Cundinamarca - Colombia"		,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"PBX:730 6100 DIRECTO VENTAS:7306111" ,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+700,"FAX:730 6110 - 730 6090"				,	oArial12,,,,2)
	else

		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"Domicilio Fiscal"							,	oArial12N,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"Empoala 251-piso 10, col, Narvarte CD. Ciudad de México,"					,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"C.P. 03020, Benito juarez, Ciudad de México, México" ,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"Bodega:"		,	oArial12N,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"Calle Carretera Federal Puebla  Tlaxcala no. 242 NAVE 5," ,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"Colonia San Pablo XOCHIMEHUACAN C.P. 72014 Puebla"				,	oArial12,,,,2)
		nLinebox1 ++;	Oprinter:Say(nFontAlto*nLinebox1,nMargIqz+650,"México"				,	oArial12,,,,2)

	EndIf

	nLinebox3 = 14.5
					oPrinter:Box(nFontAlto*15	,nMargIqz+30,(nFontAlto*23)-5,2250,"-8")
	Qrymemovirtual(cA1cod)
	/*El while imprime las observaciones del cliente A1_VM_OBS*/
	while (!((aliasmemoqry)->(EOF())))
		i++
		cObservacion := AllTrim(STRTRAN(aliasmemoqry->YP_TEXTO,"\13\10",""))
		
		if (i>3)
			nspace = nspace + 14*tamtexto
			Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50+nspace," -- "+cObservacion,	oArial11,,,,2)
			tamtexto = Len(cObservacion)	
		else
		nLinebox3 ++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50,cObservacion,	oArial11,,,,2)
		tamtexto 	= LEN(cObservacion)
		endif
		(aliasmemoqry)->(dbSkip())
	end
	(aliasmemoqry)->(DBCLOSEAREA())
	nLinebox3++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50,"INCOTERMS / TERMINO DE NEGOCIACION: " + SUBSTR( AllTrim((cRem)->C5_INCOTER)+" - "+ AllTrim((cRem)->C5_XPUERTO)+" "+ AllTrim((cRem)->TEXCLI), 1, 103),	oArial11,,,,2)
	
	If len(AllTrim((cRem)->TEXCLI))>97
		nLinebox3++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50, SUBSTR(AllTrim((cRem)->C5_INCOTER)+" - "+AllTrim((cRem)->C5_XPUERTO)+" "+AllTrim((cRem)->TEXCLI), 104, 137),	oArial11,,,,2)
		If len(AllTrim((cRem)->TEXCLI))>140
			nLinebox3++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50, SUBSTR(AllTrim((cRem)->C5_INCOTER)+" - "+AllTrim((cRem)->C5_XPUERTO)+" "+AllTrim((cRem)->TEXCLI), 241, 137),	oArial11,,,,2)
			If len(AllTrim((cRem)->TEXCLI))>365
				nLinebox3++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50, SUBSTR(AllTrim((cRem)->C5_INCOTER)+" - "+AllTrim((cRem)->C5_XPUERTO)+" "+AllTrim((cRem)->TEXCLI), 378, 137),	oArial11,,,,2)
			EndIf
		EndIf
	EndIf

	
	nLinebox3++;	Oprinter:Say(nFontAlto*nLinebox3,nMargIqz+50,"CURRENCY / MONEDA: " +AllTrim((cRem)->CTO_SIMB) + " " + AllTrim((cRem)->CTO_DESC),	oArial11,,,,2)
	//nLinebox3+= ImpMemo(oPrinter,zMemoToA(AllTrim((cRem)->C5_MENNOTA), 130)	, nFontAlto*nLinebox3 , nMargIqz+50, 2100  	, nFontAlto	, oArial12	, 0			,0)
	nLinebox3+=ImpMemo(oPrinter,zMemoToA(AllTrim((cRem)->C5_MENNOTA),130)	,nFontAlto*nLinebox3+15 , nMargIqz+50, 2280 	, nFontAlto-5	, oArial11	, 0			,0)
	
	nLinea +=	11
				oPrinter:Box((nFontAlto*23)-5	,nMargIqz+30,(nFontAlto*24),2250,"-8")
	nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+50	, "ITEM"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1200	, "CANTIDAD"										,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1500	, "UNID"										    ,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1700	, "PRECIO"											,	oArial12n,,,,2)
				oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2000	, "VALOR"										,	oArial12n,,,,2)
	nLinea ++;	oPrinter:Line(n1Linea+(nFontAlto*nLinea)-10,0,n1Linea+(nFontAlto*nLinea), 2400,,"-8")
	nLinea +=	0.5;

	
Return
/*
+===========================================================================+
| Programa  # AcmDtaiPR    |Autor  | Axel Diaz      |Fecha |  10/12/2019    |
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
	local precio_acumulado 	:= 0

	nLinea += 13
	While (!((AliasQDetail)->(EOF())))



		cCanIMP	:= AllTrim(TRANSFORM((AliasQDetail)->C6_VALOR,"@E 999,999,999.99"))
		precio_acumulado = precio_acumulado + (AliasQDetail)->C6_VALOR
		nLinea += 0.5;

		nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+30	, (AliasQDetail)->C6_PRODUTO						,	oArial11,,,,2)
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1250	, cValToChar((AliasQDetail)->C6_QTDVEN)				,	oArial11,,,,2)
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1510	, (AliasQDetail)->C6_UM			,	oArial12,,,,2)
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1700	, AllTrim(TRANSFORM((AliasQDetail)->C6_PRCVEN,"@E 999,999,999.99"))	,	oArial11,,,,2)
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2000	, 	cCanIMP											,	oArial11,,,,2)
		nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+100	, (AliasQDetail)->C6_DESCRI							,	oArial11,,,,2)

		if Alltrim((AliasQDetail)->XDESCRI) <>"" 
			//nLinea++; oPrinter:Say((n1Linea)+(nFontAlto*nLinea)	,nMargIqz+3	, ">"								,	oArial12,,,,2); nLinea--
			nLinea+=0.5	/*oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+10	, (cQueryx)->XDESCRI	,	oArial12,,,,2)*/
			nLinea +=ImpMemo(oPrinter,zMemoToA( "> "+(AliasQDetail)->XDESCRI, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)
		endif

		if Alltrim(AliasQDetail->A7_CODCLI) <>"" .OR. Alltrim(AliasQDetail->A7_DESCCLI) <> ""

			nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+30	, "Su item..... "						,	oArial11N,,,,2)
						oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQDetail->A7_CODCLI				,	oArial11N,,,,2)
			nLinea ++;	oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+300	, AliasQDetail->A7_DESCCLI				,	oArial11N,,,,2)
			if Alltrim((AliasQDetail)->OBS) <>"" 
				nLinea +=0.5
				nLinea +=ImpMemo(oPrinter,zMemoToA( "+ "+(AliasQDetail)->OBS, 80)	,n1Linea+(nFontAlto*nLinea) , nMargIqz+25, 1100  	, nFontAlto	, oArial12	, 0			,0)
			endif
		endif

		(AliasQDetail)->(dbSkip())
		If !((AliasQDetail)->(EOF())) .and. nLinea > nLineasPag
				//AcmFootPR(cTipo)
				AcmFootPR()
				oPrinter:EndPage()
				oPrinter:StartPage()
				//AcmHeadPR(cTipo,.T.)
				AcmHeadPR()
				nLinea:=22.5
		EndIf

		if ((AliasQDetail)->(EOF()))

			If nLinea>nLineasPag
			AcmFootPR()
			oPrinter:EndPage()
			oPrinter:StartPage()
			AcmHeadPR()

		nLinea:=21.5
		EndIf

		nLinea++
		nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1300	, "LINEA TOTAL ORDEN :"						,	oArial12N,,,,2)
					oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2000	, AllTrim(TRANSFORM(precio_acumulado,"@E 999,999,999,999.99")),	oArial12N,,,,2)
		// nLinea ++;  oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+1300	, "TOTAL  USD : "						,	oArial12N,,,,2)	
		// 			oPrinter:Say(n1Linea+(nFontAlto*nLinea)	,nMargIqz+2000	, AllTrim(TRANSFORM(precio_acumulado,"@E 999,999,999,999.99")),	oArial12N,,,,2)		
		endif	
	EndDo
	
Return
/*
+===========================================================================+
| Programa  # AcmFootPR    |Autor  | Axel Diaz      |Fecha |  10/12/2019    |
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
	local nMargIqz		:= 50
	local nLinea		:= 70
	//Local nMargDer		:= 2400-10
	Default lSaltoPagina:=.F.
	
	
	IF !lSaltoPagina
		(cRem)->(DbGoTop())
	EndIf
	cRespon	:= ALLTRIM("")

	IF "01" $ cEmpAnt			
		nLinea =61
					oPrinter:Line(n1Linea+(nFontAlto*nLinea),0,n1Linea+(nFontAlto*nLinea), 2400,,"-8")
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"PROGEN S.A"							,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Carrera 3 No.56-07"					,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Zona Industrial Cazuca Entrada No.2"	,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Soacha Cundinamarca - Colombia"		,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"PBX:730 6100 DIRECTO VENTAS:7306111"	,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"FAX:730 6110 - 730 6090"				,	oArial11,,,,2)

		nLinea = 61

		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+750,"PRODUCTOR - IMPORTADOR"					,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+650,"RESPONSABLE I.V.A. - REGIMEN COMUN"		,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+750,"REGISTRO 993-040"						,	oArial11N,,,,2)
		nLinea ++
		nLinea ++; 	oPrinter:Say(nFontAlto*nLinea,nMargIqz+750, "www.progen.com.co"  					,	oArial11,,,,2)
		nLinea ++; 	oPrinter:Say(nFontAlto*nLinea,nMargIqz+750, "www.royalcondor.com"  					,	oArial11,,,,2)

		nLinea = 61

		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1300,"AGENTE RETENEDOR DE IVA GRAN CONTRIBUYENTE"						,	oArial12N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1400,"Resolución 41 de Enero 30/2014"									,	oArial11N,,,,2)
		nLinea ++
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1400,"Actividad Económica Principal 2821"								,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1200,"NO EFECTUAR RETENCIÓN A TITULO DE RENTA E IMPUESTO CREE"			,	oArial12N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1200,"SOMOS AUTORRETENEDORES Res.000041 Julio 16/92"						,	oArial14N,,,,2)
	else
				nLinea =61
					oPrinter:Line(n1Linea+(nFontAlto*nLinea),0,n1Linea+(nFontAlto*nLinea), 2400,,"-8")
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Domicilio Fiscal"					,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Empoala 251-piso 10, col, Narvarte CD. Ciudad de México,"					,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"C.P. 03020, Benito juarez, Ciudad de México, México"	,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Bodega:"		,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Calle Carretera Federal Puebla  Tlaxcala no. 242 NAVE 5,"	,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"Colonia San Pablo XOCHIMEHUACAN C.P. 72014 Puebla"				,	oArial11,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+50,"México"				,	oArial11,,,,2)

		nLinea = 61

		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1200,"RFC EMISOR"					,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1200,"No. De Series del CSD"		,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1200,"RÉGIMEN FISCAL"						,	oArial11N,,,,2)

		nLinea = 61

		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1700,"TIER050426R62"						,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1700,"00001000000505551459"									,	oArial11N,,,,2)
		nLinea ++;	Oprinter:Say(nFontAlto*nLinea,nMargIqz+1700,"General de Ley Pesonas Morales"								,	oArial11N,,,,2)

	EndIf
Return
/*
+===========================================================================+
| Programa  # RQuery    |Autor  | Axel Diaz      |Fecha |  10/12/2019       |
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
		// Query trae datos del cliente de entrega
	If Select("cQueryx") > 0
		dbSelectArea("cQueryx")
		dbCloseArea()
	Endif

		cQrylotser:=" SELECT  " + CRLF
		cQrylotser+=" D2_PEDIDO, D2_COD, B1_DESC, D2_QUANT, D2_SERIE, D2_LOTECTL, D2_DOC, C6_SERIE, C6_LOCAL, C6_CLI, C6_NUMSERI, C6_LOTECTL, D2_NUMLOTE, D2_NUMSERI, D2_LOJA, " + CRLF
		cQrylotser+=" ISNULL(CAST(CAST(B1_XDESCRI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS XDESCRI, C6_CODINF , ISNULL(CAST(CAST(C6_VDOBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') OBS" + CRLF
		//cQrylotser+=" ISNULL(CAST(CAST(B.C6_INFAD AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS INFAD " + CRLF
		cQrylotser+=" FROM "+ InitSqlName("SD2") +" SD2 " + CRLF
		cQrylotser+=" INNER JOIN "+ InitSqlName("SB1") +" SB1 ON  " + CRLF
		cQrylotser+=" D2_COD = B1_COD  AND SB1.D_E_L_E_T_='' " + CRLF
		cQrylotser+=" INNER JOIN "+ InitSqlName("SC6") +" B ON  " + CRLF
		cQrylotser+=" B.C6_NUM = D2_PEDIDO AND B.C6_PRODUTO = D2_COD AND B.D_E_L_E_T_='' " + CRLF
		//cQrylotser+=" INNER JOIN "+ InitSqlName("SDC") +" SDC ON  " + CRLF
		//cQrylotser+=" SDC.D_E_L_E_T_=' ' AND DC_PEDIDO = D2_PEDIDO " + CRLF
		cQrylotser+=" WHERE" + CRLF
		cQrylotser+=" SD2.D_E_L_E_T_='' AND D2_PEDIDO='" +pedido+ "' AND D2_DOC= '"+documentox+"' "+ CRLF
		cQrylotser+=" AND D2_SERIE='"+seriex+ "' " + CRLF
		
	TCQuery cQrylotser New Alias "cQueryx"

Return


// query para buscar los campo observaciones de cliente tipo virtual (A1_VM_OBS) de cada producto
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
	memoquery+=" A.D_E_L_E_T_ <>'*' AND A.YP_CHAVE='"+chave+"' AND A.YP_CAMPO='A1_OBS' " + CRLF

	TCQuery memoquery New Alias aliasmemoqry

Return 

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


/*
Este query lista el detalle del pedido de venta, es decir, muestra la informacion principal de la 
tabla SC6
*/
Static Function QryDetalle (cPedido, cCliente, cTienda)

Local cQryDetail := ""

if SELECT("AliasQDetail")>0
	DbSelectArea("AliasQDetail")
	DBCLOSEAREA()

endif
cQryDetail:= "SELECT C6_NUM, C6_PRODUTO, ISNULL(CAST(CAST(C6_VDOBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS , C6_DESCRI, C6_PRCVEN, C6_QTDVEN, C6_VALOR, C6_LOJA, C6_CLI, C6_LOCAL, C6_UM, " 
cQryDetail+= "A7_CODCLI, A7_DESCCLI,   " + CRLF
cQryDetail+= " ISNULL(CAST(CAST(C.B1_XDESCRI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS XDESCRI " + CRLF
cQryDetail+= "FROM "+InitSqlName("SC6")+" A "  + CRLF
cQryDetail+= "LEFT JOIN "+InitSqlName("SA7")+" B ON A.C6_PRODUTO=B.A7_PRODUTO AND A.C6_LOJA=B.A7_LOJA AND A.C6_CLI=B.A7_CLIENTE AND B.D_E_L_E_T_<>'*' "  + CRLF
cQryDetail+= "LEFT JOIN "+InitSqlName("SB1")+" C ON A.C6_PRODUTO = C.B1_COD AND C.D_E_L_E_T_ <>'*' "  + CRLF
cQryDetail+= "WHERE A.C6_NUM = '"+cPedido+"' AND A.C6_LOJA='"+cTienda+"'  AND A.C6_CLI =  '"+cCliente+"'  AND A.D_E_L_E_T_ <>'*' " + CRLF

TCQuery cQryDetail New Alias AliasQDetail

return

/*
+===========================================================================+
| Programa  # FECHA     |Autor  | Axel Diaz      |Fecha |  10/12/2019       |
+===========================================================================+
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
|  Programa  |AjustaSX1            |Autor  |Axe Diaz |Data    06/01/2020    |
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
	dbSeek("C5_NUM")
	nLarDoc:=SX3->X3_TAMANHO
	dbSeek("F2_SERIE")
	nLarSer:=SX3->X3_TAMANHO
	dbSeek("F2_CLIENTE")
	nLarFor:=SX3->X3_TAMANHO
	dbSeek("F2_LOJA")
	nLarLoj:=SX3->X3_TAMANHO
	dbCloseArea("SX3")

	aAdd(aRegs,{cPerg,"01","Tipo Documento"		,"Tipo Documento"	,"Tipo Documento"	,"MV_CH01"	,"C"	, 08 		,0,2	,"C"	,"" 															,"MV_PAR01","Profo.Ped.Venta" ,"Profo.Ped.Venta" ,"Profo.Ped.Venta","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02",DEFECHA		,DEFECHA	,DEFECHA	,"MV_CH02"	,"D"	, 08 		,0,2	,"G"	,"" 															,"MV_PAR02","" ,"" ,"" ,"'01/01/20'"				,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03",AFECHA		,AFECHA		,AFECHA		,"MV_CH03"	,"D"	, 08 		,0,2	,"G"	,"!Empty(MV_PAR03) .And. MV_PAR02<=MV_PAR03" 					,"MV_PAR03","" ,"" ,"" ,"'31/12/20'"				,"","","","","","","","","","","","","","","","","","","","","",""})
	// aAdd(aRegs,{cPerg,"04",DESERIE		,DESERIE	,DESERIE	,"MV_CH04"	,"C"	, nLarSer	,0,2	,"G"	,"" 															,"MV_PAR04","" ,"" ,"" ,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
	// aAdd(aRegs,{cPerg,"05",ASERIE		,ASERIE		,ASERIE		,"MV_CH05"	,"C"	, nLarSer	,0,2	,"G"	,"!Empty(MV_PAR05) .And. MV_PAR04<=MV_PAR05"	 				,"MV_PAR05","" ,"" ,"" ,REPLICATE("Z",nLarSer) 		,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","De pedido origen"		,"De pedido origen"		,"De pedido origen"		,"MV_CH04"	,"C"	, nLarDoc	,0,2	,"G"	,"" 															,"MV_PAR04","" ,"" ,"" ,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Hasta pedido origen"			,"Hasta pedido origen"		,"Hasta pedido origen"		,"MV_CH05"	,"C"	, nLarDoc	,0,2	,"G"	,"!Empty(MV_PAR05) .And. MV_PAR04<=MV_PAR05" 					,"MV_PAR05","" ,"" ,"" ,REPLICATE("Z",nLarDoc) 		,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06",DECLIENTE	,DECLIENTE	,DECLIENTE	,"MV_CH06"	,"C"	, nLarFor	,0,2	,"G"	,"" 															,"MV_PAR06","" ,"" ,"" ,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07",ACLIENTE		,ACLIENTE	,ACLIENTE	,"MV_CH07"	,"C"	, nLarFor	,0,2	,"G"	,"!Empty(MV_PAR07) .And. MV_PAR06<=MV_PAR07" 					,"MV_PAR07","" ,"" ,"" ,/*REPLICATE("Z",nLarFor)*/"ZZZZZZZZZZZZZZZ" 		,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08",DETIENDA		,DETIENDA	,DETIENDA	,"MV_CH08"	,"C"	, nLarLoj	,0,2	,"G"	,"" 															,"MV_PAR08","" ,"" ,"" ,"" 							,"","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09",ATIENDA		,ATIENDA	,ATIENDA	,"MV_CH09"	,"C"	, nLarLoj	,0,2	,"G"	,"!Empty(MV_PAR09) .And. MV_PAR08<=MV_PAR09" 					,"MV_PAR09","" ,"" ,"" ,REPLICATE("Z",nLarLoj) 		,"","","","","","","","","","","","","","","","","","","","","",""})		
	aAdd(aRegs,{cPerg,"10",DIRDESTINO	,DIRDESTINO	,DIRDESTINO	,"MV_CH10"	,"C"	, 99		,0,2	,"G"	,"!Vazio().or.(MV_PAR10:=cGetFile('PDFs |*.*','',,,,176,.F.))" 	,"MV_PAR10","" ,"" ,"" ,"C:\SPOOL\"					,"","","","","","","","","","","","","","","","","","","","","",""})
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
|  Programa  Tipoquery Autor  Axel Diaz Fecha 04/06/2018                    |
|                                                                           |
|  Uso       | Signature                                                    |
+===========================================================================+
*/
Static function TipoQuery(cDocQuery,cPedido,cCliente,cTienda )
	Local cQueryRem	:=''
	dbSelectArea("SC5")
	dbSetOrder(3)
	dbGoTop()
	DbSeek( xFilial("SC5") + cCliente + cTienda + cPedido)

	If cDocQuery==1
		cQueryRem	:= " SELECT  "
		cQueryRem	+= " C5_NUM, C5_CLIENTE, C5_EMISSAO, C5_LOJACLI, C5_INCOTER, E4_DESCRI, E4_COND, CTO_MOEDA, CTO_DESC, CTO_SIMB, C5_XORCOMP, A3_NOME, A3_EMAIL, C5_MENNOTA, C5_XPUERTO, " + CRLF
		// cQueryRem	+= " SUBSTRING((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XTEXCLI))),1,LEN((CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_XOBS))))) AS C5_XOBS, "  + CRLF
		cQueryRem	+= " ISNULL(CAST(CAST(C5_XTEXCLI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS TEXCLI "  + CRLF
		cQueryRem	+= " FROM "+ InitSqlName("SC5") +" A  " + CRLF
		cQueryRem	+= " LEFT JOIN "+ InitSqlName("SE4") +" B ON B.E4_CODIGO=A.C5_CONDPAG " + CRLF
		cQueryRem	+= " LEFT JOIN "+ InitSqlName("CTO") +" C ON C.CTO_MOEDA=A.C5_MOEDA " + CRLF
		cQueryRem	+= " LEFT JOIN "+ InitSqlName("SA3") +" D ON D.A3_COD=A.C5_VEND1 " + CRLF
	//	cQueryRem	+= " INNER JOIN "+ InitSqlName("SA1") +" SA1 ON (SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ') "  + CRLF
		cQueryRem	+= " WHERE A.C5_NUM='"+cPedido+"' AND A.C5_FILIAL='"+xFilial('SC5')+"'AND A.C5_LOJACLI='"+cTienda+"' AND A.C5_CLIENTE='"+cCliente+"' AND A.D_E_L_E_T_ <> '*' AND D.D_E_L_E_T_ <> '*' " + CRLF

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
