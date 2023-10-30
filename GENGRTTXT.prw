#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GENSA2TXT      ||Data: 17/12/2022 ||Empresa: PROGEN       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Recepcion                        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function GENGRTTXT()

Local lSigue        := .T.
Local cQuery        := ""
Private nTotReg 	:= 0

MakeDir("C:\TOTVS")
MakeDir("C:\TOTVS\GRPROV")

If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        cFile := '860016310'+'_'+'RCP'+'_'+DTOS(dDataBase)+Substr(GetRmtTime(),1,2)+Substr(GetRmtTime(),4,2)+Substr(GetRmtTime(),7,2)+'.carga'+'.txt'
      
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
    cSD1 := RetSqlName('SD1')
    
    cQuery := " SELECT * "
	cQuery += " FROM " +cSD1
    cQuery += " WHERE "
    cQuery += " D1_DTDIGIT BETWEEN '"+Dtos(dDatabase-180)+"' AND '"+dTos(dDatabase) + "' AND "
    cQuery += " D1_ESPECIE IN ('RCN') AND " 
    cQuery += " D_E_L_E_T_ <> '*' "
    cQuery := ChangeQuery( cQuery )
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

    DbSelectArea("TRB")
    DbGoTop()

    RptStatus({|| U_GenGR()}, "Aguarde...", "Ejecutando rutina de emision Guia Recepcion...")

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

User Function GenGR()

Local cCondPed
Local cTotal  
Local cTrm
Local cSol
Local cCantAbOP
Local cCantCeOP
Local cCantSolOP

