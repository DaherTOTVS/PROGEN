User Function ACD100FI()
Local nOrig    := PARAMIXB[1] // 1 = Pedido de Venda / 2 = Nota Fiscal / 3 = Ordem de Produção
Local cFilSC9  := .T.  
Local cPerg    := "ACDPED01"

Pergunte(cPerg,.T.) 
	
cFilSC9 := ' DTOS(C9_DATENT)>="'+DTOS(mv_par01)+'".And.DTOS(C9_DATENT)<="'+DTOS(mv_par02)+'" .and. '
cFilSC9 += ' C9_XLSTEMP >="'+mv_par03+'".And.C9_XLSTEMP<="'+mv_par04+'" '

Return {1,cFilSC9} // {Origem,Filtro ADVPL}
