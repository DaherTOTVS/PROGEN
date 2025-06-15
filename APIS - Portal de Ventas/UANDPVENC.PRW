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



WSRESTFUL UANDPVENC DESCRIPTION "Servicio API Rest Para la consulta / Modificacion de Pedidos de Venta |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA DIni         AS STRING OPTIONAL
    WSDATA DFin         AS STRING  OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de pedidos de Venta Encabezado."                         WSSYNTAX "/VerPedEnc"     PATH "/VerPedEnc"
   // WSMETHOD POST        DESCRIPTION "Crea un nuevo cClient en el sistema Protheus  "                          WSSYNTAX "/CrePedido"     PATH "/CrecClient"    // Crea un Nuevo Producto
    // WSMETHOD PUT      DESCRIPTION "Actualiza la informacin de un Pedido de Venta - Aprobacion"              WSSYNTAX "/ActPedido"     PATH "/ActPedido"    // Modifica un Producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, DIni, DFin, Page, PageSize  WSREST UANDPVENC
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0

Default Self:Cod        := ''
Default Self:DIni       := ''
Default Self:DFin       := ''
Default Self:Page       := 1
//Default Self:PageSize   := 10


::SetContentType("application/json")
cAlias := GetNextAlias()
cQuery := " SELECT  "
cQuery += " SC5.C5_FILIAL, "
cQuery += " SC5.C5_NUM,   "
cQuery += " SC5.C5_VEND1, "
cQuery += " SC5.C5_EMISSAO, "
cQuery += " SC5.C5_FECENT, "
cQuery += " SC5.C5_CLIENTE, "
cQuery += " SC5.C5_LOJACLI, "
cQuery += " SC5.C5_CLIENT, "
cQuery += " SC5.C5_LOJAENT, "
cQuery += " SC5.C5_MENNOTA, "
cQuery += " SC5.C5_NATUREZ, "
cQuery += " SC5.C5_XENDENT, "
cQuery += " SC5.C5_XEST, "
cQuery += " SC5.C5_XCOD_MU, "
cQuery += " SA1.A1_NOME, "
cQuery += " SC5.C5_TIPOCLI, "
cQuery += " (SELECT SUM(C6_VALOR) FROM" + RetSqlName("SC6") + " SC6 "+ " WHERE C6_NUM = SC5.C5_NUM AND C6_FILIAL = SC5.C5_FILIAL AND C6_LOJA = SC5.C5_LOJACLI ) TOTAL, "
cQuery += " SC5.C5_DESC1, "
cQuery += " SA1.A1_END, "
cQuery += " SC5.C5_CONDPAG, "
cQuery += " SC5.C5_DOCGER, "
cQuery += " SC5.C5_LIBEROK, "
cQuery += " SC5.C5_NOTA, "
cQuery += " MAX(SC9.C9_BLCRED) CR, "
cQuery += " MAX(SC9.C9_BLEST) ST, "
cQuery += " SC5.C5_BLQ, "
cQuery += " case SC5.D_E_L_E_T_  when '*' then 'I' when ' '  then 'A' end as  LOGDELSTATUS, "
cQuery += " CASE
cQuery += " WHEN C5_LIBEROK = ' ' AND C5_NOTA = ' '  AND C5_BLQ = ' ' THEN 'ABIERTO'
cQuery += " WHEN C5_NOTA <> ' ' OR  C5_LIBEROK  = 'E' AND C5_BLq = ' ' THEN 'CERRADO'
cQuery += " WHEN C5_LIBEROK  <> ' ' AND  C5_NOTA = ' '  AND C5_BLq = ' ' THEN  'APROBADO'
cQuery += " WHEN C5_BLQ = '1' THEN 'BLOQUEADO'
cQuery += " END AS ESTADO, "
cQuery += " D2_DOC "
cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
cQuery += " INNER JOIN " +RetSqlName("SC5") + " SC5 "
cQuery += " ON C5_LOJACLI = A1_LOJA "
cQuery += " AND C5_CLIENT = A1_COD   "
cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN "+ RetSqlName("SC9") + " SC9 "
cQuery += " ON C9_PEDIDO = C5_NUM   "
cQuery += " AND C5_CLIENT = C9_CLIENTE  "
cQuery += " AND C5_LOJACLI = C9_LOJA   "
cQuery += " AND SC9.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN "+ RetSqlName("SD2") + " SD2 "
cQuery += " ON D2_PEDIDO=C5_NUM
cQuery += " AND D2_CLIENTE=C5_CLIENTE
cQuery += " AND D2_LOJA=C5_LOJACLI
cQuery += " AND SD2.D_E_L_E_T_ <> '*'
cQuery += " AND D2_ESPECIE='NF'
cQuery += " WHERE "
cQuery += " SA1.D_E_L_E_T_ <> '*' "



