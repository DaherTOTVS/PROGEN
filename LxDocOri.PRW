#Include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  LXDOCORI     �Autor  �Felipe Gonzalez   � Data �  13/09/23   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User function LXDOCORI()
	Local _cQuery	:= Paramixb[1]

    //Descripcion: Se forza la recepci�n de la moneda y la tasa en NCC Y RFD para calculo correcto de acols
    //Autor: Duvan Hernandez
    //Fecha: 27/06/2024
If (Funname()== "MATA465N".AND. "NCC"$cEspecie)
    U_SyEnterCpo("F1_MOEDA",M->F1_MOEDA, n)
    SysRefresh()
    U_SyEnterCpo("F1_TXMOEDA",M->F1_TXMOEDA, n)
    SysRefresh()
EndIF

If(FUNNAME() $ "MATA462DN" .AND."RFD"$cEspecie)
    U_SyEnterCpo("F1_MOEDA",M->F1_MOEDA, n)
    SysRefresh()
    U_SyEnterCpo("F1_TXMOEDA",M->F1_TXMOEDA, n)
    SysRefresh()
EndIF

Return _cQuery
