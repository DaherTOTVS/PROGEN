#INCLUDE "TOTVS.CH" 

/*/{Protheus.doc} MT170QRY
Manipulação do Query

@type        function
@author      Duvan Hernandez
@since       2025.03.06
/*/
User Function MT170QRY()
Local cQuery := ParamIXB[01] as character
Local cWhere := ""

    If FUNNAME() == 'MATA170'
	    cWhere := " AND SB1.B1_XPLANEA >='"  +Mv_Par23+"' AND SB1.B1_XPLANEA <='"  +Mv_Par24+"'  "
    ElseIf FUNNAME() == 'MATR440'
	    cWhere := " AND SB1.B1_XPLANEA >='"  +Mv_Par21+"' AND SB1.B1_XPLANEA <='"  +Mv_Par22+"'  "
    EndIf
    cQuery += cWhere

Return( cQuery  )
