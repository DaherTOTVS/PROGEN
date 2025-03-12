#INCLUDE "TOTVS.CH" 

/*/{Protheus.doc} M760VLDP
Manipulação do Query

@type        function
@author      Duvan Hernandez
@since       2025.03.06
/*/
User Function M760VLDP()
Local cProduto := ParamIXB[1] as character
local lRet     := .F.

    If SB1->B1_XPLANEA >= MV_PAR18 .AND. SB1->B1_XPLANEA <= MV_PAR19
        lRet := .T.
    EndIf



Return( lRet  )
