#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: TFBANC
Titulo	: TF - CREDICORP
Fecha	: 29/11/202023
Autor 	: Juan Pablo Astorga 
Descripcion : Transferencia Bancaria Credicorp
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

User Function TFBANCRE()

    Local lSigue 		:= .T.
    Private cPerg 		:= "TFBANCRE"
    PRIVATE cAliasSEK	:= 	GetNextAlias()//"SEK"
    Private nTotReg 	:= 0
    MakeDir("C:\TOTVS")
    MakeDir("C:\TOTVS\INTEGRACION_BANCOS")


    AjustaSX1(cPerg)

    If !Pergunte(cPerg,.T.)
        Return
    EndIf

    If MV_PAR01 <> 'TF' //Forma de Pago
        MsgAlert("Forma de Pago inválida") //"Forma de pago Invalida
        lSigue := .F.
    End if

    dbSelectArea("SA6")
    dbSetOrder(1)
    If !DbSeek(xFilial("SA6")+mv_par02+mv_par03+mv_par04)//Banco,Agencia,Cuenta
        MSGINFO(OemToAnsi("Banco Inexistente, "),OemToAnsi("Imposible continuar"))
        lSigue:=.F.
    Else
        cTipoCtaB := "02" //Cuenta de Administración de Valores
    Endif

    //no fue infomado el nombre del archivo
    IF Empty(mv_par10)//Nombre archivo
        MSGINFO("Debe informar el nombre del archivo (ejemplo = pagoProveedores.txt)","Control de datos")
        lSigue:=.F.
    ENDIF

    //no fue infomado la ruta del archivo
    IF Empty(mv_par09)//Ruta del archivo
        MSGINFO("Debe informar la carpeta destino del archivo ( ejemplo =   C:\TOTVS\ ) ","Control de datos")
        lSigue:=.F.
    ENDIF

    If lSigue
        cFechaGen:=DTOS(dDatabase)
        //Controla nombre del archivo, agregando datos de la empresa
        IF '.TXT' $ UPPER(mv_par10)
            cFile := cFilAnt+"_"+ALLTRIM(SM0->M0_FILIAL)+'_'+Alltrim(mv_par10)
        ELSE
            cFile := cFilAnt+"_"+ALLTRIM(SM0->M0_FILIAL)+'_'+Alltrim(mv_par10) + '.txt'
        ENDIF

        //Controla ruta del archivo
        cPath:=ALLTRIM(MV_PAR09)
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
    End if

    IF lSigue


        cNtxTmp := CriaTrab( , .f. )
        cSEK := RetSqlName('SEK')
        cSA2 := RetSqlName('SA2')

        cQuery := "SELECT EK_EMISSAO, EK_FORNECE, EK_ORDPAGO, EK_VALOR, A2_NOME, EK_LOJA, EK_BANCO, EK_AGENCIA, EK_CONTA, EK_LA , EK_NUM "
        cQuery += "FROM " +cSEK
        cQuery += " INNER JOIN "+ cSA2 + " ON " + cSEK + ".EK_FORNECE = " + cSA2 + ".A2_COD AND "
        cQuery += cSEK + ".EK_LOJA = " + cSA2 + ".A2_LOJA "
        cQuery += "WHERE " +cSEK+".EK_FILIAL = '" + xFilial("SEK") + "'  AND "
        cQuery += cSEK+".EK_ORDPAGO BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND "
        cQuery += cSEK+".EK_TIPO = 'TF ' AND "+cSEK+".EK_BANCO = '" + mv_par02 + "' AND "
        cQuery += cSek+".EK_LA <> 'C' AND "
        cQuery += cSEK+".EK_AGENCIA = '" + mv_par03 + "' AND "+cSEK+".EK_CONTA = '" + mv_par04 + "' AND "
        cQuery += cSEK+".EK_EMISSAO BETWEEN '"+dTos(mv_par05)+"' AND '"+dTos(mv_par06) + "' AND "
        cQuery += cSEK+".D_E_L_E_T_ <> '*' AND "
        cQuery += cSA2+".D_E_L_E_T_ <> '*' AND " + cSEK+".EK_TIPODOC = 'CP' AND 'TF' = '"+mv_par01+"' "

        cQuery   := ChangeQuery( cQuery )
        dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)


        TCSetField( 'TRB', 'EK_EMISSAO'  , 'D',8, 0 )
        TCSetField( 'TRB', 'EK_VALOR'    , 'N',15, 2 )


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

        IndRegua("TRB",cNtxTmp,'EK_ORDPAGO',,,"Indexando Registros...")
        cCadastro := OemToAnsi("Generacion de archivo para Transferencia Bancaria Crediscorp")
        DbSelectArea("TRB")
        DbGoTop()

        U_GenPago2()

        DbUnlockAll()
        DbSelectArea( 'TRB' )
        DbCloseArea()
        FErase( cNtxTmp + OrdBagExt() )

        FClose( nHnd )

    ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   GenPago  ³ Autor ³                      ³ Data ³ 29/11/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.   ³ Generacion del archivo para mandar al Banco.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Transferencia Bancaria                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GenPago2

    Local cFilSA2       := xFilial('SA2')
    Local nRecno        := REcno()
    Local aArea         := GetArea()
    Local lGenPay       := .F.
    Local nConsec       := 0
    Local IdLinea       := "2"
    Local cRellen       := "000000"
    Local cNitOrde      := "0860016310"
    Local cAo           := str(Year(TRB->EK_EMISSAO),4)
    Local cMes          := Strzero(Month(TRB->EK_EMISSAO),2)
    Local cDia          := Strzero(Day(TRB->EK_EMISSAO),2)
    Local cTipoPago     := "1"
    Local cNumeroCompr  := ""
    Private nSecuen     := 0
    Private nTotPag     := 0
    Private nTot        := 0

    DbSelectArea("TRB")
    DbGoTop()
    While !EOF()
        nTot += TRB->EK_VALOR
        DbSkip()
    End do

    DbSelectArea("TRB")
    DbGoTop()

    GenPago2(nTot) //Encabezado

    
    //Detalles
    While !EOF()
        nSecuen ++
        aDeta := { }
            cBenef   := Substr(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_NOME"),1,30)
        if empty(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_CGC"))
            cNit        := StrZero(Val(Alltrim(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_PFISICA"))),11)			//cNit	 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_CGC")
        elseif empty(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_PFISICA"))
            cNit        := StrZero(Val(Alltrim(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA,"A2_CGC"))),11)
        EndIF
            cCodCtaB 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_BANCO")	    //codigo banco del proveedor de acuerdo a las tablas de crediscorp.
            cBcoDest 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_NUMCON")	    //A2_XNUMCON
            cCcCAho     := Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XTPCONT")    //A2_XTPCONT (S=AHORROS; D=CORRIENTE)		// tipo de cuenta (1=corriente; 2=ahorros)

            If cCcCAho == 'D'
                cCcCAho := 'C'  //cuenta corriente
            ElseIf cCcCAho == 'S'
                cCcCAho := 'A' //cuenta de ahorros
            Else
                cCcCAho := ' '
            Endif
        cNumeroCompr:=TRB->EK_ORDPAGO
        cRef        := MV_PAR11
        AAdd( aDeta,{ IdLinea , Strzero(nSecuen,4) ,cNitOrde  , cRellen , cBenef , cNit ,"0"+cCodCtaB,cAo,cMes,cDia,cTipoPago,Strzero(TRB->EK_VALOR*100,15),Strzero(Val(cBcoDest),16),Strzero(Val(cNumeroCompr),12),cCcCAho,mv_par11 })

        If Len(aDeta) > 0
            GenDeta(aDeta)
        EndIf
        DbSkip()
    Enddo

     GenPago3(nTot,nSecuen) // Final del archivo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³  GenPago  ³ Autor ³ Yamila Mikati         ³ Data ³ 25/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.   ³ Generacion del registro de pago.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Transferencia Bancaria                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GenPago2(nTot)

    cTipo    	:= "1"
    cConteo     := "0000"
    cAño        := str(Year(dDatabase),4)
    cMes        := Strzero(Month(dDatabase),2)
    cDia        := Strzero(Day(dDatabase),2)
    cCtaDisper  := Space( 16 )
    cRelleno    := StrZero(0,100)+StrZero(0,36)
    cCtaPpal 	:= Posicione("SA6",1,xFilial("SA6") + TRB->EK_BANCO + TRB->EK_AGENCIA + TRB->EK_CONTA,"A6_NUMCON")
    cNitEnt  	:= "0860016310"
    cPropTrans 	:= MV_PAR11

    cString  := cTipo + cConteo + cAño + cMes + cDia + Strzero(nTot,18) + cNitEnt + cTipoCtaB + cCtaDisper + cRelleno

    GrabaLog( cString )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³  GenDeta  ³ Autor ³ Yamila Mikato		   ³ Data ³ 25/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.   ³ Generacion del registro de Detalle.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Transferencia Bancaria                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GenDeta(aDeta)

    Local cString := ""
    Local xI:=""
    FOR xI := 1 TO Len(aDeta)

        /*
   cString := aDeta[xI,1]
   cString += Strzero(Val(SubStr(aDeta[xI,2],1,15)),15)
   cString += SubStr(aDeta[xI,3],1,18)
   cString += aDeta[xI,4]
   cString += Strzero(Val(aDeta[xI,5]),17)
   cString += aDeta[xI,6] + aDeta[xI,7] + aDeta[xI,8] +aDeta[xI,9] + aDeta[xI,10] +aDeta[xI,11]
        */
        cString += aDeta[xI,1] + aDeta[xI,2] + aDeta[xI,3] +aDeta[xI,4] + aDeta[xI,5] +aDeta[xI,6]+ aDeta[xI,7] + aDeta[xI,8] +aDeta[xI,9] + aDeta[xI,10] +aDeta[xI,11]+ aDeta[xI,12] + aDeta[xI,13] + aDeta[xI,14] + aDeta[xI,15] + aDeta[xI,16] 
        GrabaLog( cString )


    NEXT

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n     ³ GrabaLog³ Autor ³ Yamila Mikati		 ³ Data ³ 25/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripci¢n ³ Genera el Log de las migraciones...                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ MultiMig                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrabaLog( cString )

    FWrite( nHnd, cString + Chr(13) + Chr(10) )

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: AjustaSX1
Titulo	:
Fecha	: 25/01/2013
Autor 	: Mikati Yamila
Descripcion :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AjustaSX1(cPerg)
    Local aArea := GetArea()
    Local aRegs := {}, i, j

    cPerg := Padr(cPerg,Len(SX1->X1_GRUPO))

    DbSelectArea("SX1")
    DbSetOrder(1)


    aAdd(aRegs,{cPerg,"01","Forma de Pago 		","Forma de Pago 	","Forma de Pago  	","mv_ch1","C",02,0,0,"G","","MV_PAR01","","","","TF","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"02","Banco ?"            ,"Banco ?"            ,"Banco ?"            ,"mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA6","",""})
    aAdd(aRegs,{cPerg,"03","Agencia ?"          ,"Agencia ?"          ,"Agencia ?"          ,"mv_ch3","C",05,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"04","Cuenta ?"           ,"Cuenta ?"           ,"Cuenta ?"           ,"mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"05","De Fecha de OP		","De Fecha de OP 	","De Fecha de OP  	","mv_ch5","D",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"06","A Fecha de OP		","A Fecha de OP 	","A Fecha de OP  	","mv_ch6","D",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"07","De Numero de OP 		","De Numero de OP 	","De Numero de OP  	","mv_ch7","C",12,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"08","A Numero de OP 		","A Numero de OP 	","A Numero de OP  	","mv_ch86","C",12,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"09","Ruta del Archivo","Ruta del Archivo","Ruta del Archivo","mv_ch9","C",60,0,0,"G","","MV_PAR09","","","","C:\TOTVS\TF","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"10","Nombre del Archivo","Nombre del Archivo","Nombre del Archivo","mv_chA","C",20,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"11","Descrip Propósito Trans","Descrip Propósito Trans","Descrip Propósito Trans","mv_chB","C",80,0,0,"G","","MV_PAR11","","","","PAGO PROV ","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"12","Fecha Aplicación del Pago	","Fecha Aplicación del Pago 	","Fecha Aplicación del Pago  	","mv_chC","D",08,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )

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

/*------------------------------------------------
Funcion para validar carateres especiales para XML
Ej Uso:
cCampo := xValCar(cDato)
-------------------------------------------------*/

User Function ValCar(cDato1)
Local cValFin1 := cDato1
Local aArea := getArea()
//Caracteres Especiales
cValFin1 := StrTran(cValFin1,"&","")
cValFin1 := StrTran(cValFin1,'"',"")
cValFin1 := StrTran(cValFin1,"'","")
cValFin1 := StrTran(cValFin1,"<","")
cValFin1 := StrTran(cValFin1,">","")
cValFin1 := StrTran(cValFin1,".","")
cValFin1 := StrTran(cValFin1,"-","")
cValFin1 := StrTran(cValFin1,"_","")
//Otros Caracteres
cValFin1 := StrTran(cValFin1,"á","a") 
cValFin1 := StrTran(cValFin1,"é","e")
cValFin1 := StrTran(cValFin1,"í","i")
cValFin1 := StrTran(cValFin1,"ó","o")
cValFin1 := StrTran(cValFin1,"ú","u") 
cValFin1 := StrTran(cValFin1,"Á","A") 
cValFin1 := StrTran(cValFin1,"É","E")
cValFin1 := StrTran(cValFin1,"Í","I")
cValFin1 := StrTran(cValFin1,"Ó","O")
cValFin1 := StrTran(cValFin1,"Ú","U") 

RestArea(aArea)

Return(cValFin1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄ-ÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³  GenPago  ³ Autor ³ Yamila Mikati         ³ Data ³ 25/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.   ³ Generacion del registro de pago.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Transferencia Bancaria                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GenPago3(nTot,nSecuen)

    cIdLinea2   := "3"
    cConteoFin  := "9999"
    cSecuencia  := nSecuen
    cRelleno2   := StrZero(0,100)+StrZero(0,22)

    cString  := cIdLinea2 + cConteoFin + Strzero(cSecuencia,4) + Strzero(nTot,18) + cRelleno2

    GrabaLog( cString )

Return
