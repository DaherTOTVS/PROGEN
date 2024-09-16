

#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function M290QSD1()
 Local aArea    := GetArea()
 Local cQueryUsr := ""
//SE ADICIONA FILTRO PARA TENER EN CUENTA SOLO SALIDAS
 cQueryUsr := " AND D1_TES > 499"


    RestArea(aArea)
Return cQueryUsr