DbSelectArea( 'TRB' )
DbGoTop()
GenSC7() //Encabezado

    While !EOF()
        
        cCondPed    := Posicione("SC7",1,Xfilial("SC7")+TRB->D1_PEDIDO,"C7_COND")	
        cTotal      := u_TotalRCN(TRB->D1_FORNECE,TRB->D1_LOJA,TRB->D1_DOC,TRB->D1_SERIE)       
        cTrm        := u_TRM(TRB->D1_FORNECE,TRB->D1_LOJA,TRB->D1_DOC,TRB->D1_SERIE)
        cSol        := Posicione("SC7",1,Xfilial("SC7")+TRB->D1_PEDIDO,"C7_USER")	
        cCantAbOP   := Posicione("SC7",1,Xfilial("SC7")+TRB->D1_FORNECE+TRB->D1_LOJA+TRB->D1_PEDIDO+TRB->D1_ITEMPC,"C7_QUANT")-Posicione("SC7",1,Xfilial("SC7")+TRB->D1_FORNECE+TRB->D1_LOJA+TRB->D1_PEDIDO+TRB->D1_ITEMPC,"C7_QUJE")
        cCantCeOP   := Posicione("SC7",1,Xfilial("SC7")+TRB->D1_FORNECE+TRB->D1_LOJA+TRB->D1_PEDIDO+TRB->D1_ITEMPC,"C7_QUJE")
        cCantSolOP  := Posicione("SC7",1,Xfilial("SC7")+TRB->D1_FORNECE+TRB->D1_LOJA+TRB->D1_PEDIDO+TRB->D1_ITEMPC,"C7_QUANT")

        aDeta       := { }
        cID         := Alltrim(TRB->D1_DOC)     //1
        cNumRcp     := Alltrim(TRB->D1_DOC)     //2
        cNumOP      := Alltrim(TRB->D1_PEDIDO)  //3
        cTipoOc     := "801"                    //4
        cDescri     := "Orden de compra"        //5
        cFechaOC    := Dtos(Posicione("SC7",1,Xfilial("SC7")+TRB->D1_PEDIDO,"C7_EMISSAO"))	//6
        cNit        := Alltrim(TRB->D1_FORNECE) //7
        cRazonS     := Alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->D1_FORNECE+TRB->D1_LOJA,"A2_NOME")) //8
        cCondPag    := AllTrim(Posicione("SE4",1,xFilial("SE4")+cCondPed,"E4_DESCRI"))          //9
        cAlmacen    := Alltrim(TRB->D1_LOCAL)   //10
        cTotalLine  := Alltrim(transform(TRB->D1_TOTAL ,"@r 9999999999999.99")) //11
        cMoneda     := u_Moneda(TRB->D1_FORNECE,TRB->D1_LOJA,TRB->D1_DOC,TRB->D1_SERIE)     //12  
        cTrm        := Alltrim(transform(u_TRM(TRB->D1_FORNECE,TRB->D1_LOJA,TRB->D1_DOC,TRB->D1_SERIE) ,"@r 9999999999999.99")) //13
        cTotalPesos := Alltrim(transform(cTotal*Val(cTrm),"@r 9999999999999.99")) //14
        cStatus     := "Orden de compra" //15
        cSolicitante:= Alltrim(UsrFullName(cSol)) //16
        cNumLine    := Alltrim(TRB->D1_ITEM)      //17
        cCodProd    := Alltrim(TRB->D1_COD)       //18
        cDescProd   := AllTrim(Posicione("SB1",1,xFilial("SB1")+TRB->D1_COD,"B1_DESC")) //19
        cValorUnit  := Alltrim(transform(TRB->D1_VUNIT,"@r 9999999999999.99")) //20
        cUnidMed    := If(Alltrim(TRB->D1_XUNIDAD)='1',Alltrim(TRB->D1_UM),Alltrim(TRB->D1_SEGUM)) //21
        cCantAbiert := Alltrim(transform(cCantAbOP,"@r 9999999999999.99")) // 22
        cCantCerra  := Alltrim(transform(cCantCeOP,"@r 9999999999999.99")) // 23
        cCantSolic  := Alltrim(transform(cCantSolOP,"@r 9999999999999.99")) // 24 
        cSubtotal   := Alltrim(transform(TRB->D1_TOTAL,"@r 9999999999999.99")) // 25
        cStatus     := "O" // 26
        cTotal1     := Alltrim(transform(TRB->D1_TOTAL,"@r 9999999999999.99")) // 27
        cTotal2     := Alltrim(transform(TRB->D1_TOTAL,"@r 9999999999999.99")) // 28

    AAdd(aDeta,{cID,cNumRcp,cNumOP,cTipoOc,cDescri,cFechaOC,cNit,cRazonS,cCondPag,cAlmacen,cTotalLine,cMoneda,cTrm,cTotalPesos,cStatus,cSolicitante,cNumLine,cCodProd,cDescProd,cValorUnit,cUnidMed,cCantAbiert,cCantCerra,cCantSolic,cSubtotal,cStatus,cTotal1,cTotal2})
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
    Local xI      := ""
    For xI := 1 TO Len(aDeta)
        cString += aDeta[xI,1]+";"+aDeta[xI,2]+";"+aDeta[xI,3]+";"+aDeta[xI,4]+";"+aDeta[xI,5]+";"+aDeta[xI,6]+";"+aDeta[xI,7]+";"+aDeta[xI,8]+";"+aDeta[xI,9]+";"+aDeta[xI,10]+";"+aDeta[xI,11]+";"+aDeta[xI,12]+";"+aDeta[xI,13]+";"+aDeta[xI,14]+";"+aDeta[xI,15]+";"+aDeta[xI,16]+";"+aDeta[xI,17]+";"+aDeta[xI,18]+";"+aDeta[xI,19]+";"+aDeta[xI,20]+";"+aDeta[xI,21]+";"+aDeta[xI,22]+";"+aDeta[xI,23]+";"+aDeta[xI,24]+";"+aDeta[xI,25]+";"+aDeta[xI,26]+";"+aDeta[xI,27]+";"+aDeta[xI,28]
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

        cID         := "ID;"
        cNumRcp     := "numeroRCP;"
        cNumOP      := "numero_OC;"
        cTipoOc     := "Tipo_OC;"
        cDescri     := "Descripcion;"
        cFechaOC    := "Fecha_OC;"
        cNit        := "NIT;"
        cRazonS     := "Razon_social;"
        cCondPag    := "condicion_pago;"
        cAlmacen    := "almacen;"
        cTotalLine  := "Total recibido linea;"
        cMoneda     := "Moneda;"
        cTrm        := "TRM;"
        cTotalPesos := "Total_pesos;"
        cStatus     := "Estatus_OC;"
        cSolicitante:= "Solicitante;"
        cNumLine    := "Numero_linea;"
        cCodProd    := "Codigo;"
        cDescProd   := "Descripcion_Linea;"
        cValorUnit  := "Valor_unitario;"
        cUnidMed    := "unidad_medida;"
        cCantAbiert := "cantidad_abierta;"
        cCantCerra  := "Cantidad_cerrada;"
        cCantSolic  := "Cantidad_Solicitada;"
        cSubtotal   := "Subtotal;"
        cStatus     := "Lestatus;"
        cTotal1     := "Total recibido linea;"
        cTotal2     := "Total recibido linea;"
        
