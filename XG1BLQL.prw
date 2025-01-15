#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#include 'fivewin.ch'

User Function XG1BLQL(COD,REVINI)
  
Local aArea 	:= GetArea()
Local cBlq    := "No"
Local cEstado  := ""

cEstado := POSICIONE("SG5",1,XFILIAL("SG5")+COD+REVINI,"G5_MSBLQL")        

If Alltrim(cEstado) == "1"
    cBlq := "Si"
EndIF

RestArea(aArea)
Return cBlq
