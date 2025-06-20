#Include "Protheus.Ch"
#Include "Rwmake.ch"
#Include "TopConn.ch"
/*
    
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA410MNU �Autor  �Caio Pereira        � Data �  10/20/11   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
Ponto de entrada utilizado para acrescentar botoes en la pantalla de 
Pedidos de Venta
���������������������������������������������������������������������������*/
User Function MA410MNU()

	Aadd(aRotina,{"Modificar Mens.p/Nota"     ,"U_ModText(SC5->C5_NUM)",0,13,Nil})
	Aadd(aRotina,{"Consulta Relacionada Seguimiento"  ,"U_SC9Visu(SC5->C5_NUM)",0,14,Nil}) // Modificado 03/05/2023 Juan Pablo Astorga
	Aadd(aRotina,{"Modificar Correo Elec."     ,"U_ModCorr(SC5->C5_NUM)",0,15,Nil})

    Aadd(aRotina,{"Modificar Fecha de entrga"     ,"U_ModFeEnt(SC5->C5_NUM)",0,15,Nil})

Return()

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: ModText      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||M�dulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descri��o: P.E. Funcion para modificar texto en el pedido de venta  //
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
		MsgAlert("Processo Cancelado por usu�rio")	
		return
	EndIf
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: ModText      ||Data: 03/05/2023 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||M�dulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descri��o: P.E. Funcion para visualizar consulta en la SC9          //
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
        GD_UPDATE,;          //nStyle    - Estilos para edi��o da Grid (GD_INSERT = Inclus�o de Linha; GD_UPDATE = Altera��o de Linhas; GD_DELETE = Exclus�o de Linhas)
        "AllwaysTrue()",;    //cLinhaOk  - Valida��o da linha
        ,;                   //cTudoOk   - Valida��o de todas as linhas
        "",;                 //cIniCpos  - Fun��o para inicializa��o de campos
        {},;     			 //aAlter    - Colunas que podem ser alteradas
        ,;                   //nFreeze   - N�mero da coluna que ser� congelada
        9999,;               //nMax      - M�ximo de Linhas
        ,;                   //cFieldOK  - Valida��o da coluna
        ,;                   //cSuperDel - Valida��o ao apertar '+'
        ,;                   //cDelOk    - Valida��o na exclus�o da linha
        oDlgPvt,;            //oWnd      - Janela que � a dona da grid
        aHeadSBM,;           //aHeader   - Cabe�alho da Grid
        aColsSBM)            //aCols     - Dados da Grid
    //oMsGetSBM:lActive := .F.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
