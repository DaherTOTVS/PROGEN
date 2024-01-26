#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLocxpe16     บAutor  ณJuan Pablo Astorga  บFecha ณ31/08/2022บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacion en el ok de la Locxnf                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROGEN - Validaciones Varias                               บฑฑ  
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function Locxpe16
Local _lRet	    	:= .T.
Local nPosPedD1		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})  	// Pedido de Compra
Local nPosLote  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOTECTL"})
Local nPosLoteF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DTVALID"})
Local nPosCod   	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
Local nPosQuant 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
Local nPosPed		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})
Local nPosImPed 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})
Local nPosForne 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_FORNECE"})
Local nPosLoja 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOJA"})
Local nPosRemito 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_REMITO"})
Local nPosSerirem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIREM"})
Local nPosDoc 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DOC"})
Local nPosSerie 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIE"})
Local nPosSeriF 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIORI"})
Local nPosDocF	 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})

Local cPedQuant := ""
Local _aArea	:= GetArea()
Local nx      
Local cModalidad:="" 
             
If Funname()== "MATA102N"
	for nx := 1 to len(acols)
		If !aCols[nX,Len(aHeader)+1]
		 	If Empty(gdfieldget("D1_PEDIDO",nx))    
				MsgAlert("Necesario que la Guia este relacionado a un pedido de compra ITEM : " + gdfieldget("D1_ITEM",nx)  , "Guia vs Pedido")
				_lRet:=.F.                                                           
			EndIf
			If Empty(gdfieldget("D1_XUNIDAD",nx))    
				MsgAlert("Necesario ingresar unidad de compra ITEM : " + gdfieldget("D1_ITEM",nx)  , "Unidad Compra")
				_lRet:=.F.                                                           
			EndIf
			If POSICIONE("SB1",1,xFilial("SB1")+Acols[nx][nPosCod],"B1_RASTRO")$"S|L"
				If Empty(gdfieldget("D1_LOTECTL",nx))
					MsgAlert("Necesario Ingresar un LOTE : Item " + gdfieldget("D1_ITEM",nx)  , "LOTE")
					_lRet:=.F.                                                           
				EndIf
				If Empty(gdfieldget("D1_DTVALID",nx))
					MsgAlert("Necesario Ingresar una Fecha LOTE : Item " + gdfieldget("D1_ITEM",nx)  , "Fecha LOTE")
					_lRet:=.F.                                                           
				EndIf
			EndIf

			cPedQuant := Posicione("SC7",1,xFilial("SC7")+Acols[nx][nPosPed]+Acols[nx][nPosImPed],"C7_QUANT")
			If !Empty(cPedQuant)
				If	cPedQuant <> Acols[nx][nPosQuant]
					If !MsgYesno("las cantidades son distintas entre pedido : " +CVALTOCHAR(cPedQuant) + " vs guia : " + CVALTOCHAR(Acols[nx][nPosQuant]) + " Item -> :" + gdfieldget("D1_ITEM",nx),"Desea Continuar?")
						_lRet	:= .F.
					EndIf	
				EndIf
			EndIf	
		EndIF
	next 	
EndIf

//Descripcion: No permite guardar NC con remitos o facturas de diferente modalidad
//Autor: Felipe Gonzalez
//Fecha: 25/09/2023

