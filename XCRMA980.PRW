#include "Protheus.ch"
#include "FWMVCDEF.CH" 
 
Static __LogTela    := NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Ponto de Entrada do Cadastro de Clientes (MVC)
@param      Não há
@return     Vários. Dependerá de qual PE está sendo executado.
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6
 
Local aParam        := PARAMIXB
Local xRet          := .T.
Local lIsGrid       := .F.
Local nLinha        := 0
Local nQtdLinhas    := 0
Local cRotMVC       := "CRMA980"
Local cIDPonto      := ''
Local cIDModel      := ''
Local cIDForm       := ''
Local cEvento       := ''
Local cCampo        := ''
Local cConteudo     := ''
Local cMsg          := ''
Local oObj          := NIL

If aParam <> NIL
 
    oObj        := aParam[1]
    cIDPonto    := aParam[2]
    cIDModel    := aParam[3]
    lIsGrid     := (Len(aParam) > 3)
 
    If cIDPonto == 'FORMPRE'
 
        cEvento     := aParam[4]
        cCampo      := aParam[5]
        cConteudo   := If( ValType(aParam[6]) == 'C',;
                           "'" + aParam[6] + "'",;
                           If( ValType(aParam[6]) == 'N',;
                               AllTrim(Str(aParam[6])),;
                               If( ValType(aParam[6]) == 'D',;
                                   DtoC(aParam[6]),;
                                   If(ValType(aParam[4]) == 'L',;
                                      If(aParam[4], '.T.', '.F.'),;
                                      ''))))
        cIDForm     := oObj:GetID()
 
    ElseIf cIDPonto == 'FORMPOS'
 
        cIDForm     := oObj:GetID()
 
    ElseIf cIDPonto == 'FORMCOMMITTTSPRE' .OR. cIDPonto == 'FORMCOMMITTTSPOS'
 
        cConteudo   := If( ValType(aParam[4]) == 'L',;
                           If( aParam[4], '.T.', '.F.'),;
                           '')
 
    EndIf
 
 
    If cIDPonto == 'MODELVLDACTIVE'
 
        
 
    ElseIf cIDPonto == 'MODELPRE'
 
    
 
    ElseIf cIDPonto == 'FORMPRE'
 
 
    ElseIf cIDPonto == 'BUTTONBAR'
 
        
    ElseIf cIDPonto == 'FORMPOS'
 
        
  
    ElseIf  cIDPonto == 'MODELPOS'
 
        
 
    ElseIf cIDPonto == 'FORMCOMMITTTSPRE'
 
       
 
    ElseIf cIDPonto == 'FORMCOMMITTTSPOS'
 
        
 
    ElseIf cIDPonto == 'MODELCOMMITTTS'
 
       
 
    ElseIf cIDPonto == 'MODELCOMMITNTTS'
 
   
 
    ElseIf cIDPonto == 'MODELCANCEL'
 
       
    EndIf
 
EndIf
 
Return xRet
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ShwParam
Exibe os parâmetros do Ponto de Entrada do Cadastro de Clientes (MVC)
@param      aParam
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function ShwParam(aParam)
 
Local nInd          := 1
Local cAuxMsg       := ''
Local cAuxMsg2      := ''
Local cSeparador    := Repl('-', 40)
Local cMsg          := Iif( !(aParam[2] $ 'FORMPRE//FORMPOS//FORMCOMMITTTSPRE//FORMCOMMITTTSPOS'),;
                            'OPERATION = ' + AllTrim(Str(aParam[01]:NOPERATION)) + CRLF,;
                            '')
 
