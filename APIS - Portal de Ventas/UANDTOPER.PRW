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

WSRESTFUL UANDTOPER DESCRIPTION "Servicio API Rest Para la consulta de Tipos de Operacion |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL
    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de las Tipos de Operacion Filtra por un Dato."          WSSYNTAX "/VerToper"     PATH "/VerToper"    // Obtiene Todos los Prodcutos o filtra un producto
END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDTOPER
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

cQuery := " SELECT SFM.FM_FILIAL, SFM.FM_ID,"
cQuery += " SFM.FM_TIPO, "
cQuery += " SFM.FM_DESCR, "
cQuery += " SFM.FM_XDESTES "
cQuery += " FROM " + RetSqlName("SFM") + " SFM "
cQuery += " WHERE "
cQuery += " SFM.FM_FILIAL   = '"+xFilial("SFM")+"' "
cQuery += " AND SFM.D_E_L_E_T_ <> '*'  "
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( SFM.FM_TIPO LIKE '%" + cCod + "%' OR "
    cQuery += " SFM.FM_DESCR LIKE '%" + FwNoAccent( cCod ) + "%' OR "
    cQuery += " SFM.FM_DESCR LIKE '%" + cCod + "%' ) "
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
            oTask['banch']              :=  (cAlias)->FM_FILIAL
            oTask['code']               :=  AllTrim((cAlias)->FM_ID)
            oTask['codepla']            :=  UPPER(AllTrim((cAlias)->FM_TIPO))
            oTask['descr']               :=  AllTrim((cAlias)->FM_DESCR)
            oTask['desctes']            :=  UPPER(AllTrim((cAlias)->FM_XDESTES))
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
oResponse['CodToper'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

