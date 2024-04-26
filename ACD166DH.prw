#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACD166DH()
 Local aArea    := GetArea()
 Local cAlias1	:= " "
 Local lREt     := .T.



 Upd := " UPDATE SDC010 SET D_E_L_E_T_ = '*',DC_OP=DC_PEDIDO WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM SDC010 WHERE D_E_L_E_T_ <>'*' AND DC_SEQ NOT IN ( "
 Upd +=" SELECT C9_SEQUEN FROM SC9010 WHERE D_E_L_E_T_ <>'*' AND C9_PEDIDO=DC_PEDIDO "
 Upd +=" AND DC_PRODUTO=C9_PRODUTO "
 Upd +=" AND DC_LOCAL=C9_LOCAL "
 Upd +=" AND C9_ITEM =DC_ITEM "
 Upd +=" )) AND D_E_L_E_T_ <>'*' "
 n1Statud :=TCSqlExec(Upd)

 Upd := "UPDATE SDC010 SET D_E_L_E_T_='*',DC_OP=DC_PEDIDO WHERE D_E_L_E_T_ <> '*' "
 Upd += " AND EXISTS (SELECT 1  FROM SC9010 "
 Upd += " WHERE D_E_L_E_T_ <> '*' AND DC_PEDIDO = C9_PEDIDO AND DC_ITEM = C9_ITEM AND DC_LOCAL=C9_LOCAL  AND "
 Upd += " DC_PRODUTO=C9_PRODUTO AND C9_SEQUEN=DC_SEQ AND"
 Upd += " LEN(TRIM(C9_REMITO))>0 AND  "
 Upd += " LEN(TRIM(C9_ORDSEP))>0) "
 n1Statud :=TCSqlExec(Upd)

Upd := "UPDATE SDC010 SET D_E_L_E_T_='*',DC_OP=DC_PEDIDO WHERE D_E_L_E_T_ <> '*' "
Upd += " AND NOT EXISTS (SELECT 1  FROM SBF010 WHERE D_E_L_E_T_ <> '*' AND DC_NUMSERI = BF_NUMSERI  AND DC_LOCAL=BF_LOCAL  AND DC_PRODUTO=BF_PRODUTO ) "
n1Statud :=TCSqlExec(Upd)

Upds := "UPDATE SBF010 SET BF_EMPENHO=0,BF_ESTFIS='1' WHERE D_E_L_E_T_ <> '*' "
Upds += " AND NOT EXISTS(SELECT 1 FROM SDC010 WHERE D_E_L_E_T_ <>'*' AND DC_PRODUTO=BF_PRODUTO AND BF_LOCAL=DC_LOCAL AND BF_NUMSERI=DC_NUMSERI) "
Upds += " AND BF_EMPENHO=1 "
n1Statud :=TCSqlExec(Upds)


If Select(cAlias1) > 0
	(cAlias1)->(dbCloseArea())
EndIf


cAlias1	:= GetNextAlias()

BeginSQL Alias cAlias1

    SELECT CB7_ORDSEP,CB9_NUMSER,CB9_SEQUEN,CB9_PEDIDO,CB9_ITESEP,CB9_LOCAL,CB9_LCALIZ,CB9_PROD,CB9_SEQUEN+CB9_LOTECT
     FROM CB7010 CB7
    INNER JOIN SC9010 C9 
    ON CB7_ORDSEP = C9_ORDSEP
    AND C9_REMITO = ' '
    AND C9.%notDel%
    INNER JOIN CB9010 CB9 
    ON CB7_ORDSEP = CB9_ORDSEP
    AND CB9_PEDIDO = C9_PEDIDO
    AND CB9_NUMSER != ''
    AND CB9.%notDel%
    WHERE CB7.%notDel%
    AND CB9_NUMSER NOT IN 
    (SELECT DC_NUMSERI FROM  SDC010 WHERE %notDel% AND CB9_PEDIDO=DC_PEDIDO 
    AND CB9_PROD = DC_PRODUTO AND CB9_ITESEP = DC_ITEM AND CB9_SEQUEN = DC_SEQ AND CB9_LCALIZ=DC_LOCALIZ)

EndSQL

While (cAlias1)->(!Eof())

    IF SBF->(dbSeek(xFilial("SBF")+(cAlias1)->CB9_LOCAL+(cAlias1)->CB9_LCALIZ+(cAlias1)->CB9_PROD+(cAlias1)->CB9_NUMSER))
        Reclock("SBF",.F.)
            SBF->BF_EMPENHO := 0
            SBF->BF_ESTFIS  := '2'
        SBF->(MsUnlock())
        SBF->(GravaEmp(BF_PRODUTO,;  //-- 01.C¢digo do Produto
            BF_LOCAL,;    	//-- 02.Local
            BF_QUANT,;   	//-- 03.Quantidade
            BF_QTSEGUM,;  //-- 04.Quantidade
            BF_LOTECTL,;  //-- 05.Lote
            BF_NUMLOTE,;  //-- 06.SubLote
            BF_LOCALIZ,;  //-- 07.Localiza‡Æo
            BF_NUMSERI,; //-- 08.Numero de S‚rie
            Nil,;         	//-- 09.OP
            (cAlias1)->CB9_SEQUEN,;        	//-- 10.Seq. do Empenho/Libera‡Æo do PV (Pedido de Venda)
            (cAlias1)->CB9_PEDIDO,;  	//-- 11.PV
            (cAlias1)->CB9_ITESEP,;     	//-- 12.Item do PV
            'SC6',;       	//-- 13.Origem do Empenho
            Nil,;        	//-- 14.OP Original
            Nil,;			//-- 15.Data da Entrega do Empenho
            NIL,;			//-- 16.Array para Travamento de arquivos
            .F.,;     	   	//-- 17.Estorna Empenho?
            .F.,;         	//-- 18.? chamada da Proje‡Æo de Estoques?
            .F.,;         	//-- 19.Empenha no SB2?
            .F.,;         	//-- 20.Grava SD4?
            .T.,;         	//-- 21.Considera Lotes Vencidos?
            .T.,;         //-- 22.Empenha no SB8/SBF?
            .T.))         //-- 23.Cria SDC?
    EndIf
   

    (cAlias1)->(DbSkip())
EndDo
(cAlias1)->(dbCloseArea())

Upds := "UPDATE SBF010 SET BF_EMPENHO=1,BF_ESTFIS='2' WHERE D_E_L_E_T_ <> '*' "
Upds += " AND  EXISTS(SELECT 1 FROM SDC010 WHERE D_E_L_E_T_ <>'*' AND DC_PRODUTO=BF_PRODUTO AND BF_LOCAL=DC_LOCAL AND BF_NUMSERI=DC_NUMSERI) "
Upds += " AND BF_EMPENHO=0 "
n1Statud :=TCSqlExec(Upds)
    
RestArea(aArea)

Return lREt
