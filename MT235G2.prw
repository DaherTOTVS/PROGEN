#include "Protheus.ch"
#include "RwMake.ch"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT235G2   �Autor  �Duvan Hernande      � Data �  22/05/25   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada antes da elimina��o do residuo            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT235G2()

Local cAliasPE := PARAMIXB[1]
Local nNum    := PARAMIXB[2]
Local lRet := .T.

If nNum == 1
  IF ALLTRIM(SC7->C7_USER)!=ALLTRIM(MV_PAR18)
     lRet := .F.
  EndIf
ElseIf nNum == 3
dbSelectArea("SC1")
  dbGoto((cAliasPE)->(SC1RECNO))
  IF ALLTRIM(SC1->C1_USER)!=ALLTRIM(MV_PAR18)
     lRet := .F.
  EndIf
  ("SC1")->(DbCloseArea())
EndIf


Return lRet
