#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  LP610    �Autor  �Juan P. Astorg+a        � Data �  03/11/23 ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene el valor en la cuenta de ingreso(VENTAS)           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function LP610IN() // PESOS 
Local nValor:= 0
//610-001
If Alltrim(SD2->D2_ESPECIE)=='NF'.And.!(SD2->D2_TES)$"512/513/514/805/524/510".And.SF2->F2_VALBRUT>0 
    nValor:= xMoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,1,SF2->F2_DTDIGIT,2,SF2->F2_TXMOEDA)
EndIf
Return nValor

User Function LP610IN2() // DOLARES
Local nValor:= 0
If Alltrim(SD2->D2_ESPECIE)=='NF'.And.!(SD2->D2_TES)$"512/513/514/805/524/510".And.SF2->F2_VALBRUT>0 
    nValor:= xMoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,2,SF2->F2_DTDIGIT,2,SF2->F2_TXMOEDA)
EndIf

Return nValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  LP610    �Autor  �Juan P. Astorg+a        � Data �  03/11/23 ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene el valor en la cuenta de CREE(VENTAS)           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LP610CRE() // PESOS
Local nValor:=0
//610-016
If Alltrim(SD2->D2_ESPECIE)=="NF" .And.!ALLTRIM(SF2->F2_NATUREZ)$'0300105|0300107|0300108'
    nValor:= xMoeda(SD2->D2_VALIMP9,SF2->F2_MOEDA,1,SF2->F2_DTDIGIT,2,SF2->F2_TXMOEDA)                                                                                                                                                                                                                                          
EndIF   
Return nValor

User Function LP610CR2() // DOLAR
Local nValor:=0
If Alltrim(SD2->D2_ESPECIE)=="NF" .And.!ALLTRIM(SF2->F2_NATUREZ)$'0300105|0300107|0300108'
     nValor:= xMoeda(SD2->D2_VALIMP9,SF2->F2_MOEDA,2,SF2->F2_DTDIGIT,2,SF2->F2_TXMOEDA)                                                                                                                                                                                                                                       
EndIf
Return nValor
