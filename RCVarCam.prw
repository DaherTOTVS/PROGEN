#Include "Rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCVarCam    ºAutor  ³EDUAR ANDIA       º Data ³  13/01/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Diferencia en Cambio en Recibos de Caja                    º±±
±±º          ³ Baja de Titulo                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Colombia\Q&C                                      		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCVarCam
Local aArea 	:= GetArea()
Local aAreaSE1  := SE1->(GetArea())
Local nVlDifCb 	:= 0
Local nxVlHoy 	:= 0 

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1")+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))	
	                           
	If ALLTRIM(SEL->EL_TIPODOC) $ "TB" .AND. ALLTRIM(SEL->EL_TIPO) $ "NF|NDC" .AND. SEL->EL_MOEDA=="02" .AND. Alltrim(SEL->EL_SERIE)<>'CMP'
		nxVlHoy := SEL->EL_VLMOED1
		
		/*** Verifica la Última Diferencia en Cálculo ***/
		If SE1->E1_TXMDCOR > 0
			If E1_DTVARIA <> SEL->EL_EMISSAO
				nVUltCor := SEL->EL_VALOR * SE1->E1_TXMDCOR
				nVlDifCb := nxVlHoy - nVUltCor
			Endif
		Else
			//No tiene corrección cambiaria
			//If SE1->E1_TXMOEDA > SEL->EL_TXMOE02
			   //	nVlDifCb :=  (SEL->EL_VALOR * SE1->E1_TXMOEDA)- nxVlHoy
			//Else 
		   		nVlDifCb := nxVlHoy - (SEL->EL_VALOR * SE1->E1_TXMOEDA)
			//EndIf
		Endif
	Endif    	
Endif

RestArea(aAreaSE1)
RestArea(aArea)

Return(nVlDifCb)
