#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GENSA2TXT      ||Data: 17/12/2022 ||Empresa: PROGEN       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Factura de Proveedor             //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function GENFATTXT()

Local lSigue        := .T.
Local cQuery        := ""
Private nTotReg 	:= 0

MakeDir("C:\TOTVS")
MakeDir("C:\TOTVS\FATPROV")

If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        cFile := '860016310'+'_'+'FAC'+'_'+DTOS(dDataBase)+Substr(GetRmtTime(),1,2)+Substr(GetRmtTime(),4,2)+Substr(GetRmtTime(),7,2)+'.carga'+'.txt'
      
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
    cSF1 := RetSqlName('SD1')
    cSF2 := RetSqlName('SD2')
    
    cQuery := " SELECT D1_PEDIDO AS PEDIDO , D1_FORNECE AS PROVEEDOR  , D1_LOJA  AS LOJA , D1_DOC AS COMPROBANTE, D1_SERIE AS SERIE , D1_ESPECIE AS ESPECIE , D1_EMISSAO AS EMISION , D1_DTDIGIT AS FECHACONTB "
	cQuery += " FROM " +cSF1
    cQuery += " WHERE "
    cQuery += " D1_DTDIGIT BETWEEN '"+Dtos(dDatabase-180)+"' AND '"+dTos(dDatabase) + "' AND "
    cQuery += " D1_ESPECIE IN ('NF','NDP') AND " 
    cQuery += " D_E_L_E_T_ <> '*' "
    cQuery += " UNION "
    cQuery += " SELECT D2_PEDIDO AS PEDIDO , D2_CLIENTE AS PROVEEDOR  , D2_LOJA  AS LOJA , D2_DOC AS COMPROBANTE, D2_SERIE AS SERIE , D2_ESPECIE AS ESPECIE , D2_EMISSAO AS EMISION , D2_DTDIGIT AS FECHACONTB "
	cQuery += " FROM " +cSF2
    cQuery += " WHERE "
    cQuery += " D2_DTDIGIT BETWEEN '"+Dtos(dDatabase-180)+"' AND '"+dTos(dDatabase) + "' AND "
    cQuery += " D2_ESPECIE IN ('NCP') AND " 
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

    RptStatus({|| U_Genfat()}, "Aguarde...", "Ejecutando rutina de emision factura Proveedor..")

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

User Function Genfat()
Local cValorLiq
Local cHora

