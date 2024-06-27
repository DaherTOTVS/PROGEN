#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "XMATA415.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT462MNU �Autor  �Erick Etcheverry� Data �  19/12/21	      ���
�������������������������������������������������������������������������͹��
���Desc.     �Punto de Entrada que adiciona un boton para imprimir        ���
���          �de acuerdo a una rutina en especifica 					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA415MNU()

	PRIVATE aRotina := {{STR0002,"AxPesqui"  	, 0 , 1, 0, .F.},; 	//"Pesquisar"
						{STR0003,"A415Visual"	, 0 , 2, 0, NIL},; 	//"Visualizar"
						{STR0004,"A415Inclui"	, 0 , 3, 0, NIL},; 	//"Incluir"
						{STR0005,"A415Altera"	, 0 , 4, 0, NIL},; 	//"Alterar"
						{STR0038,"A415Exclui"	, 0 , 5, 0, NIL},;	//"Exclui"
						{STR0039,"A415Cancel" 	, 0 , 2, 0, NIL},;	//"Cancela"
						{STR0006,"A415Impri" 	, 0 , 2, 0, NIL},; 	//"impRimir"
						{STR0057,"A415Legend"	, 0 , 2, 0, .F.},;	//"Legenda"
						{STR0076,"MsDocument"	, 0 , 4, 0, NIL}}	//"Conhecimento"

	//������������������������������������������������������������������������Ŀ
	//�Verifica motivo de bloqueio por regra/verba                             �
	//��������������������������������������������������������������������������
	If	SuperGetMv("MV_VEBLQRG", .F., .F.)
		aAdd(aRotina,{STR0084,"OrcBlqRegB", 0 , 0 , 0 , .F.})		// "Blq. Regra"
	EndIf
	Do Case
		Case FUNNAME()=='MATA415' ///credito
		AADD(aRotina,{ 'Aprobar Presupuesto',"MATA416()" , 0 , 5})
        
	EndCase

Return
