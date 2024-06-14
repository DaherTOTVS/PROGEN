#INCLUDE "PROTHEUS.CH"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Programa: TFBANC
Titulo	: TF - BANCOLOMBIA
Fecha	: 13/12/2016
Autor 	:
Descripcion : Transferencia Bancaria Bancolombia
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹*/


/*
Modificado por Gabriel Pulido
Se adiciona validacion para validar dato de NIT o dato del
*/


User Function TFBANC()

    Local lSigue 		:= .T.
    Private cPerg 		:= "TFBANC"
    PRIVATE cAliasSEK	:= 	GetNextAlias()//"SEK"
    Private nTotReg 	:= 0
    MakeDir("C:\TOTVS")
    MakeDir("C:\TOTVS\INTEGRACION_BANCOS")


    AjustaSX1(cPerg)

    If !Pergunte(cPerg,.T.)
        Return
    EndIf

    If MV_PAR01 <> 'TF' //Forma de Pago
        MsgAlert("Forma de Pago inv·lida") //"Forma de pago Invalida
        lSigue := .F.
    End if

    dbSelectArea("SA6")
    dbSetOrder(1)
    If !DbSeek(xFilial("SA6")+mv_par02+mv_par03+mv_par04)//Banco,Agencia,Cuenta
        MSGINFO(OemToAnsi("Banco Inexistente, "),OemToAnsi("Imposible continuar"))
        lSigue:=.F.
    Else
        /*
	cTipoCtaB := Substr(SA6->A6_CLASENT,1,1) //a6_XTPCONT
    If(cTipoCtaB == '1')
      cTipoCtaB := "D"
    ElseIf(cTipoCtaB == '2')
      cTipoCtaB := "S"
    Else
      cTipoCtaB := " "
    Endif
        */
        cTipoCtaB := Substr(SA6->A6_XTPCONT,1,1) //a6_XTPCONT (Tipo de cuenta)
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

        cQuery := "SELECT EK_EMISSAO, EK_FORNECE, EK_ORDPAGO, EK_VALOR, A2_NOME, EK_LOJA, EK_BANCO, EK_AGENCIA, EK_CONTA, EK_LA "
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
        cCadastro := OemToAnsi("Generacion de archivo para Transferencia Bancaria")
        DbSelectArea("TRB")
        DbGoTop()

        U_GenPago()

        DbUnlockAll()
        DbSelectArea( 'TRB' )
        DbCloseArea()
        FErase( cNtxTmp + OrdBagExt() )

        FClose( nHnd )

    ENDIF

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ-¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥   GenPay  ≥ Autor ≥ Yamila Mikati         ≥ Data ≥ 25/01/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.   ≥ Generacion del archivo para mandar al Banco.                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ Transferencia Bancaria                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function GenPago
    Local cFilSA2  := xFilial('SA2'),;
        nRecno   := REcno(),;
        aArea    := GetArea(),;
        lGenPay  := .F.,;
        nConsec  := 0,;
        cTipo    := "6"
    Private nSecuen := 0,;
        nTotPag := 0,;
        nTot := 0




    DbSelectArea("TRB")
    DbGoTop()
    While !EOF()
        nTot += TRB->EK_VALOR
        DbSkip()
    End do

    DbSelectArea("TRB")
    DbGoTop()

    GenPago(nTot) //Encabezado


    //Detalles
    While !EOF()
        aDeta := { }
        //  cBenef   := Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_NOME")
        cProvBenf   := Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XBENEF")
        cLoja2      := Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XLOJBEN")
        //Midificacion GAP
    iF Empty(cProvBenf)
            cBenef   	:= u_ValCarPro(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA,"A2_NOME"))
                if empty(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_CGC"))
                    cNit        := StrZero(Val(Alltrim(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_PFISICA"))),15)			//cNit	 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_CGC")
                elseif empty(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_PFISICA"))
                    cNit        := StrZero(Val(Substr(Alltrim(Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA,"A2_CGC")),1,9)),15)
                EndIF
            cCodCtaB 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XCDBNCO")	 //A2_XCDBNCO		//codigo banco del proveedor de acuerdo a las tablas de bancolombia
            cBcoDest 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_NUMCON")	     //A2_XNUMCON
            cCcCAho     := Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XTPCONT")     //A2_XTPCONT (S=AHORROS; D=CORRIENTE)		// tipo de cuenta (1=corriente; 2=ahorros)

            If cCcCAho == 'D'
                cCcCAho := '27'  //cuenta corriente
            ElseIf cCcCAho == 'S'
                cCcCAho := '37' //cuenta de ahorros
            Else
                cCcCAho := '  '
            Endif
            cConcepto   := "         "
    else
        cBenef   	:= u_ValCarPro(Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_NOME"))
            if empty(Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_CGC"))
                cNit        := StrZero(Val(Alltrim(Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2,"A2_PFISICA"))),15)	//cNit	 	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_CGC")
            elseif empty(Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_PFISICA"))
                cNit        := StrZero(Val(Substr(Alltrim(Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_CGC")),1,9)),15)
            EndIF
        cCodCtaB 	:= Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_XCDBNCO") //A2_XCDBNCO		//codigo banco del proveedor de acuerdo a las tablas de bancolombia
        cBcoDest 	:= Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_NUMCON")	 //A2_XNUMCON
        cCcCAho     := Posicione("SA2",1, xFilial("SA2") + cProvBenf + cLoja2, "A2_XTPCONT") //A2_XTPCONT (S=AHORROS; D=CORRIENTE)		// tipo de cuenta (1=corriente; 2=ahorros)

        If cCcCAho == 'D'
            cCcCAho := '27'  //cuenta corriente
        ElseIf cCcCAho == 'S'
            cCcCAho := '37' //cuenta de ahorros
        Else
            cCcCAho := '  '
        Endif
        cConcepto   := "         "
    EndIf
        //cReferencia := "               "
        /*cReferencia	:= "FAC:" + Posicione("SEK",1,xFilial("SEK") + TRB->EK_ORDPAGO + "TB", "EK_NUM")
        cRelleno    := "                           "
        cFecAplic  	:= DTOS(MV_PAR12)
        cTpessoa	:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_XDOCIDN")
        cEmail		:= Posicione("SA2",1, xFilial("SA2") + TRB->EK_FORNECE + TRB->EK_LOJA, "A2_EMAIL")*/
        cReferencia := ""
        cRelleno    := ""
        cFecAplic  	:= ""
        cTpessoa	:= ""
        cEmail		:= ""
        cRef        := MV_PAR11
        //AAdd( aDeta,{cTipo, cNit, cBenef,cCodCtaB, cBcoDest, "S", "27", Strzero((TRB->EK_VALOR)*100,10), "         ","            "," "})
        //AAdd( aDeta,{cTipo, cNit, cBenef,cCodCtaB, cBcoDest, "S", "27", Strzero((TRB->EK_VALOR),10), cConcepto , cReferencia , cRelleno })
        //AAdd( aDeta,{cTipo, PADR('00000' + left(cNit,10),15,' '), PADR(cBenef,30,' '),cCodCtaB, PADR(cBcoDest,17,' '), "1", cCcCAho , Strzero((TRB->EK_VALOR * 100),17), cFecAplic, PADR(cReferencia,21,' ') /*'REFERENCIA           '*/,/*TIPO ID*/cTpessoa , '00001' , '               ' ,/*EMAIL*/PADR(cEmail,80,' ') , "               " , cRelleno })
        //AAdd( aDeta,{cTipo, PADR('00000' + left(cNit,10),15,' '), PADR(cBenef,30,' '),cCodCtaB, Strzero(Val(cBcoDest),17), "S", cCcCAho , Strzero((TRB->EK_VALOR * 100),17), cFecAplic, PADR(cReferencia,21,' ') /*'REFERENCIA           '*/,/*TIPO ID*/cTpessoa ,'', '               ' ,/*EMAIL*/PADR(cEmail,80,' ') , "               " , cRelleno })
        //AAdd( aDeta,{cTipo, PADR('00000' + left(cNit,10),15,' '), PADR(cBenef,18,' '),cCodCtaB, Strzero(Val(cBcoDest),17), "S", cCcCAho , Strzero(TRB->EK_VALOR,10), cRef, PADR(cReferencia,21,' ') /*'REFERENCIA           '*/,/*TIPO ID*/cTpessoa ,'', '               ' ,/*EMAIL*/PADR(cEmail,80,' ') , "               " , cRelleno })
        AAdd( aDeta,{cTipo, cNit  , PADR(cBenef,18,' '),cCodCtaB, Strzero(Val(cBcoDest),17), "S", cCcCAho , Strzero(TRB->EK_VALOR,10), cRef, PADR(cReferencia,21,' ') /*'REFERENCIA           '*/,/*TIPO ID*/cTpessoa ,'', '               ' ,/*EMAIL*/PADR(cEmail,80,' ') , "               " , cRelleno })



        If Len(aDeta) > 0
            GenDeta(aDeta)
        EndIf
        DbSkip()
    End do

Return



/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ-¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥  GenPago  ≥ Autor ≥ Yamila Mikati         ≥ Data ≥ 25/01/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.   ≥ Generacion del registro de pago.                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ Transferencia Bancaria                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GenPago(nTot)

    //cFecEmi  	:= SUBSTR(str(Year(dDatabase),4),3,2)+ Strzero(Month(dDatabase),2) + Strzero(Day(dDatabase),2)
    cFecEmi  	:= SUBSTR(str(Year(dDatabase),4),3,2)+ Strzero(Month(dDatabase),2) + Strzero(Day(dDatabase),2)//DTOS(dDatabase)
    //cFecAplic  := SUBSTR(str(Year(MV_PAR12),4),3,2)+ Strzero(Month(MV_PAR12),2) + Strzero(Day(MV_PAR12),2)
    cFecAplic  	:= SUBSTR(str(Year(dDatabase),4),3,2)+ Strzero(Month(dDatabase),2) + Strzero(Day(dDatabase),2) //DTOS(MV_PAR12)
    cTipo    	:= "1"
    cCtaPpal 	:= Posicione("SA6",1,xFilial("SA6") + TRB->EK_BANCO + TRB->EK_AGENCIA + TRB->EK_CONTA,"A6_NUMCON")
    //cCtaPpal 	:= Posicione("SA6",1,xFilial("SA6") + TRB->EK_BANCO + TRB->EK_AGENCIA + TRB->EK_CONTA,"A6_OYCTACM")
    cNitEnt  	:= "0860016310"
    cNomEnt  	:= "PROGEN SA"
    cClase   	:="220"
    //cEnvio   	:= "1"
    cEnvio   	:= "B"
    cPropTrans 	:= MV_PAR11

    //cString  := cTipo + cNitEnt + cNomEnt + cClase+ cPropTrans + cFecEmi + cEnvio+ cFecAplic + Strzero(nTotReg,6)  + Strzero(0,12)+ Strzero((nTot)*100,12) +  SubStr(cCtaPpal,1,11) +"D"
    //estructura SAP//cString  := cTipo + cNitEnt + cNomEnt + cClase+ cPropTrans + cFecEmi + cEnvio+ cFecAplic + Strzero(nTotReg,6)  + Strzero(0,12)+ Strzero((nTot),12) +  SubStr(cCtaPpal,1,11) +cTipoCtaB
    // cString  := cTipo + cNitEnt + 'I' + '               ' + cClase + /*'PAGO DE PR'*/cPropTrans + cFecEmi + cEnvio+ cFecAplic + Strzero(nTotReg,6)  + Strzero(0,17)+ Strzero((nTot * 100),17) +  SubStr(cCtaPpal,1,11) + cTipoCtaB + '                                                                                                                                                     '
    //cString  := cTipo + cNitEnt +PADR(cNomEnt,16,'')+ cClase + /*'PAGO DE PR'*/cPropTrans + cFecEmi + cEnvio+ cFecAplic + Strzero(nTotReg,6)  + Strzero(0,17)+ Strzero((nTot * 100),17) +  SubStr(cCtaPpal,1,11) + cTipoCtaB + '                                                                                                                                                     '
    cString  := cTipo + cNitEnt +PADR(cNomEnt,16,'')+ cClase + /*'PAGO DE PR'*/cPropTrans + cFecEmi + cEnvio+ cFecAplic + Strzero(nTotReg,6)  + Strzero(0,7)+ Strzero(nTot,17) +  SubStr(cCtaPpal,1,11) + cTipoCtaB + '                                                                                                                                                     '

    GrabaLog( cString )

Return


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ-¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥  GenDeta  ≥ Autor ≥ Yamila Mikato		   ≥ Data ≥ 25/01/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.   ≥ Generacion del registro de Detalle.                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ Transferencia Bancaria                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ-¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
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
        cString += aDeta[xI,1] + aDeta[xI,2] + aDeta[xI,3] +aDeta[xI,4] + aDeta[xI,5] +aDeta[xI,6]+ aDeta[xI,7] + aDeta[xI,8] +aDeta[xI,9] + aDeta[xI,10] +aDeta[xI,11]+ aDeta[xI,12] + aDeta[xI,13] +aDeta[xI,14] + aDeta[xI,15] +aDeta[xI,16]
        GrabaLog( cString )


    NEXT

Return




/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funci¢n     ≥ GrabaLog≥ Autor ≥ Yamila Mikati		 ≥ Data ≥ 25/01/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descripci¢n ≥ Genera el Log de las migraciones...                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso         ≥ MultiMig                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GrabaLog( cString )

    FWrite( nHnd, cString + Chr(13) + Chr(10) )

Return


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Programa: AjustaSX1
Titulo	:
Fecha	: 25/01/2013
Autor 	: Mikati Yamila
Descripcion :
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹*/
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
    aAdd(aRegs,{cPerg,"11","Descrip PropÛsito Trans","Descrip PropÛsito Trans","Descrip PropÛsito Trans","mv_chB","C",10,0,0,"G","","MV_PAR11","","","","PAGO PROV ","","","","","","","","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"12","Fecha AplicaciÛn del Pago	","Fecha AplicaciÛn del Pago 	","Fecha AplicaciÛn del Pago  	","mv_chC","D",08,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )

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

User Function ValCarPro(cDato1)
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
cValFin1 := StrTran(cValFin1,"·","a") 
cValFin1 := StrTran(cValFin1,"È","e")
cValFin1 := StrTran(cValFin1,"Ì","i")
cValFin1 := StrTran(cValFin1,"Û","o")
cValFin1 := StrTran(cValFin1,"˙","u") 
cValFin1 := StrTran(cValFin1,"¡","A") 
cValFin1 := StrTran(cValFin1,"…","E")
cValFin1 := StrTran(cValFin1,"Õ","I")
cValFin1 := StrTran(cValFin1,"”","O")
cValFin1 := StrTran(cValFin1,"⁄","U") 

RestArea(aArea)

Return(cValFin1)
