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

//    //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
//    //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
//    //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
//    //ljob := .F.	

//     lSuccess := totvs.framework.treports.callTReports("custom.faturamento.proforma.integratedprovider",,,,,.F.,,.T.,)

// Return lSuccess


user Function PRBSV004()

//1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
//2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
//3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
//4º parâmetro = Informações de impressão
//5º parâmetro = Parâmetros do relatório
//6º parâmetro = Indica se executa em job
//7º parâmetro = Indica se exibe os parâmetros para preenchimento
//8º parâmetro = Indica se exibe o wizard de configuração do Smart View
//9º parâmetro = Erro da execução

totvs.framework.treports.callTReports("custom.faturamento.Etiqueta.integratedprovider","report",1,,,.F.)

Return