//Filtros
IF !Empty(Self:DIni)
    cCod := AllTrim(Upper(Self:Cod))
    cDIni :=AllTrim(Self:DIni)
    cDFin := AllTrim(Self:DFin)
    cQuery += " AND (SC5.C5_NUM LIKE '%" + cCod + "%'  OR "
    cQuery += "  SC5.C5_CLIENTE LIKE '%" + cCod + "%'  ) AND SC5.C5_EMISSAO BETWEEN '"+cDIni+"' AND '"+ cDFin +"' "
    cQuery += " GROUP BY SC5.C5_FILIAL,	SC5.C5_NUM,	SC5.C5_VEND1,	SC5.C5_EMISSAO,	SC5.C5_FECENT,	SC5.C5_CLIENTE,	SC5.C5_LOJACLI,	SC5.C5_CLIENT,	SC5.C5_LOJAENT,	SC5.C5_MENNOTA,	SC5.C5_NATUREZ,	SC5.C5_XENDENT,	SC5.C5_XEST,	SC5.C5_XCOD_MU,	SA1.A1_NOME,	SC5.C5_TIPOCLI,  SC5.C5_DESC1,	SA1.A1_END,	SC5.C5_CONDPAG,	SC5.C5_DOCGER,	SC5.C5_LIBEROK,	SC5.C5_NOTA, SC5.C5_BLQ, SC5.D_E_L_E_T_, D2_DOC"
    //cQuery += " ORDER BY C5_EMISSAO,SC5.C5_NUM "
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
            oTask['branch']             := AllTrim((cAlias)->C5_FILIAL)
            oTask['code']               := AllTrim((cAlias)->C5_NUM)
            oTask['seller1']            := AllTrim((cAlias)->C5_VEND1)
            oTask['emitiondate']        := AllTrim((cAlias)->C5_EMISSAO)
            oTask['deliverydate']       := AllTrim((cAlias)->C5_FECENT)
            oTask['codclient']          := AllTrim((cAlias)->C5_CLIENTE)
            oTask['clientname']         := AllTrim(EncodeUTF8((cAlias)->A1_NOME ))
            oTask['storeclient']        := (cAlias)->C5_LOJACLI
            oTask['clientype']          := (cAlias)->C5_TIPOCLI
            oTask['codclientent']          := AllTrim((cAlias)->C5_CLIENT)
            oTask['storeent']        := (cAlias)->C5_LOJAENT
            oTask['observaped']         := AllTrim(EncodeUTF8((cAlias)->C5_MENNOTA))
            oTask['total']              := (cAlias)->TOTAL
            oTask['discountvalue']      := (cAlias)->C5_DESC1
            oTask['addres']             := AllTrim(EncodeUTF8((cAlias)->A1_END  ))
            oTask['paymentterms']       := (cAlias)->C5_CONDPAG
            oTask['modalidad']          := (cAlias)->C5_NATUREZ
            oTask['doccreate']          := (cAlias)->C5_DOCGER
            oTask['orderstatus']        := (cAlias)->C5_LIBEROK
            oTask['adressent']          := AllTrim(EncodeUTF8((cAlias)->C5_XENDENT))
            oTask['depto']              := AllTrim((cAlias)->C5_XEST)
            oTask['codmun']             := AllTrim((cAlias)->C5_XCOD_MU)
            oTask['logdelstatus']       := AllTrim((cAlias)->LOGDELSTATUS)
            oTask['bloqcart']       := AllTrim((cAlias)->CR)
            oTask['blocstck']       := AllTrim((cAlias)->ST)
            oTask['estado']         := (cAlias)->ESTADO
            oTask['fact']         := (cAlias)->D2_DOC   
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
oResponse['PedVeEnc'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

