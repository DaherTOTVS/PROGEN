#include 'protheus.ch'
#include 'parmtype.ch'

user function MC030SALD()
Local aTest := PARAMIXB[1]
Local cUsuariolog := upper(cusername)
Local cUsuariossincosto := upper(SuperGetMV("PG_USUNOCO",.F.,"")) 
if !(cUsuariolog $ cUsuariossincosto)
    aTest[2] := "0"
    aTest[3] := "   0"
    nTotVEnt := "0"
    nTotVSda := "0"
    aSalAtu[mv_par05+1] := 0
endif
return aTest
