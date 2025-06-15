#Include 'protheus.ch'
#Include "Rwmake.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  MT120BRW    ºAutor  ³Microsiga           ºFecha ³  09/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Punto de entrada para agregar una rutina en el browse      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT120BRW

AADD(aRotina,{"Imp.Pedido de Compra","U_PEDGRF",0,5,0,})
AADD(aRotina,{"Seguimiento Pedido de Compra","u_SC7SEG(SC7->C7_NUM)",0,5,0,})

Return

User Function SC7SEG(cPedido)

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

aAdd(aHeadSBM, {"Numero Pedido",            "D1_PEDIDO",    "",                             TamSX3("D1_PEDIDO")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Item",          	        "D1_ITEM",      "",                             TamSX3("D1_ITEM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",                 "D1_COD",       "",                          	TamSX3("D1_COD")[01],   	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Desc Prod",                "B1_DESC",      "",                             TamSX3("B1_DESC")[01],     	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Deposito",                 "D1_LOCAL",      "",                            TamSX3("D1_LOCAL")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad",                 "D1_QUANT",    "@E 999,999,999.99",      		TamSX3("D1_QUANT")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Valor Unitario",           "D1_VUNIT",    "@E 999,999,999.99",             TamSX3("D1_VUNIT")[01],   	    0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Valor Total",              "D1_TOTAL",    "@E 999,999,999.99",             TamSX3("D1_TOTAL")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Proveedor",                "A2_NOME",   "",                                TamSX3("A2_NOME")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Numero Remision",          "D1_DOC",       "",                             TamSX3("D1_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Nro Control de Calidad",   "D1_NUMCQ",     "",                             TamSX3("D1_NUMCQ")[01],     	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Orden Produccion",         "D1_OP",        "",                             TamSX3("D1_OP")[01],     	    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad REM",                 "D1_QUANT",    "@E 999,999,999.99",      		TamSX3("D1_QUANT")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )
aAdd(aHeadSBM, {"Numero Factura",           "D1_DOC",       "",                             TamSX3("D1_DOC")[01],       	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cantidad FAC",                 "D1_QUANT",    "@E 999,999,999.99",      		TamSX3("D1_QUANT")[01],     	0,                        ".T.",              ".T.", "N", "",    ""} )


Processa({|| fCarAcols1(cPedido,@ldatos)}, "Processando ... Por favor espere ...")
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

Static Function fCarAcols1(cPedido,ldatos)
    
	Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0

    
cQry := "  SELECT  "           + CRLF                 
cQry += "  C7_ITEM, "   + CRLF                
cQry += "  C7_NUM, "   + CRLF                 
cQry += "  C7_OP, "   + CRLF                  
cQry += "  C7_LOCAL, "   + CRLF 
cQry += "  C7_QUANT, "   + CRLF               
cQry += "  C7_PRECO, "   + CRLF               
cQry += "  C7_TOTAL, "   + CRLF               
cQry += "  C7_PRODUTO, "   + CRLF             
cQry += "  C7_FORNECE, "   + CRLF             
cQry += "  C7_LOJA, "   + CRLF             
cQry += "  SB1.B1_DESC, "   + CRLF  
cQry += "  D11.D1_FORNECE, "   + CRLF 
cQry += "  D11.D1_DOC DOC_GUIA, "   + CRLF              
cQry += "  D11.D1_ITEM IT_RCN, "   + CRLF                          
cQry += "  D11.D1_ESPECIE GUIA, "   + CRLF   
cQry += "  D11.D1_QUANT QTD_GUIA  , "   + CRLF             
cQry += "  D11.D1_NUMCQ CCQ, "   + CRLF          
cQry += "  D12.D1_ESPECIE FACTURA, "   + CRLF 
cQry += "  D12.D1_DOC DOC_NF, "   + CRLF
cQry += "  D12.D1_ITEM IT_NF    , "   + CRLF
cQry += "  D12.D1_QUANT QTD_FACTURA  "   + CRLF       
cQry += "  FROM   " + RetSQLName('SC7') + "  C7 "   + CRLF
cQry += "  INNER JOIN " + RetSQLName('SB1') + "  SB1 "   + CRLF
cQry += "  ON SB1.B1_COD=C7_PRODUTO "   + CRLF
cQry += "  AND SB1.D_E_L_E_T_ <> '*' "   + CRLF
cQry += "  LEFT JOIN " + RetSQLName('SD1') + " D11    "   + CRLF   
cQry += "  ON D11.D1_PEDIDO=C7.C7_NUM "   + CRLF      
cQry += "  AND D11.D1_ITEMPC=C7.C7_ITEM   "   + CRLF    
cQry += "  AND D11.D1_ESPECIE='RCN'    "   + CRLF   
cQry += "  AND D11.D_E_L_E_T_<>'*'    "   + CRLF   
cQry += "  LEFT JOIN " + RetSQLName('SD1') + " D12    "   + CRLF   
cQry += "  ON D12.D1_PEDIDO=C7.C7_NUM  "   + CRLF
cQry += "  AND D12.D1_ITEMPC=C7.C7_ITEM "   + CRLF
cQry += "  AND D12.D1_REMITO=D11.D1_DOC "   + CRLF
cQry += "  AND D12.D1_SERIREM=D11.D1_SERIE "   + CRLF 
cQry += "  AND D12.D1_ESPECIE='NF'  "   + CRLF
cQry += "  AND D12.D_E_L_E_T_<>'*'  "   + CRLF
cQry += "  WHERE C7.D_E_L_E_T_<> '*'  "   + CRLF            
 cQry += "  AND C7_NUM = '"+cPedido+"' 		"      + CRLF		  
    

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
            IncProc("Adicionando " + Alltrim(QRY_SBM->C7_PRODUTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padrão como preto
            
            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
			 	QRY_SBM->C7_NUM ,;
                QRY_SBM->C7_ITEM,;
                QRY_SBM->C7_PRODUTO,;
                QRY_SBM->B1_DESC,;
                QRY_SBM->C7_LOCAL,;
                QRY_SBM->C7_QUANT,;
                QRY_SBM->C7_PRECO,;
                QRY_SBM->C7_TOTAL,;
                Posicione("SA2",1,xFilial("SA2")+QRY_SBM->C7_FORNECE+QRY_SBM->C7_LOJA,"A2_NOME"),;    
                QRY_SBM->DOC_GUIA,;
                QRY_SBM->CCQ,;
                QRY_SBM->C7_OP,;
                QRY_SBM->QTD_GUIA,;
                QRY_SBM->DOC_NF,;
                QRY_SBM->QTD_FACTURA,;
                })

            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return

