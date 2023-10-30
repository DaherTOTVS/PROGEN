#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

User Function cMed666()

Local cValor:=0 

IF SD3->D3_CF=="RE6".AND.!(SD3->D3_TIPO)$"AF/CI/GT/SR"
 cValor:= SD3->D3_CUSTO1                                                                                                                                                                                                                                                                                                                                         
EndIF

IF SD3->D3_CF=="RE0".AND.Alltrim(SD3->D3_DOC)<>'INVENT'.AND.!(SD3->D3_TIPO)$"AF/CI/GT/SR
 cValor:= SD3->D3_CUSTO1
EndIF

Return cValor
