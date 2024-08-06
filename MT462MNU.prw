#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT462MNU ºAutor  ³Juan Pablo Astorga	  º Data ³  26/10/2022º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE - Para adicionar novas rotinas (botão) em LOCXNF        º±±
±±º          ³ MATA101N/MATA467N ... 					  				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Colombia\PROGEN                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT462MNU


if FUNNAME()=='MATA102DN'
	  	AADD(AROTINA,{ 'Imprimir-Remito Devolucion',"U_ARIFA004()",0,5})	
EndIf
iF  Funname()=="MATA462N"
		AADD(AROTINA,{ 'Modificar Precio/Obs.Pieza','u_SD2Alt(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_DOC,SF2->F2_SERIE)',0,5})	
        AADD(AROTINA,{ 'Seguimiento Guia','u_SD2SEGG(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_DOC,SF2->F2_SERIE)',0,5})	
EndiF
if FUNNAME()=='MATA101N'
	  	AADD(AROTINA,{ 'Pedido Compra',"MATA121()",0,5})
        AADD(AROTINA,{ 'Informe Pedido Compra vs Guia ',"MATR131()",0,5})	
EndIf
iF  Funname()=="MATA467N"
        AADD(AROTINA,{ 'Seguimiento Factura','u_SD2SEFT(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_DOC,SF2->F2_SERIE)',0,5})	
EndiF

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para modificar el precio Unitario GR        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SD2Alt(cCliente,cLoja,cDocumento,cSerie)

Local aArea := GetArea()
Private aHeadSBM := {}
Private aColsSBM := {}
Private oDlgPvt
Private oMsGetSBM
Private oBtnFech
Private oBtnLege
Private nJanLarg   := 1100
Private nJanAltu   := 600
Private cFontUti   := "Tahoma"
Private oFontAno   := TFont():New(cFontUti,,-38)
Private oFontSub   := TFont():New(cFontUti,,-20)
Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
Private oFontBtn   := TFont():New(cFontUti,,-14)
Private ldatos     := .F. 

 //              Título               Campo        Máscara                        Tamanho                   Decimal                   Valid               Usado  Tipo F3     Combo
aAdd(aHeadSBM, {"Item",          	 "D2_ITEM",     "",                             TamSX3("D2_ITEM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",          "D2_COD",      "",                          	TamSX3("D2_COD")[01],      		0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Desc Prod",         "B1_DESC",     "",                             TamSX3("B1_DESC")[01],     		0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad",          "D2_QUANT",    "@E 999,999,999,999,999.99",    TamSX3("D2_QUANT")[01],    		0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Precio",            "D2_PRCVEN",   "@E 999,999,999,999,999.99",    TamSX3("D2_PRCVEN")[01],    	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Total",        	 "D2_TOTAL",    "@E 999,999,999,999,999.99",    TamSX3("D2_TOTAL")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Descuento",         "D2_DESCON",   "@E 999,999,999,999,999.99",    TamSX3("D2_DESCON")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"% Desc",            "D2_DESC",     "@E 999,999.99",                TamSX3("D2_DESC")[01],       	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Precio Lista",      "D2_PRUNIT",   "@E 999,999,999,999,999.99",    TamSX3("D2_PRUNIT")[01],       	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Documento",         "D2_DOC",        "",                           TamSX3("D2_DOC")[01],      	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Pedido",            "D2_PEDIDO",     "",                           TamSX3("D2_PEDIDO")[01],      	0,                        ".T.",          	  ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Item PV",           "D2_ITEMPV",     "",                           TamSX3("D2_ITEMPV")[01],      	0,                        ".T.",          	  ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Obs.Pieza",         "C6_VDOBS",      "",                           TamSX3("C6_VDOBS")[01],      	0,                        ".T.",          	  ".T.", "M", "",    ""} )

Processa({|| fCarAcols(cCliente,cLoja,cDocumento,cSerie,@ldatos)}, "Processando ... Por favor espere ...")
if ldatos=.F.
    Return
else   

DEFINE MSDIALOG oDlgPvt TITLE "Proceso para Modificar el precio unitario en la guia de remision" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
@ 004, 003 SAY "REPROCESO"                SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
@ 004, 150 SAY "Ajuste Precio y "          SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
@ 014, 150 SAY "Obs.Pieza Guia de Remision" SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Salir"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
@ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Guardar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar(cCliente,cLoja,cDocumento,cSerie)) FONT oFontBtn PIXEL
    //Grid dos grupos
    oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
        003,;                //nLeft     - Coluna Inicial
        (nJanAltu/2)-3,;     //nBottom   - Linha Final
        (nJanLarg/2)-3,;     //nRight    - Coluna Final
        GD_UPDATE,;          //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
        "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
        ,;                   //cTudoOk   - Validação de todas as linhas
        "",;                 //cIniCpos  - Função para inicialização de campos
        {'D2_PRCVEN','C6_VDOBS'} ,;     //aAlter    - Colunas que podem ser alteradas
        ,;                   //nFreeze   - Número da coluna que será congelada
        9999,;               //nMax      - Máximo de Linhas
        ,;                   //cFieldOK  - Validação da coluna
        ,;                   //cSuperDel - Validação ao apertar '+'
        ,;                   //cDelOk    - Validação na exclusão da linha
        oDlgPvt,;            //oWnd      - Janela que é a dona da grid
        aHeadSBM,;           //aHeader   - Cabeçalho da Grid
        aColsSBM)            //aCols     - Dados da Grid
    //oMsGetSBM:lActive := .F.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
