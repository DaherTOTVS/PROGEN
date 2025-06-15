#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDCLIE                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST Clientes                                       !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDALMAC encargada de realizar la consulta         !
!                  ! y adicion de Clientes                                   !
!                  !                                                         !
!                  !   1. Consulta de Cartera                                !
!                  !   * Filtra por RUC, Nombre                              !
!                  !   * Adiciona nuevo cliente Execauto MATA030             !
+------------------+---------------------------------------------------------+
! Ejemplo JSSON metodo POST                                                  !
!    "CLIENTE": {                                                            !
!        "cod":"1010190095",                                                 !
!        "loja":"01",                                                        !
!        "nome":"GABRIEL ALEJANDRO PULIDO ACEVEDO",                          !
!        "dire":"CALLE 152B NO 104 50",                                      !
!        "esta":"109",                                                       !
!        "muni":"10901",                                                     !
!        "nature":"OTROS",                                                   !
!        "tpdoc":"01",                                                       !
!        "vende":"000001",                                                   !
!        "condi":"010",                                                      !
!        "mail":"GABRIEL.PULIDO@TOTVS.COM",                                  !
!        "telef":"3107587205"                                                !
!	     }                                                                   !
!     }                                                                      !
!                                                                            !
+------------------+---------------------------------------------------------+
!Autor             ! Gabriel Alejandro Pulido                                !
+------------------+---------------------------------------------------------+
!Fecha creacion    !  01-2022                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACIONES                                                           !
+-------------------------------------------+-----------+-----------+--------+
!Descripcion detallada de la actualizacion  !Nombre del ! Analista  !FEcha de!
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
|________________________________________________________________________________________|
|   //////  //////  //////  //    //  //////  | Developed For Protheus by TOTVS          |
|    //    //  //    //     //   //  //       | ADVPL                                    |
|   //    //  //    //      // //   //////    | TOTVS Technology                         |
|  //    //  //    //       ////       //     | Gabriel Alejandro Pulido -TOTVS Colombia.|
| //    //////    //        //    //////      | gabriel.pulido@totvs.com                 |
|_____________________________________________|__________________________________________|
|          _______   _______  _________    _______   _______   _______  _________        |
|         (  ___  ) (  ____ ) \__   __/   (  ____ ) (  ____ \ (  ____ \ \__   __/        |
|         | (   ) | | (    )|    ) (      | (    )| | (    \/ | (    \/    ) (           |
|         | (___) | | (____)|    | |      | (____)| | (__     | (_____     | |           |
|         |  ___  | |  _____)    | |      |     __) |  __)    (_____  )    | |           |
|         | (   ) | | (          | |      | (\ (    | (             ) |    | |           |
|         | )   ( | | )       ___) (___   | ) \ \__ | (____/\ /\____) |    | |           |
|         |/     \| |/        \_______/   |/   \__/ (_______/ \_______)    )_(           |
|________________________________________________________________________________________|
|                                                                                        |
|           ##     ## ######## ########  #######  ########   #######   ######    ##      |
|           ###   ### ##          ##    ##     ## ##     ## ##     ## ##    ##  ####     |
|           #### #### ##          ##    ##     ## ##     ## ##     ## ##         ##      |
|           ## ### ## ######      ##    ##     ## ##     ## ##     ##  ######            |
|           ##     ## ##          ##    ##     ## ##     ## ##     ##       ##   ##      |
|           ##     ## ##          ##    ##     ## ##     ## ##     ## ##    ##  ####     |
|           ##     ## ########    ##     #######  ########   #######   ######    ##      |
|                                                                                        |
|                                                                                        |
|                ######   ######## ########                                              |
|               ##    ##  ##          ##                                                 |
|               ##        ##          ##                                                 |
|               ##   #### ######      ##                                                 |
|               ##    ##  ##          ##                                                 |
|               ##    ##  ##          ##    ###                                          |
|                ######   ########    ##    ###                                          |
|                                                                                        |
|               ########   #######   ######  ########                                    |
|               ##     ## ##     ## ##    ##    ##                                       |
|               ##     ## ##     ## ##          ##                                       |
|               ########  ##     ##  ######     ##                                       |
|               ##        ##     ##       ##    ##                                       |
|               ##        ##     ## ##    ##    ##    ###                                |
|               ##         #######   ######     ##    ###                                |
|                                                                                        |
|                                                                                        |
|----------------------------------------------------------------------------------------|
|                          _==/                             \==                          |
|                         /XX/            |\___/|            \XX\                        |
|                       /XXXX\            |XXXXX|            /XXXX\                      |
|                      |XXXXXX\_         _XXXXXXX_         _/XXXXXX|                     |
|                      XXXXXXXXXXXxxxxxxxXXXXXXXXXXXxxxxxxxXXXXXXXXXXX                   |
|                     |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|                  |
|                     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                  |
|                     |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|                  |
|                      XXXXXX/^^^^"\XXXXXXXXXXXXXXXXXXXXX/^^^^^\XXXXXX                   |
|                      |XXX|       \XXX/^^\XXXXX/^^\XXX/       |XXX|                     |
|                        \XX\       \X/    \XXX/    \X/       /XX/                       |
|                           "\       "      \X/      "       /"                          |
|________________________________________________________________________________________|
|                          //       ////    //   //   //////   //                        |
|                        // //     //  //   //  //   //  //   //                         |
|                       //  //    //  //    // //   //////   //                          |
|                      ///////   //  //     ////   //       //                           |
|                     //    //  ////        //    //       ///////                       |
|_______________________________________________________________________________________*/



WSRESTFUL UANDCLIE DESCRIPTION "Servicio API Rest Para la consulta / Modificacion de cClients del Sistema |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de todos los cClients o Filtra por un Dato."             WSSYNTAX "/VercClient"     PATH "/VercClient"
    WSMETHOD POST        DESCRIPTION "Crea un nuevo cClient en el sistema Protheus  "                          WSSYNTAX "/CrecClient"     PATH "/CrecClient"    // Crea un Nuevo Producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDCLIE
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0

Default Self:Cod        := ''
Default Self:Page       := 1
//Default Self:PageSize   := 10


::SetContentType("application/json")
cAlias := GetNextAlias()
cQuery := " SELECT  "
cQuery += " SA1.A1_COD , "
cQuery += " SA1.A1_LOJA , "
cQuery += " SA1.A1_NOME , "
cQuery += " SA1.A1_CGC , "
cQuery += " SA1.A1_EMAIL  , "
cQuery += " SA1.A1_TEL   , "
cQuery += " SA1.A1_VEND  , "
cQuery += " SA1.A1_FILIAL, "
cQuery += " SA1.A1_TABELA, "
// cQuery += " SA1.A1_TIPDOC, "
cQuery += " SA1.A1_END, "
cQuery += " SA1.A1_SALDUP, "
cQuery += " SA1.A1_LC, "
cQuery += " SA1.A1_GRPVEN, "
cQuery += " SA1.A1_ESTADO, "
cQuery += " SA1.A1_BAIRRO, "
cQuery += " SA1.A1_MUN, "
cQuery += " SA1.A1_COND, "
cQuery += " SA1.A1_EST, "
cQuery += " SA1.A1_COD_MUN, "
cQuery += "  SA1.A1_CONTATO "
cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
cQuery += " WHERE "
cQuery += " SA1.A1_FILIAL   = '"+xFilial("SA1")+"' "
cQuery += " AND SA1.D_E_L_E_T_ <> '*' AND SA1.A1_MSBLQL = '2' "
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( SA1.A1_COD LIKE '%" + cCod + "%' OR "
    cQuery += " SA1.A1_CGC LIKE '%" + cCod + "%' OR "
    cQuery += " SA1.A1_NOME LIKE '%" + cCod + "%' ) "
EndIF
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery, cAlias)
If (cAlias)->(!Eof())
    Count To nRecord
    IF Self:Page > 1
        nStart  := ((Self:Page-1)*Self:PageSize)+1
        nReg    := nRecord-nStart+1
    ELSE
        nReg := nRecord
    EndIF
    (cAlias)->(dbGoTop())
    IF nReg > Self:PageSize
        oResponse['hasNext'] := .T.
    ELSE
        oResponse['hasNext'] := .F.
    EndIF
    While (cAlias)->(!Eof())
        nCount++
        IF nCount >= nStart
            nAux++
            oTask := JsonObject():New()
            oTask['branch']          := (cAlias)->A1_FILIAL                          //Filial
            oTask['code']            := (cAlias)->A1_COD                             //Codigo
            oTask['name']            := Alltrim( EncodeUTF8((cAlias)->A1_NOME))   //Nombre
            oTask['store']           := Alltrim( EncodeUTF8((cAlias)->A1_LOJA))   //Tienda
            oTask['ruc']             := (cAlias)->A1_CGC                             //RUC
            oTask['email']           := Alltrim( EncodeUTF8((cAlias)->A1_EMAIL))                           //correo electronico
            oTask['phone']           := (cAlias)->A1_TEL                             //Telefono
            oTask['seller']          := (cAlias)->A1_VEND                            //Vendedor
            oTask['pricelist']       := (cAlias)->A1_TABELA                          //Tabla Precios
            // oTask['doctype']         := (cAlias)->A1_TIPDOC                          //Tipo Documento
            oTask['customeraddress'] := Alltrim( EncodeUTF8((cAlias)->A1_END))                            //Direccion
            oTask['unpaidbalance']   := (cAlias)->A1_SALDUP                          //Saldo Pendiente
            oTask['creditlimit']     := (cAlias)->A1_LC                              //Limite de Credito
            oTask['salesgroup']      := (cAlias)->A1_GRPVEN                          // Grupo de Ventas
            oTask['state']           := (cAlias)->A1_EST                         //Cod Estado
            oTask['state']           := (cAlias)->A1_ESTADO                          //Estado
            oTask['province']        := (cAlias)->A1_COD_MUN                             //Cod Municipio
            oTask['province']        := (cAlias)->A1_MUN                             //Municipio
            oTask['district']        := (cAlias)->A1_BAIRRO                          //Barrio
            oTask['contact']         := (cAlias)->A1_CONTATO                         //Contacto
            oTask['paymentterms']    := (cAlias)->A1_COND                            //Condicion Pagp
            oTask['FecVer']    := "16/09/2023"                       //Version Api
            AAdd(aTasks, oTask)
            IF Len(aTasks) >= Self:PageSize
                Exit
            EndIF
        EndIF
        (cAlias)->(DbSkip())
    End
Else
    oResponse['hasNext'] := .F.
    cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
    ::SetResponse(cResponse)
EndIf
oResponse['clients'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost


WSMETHOD POST WSRECEIVE cClient  WSSERVICE UANDCLIE

    Local cJSON := Self:GetContent() // Pega a string do JSON
    Local oParseJSON := Nil
    Local aDadosCli := {} //–> Array para ExecAuto do MATA030
    Local cFileLog := ""
    Local cJsonRet := ""
    Local cArqLog := ""
    Local cErro := ""
    Local cCodSA1 := ""
    Local lRet := .T.
    Local cCodCli := ""
    Local cLoja  := ""
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.


    // –> Cria o diretório para salvar os arquivos de log
    If !ExistDir("_RESTLOG\log_cli")
        MakeDir("_RESTLOG\log_cli")
    EndIf

    // –> Deserializa a string JSON

    FWJsonDeserialize(cJson, @oParseJSON)
    cCodCli := oParseJSON:CLIENTE:cod
    cLoja   := oParseJSON:CLIENTE:loja

    ConOut( cCodCli)
    ConOut( cLoja)

    IF Empty(cCodCli)
        SetRestFault(400, "No hay datos para proceder ")
        lRet := .F.
    EndIF
    SA1->(DbSetOrder(1))
    If !(SA1->(DbSeek(xFilial("SA1")+cCodCli)))
        Aadd(aDadosCli, {"A1_FILIAL" ,    xFilial("SA1") ,           Nil} )
        Aadd(aDadosCli, {"A1_COD" ,       oParseJSON:CLIENTE:cod ,   Nil} )
        Aadd(aDadosCli, {"A1_LOJA" ,      oParseJSON:CLIENTE:loja,   Nil} )
        Aadd(aDadosCli, {"A1_NOME" ,      oParseJSON:CLIENTE:nome,   Nil} )
        Aadd(aDadosCli, {"A1_END" ,       oParseJSON:CLIENTE:dire,   Nil} )
        Aadd(aDadosCli, {"A1_TIPO" ,      "1",                       Nil} )
        Aadd(aDadosCli, {"A1_RETFUEN",    "N",                       Nil} )
        Aadd(aDadosCli, {"A1_NREDUZ",     oParseJSON:CLIENTE:nome,   Nil} )
        Aadd(aDadosCli, {"A1_EST" ,       oParseJSON:CLIENTE:esta,   Nil} )
        Aadd(aDadosCli, {"A1_COD_MUN" ,   oParseJSON:CLIENTE:muni,   Nil} )
        Aadd(aDadosCli, {"A1_NATUREZ" ,   oParseJSON:CLIENTE:nature, Nil} )
        // Aadd(aDadosCli, {"A1_TIPDOC" ,    oParseJSON:CLIENTE:tpdoc,  Nil} )
        Aadd(aDadosCli, {"A1_VEND" ,      oParseJSON:CLIENTE:vende,  Nil} )
        Aadd(aDadosCli, {"A1_COND" ,      oParseJSON:CLIENTE:condi,  Nil} )
        Aadd(aDadosCli, {"A1_EMAIL" ,     oParseJSON:CLIENTE:mail,   Nil} )
        Aadd(aDadosCli, {"A1_CONTA" ,     "1301010001",              Nil} )
        Aadd(aDadosCli, {"A1_XCTAANT" ,   "1301010001",              Nil} )
        Aadd(aDadosCli, {"A1_TEL" ,       oParseJSON:CLIENTE:telef,  Nil} )
        
        
        MsExecAuto({|x,y| MATA030(x,y)}, aDadosCli, 3)
        
        
        If lMsErroAuto
            ConOut( "A V I S O *************** Error en la Rutina Automatica ")
            cArqLog := oParseJSON:CLIENTE:cod + "-" +SubStr(Time(),1,5)+dTOS(Date()) + ".log"
            cErro := MostraErro("_RESTLOG\log_cli", cArqLog)
            // := TrataErro(cErro) //
            SetRestFault(400, cErro)
            lRet := .F.
        Else
            cJSONRet := '{ "cod_cli":"' + SA1->A1_COD + '"';
                + ',"loja":"' + SA1->A1_LOJA + '"';
                + ',"msg":"' + "Cliente  creado con Exito en el sistema !!!!" + '"';
                +'}'
            ::SetResponse( cJSONRet )
        EndIf
    Else
        SetRestFault(400, "Cliente ya registrado: " + SA1->A1_COD + "-" + SA1->A1_LOJA)
        lRet := .F.
    EndIf
Return(lRet)
