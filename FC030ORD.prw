#include "protheus.ch"
#include "rwmake.ch"

User Function FC030ORD()

Local cEstrut := ParamIxb[1] //Contém os campos que podem ser utilizados na cláusula ORDER BY
Local cOrdAtu := ParamIxb[2] //Contém a cláusula ORDER BY padrão do sistema
Local nOpProc := ParamIxb[3] //Corresponde à visualização de títulos em aberto (1) ou pagos (2)
Local cRet    

if nOpProc == 2
    cRet := "E5_ORDREC ASC"
else
    cRet := cOrdAtu
EndIf

Return cRet

