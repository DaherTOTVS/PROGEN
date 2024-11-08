#include "protheus.ch"
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOCXPE35  �Autor  �Juan Pablo Astorga  � Data �  22/08/2022 ���
�������������������������������������������������������������������������͹��
���Desc.     � PE para mostrar la Unidad de Compra en el momento          ���
���          � de jalar el remito de entrada                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LocxPE35() 

Local aArea			:= GetArea()
Local nPosUn		:= Ascan(aHeader, {|x| AllTrim(x[2]) == "D1_XUNIDAD" } )
Local nPosPrec2 	      := aScan(aHeader,{ |x| AllTrim(x[2]) == 'D1_XPRECO2'})
Local nPosOP	 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'D1_OP'})
Local nPosCC	 	:= aScan(aHeader,{ |x| AllTrim(x[2]) == 'D1_CC'})
Local i			:= 1
Local lRet     		:= .T.    
Local aAreaSD1 		:= SD1->(GetArea())
Local nPosCod  		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_COD"       })  
Local nPosPrv  		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_FORNECE"   }) 
Local nPosLj   		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_LOJA"      })
Local nPosDoc  		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_DOC"       })  
Local nPosNfor 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_NFORI"     })
Local nPosSeor 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_SERIORI"   })
Local nPosItor 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEMORI"   })
Local nPosRemi 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_REMITO"    })
Local nPosSerr 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_SERIREM"   })
Local nPosItem 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEM"      })
Local nPosItRe 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_ITEMREM"   }) 
Local nPosItVund 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_VUNIT"   }) 
Local nPosItTot 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_TOTAL"   }) 
Local nPosItDesc 		:= AScan(aHeader, {|x| Alltrim(x[2]) == "D1_VALDESC" }) 
Local nPosDescri        := AScan(aHeader, {|x| Alltrim(x[2]) == "D1_XDESCRI" }) 
Local nPosxCodcw        := AScan(aHeader, {|x| Alltrim(x[2]) == "D1_XCODCW" }) 

Local cQuery   		:= ""
Local _cAlias  		:= GetNextAlias()
Local _cAliFC  		:= GetNextAlias()
Local cNumDocCli  	:= ""  
Local cQueryFC    	:= "" 
Local nX          	:= 0
Local nMoeda            := 1
Local nTxMoeda          := 1
Local cSF2Naturez    	:= ""  // 05-MAY-2023 PARA TRAER LA NATURALEZ DESDE LA FACTURA DE VENTAS
Local cSF2Vendedor      := ""  // 25-MAY-2023 PARA TRAR EL VENDEDOR DESDE LA FACTURA DE VENTAS 


If FunName()$"MATA101N|MATA102N" //FACTURA ENTRADA - REMITO DE ENTRADA
	For i := 1 to Len(aCols)
		IF (acols[i][nPosRemi])==SD1->D1_DOC.AND.(acols[i][nPosItRe])==SD1->D1_ITEM     
			aCols[i][nPosUn] 	      := SD1->D1_XUNIDAD
			aCols[i][nPosPrec2]     := SD1->D1_XPRECO2
			aCols[i][nPosOP] 	      := SD1->D1_OP
			aCols[i][nPosCC] 	      := SD1->D1_CC
                  aCols[i][nPosDescri] 	:= SD1->D1_XDESCRI  // Modificado 16/02/2023 Juan Pablo Astorga
                  aCols[i][nPosxCodcw]    := SD1->D1_XCODCW   // Modificado 21/03/2023 Juan Pablo Astorga 
		EndIF
	Next i
EndIf

