#Include "Totvs.Ch"

/*/{Protheus.doc} MT241TOK
VALIDACAO DA TUDO OK DO MATA241
@type       function
@version    001
@author     Larson Zordan
@since      15/12/2022
@return     variant, .T. 
/*/
User Function MT241TOK()
Local cTMOP     := GetNewPar("PG_TMOP","550")
Local nPosObs 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D3_OBSERVA"}) // Juan Pablo Astorga 17.03.2023
Local lRet      := .T.
Local nX 
Local nPosFun 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D3_XFUN"}) // Juan Pablo Astorga 17.03.2023
Local cParamTM := SuperGetMV("PG_TMFUN",.F.,"")

If cTM $ cTMOP
    For nX := 1 To Len(aCols)
        If Empty(aCols[nX][nPosOP])
            Help(" ",1,"NVAZIO",, RetTitle("D3_OP"), 3, 0)
            lRet := .F.
            Exit
        EndIf
        If Empty(aCols[nX][nPosObs])             // Juan Pablo Astorga 17.03.2023
            Help(" ",1,"NVAZIO",, RetTitle("D3_OBSERVA"),3,0)
            lRet := .F.
            Exit
        EndIf
    Next nX
EndIf

If cTM $ cParamTM
    For nX := 1 To Len(aCols)
        If Empty(aCols[nX][nPosFun])
            msgalert("Informar funcionario en la linea "+alltrim(str(nX))+"","Funcionario Vacio")
            lRet := .F.
            Exit
        EndIf
    Next nX
EndIf

Return(lRet)
