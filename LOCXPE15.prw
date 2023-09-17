#Include 'Protheus.ch'
#include 'rwmake.ch'

//LocxPE(37)

/*/{Protheus.doc} LocxPE15
description Punto de entrada utilzado para guardar nombre producto en la tabla SD1 
@type function
@version  
@author juan.ricaurte
@since 18/7/2023
@return variant, return_description
/*/
User Function LocxPE15()

	Local cSerie   := SF1->F1_SERIE
	Local cNumero  := SF1->F1_DOC
	Local cProveed := SF1->F1_FORNECE
	Local cLojF1   := SF1->F1_LOJA
	Local cNatSF1  := SF1->F1_NATUREZ
	Local cChaveSE1:= ""
	Local cPrefi   := SF2->F2_SERIE
	Local cDocum   := SF2->F2_DOC
	Local cClien   := SF2->F2_CLIENTE
	Local cLojF2   := SF2->F2_LOJA
	Local cChaveSE2:=""

	If(Funname()=="MATA465N".AND. AllTrim(cEspecie)=="NCC")//nNFTipo == 4 //Nota credito cliente

		cQuery := "UPDATE SD1 SET D1_XDESCRI=B1_DESC "
		cQuery += "FROM "+RetSqlName("SD1")+" SD1 INNER JOIN "+RetSqlName("SB1")+ " 
		cQuery += "SB1 ON (D1_COD=B1_COD) "
		cQuery += "WHERE D1_FORNECE ='"+cProveed+"' AND D1_LOJA ='"+cLojF1+"' "  
		cQuery += "AND D1_DOC ='"+cNumero+"' AND D1_SERIE ='"+cSerie+"' "
		TcSqlExec(cQuery)
		lResult := TCSQLEXEC(cQuery)
        If lResult < 0
            Return MsgStop("Error al guardar la descripcion de los productos " + TCSQLError())
        EndIf
	EndIF
Return ()
