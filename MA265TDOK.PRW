#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.Doc} MA265TDOK
 si genero una orden de producción el sistema registre el campo C2_LOCAL con la información del campo B1_XALM pero si ese campo es VACIO 
 tome el campo de la bodega default del producto o el B1_LOCPAD. 
@type function
@version 
@author Samuel Avila
@since 29/08/2023
 
/*/
User function MA265TDOK()
	Local aArea := getArea()
	Local cBodega := ""
    Local cProducto := ""
    Local cNumser := ""
    Local cLocaliz := ""
    Local cLote := ""
    Local cNLote := ""
	Local cItem := ""
	Local cEstorno:= ""
	Local cSequen := ""
	Local nSaldo := 0
	Local nQtd:= 0
	Local lRet := .T.
	Local i 
	Local cLogTxt       := ""
	Local cArquivo      := 'C:\TOTVS\'+DTOS(dDataBase)+'_UBICA'+'log.txt'
	Local cPasta        := DTOS(dDataBase)+'_UBICA'+'log.txt'
	Local cDoc
	Local txt 
	Local cDaDoc
	Local aLogAuto := ""
	Local  aItens := {}
	Local cAQuery := ""

	If(Funname()=="MATA265" )
		IF !(M->DA_SERIE $ "NCC|RDV")

			cBodega := M->DA_LOCAL
			cProducto := M->DA_PRODUTO
			cLote := M->DA_LOTECTL
			cNLote := M->DA_NUMLOTE
			nSaldo := M->DA_SALDO
			nQtd	:= M->DA_QTDORI
			cSequen := M->DA_NUMSEQ
			cDaDoc := M->DA_DOC

			For i:=1 To Len(aCols)
				cNumser := aCols[i,6]
				cLocaliz := aCols[i,3]
				cItem := aCols[i,1]
				cEstorno := aCols[i,2]
				
				If ALLTRIM(cEstorno) ==''

				    
                	If ( Ascan( aItens, {|x| x[1] == cNumser} ) ) == 0
						aAdd( aItens, {cNumser})
					else
						aLogAuto := "*************************"+CRLF+;
						"Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en este mismo documento "+CRLF+;
						"*************************"+CRLF
						// MSGALERT( "Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en el documento "+ALLTRIM(SDB->(DB_DOC)), "Entrada duplicada" )
						lRet := .F.
					EndIf
					dbSelectArea( "SD3" )
					SD3 ->(dbSetOrder(2))

					cAQuery := " SELECT DB_FILIAL,DB_DOC,DB_PRODUTO,DB_LOCAL,DB_LOTECTL,DB_NUMLOTE,DB_NUMSERI,DB_LOCALIZ,DB_NUMSEQ FROM  "+RetSQLName('SDB')+"  SDB "
					cAQuery += " WHERE D_E_L_E_T_ <> '*' "
					cAQuery += " AND DB_FILIAL =  '"+xFilial("SDB")+"' "
					cAQuery += " AND DB_PRODUTO =  '"+cProducto+"' "
					cAQuery += " AND DB_NUMSERI =  '"+cNumser+"' "
					cAQuery += " AND DB_TM  <=  '499' "
					cAQuery += " AND TRIM(DB_ESTORNO) =  '' "
					TcQuery cAQuery New Alias "_aQRY"
					dbSelectArea("_aQRY")
					While !_aQRY->(EOF())
					
						cDoc := ALLTRIM(_aQRY->DB_DOC)
						If !(ALLTRIM(_aQRY->DB_NUMSEQ)==ALLTRIM(cSequen) .AND. ALLTRIM(cDoc) == ALLTRIM(cDaDoc))
							txt := "el movimiento interno"
							IF SD3->(DBSEEK(xfilial("SD3")+cDoc+cProducto))
								IF !EMPTY(SD3->(D3_OP))
									txt := "la Orden de Producción"
								EndIF
							EndIF
							aLogAuto := "*************************"+CRLF+;
							"Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en "+txt+" "+cDoc+CRLF+;
							"*************************"+CRLF
							lRet := .F.
						EndIF

						_aQRY->(dbSkip())
					EndDo
					_aQRY->(dbCloseArea())

					If !EMPTY( aLogAuto )
						cLogTxt += aLogAuto + CRLF
						MemoWrite(cArquivo, cLogTxt)
						aLogAuto := ""
					EndIf

					("SD3")->(DBCloseArea())	
				EndIf
			Next i


			IF !Empty(cLogTxt)
				FWAlertError("Hay items con novedades, revisar el LOG.")
				ShellExecute("OPEN", cPasta, "", 'C:\TOTVS\', 1)
			ENDIF
		ENDIF	
	EndIf
	RestArea(aArea)    
RETURN lRet
