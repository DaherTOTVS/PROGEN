#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MATA101N
Fun��o para cria��o de fatura de entrada e documento suporte usando ExecAuto
@author Claude
@since 2024
@version 1.0
/*/

User Function MATA101N()
    Local aArea     := GetArea()
    Local aAuto     := {}
    Local aAutoIt   := {}
    Local nOpcAuto  := 3
    Local lSeek     := .T.
    Local nTipoOper := 0
    Local nTipo     := 0
    
    // Configura��o para documento soporte
    nTipo := 10 // Tipo 10 para documento soporte
    
    // Chama a fun��o de cria��o do documento
    LocxNf(nTipo, @aAuto, @aAutoIt, nOpcAuto, "MATA101N", lSeek, nTipoOper)
    
    RestArea(aArea)
Return

/*/{Protheus.doc} LocxNf
Fun��o para localizar e criar o documento
@author Claude
@since 2024
@version 1.0
/*/
Static Function LocxNf(nTipo, aAuto, aAutoIt, nOpcAuto, cFunName, lSeek, nTipoOper)
    Local aArea     := GetArea()
    Local lDocSp    := .F.
    Local lAutoFact := .F.
    Local aAutofac  := {}
    Local cPaisLoc  := SuperGetMV("MV_PAIS",,"")
    
    // Configura��o para documento soporte
    If cPaisLoc == "COL"
        lDocSp := .T.
    EndIf
    
    // ExecAuto para cria��o do documento
    If !Empty(aAuto) .And. !Empty(aAutoIt)
        // Configura��o do cabe�alho
        aAdd(aAuto, {"F1_TIPODOC", nTipo, Nil})
        aAdd(aAuto, {"F1_SOPORT", IIf(lDocSp, "S", "N"), Nil})
        
        // ExecAuto para criar o documento
        nOpcAuto := 3 // Incluir/Alterar/Excluir
        If !Empty(aAuto) .And. !Empty(aAutoIt)
            If !lAutoFact
                // ExecAuto para fatura normal
                ExecAuto(1, aAuto, aAutoIt, nOpcAuto)
            Else
                // ExecAuto para fatura autom�tica
                ExecAuto(5, aAuto, aAutoIt, nOpcAuto)
            EndIf
        EndIf
    EndIf
    
    RestArea(aArea)
Return 
