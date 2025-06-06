#INCLUDE "TOTVS.CH"
 
User Function PApPosAp()
    Local cTipoApon := PARAMIXB[1] //Tipo do apontamento em execu��o
    Local aDados    := PARAMIXB[2] //Array de dados que ser� utilizado pelo MATA250 ou MATA681
    Local oModel    := PARAMIXB[3] //Modelo de dados da rotina de apontamento do ch�o de f�brica
    Local cTipoSFC  := PARAMIXB[4] //Tipo de opera��o no ch�o de f�brica
    Local cFormCode := PARAMIXB[5] //C�digo do Formul�rio de Apontamento utilizado para chamar o PE
 
    Do Case
        Case cTipoApon == "1" // Apontamento MATA250
            If cFormCode = "USINAGEM"
                cust250USI(@aDados)
            Else
                custom250(@aDados)
            EndIf
        Case cTipoApon == "3" // Apontamento MATA681
            custom681(@aDados)
        Case cTipoApon == "4" // Apontamento SFCA314
            customSFC(@oModel, cTipoSFC)
    EndCase
     
Return aDados
  
Static Function cust250USI(aDados)
    Local nPos   := 0
 
    nPos := aScan(aDados, {|x| x[1] == "D3_TM"})
    If nPos > 0
        aDados[nPos][2] := "001" //Altera o tipo de movimento utilizado para o formul�rio "USINAGEM"
    EndIf
 
    //Adiciona nova informa��o no array
    aAdd(aDados, {"D3_OBSERVA", "USINAGEM001", Nil})
 
Return Nil
 
Static Function custom250(aDados)
    Local nPos   := 0
 
    nPos := aScan(aDados, {|x| x[1] == "D3_TM"})
    If nPos > 0
        aDados[nPos][2] := "011" //Altera o tipo de movimento utilizado
    EndIf
 
    //Adiciona nova informa��o no array
    aAdd(aDados, {"D3_OBSERVA", "TESTE", Nil})
 
Return Nil
 
Static Function custom681(aDados)
    Local cNumOp := ""
    Local nPos   := 0
 
    //Busca n�mero da OP
    nPos := aScan(aDados, {|x| x[1] == "H6_OP"})
    If nPos > 0
        cNumOp := aDados[nPos][2]
    EndIf
 
    //Atualiza informa��o no array para inclus�o do apontamento.
    nPos := aScan(aDados, {|x| x[1] == "H6_OBSERVA"})
    If nPos > 0
        aDados[nPos][2] := "OBS:" + cNumOp
    Else
        //Adiciona nova informa��o no array
        aAdd(aDados, {"H6_OBSERVA", "OBS:" + cNumOp, Nil})
    EndIf
 
Return Nil
 
Static Function customSFC(oModel, cTipo)
    Local aErro   := {}
    Local lRet    := .T.
    Local nQtd    := 0
    Local oMdlCYV := oModel:GetModel("CYVMASTER")
 
    If cTipo == "1" // Apontamento de produ��o.
         
        //Recupera quantidade reportada do apontamento
        nQtd := oMdlCYV:GetValue("CYV_QTATRP")
 
        //Soma +1 na quantidade reportada do apontamento
        lRet := oMdlCYV:SetValue("CYV_QTATRP", nQtd + 1)
        If !lRet
            aErro := oModel:GetErrorMessage()
            VarInfo("aErro:", aErro)
        EndIf
    ElseIf cTipo == "2" // In�cio de apontamento
        //Adiciona uma informa��o na coluna CYV_CDRE
        lRet := oMdlCYV:SetValue("CYV_CDRE", "RF_TESTE")
        If !lRet
            aErro := oModel:GetErrorMessage()
            VarInfo("aErro:", aErro)
        EndIf
    ElseIf cTipo == "3" // Abandono de apontamento
        //Adiciona uma informa��o na coluna CYV_CDRE
        lRet := oMdlCYV:SetValue("CYV_CDRE", "RF_TESTE3")
        If !lRet
            aErro := oModel:GetErrorMessage()
            VarInfo("aErro:", aErro)
        EndIf
    EndIf
 
Return Nil