cString  := cID+cNumRcp+cNumOP+cTipoOc+cDescri+cFechaOC+cNit+cRazonS+cCondPag+cAlmacen+cTotalLine+cMoneda+cTrm+cTotalPesos+cStatus+cSolicitante+cNumLine+cCodProd+cDescProd+cValorUnit+cUnidMed+cCantAbiert+cCantCerra+cCantSolic+cSubtotal+cStatus+cTotal1+cTotal2

GrabaLog( cString )

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function Moneda(cFornece,cLoja,cDoc,cSerie)

Local cQry	  	
Local cAliasSF1 := GetNextAlias()
Local nMoneda 
Local nMoeDescri 

    cQry := "SELECT * "
    cQry += " FROM " + RetSqlName("SF1") + " "
    cQry += " WHERE "
    cQry += " F1_DOC  = '" + cDoc + "' AND " 
    cQry += " F1_SERIE  = '" + cSerie + "' AND " 
    cQry += " F1_FORNECE  = '" + cFornece + "' AND " 
    cQry += " F1_LOJA  = '" + cLoja + "' AND " 
    cQry += " F1_ESPECIE  = 'RCN' AND " 
    cQry += "D_E_L_E_T_ <> '*' "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSF1,.T.,.T.) 
	IF (cAliasSF1)->(!EOF())
	    nMoneda := (cAliasSF1)->F1_MOEDA
	EndIF
       (cAliasSF1)->(DbCloseArea()) 

    If nMoneda=1
        nMoeDescri:="COP"
    Elseif nMoneda=2
        nMoeDescri:="USD"
    elseif nMoneda=3
        nMoeDescri:="EUR"
    EndIF

  Return nMoeDescri

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function TRM(cFornece,cLoja,cDoc,cSerie)

Local cQry	  	
Local cAliasSF1 := GetNextAlias()
Local nTRM

    cQry := "SELECT * "
    cQry += " FROM " + RetSqlName("SF1") + " "
    cQry += " WHERE "
    cQry += " F1_DOC  = '" + cDoc + "' AND " 
    cQry += " F1_SERIE  = '" + cSerie + "' AND " 
    cQry += " F1_FORNECE  = '" + cFornece + "' AND " 
    cQry += " F1_LOJA  = '" + cLoja + "' AND " 
    cQry += " F1_ESPECIE  = 'RCN' AND " 
    cQry += "D_E_L_E_T_ <> '*' "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSF1,.T.,.T.) 
	IF (cAliasSF1)->(!EOF())
	    nTRM := (cAliasSF1)->F1_TXMOEDA
	EndIF
       (cAliasSF1)->(DbCloseArea()) 

Return nTRM

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function TotalRCN(cFornece,cLoja,cDoc,cSerie)

Local cQry	  	
Local cAliasSF1 := GetNextAlias()
Local nTotalRCN

    cQry := "SELECT * "
    cQry += " FROM " + RetSqlName("SF1") + " "
    cQry += " WHERE "
    cQry += " F1_DOC  = '" + cDoc + "' AND " 
    cQry += " F1_SERIE  = '" + cSerie + "' AND " 
    cQry += " F1_FORNECE  = '" + cFornece + "' AND " 
    cQry += " F1_LOJA  = '" + cLoja + "' AND " 
    cQry += " F1_ESPECIE  = 'RCN' AND " 
    cQry += "D_E_L_E_T_ <> '*' "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSF1,.T.,.T.) 
	IF (cAliasSF1)->(!EOF())
	    nTotalRCN := (cAliasSF1)->F1_VALBRUT
	EndIF
       (cAliasSF1)->(DbCloseArea()) 

Return nTotalRCN


