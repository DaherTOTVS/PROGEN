#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATSV015
Fonte de menu para chamada dos artefatos do SMartView para 
Recibos para Despacho

@author FAT/CRM
@since 22/09/2023
@version 1.0
*/
//-------------------------------------------------------------------  

user Function PRBSV001()

//1� par�metro = Relat�rio cadastrado na tabela de De/Para (Campo TR__IDREL)
//2� par�metro = Tipo do relat�rio ("reports" = relat�rio comum, "data-grid" = vis�o de dados, "pivot-table" = tabela din�mica)
//3� par�metro = Tipo do impress�o (Arquivo=1, Email=2)
//4� par�metro = Informa��es de impress�o
//5� par�metro = Par�metros do relat�rio
//6� par�metro = Indica se executa em job
//7� par�metro = Indica se exibe os par�metros para preenchimento
//8� par�metro = Indica se exibe o wizard de configura��o do Smart View
//9� par�metro = Erro da execu��o

totvs.framework.treports.callTReports("backoffice.sv.fat.clintlist","data-grid",,,,.F.)

Return

Function PRBSV001()

//1� par�metro = Relat�rio cadastrado na tabela de De/Para (Campo TR__IDREL)
//2� par�metro = Tipo do relat�rio ("reports" = relat�rio comum, "data-grid" = vis�o de dados, "pivot-table" = tabela din�mica)
//3� par�metro = Tipo do impress�o (Arquivo=1, Email=2)
//4� par�metro = Informa��es de impress�o
//5� par�metro = Par�metros do relat�rio
//6� par�metro = Indica se executa em job
//7� par�metro = Indica se exibe os par�metros para preenchimento
//8� par�metro = Indica se exibe o wizard de configura��o do Smart View
//9� par�metro = Erro da execu��o

totvs.framework.treports.callTReports("backoffice.sv.fat.billingbycustomer",,,,,.F.)

Return