EndIf
    RestArea(aArea)
Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||M�dulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descri��o: P.E. Funcion para cargar los ACOLS						  //
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
    cQry += "  B1_DESC,     "             + CRLF
    cQry += "  C9_DATALIB,	    "         + CRLF
    cQry += "  D2_DOC C9_NFISCAL,	    "         + CRLF
    cQry += "  D2_SERIE C9_SERIENF,      "         + CRLF
    cQry += "  C9_BLEST,	  "	          + CRLF
    cQry += "  C9_BLCRED,	      "	      + CRLF
    cQry += "  C9_REMITO,	  "	          + CRLF
    cQry += "  C9_SERIREM,	     "	      + CRLF
    cQry += "  C9_ORDSEP,	  "           + CRLF
    cQry += "  C9_PEDIDO,	  "           + CRLF
    cQry += "  CASE  WHEN D2_QUANT IS NULL OR D2_QUANT = 0 THEN C9_QTDLIB ELSE D2_QUANT END AS C9_QTDLIB "           + CRLF

    cQry += "  FROM   " + RetSQLName('SC9') + " SC9 "      + CRLF

    cQry += "  INNER JOIN " + RetSQLName('SB1') + " SB1      "           + CRLF    
    cQry += "  ON  B1_COD =   C9_PRODUTO "           + CRLF
    cQry += "  LEFT JOIN " + RetSQLName('SD2') + " SD2 "           + CRLF
    cQry += "  ON D2_PEDIDO=C9_PEDIDO "           + CRLF
    cQry += "  AND D2_ITEMPV=C9_ITEM "           + CRLF
    cQry += "  AND D2_SERIE IN ('FVE','SET') "           + CRLF
    cQry += "  AND C9_REMITO=D2_REMITO "           + CRLF
    cQry += "  AND SD2.D_E_L_E_T_ <> '*'   "           + CRLF    

    cQry += "  WHERE SC9.D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND   SB1.D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND C9_PEDIDO = '"+cPedido+"' 		"      + CRLF
    cQry += "  ORDER BY C9_ITEM"      + CRLF
 
   TCQuery cQry New Alias "QRY_SBM"

    //Setando o tamanho da r�gua
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
            //  Atualizar r�gua de processamento
            nAtual++
            IncProc("Adicionando " + Alltrim(QRY_SBM->C9_PRODUTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padr�o como preto
            
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


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: ModText      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||M�dulo: Facturacion   //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descri��o: P.E. Funcion para modificar texto en el pedido de venta  //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function ModCorr(cPedido)

Local aPergs  := {}
Local aObs    := {}
    DbSelectArea("SC5")
    DbSetorder(1)                                                                                                                                                                                                      
    IF  DbSeek(xFilial('SC5') + cPedido , .T.)
        IF EstadoPed(cPedido)
            aAdd( aPergs ,{9,"Correo Actual: "+SC5->C5_XEMAIL,200, 40,.T.}) 
            aAdd( aPergs , {1,"Nuevo Correo Elect.:",Space(TamSx3("C5_XEMAIL")[1]),  "@!","U_CheckEmail(ALLTRIM(MV_PAR02))", "", '.T.',80,.F.})
            If ParamBox(aPergs ,"Nuevo Correo Elect.:",@aObs,,,,,,,,.f.)
                If !Empty(aObs[2])

                    If   Reclock('SC5', .F.)
                        SC5->C5_XEMAIL := ALLTRIM(aObs[2])
                        SC5->( MsUnlock())
                    EndIf
                    
                    MsgInfo("Modificaciones realizadas con exito!", "Aviso")
                    Return
                EndIf
            Else
                MsgAlert("Processo Cancelado por usu�rio")	
                return
            EndIf  
        EndIf
    EndIf
Return

User Function CheckEmail(cEmail)
    Local lIsValid := .T.
    Local aSpecialChars := {"!", "#", "$", "%", "&", "'", "*", "+", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~"}
    Local nCount := Len(aSpecialChars)
    Local i := 1

    // Verifica si el correo tiene caracteres especiales
    For i := 1 To nCount
        If aSpecialChars[i] $ cEmail
            lIsValid := .F.
            Exit
        EndIf
    Next

    // Verifica si el correo tiene un formato b�sico v�lido (algo@algo.algo)
    If !IsEmail(cEmail)
        lIsValid := .F.
    EndIf

    IF !lIsValid
        msgAlert("El correo no cumple con una estructura valida.","Validaci�n C5_XEMAIL")
    EndIf

Return lIsValid


Static Function IsEmailFormat(cEmail)
    Local lResult := .F.
    Local nAt := At("@", cEmail)
    Local nDot := At(".", cEmail, nAt)

    If nAt > 1 .And. nDot > nAt + 1 .And. nDot < Len(cEmail)
        lResult := .T.
    EndIf

Return lResult

static Function EstadoPed(cNumPed)
 	
	Local lRet := .F.

	Qryped := " SELECT  C9_PEDIDO,C9_NFISCAL,C9_SERIENF,C9_CLIENTE,C9_LOJA  FROM   "+RetSQLName('SC9')+" WHERE "
	Qryped += " C9_PEDIDO = '"+cNumPed+"' "
	// Qryped += " AND C9_REMITO    != ' ' "
	//Qryped += " AND C9_NFISCAL = ' '"
	Qryped += " AND D_E_L_E_T_  != '*'"
	TcQuery Qryped New Alias "_QRYPED"
	dbSelectArea("_QRYPED")
	IF !_QRYPED->(EOF())
	    
        If !Empty(_QRYPED->(C9_NFISCAL))
            DbSelectArea("SF2")
			SF2->(DbSetOrder(1))
			IF SF2->(DbSeek(xFilial("SF2") + _QRYPED->(C9_NFISCAL) + _QRYPED->(C9_SERIENF)+ _QRYPED->(C9_CLIENTE)+ _QRYPED->(C9_LOJA) ))
                If SF2->F2_FLFTEX !='6'
                    lRet := .T.
                Else
                    msgAlert("El pedido "+cNumPed+" ya se encuentra con factura transmitida.","Proceso abortado")
                EndIF
            EndIf
        Else
            lRet := .T.
        EndIf
	Else  
        msgAlert("El pedido "+cNumPed+" No cuenta con Liberaci�n.","Proceso abortado")
	EndIf
	("_QRYPED")->(DBCloseArea())

Return lRet

User Function ModFeEnt(cPedido)

Local aArea := GetArea()
Local cUserActua := upper(cusername)
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


 //              T�tulo               Campo        M�scara                        Tamanho                   Decimal                   Valid               Usado  Tipo F3     Combo
aAdd(aHeadSBM, {"Pedido",          	 "C5_NUM",     "",                              TamSX3("C5_NUM")[01],      	0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Cliente",          "C5_CLIENT",      "",                          TamSX3("C5_CLIENT")[01],    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Tienda",         "C5_LOJAENT",     "",                          TamSX3("C5_LOJAENT")[01],   0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Nombre",          "C5_XNCLIEN",    "",                           TamSX3("C5_XNCLIEN")[01],   0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fec. Pedido",            "C5_EMISSAO",   "@D",                            TamSX3("C5_EMISSAO")[01],   0,                        ".T.",              ".T.", "D", "",    ""} )
aAdd(aHeadSBM, {"Item",        	 "C6_ITEM",    "",                              TamSX3("C6_ITEM")[01],     0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Producto",         "C6_PRODUTO",   "",                            TamSX3("C6_PRODUTO")[01],    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Local",            "C6_LOCAL",     "",                            TamSX3("C6_LOCAL")[01],      0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"QTD venta",      "C6_QTDVEN",   "@E 999,999.99",                TamSX3("C6_QTDVEN")[01],    0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"QTD Entreg",         "C6_QTDENT",    "@E 999,999.99",               TamSX3("C6_QTDENT")[01],       0,                        ".T.",              ".T.", "C", "",    ""} )
aAdd(aHeadSBM, {"Fecha Entrega",            "C6_ENTREG",     "@!",                           TamSX3("C6_ENTREG")[01],    0,                        ".T.",          	  ".T.", "D", "",    ""} )


Processa({|| fCarSc6(cPedido,@ldatos)}, "Processando ... Por favor espere ...")
if ldatos=.F.
    Return
else   

DEFINE MSDIALOG oDlgPvt TITLE "Proceso para Modificarla fecha de entrega" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
@ 004, 003 SAY "REPROCESO"                SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
@ 004, 150 SAY "Ajuste Fecha de Entrega"          SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Salir"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
@ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnSalv  PROMPT "Guardar"        SIZE 050, 018 OF oDlgPvt ACTION (fSalvar(cPedido)) FONT oFontBtn PIXEL
    //Grid dos grupos
    oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
        003,;                //nLeft     - Coluna Inicial
        (nJanAltu/2)-3,;     //nBottom   - Linha Final
        (nJanLarg/2)-3,;     //nRight    - Coluna Final
        GD_UPDATE,;          //nStyle    - Estilos para edi��o da Grid (GD_INSERT = Inclus�o de Linha; GD_UPDATE = Altera��o de Linhas; GD_DELETE = Exclus�o de Linhas)
        "AllwaysTrue()",;    //cLinhaOk  - Valida��o da linha
        ,;                   //cTudoOk   - Valida��o de todas as linhas
        "",;                 //cIniCpos  - Fun��o para inicializa��o de campos
        {'C6_ENTREG'} ,;     //aAlter    - Colunas que podem ser alteradas
        ,;                   //nFreeze   - N�mero da coluna que ser� congelada
        9999,;               //nMax      - M�ximo de Linhas
        ,;                   //cFieldOK  - Valida��o da coluna
        ,;                   //cSuperDel - Valida��o ao apertar '+'
        ,;                   //cDelOk    - Valida��o na exclus�o da linha
        oDlgPvt,;            //oWnd      - Janela que � a dona da grid
        aHeadSBM,;           //aHeader   - Cabe�alho da Grid
        aColsSBM)            //aCols     - Dados da Grid
    //oMsGetSBM:lActive := .F.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
EndIf
    RestArea(aArea)
Return

Static Function fSalvar(cPedido,ldatos)
    
	Local aColsAux      := oMsGetSBM:aCols
    Local nPosItem        := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "C6_ITEM"})
    Local nPosProd      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "C6_PRODUTO"})
    Local dFeEntr     := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "C6_ENTREG"})
	Local nLinha  		:= 0

    If MsgYesNo("Desea proceder con la actualizacion de los registros", "Confirma?")
	    
		For nLinha := 1 To Len(aColsAux)
			DbSelectArea("SC6")
            DbSetorder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                  
            IF  DbSeek(xFilial('SC6') + cPedido +aColsAux[nLinha][nPosItem]+aColsAux[nLinha][nPosProd], .T.)

                If  RecLock ("SC6", .f.)
                    SC6->C6_ENTREG    := aColsAux[nLinha][dFeEntr]                 
                    SC6->C6_USREDIT    := cusername
                    SC6->(MsUnlock())
                EndIf
               
            Endif
        Next nLinha
		MsgInfo("Modificaciones realizadas con exito!", "Aviso")
        oDlgPvt:End()
    Else
        Return
    EndIf

