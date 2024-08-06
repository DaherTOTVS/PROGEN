#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} MA265TDOK
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
	Local Doc
	Local txt 
	Local cDaDoc
	Local aLogAuto := ""
	Local  aItens := {}

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

				    
                	If ( Ascan( aItens, {|x| x[1]+x[2] == cLocaliz+cNumser} ) ) == 0
						aAdd( aItens, {cLocaliz,cNumser})
					else
						aLogAuto := "*************************"+CRLF+;
						"Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en este mismo documento "+CRLF+;
						"*************************"+CRLF
						// MSGALERT( "Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en el documento "+ALLTRIM(SDB->(DB_DOC)), "Entrada duplicada" )
						lRet := .F.
					EndIf
					dbSelectArea( "SDB" )
					dbSelectArea( "SD3" )
					SDB ->(dbSetOrder(2))
					SD3 ->(dbSetOrder(2))
					SDB->(DbSeek(xfilial("SDB")+cProducto+cBodega+cLote+cNLote+cNumser+cLocaliz))
					While !SDB->(Eof()) .AND. xfilial("SDB")+cProducto+cBodega+cLote+cNLote+cNumser+cLocaliz ==;
											SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ)
						IF SDB->(DB_TM) <='499'					
							Doc := ALLTRIM(SDB->(DB_DOC))
							If	ALLTRIM(SDB->(DB_ESTORNO)) ==''
								If !(ALLTRIM(SDB->(DB_NUMSEQ))==ALLTRIM(cSequen) .AND. ALLTRIM(Doc) == ALLTRIM(cDaDoc))
									txt := "el movimiento interno"
									IF SD3->(DBSEEK(xfilial("SD3")+Doc+cProducto))
										IF !EMPTY(SD3->(D3_OP))
											txt := "la Orden de Producción"
										EndIF
									EndIF
									aLogAuto := "*************************"+CRLF+;
									"Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en "+txt+" "+Doc+CRLF+;
									"*************************"+CRLF
									// MSGALERT( "Item "+ALLTRIM(cItem)+" - Numero de serie "+ALLTRIM(cNumser)+" no permitido, tuvo entrada en el documento "+ALLTRIM(SDB->(DB_DOC)), "Entrada duplicada" )
									lRet := .F.
								EndIF
							EndIF
						EndIf
						SDB->(dbSkip())
					EndDo
					If !EMPTY( aLogAuto )
						cLogTxt += aLogAuto + CRLF
						MemoWrite(cArquivo, cLogTxt)
						aLogAuto := ""
					EndIf

					("SDB")->(DBCloseArea())
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
