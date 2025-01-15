#INCLUDE 'rwmake.ch'
#INCLUDE 'PROTHEUS.CH'
 
/*/{Protheus.doc} WFPRUEBA3
    Función principal que se debe informar en el Schedule
    /*/
User Function WFTRASAUT(aPar)
    If aPar $ 'FVE|SET'
        If IsBlind()
            BatchProcess("FVE","FAC",,{ || TSTExec3() })
        EndIf
    ElseIf aPar $ 'NCC|HAN'
        If IsBlind()
            BatchProcess("NCC","Nota",,{ || TSTExec3() })
        EndIf
    ElseIf aPar $ 'DSE'
        If IsBlind()
            BatchProcess("DSE","doc",,{ || TSTExec3() })
        EndIf
    EndIf

Return Nil
 
/*/{Protheus.doc} TSTExec3
    Función informanda en la función BatchProcess, la cual se ejecutará
    conforme a la periodicidad informada en el Schedule.
    /*/
User Function TSTExec3()
    MakeSqlExpr("MATA486K")
    DSVFAT1(MV_PAR01,MV_PAR02)
Return      
 
/*/{Protheus.doc} SchedDef
    Función requerida para ejecución en el Schedule.
    /*/
Static Function SchedDef()
    Local aParam  := {}
 
    aParam := { "P",;           //Tipo R para relatorio P para processo
                "MATA486K",;        //Pergunte do relatorio, caso nao use passar ParamDef
                ,;              //Alias
                ,;              //Array de ordens
                ""}             //Titulo - "Calculo de Depreciacao e Correcao Monetaria"
 
Return aParam
