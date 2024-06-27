#include 'Protheus.ch'
#INCLUDE "rwmake.ch"                                 
#INCLUDE "RPTDEF.CH"

/*                                                                       >
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCXPE11  ºAutor  ³Juan Pablo Astorga ºFecha ³  22/08/2022  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Actualiza campos en la SDA al momento grabar Factura      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function  LOCXPE11()
           
Local _aArea	:= GetArea()
Local updateSDA	:= ""
Local updateSE1	:= ""
Local cVlCruz
Local cQuery		
Local cAliasSE2 	:= GetNextAlias()
	
If FunName()$"MATA143"  // Rutina Importación - Despachos
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

If FunName()$"MATA467N"
		SE1->( RecLock("SE1",.F.) )
		SE1->E1_XDESCFI	:= Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XDESCFI")
		SE1->E1_XDIADES	:= Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XDIADES")
		SE1->E1_CCUSTO	:= Posicione("SA1",1,Xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_XCC")
		SE1->E1_VALIMP1 := SF2->F2_VALIMP1
		SE1->E1_VALIMP2 := SF2->F2_VALIMP2
		SE1->E1_XVALBRU := SF2->F2_VALBRUT + SF2->F2_VALIMP2
		SE1->( MsUnLock())   
EndIF

If FunName()$"MATA101N"

	// Query para buscar cuantos anticipos tienen el proveedor + tienda y mostrar como mensaje

	cQuery := " SELECT COUNT(*) TOTAL "
    cQuery += "   FROM " + RetSqlName( "SE2" )
    cQuery += "  WHERE E2_FILIAL='" + xFilial( "SE2" ) + "'"
    cQuery += "    AND E2_FORNECE = '" + SF1->F1_FORNECE + "'"
    cQuery += "    AND E2_LOJA    = '" + SF1->F1_LOJA   + "'"
	cQuery += "    AND E2_TIPO    = 'PA' "
   	cQuery += "    AND E2_SALDO   > 0    "
	cQuery += "    AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.F.,.T. )
    If (cAliasSE2)->TOTAL > 0
       Aviso("A V I S O","EL PROVEEDOR TIENE " +cValToChar((cAliasSE2)->TOTAL)+ " ANTICIPOS CON SALDO ")
    Endif
    (cAliasSE2)->(DbCloseArea()) 

	SE2->( RecLock("SE2",.F.) )
	SE2->E2_XREMBOL := SF1->F1_XREMBOL
	SE2->E2_HIST	:= SF1->F1_XOBS		// Envio Historial Modificado 03022023 Juan Pablo Astorga 
	SE2->( MsUnLock()) 

EndIF

RestArea( _aArea )
Return()
