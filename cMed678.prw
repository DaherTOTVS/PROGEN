#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

User Function cMed678()

Local cValor:=0 

IF Alltrim(SD2->D2_ESPECIE)$"NF".AND.!(SD2->D2_TP)$"AF/CI/GT/SR"
    cValor:= SD2->D2_CUSTO1
EndIF                                                                                                                                                                                                                                                                                                                          

IF Alltrim(SD2->D2_ESPECIE)$"RFN".AND.!(SD2->D2_TP)$"AF/CI/GT/SR"
    cValor:= SD2->D2_CUSTO1
EndIF

Return cValor
