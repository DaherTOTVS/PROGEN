#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MT681INC                                                                                      |
 | Desc:  Validação do usuário (Confirmação), na inclusão de Produção PCP Modelo 2                      |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6089415                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function A680MOD()
    Local aArea:= GetArea()
    local aAreaSG2  := SG2->(GetArea())
    Local cMOD := SH6->H6_CERQUA
    Local cTempo := SH6->H6_TEMPO
    Local nRet := PARAMIXB
    Local nNewTempo := 0

    CONOUT("A680MOD","DESARROLLO_WS",cMOD)


    If !EMPTY(cMOD)

        nNewTempo := MultiplicaTiempo(cTempo,cMOD)

        RecLock("SH6", .F.)
            SH6->H6_TEMPO := nNewTempo
        SH6->(MsUnlock())

        nRet := A680QtMod()


        RecLock("SH6", .F.)
            SH6->H6_TEMPO := cTempo
        SH6->(MsUnlock())

    EndIf


    RestArea(aAreaSG2)
    RestArea(aArea)  

Return nRet


static Function MultiplicaTiempo(cTime, nMultiplicador)
	Local nHoras := 0
	Local nMinutos := 0
	Local nTotalMinuto := 0
    Local nTotalMinutos := 0
	Local nNuevasHoras := 0
	Local nNuevosMinutos := 0

    nHoras := Val(SubStr(cTime, 1, 2))
	nMinutos := Val(SubStr(cTime, 4, 2))
	nTotalMinuto := (nHoras * 60 + nMinutos)
    nTotalMinutos := nTotalMinuto * Val(nMultiplicador)
	nNuevasHoras := Int(nTotalMinutos / 60)
	nNuevosMinutos := Mod(nTotalMinutos, 60)
	
Return PadL(AllTrim(Str(nNuevasHoras)), 2, "0") + ":" + PadL(AllTrim(Str(nNuevosMinutos)), 2, "0")

