#include "protheus.ch"
#include "rwmake.ch"

User Function FC030ORD()

Local cEstrut := ParamIxb[1] //Cont�m os campos que podem ser utilizados na cl�usula ORDER BY
Local cOrdAtu := ParamIxb[2] //Cont�m a cl�usula ORDER BY padr�o do sistema
Local nOpProc := ParamIxb[3] //Corresponde � visualiza��o de t�tulos em aberto (1) ou pagos (2)
Local cRet    

if nOpProc == 2
    cRet := "E5_ORDREC ASC"
else
    cRet := cOrdAtu
EndIf

Return cRet

