#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

User Function CMed641()

Local cValor:=0 

IF Alltrim(SD1->D1_ESPECIE)$"NCC".AND.!(SD1->D1_TP)$"AF/CI/GT/SR"
    cValor:= SD1->D1_CUSTO                                                                                                                                                                                                                                                                                                                              
EndIF

IF Alltrim(SD1->D1_ESPECIE)$"RFD".AND.!(SD1->D1_TP)$"AF/CI/GT/SR"
    cValor:= SD1->D1_CUSTO
EndIF                                                                                                                                                                                                                                                                                                                              

Return cValor   
