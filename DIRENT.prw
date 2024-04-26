#Include "Protheus.ch"

User Function DIRENTC5(nTipo)
Local aArea    := GetArea()
Local aSvZZE   := ZZE->(GetArea())
Local cCli  := M->C5_CLIENT
Local cLoj  := M->C5_LOJAENT 
Local cDir  := M->C5_XENDENT
Local cEst  := M->C5_XEST
Local cMun  := M->C5_XCOD_MU
Local cNMun  := M->C5_XMUN
Local cRet  := ""
Default nTipo := 1


	dbSelectArea( "ZZE" )
	ZZE->(dbSetOrder(2))
	IF ZZE->(DBSEEK(cCli+cLoj+cDir))

        If nTipo == 1 // Departamento
            cRet := ZZE->(ZZE_EST)
        ElseIf nTipo == 2 // Municipio
            cRet := ZZE->(ZZE_MUN)
        Else 
            cRet := POSICIONE("CC2",1,xfilial("CC2")+ZZE->(ZZE_EST)+ZZE->(ZZE_MUN),"CC2_MUN")
        EndIf

    else

        If nTipo == 1 // Departamento
            cRet := cEst
        ElseIf nTipo == 2 // Municipio 
            cRet := cMun
        Else
            cRet := cNMun
        EndIf

    EndIf
    ("ZZE")->(DBCloseArea())

RestArea( aSvZZE )
RestArea(aArea)
Return cRet

User Function DIRENTCJ(nTipo)
Local aArea    := GetArea()
Local aSvZZE   := ZZE->(GetArea())
Local cCli  := PADR(M->CJ_CLIENT,TAMSX3("ZZE_CODCL")[1])
Local cLoj  := PADR(M->CJ_LOJAENT,TAMSX3("ZZE_LOJC")[1])
Local cDir  := PADR(M->CJ_XENDEN,TAMSX3("ZZE_DIRECC")[1])
Local cEst  := PADR(M->CJ_XESTDEP,TAMSX3("ZZE_EST")[1])
Local cMun  := PADR(M->CJ_XCODMUN,TAMSX3("ZZE_MUN")[1])
Local cNMun  := M->CJ_XMUNENT
Local cRet  := ""

Default nTipo := 1


	dbSelectArea( "ZZE" )
	ZZE->(dbSetOrder(2))
	IF ZZE->(DBSEEK(cCli+cLoj+cDir))

        If nTipo == 1 // Departamento
            cRet := ZZE->(ZZE_EST)
        ElseIf nTipo == 2 // Municipio
            cRet := ZZE->(ZZE_MUN)
        Else 
            cRet := POSICIONE("CC2",1,xfilial("CC2")+ZZE->(ZZE_EST)+ZZE->(ZZE_MUN),"CC2_MUN")
        EndIf

    else

        If nTipo == 1 // Departamento
            cRet := cEst
        ElseIf nTipo == 2 // Municipio 
            cRet := cMun
        Else
            cRet := cNMun
        EndIf

    EndIf
    ("ZZE")->(DBCloseArea())

RestArea( aSvZZE )
RestArea(aArea)
Return cRet
