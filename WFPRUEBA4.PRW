#INCLUDE 'rwmake.ch'
#INCLUDE 'PROTHEUS.CH'
 
/*/{Protheus.doc} WFPRUEBA3
    Función principal que se debe informar en el Schedule
    /*/
Function WFPRUEBA4(aPar)
    If IsBlind()
        BatchProcess("Teste","Teste",,{ || TSTExec4() })
    EndIf
Return Nil
 
/*/{Protheus.doc} TSTExec3
    Función informanda en la función BatchProcess, la cual se ejecutará
    conforme a la periodicidad informada en el Schedule.
    /*/
Function TSTExec4()
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
