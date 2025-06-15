#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDALMAC                                           !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST                                                !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDALMAC encargada de realizar la consulta         !
!                  ! de Cartera Financiera                                   !
!                  ! Funcionalidades Adicionadas.                            !
!                  !   1. Consulta de Cartera                                !
!                  !   * Filtra por Titulos, Cliente, Nombre                 !
!                  !                                                         !
!                  !                                                         !
!                  !							                             !
!                  ! 						                                 !
!                  !                                                         !
!                  !                                                         !
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


WSRESTFUL UANDCART DESCRIPTION "Servicio API Rest Para la consulta de cartera del cliente  |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA DIni         AS STRING OPTIONAL
    WSDATA DFin         AS STRING  OPTIONAL
    WSDATA Cloja         AS STRING  OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos

    WSMETHOD GET         DESCRIPTION "Retorna listado de Cartera de cliente Filtra por un Dato."          WSSYNTAX "/VerCartera"     PATH "/VerCartera"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod,  DIni, DFin, Cloja, Page, PageSize  WSREST UANDCART
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
//Default Self:PageSize   := 100


::SetContentType("application/json")
cAlias := GetNextAlias()
//Se establece consulta estandar de ejemplo de Takker para implementar Query con cartera basado en despachos (Remisiones).
//Hay que validar el Tema con usuaria de un ejemplo de esta cartera para validar.
cQuery := " SELECT "
cQuery += "    DISTINCT SE1.E1_FILIAL, "
cQuery += "    SE1.E1_CLIENTE, "
cQuery += "    SA1.A1_COD, "
cQuery += "    SA1.A1_NOME, "
cQuery += "    SA1.A1_LC, "
cQuery += "    SE1.E1_LOJA, "
cQuery += "    SE1.E1_PARCELA, "
cQuery += "    SE1.E1_NUM, "
cQuery += "    MAX(SF2.F2_COND) F2_COND, "
cQuery += "    SE1.E1_PREFIXO, "
cQuery += "    SE1.E1_EMISSAO, "
cQuery += "    SE1.E1_VENCREA, "
cQuery += "    SE1.E1_VALOR, "
cQuery += "    SE1.E1_BAIXA, "
cQuery += "    SE1.E1_MOVIMEN, "
cQuery += "    SE1.E1_SALDO, "
cQuery += "    SE1.E1_MOEDA, "
cQuery += "    SE1.E1_TIPO, "
cQuery += "    SE1.E1_BAIXA VENC "
cQuery += "    FROM " + RetSqlName("SA1") + " SA1 "
cQuery += "    INNER JOIN "+ RetSqlName("SE1") + " SE1  ON SE1.D_E_L_E_T_ <> '*' "
cQuery += "    AND SE1.E1_LOJA = SA1.A1_LOJA "
cQuery += "    AND SA1.A1_COD = SE1.E1_CLIENTE "
cQuery += "    LEFT JOIN " + RetSqlName("SF2") + " SF2  ON SF2.D_E_L_E_T_ <> '*' "
cQuery += "    AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "
cQuery += "    AND SF2.F2_CLIENTE = SA1.A1_COD "
cQuery += "    AND SF2.F2_LOJA = SE1.E1_LOJA "
cQuery += "    AND SF2.F2_LOJA = SA1.A1_LOJA "
cQuery += "    AND SF2.F2_EMISSAO = SE1.E1_EMISSAO "
cQuery += "    WHERE "
cQuery += "    SA1.D_E_L_E_T_ <> '*'  "
//Filtros
IF !Empty(Self:DIni)
    cCod := AllTrim(Upper(Self:Cod))
    cDIni :=AllTrim(Self:DIni)
    cDFin := AllTrim(Self:DFin)
    cCloja := AllTrim(Self:Cloja)
    cQuery += " AND (SA1.A1_COD  LIKE '%" + cCod + "%' OR "
    cQuery += "  SE1.E1_FILIAL+TRIM(SE1.E1_CLIENTE)+SE1.E1_LOJA LIKE '%" + cCod + "%' ) AND SE1.E1_EMISSAO BETWEEN '"+cDIni+"' AND '"+ cDFin +"' AND SA1.A1_LOJA LIKE '%"+ cCloja +"%' "
endIF
cQuery += "GROUP BY "
cQuery += "    SE1.E1_FILIAL, "
cQuery += "    SE1.E1_CLIENTE,"
cQuery += "    SA1.A1_COD,"
cQuery += "    SA1.A1_NOME,"
cQuery += "    SA1.A1_LC,"
cQuery += "    SE1.E1_LOJA, "
cQuery += "    SE1.E1_PARCELA,"
cQuery += "    SE1.E1_NUM, "
cQuery += "    SE1.E1_PREFIXO, "
cQuery += "    SE1.E1_EMISSAO, "
cQuery += "    SE1.E1_VENCREA, "
cQuery += "    SE1.E1_VALOR, "
cQuery += "    SE1.E1_BAIXA, "
cQuery += "    SE1.E1_MOVIMEN, "
cQuery += "    SE1.E1_SALDO, "
cQuery += "    SE1.E1_MOEDA, "
cQuery += "    SE1.E1_TIPO, "
cQuery += "    SE1.E1_BAIXA "
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
            oTask['branch']             := AllTrim((cAlias)->E1_FILIAL) //Sucursal
            oTask['codclient']          := AllTrim((cAlias)->E1_CLIENTE) // Codigo Cliente
            oTask['storeclient']        := AllTrim((cAlias)->E1_LOJA) //Tienda
            oTask['paymentfees']         := AllTrim((cAlias)->E1_PARCELA) // Cuotas
            //oTask['especie']              := AllTrim((cAlias)->FP_ESPECIE) // Prefijo
            //oTask['serie']              := AllTrim((cAlias)->FP_SERIE) // Prefijo
            oTask['invoicenum']         := AllTrim((cAlias)->E1_NUM) //Numero Doc
            oTask['emission date']      := (cAlias)->E1_EMISSAO // Fecha emisiòn
            oTask['realexpirationdate'] := (cAlias)->E1_VENCREA // Fecha real de venciminto (En caso de negociaciòn con Proveedor)
            oTask['totalamount']        := (cAlias)->E1_VALOR //Valor DOC
            oTask['expirationdate']     := (cAlias)->VENC //Fecha vencimiento calculada inicialmente
            //  oTask['expirationdays']     := (cAlias)->DATEDIFF
            oTask['currency']           := (cAlias)->E1_MOEDA //Moneda
            oTask['lasttrans']          := (cAlias)->E1_MOVIMEN//Fecha de Ultima Transacciòn Realizado
            oTask['balancedue']         := (cAlias)->E1_SALDO //Saldo a la fecha
            oTask['paidinfulldate']     := (cAlias)->E1_BAIXA// Fecha de pago total.
            oTask['terpago']     := (cAlias)->F2_COND// Condicion de pago.
            oTask['limcredit']     := (cAlias)->A1_LC// Limite de Credito Cliente
            oTask['tipo']     := (cAlias)->E1_TIPO// Limite de Credito Cliente
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
oResponse['Cartera'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

