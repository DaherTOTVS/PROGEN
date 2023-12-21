#include "protheus.ch"
#Include "Topconn.ch"
#INCLUDE "AcdXFun.ch"
#INCLUDE "apvt100.ch"

user function ACDVCB8()
    Local aSvAlias 	:= GetArea()
    Local aSvSC9   	:= SC9->( GetArea() )
    Local aSvCB9   	:= CB9->( GetArea() )
    Local lRet     := .T.
    Local cProd    :=Paramixb[4]
    Local cNumSer  :=Paramixb[9]
    Local cNumSerNew :=Paramixb[11]
    Local cQuery	:= " "
    Local cFinalQuery := " "
    Local cAlias1	  := " "
    Local oStatement
    Local lApp  := .F.

    If (cNumSer==CB8->CB8_NUMSER)
        lRet:=.T.

        IF EMPTY(cNumSer)
         VtAlert("Producto:  "+cProd+" No cuenta con SERIAL Informado no puede realizar toma ","A V I S O",.T.,1000) //"Aviso"
         lRet := .F.
        EndIF 
    EndIf





If lRet
    oStatement := FWPreparedStatement():New()

    cQuery := " SELECT CB9.R_E_C_N_O_ AS REG FROM "+RetSqlName("CB9")+" CB9"
    cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9 ON "
    cQuery += " SC9.C9_FILIAL = ? AND "
    cQuery += " SC9.C9_PEDIDO = CB9.CB9_PEDIDO AND "
    cQuery += " SC9.C9_PRODUTO = CB9.CB9_PROD AND "
    cQuery += " SC9.C9_LOCAL = CB9.CB9_LOCAL AND "
    cQuery += " SC9.C9_ORDSEP = CB9.CB9_ORDSEP AND "
    cQuery += " SC9.C9_REMITO = ' ' AND "
    cQuery += " SC9.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE CB9.CB9_FILIAL = ? AND "
    cQuery += " CB9.CB9_PROD = ? AND "
    cQuery += " CB9.CB9_LOCAL = ? AND "
    cQuery += " CB9.CB9_LCALIZ = ? AND "
    cQuery += " CB9.CB9_NUMSER = ? AND "
    cQuery += " CB9.D_E_L_E_T_ = ' ' "
    cQuery    := ChangeQuery(cQuery)
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, xFilial("SC9"))
    oStatement:SetString(2, xFilial("CB9"))
    oStatement:SetString(3,CB8->CB8_PROD)
    oStatement:SetString(4,CB8->CB8_LOCAL)
    oStatement:SetString(5,CB8->CB8_LCALIZ)
    oStatement:SetString(6,cNumSerNew)

    cFinalQuery := oStatement:GetFixQuery()
    cAlias1 := MpSysOpenQuery(cFinalQuery)
    If (cAlias1)->(!Eof()) .AND. (cAlias1)->REG > 0
            IF !lApp
                VTAlert('el serial ya lo leiste en otra orden',STR0004,.T.,3000) //### "O numero de serie selecionado pertence a outra ordem de separacao, selecione outro numero de serie"
            EndIf
        lRet := .F.
    EndIf
    (cAlias1)->(dbCloseArea())
EndIf
RestArea( aSvCB9 )
RestArea( aSvSC9 )
RestArea( aSvAlias )
FWFreeArray( aSvCB9 )
FWFreeArray( aSvSC9 )
FWFreeArray( aSvAlias )
FreeObj(oStatement)
Return lRet