For nInd := 1 to Len(aParam)
 
    cAuxMsg     := ''
    cAuxMsg2    := ''
 
    If ValType(aParam[nInd]) == 'U'
        cAuxMsg2         := '= ' + ' NIL'
    ElseIf ValType(aParam[nInd]) == 'O'
        cAuxMsg2         := ' (OBJETO)'
    ElseIf ValType(aParam[nInd]) == 'C'
        cAuxMsg2         := "= '" + aParam[nInd] + "'"
    ElseIf ValType(aParam[nInd]) == "N"
        cAuxMsg2         := '= ' + AllTrim(Str(aParam[nInd]))
    ElseIf ValType(aParam[nInd]) == "D"
        cAuxMsg2         := '= ' + DtoC(aParam[nInd])
    ElseIf ValType(aParam[nInd]) == 'L'
        cAuxMsg2         := '= ' + If(aParam[4], '.T.', '.F.')
    EndIf
 
    If nInd == 2
        cAuxMsg        := 'IDPonto (Evento)'
    ElseIf nInd == 3
        cAuxMsg        := 'IDModelo'
    ElseIf (nInd == 4 .OR. nInd == 5 .OR. nInd == 6)
        If aParam[2] == 'FORMPRE'
            If nInd == 4
                cAuxMsg    := 'Evento'
            ElseIf nInd == 5
                cAuxMsg    := 'Campo'
            ElseIf nInd == 6 .AND. aParam[4] == 'SETVALUE'
                cAuxMsg    := 'Conteúdo'
            EndIf
        ElseIf (aParam[2] $ 'FORMCOMMITTTSPRE//FORMCOMMITTTSPOS') .AND. nInd == 6
            cAuxMsg        := 'Conteúdo'
        EndIf
    EndIf
 
    cMsg    += 'PARAMIXB[' + StrZero(nInd,2) + '] => ' + If(!Empty(cAuxMsg),cAuxMsg + ' ', '') + cAuxMsg2 + CRLF
 
Next nInd
 
If __LogTela
    ApMsgInfo("Segue a descrição dos parâmetros recebidos no PE CRMA980 MVC conforme o 'IDPonto' que está sendo executado no momento:" +;
              CRLF + CRLF +;
              cMsg)
Else
    ConOut(cMsg + cSeparador)
EndIf
Return NIL
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModifModel
Customizações nas propriedades dos campos do Modelo do Cadastro de Clientes (MVC)
@param      oObj, cIDPonto, cIDModel
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function ModifModel(oObj, cIDPonto, cIDModel)
 
If ApMsgYesNo("Vamos bloquear a digitação do campo 'A1_TELEX' no IDPonto '" + cIDPonto + "' - Modelo '" + cIDModel + "' ?")
 
    // Bloqueando a edição de um campo no Modelo...
    ApMsgInfo("Como a tela do Modelo será exibida ao usuário, vamos bloquear a edição do campo 'A1_TELEX'")
//  MODELO     -> SUBMODELO -> ESTRUTURA -> PROPRIEDADE                             -> BLOCO DE CÓDIGO                 -> X3_WHEN := .F.
    oObj:GetModel("SA1MASTER"):GetStruct():SetProperty("A1_TELEX", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
    //
 
EndIf
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} SetField
Exemplo de preenchimento de um campo do Modelo do Cadastro de Clientes (MVC)
@param      oObj, cIDPonto, cIDModel, cIDForm
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function SetField(oObj, cIDPonto, cIDModel, cIDForm)
 
If cIDModel == 'SA1MASTER'
    If oObj:GetValue('A1_EST') $ 'AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MG/MS/MT/PA/PB/PE/PI/PR/RJ/RN/RO/RR/RS/SC/SE/SP/TO' .AND.;
       Empty(oObj:GetValue('A1_PAIS'))
 
        If ApMsgYesNo("Foi informado o campo 'A1_EST' com uma Unidade Federativa do Brasil, e não foi informado o código do país." + CRLF +;
                      "Então, vamos preencher o campo 'A1_PAIS' no IDPonto '" +;
                      cIDPonto + "' - Modelo '" + cIDModel + "' ?")
            oObj:SetValue('A1_PAIS', '105')
        EndIf
 
    EndIf
EndIf
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPre
Função específica que será executada no momento FORM COMMIT TTS PRE
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyFTTSPre(oObj, cIDPonto, cIDModel, cConteudo)
 
ApMsgInfo("Esta é a minha função específica que será executada no momento 'FORM COMMIT TTS PRE'.")
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPos
Função específica que será executada no momento FORM COMMIT TTS POS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyFTTSPos(oObj, cIDPonto, cIDModel, cConteudo)
 
ApMsgInfo("Esta é a minha função específica que será executada no momento 'FORM COMMIT TTS POS'.")
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyMTTS
Função específica que será executada no momento MODEL COMMIT TTS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyMTTS(oObj, cIDPonto, cIDModel, cConteudo)
 
ApMsgInfo("Esta é a minha função específica que será executada no momento 'MODEL COMMIT TTS'.")
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyMNTTS
Função específica que será executada no momento MODEL COMMIT NÃO TTS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyMNTTS(oObj, cIDPonto, cIDModel, cConteudo)
 
ApMsgInfo("Esta é a minha função específica que será executada no momento 'MODEL COMMIT NÃO TTS'.")
Return NIL