EndIf
    RestArea(aArea)
Return


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para cargar los ACOLS						  //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function fCarAcols(cliente,loja,doc,serie,ldatos)
    
	Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
    
    cQry := " SELECT        "             + CRLF
    cQry += "  D2_ITEM,       "              + CRLF
    cQry += "  D2_COD,    "              + CRLF
    cQry += "  (SELECT B1_DESC FROM " + RetSQLName('SB1') + " SB1 WHERE SB1.D_E_L_E_T_ <> '*' AND B1_COD =   D2_COD   ) AS B1_DESC,     "              + CRLF
    cQry += "  D2_QUANT,	    "              + CRLF
    cQry += "  D2_PRCVEN,	    "              + CRLF
    cQry += "  D2_TOTAL,      "                + CRLF
    cQry += "  D2_DESCON,	  "	               + CRLF
    cQry += "  D2_DESC,	      "	               + CRLF
    cQry += "  D2_PRUNIT,	  "	               + CRLF
    cQry += "  D2_DOC,	     "	               + CRLF
    cQry += "  D2_PEDIDO,	  "                + CRLF
    cQry += "  D2_ITEMPV		  "            + CRLF    
    cQry += "  FROM   " + RetSQLName('SD2') + " SD2 "      + CRLF
    cQry += "  WHERE D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND D2_CLIENTE = '"+cliente+"' 		"      + CRLF
    cQry += "  AND D2_LOJA	  = '"+ loja	 +"' 	"      + CRLF
    cQry += "  AND D2_DOC	  = '"+doc+"' 		    "      + CRLF
    cQry += "  AND D2_SERIE = '"+serie+"' 		    "      + CRLF
    cQry += "  AND D2_ESPECIE = 'RFN'               "      + CRLF
	cQry += "  AND D2_QTDEFAT = '0'                 "      + CRLF
	
    TCQuery cQry New Alias "QRY_SBM"

    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)

    //Enquanto houver dados
    QRY_SBM->(DbGoTop())

    If QRY_SBM->(EoF())
        MsgInfo("No hay datos por Exhibir, o ya se genero la Factura de Venta", "Aviso")
        ldatos:=.F.
        //oDlgPvt:End()
        QRY_SBM->(DbSkip())
        QRY_SBM->(DbCloseArea())
        Return ldatos
    Else
        ldatos:=.T.
        While !QRY_SBM->(EoF())
            //  Atualizar régua de processamento
            nAtual++
            IncProc("Adicionando " + Alltrim(QRY_SBM->D2_COD) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padrão como preto
            
            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
                QRY_SBM->D2_ITEM,;
                QRY_SBM->D2_COD,;
                QRY_SBM->B1_DESC,;
				QRY_SBM->D2_QUANT,;
				QRY_SBM->D2_PRCVEN,;
                QRY_SBM->D2_TOTAL,;
                QRY_SBM->D2_DESCON,;
                QRY_SBM->D2_DESC,;
                QRY_SBM->D2_PRUNIT,;
                QRY_SBM->D2_DOC,;
                QRY_SBM->D2_PEDIDO,;
                QRY_SBM->D2_ITEMPV,;
                Posicione("SC6",1, xFilial("SC6")+QRY_SBM->D2_PEDIDO+QRY_SBM->D2_ITEMPV,"C6_VDOBS")    ,; // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
				})
            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para guardar los cambios del precio unitario//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function fSalvar(cliente,loja,doc,serie,ldatos)
    
	Local aColsAux      := oMsGetSBM:aCols
    Local nPosCod       := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_COD"})
    Local nPosItem      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_ITEM"})
	Local nPosPrec      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_PRCVEN"})
	Local nPosTot       := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_TOTAL"})
    Local nPosPed       := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_PEDIDO"})
    Local nPosIP        := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_ITEMPV"})
    Local nDescont      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_DESCON"})
    Local nDesPorc      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_DESC"})
    Local nListaPre     := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "D2_PRUNIT"})
	Local nTotal		:= 0
    Local nDesc         := 0
	Local nLinha  		:= 0

    If MsgYesNo("Desea proceder con la actualizacion de los registros", "Confirma?")
	    
		For nLinha := 1 To Len(aColsAux)
			DbSelectArea("SD2")
            DbSetorder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     
            // Produto + Armazem + Sequencial + Tipo RE/DE
            IF  DbSeek(xFilial('SD2') + doc + serie  + cliente + loja +aColsAux[nLinha][nPosCod]+aColsAux[nLinha][nPosItem], .T.)
                nTotal += aColsAux[nLinha][nPosTot]
                nDesc  += aColsAux[nLinha][nDescont]
                If  RecLock ("SD2", .f.)
                    SD2->D2_PRCVEN    := aColsAux[nLinha][nPosPrec]
                    SD2->D2_TOTAL     := aColsAux[nLinha][nPosTot]
                    SD2->D2_PRUNIT    := aColsAux[nLinha][nListaPre]
                    SD2->D2_DESCON    := aColsAux[nLinha][nDescont]
                    SD2->D2_DESC      := aColsAux[nLinha][nDesPorc]
                    SD2->(MsUnlock())
                EndIf
               
            Endif
            DbSelectArea("SC6")
			DbSetorder(1) //// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                                                                                                                                                                                                                                
			IF  DbSeek(xFilial('SC6') + aColsAux[nLinha][nPosPed]+aColsAux[nLinha][nPosIP]+aColsAux[nLinha][nPosCod], .T.)
				If  RecLock ("SC6", .f.)
					SC6->C6_VDOBS   := aColsAux[nLinha][13]
                    SC6->C6_PRCVEN  := aColsAux[nLinha][nPosPrec]
                    // SC6->C6_VALOR   := aColsAux[nLinha][nPosTot]
                    SC6->C6_VALOR   := aColsAux[nLinha][nPosPrec] * SC6->C6_QTDVEN
                    SC6->C6_DESCONT := aColsAux[nLinha][nDesPorc]
                    SC6->C6_VALDESC := aColsAux[nLinha][nDescont]
                    SC6->C6_PRUNIT  := aColsAux[nLinha][nListaPre]
				EndIf
			EndIf
        Next
			DbSelectArea("SF2")
			DbSetorder(1) //2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                                                                                                                     
			IF  DbSeek(xFilial('SF2') + doc + serie  + cliente + loja , .T.)
				If  RecLock ("SF2", .f.)
					SF2->F2_VALBRUT := nTotal
					SF2->F2_VALMERC	:= nTotal
                    SF2->F2_DESCONT := nDesc
				EndIf
			EndIf
            
		MsgInfo("Modificaciones realizadas con exito!", "Aviso")
        oDlgPvt:End()
    Else
        Return
    EndIf

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 15/05/2023 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Seguimiento de Guia de remision                     //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SD2SEGG(cCliente,cLoja,cDocumento,cSerie)

