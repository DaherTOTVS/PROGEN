#include "protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

user function XCREASDV()


// XCREASDB1('TR01M_CO-046','002','99D5JI')
// XCREASDB2('TR01M_CO-045','002','99D5JJ')
 XCREASDB3('TR01M_CO-044','002','99D5JK')



Return


static function XCREASDB1(cProduto,cLocal,cNumSeq)

	Local aArea    := GetArea()
	Local aSvSDB	:= SDB->(GetArea())
	Local aSvCB9	:= CB9->(GetArea())
	Local cOrdsep    := '019497'
	Local cPedido    := '014742'
    Local cSerie :='R'
    Local cLoja := '01'
    Local cOrigem :='SC6'
	Local cDoc    := '0000000018820'
	Local cClifor   := '901022316'
	Local QryB9      := ""
	Local cFinalB9      := ""
	Local oStatement

    Default cProduto  := ''  
    Default cLocal   := ''
    Default cNumSeq := ''


	QryB9 := " SELECT  CB9_NUMSER FROM  "+RetSQLName('CB9')+" CB9
	QryB9 += " WHERE D_E_L_E_T_ <> '*' "
	QryB9 += " AND CB9_ORDSEP = ? "
	QryB9 += " AND CB9_PEDIDO= ? "
	QryB9 += " AND CB9_PROD = ? "
	oStatement := FWPreparedStatement():New()
	QryB9    := ChangeQuery(QryB9)
	oStatement:SetQuery(QryB9)
	oStatement:SetString(1, cOrdsep)
	oStatement:SetString(2, cPedido)
	oStatement:SetString(3,cProduto)

	QryB9 := oStatement:GetFixQuery()
	cFinalB9 := MpSysOpenQuery(QryB9)

	While (cFinalB9)->(!Eof())

		Reclock('SDB', .T.)
		Replace DB_FILIAL    With xFilial('SDB')
		Replace DB_PRODUTO   With cProduto
		Replace DB_LOCAL     With cLocal
		Replace DB_QUANT     With 1
		Replace DB_EMPENHO   With 0
		Replace DB_LOCALIZ   With 'A'
		Replace DB_NUMSERI   With (cFinalB9)->CB9_NUMSER
		Replace DB_DOC       With cDoc
		Replace DB_SERIE     With cSerie
		Replace DB_CLIFOR    With cClifor
		Replace DB_LOJA      With cLoja
		Replace DB_ORIGEM    With cOrigem
		Replace DB_DATA      With dDataBase
		
		Replace DB_NUMSEQ    With cNumSeq
		Replace DB_TM        With '502'
		Replace DB_TIPO      With 'M'
		Replace DB_ITEM      With '0001'

		Replace DB_SERVIC    With '999'
		Replace DB_ATIVID    With 'ZZZ'
		
		Replace DB_HRINI     With Time()
		
		Replace DB_IDOPERA   With GetSx8Num('SDB','DB_IDOPERA')
		SDB->(MsUnlock())

		(cFinalB9)->(dbSkip())
	EndDo

	(cFinalB9)->(dbCloseArea())

	RestArea(aSvSDB)
	RestArea(aSvCB9)
	RestArea(aArea)

