

#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function M290QSD3()
 Local aArea    := GetArea()
 Local cQueryUsr := ""
//SE ADICIONA FILTRO PARA TENER EN CUENTA SOLO SALIDAS
 cQueryUsr := " AND D3_TM > 499"
 cQueryUsr += " AND D3_ESTORNO <> 'S' "


    RestArea(aArea)
Return cQueryUsr
