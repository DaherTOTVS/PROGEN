#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#include "topconn.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                     
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LC13R    ºAutor ³Kildare Monteiro       Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PEDIDO DE COMPRAS (Emissao em formato Grafico)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// alterar o parametro MV_PCOMPRA e colocar PEDGRF para substituir a impressão padrão.

User Function PEDGRF()     
Private	lEnd		:= .f.,;
		aAreaSC7	:= SC7->(GetArea()),;
		aAreaSA2	:= SA2->(GetArea()),;
		aAreaSA5	:= SA5->(GetArea()),;   
		aAreaSF4	:= SF4->(GetArea()),;
	 	cPerg		:= Padr('PEDGRF',10)


	 	//	aAreaSZF	:= SZF->(GetArea()),;

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta os parametros.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AjustaSX1(cPerg)

		// Se a Impressão Não Vier da Tela de Pedido de Compras então Efetua Pergunta de Parâmetros
		// Caso contrário então posiciona no pedido que foi clicado a opção imprimir.

		If Upper(ProcName(2)) <> 'A120IMPRI'
           	If !Pergunte(cPerg,.t.)
           		Return
           	Endif

			Private	cNumPed  	:= MV_PAR01		// Numero do Pedido de Compras
			Private	lImpPrc		:= .t.	// Imprime os Precos ?
		//	Private	nTitulo 	:= mv_par03			// Titulo do Relatorio ?
		//	Private	cObserv1	:= mv_par02	// 1a Linha de Observacoes
		//	Private	cObserv2	:= mv_par04			// 2a Linha de Observacoes
		//	Private	cObserv3	:= mv_par05			// 3a Linha de Observacoes
		//	Private	cObserv4	:= mv_par06			// 4a Linha de Observacoes
		//	Private	lPrintCodFor:= (mv_par08==1)	// Imprime o Cvvvvvvvvvvvvvvvvvvvvvvvvvvvodigo do produto no fornecedor ?

  		Else

			Private	cNumPed  	:= SC7->C7_NUM		// Numero do Pedido de Compras
			Private	lImpPrc		:= .t.	// Imprime os Precos ?
		//	Private	nTitulo 	:= 2				// Titulo do Relatorio ?
		//	Private	cObserv1	:= mv_par02			// 1a Linha de Observacoes
		//	Private	cObserv2	:= mv_par04			// 2a Linha de Observacoes
		//	Private	cObserv3	:= mv_par05			// 3a Linha de Observacoes
		//	Private	cObserv4	:= mv_par06			// 4a Linha de Observacoes
		//	Private	lPrintCodFor:= .f.	// Imprime o Codigo do produto no fornecedor ?
			 
			
  		Endif


		DbSelectArea('SC7')
		SC7->(DbSetOrder(1))
		If	( ! SC7->(DbSeek(xFilial('SC7') + cNumPed)) )
			Help('',1,'PEDGRF',,OemToAnsi('Pedido não encontrado.'),1)
			Return .f.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a rotina de impressao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({ |lEnd| xPrintRel(),OemToAnsi('Generando el informe.')}, OemToAnsi('Espere...'))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Restaura a area anterior ao processamento. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea(aAreaSC7)
		RestArea(aAreaSA2)
		RestArea(aAreaSA5)
	 //	RestArea(aAreaSZF)
		RestArea(aAreaSF4)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xPrintRelºAutor ³Luis Henrique Robustoº Data ³  10/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime a Duplicata...                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xPrintRel()
	cFileLogo := "\img\logo_pg.png"
	If !File(cFileLogo)
		cFileLogo := "\img\logo_pg.png"
	EndIf
	
Private lEmail		:= .f.
Private	lFlag		:= .t.,;	// Controla a impressao do fornecedor
		nLinha		:= 3000,;	// Controla a linha por extenso
		nLinFim		:= 0,;		// Linha final para montar a caixa dos itens
		lPrintDesTab:= .f.,;	// Imprime a Descricao da tabela (a cada nova pagina)
		cRepres		:= Space(80)