Local aArea := GetArea()
Private aHeadSBM := {}
Private aColsSBM := {}
Private oDlgPvt
Private oMsGetSBM
Private oBtnFech
Private oBtnLege
Private nJanLarg   := 1100
Private nJanAltu   := 600
Private cFontUti   := "Tahoma"
Private oFontAno   := TFont():New(cFontUti,,-38)
Private oFontSub   := TFont():New(cFontUti,,-20)
Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
Private oFontBtn   := TFont():New(cFontUti,,-14)
Private ldatos     := .F. 

aAdd(aHeadSBM, {"Numero Guia",       "D2_DOC",       "",                             TamSX3("D2_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Guia",        "D2_SERIE",     "",                             TamSX3("D2_SERIE")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Emision Guia",      "D2_EMISSAO",   "",                             TamSX3("D2_EMISSAO")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Pedido Venta",      "D2_PEDIDO",    "",                             TamSX3("D2_PEDIDO")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Pedido",      "C9_DATALIB",   "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Item",          	 "D2_ITEM",      "",                             TamSX3("D2_ITEM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",          "D2_COD",       "",                          	 TamSX3("D2_COD")[01],   	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Desc Prod",         "B1_DESC",      "",                             TamSX3("B1_DESC")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad",          "D2_QUANT",     "@E 999,999,999.99",      		 TamSX3("D2_QUANT")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Orden Separacion",  "D2_ORDSEP",    "",                          	 TamSX3("D2_ORDSEP")[01],   	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Inicio OS",   "C9_DATALIB",   "",                              TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Inicio OS",    "CB7_HRINIS",   "",                              TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Final OS",    "C9_DATALIB",   "",                              TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Final OS",     "CB7_HRINIS",   "",                              TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Numero Factura",    "D2_DOC",       "",                             TamSX3("D2_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Factura",     "D2_SERIE",     "",                             TamSX3("D2_SERIE")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Emision Factra",    "D2_EMISSAO",   "",                             TamSX3("D2_EMISSAO")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )


Processa({|| fCarAcols1(cCliente,cLoja,cDocumento,cSerie,@ldatos)}, "Processando ... Por favor espere ...")
if ldatos=.F.
    Return
else   

DEFINE MSDIALOG oDlgPvt TITLE "Proceso para consulta relacionada" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
@ 004, 003 SAY "Proceso Seguimiento" SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
//@ 004, 150 SAY "Seguimiento"       SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
//@ 014, 150 SAY "SC9" 					    SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Salir"  SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
//@ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Guardar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar(cCliente,cLoja,cDocumento,cSerie)) FONT oFontBtn PIXEL
    //Grid dos grupos
    oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
        003,;                //nLeft     - Coluna Inicial
        (nJanAltu/2)-3,;     //nBottom   - Linha Final
        (nJanLarg/2)-3,;     //nRight    - Coluna Final
        GD_UPDATE,;          //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
        "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
        ,;                   //cTudoOk   - Validação de todas as linhas
        "",;                 //cIniCpos  - Função para inicialização de campos
        {},;     			 //aAlter    - Colunas que podem ser alteradas
        ,;                   //nFreeze   - Número da coluna que será congelada
        9999,;               //nMax      - Máximo de Linhas
        ,;                   //cFieldOK  - Validação da coluna
        ,;                   //cSuperDel - Validação ao apertar '+'
        ,;                   //cDelOk    - Validação na exclusão da linha
        oDlgPvt,;            //oWnd      - Janela que é a dona da grid
        aHeadSBM,;           //aHeader   - Cabeçalho da Grid
        aColsSBM)            //aCols     - Dados da Grid
    //oMsGetSBM:lActive := .F.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
EndIf
    RestArea(aArea)
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para cargar los ACOLS						  //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function fCarAcols1(cCliente,cLoja,cDocumento,cSerie,ldatos)
    
	Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
    Local cHora1 := ""
    Local cHora2 := ""
    Local cHora3 := ""
    Local cHora4 := ""
    Local cHora5 := ""
    Local cHora6 := ""
    

    cQry := " SELECT        "             + CRLF
    cQry += "  D2_ITEM,       "           + CRLF
    cQry += "  D2_COD,    "           + CRLF
    cQry += "  (SELECT B1_DESC FROM " + RetSQLName('SB1') + " SB1 WHERE SB1.D_E_L_E_T_ <> '*' AND B1_COD =   D2_COD  ) AS B1_DESC,     "              + CRLF
    cQry += "  D2_DOC,	      "           + CRLF
    cQry += "  D2_SERIE,	  "           + CRLF
    cQry += "  D2_QUANT,      "           + CRLF
    cQry += "  D2_ORDSEP,	  "	          + CRLF
    cQry += "  D2_PEDIDO,	  "	          + CRLF
    cQry += "  D2_EMISSAO,	  "	          + CRLF
    cQry += "  D2_CLIENTE,	  "	          + CRLF
    cQry += "  D2_LOJA  	  "	          + CRLF
    cQry += "  FROM   " + RetSQLName('SD2') + " SD2 "      + CRLF
    cQry += "  WHERE D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND D2_CLIENTE = '"+cCliente+"' 		"      + CRLF
    cQry += "  AND D2_LOJA    = '"+cLoja+"' 		"      + CRLF
    cQry += "  AND D2_DOC     = '"+cDocumento+"' 	"      + CRLF
    cQry += "  AND D2_SERIE   = '"+cSerie+"' 		"      + CRLF

 
   TCQuery cQry New Alias "QRY_SBM"

    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)

    //Enquanto houver dados
    QRY_SBM->(DbGoTop())

    If QRY_SBM->(EoF())
        MsgInfo("No hay datos por Exhibir", "Aviso")
        ldatos:=.F.
        //oDlgPvt:End()
        QRY_SBM->(DbSkip())
        QRY_SBM->(DbCloseArea())
        Return ldatos
    Else
        ldatos:=.T.
        While !QRY_SBM->(EoF())
            //  Atualizar régua de processamento
            nAtual++
            IncProc("Adicionando " + Alltrim(QRY_SBM->D2_COD) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padrão como preto
            
            cHora1:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),1,2)
            cHora2:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),3,2)
            cHora3:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),5,6)

            cHora4:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),1,2)
            cHora5:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),3,2)
            cHora6:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),5,6)

            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
			 	QRY_SBM->D2_DOC ,;
                QRY_SBM->D2_SERIE ,;
                StoD(QRY_SBM->D2_EMISSAO),;
                QRY_SBM->D2_PEDIDO ,;
                Posicione("SC5",1, xFilial("SC5")+QRY_SBM->D2_PEDIDO,"C5_EMISSAO"),;
                QRY_SBM->D2_ITEM,;
                QRY_SBM->D2_COD,;
                QRY_SBM->B1_DESC,;
			    QRY_SBM->D2_QUANT,;
                QRY_SBM->D2_ORDSEP ,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_DTEMIS"),;
                cHora4+":"+cHora5+":"+cHora6,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_DTFIMS"),;
              	cHora1+":"+cHora2+":"+cHora3,;
                Posicione("SD2",9,xFilial("SD2")+QRY_SBM->D2_CLIENTE+QRY_SBM->D2_LOJA+QRY_SBM->D2_SERIE+QRY_SBM->D2_DOC+QRY_SBM->D2_ITEM,"D2_DOC"),;       // D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM                                                                                                    
                Posicione("SD2",9,xFilial("SD2")+QRY_SBM->D2_CLIENTE+QRY_SBM->D2_LOJA+QRY_SBM->D2_SERIE+QRY_SBM->D2_DOC+QRY_SBM->D2_ITEM,"D2_SERIE"),;     // D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM                                                                                                    
                Posicione("SD2",9,xFilial("SD2")+QRY_SBM->D2_CLIENTE+QRY_SBM->D2_LOJA+QRY_SBM->D2_SERIE+QRY_SBM->D2_DOC+QRY_SBM->D2_ITEM,"D2_EMISSAO"),;   // D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM                                                                                                    
                })
            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 15/05/2023 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Seguimiento de Factura de Venta                     //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SD2SEFT(cCliente,cLoja,cDocumento,cSerie)

