#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

User Function SE2DOC()
Local NumDoc    := ""  
Local cQuery    := ""
Local aArea 	:= GetArea()

If Alltrim(M->E2_PREFIXO)$"CPR|FLI|RCM|FLT|GPR|LGA" .and. Alltrim(FunName())=="FINA050"

    cQuery := " SELECT TOP 1 E2_PREFIXO , E2_NUM ,R_E_C_N_O_ "  +CRLF
	cQuery += " FROM " + RetSqlName("SE2") + " "                +CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND "                    +CRLF
	cQuery += " E2_PREFIXO  = '" + M->E2_PREFIXO + "' "         +CRLF
    cQuery += " AND LEN(E2_NUM) = 7   "  +CRLF
    cQuery += " ORDER BY E2_NUM DESC  "
	TcQuery cQuery New Alias "TRB3"
    dbSelectArea("TRB3")
	If !TRB3->(EoF())
	    NumDoc:= StrZero(Val(TRB3->E2_NUM)+1,7)
    else
	    NumDoc:= "0000001"
    EndIF

    TRB3->(DbCloseArea())

EndIF

    RestArea(aArea)

Return NumDoc
