#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GENSA2TXT      ||Data: 17/12/2022 ||Empresa: PROGEN       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Orden de Compra                  //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function GENSC7TXT()

Local lSigue        := .T.
Local cQuery        := ""
Private nTotReg 	:= 0
//Private cPerg 		:= "INTSC7"

MakeDir("C:\TOTVS")
MakeDir("C:\TOTVS\PEDIDOS")

/*AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
    Return
EndIf*/
//RptStatus({|| u_GENSC7TXT()}, "Aguarde...", "Ejecutando rotina...")

//MsgRun( "Aguarde, Leyendo informaciones de pedido de compra ..." ,, {|| GenSC7() } )

If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        cFile := '860016310'+'_'+'OC'+'_'+DTOS(dDataBase)+Substr(GetRmtTime(),1,2)+Substr(GetRmtTime(),4,2)+Substr(GetRmtTime(),7,2)+'.carga'+'.txt'
      
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
    cSC7 := RetSqlName('SC7')
    cQuery := "SELECT * "
    cQuery += "FROM " +cSC7
    cQuery += " WHERE "
    cQuery += "C7_EMISSAO BETWEEN '"+Dtos(dDatabase-90)+"' AND '"+dTos(dDatabase) + "' AND "
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

    IndRegua("TRB",cNtxTmp,'C7_NUM',,,"Indexando Registros...")
    cCadastro := OemToAnsi("Generacion de archivo Pedidos de Compra")
    DbSelectArea("TRB")
    DbGoTop()

    //U_GenPed()
    RptStatus({|| U_GenPed()}, "Aguarde...", "Ejecutando rutina de emision orden de compra...")

    DbUnlockAll()
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

User Function GenPed()

Local cTipoCamb := ""

DbSelectArea( 'TRB' )
DbGoTop()
GenSC7() //Encabezado

    While !EOF()
        cTipoCamb := IF(TRB->C7_MOEDA=1,1.0000,Posicione("SM2",1,TRB->C7_EMISSAO,"M2_MOEDA2"))
        aDeta       := { }
        cIDNum      := Alltrim(TRB->C7_NUM)     //1
        cNum        := Alltrim(TRB->C7_NUM)     //2
        cTipoOCDT   := "801"                    // 3
        cTipoOC     := IF(TRB->C7_TIPO=1,"0C.Nacional(N/A)","0C.Importación(N/A)") // 4
        cFechaOc    := TRB->C7_EMISSAO                                             // 5 
        cNit        := Alltrim(TRB->C7_FORNECE)     // 6
        cRazon      := Alltrim(Posicione("SA2",1,XFILIAL("SA2")+TRB->C7_FORNECE+TRB->C7_LOJA,"A2_NOME"))    // 7
        cCondPag    := AllTrim(Posicione("SE4",1,xFilial("SE4")+TRB->C7_COND,"E4_DESCRI"))                  // 8
        cAlmacen    := Alltrim(TRB->C7_LOCAL)       // 9
        cTotalPedi  := Alltrim(transform(u_SC7TOT(TRB->C7_NUM),"@r 9999999999999.99"))  // 10       
        cMoneda     := IF(TRB->C7_MOEDA=1,"COP","USD")                                  // 11
        cTRM        := IF(TRB->C7_MOEDA=1,'1.0000',Alltrim(transform(Posicione("SM2",1,TRB->C7_EMISSAO,"M2_MOEDA2"),"@r 999999999.99")))    // 12
        cOLRCXR     := IF(TRB->C7_MOEDA=1,'1.0000',Alltrim(transform(Posicione("SM2",1,TRB->C7_EMISSAO,"M2_MOEDA2"),"@r 999999999.99")))    // 13
        cTotalPesos := Alltrim(transform(u_SC7TOT(TRB->C7_NUM)*cTipoCamb,"@r 9999999999999.99"))     // 14
        cProceso    := "En proceso"     // 15
        cSolicitante:= Alltrim(UsrFullName(TRB->C7_USER))   // 16
        cNumLine    := Alltrim(Substr(TRB->C7_ITEM,3,4))    // 17
        cCodProd    := Alltrim(TRB->C7_PRODUTO)     // 18
        cNomCodProd := Alltrim(TRB->C7_DESCRI)      // 19
        cvalorUni   := If(TRB->C7_XUNIDAD=='1',Alltrim(transform(TRB->C7_PRECO,"@r 9999999999999.99")),Alltrim(transform(TRB->C7_XPRECO2,"@r 9999999999999.99")))
        cUnidadMed  := If(TRB->C7_XUNIDAD=='1',Alltrim(TRB->C7_UM),Alltrim(TRB->C7_SEGUM))  //21
        cCantAbier  := Alltrim(transform(TRB->C7_QUANT - TRB->C7_QUJE,"@r 9999999999999.99")) // 22
        cCantCerr   := Alltrim(transform(TRB->C7_QUJE ,"@r 9999999999999.99")) //23
        cCantSolic  := Alltrim(transform(TRB->C7_QUANT,"@r 9999999999999.99")) //24
        cSubtotal   := Alltrim(transform(TRB->C7_TOTAL,"@r 9999999999999.99")) //25
        cCodPend    := ""   //26
        cPendLine   := ""   //27
        cStatus     := "O"  //28


        AAdd( aDeta,{cIDNum,cNum,cTipoOCDT,cTipoOC,cFechaOc,cNit,cRazon,cCondPag,cAlmacen,cTotalPedi,cMoneda,cTRM,cOLRCXR,cTotalPesos,cProceso,cSolicitante,cNumLine,cCodProd,cNomCodProd,cvalorUni,cUnidadMed,cCantAbier,cCantCerr,cCantSolic,cSubtotal,cCodPend,cPendLine,cStatus})
         If Len(aDeta) > 0
            GenDeta(aDeta)
        EndIf
        DbSelectArea( 'TRB' )
        DbSkip()
    EndDo
        DbSelectArea( 'TRB' )
        DbCloseArea()

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
        cString += aDeta[xI,1]+";"+ aDeta[xI,2]+";"+ aDeta[xI,3]+";"+aDeta[xI,4]+";"+aDeta[xI,5]+";"+aDeta[xI,6]+";"+aDeta[xI,7]+";"+aDeta[xI,8]+";"+aDeta[xI,9]+";"+aDeta[xI,10]+";"+aDeta[xI,11]+";"+aDeta[xI,12]+";"+aDeta[xI,13]+";"+aDeta[xI,14]+";"+aDeta[xI,15]+";"+aDeta[xI,16]+";"+aDeta[xI,17]+";"+aDeta[xI,18]+";"+aDeta[xI,19]+";"+aDeta[xI,20]+";"+aDeta[xI,21]+";"+aDeta[xI,22]+";"+aDeta[xI,23]+";"+aDeta[xI,24]+";"+aDeta[xI,25]+";"+aDeta[xI,26]+";"+aDeta[xI,27]+";"+aDeta[xI,28]
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

