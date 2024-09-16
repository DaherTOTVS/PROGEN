//Agrega los costos de importacion al costo estandar del producto
#include "Protheus.ch"


USER FUNCTION A320CUST()
    
      Local cProc := ParamIXB[3] // Define qual processamento sera realizado de acordo com a funcao
      Local cQry:=''
      Local cSD1:="cAliasSD1"
      Local nCosto:=ParamIXB[2]
      Local cCod:=SB1->B1_COD //ParamIXB[1]
      
      IF cProc <> "MA320LCust"
             Return
      endif
      cQry += "SELECT D1_TIPO, D1_COD,D1_TES, D1_LOCAL,D1_DTDIGIT,  D1_QUANT,D1_NUMSEQ,D1_CUSTO, D1_CUSTO2,D1_CUSTO3,D1_CUSTO4,D1_CUSTO5, D1_DOC, D1_SERIE, D1_ITEM, F4_ESTOQUE,F4_UPRC,F4_CODIGO "
	cQRy += " FROM " + RetSqlName("SD1") + "  SD1, "+ RetSqlName("SF4") + "  SF4 "
      cQry += " WHERE SD1.D1_FILIAL= '" + xFilial("SD1") + "' AND  SF4.F4_FILIAL= '" + xFilial("SF4") + "' AND  SD1.D_E_L_E_T_=' ' AND SD1.D1_COD = '"+cCod+"' " 
      cQry += " AND SD1.D1_TES = SF4.F4_CODIGO AND SD1.D1_TIPO = 'N' "
      cQry += " ORDER BY SD1.R_E_C_N_O_ DESC " 
      //cQry += " ORDER BY SD1.D1_DTDIGIT DESC" 
      cQry := ChangeQuery(cQry)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cSD1,.T.,.F.)
      dbSelectArea(cSD1)

	While !(cSD1)->(Eof())
            IF  (cSD1)->F4_ESTOQUE == "S" .And. (cSD1)->F4_UPRC <> 'N'
                  nCosto:= u_SumaComplemento((cSD1)->D1_DOC,(cSD1)->D1_SERIE,(cSD1)->D1_COD,(cSD1)->D1_ITEM)
                  if nCosto > 0
                        nCosto:= nCosto / (cSD1)->D1_QUANT
                  endif      
            endif
            Exit
            //(cSD1)->(dbskip())
     	EndDo
      (cSD1)->(dbClosearea())

      if nCosto>0
            If RetArqProd(cCod)
                  RecLock("SB1",.F.)
                  SB1->B1_CUSTD += nCosto
                  SB1->(MsUnLock())
            Else
                  RecLock("SBZ",.F.)
                  SBZ->BZ_CUSTD+= nCosto
                  SBZ->(MsUnLock())
                  dbSelectArea("SB1")
            EndIf
      endif
 
RETURN 

User function SumaComplemento(cDoc, cSerie,cProd,cItem)


Local cQry2:=''
Local cSD1Com:="SD1COM"
Local nSumaComp:=0
      
      
cQry2 += "SELECT D1_TIPO, D1_COD,D1_TES, D1_LOCAL,D1_DTDIGIT,  D1_QUANT,D1_NUMSEQ,D1_CUSTO, D1_CUSTO2,D1_CUSTO3,D1_CUSTO4,D1_CUSTO5, D1_NFORI, D1_SERIORI, D1_ITEMORI"
cQRy2 += " FROM " + RetSqlName("SD1") + "  SD1"
cQry2 += " WHERE SD1.D1_FILIAL= '"+xFilial("SD1") + "' AND  SD1.D_E_L_E_T_ = ''   AND SD1.D1_NFORI='"+cDoc+"' and SD1.D1_SERIORI='"+cSerie+"' "
cQry2 += " AND SD1.D1_ITEMORI='" +cItem+"' "

cQry2 := ChangeQuery(cQry2)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cSD1Com,.T.,.F.)
dbSelectArea(cSD1Com)

While !(cSD1Com)->(Eof())
       nSumaComp+=&("(cSD1Com)->D1_CUSTO"+If(mv_par01==1," ",Str(mv_par01,1,0))) 
       (cSD1Com)->(dbskip())
EndDo
(cSD1Com)->(dbClosearea())

Return  nSumaComp
