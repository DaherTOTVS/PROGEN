#INCLUDE "Protheus.ch"


/*
  /* 
  ________   _________  __________ ___      ___ ________           ________  ________   ________  ___  ________   ________     
  |\___   ___\\   __  \|\___   ___\\  \    /  /|\   ____\         |\   __  \|\   ___  \|\   ___ \|\  \|\   ___  \|\   __  \    
  \|___ \  \_\ \  \|\  \|___ \  \_\ \  \  /  / | \  \___|_        \ \  \|\  \ \  \\ \  \ \  \_|\ \ \  \ \  \\ \  \ \  \|\  \   
       \ \  \ \ \  \\\  \   \ \  \ \ \  \/  / / \ \_____  \        \ \   __  \ \  \\ \  \ \  \ \\ \ \  \ \  \\ \  \ \   __  \  
        \ \  \ \ \  \\\  \   \ \  \ \ \    / /   \|____|\  \        \ \  \ \  \ \  \\ \  \ \  \_\\ \ \  \ \  \\ \  \ \  \ \  \ 
         \ \__\ \ \_______\   \ \__\ \ \__/ /      ____\_\  \        \ \__\ \__\ \__\\ \__\ \_______\ \__\ \__\\ \__\ \__\ \__\
          \|__|  \|_______|    \|__|  \|__|/      |\_________\        \|__|\|__|\|__| \|__|\|_______|\|__|\|__| \|__|\|__|\|__|
                                                  \|_________|                                                                 
  -----------------------------------------------------------------------------------------------------------------------------    
    				PUNTO DE ENTRADA PARA VALIDAR TES X MODALIDAD EN LA CREACION DE LOS PEDIDOS DE VENTA
                                       AUTORES: JAVIER ROCHA - JUAN DAVID PATIÑO - FELIPE GONZALEZ
                                                      FECHA:   25/05/2023                                                     */


User Function Mt410tok

	Local _aArea 	:= GetArea()
	Local _lRet		:= .T.
	Local nX		:= 1
	Local nOpc      := PARAMIXB[1]
	Local cMotGaratia := Ascan(Aheader,{|x| AllTrim(x[2]) == "C6_XMOTGTA" })
	Local cTRBQry		:=	GetNextAlias()
	Local cQuery        := ""
	Local aDatos        := {}

	If FunName() == "MATA410" .AND. (nOpc == 3 .OR. nOpc == 4) // Ingresa cuando se esta incluyendo el Pedido de Venta MOD. JD
		//Consulta si la modalidad del encabezado del pedido esta en la rutina de Modalidades x TES
		cQuery := " SELECT "
		cQuery += "	ZZD_CODMOD MOD,"
		cQuery += "	ZZD_CODTES TES"
		cQuery += " FROM "
		cQuery +=   RetSqlName("ZZD") + " AS D "
		cQuery += " INNER JOIN " + RetSqlName("ZZC") + " AS C "
		cQuery += " ON D.ZZD_CODMOD = ZZC_CODMOD "
		cQuery += " WHERE "
		cQuery += " C.D_E_L_E_T_ <> '*' "
		cQuery += " AND D.D_E_L_E_T_ <> '*' "
		cQuery += " AND C.ZZC_FILIAL ='"+xFilial("ZZC")+"' "
		cQuery += " AND D.ZZD_FILIAL ='"+xFilial("ZZD")+"' "
		cQuery += " AND C.ZZC_TIPO 	='"+alltrim(M->C5_DOCGER)+"' "
		cQuery += " AND D.ZZD_CODMOD='"+alltrim(M->C5_NATUREZ)+"' "
		DbUseArea(.T.,  "TOPCONN", TcGenQry(,,cQuery ),cTRBQry,.T.,.T.)
		While (cTRBQry)->(!eof())
			aAdd(aDatos,(cTRBQry)->TES) //Se agregan las TES a un arreglo//Mod. Juan David 
			(cTRBQry)->(DbSkip())
		EndDo
		(cTRBQry)->(dbCloseArea())

		IF Len(aDatos)>0 // Ingresa cuando el arreglo viene con datos

			IF Alltrim(M->C5_CLIENTE)$"901019138|901401130|901126410"
				if alltrim(M->C5_NATUREZ)<>'0300118'
					msgstop("Ingresa la MODALIDAD 0300118 - Contrato 16% IVA ")
					_lRet := .F.
				EndIf
			Endif
			If ALLTRIM(M->C5_NATUREZ) == "0300107" .or. ALLTRIM(M->C5_NATUREZ) == "0300114"  // Modalidades GARANTIAS PRODUCTO
				If VAZIO(acols[n][cMotGaratia])
					Alert("Falta el Motivo de Garantia")
					_lRet := .F.
				EndIf
			EndIf
			for nx := 1 to len(acols) // Recorre los Items 
				If !aCols[n,Len(aHeader)+1]
					nPos := aScan(aDatos, acols[nx][gdfieldpos("C6_TES")]  ) //Busca la TES del item en el arreglo y Devuelve valor numerico//MOD.JD
					//Mod. por Juan David 
					If(nPos=0) // Ingresa Si no encuentra la TES en el arreglo
						msgstop( "La TES seleccionada para el #Item: " + ALLTRIM(aCols[nX][gdfieldpos("C6_ITEM")])+" No es valida para la Modalidad")
						_lRet := .F. 
					ENDIF
					//Mod. por Felipe Gonzalez
					//2023-08-28
					//Se quita validacion que estaba predeterminada, se debe realizar relacion por rutina MOdificacion x TES
					/*
					If Alltrim(M->C5_CLIENTE)$"901019138|901401130|901126410" .and. alltrim(M->C5_NATUREZ)=='0300118'
						if gdfieldget("C6_TES",nx)<>'504'
							msgstop("Ingresar la TES 504 en el ITEM : " + ALLTRIM(aCols[nX][gdfieldpos("C6_ITEM")]))
							_lRet := .F.
						EndIf
					EndIF
					*/
				Endif
			next nX
		ELSE // Entra cuando la modalidad del pedido no està relacionada en la Rutina de Modalidades X TES
			msgstop("La MODALIDAD,TES,TIPO(FACTURA/REMISION) Seleccionadas no se encuentra relacionada en la rutina Modalidades X TES,Por favor validar ")
			_lRet := .F.
		EndIf
	ENDIF
	RestArea(_aArea)
Return _lRet
