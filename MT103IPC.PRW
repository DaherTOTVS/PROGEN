/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103IPC  �Autor  �Juan Pablo  Astorga �Fecha �  11/06/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � PUNTO DE ENTRADA PARA HEREDAR CAMPOS DE PEDIDO DE COMPRA   ���
���          � A FACTURA DE ENTRADA                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Progen                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"

User Function MT103IPC()

_xx := PARAMIXB[1]

aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XUNIDAD" })] := SC7->C7_XUNIDAD
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XPRECO2" })] := SC7->C7_XPRECO2
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_OP" })]      := "  "//SC7->C7_OP
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_CC" })]      := SC7->C7_CC
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XLOCAL" })]  := SC7->C7_LOCAL
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XDESCRI"})]  := SC7->C7_DESCRI // Modificado 16/02/2023 Juan Pablo Astorga
aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_XCODCW"})]   := SC7->C7_XCODCW // Modificado 21/03/2023 Juan Pablo Astorga



Return 