DbSelectArea( 'TRB' )
DbGoTop()
GenSC7() //Encabezado

    While !EOF()
        
        cValorLiq   := Posicione("SE2",6,xFilial("SE2")+TRB->PROVEEDOR+TRB->LOJA+TRB->SERIE+TRB->COMPROBANTE,"E2_VALLIQ")
        cHora       := u_lhora(TRB->ESPECIE) 

        aDeta       := { }
        cIDNum      := Alltrim(TRB->PROVEEDOR)+Alltrim(TRB->COMPROBANTE)+cHora // 1
        cNIT        := Alltrim(TRB->PROVEEDOR)      //2
        cRazon      := Alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->PROVEEDOR+TRB->LOJA,"A2_NOME"))    //3
        cFolio      := Alltrim(TRB->COMPROBANTE)    //4
        cTipoDoc    := BuscaTipo(ESPECIE)           //5
        cFechaFol   := TRB->FECHACONTB              //6
        cDescripDoc := ""                           //7
        cTipoDoc2   := ""                           //8
        cNumDoc     := Alltrim(TRB->COMPROBANTE)    //9
        cOrdenComp  := Alltrim(TRB->PEDIDO) //10
        cFechaEmis  := TRB->EMISION     //11
        cFechaVenc  := Alltrim(Dtos(Posicione("SE2",6,xFilial("SE2")+TRB->PROVEEDOR+TRB->LOJA+TRB->SERIE+TRB->COMPROBANTE,"E2_VENCTO")))    //12
        cMoneda     := u_Moeda(TRB->ESPECIE) //13
        cSubtotal   := u_cSubtotal(TRB->ESPECIE)//Alltrim(transform(TRB->SUBTOTAL  ,"@r 9999999999999.99")) //14
        cRetefuente := u_cRetefuente(TRB->ESPECIE)//Alltrim(transform(TRB->VALRETFU  ,"@r 9999999999999.99")) //15
        cReteICA    := u_cReteICA(TRB->ESPECIE)//Alltrim(transform(TRB->VALRETICA ,"@r 9999999999999.99")) //16
        cIVA        := u_cIVA(TRB->ESPECIE)//Alltrim(transform(TRB->VALIVA    ,"@r 9999999999999.99")) //17
        cTotal      := u_cTotal(TRB->ESPECIE) //Alltrim(transform(TRB->TOTAL     ,"@r 9999999999999.99")) //18
        cFechapago  := Alltrim(Dtos(Posicione("SE2",6,xFilial("SE2")+TRB->PROVEEDOR+TRB->LOJA+TRB->SERIE+TRB->COMPROBANTE,"E2_BAIXA")))   //19
        cValorpag   := Alltrim(transform(cValorLiq,"@r 9999999999999.99"))  // 20
        codpago     := Alltrim(u_CondP(TRB->ESPECIE))    // 21
        Termipago   := AllTrim(Posicione("SE4",1,xFilial("SE4")+u_CondP(ESPECIE),"E4_DESCRI")) //22
        cMedioPago  := u_MedPag(TRB->COMPROBANTE,TRB->PROVEEDOR,TRB->LOJA,TRB->SERIE)       // 23
        cBancoProv  := if(cMedioPago<>'',u_DescBanc(TRB->PROVEEDOR,TRB->LOJA),"") // 24
        cCtaProv    := if(cMedioPago<>'',Alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->PROVEEDOR+TRB->LOJA,"A2_NUMCON")) ,"") // 25

           
    AAdd(aDeta,{cIDNum,cNIT,cRazon,cFolio,cTipoDoc,cFechaFol,cDescripDoc,cTipoDoc2,cNumDoc,cOrdenComp,cFechaEmis,cFechaVenc,cMoneda,cSubtotal,cRetefuente,cReteICA,cIVA,cTotal,cFechapago,cValorpag,codpago,Termipago,cMedioPago,cBancoProv,cCtaProv})
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
        cString += aDeta[xI,1]+";"+aDeta[xI,2]+";"+aDeta[xI,3]+";"+aDeta[xI,4]+";"+aDeta[xI,5]+";"+aDeta[xI,6]+";"+aDeta[xI,7]+";"+aDeta[xI,8]+";"+aDeta[xI,9]+";"+aDeta[xI,10]+";"+aDeta[xI,11]+";"+aDeta[xI,12]+";"+aDeta[xI,13]+";"+aDeta[xI,14]+";"+aDeta[xI,15]+";"+aDeta[xI,16]+";"+aDeta[xI,17]+";"+aDeta[xI,18]+";"+aDeta[xI,19]+";"+aDeta[xI,20]+";"+aDeta[xI,21]+";"+aDeta[xI,22]+";"+aDeta[xI,23]+";"+aDeta[xI,24]+";"+aDeta[xI,25]
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
cNIT        := "NIT;"
cRazon      := "Razon_Social;"
cFolio      := "Folio;"
cTipoDoc    := "Tipo_DOC;"
cFechaFol   := "Fecha_Folio;"
cDescripDoc := "Descripcion_documento;" 
cTipoDoc2   := "Tipo_Documento;"
cNumDoc     := "Numero_documento;"
cOrdenComp  := "Orden_compra;"
cFechaEmis  := "Fecha_documento;"
cFechaVenc  := "Fecha_vencimiento;"
cMoneda     := "Moneda;"
cSubtotal   := "Subtotal;"
cRetefuente := "Retefuente;"
cReteICA    := "ReteICA;"
cIVA        := "IVA;"
cTotal      := "Total;"
cFechapago  := "Fecha_pago;"
cValorpag   := "Valor_pagado;"
codpago     := "cod_ter_pago;"
Termipago   := "Termino_pago;"
cMedioPago  := "Medio_Pago;"
cBancoProv  := "Banco_proveedor;"
cCtaProv    := "Cuenta_Banco_Proveedor"

cString  := cIDNum+cNIT+cRazon+cFolio+cTipoDoc+cFechaFol+cDescripDoc+cTipoDoc+cNumDoc+cOrdenComp+cFechaEmis+cFechaVenc+cMoneda+cSubtotal+cRetefuente+cReteICA+cIVA+cTotal+cFechapago+cValorpag+codpago+Termipago+cMedioPago+cBancoProv+cCtaProv

GrabaLog( cString )

Return

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

Static Function BuscaTipo(cEspecie)

Local cTipo := ""

If Alltrim(cEspecie)=='NF'
    cTipo:="33"
