#include 'Protheus.ch'
#include "rwmake.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA416PV  �Autor  �Felipe Gonzalez � Data �  13/07/2023     ���
�������������������������������������������������������������������������͹��
���Desc.     � Adiciona campos que el estandar no lleva cuando el         ���
���          � presupuesto se convierte en PV                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA416PV()

	Local nAux		:= PARAMIXB 
	
    M->C5_XNOME		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME")
	M->C5_XNCLIEN	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENT+M->C5_LOJAENT,"A1_NOME")   
	M->C5_XEMAIL	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EMAIL")
	// CAMPO DEFAULT DESDE PV
	M->C5_XENDENT	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ENDENT")
	
Return Nil
