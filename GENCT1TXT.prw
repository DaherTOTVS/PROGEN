#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GENSA2TXT      ||Data: 17/12/2022 ||Empresa: PROGEN        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function GENCT1TXT()

Local lSigue        := .T.
Local cQuery        := ""
Private nTotReg 	:= 0

MakeDir("C:\TOTVS")
MakeDir("C:\TOTVS\PLAN")
If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        cFile := '860016310'+'_'+'ACC'+'_'+DTOS(dDataBase)+Substr(GetRmtTime(),1,2)+Substr(GetRmtTime(),4,2)+Substr(GetRmtTime(),7,2)+'.carga'+'.txt'
      
        //Controla ruta del archivo
        cPath:="C:\TOTVS\"
        cPath := cGetFile( '*.txt|*.txt' , 'Ruta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

        IF SUBSTR(cPath,Len(cPath),1)$"\"
            cFile := cPath+cFile
        ELSE
            cFile := cPath+'\'+cFile
        ENDIF

        While ( nHnd  := FCreate( cFile )   ) == -1
            If !MsgYesNo("No se puede Crear el Archivo "+Alltrim(cFile)+Chr(13)+Chr(10)+"Continua?")
                lSigue   := .F.
                Exit
            EndIf
        EndDo
Endif

IF lSigue
    cNtxTmp := CriaTrab( , .f. )
    cCT1 := RetSqlName('CT1')
    cQuery := "SELECT * "
    cQuery += "FROM " +cCT1
    cQuery += "WHERE "
    cQuery += "CT1_BLOQ='2' AND "
    cQuery += "D_E_L_E_T_ <> '*' "
    cQuery += "ORDER BY CT1_CONTA "
    cQuery   := ChangeQuery( cQuery )
    dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
    
    DbSelectArea("TRB")
    Count To nTotReg
    DbGoTop()
        
    If EOF() .AND. BOF()
        MsgStop( OemToAnsi( "No se encontraron registros" ) )
        DbUnlockAll()
        DbSelectArea( 'TRB' )
        DbCloseArea()
        FErase( cNtxTmp + OrdBagExt() )
        FClose( nHnd )
         Return
    EndIf

    IndRegua("TRB",cNtxTmp,'CT1_CONTA',,,"Indexando Registros...")
    cCadastro := OemToAnsi("Generacion de archivo de Plan de Cuentas")
    DbSelectArea("TRB")
    DbGoTop()

    RptStatus({|| U_GenPlan()}, "Aguarde...", "Ejecutando emision de plan de cuentas...")

    DbUnlockAll()
    DbSelectArea( 'TRB' )
    DbCloseArea()
    FErase( cNtxTmp + OrdBagExt() )
    FClose( nHnd )
EndIf

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function GenPlan()

DbSelectArea("TRB")
DbGoTop()
GenPlanC() //Encabezado

    While !EOF()
            aDeta := { }
            cConta  := Alltrim(TRB->CT1_CONTA) 
            cDesc   := Alltrim(TRB->CT1_DESC01)
            cTipo   := "Cuenta Contable"
            AAdd( aDeta,{cConta,cDesc,cTipo})
            If Len(aDeta) > 0
                GenDeta(aDeta)
            EndIf
            DbSkip()
    EndDo

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function GenDeta(aDeta)

    Local cString := ""
    Local xI:=""
    For xI := 1 TO Len(aDeta)
        cString += aDeta[xI,1]+";"+ aDeta[xI,2]+";"+ aDeta[xI,3]
        GrabaLog( cString )
    Next

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function GrabaLog( cString )

    FWrite( nHnd, cString + Chr(13) + Chr(10) )

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function GenPlanC()

cID  	:= "ID;"
cDesc   := "Descripcion;"
cTipo   := "Tipo"

cString  := cID + cDesc + cTipo
GrabaLog( cString )

Return
