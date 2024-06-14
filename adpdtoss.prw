
/*/{Protheus.doc} adpDTOSS
Recibe una Fecha y devuelve "YYYY-MM-DD"
@type function
@version 
@author AxelDiaz
@since 22/11/2020
@param dFecha, date, param_description
@return return_type, return_description
/*/
User Function adpDTOSS(dFecha)
Local cFecha:=DTOS(dFecha)
Return cfecha:=LEFT(cFecha,4)+"-"+SUBSTR(cFecha,5,2)+"-"+RIGHT(cFecha,2)
