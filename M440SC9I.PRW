#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M440SC9I �Autor  �Alejandro Perret    �Fecha � 20/11/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     �Graba campos especificos del pedido(SC5/SC6) en la SC9.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FACTURACION - Aprobacion de pedidos - FATXFUN              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function M440SC9I()
	Local lMvAvalEst:= SuperGetMV("MV_AVALEST")==2
	Local lBLQlEst:= SuperGetMV("MV_AVALEST")==3
	Local lEstoque	:= .F.
	Local cAccion :=""
   
    // If isincallstack("a462adivsc9")   // si es remito parcial 

	// C9 APARTIR DE CREACI�N 
		//FUNNAME() = MATA410

	// C9 APARTIR DE LIBERACI�N PV
		//FUNNAME() = MATA440

	//Liberaci�n apartir de (Gen Doc Salida)
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
