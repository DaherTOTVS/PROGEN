#include 'protheus.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT123ISC  ºAutor  ³Microsiga           º Data ³  01/17/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Punto de entrada para colocar el TES automaticamente traida º±±
±±º          ³de la solicitud de importacion                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT123ISC()
Local _aArea    := GetArea()
Local nX 	    := 0
Local lOk       := .T.
Local cTrans	:= ""
Local cAlmacen	:= ""
Local cVariable	:= ""
Local nFecEntr	:= ""
Local nFecIniCo := ""
Local nFecIniTr	:= ""
Local nFecIniCq	:= ""

If Alltrim(Funname())=='MATA123'  // pedido de compra intenacional / Purchase Order	

	IF Empty(CA123VIA)
		CA123VIA  := Posicione("SA2",1,xFilial("SA2")+cA120Forn,"A2_TIPO_XE")
		CDESCVIA  := Posicione("DBF",1,xFilial("DBF")+CA123VIA,"DBF_DESCR")
		CA123ORI  := Posicione("DBF",1,xFilial("DBF")+CA123VIA,"DBF_ORIGEM")
		CA123DEST := Posicione("DBF",1,xFilial("DBF")+CA123VIA,"DBF_DESTIN")
		CA123INC  := Posicione("SA2",1,xFilial("SA2")+cA120Forn,"A2_XINCOTE")
	EndIf

	For nX := 1 To Len(aHeader)

		if nItmTEL="1"
			cTrans 		:= "1"
			cAlmacen	:= "097"
		EndIf

		If nItmTEL="2"
			cTrans 		:= "2"
			cAlmacen	:= SC1->C1_LOCAL
		EndIf

		dbSelectArea("SA5")
		SA5->(dbSetOrder(1))
		If SA5->(DbSeek(xFilial("SA5")+cA120FORN+cA120LOJ+SC1->C1_PRODUTO))
			nFecEntr	:= DDATABASE+SA5->A5_PE+SA5->A5_TEMPTRA   
			nFecIniCo 	:= DDATABASE //DDATABASE+SA5->A5_TEMPTRA  
			nFecIniTr	:= DDATABASE+SA5->A5_PE 	//DDATABASE+SA5->A5_PE+SA5->A5_TEMPTRA 
			nFecIniCq	:= DDATABASE+SA5->A5_PE+SA5->A5_TEMPTRA 
			else
			nFecEntr	:= DDATABASE   
			nFecIniCo 	:= DDATABASE  
			nFecIniTr	:= DDATABASE
			nFecIniCq	:= DDATABASE
		EndIf
		Do Case
		// TRAE LA UNIDAD DE COMPRA
			Case Trim(aHeader[nX][2]) == "C7_XUNIDAD" 
			aCols[n][nX] 	:= SC1->C1_XUNIDAD
		// TRAE EL ULTIMO PRECIO DE LA FACTURA DE ENTRADA , DEPENDE DE LA MONEDA	
			Case Trim(aHeader[nX][2])== "C7_XUPRC" 
			aCols[n][nX]	:= u_cUltPrec()
		// TRAE LA LISTA DE PRECIO DEL PROVEEDOR DEPENDIENDO LA UNIDAD DE COMPRA
		/*	Case Trim(aHeader[nX][2])== "C7_CODTAB" 
			aCols[n][nX]	:= u_cTabela()*/
			Case Trim(aHeader[nX][2]) == "C7_QUANT"
			aCols[n][nX] := SC1->C1_QUANT-SC1->C1_QUJE
		// TRAE LA TES DE FORMA AUTOMATICA
			Case Trim(aHeader[nX][2])== "C7_TES"
			aCols[n][nX]	:= "300"
			Case Trim(aHeader[nX][2])== "C7_XDESTRA"
			aCols[n][nX]	:= cTrans
			Case Trim(aHeader[nX][2])== "C7_LOCAL"
			aCols[n][nX]	:= cAlmacen
			Case Trim(aHeader[nX][2]) == "C7_XPRECO2" 
			aCols[n][nX] 	:= SC1->C1_XPRECO2
			Case Trim(aHeader[nX][2]) == "C7_DATPRF" 
			aCols[n][nX] 	:= nFecEntr  
			Case Trim(aHeader[nX][2]) == "C7_DINICOM" 
			aCols[n][nX] 	:= nFecIniCo   
			Case Trim(aHeader[nX][2]) == "C7_DINITRA" 
			aCols[n][nX] 	:= nFecIniTr  
			Case Trim(aHeader[nX][2]) == "C7_DINICQ" 
			aCols[n][nX] 	:= nFecIniCq 
			Case Trim(aHeader[nX][2]) == "C7_PRECO" 
			aCols[n][nX] 	:= SC1->C1_PRECO
			Case Trim(aHeader[nX][2]) == "C7_TOTAL" 
			aCols[n][nX] 	:= SC1->C1_TOTAL
			EndCase
	Next nX
