#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACD166FM(cOrdsep)
 Local aArea    := GetArea()
 Local cAlias1	:= " "
 Local lREt     := .T.
 Default cOrdsep := CB7->CB7_ORDSEP

 //ELIMINAR LA SDC CUANDO EL PEDIDO,PRODUTO,ITEM CORRESPONDAN Y NO EXISTAN EN LA LECTURA DE LA CB9
If Select(cAlias1) > 0
	(cAlias1)->(dbCloseArea())
EndIf


cAlias1	:= GetNextAlias()

BeginSQL Alias cAlias1

    SELECT DC.R_E_C_N_O_ AS REG FROM %table:SDC% DC
    INNER JOIN %table:CB8% CB8 
    ON CB8_PROD = DC_PRODUTO
    AND CB8_PEDIDO = DC_PEDIDO
    AND CB8_LOCAL = DC_LOCAL
    AND CB8_SEQUEN = DC_SEQ
    AND CB8_ITEM = DC_ITEM
    AND CB8.%notDel%
    WHERE DC.%notDel%
    AND DC_NUMSERI NOT IN 
    (SELECT CB9_NUMSER FROM  %table:CB9%  WHERE %notDel% AND CB9_ORDSEP = CB8_ORDSEP 
    AND CB9_PROD = CB8_PROD AND CB9_PEDIDO = CB8_PEDIDO)
    AND CB8_ORDSEP = %Exp:cOrdsep%

EndSQL

While (cAlias1)->(!Eof())
    SDC->(dbGoTo((cAlias1)->REG))
    RecLock("SDC",.F.)
	SDC->(DbDelete())
	SDC->(MsUnlock())
    (cAlias1)->(DbSkip())
EndDo
(cAlias1)->(dbCloseArea())

    CB9->(DbSetOrder(1))
	CB9->(DbSeek(xFilial("CB8")+cOrdsep))
    While !CB9->(Eof())
        SDC->(dbSetOrder(1))
        If!SDC->(DbSeek(xFilial("SDC")+CB9->(CB9_PROD+CB9_LOCAL+'SC6'+CB9_PEDIDO+CB9_ITESEP+CB9_SEQUEN+CB9_LOTECT+CB9_NUMLOT+CB9_LCALIZ+CB9_NUMSER)))
            SBF->(dbSetOrder(1))
            IF SBF->(dbSeek(xFilial("SBF")+CB9->(CB9_LOCAL+CB9_LCALIZ+CB9_PROD+CB9_NUMSER)))
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
                    CB9->(CB9_SEQUEN),;        	//-- 10.Seq. do Empenho/Libera‡Æo do PV (Pedido de Venda)
                    CB9->(CB9_PEDIDO),;  	//-- 11.PV
                    CB9->(CB9_ITESEP),;     	//-- 12.Item do PV
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


        EndIf
    	CB9->(dbSkip())
    EndDo


    
    RestArea(aArea)


    // U_ACD166DH()
Return lREt
