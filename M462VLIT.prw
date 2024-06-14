#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function M462VLIT()
Local aArea    := GetArea()
Local cAlias1 := GetNextAlias()
Local aAreaCB7   := CB7->(GetArea())
Local lRet := .T.
Local cPedido := SC9->C9_PEDIDO
Local cItem := SC9->C9_ITEM
Local cProduto := SC9->C9_PRODUTO
Local cSequen := SC9->C9_SEQUEN
Local cOrdsep := SC9->C9_ORDSEP
local Upds := ""



If Select(cAlias1) > 0
	(cAlias1)->(dbCloseArea())
EndIf

CB7->(dbSetOrder(1))
If ALLTRIM(cOrdsep)!= "" .AND. CB7->(dbSeek(xFilial("CB7")+cOrdsep))

    Upds := "DELETE  FROM "+RetSqlName("SDC")+" WHERE  "
    Upds += "  DC_PRODUTO='" + AllTrim(cProduto)+"' AND DC_PEDIDO='" + AllTrim(cPedido)+"' "
    Upds += " AND DC_SEQ='" + AllTrim(cSequen)+"' AND DC_ITEM='" + AllTrim(cItem)+"'  "

    n1Statud :=TCSqlExec(Upds)

    BeginSQL Alias cAlias1

        SELECT  CB7_ORDSEP,CB9_NUMSER,CB9_SEQUEN,CB9_PEDIDO,CB9_ITESEP,CB9_LOCAL,CB9_LCALIZ,CB9_PROD,CB9_SEQUEN
        FROM %table:CB7%  CB7
        INNER JOIN %table:SC9%  C9 
        ON CB7_ORDSEP = C9_ORDSEP
        AND C9_REMITO = ' '
        AND C9.%notDel%
        INNER JOIN %table:CB9%  CB9 
        ON CB7_ORDSEP = CB9_ORDSEP
        AND CB9_PEDIDO = C9_PEDIDO
        AND CB9_ITESEP=C9_ITEM
        AND CB9_QTESEP > 0
        AND CB9_NUMSER != ''
        AND CB9.%notDel%
        WHERE CB7.%notDel%
        AND CB9_PEDIDO = %Exp:cPedido%
        AND CB9_ORDSEP = %Exp:cOrdsep%
        AND CB9_PROD = %Exp:cProduto%
        AND CB9_SEQUEN = %Exp:cSequen%
        AND CB9_NUMSER NOT IN 
        (SELECT DC_NUMSERI FROM  %table:SDC%  WHERE %notDel% AND CB9_PEDIDO=DC_PEDIDO 
        AND CB9_PROD = DC_PRODUTO AND CB9_ITESEP = DC_ITEM AND CB9_SEQUEN = DC_SEQ AND CB9_LCALIZ=DC_LOCALIZ)

    EndSQL

    While (cAlias1)->(!Eof())
            SBF->(dbSetOrder(1))
        IF SBF->(dbSeek(xFilial("SBF")+(cAlias1)->CB9_LOCAL+(cAlias1)->CB9_LCALIZ+(cAlias1)->CB9_PROD+(cAlias1)->CB9_NUMSER))
            Reclock("SBF",.F.)
                SBF->BF_EMPENHO := 0
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

EndIf
RestArea(aAreaCB7)
RestArea(aArea)

Return lRet
