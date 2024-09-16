#include "protheus.ch"
#include "rwmake.ch"


User Function LocxPE35 

Local aArea			:= GetArea()

Local i			:= 1
Local aAreaSD1 		:= SD1->(GetArea())
Local nPosDescri        := AScan(aHeader, {|x| Alltrim(x[2]) == "D1_XDESCRI" }) 



If FunName()$"MATA101N|MATA102N" //FACTURA ENTRADA - REMITO DE ENTRADA
	For i := 1 to Len(aCols)
		IF (acols[i][nPosRemi])==SD1->D1_DOC.AND.(acols[i][nPosItRe])==SD1->D1_ITEM     

            aCols[i][nPosDescri] 	:= SD1->D1_XDESCRI  // Modificado 16/02/2023 Juan Pablo Astorga
            EndIf
	Next i
EndIf

RestArea(aAreaSD1)	
RestArea(aArea)
Return(.T.)
