#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------!
!Punto de entrada para filtar pedidos de venta que manejan montaje de carga!
!                        	Felipe Gonzalez                    		       !
!                          	   23/04/2025                         		   !
--------------------------------------------------------------------------*/
User Function M462NFLT()
Local cQuery := " "

	IF	FUNNAME() == "MATA462AN"
			cQuery += " C9_LOCAL BETWEEN '"+mv_par15+"' AND '"+mv_par16+"' "+CRLF
			cQuery += " AND ((C9_ORDSEP = ' ' AND TRIM('"+mv_par17+"')='')  OR (C9_ORDSEP BETWEEN '"+mv_par17+"' AND '"+mv_par18+"' "+CRLF
			cQuery += " AND EXISTS ( " +CRLF
            cQuery += " SELECT 1 FROM "+	RetSqlName("CB7") + " CB7 "+CRLF
            cQuery += " WHERE CB7.CB7_ORDSEP = SC9.C9_ORDSEP "+CRLF
            cQuery += " AND CB7.CB7_STATUS IN ('2','4','9')  )))"+CRLF
       

	EndIF	

Return cQuery