Return
static function XCREASDB2(cProduto,cLocal,cNumSeq)

	Local aArea    := GetArea()
	Local aSvSDB	:= SDB->(GetArea())
	Local aSvCB9	:= CB9->(GetArea())
	Local cOrdsep    := '019497'
	Local cPedido    := '014742'
    Local cSerie :='R'
    Local cLoja := '01'
    Local cOrigem :='SC6'
	Local cDoc    := '0000000018820'
	Local cClifor   := '901022316'
	Local QryB9      := ""
	Local cFinalB9      := ""
	Local oStatement

    Default cProduto  := ''  
    Default cLocal   := ''
    Default cNumSeq := ''


	QryB9 := " SELECT  CB9_NUMSER FROM  "+RetSQLName('CB9')+" CB9
	QryB9 += " WHERE D_E_L_E_T_ <> '*' "
	QryB9 += " AND CB9_ORDSEP = ? "
	QryB9 += " AND CB9_PEDIDO= ? "
	QryB9 += " AND CB9_PROD = ? "
	oStatement := FWPreparedStatement():New()
	QryB9    := ChangeQuery(QryB9)
	oStatement:SetQuery(QryB9)
	oStatement:SetString(1, cOrdsep)
	oStatement:SetString(2, cPedido)
	oStatement:SetString(3,cProduto)

	QryB9 := oStatement:GetFixQuery()
	cFinalB9 := MpSysOpenQuery(QryB9)

	While (cFinalB9)->(!Eof())

		Reclock('SDB', .F.)
		Replace DB_FILIAL    With xFilial('SDB')
		Replace DB_PRODUTO   With cProduto
		Replace DB_LOCAL     With cLocal
		Replace DB_QUANT     With 1
		Replace DB_EMPENHO   With 0
		Replace DB_LOCALIZ   With 'A'
		Replace DB_NUMSERI   With (cFinalB9)->CB9_NUMSER
		Replace DB_DOC       With cDoc
		Replace DB_SERIE     With cSerie
		Replace DB_CLIFOR    With cClifor
		Replace DB_LOJA      With cLoja
		Replace DB_ORIGEM    With cOrigem
		Replace DB_DATA      With dDataBase
		
		Replace DB_NUMSEQ    With cNumSeq
		Replace DB_TM        With '502'
		Replace DB_TIPO      With 'M'
		Replace DB_ITEM      With '0001'

		Replace DB_SERVIC    With '999'
		Replace DB_ATIVID    With 'ZZZ'
		
		Replace DB_HRINI     With Time()
		
		Replace DB_IDOPERA   With GetSx8Num('SDB','DB_IDOPERA')
		SDB->(MsUnlock())

		(cFinalB9)->(dbSkip())
	EndDo

	(cFinalB9)->(dbCloseArea())

	RestArea(aSvSDB)
	RestArea(aSvCB9)
	RestArea(aArea)

Return


static function XCREASDB3(cProduto,cLocal,cNumSeq)

	Local aArea    := GetArea()
	Local aSvSDB	:= SDB->(GetArea())
	Local aSvCB9	:= CB9->(GetArea())
	Local cOrdsep    := '019497'
	Local cPedido    := '014742'
    Local cSerie :='R'
    Local cLoja := '01'
    Local cOrigem :='SC6'
	Local cDoc    := '0000000018820'
	Local cClifor   := '901022316'
	Local QryB9      := ""
	Local cFinalB9      := ""
	Local oStatement

    Default cProduto  := ''  
    Default cLocal   := ''
    Default cNumSeq := ''


	QryB9 := " SELECT  CB9_NUMSER FROM  "+RetSQLName('CB9')+" CB9
	QryB9 += " WHERE D_E_L_E_T_ <> '*' "
	QryB9 += " AND CB9_ORDSEP = ? "
	QryB9 += " AND CB9_PEDIDO= ? "
	QryB9 += " AND CB9_PROD = ? "
	oStatement := FWPreparedStatement():New()
	QryB9    := ChangeQuery(QryB9)
	oStatement:SetQuery(QryB9)
	oStatement:SetString(1, cOrdsep)
	oStatement:SetString(2, cPedido)
	oStatement:SetString(3,cProduto)

	QryB9 := oStatement:GetFixQuery()
	cFinalB9 := MpSysOpenQuery(QryB9)

	While (cFinalB9)->(!Eof())

		Reclock('SDB', .F.)
		Replace DB_FILIAL    With xFilial('SDB')
		Replace DB_PRODUTO   With cProduto
		Replace DB_LOCAL     With cLocal
		Replace DB_QUANT     With 1
		Replace DB_EMPENHO   With 0
		Replace DB_LOCALIZ   With 'A'
		Replace DB_NUMSERI   With (cFinalB9)->CB9_NUMSER
		Replace DB_DOC       With cDoc
		Replace DB_SERIE     With cSerie
		Replace DB_CLIFOR    With cClifor
		Replace DB_LOJA      With cLoja
		Replace DB_ORIGEM    With cOrigem
		Replace DB_DATA      With dDataBase
		
		Replace DB_NUMSEQ    With cNumSeq
		Replace DB_TM        With '502'
		Replace DB_TIPO      With 'M'
		Replace DB_ITEM      With '0001'

		Replace DB_SERVIC    With '999'
		Replace DB_ATIVID    With 'ZZZ'
		
		Replace DB_HRINI     With Time()
		
		Replace DB_IDOPERA   With GetSx8Num('SDB','DB_IDOPERA')
		SDB->(MsUnlock())

		(cFinalB9)->(dbSkip())
	EndDo

	(cFinalB9)->(dbCloseArea())

	RestArea(aSvSDB)
	RestArea(aSvCB9)
	RestArea(aArea)

Return

