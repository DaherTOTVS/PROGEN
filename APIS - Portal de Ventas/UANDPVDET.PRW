#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDPVPRU                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST Clientes                                       !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDALMAC encargada de realizar la consulta         !
!                  ! y adicion de Clientes                                   !
!                  !                                                         !
!                  !   1. Consulta de Cartera                                !
!                  !   * Filtra por RUC, Nombre                              !
                   !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!
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



WSRESTFUL UANDPVDET DESCRIPTION "Servicio API Rest Para la consulta / Modificacion de Pedidos de Venta |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de pedidos de Venta Encabezado."                         WSSYNTAX "/VerPedDet"     PATH "/VerPedDet"
    // WSMETHOD POST        DESCRIPTION "Crea un nuevo cClient en el sistema Protheus  "                          WSSYNTAX "/CrePedido"     PATH "/CrecClient"    // Crea un Nuevo Producto
    // WSMETHOD PUT      DESCRIPTION "Actualiza la informacin de un Pedido de Venta - Aprobacion"              WSSYNTAX "/ActPedido"     PATH "/ActPedido"    // Modifica un Producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDPVDET
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
//Default Self:PageSize   := 1


::SetContentType("application/json")
cAlias := GetNextAlias()
cQuery := " SELECT DISTINCT "
cQuery += " SC6.C6_FILIAL , "
cQuery += "    SC6.C6_NUM, "
cQuery += "    SC6.C6_ITEM, "
cQuery += "    SC6.C6_PRODUTO, "
cQuery += "    SC6.C6_DESCRI, "
cQuery += "    SC6.C6_QTDVEN, "
cQuery += "    SC6.C6_UM, "
cQuery += "    SC6.C6_PRCVEN, "
cQuery += "    SC6.C6_VALOR, "
cQuery += "    SC6.C6_VALDESC, "
cQuery += "    SC6.C6_QTDLIB, "
cQuery += "    SC6.C6_QTDENT, "
cQuery += "    SC6.C6_QTDENT, "
cQuery += "    SC6.C6_ENTREG, "
cQuery += "    SD2.D2_EMISSAO, "
cQuery += "    CASE "
cQuery += "        SC6.D_E_L_E_T_ "
cQuery += "        WHEN '*' THEN 'S' "
cQuery += "        WHEN ' ' THEN 'N' "
cQuery += "    END AS DELITEM "
cQuery += "FROM " + RetSqlName("SC6") + " SC6 "
cQuery += "    LEFT JOIN " + RetSqlName("SD2") + " SD2  ON SD2.D2_COD = SC6.C6_PRODUTO "
cQuery += "    AND SD2.D2_PEDIDO = SC6.C6_NUM "
cQuery += "    AND SD2.D2_CLIENTE = SC6.C6_CLI "
cQuery += "    AND SD2.D2_LOJA = SC6.C6_LOJA "
cQuery += "    AND SD2.D2_ESPECIE = 'RFN' "
cQuery += "    AND SD2.D_E_L_E_T_ <> '*' "
cQuery += "    LEFT JOIN " + RetSqlName("SF2") + " SF2  ON SF2.F2_DOC = SD2.D2_DOC "
cQuery += "    AND SD2.D2_ESPECIE = SF2.F2_ESPECIE "
cQuery += "    AND SF2.F2_CLIENTE = SC6.C6_CLI"
cQuery += "    AND SF2.F2_LOJA = SC6.C6_LOJA"
cQuery += "    AND SF2.D_E_L_E_T_ <> '*'"
cQuery += "WHERE"
cQuery += "    SC6.D_E_L_E_T_ <> '*'"


//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += "  AND SC6.C6_NUM LIKE '%" + cCod + "%' "
EndIF
cQuery += "  ORDER BY C6_NUM ASC "
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

            oTask['branch']             := AllTrim((cAlias)->C6_FILIAL)
            oTask['item']               := AllTrim((cAlias)->C6_ITEM)
            oTask['code']               := AllTrim((cAlias)->C6_NUM)
            oTask['productid']          := AllTrim((cAlias)->C6_PRODUTO)
            oTask['productname']        := AllTrim(EncodeUtf8((cAlias)->C6_DESCRI))
            oTask['quantity']           := (cAlias)->C6_QTDVEN
            oTask['unit']               := (cAlias)->C6_UM
            oTask['saleprice']          := (cAlias)->C6_PRCVEN
            oTask['totalline']          := (cAlias)->C6_VALOR
            oTask['totaldiscount']      := (cAlias)->C6_VALDESC
            oTask['cantlib']      := (cAlias)->C6_QTDLIB
            oTask['cantent']      := (cAlias)->C6_QTDENT
            oTask['entreg']      := (cAlias)->C6_ENTREG
            oTask['delitem']            := (cAlias)->DELITEM
            oTask['dateremito']            := (cAlias)->D2_EMISSAO
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
oResponse['PedVenDet'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

