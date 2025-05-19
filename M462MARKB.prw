#INCLUDE "PROTHEUS.CH"

User Function M462MARKB()
// Local aArea := GetArea()
// Local aAreaCB7  := CB7->(GetArea())
Local lRet  := .T.
// Local lValid1 := IIF(C9_ORDSEP==NIL,SC9->C9_ORDSEP,C9_ORDSEP)
	
// 	If !Empty(lValid1)
// 		cStatus := POSICIONE("CB7",1,XFILIAL("CB7")+C9_ORDSEP,"CB7_STATUS")     

// 		If Alltrim(cStatus) $ "2|4|9"
// 			lRet := .T.
// 		Else
// 			MsgAlert("El Pedido "+' '+C9_PEDIDO+' '+" tiene Orden de separación "+' '+C9_ORDSEP+' '+" no finalizada.")
// 		EndIf
// 	Else
// 		lRet := .T.
// 	EndIf
	

// RestArea(aAreaCB7)
// RestArea(aArea)

Return lRet
