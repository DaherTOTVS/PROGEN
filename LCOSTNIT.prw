#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

User Function COSTSD1()
// 641 -003
Local cCliente  := SD1->D1_FORNECE
Local cLoja     := SD1->D1_LOJA
Local cIdent    := ""
Local cNit      := "" 
Local cfisica   := ""
Local aArea 	:= getArea()
dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                                 
If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
	cNit    := SA1->A1_CGC
    cfisica := SA1->A1_PFISICA  
EndIf
RestArea(aArea)	

if Alltrim(cNit)==''
    cIdent:= cfisica
    else
    cIdent:=cNit
EndIf 

Return cIdent


User Function COSTSD2()
// 678-003
Local cCliente  := SD2->D2_CLIENTE
Local cLoja     := SD2->D2_LOJA
Local cIdent    := ""
Local cNit      := "" 
Local cfisica   := ""
Local aArea 	:= getArea()
dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                                 
If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
	cNit    := SA1->A1_CGC
    cfisica := SA1->A1_PFISICA  
EndIf
RestArea(aArea)	

if Alltrim(cNit)==''
    cIdent:= cfisica
    else
    cIdent:=cNit
EndIf 

Return cIdent
