#Include "Protheus.ch"
#Include "TopConn.ch"



User Function USQLSBF()



	Local aArea       := GetArea()
	Local Upd			:= ""
	

	if UserActua<>"000027"
		Return
	EndIF



	Upd := " UPDATE SDC010 SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM SDC010 WHERE D_E_L_E_T_ <>'*' AND DC_SEQ NOT IN ( "
	Upd +=" SELECT C9_SEQUEN FROM SC9010 WHERE D_E_L_E_T_ <>'*' AND C9_PEDIDO=DC_PEDIDO "
	Upd +=" AND DC_PRODUTO=C9_PRODUTO "
	Upd +=" AND C9_ITEM =DC_ITEM "
	Upd +=" AND C9_NFISCAL='' "
	Upd +=" )ORDER BY DC_PEDIDO DESC) AND D_E_L_E_T_ <>'*' "
	n1Statud :=TCSqlExec(Upd)



	
	RestArea(aArea)
Return



