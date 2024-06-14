#include "Protheus.ch"
/*                                                                       >
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CUSTOMERVENDOR �Autor �Juan Pablo Astorga �Fecha 27/05/2024 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Punto de entrada para alterar la CV0 esto para que se     ���
���          �  pueda alterar la fecha de existencia , esto para inclusion���
���          �  y modiciacion                                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function CUSTOMERVENDOR 

Local aParam := PARAMIXB
Local cRet      := .T.
Local oObj      := ""
Local cIdPonto  := ""
Local cIdModel  := ""

If aParam <> NIL
    oObj     := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
    If cIdPonto == 'MODELCOMMITTTS'
        DBSelectArea("CV0")
        dbsetorder(1)
        IF dbseek(xfilial("CV0")+"01"+Padr(SA2->A2_COD,15),.T.)
            RecLock("CV0",.F.)
            CV0->CV0_DTIEXI := SA2->A2_XFECREG
            MsUnlock()
        EndIf
    EndIf
EndIf

Return cRet