Elseif Alltrim(cEspecie)=='NCP'
    cTipo:="61"
ElseIf Alltrim(cEspecie)=='NDP'
    cTipo:="56"
EndIF

Return cTipo


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Tercer Proveedores               //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function Moeda(cEspecie)
Local cMoneda
Local cDescMoe

If Alltrim(cEspecie)=='NF'
    // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
    cMoneda:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_MOEDA")
    cDescMoe:= If(cMoneda=1,"COP","USD")
Elseif Alltrim(cEspecie)=='NCP'
    // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE                                                                                                 
    cMoneda:=  Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_MOEDA")
    cDescMoe:= If(cMoneda=1,"COP","USD")
ElseIf Alltrim(cEspecie)=='NDP'
    cMoneda:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_MOEDA")
    cDescMoe:= If(cMoneda=1,"COP","USD")
EndIf

Return cDescMoe

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function cSubtotal(cEspecie)

Local cSubtot

if Alltrim(cEspecie)$'NF|NDP'
    cSubtot:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_VALMERC")
Elseif Alltrim(cEspecie)=='NCP'
    cSubtot:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_VALMERC")
EndIf

Return Alltrim(transform(cSubtot,"@r 9999999999999.99")) 

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function cRetefuente(cEspecie)

Local cRetFuent

if Alltrim(cEspecie)$'NF|NDP'
    cRetFuent:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_VALIMP4")
Elseif Alltrim(cEspecie)=='NCP'
    cRetFuent:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_VALIMP4")
EndIf

Return Alltrim(transform(cRetFuent,"@r 9999999999999.99"))  

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function cReteICA(cEspecie)

Local cRetIca

if Alltrim(cEspecie)$'NF|NDP'
    cRetIca:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_VALIMP7")
Elseif Alltrim(cEspecie)=='NCP'
    cRetIca:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_VALIMP7")
EndIf

Return Alltrim(transform(cRetIca,"@r 9999999999999.99"))  

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function cIVA(cEspecie)

Local cVlIva 

if Alltrim(cEspecie)$'NF|NDP'
    cVlIva:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_VALIMP7")
Elseif Alltrim(cEspecie)=='NCP'
    cVlIva:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_VALIMP7")
EndIf

Return Alltrim(transform(cVlIva,"@r 9999999999999.99"))  

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function cTotal(cEspecie)

Local cTotFat

if Alltrim(cEspecie)$'NF|NDP'
    cTotFat:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_VALBRUT")
Elseif Alltrim(cEspecie)=='NCP'
    cTotFat:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_VALBRUT")
EndIf

Return Alltrim(transform(cTotFat,"@r 9999999999999.99"))        

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function CondP(cEspecie)

Local cCodigo 

if Alltrim(cEspecie)$'NF|NDP'
    cCodigo:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_COND")
Elseif Alltrim(cEspecie)=='NCP'
    cCodigo:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_COND")
EndIf

Return cCodigo

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function MedPag(cComprobante,cProveedor,cLoja,cSerie)

Local cQry      := ""
Local cQry2     := ""
Local cAliasSEK := GetNextAlias()
Local cAliasSEK2:= GetNextAlias()
Local cMedio    := ""
Local cTipodoc  := ""

    cQry := " SELECT EK_ORDPAGO "
	cQry += " FROM " + RetSqlName("SEK") + " "
	cQry += " WHERE D_E_L_E_T_ = ' ' AND "
	cQry += " EK_FILIAL = '" + xFilial("SEK") + "' AND "
	cQry += " EK_NUM  = '" + cComprobante + "' AND "
	cQry += " EK_FORNECE  = '" + cProveedor + "' AND "
	cQry += " EK_LOJA  = '" + cLoja+ "' AND "
	cQry += " EK_PREFIXO  = '" + cSerie + "' AND "
	cQry += " EK_CANCEL  = 'F'  "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ),cAliasSEK,.T.,.T.) 
	
    If (cAliasSEK)->(!EOF())
      
        cQry2 := "SELECT * "
	    cQry2 += " FROM " + RetSqlName("SEK") + " "
	    cQry2 += " WHERE D_E_L_E_T_ = ' ' AND "
	    cQry2 += " EK_FILIAL = '" + xFilial("SEK") + "' AND "
	    cQry2 += " EK_ORDPAGO = '" + (cAliasSEK)->EK_ORDPAGO + "' AND "
	    cQry2 += " EK_CANCEL  = 'F' AND "
	    cQry2 += " EK_TIPODOC  = 'CP'  "
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry2 ),cAliasSEK2,.T.,.T.) 
        If (cAliasSEK2)->(!EOF())
        	cTipodoc:= (cAliasSEK2)->EK_TIPO
        EndIf
        cMedio:=if(Alltrim((cAliasSEK2)->EK_TIPO)=='TF',"TRANSF","CHEQUE")
        (cAliasSEK2)->(DbCloseArea()) 
    else
        cMedio:=""
    Endif

	(cAliasSEK)->(DbCloseArea()) 