Static Function GenSC7()

cIDNum      := "ID;"
cNum        := "Numero_OC;"
cTipoOCDT   := "Tipo_OCDT;"
cTipoOC     := "Tipo_OC;"
cFechaOc    := "Fecha_OC;"
cNit        := "NIT;"
cRazon      := "Razon_Social;"
cCondPag    := "Condicion_Pago;"
cAlmacen    := "Almacen;"
cTotalPedi  := "Total_Original;"
cMoneda     := "Moneda;"
cTRM        := "TRM;"
cOLRCXR     := "OLRCXR;"
cTotalPesos := "Total_Pesos;"
cProceso    := "Estatus_OC;"
cSolicitante:= "Solicitante;"
cNumLine    := "Numero_Linea;"
cCodProd    := "Codigo;"
cNomCodProd := "Descripcion;"   
cvalorUni   := "valor_unitario;"
cUnidadMed  := "OLUNIT;"
cCantAbier  := "cantidad_abierta;"
cCantCerr   := "Cantidad_cerrada;"
cCantSolic  := "Cantidad_solicitada;"
cSubtotal   := "subtotal;"
cCodPend    := "Codigo_pendiente;"
cPendLine   := "Pendiente_Linea;"
cStatus     := "LS_status"

cString  := cIDNum+cNum+cTipoOCDT+cTipoOC+cFechaOc+cNit+cRazon+cCondPag+cAlmacen+cTotalPedi+cMoneda+cTRM+cOLRCXR+cTotalPesos+cProceso+cSolicitante+cNumLine+cCodProd+cNomCodProd+cvalorUni+cUnidadMed+cCantAbier+cCantCerr+cCantSolic+cSubtotal+cCodPend+cPendLine+cStatus
GrabaLog( cString )

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function SC7TOT(nPedidoTot)

Local cQry	  	
Local cAliasSC7 := GetNextAlias()
Local nVlTotSC7  

    cQry := "SELECT SUM(C7_TOTAL) AS TOTAL "
    cQry += " FROM " + RetSqlName("SC7") + " "
    cQry += "WHERE "
    cQry += "C7_NUM  = '" + nPedidoTot + "' AND " 
    cQry += "D_E_L_E_T_ <> '*' "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSC7,.T.,.T.) 
	IF (cAliasSC7)->(!EOF())
	    nVlTotSC7 := (cAliasSC7)->TOTAL
	EndIF
   (cAliasSC7)->(DbCloseArea()) 

  Return nVlTotSC7

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: AjustaSX1
Titulo	:
Fecha	: 22/12/202
Autor 	: Juan Pablo Astorga
Descripcion : Pregunta para la integracion plataforma PROGEN
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AjustaSX1(cPerg)
    Local aArea := GetArea()
    Local aRegs := {}, i, j

    cPerg := Padr(cPerg,Len(SX1->X1_GRUPO))

    DbSelectArea("SX1")
    DbSetOrder(1)

    aAdd(aRegs,{cPerg,"01","De Fecha Orden	","De Fecha Orden 	","De Fecha Orden	","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"02","A Fecha Orden	","A Fecha Orden    ","A Fecha Orden	","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"03","De Numero Orden ","De Numero Orden 	","De Numero Orden	","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"04","A Numero Orden	","A Numero Orden	","A Numero Orden 	","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    
    For i:=1 to Len(aRegs)
        If !dbSeek(cPerg+aRegs[i,2])
            RecLock("SX1",.T.)
            For j:=1 to FCount()
                If j <= Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                Endif
            Next
            MsUnlock()
        Endif
    Next

    RestArea(aArea)
Return
