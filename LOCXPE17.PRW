#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*-----------------------------------------------------------------!
!          FUNCION PARA VALIDAR QUE LAS NCC NO SE VAYAN            !
!                         SIN MODALIDAD                            !
!                         JAVIER ROCHA                             !
!                         MOD 22/02/2024                           !
-------------------------------------------------------------------*/

User Function LocxPE17()
	Local aArea    	:= GetArea()
	Local aAreaSF2 	:= SF2->(GetArea())
	Local aAreaSF1 	:= SF1->(GetArea())
	Local aAreaSD2 	:= SD2->(GetArea())
	Local aAreaSD1 	:= SD1->(GetArea())
	Local _lRet   := .T.
	Local cQuery  := ""
	Local cTRBQry := GetNextAlias()
	Local cModa	  := M->F1_NATUREZ
	Local cNat    := ""
	Local cMoeda  := M->F1_MOEDA 
	Local cTxMoeda  := M->F1_TXMOEDA 
	

	If (Funname()== "MATA465N".AND. "NCC"$cEspecie  )
		If M->F1_MOEDA != 2
			M->F1_MOEDA := POSICIONE("SF2",2,xFilial("SF2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_NFORI+SD1->D1_SERIORI+"N"+"RFN","F2_MOEDA")
			U_SyEnterCpo("F1_MOEDA",M->F1_MOEDA, n)
			SysRefresh()
			If  M->F1_TXMOEDA <= 1
				M->F1_TXMOEDA := POSICIONE("SF2",2,xFilial("SF2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_NFORI+SD1->D1_SERIORI+"N"+"RFN","F2_TXMOEDA")
				U_SyEnterCpo("F1_TXMOEDA",M->F1_TXMOEDA, n)
				SysRefresh()
			EndIF
		EndIF
	EndIF
	
	If(Funname()=="MATA465N".AND. AllTrim(cEspecie)=="NCC")
		if AllTrim(SD1->D1_SERIORI)$'R'
			//Consulta Naturaleza cuando viene de Remito
			cQuery := " SELECT "
			cQuery += " F2_NATUREZ NAT, F2_MOEDA MOEDA, F2_TXMOEDA TXMOEDA "
			cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
			cQuery += " WHERE " 
			cQuery += " F2_FILIAL = '" +XFILIAL("SF2")+"' "
			cQuery += " AND F2_CLIENTE = '" +Alltrim(SD1->D1_FORNECE)+"' "
			cQuery += " AND F2_LOJA = '" +  Alltrim(SD1->D1_LOJA) + "' "
			cQuery += " AND F2_DOC = " + Alltrim(SD1->D1_NFORI)
			cQuery += " AND F2_SERIE = '" + SD1->D1_SERIORI +"' "
			cQuery += " AND F2_ESPECIE = 'RFN' "
			cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
			DbUseArea(.T.,  "TOPCONN", TcGenQry(,,cQuery ),cTRBQry,.T.,.T.)
			While (cTRBQry)->(!eof())
				cNat := (cTRBQry)->NAT
				cMoeda := (cTRBQry)->MOEDA
				cTxMoeda := (cTRBQry)->TXMOEDA
				(cTRBQry)->(DbSkip())
			EndDo
			If M->F1_TXMOEDA != cTxMoeda
				M->F1_TXMOEDA := cTxMoeda
			EndIf
			If M->F1_MOEDA != cMoeda
				M->F1_MOEDA  := cMoeda
				U_SyEnterCpo("F1_MOEDA",M->F1_MOEDA, n)
			EndIF
			(cTRBQry)->(dbCloseArea())
		elseif ALLTRIM(SD2->D2_ESPECIE)=='NF'
			//Consulta Naturaleza cuando viene de FVE
			cQuery := " SELECT "
			cQuery += " F2_NATUREZ NAT "
			cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
			cQuery += " WHERE "
			cQuery += " F2_FILIAL = '" +XFILIAL("SF2")+"' "
			cQuery += " AND F2_CLIENTE = '" +Alltrim(SD2->D2_CLIENTE)+"' "
			cQuery += " AND F2_LOJA = '" +  Alltrim(SD2->D2_LOJA) + "' "
			cQuery += " AND F2_DOC = '" + Alltrim(SD2->D2_DOC) + "' "
			cQuery += " AND F2_SERIE = '" + SD2->D2_SERIE +"' "
			cQuery += " AND F2_ESPECIE = 'NF' "
			cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
			DbUseArea(.T.,  "TOPCONN", TcGenQry(,,cQuery ),cTRBQry,.T.,.T.)
			While (cTRBQry)->(!eof())
				cNat := (cTRBQry)->NAT
				(cTRBQry)->(DbSkip())
			EndDo
			(cTRBQry)->(dbCloseArea())
		ENDIF
		
		IF !EMPTY(cNat)
			//Descripcion: Se quita mensaje de validación de usuario y se asigna misma modalidad del documento origen
			//Autor: Duvan Hernandez
			//Fecha: 27/06/2024
			M->F1_NATUREZ := cNat
			M->F1_TXMOEDA := IIF(M->F1_MOEDA <> 1,xMoeda(1,M->F1_MOEDA,1,M->F1_EMISSAO,4),1)
			                                                                                                                                         

			_lRet := .T.
			Return _lRet
		else	
			While EMPTY(cModa) 
				msgstop("Modalidad Vacia!!!, por favor seleccionar una.")
				_lRet := .F.
				Return _lRet
			EndDo
		ENDIF
	ELSEIf(FUNNAME() $ "MATA462DN" .AND."RFD"$cEspecie)
		
		//Descripcion: Se forza la recepción del valor en el campo
		//Autor: Duvan Hernandez
		//Fecha: 27/06/2024
		cQuery := " SELECT "
		cQuery += " F2_NATUREZ NAT, F2_MOEDA MOEDA "
		cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " WHERE "
		cQuery += " F2_FILIAL = '" +XFILIAL("SF2")+"' "
		cQuery += " AND F2_CLIENTE = '" +Alltrim(SD2->D2_CLIENTE)+"' "
		cQuery += " AND F2_LOJA = '" +  Alltrim(SD2->D2_LOJA) + "' "
		cQuery += " AND F2_DOC = '" + Alltrim(SD2->D2_DOC) + "' "
		cQuery += " AND F2_SERIE = '" + SD2->D2_SERIE +"' "
		cQuery += " AND F2_ESPECIE = 'RFN' "
		cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
		DbUseArea(.T.,  "TOPCONN", TcGenQry(,,cQuery ),cTRBQry,.T.,.T.)
		While (cTRBQry)->(!eof())
			cNat := (cTRBQry)->NAT
			(cTRBQry)->(DbSkip())
		EndDo
		(cTRBQry)->(dbCloseArea())

		IF !EMPTY(cNat)
			//Autor: Duvan Hernandez
			//Fecha: 27/06/2024
			M->F1_NATUREZ := cNat                                                                                                                                      

			_lRet := .T.
			Return _lRet
		else	
			While EMPTY(cModa) 
				msgstop("Modalidad Vacia!!!, por favor seleccionar una.")
				_lRet := .F.
				Return _lRet
			EndDo
		ENDIF

	ENDIF

	RestArea(aAreaSD2)
	RestArea(aAreaSD1)
	RestArea(aAreaSF2)
	RestArea(aAreaSF1)
	RestArea(aArea)
Return (_lRet)
