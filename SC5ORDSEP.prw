#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

User Function SC5ORDSEP()

Local cAliasSC9 := GetNextAlias()
Local cQry	  	:= ""
Local nRet      := ""
Local nOrdSep   := ""

    cQry := "SELECT COUNT(C9_ORDSEP) as TOTAL "
	cQry += "FROM " + RetSqlName("SC9") + " "
	cQry += "WHERE D_E_L_E_T_ = ' ' AND "
	cQry += "C9_ORDSEP<>'' AND "
	cQry += "C9_PEDIDO  = '" + SC5->C5_NUM + "' "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSC9,.T.,.T.) 
	If (cAliasSC9)->(!EOF())
		nRet := (cAliasSC9)->TOTAL
	Endif
	(cAliasSC9)->(DbCloseArea()) 

    IF nRet >= 1
		nOrdSep := "Si"
	Else
		nOrdSep := " "
	endIF

Return nOrdSep

