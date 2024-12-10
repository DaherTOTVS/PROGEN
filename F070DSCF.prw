#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F100TOK � Autor � Juan Pablo Astorga   � Data �  16/12/2021 ���
�������������������������������������������������������������������������͹��
���Descricao � Validar para que se ingrese las cuentas contables  y       ���
���          � Centro de Costo                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F070DSCF
Local cDescuento    := 0
Local cDiaV         := ""
Local dDtLimite     := ""

If FunName()$"FINA087A|FINA998"
    if SE1->E1_DESCFIN<>0 .AND. SE1->E1_DIADESC<>0
        dDtLimite := SE1->E1_VENCREA - SE1->E1_DIADESC
        if dDataBase <= dDtLimite
        cDescuento := (SE1->E1_VALOR-SE1->E1_VALIMP1+SE1->E1_VALIMP2) * (SE1->E1_DESCFIN / 100 )  // 28.11.2024 Juan Pablo Astorga se agrego el VALIMP2 para calcular RETIVA
        Else
            IF SE1->E1_XDESCFI<>0 .and. (SE1->E1_XDIADES<>0 .or. SE1->E1_XDIADES=0)
                cDiaV := SE1->E1_VENCREA - SE1->E1_XDIADES
                if dDataBase <= cDiaV
                    cDescuento := (SE1->E1_VALOR-SE1->E1_VALIMP1+SE1->E1_VALIMP2) * (SE1->E1_XDESCFI / 100 ) // 28.11.2024 Juan Pablo Astorga se agrego el VALIMP2 para calcular RETIVA
                else
                    cDescuento := 0
                EndIF
            EndIf
        EndIF    
    EndIf  
EndIf
Return Round(cDescuento,2)
