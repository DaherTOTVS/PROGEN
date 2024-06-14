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
    // Local lIntSFC    := IntegraSFC() .And. IsInCallStack("AUTO681")
    // Local lProces    := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T.

    // cRotPad := SB1->B1_OPERPAD
    // If !Empty(SC2->C2_ROTEIRO)
	//    cRoteiro := SC2->C2_ROTEIRO
    // Else
	//     If !Empty(cRotPad)
	//         cRoteiro := cRotPad
	//     Else
	//         cRoteiro := StrZero(1, Len(SG2->G2_CODIGO))
	//     EndIf
	// EndIf

    If !EMPTY(cMOD)

        nNewTempo := MultiplicaTiempo(cTempo,cMOD)

        // If lProces
        //     dbSelectArea("SG2")
        //     SG2->(dbSetOrder(1))
        //     If SG2->(dbSeek(xFilial("SG2")+SH6->H6_PRODUTO+cRoteiro+SH6->H6_OPERAC))

        RecLock("SH6", .F.)
            SH6->H6_TEMPO := nNewTempo
        SH6->(MsUnlock())

        //         nRet := A680QtMod()*If(Empty(SG2->G2_MAOOBRA),1,SG2->G2_MAOOBRA)
        //     Else
        nRet := A680QtMod()
        //     EndIf
        // else
            // RecLock("SH6", .F.)
            //     SH6->H6_TEMPO := nNewTempo
            // SH6->(MsUnlock())

        //     nRet := A680QtMod()*If(Empty(SG2->G2_MAOOBRA),1,SG2->G2_MAOOBRA)
        // endIf

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

