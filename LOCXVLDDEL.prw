#Include "Protheus.Ch"
#INCLUDE "rwmake.ch"
#Include "TopConn.Ch"

/*
+-----------------------------------------------------------------------------------------+
+----------+----------+-------+--------------------+------+-------------------------------+
|Programa  |LOCXVLDDEL  |Autor  |M&H        | Data | 19/01/2023		                      |
+----------+----------+-------+--------------------+------+-------------------------------+
+-----------------------------------------------------------------------------------------+
|Funcion que filtra todos los items que fueran 								              |
|Limita el borrado de las NCC / NF 		                                  				  |
+-----------------------------------------------------------------------------------------+
*/
/*****************************************************************************************/
/*****************************************************************************************/
User Function LOCXVLDDEL()
Local _lret		:= .T.
//LOCAL _aTitulos	:= array(0)
Local _cAlias	:= paramixb[1]
Local _aArea	:= GetARea()
Local cUsersAdm :=  GetMV("MV_USRADM",,"")

If __cUserID $ cUsersAdm
_lRet := .T.
ELSEIF (Funname() $ "MATA465N|MATA467N|MATA462N|MATA462DN") .AND.  __nOpcx == 5  //NCC|FACTURA VENTA|REMITO VENTA|REMITO DEVOLUCION VENTA
 		MsgAlert("Este tipo de documento no puede ser Borrado, Contacte al Admin")
		_lRet := .F.
EndIF
RestaREa(_aarea)

Return(_lRet)
