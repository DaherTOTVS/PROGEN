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



WSRESTFUL UANDPEDES DESCRIPTION "Servicio API Rest Para la consulta /  Estado de los pedidos de Venta Sistema |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA DIni         AS STRING OPTIONAL
    WSDATA DFin         AS STRING  OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna estado de pedido de venta."             WSSYNTAX "/VerPedEstat"     PATH "/VerPedEstat"

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, DIni, DFin, Page, PageSize  WSREST UANDPEDES
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
cQuery += "  C5_NUM, C5_CLIENTE, c5_lojacli,  C5_EMISSAO, C5_XENDENT, (SELECT DISTINCT A1_NOME FROM  "+ RetSqlName("SA1") + " SA1  WHERE A1_COD = C5_CLIENTE AND SA1.D_E_L_E_T_ <> '*' AND SA1.A1_LOJA=SC5.C5_LOJACLI) AS NOME,
cQuery += "(SELECT SUM(C6_VALOR) FROM" + RetSqlName("SC6") + " SC6 "+ " WHERE C6_NUM = SC5.C5_NUM AND C6_FILIAL = SC5.C5_FILIAL AND C6_LOJA = SC5.C5_LOJACLI ) TOTAL, "
cQuery += " CASE
cQuery += " WHEN C5_LIBEROK = ' ' AND C5_NOTA = ' '  AND C5_BLQ = ' ' THEN 'ABIERTO'
cQuery += " WHEN C5_NOTA <> ' ' OR  C5_LIBEROK  = 'E' AND C5_BLq = ' ' THEN 'CERRADO'
cQuery += " WHEN C5_LIBEROK  <> ' ' AND  C5_NOTA = ' '  AND C5_BLq = ' ' THEN  'APROBADO'
cQuery += " WHEN C5_BLQ = '1' THEN 'BLOQUEADO'
cQuery += " END AS ESTADO
cQuery += " FROM " + RetSqlName("SC5") + " SC5
cQuery += " WHERE SC5.D_E_L_E_T_ <> '*'


IF !Empty(Self:DIni)
    cCod := AllTrim(Upper(Self:Cod))
    cDIni :=AllTrim(Self:DIni)
    cDFin := AllTrim(Self:DFin)
    cQuery += " AND (SC5.C5_NUM LIKE '%" + cCod + "%'  OR "
    cQuery += "  SC5.C5_CLIENTE LIKE '%" + cCod + "%'  ) AND SC5.C5_EMISSAO BETWEEN '"+cDIni+"' AND '"+ cDFin +"' "
   // cQuery += " GROUP BY SC5.C5_FILIAL,	SC5.C5_NUM,	SC5.C5_VEND1,	SC5.C5_EMISSAO,	SC5.C5_FECENT,	SC5.C5_CLIENTE,	SC5.C5_LOJACLI,	SC5.C5_CLIENT,	SC5.C5_LOJAENT,	SC5.C5_MENNOTA,	SC5.C5_NATUREZ,	SC5.C5_XENDENT,	SC5.C5_XEST,	SC5.C5_XCOD_MU,	SA1.A1_NOME,	SC5.C5_TIPOCLI,  SC5.C5_DESC1,	SA1.A1_END,	SC5.C5_CONDPAG,	SC5.C5_DOCGER,	SC5.C5_LIBEROK,	SC5.C5_NOTA, SC5.C5_BLQ, SC5.D_E_L_E_T_"
ENDIF



//Filtros
/*IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND  SC5.C5_NUM LIKE '%" + cCod + "%' "
EndIF*/
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
        oResponse['hasNext'] := .f.
    ELSE
        oResponse['hasNext'] := .t.
    EndIF
    While (cAlias)->(!Eof())
        nCount++
        IF nCount >= nStart
            nAux++
            oTask := JsonObject():New()
            oTask['branch']         := xFilial("SC5")                         
            oTask['code']           := (cAlias)->C5_NUM                          
            oTask['client']         := (cAlias)->C5_CLIENTE                           
            oTask['loja']           := (cAlias)->c5_lojacli   
            oTask['data']           := (cAlias)->C5_EMISSAO    
            oTask['adressent']           := (cAlias)->C5_XENDENT    
            oTask['nome']           := Alltrim( EncodeUTF8((cAlias)->NOME))                        
            oTask['estado']         := (cAlias)->ESTADO    
            oTask['total']         := (cAlias)->TOTAL        
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
oResponse['StatPed'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

