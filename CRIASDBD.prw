#INCLUDE "Acda100.ch" 
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � CRIASDBD     � Autor � Duvan Hernandez  � Data � 16/07/23 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Ingresa seriales leidos que no estan en la SDC		      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   											                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矴enerico - Modulos ACD                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
User Function CRIASDBD()
 Local cxNumSerie    := DB_NUMSERI
 Local cxRemDOc    := DB_DOC
 Local cxProduto     := DB_PRODUTO
 Local cxLocal       := DB_LOCAL
 Local cxLocaliza    := DB_LOCALIZ
 Local cxPedido      := SC9->(C9_pedido)
 Local cxOrdsep      := SC9->(C9_ORDSEP)
 Local cNumSerie     := ""
 Local lxAglutina      := lAglutina
 Local aArea    := GetArea()
 Local lREt     := .T.

    If !lxAglutina
        If ALLTRIM(cxNumSerie) == ""
            _cAQuery := " SELECT TOP 1 CB9_NUMSER cNumSerie FROM "+RetSQLName('CB9')+" "
            _cAQuery += " WHERE D_E_L_E_T_ <>'*' "
            _cAQuery += " AND CB9_PEDIDO='"+cxPedido+"' AND "
            _cAQuery += " CB9_PROD='"+cxProduto+"' AND "
            _cAQuery += " CB9_LOCAL='"+cxLocal+"' AND "
            _cAQuery += " CB9_ORDSEP='"+cxOrdsep+"' AND"
            _cAQuery += " CB9_LCALIZ='"+cxLocaliza+"' AND"
            _cAQuery += " CB9_NUMSER NOT IN (SELECT DB_NUMSERI FROM "+RetSQLName('SDB')+" WHERE D_E_L_E_T_ <>'*' AND DB_DOC='"+cxRemDOc+"' AND DB_PRODUTO=CB9_PROD AND DB_LOCAL=CB9_LOCAL AND DB_LOCALIZ=CB9_LCALIZ AND DB_ORIGEM='SC6' AND DB_SERIE='R')"
       
            TcQuery _cAQuery New Alias "_aQRY"
            dbSelectArea("_aQRY")
            If !_aQRY->(EOF())
                If ALLTRIM(_aQRY->cNumSerie) != ""
                    cNumSerie := _aQRY->cNumSerie
                    SBF->(dbSetOrder(1))
                    SBF->(dbSeek(xFilial("SBF")+cxLocal+cxLocaliza+cxProduto+cNumSerie))
                    SBF->(GravaEmp(BF_PRODUTO,;  //-- 01.Cigo do Produto
                            BF_LOCAL,;    	//-- 02.Local
                            BF_QUANT,;   	//-- 03.Quantidade
                            BF_QTSEGUM,;  //-- 04.Quantidade
                            BF_LOTECTL,;  //-- 05.Lote
                            BF_NUMLOTE,;  //-- 06.SubLote
                            BF_LOCALIZ,;  //-- 07.Localiza嚻o
                            BF_NUMSERIE,; //-- 08.Numero de S俽ie
                            Nil,;         	//-- 09.OP
                            SC9->(C9_SEQUEN),;        	//-- 10.Seq. do Empenho/Libera嚻o do PV (Pedido de Venda)
                            SC9->(C9_PEDIDO),;  	//-- 11.PV
                            SC9->(C9_ITEM),;     	//-- 12.Item do PV
                            'SC6',;       	//-- 13.Origem do Empenho
                            Nil,;        	//-- 14.OP Original
                            Nil,;			//-- 15.Data da Entrega do Empenho
                            NIL,;			//-- 16.Array para Travamento de arquivos
                            .F.,;     	   	//-- 17.Estorna Empenho?
                            .F.,;         	//-- 18.? chamada da Proje嚻o de Estoques?
                            .T.,;         	//-- 19.Empenha no SB2?
                            .F.,;         	//-- 20.Grava SD4?
                            .T.,;         	//-- 21.Considera Lotes Vencidos?
                            .T.,;         //-- 22.Empenha no SB8/SBF?
                            .T.))         //-- 23.Cria SDC?
                    Reclock('SDB', .F.)
                    Replace SDB->DB_NUMSERI With cNumSerie
                    SDB->( MsUnlock())
                Endif
                _aQRY->(dbSkip())
            EndIf
            _aQRY->(dbCloseArea())
        EndIf
    EndIf
    RestArea(aArea)

Return lREt
