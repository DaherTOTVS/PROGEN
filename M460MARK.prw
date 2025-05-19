#INCLUDE "Rwmake.Ch"
#Include "Protheus.Ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} M460MARK - PE - No permite crear facturas con pedidos o remisiones con diferente modalidad
description
@type function
@version  
@author Felipe Gonzalez
@since 14/6/2023
@return variant, return_description
/*/
User Function M460MARK()

Local cModalidad := ""
Local cPedidos := ""

Local _cMark     := PARAMIXB[1]          // caracteres referentes aos itens selecionados para NF de saida

IF APERGUNTA[1][8] == 1
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQUERY CON ITENS SELECCIONADOS PARA NF CON BASE EN PEDIDOSЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cPedidos:= ArrTokStr(APEDIDO, "','")

      cQuery := "SELECT * FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SC5")+" SC5 ON (C9_FILIAL=C5_FILIAL AND C9_PEDIDO=C5_NUM) WHERE SC9.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*' AND C9_NFISCAL = ''  "
      cQuery += "AND C9_PEDIDO IN ('"+cPedidos+"') "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QrySC9",.T.,.T.)
      dbSelectArea("QrySC9")
      dbGoTop()
	   
      While !QrySC9->(EOF())
         IF empty(cModalidad)
            cModalidad := QrySC9->C5_NATUREZ
         ELSE
            IF (cModalidad<> QrySC9->C5_NATUREZ)
               cModalidad := ""
               msgstop("No es Permitido Facturar Pedidos con diferente Modalidad")
               QrySC9->(dbCloseArea())
               return
            EndIf
         Endif
         QrySC9->(dbSkip())
	   EndDo
	   QrySC9->(dbCloseArea()) 

ELSEIF APERGUNTA[1][8] == 2
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQUERY CON ITENS SELECCIONADOS PARA NF CON BASE EN REMISIONЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cQuery := "SELECT * FROM "+RetSqlName("SD2")+" SD2 INNER JOIN "+RetSqlName("SF2")+" SF2 ON (D2_FILIAL=F2_FILIAL AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA) " 
      cQuery += "WHERE SF2.D_E_L_E_T_ <>'*' AND SD2.D_E_L_E_T_ <>'*' "
      cQuery += "AND D2_OK = '"+_cMark+"' "
      cQuery += "AND D2_PEDIDO >= '"+MV_PAR26+"' "
      cQuery += "AND D2_PEDIDO <= '"+MV_PAR27+"' "
      cQuery += "AND D2_DOC >= '"+MV_PAR01+"' "
      cQuery += "AND D2_DOC <= '"+MV_PAR02+"' "
      
      TcQuery cQuery New Alias "QrySD2"
	   dbSelectArea("QrySD2")

	   While !QrySD2->(EOF())

         IF empty(cModalidad)
            cModalidad := QrySD2->F2_NATUREZ
         ELSE
            IF (cModalidad<> QrySD2->F2_NATUREZ)
               cModalidad := ""
               msgstop("No es Permitido Facturar Remisiones con diferente Modalidad")
               QrySD2->(dbCloseArea())
               return
            EndIf
         Endif
         QrySD2->(dbSkip())
	   EndDo
	   QrySD2->(dbCloseArea())
ENDIF
Return .T.



