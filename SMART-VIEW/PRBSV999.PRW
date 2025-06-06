#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV006 - Grupo x Fornecedor
chamada para os relatorios backoffice.sv.com.groupxsupplier.tlpp - COMSV006
@since 21/09/2023
/*/
//-------------------------------------------------------------------
// user Function PRBSV004()
// Local lSuccess As Logical

//    //1� par�metro = Relat�rio cadastrado na tabela de De/Para (Campo TR__IDREL)`
//    //2� par�metro = Tipo do relat�rio ("reports" = relat�rio, "data-grid" = vis�o de dados, "pivot-table" = tabela din�mica)`
//    //Como n�o foi mandado o 6� par�metro como .F. o relat�rio ser� gerado em job, caso esse par�metro seja enviado ser� aberta a tela de op��es`
//    //ljob := .F.	

//     lSuccess := totvs.framework.treports.callTReports("custom.faturamento.proforma.integratedprovider",,,,,.F.,,.T.,)

// Return lSuccess


user Function PRBSV004()

//1� par�metro = Relat�rio cadastrado na tabela de De/Para (Campo TR__IDREL)
//2� par�metro = Tipo do relat�rio ("reports" = relat�rio comum, "data-grid" = vis�o de dados, "pivot-table" = tabela din�mica)
//3� par�metro = Tipo do impress�o (Arquivo=1, Email=2)
//4� par�metro = Informa��es de impress�o
//5� par�metro = Par�metros do relat�rio
//6� par�metro = Indica se executa em job
//7� par�metro = Indica se exibe os par�metros para preenchimento
//8� par�metro = Indica se exibe o wizard de configura��o do Smart View
//9� par�metro = Erro da execu��o

totvs.framework.treports.callTReports("custom.faturamento.Etiqueta.integratedprovider","report",1,,,.F.)

Return

