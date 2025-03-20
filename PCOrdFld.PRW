#Include 'TOTVS.CH'
  
User Function PCOrdFld()
    Local aHeader   := PARAMIXB[1] //Array com os campos e valores do cabeçalho que serão encaminhados para a gravação do Pedidos de Vendas.
    Local aItems    := PARAMIXB[2] //Array com os Itens e valores que serão encaminhados para a gravação do Pedidos de Vendas.
    Local nX        := 1
    Local aRet      := {}
     
    //Adicionar campo customizado C5_XPGV no cabeçalho do Pedidos de Vendas com o valor "Reg. Op:3 Portal do Cliente"        
    Aadd( aHeader, { "C5_VEND1" , "999999", NIL } )
     
//    //Percorrer todos os itens desse Pedido de Vendas
//    For nX:= 1 To Len(aItems)
//       //Adicionar campo customizado 'C6_XPGV' em todos os itens do Pedidos de Vendas com o valor "Reg. Op:3 Portal do Cliente"
//       Aadd( aItems[nX], { "C6_XPGV" , "Reg. Op:"+cValToChar(3)+" Portal do Cliente", NIL } )
//    Next   
  
    aRet :={ aHeader, aItems }
      
Return aRet
