#include "protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

User function FORMPRZ()
Local cA5PE     := ""
Local CA5TEMP   := ""
Local cB5PRZ    := ""
Local cTotal    := 0
Local nPosA5PE 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "A5_PE"})  

cA5PE   := POSICIONE("SA5",2,XFILIAL("SA5")+M->B1_COD,"A5_PE")
CA5TEMP := POSICIONE("SA5",2,XFILIAL("SA5")+M->B1_COD,"A5_TEMPTRA")
cB5PRZ  := POSICIONE("SB5",1,XFILIAL("SB5")+M->B1_COD,"B5_PRZCQ")

cTotal := cA5PE + CA5TEMP + cB5PRZ


// ***************COPIA************//
// 2197
// MT010CPCAN
// SA5->A5_TEMPTRA
// SA5->A5_PE
// SB5->B5_PRZCQ

Return cTotal