Local aArea := GetArea()
Private aHeadSBM := {}
Private aColsSBM := {}
Private oDlgPvt
Private oMsGetSBM
Private oBtnFech
Private oBtnLege
Private nJanLarg   := 1100
Private nJanAltu   := 600
Private cFontUti   := "Tahoma"
Private oFontAno   := TFont():New(cFontUti,,-38)
Private oFontSub   := TFont():New(cFontUti,,-20)
Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
Private oFontBtn   := TFont():New(cFontUti,,-14)
Private ldatos     := .F. 

aAdd(aHeadSBM, {"Numero Factura",    "D2_DOC",       "",                             TamSX3("D2_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Factura",     "D2_SERIE",     "",                             TamSX3("D2_SERIE")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Emision Factura",   "D2_EMISSAO",   "",                             TamSX3("D2_EMISSAO")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Pedido Venta",      "D2_PEDIDO",    "",                             TamSX3("D2_PEDIDO")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Pedido",      "C9_DATALIB",   "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Item",          	 "D2_ITEM",      "",                             TamSX3("D2_ITEM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",          "D2_COD",       "",                          	 TamSX3("D2_COD")[01],   	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Desc Prod",         "B1_DESC",      "",                             TamSX3("B1_DESC")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad",          "D2_QUANT",     "@E 999,999,999.99",      		 TamSX3("D2_QUANT")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Orden Separacion",  "D2_ORDSEP",    "",                          	 TamSX3("D2_ORDSEP")[01],   	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Inicio OS",   "C9_DATALIB",   "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Inicio OS",    "CB7_HRINIS",   "",                             TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Final OS",    "C9_DATALIB",   "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Final OS",     "CB7_HRINIS",   "",                             TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Numero Guia",       "D2_DOC",       "",                             TamSX3("D2_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Guia",        "D2_SERIE",     "",                             TamSX3("D2_SERIE")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Emision Guia",      "D2_EMISSAO",   "",                             TamSX3("D2_EMISSAO")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )


Processa({|| fCarAcols2(cCliente,cLoja,cDocumento,cSerie,@ldatos)}, "Processando ... Por favor espere ...")
if ldatos=.F.
    Return
else   

DEFINE MSDIALOG oDlgPvt TITLE "Proceso para consulta relacionada" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
@ 004, 003 SAY "Proceso Seguimiento" SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
//@ 004, 150 SAY "Seguimiento"       SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
//@ 014, 150 SAY "SC9" 					    SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Salir"  SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
//@ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Guardar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar(cCliente,cLoja,cDocumento,cSerie)) FONT oFontBtn PIXEL
    //Grid dos grupos
    oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
        003,;                //nLeft     - Coluna Inicial
        (nJanAltu/2)-3,;     //nBottom   - Linha Final
        (nJanLarg/2)-3,;     //nRight    - Coluna Final
        GD_UPDATE,;          //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
        "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
        ,;                   //cTudoOk   - Validação de todas as linhas
        "",;                 //cIniCpos  - Função para inicialização de campos
        {},;     			 //aAlter    - Colunas que podem ser alteradas
        ,;                   //nFreeze   - Número da coluna que será congelada
        9999,;               //nMax      - Máximo de Linhas
        ,;                   //cFieldOK  - Validação da coluna
        ,;                   //cSuperDel - Validação ao apertar '+'
        ,;                   //cDelOk    - Validação na exclusão da linha
        oDlgPvt,;            //oWnd      - Janela que é a dona da grid
        aHeadSBM,;           //aHeader   - Cabeçalho da Grid
        aColsSBM)            //aCols     - Dados da Grid
    //oMsGetSBM:lActive := .F.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
EndIf
    RestArea(aArea)
Return

Static Function fCarAcols2(cCliente,cLoja,cDocumento,cSerie,ldatos)
    
	Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
    Local cHora1 := ""
    Local cHora2 := ""
    Local cHora3 := ""
    Local cHora4 := ""
    Local cHora5 := ""
    Local cHora6 := ""
    

    cQry := " SELECT        "             + CRLF
    cQry += "  D2_ITEM,       "           + CRLF
    cQry += "  D2_COD,    "           + CRLF
    cQry += "  (SELECT B1_DESC FROM " + RetSQLName('SB1') + " SB1 WHERE SB1.D_E_L_E_T_ <> '*' AND B1_COD =   D2_COD  ) AS B1_DESC,     "              + CRLF
    cQry += "  D2_DOC,	      "           + CRLF
    cQry += "  D2_SERIE,	  "           + CRLF
    cQry += "  D2_QUANT,      "           + CRLF
    cQry += "  D2_ORDSEP,	  "	          + CRLF
    cQry += "  D2_PEDIDO,	  "	          + CRLF
    cQry += "  D2_EMISSAO,	  "	          + CRLF
    cQry += "  D2_CLIENTE,	  "	          + CRLF
    cQry += "  D2_LOJA,  	  "	          + CRLF
    cQry += "  D2_REMITO,  	  "	          + CRLF
    cQry += "  D2_SERIREM  	  "	          + CRLF
    cQry += "  FROM   " + RetSQLName('SD2') + " SD2 "      + CRLF
    cQry += "  WHERE D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND D2_CLIENTE = '"+cCliente+"' 		"      + CRLF
    cQry += "  AND D2_LOJA    = '"+cLoja+"' 		"      + CRLF
    cQry += "  AND D2_DOC     = '"+cDocumento+"' 	"      + CRLF
    cQry += "  AND D2_SERIE   = '"+cSerie+"' 		"      + CRLF

 
   TCQuery cQry New Alias "QRY_SBM"

    //Setando o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)

    //Enquanto houver dados
    QRY_SBM->(DbGoTop())

    If QRY_SBM->(EoF())
        MsgInfo("No hay datos por Exhibir", "Aviso")
        ldatos:=.F.
        //oDlgPvt:End()
        QRY_SBM->(DbSkip())
        QRY_SBM->(DbCloseArea())
        Return ldatos
    Else
        ldatos:=.T.
        While !QRY_SBM->(EoF())
            //  Atualizar régua de processamento
            nAtual++
            IncProc("Adicionando " + Alltrim(QRY_SBM->D2_COD) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padrão como preto
            
            cHora1:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),1,2)
            cHora2:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),3,2)
            cHora3:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRFIMS"),5,6)

            cHora4:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),1,2)
            cHora5:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),3,2)
            cHora6:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_HRINIS"),5,6)

            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
			 	QRY_SBM->D2_DOC ,;
                QRY_SBM->D2_SERIE ,;
                StoD(QRY_SBM->D2_EMISSAO),;
                QRY_SBM->D2_PEDIDO ,;
                Posicione("SC5",1, xFilial("SC5")+QRY_SBM->D2_PEDIDO,"C5_EMISSAO"),;
                QRY_SBM->D2_ITEM,;
                QRY_SBM->D2_COD,;
                QRY_SBM->B1_DESC,;
			    QRY_SBM->D2_QUANT,;
                QRY_SBM->D2_ORDSEP ,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_DTEMIS"),;
                cHora4+":"+cHora5+":"+cHora6,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->D2_ORDSEP,"CB7_DTFIMS"),;
              	cHora1+":"+cHora2+":"+cHora3,;
                QRY_SBM->D2_REMITO ,;
                QRY_SBM->D2_SERIREM ,;
                Posicione("SD2",3,xFilial("SD2")+QRY_SBM->D2_REMITO+QRY_SBM->D2_SERIREM+QRY_SBM->D2_CLIENTE+QRY_SBM->D2_LOJA,"D2_EMISSAO"),;       // D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM                                                                                                    
                })
            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return