Private	_nQtdReg	:= 0,;		// Numero de registros para intruir a regua
		_nValMerc 	:= 0,;		// Valor das mercadorias
		_nValIPI	:= 0,;		// Valor do I.P.I.
		_nValDesc	:= 0,;		// Valor de Desconto
		_nTotAcr	:= 0,;		// Valor total de acrescimo
		_nTotSeg	:= 0,;		// Valor de Seguro
		_nTotFre	:= 0		// Valor de Frete
		_nTotIcmsRet:= 0		// Valor do ICMS Retido KILDARE
		_nTotIPC    := 0		// Valor do IPC		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona nos arquivos necessarios. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SA2')
		SA2->(DbSetOrder(1))
		If	! SA2->(DbSeek(xFilial('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
			Help('',1,'REGNOIS')
			Return .f.
		EndIf
		
	/*	If MsgYesNo("Desea Enviar Orden de Compra por E-mail ?") 
			lEmail := .t.
		Endif   */
		
		lViewPDF := !lEmail

		If ExistDir("V:")
			If !ExistDir("V:\spool\")
				MakeDir("V:\spool\")
			EndIf
			cPath := "V:\spool\"
		ElseIf ExistDir("C:")
			If !ExistDir("C:\spool\")
				MakeDir("C:\spool\")
			EndIf
			cPath := "C:\spool\"
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define que a impressao deve ser RETRATO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAdjustToLegacy := .T.   //.F.
		lDisableSetup  := .F.
		cFilename := Criatrab(Nil,.F.)
		cFilename := "PC"+cNumPed+"_"+time()+".pdf"
		// oPrint := FWMSPrinter():New(cFilename, IMP_PDF, lAdjustToLegacy,     , lDisableSetup,   ,,,   ,,,lViewPDF)
		oPrint := FWMsPrinter():New(cFilename, IMP_PDF, lAdjustToLegacy,cPath,.T.           ,.T.,,,.T.,,,.T.,)

	//	oPrint:Setup()
		oPrint:SetResolution(78)
		oPrint:SetPortrait() // ou SetLandscape()
		oPrint:SetPaperSize(DMPAPER_A4) 
		oPrint:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior 
		oPrint:cPathPDF := cPath // Caso seja utilizada impressão em IMP_PDF 
		cDiretorio := oPrint:cPathPDF
        //oPrint		:= TMSPrinter():New(OemToAnsi('Pedido de Compras')),;
		
Private	oBrush		:= TBrush():New(,4),;
		oPen		:= TPen():New(0,5,CLR_BLACK),;
		cFileLogo	:= "\img\logo_pg.png" ,;//GetSrvProfString('Startpath','') + "logo_pg.png",;
		oFont07		:= TFont():New( "Arial",,07,,.t.,,,,,.f. )
		oFont08		:= TFont():New( "Arial",,08,,.f.,,,,,.f. )
		oFont08n    := TFont():New( "Arial",,08,,.t.,,,,,.f. )
		oFont09		:= TFont():New( "Arial",,09,,.f.,,,,,.f. )
		oFont10		:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
		oFont10n	:= TFont():New( "Arial",,10,,.t.,,,,,.f. )
		oFont11		:= TFont():New( "Arial",,11,,.f.,,,,,.f. )
		oFont12		:= TFont():New( "Arial",,12,,.f.,,,,,.f. )
		oFont12n	:= TFont():New( "Arial",,14,,.t.,,,,,.f. )
		oFont14		:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
		oFont15		:= TFont():New( "Arial",,15,,.f.,,,,,.f. )
		oFont18		:= TFont():New( "Arial",,18,,.f.,,,,,.f. )
		oFont16		:= TFont():New( "Arial",,16,,.f.,,,,,.f. )
		oFont20		:= TFont():New( "Arial",,20,,.f.,,,,,.f. )
		oFont22		:= TFont():New( "Arial",,22,,.f.,,,,,.f. )

	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta query !³    //SC7.C7_CODPRF, 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSELECT :=	'SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_COND, SC7.C7_CONTATO, SC7.C7_OBS, SC7.C7_OP , '+;
					'SC7.C7_ITEM, SC7.C7_UM,SC7.C7_SEGUM,SC7.C7_QTSEGUM,SC7.C7_XUNIDAD,SC7.C7_PRODUTO, SC7.C7_DESCRI, SC7.C7_QUANT, '+;
					'SC7.C7_PRECO, SC7.C7_IPI, SC7.C7_TOTAL, SC7.C7_VLDESC, SC7.C7_DESPESA, SC7.C7_XPRECO2, '+;       
				  	'SC7.C7_SEGURO, SC7.C7_VALFRE, SC7.C7_TES, SC7.C7_VALIMP1,  0 C7_VALIMP8,SC7.C7_DATPRF, SC7.C7_USER, SC7.C7_USER C7_XLINPRE , SC7.C7_ITEMCTA, SC7.C7_MOEDA,SC7.C7_CC,SC7.C7_NUMSC,SC7.C7_CONTRA, '+;
					'CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),C7_OBSM)) AS OBSM'
		
		cFROM   :=	RetSqlName('SC7') + ' SC7 '

		cWHERE  :=	'SC7.D_E_L_E_T_ <>   '+CHR(39) + '*'            +CHR(39) + ' AND '+;
					'SC7.C7_FILIAL  =    '+CHR(39) + xFilial('SC7') +CHR(39) + ' AND '+;
					'SC7.C7_NUM     =    '+CHR(39) + cNumPed        +CHR(39) 

		cORDER  :=	'SC7.C7_FILIAL, SC7.C7_ITEM '

		cQuery  :=	' SELECT '   + cSELECT + ; 
					' FROM '     + cFROM   + ;
					' WHERE '    + cWHERE  + ;
					' ORDER BY ' + cORDER

		TCQUERY cQuery NEW ALIAS 'TRA'   
		
		TcSetField('TRA','C7_DATPRF','D')

		If	! USED()
			MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
		EndIf

		DbSelectArea('TRA')
		Count to _nQtdReg
		ProcRegua(_nQtdReg)
		TRA->(DbGoTop())

		cCompr := TRA->C7_USER
		
		cTipoSC7	:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
		cComprador 	:= UsrFullName(SC7->C7_USER)
		cAlter	 	:= ''
		cAprov	 	:= ''

		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf

		// Aprovadores
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
		IF Eof() .AND. cTipoSC7=="PC"  	// LIBERACION POR PEDIDO COMPLETO
			cTipoSC7:="IP"				// LIBERACION POR ITEM DE PEDIDO
			dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
		EndIf
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. (SCR->CR_TIPO == cTipoSC7) 
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
				Case SCR->CR_STATUS=="03" //Liberado
					cAprov += "Ok"
				Case SCR->CR_STATUS=="04" //Bloqueado
					cAprov += "BLQ"
				Case SCR->CR_STATUS=="05" //Nivel Liberado
					cAprov += "##"
				Case SCR->CR_STATUS=="01" //Bloqueado p/ sistema(aguardando outros niveis)
					//cAprov += "EnEspera"
					cAprov += "??"
				Case SCR->CR_STATUS=="02" //Aguardando Liberacao do usuario
					//cAprov += "SinLiberar
					cAprov += "??"
				OtherWise                 //Aguar.Lib
					cAprov += "??"
					
					/*
					'CR_STATUS== "01"', 'BR_AZUL' },;//Bloqueado p/ sistema(aguardando outros niveis)
					{ 'CR_STATUS== "02"', 'DISABLE' },;//Aguardando Liberacao do usuario
					{ 'CR_STATUS== "03"', 'ENABLE' },;//Pedido Liberado pelo usuario
					{ 'CR_STATUS== "04"', 'BR_PRETO'},;//Pedido Bloqueado pelo usuario
					{ 'CR_STATUS== "05"', 'BR_CINZA'} }//Pedido Liberado por outro usuario
					*/
			EndCase
			cAprov += "] - "
			dbSelectArea("SCR")
			dbSkip()
		Enddo

      	cObServ := ''
		While 	TRA->( ! Eof() )

				xVerPag()

				If	( lFlag )
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³Fornecedor³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Say(0530,0100,OemToAnsi('Proveedor:'),oFont10)
					oPrint:Say(0520,0430,AllTrim(SA2->A2_NOME) + '  ('+AllTrim(SA2->A2_COD)+'/'+AllTrim(SA2->A2_LOJA)+')',oFont11)  
					oPrint:Say(0580,0100,OemToAnsi('Dirección:'),oFont10)
					oPrint:Say(0580,0430,SA2->A2_END,oFont11)
					oPrint:Say(0630,0100,OemToAnsi('Ciudad:'),oFont10)
					oPrint:Say(0630,0430,AllTrim(SA2->A2_MUN)+'/'+AllTrim(SA2->A2_EST),oFont11)
					oPrint:Say(0630,1100,OemToAnsi('Zip:'),oFont10)
					oPrint:Say(0630,1300,TransForm(SA2->A2_CEP,'@R 99.999-999'),oFont11)
					oPrint:Say(0680,0100,OemToAnsi('Teléfono:'),oFont10)
					oPrint:Say(0680,0430,SA2->A2_TEL,oFont11)
					oPrint:Say(0680,1100,OemToAnsi('NIT:'),oFont10)
					oPrint:Say(0680,1300,Transform(SA2->A2_CGC,'@R 9999999999-99'),oFont11)
					oPrint:Say(0730,0100,OemToAnsi('Contacto:'),oFont10)
					oPrint:Say(0730,0430,SC7->C7_CONTATO,oFont11)
					oPrint:Say(0730,1100,OemToAnsi('E-mail:'),oFont10)
					oPrint:Say(0730,1300,SA2->A2_EMAIL,oFont11)      
					oPrint:Say(0780,0100,OemToAnsi('Moneda:'),oFont10)
					oPrint:Say(0780,0430,ALLTRIM(GETMV("MV_MOEDA"+str(SC7->C7_MOEDA,1))),oFont11)   
					oPrint:Say(0780,1100,OemToAnsi('Bogeda Entr.:'),oFont10)
					oPrint:Say(0780,1300,Upper(Posicione("NNR",1,xFilial("NNR")+MV_PAR02,"NNR_DESCRI")),oFont11)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Numero/Emissao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPrint:Box(0530,1900,0700,2300)
					oPrint:Say(0580,1960,OemToAnsi('Numero de la Orden'),oFont10n)
					oPrint:Say(0630,2000,SC7->C7_NUM,oFont18)
					oPrint:Say(0680,2000,Dtoc(SC7->C7_EMISSAO),oFont12n)
					lFlag := .f.
				EndIf
	
				If	( lPrintDesTab )
					oPrint:Box(nLinha+20,100,nLinha+80,2300) 
					oPrint:Say(nLinha+55,0120,OemToAnsi('Line'),oFont12n)
					oPrint:Say(nLinha+55,0600,OemToAnsi('Item'),oFont12n)
				//	oPrint:Say(nLinha+55,0420,OemToAnsi('Descripción'),oFont12n) 
				//	oPrint:Say(nLinha+55,1000,OemToAnsi('LP'),oFont12n)
					oPrint:Say(nLinha+55,1190,OemToAnsi('F. Entrg'),oFont12n)
					oPrint:Say(nLinha+55,1360,OemToAnsi('Cantid'),oFont12n)
					oPrint:Say(nLinha+55,1560,OemToAnsi('UN'),oFont12n)
					oPrint:Say(nLinha+55,1700,OemToAnsi('Vlr.Unit.'),oFont12n)
					oPrint:Say(nLinha+55,1910,OemToAnsi('IVA %'),oFont12n)
					oPrint:Say(nLinha+55,2080,OemToAnsi('Valor Total'),oFont12n)
					lPrintDesTab := .f.
					nLinha += 110
				EndIf
                                                                         
				oPrint:Say(nLinha,0120,Right(TRA->C7_ITEM,2),oFont10n)
				cCodPro 	:= ''
				cDesc 		:= ''
				cCodProSA5	:=''
				cDescSA5	:= ''
			//	If	( lPrintCodFor )
					DbSelectArea('SA5')
					SA5->(DbSetOrder(1))
					If	SA5->(DbSeek(xFilial('SA5') + SA2->A2_COD + SA2->A2_LOJA + TRA->C7_PRODUTO)) .and. ( ! Empty(SA5->A5_CODPRF) )
						cCodProSA5 := SA5->A5_CODPRF
					EndIf
				//Else
				//	cCodPro := TRA->C7_PRODUTO
				//EndIf	                                            
			   	//	oPrint:Say(nLinha,1000,TRA->C7_XLINPRE,oFont10) 
				//oPrint:Say(nLinha,1000,TRA->C7_ITEMCTA,oFont10)     
				
				IF TRA->C7_XUNIDAD$'2'
					oPrint:Say(nLinha,1560,TRA->C7_SEGUM,oFont10)
				else
					oPrint:Say(nLinha,1560,TRA->C7_UM,oFont10)
				EndIF	
				oPrint:Say(nLinha,1190,DtoC(TRA->C7_DATPRF),oFont10n,,,,1)
				If TRA->C7_XUNIDAD$'2'
				    oPrint:Say(nLinha,1410,Alltrim(TransForm(TRA->C7_QTSEGUM,'@E 99,999,999.99')),oFont10n,,,,1)
				else
					oPrint:Say(nLinha,1410,Alltrim(TransForm(TRA->C7_QUANT,'@E 99,999,999.99')),oFont10n,,,,1)
				EndIf
				If	( lImpPrc )
					if TRA->C7_XUNIDAD$'2'
					oPrint:Say(nLinha,1700,AllTrim(TransForm(TRA->C7_XPRECO2,'@E 99,999,999,999.99')),oFont10n,,,,1)
					Else
					oPrint:Say(nLinha,1700,AllTrim(TransForm(TRA->C7_PRECO,'@E 99,999,999,999.99')),oFont10n,,,,1)
					EndIf
					oPrint:Say(nLinha,1950,AllTrim(TransForm(TRA->C7_VALIMP1,'@E 99,999,999,999.99')),oFont10n,,,,1)
					oPrint:Say(nLinha,2150,AllTrim(TransForm(TRA->C7_TOTAL,'@E 99,999,999,999.99')),oFont10n,,,,1)
				EndIf

				SB1->(dbSetOrder(1), dbSeek(xFilial("SB1")+TRA->C7_PRODUTO))
				If SA5->(DbSeek(xFilial('SA5') + SA2->A2_COD + SA2->A2_LOJA + TRA->C7_PRODUTO)) .and. ( ! Empty(SA5->A5_CODPRF) )
					cDescSA5 := Alltrim(SA5->A5_XDESPRO)
				Endif
				
				//nLinCod := MlCount(cCodPro,21)
				 nLinCod := MlCount(TRA->C7_PRODUTO,25)
				_nLinhas := MlCount(SB1->B1_DESC,50)
				//For _nT := 1 To Max(_nLinhas,nLinCod)
				For _nT := 1 To (_nLinhas)
					oPrint:Say(nLinha,0250,MemoLine(Alltrim(TRA->C7_PRODUTO),25,_nT),oFont10)
					nLinha+=40
					//oPrint:Say(nLinha,0250,Capital(MemoLine(AllTrim(SB1->B1_DESC),60,_nT)),oFont10,,0)
					oPrint:Say(nLinha,0250,Upper(MemoLine(AllTrim(TRA->C7_DESCRI),50,_nT)),oFont10,,0)
					If !Empty(TRA->C7_OP)
					nLinha+=40
					oPrint:Say(nLinha,0250,Capital(MemoLine(Alltrim(TRA->C7_OP),50,_nT)),oFont10,,0)
					EndIf
					If !Empty(cCodProSA5)
					nLinha+=40
					oPrint:Say(nLinha,0250,Upper(Capital(MemoLine(Alltrim(Upper(cCodProSA5))),50,_nT)),oFont10,,0)
					EndIF
					If !Empty(TRA->OBSM)
					nLinha+=40
					oPrint:Say(nLinha,0250,Capital(MemoLine(Alltrim(TRA->OBSM),50,_nT)),oFont10,,0)
					EndIF
				Next _nT
		
				nLinha+=40

				oPrint:Line(nLinha,100,nLinha,2300)

				nLinha+=30

				_nValMerc 		+= TRA->C7_TOTAL
				_nValIPI		+= (TRA->C7_TOTAL * TRA->C7_IPI) / 100
				_nValDesc		+= TRA->C7_VLDESC
				_nTotAcr		+= TRA->C7_DESPESA
				_nTotSeg		+= TRA->C7_SEGURO
				_nTotFre		+= TRA->C7_VALFRE
              
				If	( Empty(TRA->C7_TES) )
					_nTotIcmsRet	+= TRA->C7_VALIMP1
				Else
					DbSelectArea('SF4')
					SF4->(DbSetOrder(1))
					If	SF4->(DbSeek(xFilial('SF4') + TRA->C7_TES))
						If	( AllTrim(SF4->F4_INCSOL) == 'S' )
							_nTotIcmsRet	+= TRA->C7_VALIMP1
						EndIf
					EndIf
				EndIf
                           
               
               If	( Empty(TRA->C7_TES) )
					_nTotIPC 	+= TRA->C7_VALIMP8
				Else
					DbSelectArea('SF4')
					SF4->(DbSetOrder(1))
					If	SF4->(DbSeek(xFilial('SF4') + TRA->C7_TES))
						If	( AllTrim(SF4->F4_INCSOL) == 'S' )
							_nTotIPC 	+= TRA->C7_VALIMP8
						EndIf
					EndIf
				EndIf
               
                
                       
                        
                        
				       
				cObserv += AllTrim(TRA->C7_OBS)+' ' 
				

			
				
			IncProc()
			TRA->(DbSkip())	

		End
		nLinha-=30

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE MERCADORIAS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor sin Impuestos ',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValMerc,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE I.P.I. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nValIpi > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor de IVA (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValIpi,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE DESCONTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nValDesc > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor de Descuento (-)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nValDesc,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE ACRESCIMO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotAcr > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor Gasto/Flete(+)',oFont12)
		//	oPrint:Say(nLinha+30,1400,'Valor de Acresc. (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotAcr,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE SEGURO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotSeg > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor de Seguro (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotSeg,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime TOTAL DE FRETE ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	( lImpPrc ) .and. ( _nTotFre > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor de Flete (+)',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotFre,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime ICMS RETIDO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
		
		If	( lImpPrc ) .and. ( _nTotIcmsRet > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor IVA',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotIcmsRet,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf
                  
		xVerPag()     

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime IMPOCONSUMO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
		
		If	( lImpPrc ) .and. ( _nTotIPC > 0 )
			oPrint:Line(nLinha,1390,nLinha+80,1390)
			oPrint:Line(nLinha,1900,nLinha+80,1900)
			oPrint:Line(nLinha,2300,nLinha+80,2300)
			oPrint:Say(nLinha+30,1400,'Valor IPC',oFont12)
			oPrint:Say(nLinha+30,2050,TransForm(_nTotIPC,'@E 99,999,999,999.99'),oFont11,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,1390,nLinha,2300)
		EndIf
                  
		xVerPag()		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o VALOR TOTAL !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		oPrint:FillRect({nLinha,1390,nLinha+80,2300},oBrush)
		oPrint:Line(nLinha,1390,nLinha+80,1390)
		oPrint:Line(nLinha,1900,nLinha+80,1900)
		oPrint:Line(nLinha,2300,nLinha+80,2300)
		oPrint:Say(nLinha+30,1400,'VALOR TOTAL ',oFont12)
		If	( lImpPrc )
		oPrint:Say(nLinha+30,2050,TransForm(_nValMerc + _nValIPI - _nValDesc + _nTotAcr	+ _nTotSeg + _nTotFre + _nTotIcmsRet + _nTotIPC,'@E 99,999,999,999.99'),oFont11,,,,1)          
		EndIf
		nLinha += 80
		xVerPag()
		oPrint:Line(nLinha,1390,nLinha,2300)
		nLinha += 70

		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime as observacoes dos parametros. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cObserv1 := Left(SC7->C7_OBS,200)
	//	cObserv2 := SubStr(cObserv2,71,70)
	//	cObserv3 := SubStr(cObserv3,141,70)
	//	cObserv4 := SubStr(cObserv4,211,70)
		oPrint:Say(nLinha,0100,OemToAnsi('Observaciones:'),oFont12)
		If	( ! Empty(cObserv1) )
			nLin := mlcount(cObserv1,80)
			For i := 1 to nLin
		        If Alltrim(MemoLine(cObserv1,80,i))<>""
				oPrint:Say(nLinha,0500,MemoLine(cObserv1,80,i),oFont12n)
			    nLinha+=60
			    xVerPag()
			   	EndIf
		    Next
			/*oPrint:Say(nLinha,0100,OemToAnsi('Observaciones:'),oFont12)
			oPrint:Say(nLinha,0500,Alltrim(cObserv1),oFont12n)
			nLinha += 60
			xVerPag()*/
		EndIf
	/*	If	( ! Empty(cObserv2) )
			oPrint:Say(nLinha,0500,cObserv2,oFont12n)
			nLinha += 60
			xVerPag()
		EndIf	
		If	( ! Empty(cObserv3) )
			oPrint:Say(nLinha,0500,cObserv3,oFont12n)
			xVerPag()
			nLinha += 60
		EndIf	
		If	( ! Empty(cObserv4) )
			oPrint:Say(nLinha,0500,cObserv4,oFont12n)
			xVerPag()
			nLinha += 60
			xVerPag()
		EndIf
	*/
		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o Representante comercial do fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		/*
		DbSelectArea('SZF')
		SZF->(DbSetOrder(1))
		If	SZF->(DbSeek(xFilial('SZF') + SA2->A2_COD + SA2->A2_LOJA))
			If	( ! Empty(SZF->ZF_REPRES) )
				oPrint:Say(nLinha,0100,OemToAnsi('Representante:'),oFont12)
				oPrint:Say(nLinha,0500,AllTrim(SZF->ZF_REPRES) + Space(5) + AllTrim(SZF->ZF_TELREPR) + Space(5) + AllTrim(SZF->ZF_FAXREPR),oFont12n)
				nLinha += 60
				xVerPag()
			EndIf
		EndIf	
        */
		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a linha de prazo pagamento/entrega!³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Say(nLinha,0100,OemToAnsi('Plazo de Pago:'),oFont12)
		If !Empty(SC7->C7_COND)
			If SE4->(dbSetOrder(1), dbSeek(xFilial("SE4")+SC7->C7_COND))
				oPrint:Say(nLinha,0500, SE4->E4_DESCRI,oFont12n)
			Endif
		Else
			oPrint:Say(nLinha,0500,'_____________________',oFont12n)
		Endif
		
//		oPrint:Say(nLinha,1120,OemToAnsi('Prazo Entrega:'),oFont12)
//		oPrint:Say(nLinha,1500,'___________________________',oFont12n)
		nLinha += 60
  		xVerPag()

		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a linha de transportadora !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*		oPrint:Say(nLinha,0100,OemToAnsi('Transportadora:'),oFont12)
		oPrint:Say(nLinha,0500,'____________________________________________________',oFont12n)*/
		nLinha += 60
		xVerPag()

		nLinha += 20
		xVerPag()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o Contato.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		/*
		If	( ! Empty(SA2->A2_CONTATO) )
			oPrint:Say(nLinha,0100,OemToAnsi('Contacto: '),oFont12)
			oPrint:Say(nLinha,0500,SA2->A2_CONTATO,oFont12n)
			nLinha += 60
			xVerPag()
		EndIf
          */
		oPrint:Line(nLinha,0100,nLinha,2300)
		nLinha += 10
		xVerPag()

		xRodape()

		TRA->(DbCloseArea())

		
/*		If !Empty(_nQtdReg)
			U_EPed(cNumPed,'')					
		Endif
  */		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime em Video, e finaliza a impressao. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oPrint:Preview()
		
		If lEmail
			U_PedMail()
		Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xCabec() ºAutor ³Luis Henrique Robustoº Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Cabecalho do relatorio...                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xCabec()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   //	oPrint:SayBitmap(050,100,cFileLogo,1050,260) SayBitmap(030,100,cFileLogo,352,324)
	    oPrint:SayBitmap(030,100,cFileLogo,600,260)
		oPrint:Say(050,1300,AllTrim(Upper(SM0->M0_NOMECOM)),oFont16)
		oPrint:Say(135,1300,AllTrim(SM0->M0_ENDCOB),oFont11)
		oPrint:Say(180,1300,Capital(AllTrim(SM0->M0_CIDCOB))+'/'+AllTrim(SM0->M0_ESTCOB)+ '  -  ' + AllTrim(TransForm(SM0->M0_CEPCOB,'@R 99.999-999')) + '  -  ' + AllTrim(SM0->M0_TEL),oFont11)
		oPrint:Say(225,1300,AllTrim('Producciones Generales'),oFont11)
		oPrint:Line(265,1300,265,2270)
		oPrint:Say(300,1300,TransForm(SM0->M0_CGC,'@R 999999999-99'),oFont12)
		oPrint:Say(300,1850,SM0->M0_INSC,oFont12)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Titulo do Relatorio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//If	( nTitulo == 1 ) // Cotacao
		//	oPrint:Say(0400,0800,OemToAnsi('Cotización de Compra'),oFont22)
		//Else
			oPrint:Say(0400,0900,OemToAnsi('Orden de Compra'),oFont22)
		//EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xRodape()ºAutor ³Luis Henrique Robustoº Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Rodape do Relatorio....                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xRodape()

Local TXTOC1 := SuperGetMv("MV_TXTOC1") 
Local TXTOC2 := SuperGetMv("MV_TXTOC2") 

//oPrint:Say(2910,0100,'NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras. ',oFont12n)
oPrint:Line(2650,0100,2650,2300)     
oPrint:Say(2690,0100,"Responsable : "+Substr(cComprador,1,60),oFont11)
oPrint:Say(2730,0100,"E-mail : "+If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),oFont11)
oPrint:Say(2770,0500,If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),oFont11)
oPrint:Say(2810,0100,"Aprobador(es) : "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),oFont11)
oPrint:Say(2850,0500,If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),oFont11)

oPrint:Say(2900,0100,Substr(TXTOC1,1,150),oFont11)
oPrint:Say(2940,0100,Substr(TXTOC1,151,150)+Substr(TXTOC2,1,51),oFont11)
oPrint:Say(2980,0100,Substr(TXTOC2,52,150),oFont11)
oPrint:Say(3020,0100,Substr(TXTOC2,151,150),oFont11)

//	oPrint:Line(3080,0100,3080,2300)
//   oPrint:Say(3120,1050,AllTrim(SM0->M0_TEL),oFont16)
//	oPrint:Line(3200,0100,3200,2300)
/*   oPrint:Say(3300,0100,'ENVIAR CERTIFICADO DE QUALIDADE E MENCIONAR Nº DO NOSSO PEDIDO NA NOTA FISCAL',oFont08n)
   IF SB1->B1_TIPO == 'MP'
	   oPrint:Say(3330,0100,'O PEDIDO REPRESENTA INTENÇÃO DE COMPRAS FIRME, PORÉM AS ENTREGAS OCORRERÃO RESPEITANDO O KANBAN SEMANAL. EVENTUAIS EXCESSOS SERÃO AJUSTADOS NO MÊS POSTERIOR',oFont08n)
	ENDIF
   oPrint:Say(3360,0100,'ENDEREÇO DE ENTREGA = RUA JOÃO NINCÃO, 328 CAPUAVA MAUÁ',oFont08n) 
   oPrint:Say(3390,0100,'NÃO RECEBEREMOS NOTAS COM MAIS DE 24 HORAS DA DATA DE EMISSAO',oFont08n) */
	oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xVerPag()ºAutor ³Luis Henrique Robustoº Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se deve ou nao saltar pagina...                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xVerPag()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia a montagem da impressao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	( nLinha >= 2650 )

		If	( ! lFlag )
			xRodape()
			oPrint:EndPage()
			nLinha:= 600
		Else
			nLinha:= 800
		EndIf

		oPrint:StartPage()
		xCabec()

		lPrintDesTab := .t.

	EndIf
	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1ºAutor ³Luis Henrique Robustoº Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
Local	aRegs   := {},;
		_sAlias := Alias(),;
		nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos a serem grav. no SX1³
		//³aRegs[nx][01] - X1_GRUPO   ³
		//³aRegs[nx][02] - X1_ORDEM   ³
		//³aRegs[nx][03] - X1_PERGUNTE³
		//³aRegs[nx][04] - X1_PERSPA  ³
		//³aRegs[nx][05] - X1_PERENG  ³
		//³aRegs[nx][06] - X1_VARIAVL ³
		//³aRegs[nx][07] - X1_TIPO    ³
		//³aRegs[nx][08] - X1_TAMANHO ³
		//³aRegs[nx][09] - X1_DECIMAL ³
		//³aRegs[nx][10] - X1_PRESEL  ³
		//³aRegs[nx][11] - X1_GSC     ³
		//³aRegs[nx][12] - X1_VALID   ³
		//³aRegs[nx][13] - X1_VAR01   ³
		//³aRegs[nx][14] - X1_DEF01   ³
		//³aRegs[nx][15] - X1_DEF02   ³
		//³aRegs[nx][16] - X1_DEF03   ³
		//³aRegs[nx][17] - X1_F3      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria uma array, contendo todos os valores...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegs,{cPerg,'01','Numero Orden de Compra   ?','Numero Orden de Compra   ?','Numero Orden de Compra   ?','mv_ch1','C', 6,0,0,'G','','mv_par01','','','','SC7'})
	//	aAdd(aRegs,{cPerg,'02','Imprime precios    ?','Imprime precios     ?','Imprime precios     ?','mv_ch2','N', 1,0,1,'C','','mv_par02',OemToAnsi('No'),'Si','',''})
	//	aAdd(aRegs,{cPerg,'03','Titulo do Informe?','Titulo do Informe?','Titulo do Informe?','mv_ch3','N', 1,0,1,'C','','mv_par03',OemToAnsi('Cotización'),'Orden de Compra','',''})
	//	aAdd(aRegs,{cPerg,'02',OemToAnsi('Observaciones'),'Observaciones         ','Observaciones         ','mv_ch2','C',99,0,1,'G','','mv_par02','','','',''})
	//	aAdd(aRegs,{cPerg,'05','                    ','                    ','                    ','mv_ch5','C',70,0,1,'G','','mv_par05','','','',''})
	//	aAdd(aRegs,{cPerg,'06','                    ','                    ','                    ','mv_ch6','C',70,0,0,'G','','mv_par06','','','',''})
	//	aAdd(aRegs,{cPerg,'07','                    ','                    ','                    ','mv_ch7','C',70,0,0,'G','','mv_par07','','','',''})
	//	aAdd(aRegs,{cPerg,'08','Imp. Cod. Prod. For?','Imp. Cod. Prod. For?','Imp. Cod. Prod. For?','mv_ch8','N', 1,0,1,'C','','mv_par08',OemToAnsi('Si'),OemToAnsi('No'),'',''})

		DbSelectArea('SX1')
		SX1->(DbSetOrder(1))                                                                                                                      

		For nX:=1 to Len(aRegs)
			If !SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02]))
				RecLock('SX1',.t.)
				Replace SX1->X1_GRUPO		With aRegs[nx][01]
				Replace SX1->X1_ORDEM   	With aRegs[nx][02]
				Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
				Replace SX1->X1_PERSPA		With aRegs[nx][04]
				Replace SX1->X1_PERENG		With aRegs[nx][05]
				Replace SX1->X1_VARIAVL		With aRegs[nx][06]
				Replace SX1->X1_TIPO		With aRegs[nx][07]
				Replace SX1->X1_TAMANHO		With aRegs[nx][08]
				Replace SX1->X1_DECIMAL		With aRegs[nx][09]
				Replace SX1->X1_PRESEL		With aRegs[nx][10]
				Replace SX1->X1_GSC			With aRegs[nx][11]
				Replace SX1->X1_VALID		With aRegs[nx][12]
				Replace SX1->X1_VAR01		With aRegs[nx][13]
				Replace SX1->X1_DEF01		With aRegs[nx][14]
				Replace SX1->X1_DEF02		With aRegs[nx][15]
				Replace SX1->X1_DEF03		With aRegs[nx][16]
				Replace SX1->X1_F3   		With aRegs[nx][17]
				MsUnlock('SX1')
			Endif
		Next nX

