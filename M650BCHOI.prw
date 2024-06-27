#INCLUDE "rwmake.ch"
#include "totvs.ch"
#include "protheus.ch"


User Function M650BCHOI()
    Local aRet := {} // Array contendo os botoes padroes da rotina.
    If RemoteType() == 1
      aAdd(aRet,{PmsBExcel()[1],{|| DlgToExcel({{"ENCHOICE",cCadastro,aGets,aTela}})},PmsBExcel()[2],PmsBExcel()[3]})
    EndIf
    If valtype(MV_PAR01)=="C"
      Pergunte("MTA650",.T.)
    EndIf
Return aRet
