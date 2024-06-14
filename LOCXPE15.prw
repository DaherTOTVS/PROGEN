#Include 'Protheus.ch'
#include 'rwmake.ch'

//LocxPE(37)

/*/{Protheus.doc} LocxPE15
description Punto de entrada utilzado para guardar nombre producto en la tabla SD1 
@type function
@version  
@author Felipe Gonzalez
@since 19/9/2023
@return variant, return_description
/*/
User Function LocxPE15()

	Local cSerie   := SF1->F1_SERIE
	Local cNumero  := SF1->F1_DOC
	Local cProveed := SF1->F1_FORNECE
	Local cLojF1   := SF1->F1_LOJA

	If(Funname()=="MATA465N".AND. AllTrim(cEspecie)=="NCC")//nNFTipo == 4 //Nota credito cliente

		cQuery := "UPDATE SD1 SET D1_XDESCRI=B1_DESC "
		cQuery += "FROM "+RetSqlName("SD1")+" SD1 INNER JOIN "+RetSqlName("SB1")+ " 
		cQuery += "SB1 ON (D1_COD=B1_COD) "
		cQuery += "WHERE D1_FORNECE ='"+cProveed+"' AND D1_LOJA ='"+cLojF1+"' "  
		cQuery += "AND D1_DOC ='"+cNumero+"' AND D1_SERIE ='"+cSerie+"' "
		cQuery += "AND SB1.D_E_L_E_T_<>'*' "
		cQuery += "AND B1_FILIAL='" + xFilial("SB1") +  "' "
		cQuery += "AND D1_FILIAL='" + xFilial("SD1") +  "' "		
		TcSqlExec(cQuery)
		lResult := TCSQLEXEC(cQuery)
        If lResult < 0
            Return MsgStop("Error al guardar la descripcion de los productos " + TCSQLError())
        EndIf

		IF EMPTY(SF1->F1_SERIE2)

			dbSelectArea("SFP")
			SFP->(dbSetOrder(1))
			SFP->(dbSeek( Xfilial("SFP") + cFilAnt + cSerie )) 

		    DbSelectArea("SX3")
			DbSetOrder(2)	
			If MsSeek("FP_SERIE2")
				SF1->F1_SERIE2=SFP->FP_SERIE2
			else
				SF1->F1_SERIE2=SFP->FP_SERIE
			Endif

			("SX3")->(dbClosearea())
			("SFP")->(DBCloseArea())

			

		EndIF
	EndIF
Return ()
