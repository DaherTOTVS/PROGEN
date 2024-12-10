#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#include 'fivewin.ch'

User Function CALDEPOS()
Local nSeqSD7   := SD7->D7_NUMSEQ
Local nSeqCal   := SD7->D7_NUMERO
Local cQuery 	:= ""		  
Local aArea 	:= GetArea()

cQuery := " SELECT D1_XLOCAL , D1_COD " +CRLF
cQuery += " FROM " + RetSqlName("SD1") + " " +CRLF
cQuery += " WHERE D_E_L_E_T_ = ' ' AND " +CRLF
cQuery += " D1_FILIAL = '" + xFilial("SD1") + "' AND " +CRLF
cQuery += " D1_NUMSEQ = '" + nSeqSD7 + "' AND " +CRLF
cQuery += " D1_NUMCQ = '" + nSeqCal + "' 
TcQuery cQuery New Alias "TRB3"
dbSelectArea("TRB3")
If !TRB3->(EoF())
    // cDeposito :=  Posicione("SB1",1,xFilial("SB1")+SD7->D7_PRODUTO,"B1_LOCPAD")   	// Modificado 03.05.2024 //TRB3->D1_XLOCAL
    cDeposito :=  TRB3->D1_XLOCAL   	// Modificado 05.12.2024 //TRB3->D1_XLOCAL
else
    cDeposito :=  Posicione("SB1",1,xFilial("SB1")+SD7->D7_PRODUTO,"B1_LOCPAD")   	
EndIf 
TRB3->(DbCloseArea())
RestArea(aArea)
Return cDeposito
