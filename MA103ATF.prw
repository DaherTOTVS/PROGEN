#Include 'Protheus.ch'

User Function MA103ATF()
Local aCab := ParamIXB[1]
Local aItens := ParamIXB[2]

 aCab[4][2]:= PADR(SD1->D1_XDESCRI,TAMSX3("N1_DESCRIC")[1])  // N1_DESCRIC


Return({aCab,aItens})