Return Alltrim(cMedio)

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo Nombre cuenta del banco          //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function DescBanc(cProveedor,cLoja)

Local cBanco
Local cDescBanc 

cBanco  :=  Alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->PROVEEDOR+TRB->LOJA,"A2_BANCO"))

if cBanco<>''

    if val(cBanco)=0
        cDescBanc:="BANCO DE LA REPUBLICA"
    elseif val(cBanco)=1
        cDescBanc:="BANCO DE BOGOTA"
    elseif val(cBanco)=2
        cDescBanc:="BANCO POPULAR"
    elseif val(cBanco)=6
        cDescBanc:="ITAU CORPBANCA COLOMBIA S.A."
    elseif val(cBanco)=7
        cDescBanc:="BANCOLOMBIA S.A."
    elseif val(cBanco)=9
        cDescBanc:="CITIBANK COLOMBIA"
    elseif val(cBanco)=12
        cDescBanc:="GNB SUDAMERIS S.A."
    elseif val(cBanco)=13
        cDescBanc:="BBVA COLOMBIA"
    elseif val(cBanco)=19
        cDescBanc:="COLPATRIA"
    elseif val(cBanco)=23
        cDescBanc:="BANCO DE OCCIDENTE"
    elseif val(cBanco)=32
        cDescBanc:="BANCO CAJA SOCIAL - BCSC S.A."
    elseif val(cBanco)=40
        cDescBanc:="BANCO AGRARIO DE COLOMBIA S.A."
    elseif val(cBanco)=51
        cDescBanc:="BANCO DAVIVIENDA S.A."
    elseif val(cBanco)=52
        cDescBanc:="BANCO AV VILLAS"
    elseif val(cBanco)=53
        cDescBanc:="BANCO W S.A."
    elseif val(cBanco)=58
        cDescBanc:="BANCO CREDIFINANCIERA S.A.C.F"
    elseif val(cBanco)=59
        cDescBanc:="BANCAMIA"
    elseif val(cBanco)=60
        cDescBanc:="BANCO PICHINCHA S.A."
    elseif val(cBanco)=61
        cDescBanc:="BANCOOMEVA"
    elseif val(cBanco)=62
        cDescBanc:="CMR FALABELLA S.A."
    elseif val(cBanco)=63
        cDescBanc:="BANCO FINANDINA S.A"
    elseif val(cBanco)=65
        cDescBanc:="BANCO SANTANDER DE NEGOCIOS COLOMBIA S.A"
    elseif val(cBanco)=66
        cDescBanc:="BANCO COOPERATIVO COOPCENTRAL"
    elseif val(cBanco)=67
        cDescBanc:="BANCO COMPARTIR S.A"
    elseif val(cBanco)=69
        cDescBanc:="BANCO SERFINANZA S.A"
    EndIf
EndIf

Return Alltrim(cDescBanc)

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: GenTerc      ||Data: 17/12/2022 ||Empresa: PROGEN         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Juan Pablo Astorga||Empresa: TOTVS   ||Módulo: Compras       //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: P.E. Generacion Archivo SUBTOTAL                         //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

User Function lhora(cEspecie) 
Local cHora2
Local cHoraCon2

if Alltrim(cEspecie)$'NF|NDP'
    cHora2:= Posicione("SF1",1,xFilial("SF1")+TRB->COMPROBANTE+TRB->SERIE+TRB->PROVEEDOR+TRB->LOJA,"F1_HORA")
Elseif Alltrim(cEspecie)=='NCP'
    cHora2:= Posicione("SF2",1,xFilial("SF2")+TRB->PROVEEDOR+TRB->LOJA+TRB->COMPROBANTE+TRB->SERIE,"F2_HORA")
EndIf

    cHoraCon2:= Substr(cHora2,1,2)+Substr(cHora2,4,2)+Substr(cHora2,7,2)

Return Alltrim(cHoraCon2)


