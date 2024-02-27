#Include "Protheus.ch"

User Function CCSC6()
Local nCC   := ""
Local nCli  := M->C5_CLIENTE
Local nLoj  := M->C5_LOJACLI 
Local nProd := gdFieldGet("C6_PRODUTO")

IF alltrim(M->C5_NATUREZ)$"0300102/0300113/0300114"
    nCC := Posicione("SA1",1,xFilial("SA1")+nCli+nLoj,"A1_XCC")            
elseif  alltrim(M->C5_NATUREZ)$"0300103"
    nCC := "VT17"
Else
    nCC := Posicione("SB1",1,xFilial("SB1")+nProd,"B1_CC")
EndIf

Return nCC