If (FunName()=="MATA465N")  // GENERACION DE NOTAS CREDITO Y DEBITO CLIENTE

      If aCFGNF[1] == 04  

            nMoeda  := __LOCXSF1->(F1_MOEDA)  //MONEDA
            M->F1_MOEDA := nMoeda
            nTxMoeda  := __LOCXSF1->(F1_TXMOEDA)  //TRM
            M->F1_TXMOEDA := nTxMoeda
      
            
            nX:= Len(aCols)

            cQuery:= " SELECT D1_VUNIT,D1_TOTAL,D1_VALDESC FROM " + RetSqlName("SD1") 
            cQuery+= " WHERE D_E_L_E_T_ <> '*' "
            cQuery+= " AND D1_DOC = '" + aCols[nX][nPosRemi] + "'"
            cQuery+= " AND D1_SERIE = '" + aCols[nX][nPosSerr] + "'"
            cQuery+= " AND D1_ITEM = '" + aCols[nX][nPosItRe] + "'"
            cQuery+= " AND D1_COD = '" + aCols[nX][nPosCod] + "'"
            cQuery+= " AND D1_FORNECE = '" + aCols[nX][nPosPrv] + "'"
            cQuery+= " AND D1_LOJA = '" + aCols[nX][nPosLj] + "'"
            
            cQuery := ChangeQuery(cQuery)
            dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), _cAlias, .F., .T.)   
            
            If !(_cAlias)->(EOF())           
                  aCols[nX][nPosItVund]     := (_cAlias)->D1_VUNIT
                  aCols[nX][nPosItTot]       := (_cAlias)->D1_TOTAL
                  aCols[nX][nPosItDesc]     := (_cAlias)->D1_VALDESC
                  
            Endif 
            (_cAlias)->(dbCloseArea())
            

            //Se llama la informacion del remito de dev -> remito de salida y facturacion.
            
            /*      cQueryFC:= " SELECT D2_DOC, D2_SERIE, D2_CCUSTO, F2_NATUREZ, F2_MOEDA FROM " + RetSqlName("SD2")  + " SD2 "
                        cQueryFC+= " WHERE D2_ESPECIE ='NF' AND SD2.D_E_L_E_T_='' "
                        cQueryFC+= " AND D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM  IN ( "
                        cQueryFC+= " SELECT D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIE+D2_DOC+D2_ITEM "
                        cQueryFC+= " FROM " + RetSqlName("SD2")  + " SD2RE  WHERE D2_ESPECIE = 'RFN' AND SD2RE.D_E_L_E_T_ ='' "
                        cQueryFC+= " AND    D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD    IN ( "
                        cQueryFC+= " SELECT D1_FILIAL + D1_NFORI + D1_SERIORI +D1_FORNECE +D1_LOJA  +D1_COD  "
                        cQueryFC+= " FROM " + RetSqlName("SD1")  + " SD1 WHERE SD1.D_E_L_E_T_ =''  "
                        cQueryFC+= " AND D1_DOC = '" + aCols[nX][nPosRemi] + "'"
                        cQueryFC+= " AND D1_SERIE = '" + aCols[nX][nPosSerr] + "'"
                        cQueryFC+= " AND D1_ITEM = '" + aCols[nX][nPosItRe] + "'"
                        cQueryFC+= " AND D1_COD = '" + aCols[nX][nPosCod] + "'"
                        cQueryFC+= " AND D1_LOJA = '" + aCols[nX][nPosLj] + "' "
                        cQueryFC+= " AND D1_FORNECE = '" + aCols[nX][nPosPrv] + "'))"

            */

                  cQueryFC:= " SELECT D2_DOC, D2_SERIE, D2_CCUSTO, F2_NATUREZ, F2_MOEDA, F2_VEND1 FROM " + RetSqlName("SD2")  + " SD2 "
                  cQueryFC+= " INNER JOIN SF2010 AS SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND SD2.D2_ESPECIE = SF2.F2_ESPECIE AND SF2.D_E_L_E_T_ <> '*' " 
                  cQueryFC+= " WHERE D2_ESPECIE ='NF' AND SD2.D_E_L_E_T_=''  "
                  cQueryFC+= " AND D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM  IN ( "
                  cQueryFC+= " SELECT D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIE+D2_DOC+D2_ITEM "
                  cQueryFC+= " FROM " + RetSqlName("SD2")  + " SD2RE  WHERE D2_ESPECIE = 'RFN' AND SD2RE.D_E_L_E_T_ ='' "
                  cQueryFC+= " AND    D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD    IN ( "
                  cQueryFC+= " SELECT D1_FILIAL + D1_NFORI + D1_SERIORI +D1_FORNECE +D1_LOJA  +D1_COD  "
                  cQueryFC+= " FROM " + RetSqlName("SD1")  + " SD1 WHERE SD1.D_E_L_E_T_ =''  "
                  cQueryFC+= " AND D1_DOC = '" + aCols[nX][nPosRemi] + "'"
                  cQueryFC+= " AND D1_SERIE = '" + aCols[nX][nPosSerr] + "'"
                  cQueryFC+= " AND D1_ITEM = '" + aCols[nX][nPosItRe] + "'"
                  cQueryFC+= " AND D1_COD = '" + aCols[nX][nPosCod] + "'"
                  cQueryFC+= " AND D1_LOJA = '" + aCols[nX][nPosLj] + "' "
                  cQueryFC+= " AND D1_FORNECE = '" + aCols[nX][nPosPrv] + "'))"

                  cQueryFC := ChangeQuery(cQueryFC)
            dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQueryFC), _cAliFC, .F., .T.)   
            
            If !(_cAliFC)->(EOF())           
                  aCols[nX][nPosNfor]     := (_cAliFC)->D2_DOC                                      
                  aCols[nX][nPosSeor]     := (_cAliFC)->D2_SERIE
			aCols[nX][nPosCC]		:= (_cAliFC)->D2_CCUSTO
			cSF2Naturez             := (_cAliFC)->F2_NATUREZ  // 05-MAY-2023 PARA TRAER LA NATURALEZ DESDE LA FACTURA DE VENTAS
                  nSF2Moeda               := (_cAliFC)->F2_MOEDA    // 05-MAY-2023 PARA TRAER LA MONEDA DESDE LA FACTURA DE VENTAS
                  cSF2Vendedor            := (_cAliFC)->F2_VEND1    // 25-MAY-2023 PARA TRAR EL VENDEDOR DESDE LA FACTURA DE VENTAS   
		Endif
            (_cAliFC)->(dbCloseArea())
      

      EndIf
      DbSelectArea("SX3")
      DbSetOrder(2)	
      If MsSeek("F1_XFTANTE")
            If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
                  
                  If Len(aCols) == 1
                        cNumDocCli := __LOCXSF1->(F1_XFTANTE)  //factura anterior en IBS
                        M->F1_XFTANTE := cNumDocCli
                  Endif
            Endif
      Endif

      ("SX3")->(dbClosearea())
	
	IF M->F1_TIPOPE == "20"
            IF !EMPTY(cSF2Naturez)
                  M->F1_NATUREZ     := cSF2Naturez   // 05-MAY-2023 PARA TRAER LA NATURALEZ DESDE LA FACTURA DE VENTAS
            ENDIF
            M->F1_VEND1       := cSF2Vendedor  // 25-MAY-2023 PARA TRAR EL VENDEDOR DESDE LA FACTURA DE VENTAS 
     ENDIF

EndIf
RestArea(aAreaSD1)	
RestArea(aArea)
Return(.T.)
