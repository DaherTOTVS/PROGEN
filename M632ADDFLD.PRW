#Include "Totvs.Ch"

/*/{Protheus.doc} M632ADDFLD
ACRESCETA CAMPO NO CABECALHO DA ROTINA MATA632 - PROCEDIMIENTO E OPERACIONES
@type       function
@version    001
@author     Larson Zordan
@since      28/11/2022
@return     variant, String com os campos a serem acrescentados
/*/
User Function M632ADDFLD()
Local cAddFields := "G2_XOBS"  // Juan Pablo Astorga 14.07.2023
Return(cAddFields)             // Juan Pablo Astorga 14.07.2023
//Return("G2_XOBS")
