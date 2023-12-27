#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
User Function MyFATA050
 
Local cDescri   := "META DE VENDA"
Local cVend1    := "Vend01"
Local nQtd1     := 1
Local nValor1   := 100
Local cVend2    := "Vend02"
Local nQtd2     := 2
Local nValor2   := 200
Local nOpcX     := 3
Local nCount    := 0
Local aErroAuto := {}
 
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
 
//* Abertura do ambiente
ConOut("Inicio: " + Time())
  
ConOut(Repl("-",80))
ConOut(PadC("Inclusao de Meta de Venda", 80))
  
PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01" MODULO "FAT" TABLES "SCT","SA3"
 
//* Inclusao - INÝCIO
aCabec  := {}
aGrid   := {}
aLinha  := {}
 
//--- Informando os dados do Cabeçalho
//****************************************************************
//* Por default da rotina o código da meta de venda é gerado de forma automática
//* Caso queira informar um código  especifico adicione o campo CT_DOC na array aCabec
//* Exemplo: aadd(aCabec, {"CT_DOC",     "Meta00001",     Nil})
//****************************************************************
aadd(aCabec, {"CT_DESCRI",  cDescri,   Nil})
 
 
//--- Informando os dados da Grid
aLinha := {}
aadd(aLinha,{"CT_SEQUEN",   '001',     Nil})
aadd(aLinha,{"CT_VEND",     cVend1,    Nil})
aadd(aLinha,{"CT_QUANT",    nQtd1,     Nil})
aadd(aLinha,{"CT_VALOR",    nValor1,   Nil})
aadd(aGrid, aLinha)
 
aLinha := {}
aadd(aLinha,{"CT_SEQUEN",   '002',     Nil})
aadd(aLinha,{"CT_VEND",     cVend2,    Nil})
aadd(aLinha,{"CT_QUANT",    nQtd2,     Nil})
aadd(aLinha,{"CT_VALOR",    nValor2,   Nil})
aadd(aGrid, aLinha)
 
 
//--- Commit da rotina
MSExecAuto({|a, b, c| FATA050(a, b, c)}, aCabec, aGrid, nOpcX)
 
If !lMsErroAuto
    ConOut("Incluida com sucesso!")
Else
    ConOut("Erro na inclusao!")
    aErroAuto := GetAutoGRLog()
    For nCount := 1 To Len(aErroAuto)
        cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
        ConOut(cLogErro)
    Next nCount
EndIf
 
RESET ENVIRONMENT
Return(.T.)