Return

USER Function PedMail()
Private _PedCom
Private nTarget:=0
Private cFOpen :=""
Private nOpc   := 0
Private bOk    := {||nOpc:=1,_PedCom:End()}
Private bCancel:= {||nOpc:=0,_PedCom:End()} 
Private lCheck1:=.F.
Private lCheck2:=.T.
Private lCheck3:=.f.


_cPara   :=SA2->A2_EMAIL
_cContato:=PadR(SA2->A2_CONTATO,30)

mCorpo := 'Sr.(a): ' + _cContato +Chr(13)+Chr(10)+Chr(13)+Chr(10)
mCorpo += 'Sigue Anexo Orden de Compra: ' + cNumPed +Chr(13)+Chr(10)+Chr(13)+Chr(10)
mCorpo += 'SOCIEDAD MINERA DE SANTANDER S.A.S'+Chr(13)+Chr(10)
mCorpo += 'Teléfono: +57 7 6971200'+Chr(13)+Chr(10)
mCorpo += 'E-mail: proveedor@minesa.com'+Chr(13)+Chr(10)
mCorpo += 'Site: www.minesa.com'+Chr(13)+Chr(10)

Define MsDialog _PedCom Title "Orden de Compra Eletrónica" From 127,037 To 531,774 Pixel 
@ 013,006 To 053,357 Title OemToAnsi("  Datos de la Orden ") 
@ 020,010 Say "Orden:" Color CLR_HBLUE // Size 25,8 
@ 020,040 Get cNumPed Picture "@!" When .f.
@ 020,097 Say "E-mail:" Color CLR_HBLUE //Size 25,8 
@ 020,125 Get _cPara Picture "@" Size 150,08
@ 030,010 Say "Proveedor: " Color CLR_HBLUE
@ 030,042 Say SA2->A2_NOME Color CLR_HRED Object oCliente //Size 19,8 
@ 040,010 Say "Contacto: " Color CLR_HBLUE //Size 25,8 
@ 040,042 Say _cContato Object oAutor
@ 040,042 Get _cContato Picture "@" Size 150,08

