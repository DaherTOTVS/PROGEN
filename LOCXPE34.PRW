#include 'Protheus.ch'
#INCLUDE "rwmake.ch"                                 
#INCLUDE "RPTDEF.CH"

User Function  LOCXPE34()
           
Local _aArea	:= GetArea()
Local cFiltro 	:= ""

	
If FunName()$"MATA101N"  // Rutina Importación - Despachos
	 if Alltrim(DBA->DBA_HAWB)<>''  
		updateSDA := "UPDATE "+InitSqlName("SDA")+" "
		updateSDA += "   SET DA_XFAT_DE= '"  + DBA->DBA_FAT_DE + "'"
        updateSDA += " WHERE DA_FILIAL= '"  + xFilial("SDA")+"'"
		updateSDA += "   AND DA_CLIFOR= '" + SF1->F1_FORNECE + "'"
    	updateSDA += "   AND DA_LOJA	= '" + SF1->F1_LOJA + "'"
	    updateSDA += "   AND DA_SERIE = '" + SF1->F1_SERIE + "'"
	    updateSDA += "   AND DA_DOC	= '" + SF1->F1_DOC + "'"	   
	    updateSDA += "   AND D_E_L_E_T_=' ' "
	    TcSqlExec(updateSDA)  		    
	EndIf
EndIF

RestArea( _aArea )

Return(cFiltro)
