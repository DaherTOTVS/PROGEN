#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A085TIT   ºAutor  ³ Luiz Otavio Campos ºFecha ³  05/15/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para grabar el centro de costo en los titulos de PA en la º±±
±±º          ³ orden de pago.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A085ATIT()

	Local aArea      := GetArea()
	Local aAreaSEK   := SEK->(GetArea())
	Local aAreaSE2   := SE2->(GetArea())
	Local aPergs     := {}
	Local aObs    	 := {}
	LOCAL _lRet      := .T.
	Local cOrdpago	 := SEK->EK_ORDPAGO
	Local updateSE2	
	Local updateSE5

/***************************************** Informar centro de custo na Generacion del PA  **************************************/
	If SEK->EK_TIPODOC = "PA"
		
		aAdd( aPergs ,{1,"Descripcion",Space(TamSx3("E2_HIST")[1]) ,"@!",,,'.T.',80,.F.})
		aAdd( aPergs ,{1,"Modalidad de Anticipo",Space(TamSx3("E5_NATUREZ")[1]),"@!",'ExistCpo("SED")',"SED",'.T.',80,.F.})
		
		While .T.
			If ParamBox(aPergs ,"Observacion",@aObs,,,,,,,,.f.)
				If !Empty(aObs[1])
					Exit
				EndIf
			EndIf
		EndDo

		DbSelectArea("SEK")
		dbsetorder(1)
		dbseek(xFilial("SEK")+cOrdpago)
		While !EOF() .and. SEK->EK_FILIAL+SEK->EK_ORDPAGO == xFilial("SEK")+cOrdpago
			RecLock( 'SEK', .F. )
			SEK->EK_XOBSERV := aObs[1]
			DbSelectArea("SEK")        
			MsUnLock()
			dbskip()
		EndDo

		// Actualiza Cuentas por pagar Modalidad y Historial
		
		updateSE2 := "UPDATE "+InitSqlName("SE2")+" "
        updateSE2 += " SET E2_HIST='"+SubStr(aObs[1],1,40)+"' , E2_NATUREZ ='"+aObs[2]+"' " 
        updateSE2 += " WHERE E2_FILIAL='"+xFilial("SE2")+"'"
		updateSE2 += " AND E2_TIPO='PA' "
        updateSE2 += " AND E2_NUM='"+cOrdpago+"' "
    //  updateSE2 += " AND D_E_L_E_T_=' ' "
        TcSqlExec(updateSE2)

		// Actualiza Movimientos Bancarios Modalidad

		updateSE5 := "UPDATE "+InitSqlName("SE5")+" "
        updateSE5 += "   SET E5_NATUREZ ='"+aObs[2]+"' " 
        updateSE5 += " WHERE E5_FILIAL='"+xFilial("SE5")+"'"
        updateSE5 += "   AND E5_ORDREC='"+cOrdpago+"' "
		updateSE5 += "   AND E5_NUMERO='"+cOrdpago+"' "
        updateSE5 += "   AND D_E_L_E_T_=' ' "
        TcSqlExec(updateSE5)
	
	EndIf 
	 	
	RestArea(aAreaSEK)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return _lRet