Return

Static Function fCarSc6(cPedido,ldatos)
    
	Local aArea  := GetArea()
    Local cQry   := ""
    Local nAtual := 0
    Local nTotal := 0
    
    cQry := " SELECT        "             + CRLF
    cQry += "  C5_NUM,       "              + CRLF
    cQry += "  C5_CLIENT,    "              + CRLF
    cQry += "  C5_LOJAENT,	    "              + CRLF
    cQry += "  C5_XNCLIEN,	    "              + CRLF
    cQry += "  C5_EMISSAO,      "                + CRLF
    cQry += "  C6_ITEM,	  "	               + CRLF
    cQry += "  C6_PRODUTO,	      "	               + CRLF
    cQry += "  C6_LOCAL,	  "	               + CRLF
    cQry += "  C6_QTDVEN,	     "	               + CRLF
    cQry += "  C6_QTDENT,	  "                + CRLF
    cQry += "  C6_ENTREG		  "            + CRLF    
    cQry += "  FROM   " + RetSQLName('SC5') + " SC5 "      + CRLF
    cQry += "  INNER JOIN    " + RetSQLName('SC6') + " SC6 "      + CRLF
    cQry += "  ON  C5_NUM = C6_NUM "      + CRLF
    cQry += "  AND  SC6.D_E_L_E_T_ <> '*' "      + CRLF
    cQry += "  AND  C6_QTDVEN > C6_QTDENT "      + CRLF
    cQry += "  WHERE SC5.D_E_L_E_T_ <> '*'              "      + CRLF
    cQry += "  AND C5_NUM = '"+cPedido+"' 		"      + CRLF
	
    TCQuery cQry New Alias "QRY_SBM"

    //Setando o tamanho da r�gua
    Count To nTotal
    ProcRegua(nTotal)

    //Enquanto houver dados
    QRY_SBM->(DbGoTop())

    If QRY_SBM->(EoF())
        MsgInfo("No se encontraron l�neas disponibles para actualizar fecha de entrega", "Aviso")
        ldatos:=.F.
        //oDlgPvt:End()
        QRY_SBM->(DbSkip())
        QRY_SBM->(DbCloseArea())
        Return ldatos
    Else
        ldatos:=.T.
        While !QRY_SBM->(EoF())
            //  Atualizar r�gua de processamento
            nAtual++
            IncProc("Adicionando " + Alltrim(QRY_SBM->C6_PRODUTO) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
            //Definindo a legenda padr�o como preto
            
            //Adiciona o item no aCols
            aAdd(aColsSBM, { ;
                QRY_SBM->C5_NUM,;
                QRY_SBM->C5_CLIENT,;
                QRY_SBM->C5_LOJAENT,;
				QRY_SBM->C5_XNCLIEN,;
				StoD(QRY_SBM->C5_EMISSAO),;
                QRY_SBM->C6_ITEM,;
                QRY_SBM->C6_PRODUTO,;
                QRY_SBM->C6_LOCAL,;
                QRY_SBM->C6_QTDVEN,;
                QRY_SBM->C6_QTDENT,;
                StoD(QRY_SBM->C6_ENTREG),;
				})
            QRY_SBM->(DbSkip())
        EndDo
        QRY_SBM->(DbCloseArea())
    EndIF
    RestArea(aArea)
Return