Endif
RestArea(_aArea)
Return(lOk)


// Busqueda del ultimo precio de referencia dependiendo de la Moneda
User Function cUltPrec()
Local _calias1	:="Qry12"
Local UltPrec
_cQry	:= " SELECT * FROM "+RetSqlname("SD1")+ " Where "
_cQry	+= " D_E_L_E_T_ <>'*' AND D1_COD = '"+ SC1->C1_PRODUTO+"' 
_cQry += " AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_ ) FROM " +RetSqlname("SD1")+" WHERE D1_COD = '"+ SC1->C1_PRODUTO+"' AND D1_TIPODOC='10' )
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,_cQry), _calias1, .F., .T.)
(_calias1)->(dbgotop())
if (_calias1)->(!EOF())
	If Posicione("SF1",1,xFilial("SF1")+(_calias1)->D1_DOC+(_calias1)->D1_SERIE+(_calias1)->D1_FORNECE+(_calias1)->D1_LOJA,"F1_MOEDA")==NMOEDAPED
		UltPrec := (_calias1)->D1_VUNIT
		else
		UltPrec := 0.00  
	EndIf 
else
	UltPrec  := 0.00    
EndIF
(_cAlias1)->(DbcloseArea())
Return UltPrec


// Busqueda de la lista de precio por proveedor y unidad de medida.
User Function cTabela()
Local _calias	:="Qry11"
Local cAlias	:="Qry12"
Local Tabela
_cQuery	:= " SELECT * FROM "+RetSqlname("AIA")+ " Where "
_cQuery	+= " D_E_L_E_T_ <>'*' AND AIA_CODFOR = '"+cA120Forn+"' AND AIA_LOJFOR = '"+cA120Loj+"'
_cQuery += " AND AIA_XUNIDA = '"+SC1->C1_XUNIDAD+"'
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,_cQuery), _calias, .F., .T.)
(_calias)->(dbgotop())
	if (_calias)->(!EOF())
		//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_CODPRO                                                                                                          
			_cQry	:= " SELECT * FROM "+RetSqlname("AIB")+ " Where "
			_cQry	+= " D_E_L_E_T_ <>'*' AND AIB_CODFOR = '"+cA120Forn+"' AND AIB_LOJFOR = '"+cA120Loj+"'
			_cQry   += " AND AIB_CODTAB = '"+(_calias)->AIA_CODTAB+"' AND AIB_CODPRO = '"+SC1->C1_PRODUTO+"'
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,_cQry), cAlias, .F., .T.)
			if (cAlias)->(!EOF())
				Tabela:= (cAlias)->AIB_CODTAB
			else
				Tabela:= "   "	
			EndIF
			(cAlias)->(DbcloseArea())
	else
			Tabela := "   "	
	EndIf 
(_cAlias)->(DbcloseArea())
Return Tabela
