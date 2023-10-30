#Include "Rwmake.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"

// Condicion Principal 610-018
//IF(FORMULA("033"),'52959502',IF(FORMULA("034"),'52959506',IF(FORMULA("028"),'51959506',IF(FORMULA("029"),'52959510',IF(FORMULA("030"),'55959506',IF(FORMULA("031"),'73959506',IF(FORMULA("032"),'17101201',SB1->B1_XCONTAC)))))))                         

User Function CMed018()

Local cCuenta:=""

If Alltrim(SF2->F2_NATUREZ)$'0300106/0300105'        // Fomula("033")                                                                              
    cCuenta:= '52959502'
elseif Alltrim(SF2->F2_NATUREZ)$'0300107/0300115'    // Fomula("034")                                                                                   
    cCuenta:= '52959506'
elseif Alltrim(SF2->F2_NATUREZ)=='0300108'.AND.SUBSTR(SD2->D2_CCUSTO,1,2)$"AD"       // Fomula("028")                                                    
    cCuenta:= '51959506''
elseif Alltrim(SF2->F2_NATUREZ)=='0300108'.AND.SUBSTR(SD2->D2_CCUSTO,1,2)$"VT"       // Fomula("029")
    cCuenta:= '52959510'
elseif Alltrim(SF2->F2_NATUREZ)=='0300108'.AND.SUBSTR(SD2->D2_CCUSTO,1,2)$"SG"       // Fomula("030")
    cCuenta:= '55959506'
elseif Alltrim(SF2->F2_NATUREZ)=='0300108'.AND.SUBSTR(SD2->D2_CCUSTO,1,2)$"CP"       // Fomula("031")
    cCuenta:= '73959506'    
elseif Alltrim(SF2->F2_NATUREZ)=='0300108'.AND.SUBSTR(SD2->D2_CCUSTO,1,2)$"PY"       // Fomula("032")
    cCuenta:= '17101201'
else
    cCuenta:= Alltrim(SB1->B1_XCONTAC)
EndIf

Return cCuenta
