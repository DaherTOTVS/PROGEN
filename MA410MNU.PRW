#Include "Protheus.Ch"
#Include "Rwmake.ch"
#Include "TopConn.ch"
/*
    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410MNU ºAutor  ³Caio Pereira        º Data ³  10/20/11   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Ponto de entrada utilizado para acrescentar botoes en la pantalla de 
Pedidos de Venta
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MA410MNU()

	Aadd(aRotina,{"Modificar Mens.p/Nota"     ,"U_ModText(SC5->C5_NUM)",0,13,Nil})
	Aadd(aRotina,{"Consulta Relacionada Seguimiento"  ,"U_SC9Visu(SC5->C5_NUM)",0,14,Nil}) // Modificado 03/05/2023 Juan Pablo Astorga
	
Return()

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: ModText      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para modificar texto en el pedido de venta  //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function ModText(cPedido)

Local aPergs  := {}
Local aObs    := {}

aAdd( aPergs ,{1,"Mens.p/Nota",Space(TamSx3("C5_MENNOTA")[1])   ,"@!",,,'.T.',80,.F.})
	If ParamBox(aPergs ,"Mens.p/Nota",@aObs,,,,,,,,.f.)
		If !Empty(aObs[1])
			DbSelectArea("SC5")
			DbSetorder(1)                                                                                                                                                                                                      
			IF  DbSeek(xFilial('SC5') + cPedido , .T.)
				If  RecLock ("SC5", .f.)
					SC5->C5_MENNOTA := aObs[1]
				EndIf
			EndIf
		MsgInfo("Modificaciones realizadas con exito!", "Aviso")
		Return
		EndIf
	Else
		MsgAlert("Processo Cancelado por usuário")	
		return
	EndIf
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: ModText      ||Data: 03/05/2023 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Funcion para visualizar consulta en la SC9          //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SC9Visu(cPedido)

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

aAdd(aHeadSBM, {"Pedido Venta",      "C9_PEDIDO",   "",                             TamSX3("C9_PEDIDO")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Pedido",      "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Item",          	 "C9_ITEM",     "",                             TamSX3("C9_ITEM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",          "C9_PRODUTO",  "",                          	TamSX3("C9_PRODUTO")[01],   	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Desc Prod",         "B1_DESC",     "",                             TamSX3("B1_DESC")[01],     		0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad Liberada", "C9_QTDLIB",  "@E 999,999,999.99",      		TamSX3("C9_QTDLIB")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Fecha Liberacion",  "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Orden Separacion",  "C9_ORDSEP",   "",                             TamSX3("C9_ORDSEP")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Inicio OS",   "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Inicio OS",    "CB7_HRINIS",  "",                             TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Final OS",    "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Hora Final OS",     "CB7_HRINIS",  "",                             TamSX3("CB7_HRINIS")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Remito",      "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Numero Remito",     "C9_REMITO",   "",                             TamSX3("C9_REMITO")[01],        0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Remito",      "C9_SERIREM",  "",                             TamSX3("C9_SERIREM")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Fact",        "C9_DATALIB",  "",                             TamSX3("C9_DATALIB")[01],     	0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Numero Fact",       "C9_NFISCAL",  "",                             TamSX3("C9_NFISCAL")[01],       0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Serie Fact",        "C9_SERIENF",  "",                             TamSX3("C9_SERIENF")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Bloqueo Stock",     "C9_BLEST",    "",                             TamSX3("C9_BLEST")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Bloqueo Credito",   "C9_BLCRED",   "",                             TamSX3("C9_BLCRED")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )

Processa({|| fCarAcols(cPedido,@ldatos)}, "Processando ... Por favor espere ...")
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

Static Function fCarAcols(cPedido,ldatos)
    
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
    cQry += "  C9_ITEM,       "           + CRLF
    cQry += "  C9_PRODUTO,    "           + CRLF
    cQry += "  (SELECT B1_DESC FROM " + RetSQLName('SB1') + " SB1 WHERE SB1.D_E_L_E_T_ <> '*' AND B1_COD =   C9_PRODUTO  ) AS B1_DESC,     "              + CRLF
    cQry += "  C9_DATALIB,	    "         + CRLF
    cQry += "  C9_NFISCAL,	    "         + CRLF
    cQry += "  C9_SERIENF,      "         + CRLF
    cQry += "  C9_BLEST,	  "	          + CRLF
    cQry += "  C9_BLCRED,	      "	      + CRLF
    cQry += "  C9_REMITO,	  "	          + CRLF
    cQry += "  C9_SERIREM,	     "	      + CRLF
    cQry += "  C9_ORDSEP,	  "           + CRLF
    cQry += "  C9_PEDIDO,	  "           + CRLF
	cQry += "  C9_QTDLIB	  "           + CRLF
    cQry += "  FROM   " + RetSQLName('SC9') + " SC9 "      + CRLF
    cQry += "  WHERE D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND C9_PEDIDO = '"+cPedido+"' 		"      + CRLF
 
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
            IncProc("Adicionando " + Alltrim(QRY_SBM->C9_PRODUTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padrão como preto
            
            cHora1:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRFIMS"),1,2)
            cHora2:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRFIMS"),3,2)
            cHora3:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRFIMS"),5,6)

            cHora4:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRINIS"),1,2)
            cHora5:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRINIS"),3,2)
            cHora6:= Substr(Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_HRINIS"),5,6)

            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
			 	QRY_SBM->C9_PEDIDO ,;
                Posicione("SC5",1, xFilial("SC5")+QRY_SBM->C9_PEDIDO,"C5_EMISSAO"),;
                QRY_SBM->C9_ITEM,;
                QRY_SBM->C9_PRODUTO,;
                QRY_SBM->B1_DESC,;
			    QRY_SBM->C9_QTDLIB,;
                StoD(QRY_SBM->C9_DATALIB),;
                QRY_SBM->C9_ORDSEP ,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_DTEMIS"),;
                cHora4+":"+cHora5+":"+cHora6,;
                Posicione("CB7",1, xFilial("SC5")+QRY_SBM->C9_ORDSEP,"CB7_DTFIMS"),;
              	cHora1+":"+cHora2+":"+cHora3,;
                Posicione("SF2",1, xFilial("SF2")+QRY_SBM->C9_REMITO+QRY_SBM->C9_SERIREM,"F2_EMISSAO"),;
                QRY_SBM->C9_REMITO,;
                QRY_SBM->C9_SERIREM,;
                Posicione("SF2",1, xFilial("SF2")+QRY_SBM->C9_NFISCAL+QRY_SBM->C9_SERIENF,"F2_EMISSAO"),;
			    QRY_SBM->C9_NFISCAL,;
				QRY_SBM->C9_SERIENF,;
                QRY_SBM->C9_BLEST,;
                QRY_SBM->C9_BLCRED,;
                })
            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return


Return
