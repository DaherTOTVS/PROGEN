#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDCONDPAG                                         !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST                                                !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDALMAC encargada de realizar la consulta         !
!                  ! Cndiciones de Pago                                      !
!                  ! Funcionalidades Adicionadas.                            !
!                  !   1. Consulta de Todos las condiciones de pago          !
!                  !   * Filtra por Codigo, Descripcion                      !
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

WSRESTFUL UANDMODA DESCRIPTION "Servicio API Rest Para la consulta de Modalidades |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL
    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de las modalidadesd Filtra por un Dato."          WSSYNTAX "/VerModalid"     PATH "/VerModalid"    // Obtiene Todos los Prodcutos o filtra un producto
END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDMODA
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

cQuery := " SELECT SED.ED_FILIAL,"
cQuery += " SED.ED_CODIGO, "
cQuery += " SED.ED_XPORTAL, "
cQuery += " SED.ED_DESCRIC "
cQuery += " FROM " + RetSqlName("SED") + " SED "
cQuery += " WHERE "
cQuery += " SED.ED_FILIAL   = '"+xFilial("SED")+"' "
cQuery += " AND SED.D_E_L_E_T_ <> '*'"
//cQuery += " AND SED.ED_XPORTAL='1' "
//cQuery += " AND SED.D_E_L_E_T_ <> '*' and ED_CODIGO LIKE '80%' "
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( SED.ED_CODIGO LIKE '%" + cCod + "%' OR "
    cQuery += " SED.ED_DESCRIC LIKE '%" + FwNoAccent( cCod ) + "%' OR "
    cQuery += " SED.ED_DESCRIC LIKE '%" + cCod + "%' ) "
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
            oTask['banch']              :=  (cAlias)->ED_FILIAL
            oTask['code']               :=  AllTrim((cAlias)->ED_CODIGO)
            oTask['descsri']            :=  UPPER(AllTrim(EncodeUtf8((cAlias)->ED_DESCRIC)))
            oTask['habil']            :=  (cAlias)->ED_XPORTAL
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
oResponse['Modalidad'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

