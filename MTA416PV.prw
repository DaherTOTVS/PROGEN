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
	//Felipe Gonzalez 20/09/2023 Adicion para agregar modalidad
	M->C5_NATUREZ	:= CJ_XNATURE
	("SFP")->(DBCloseArea())	

Return Nil
