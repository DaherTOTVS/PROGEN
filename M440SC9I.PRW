#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M440SC9I ºAutor  ³Alejandro Perret    ºFecha ³ 20/11/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Graba campos especificos del pedido(SC5/SC6) en la SC9.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FACTURACION - Aprobacion de pedidos - FATXFUN              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M440SC9I()
	Local lMvAvalEst:= SuperGetMV("MV_AVALEST")==2
	Local lBLQlEst:= SuperGetMV("MV_AVALEST")==3
	Local lEstoque	:= .F.
	Local cAccion :=""
   
    // If isincallstack("a462adivsc9")   // si es remito parcial 

	// C9 APARTIR DE CREACIÓN 
		//FUNNAME() = MATA410

	// C9 APARTIR DE LIBERACIÓN PV
		//FUNNAME() = MATA440

	//Liberación apartir de (Gen Doc Salida)
		//MATA461

	// crea liberacion en credito/stock nueva linea
	//funname MATA456




	// EndIf
	/*
	iF (IsinCallStack("U_ARACO005") .or.IsIncallStack("ARACO005")) .and. IsInCallStack("LIBAUT") .and. lBLQlEst
	reclock("SC9",.F.)
	Replace SC9->C9_BLEST	WITH '02'
	MsUnlock()

	EndIf

	*/

Return()
