#Include "Protheus.ch"
#Include "TopConn.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CtaOrdPrCC  �Autor  �Microsiga           � Data �  11/05/15 ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene la cuenta contable del producto de acuerdo         ���
���          � al centro de costos informado en el detalle del documento  ���
���          � del Modulo Producci�n.                        		      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CtaOrdPrCC(ccCostos,cCodPro,cBodega)

Local cCuenta:= ""
Local aArea  := GetArea()
Local TM	 := SD3->D3_TM

DBSelectArea("SB1")
DBSetOrder(1)
DBSeek(xFilial("SB1")+cCodPro)  
 	
DBSelectArea("CTT")
DBSetOrder(1)
DBSeek(xFilial("CTT")+ccCostos)
CtpGto:=CTT->CTT_XTPCC     

IF Alltrim(TM)$'001/501/003/503'	// //IF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'001/501/003/503'
    cCuenta := GETMV("MV_XVARI1")
ElseIf Alltrim(TM)$'012/510'
	cCuenta := GETMV("MV_XVARI2")
ElseIf Alltrim(TM)$'033/603'
	cCuenta := GETMV("MV_XVARI3")
ElseIf Alltrim(TM)$'035/605'
	cCuenta := GETMV("MV_XVARI4")
ElseIF Alltrim(TM)$'601/031/607/609/611/037/038/039'
		IF CtpGto=='51' //Costos de operaciones de administraci�n o compras generales
			cCuenta:= SB1->B1_XGTADM
		ElseIf CtpGto=='52' //Costos de operaciones comerciales     
			cCuenta:= SB1->B1_XGTCOM
		ElseIf CtpGto=='73' //Costos de operaciones operativos      
			cCuenta:= SB1->B1_XGTOPE
		ElseIf CtpGto=='55' //Costos asociados a innovacion
			cCuenta:= SB1->B1_XGTINN
		ElseIf CtpGto=='15' //Costos asociados a activos en curso
			cCuenta:= SB1->B1_XGTATF
		ELSEIF CtpGto=='17' //Costos asociados a proyectos
			cCuenta:= SB1->B1_XGTPRY
		ENDIF
ELSE
			cCuenta := SB1->B1_XCUSGAS
EndIf

RestArea(aArea)

Return(cCuenta)