@ 80,010 To 182,360
@ 88,015 Get mCorpo MEMO Size 340,90

Activate MsDialog _PedCom On Init EnchoiceBar(_PedCom,bOk,bCancel,,) Centered
If nOpc == 1
	cAnexo := 'C:\TEMP\'+cFilename+'.PDF'
	EnvMail(cAnexo, cNumPed, _cPara, _cContato, mCorpo)
EndIf
Return .t.




Static Function EnvMail(cAnexo,cNumPed,cPara,cContato,mCorpo)
Private cAssunto     := 'Orden de Compra - No. ' + cNumPed
Private nLineSize    := 60
Private nTabSize     := 3
Private lWrap        := .T. 
Private nLine        := 0
Private cTexto       := ""
Private lServErro	   := .T.
Private cServer  := Trim(GetMV("MV_RELSERV")) // 
Private cDe 	:= Trim(GetMV("MV_RELACNT"))
Private cPass    := Trim(GetMV("MV_RELPSW"))  // 
Private lAutentic	:= GetMv("MV_RELAUTH",,.F.)
Private aTarget  :={cAnexo}
Private nTarget := 0
Private lCheck1 := .F.
Private lCheck2 := .f.

cCC := UsrRetMail(RetCodUsr())
cAnexos:=cAnexo
CPYT2S(cAnexos,GetSrvProfString("Startpath", "")+'emailanexos\',.T.)
cAnexos:=GetSrvProfString("Startpath", "")+'emailanexos\'+SubStr(AllTrim(cAnexos),RAT('\',AllTrim(cAnexos))+1)
lServERRO 	:= .F.
                    
CONNECT SMTP                         ;
SERVER 	 GetMV("MV_RELSERV"); 	// Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	// Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW") ; 	// Senha
Result lConectou    

lRet := .f.
lEnviado := .f.
If lAutentic
	lRet := Mailauth(cDe,cPass)
Endif
If lRet  
	cPara   := Rtrim(cPara)
	cCC		:= Rtrim(cCC)    
	cAssunto:= Rtrim(cAssunto)  
	
//	    	    BCC 'diretoria@metalacre.com.br;gerencia@metalacre.com.br';

	SEND MAIL 	FROM cDe ;
		 		To cPara ;
	    	    CC cCc;
		 		SUBJECT	cAssunto ; 
		 		Body mCorpo;		
		 		ATTACHMENT cAnexos;
		 		RESULT lEnviado

	DISCONNECT SMTP SERVER
Endif
If !lConectou .Or. !lEnviado
	cMensagem := ""
	GET MAIL ERROR cMensagem 
	Alert(cMensagem)
Endif          
FERASE(cAnexos)
Return                      