If(Funname()=="MATA465N".AND. AllTrim(cEspecie)=="NCC")

	for nx := 1 to len(acols)
		If !aCols[n,Len(aHeader)+1]
			IF M->F1_TIPOPE == "20"
		
				//IF	acols[nx][45]=="RDV"
				IF	acols[nx][nPosSerirem]=="RDV"
					c1Query := "SELECT F1_NATUREZ "
					c1Query += "FROM "+RetSqlName("SF1")+ " 
					c1Query += "WHERE F1_FORNECE ='"+acols[nx][nPosForne]+"' AND F1_LOJA ='"+acols[nx][nPosLoja]+"' "  
					c1Query += "AND F1_DOC ='"+acols[nx][nPosRemito]+"' AND F1_SERIE ='"+acols[nx][nPosSerirem]+"' "
					c1Query += "AND D_E_L_E_T_<>'*' "
					c1Query += "AND F1_FILIAL='" + xFilial("SF1") +  "' "
      				TcQuery c1Query New Alias "QrySF1"
	   				dbSelectArea("QrySF1")
	
						While !QrySF1->(EOF())
	
        				IF empty(cModalidad)
        				    cModalidad := QrySF1->F1_NATUREZ
        				ELSE
        				    IF (cModalidad<> QrySF1->F1_NATUREZ)
        				       cModalidad := ""
        				       msgstop("No es permitido realizar NC de dos o mas Remitos con diferente modalidad")
        				       QrySF1->(dbCloseArea())
        				       _lRet := .F.
							   Return _lRet
        				    EndIf
        				Endif
        				QrySF1->(dbSkip())
						EndDo
					QrySF1->(dbCloseArea())
				Else

					c2Query := "SELECT F2_NATUREZ "
					c2Query += "FROM "+RetSqlName("SF2")+ " 
					c2Query += "WHERE F2_CLIENTE ='"+acols[nx][nPosForne]+"' AND F2_LOJA ='"+acols[nx][nPosLoja]+"' "  
					c2Query += "AND F2_DOC ='"+acols[nx][nPosDocF]+"' AND F2_SERIE ='"+acols[nx][nPosSeriF]+"' "
					c2Query += "AND D_E_L_E_T_<>'*' "
					c2Query += "AND F2_FILIAL='" + xFilial("SF2") +  "' "
      				TcQuery c2Query New Alias "QrySF2"
	   				dbSelectArea("QrySF2")
	
						While !QrySF2->(EOF())
	
        				IF empty(cModalidad)
        				    cModalidad := QrySF2->F2_NATUREZ
        				ELSE
        				    IF (cModalidad<> QrySF2->F2_NATUREZ)
        				       cModalidad := ""
        				       msgstop("No es permitido realizar NC de dos o mas facturas con diferente modalidad")
        				       QrySF2->(dbCloseArea())
        				       _lRet := .F.
							   Return _lRet
        				    EndIf
        				Endif
        				QrySF2->(dbSkip())
						EndDo
					QrySF2->(dbCloseArea())
				ENDIF
			Else
			_lRet	:= .T.
			Endif
		Endif			
	next
EndIF

//Descripcion: No permite guardar devolucion de remitos con remisiones de diferente modalidad
//Autor: Felipe Gonzalez
//Fecha: 25/09/2023
If FUNNAME() $ "MATA462DN" .AND."RFD"$cEspecie
	for nx := 1 to len(acols)
		If !aCols[n,Len(aHeader)+1]

			c3Query := "SELECT F2_NATUREZ "
			c3Query += "FROM "+RetSqlName("SF2")+ " 
			c3Query += "WHERE F2_CLIENTE ='"+acols[nx][nPosForne]+"' AND F2_LOJA ='"+acols[nx][nPosLoja]+"' "  
			c3Query += "AND F2_DOC ='"+acols[nx][nPosDocF]+"' AND F2_SERIE ='"+acols[nx][nPosSeriF]+"' "
			c3Query += "AND D_E_L_E_T_<>'*' "
			c3Query += "AND F2_FILIAL='" + xFilial("SF2") +  "' "
      		TcQuery c3Query New Alias "QySF2"
	   		dbSelectArea("QySF2")
				While !QySF2->(EOF())
        		IF empty(cModalidad)
        		    cModalidad := QySF2->F2_NATUREZ
        		ELSE
        		    IF (cModalidad<> QySF2->F2_NATUREZ)
        		       cModalidad := ""
        		       msgstop("No es permitido realizar remito de devolucion de dos o mas remitos con diferente modalidad")
					   QySF2->(dbCloseArea())
        		       _lRet := .F.
					   Return _lRet
        		    EndIf
        		Endif
        		QySF2->(dbSkip())
				EndDo
			QySF2->(dbCloseArea())
		Endif
	next	
Endif

Return _lRet
