#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GENSA2TXT      ||Data: 17/12/2022 ||Empresa: PROGEN        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function GENSA2TXT()

Local lSigue        := .T.
Local cQuery        := ""
Private nTotReg 	:= 0

MakeDir("C:\TOTVS")
MakeDir("C:\TOTVS\TERCEROS")
If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        cFile := '860016310'+'_'+'TER'+'_'+DTOS(dDataBase)+Substr(GetRmtTime(),1,2)+Substr(GetRmtTime(),4,2)+Substr(GetRmtTime(),7,2)+'.carga'+'.txt'

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
    cSA2 := RetSqlName('SA2')
    cQuery := "SELECT * "
    cQuery += "FROM " +cSA2
    cQuery += "WHERE "
    cQuery += "D_E_L_E_T_ <> '*' "
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

    IndRegua("TRB",cNtxTmp,'A2_COD',,,"Indexando Registros...")
    cCadastro := OemToAnsi("Generacion de archivo de Terceros")
    DbSelectArea("TRB")
    DbGoTop()

    RptStatus({|| U_GenTerc()}, "Aguarde...", "Ejecutando emision de terceros...")

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

User Function GenTerc()

DbSelectArea("TRB")
DbGoTop()
GenPago() //Encabezado

    While !EOF()
            aDeta := { }
            cCod  := Alltrim(TRB->A2_COD) 
            cLoja := IF(Alltrim(TRB->A2_CGC)<>'',Alltrim(TRB->A2_CGC),Alltrim(TRB->A2_PFISICA))
            cNome := Alltrim(TRB->A2_NOME)
            cGiro := ""
            AAdd( aDeta,{cCod,cLoja,cNome,cGiro})
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
        cString += aDeta[xI,1]+";"+ aDeta[xI,2]+";"+ aDeta[xI,3]+";"+aDeta[xI,4]
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

Static Function GenPago()

cID  	:= "ID;"
cRut  	:= "RUT;"
cDesc   := "Descripcion;"
cGiro   := "Giro"

cString  := cId + cRut + cDesc + cGiro
GrabaLog( cString )

Return
