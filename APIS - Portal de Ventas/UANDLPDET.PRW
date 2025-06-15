#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDLPDET                                           !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST                                                !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDLPDET encargada de realizar la consulta         !
!                  ! Detalle de la lista de precio                           !
!                  ! Funcionalidades Adicionadas.                            !
!                  !   1. Consulta de Todos los Almacenes                    !
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


WSRESTFUL UANDLPDET DESCRIPTION "Servicio API Rest Para la consulta de Listas de Precios (Detalle)  |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de listas de precios (Detalle) Filtra por un Dato."          WSSYNTAX "/VerLprecDet"     PATH "/VerLprecDet"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDLPDET
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0
Local Stock := 0
Local  aItens := {}

Default Self:Cod        := ''
Default Self:Page       := 1
//Default Self:PageSize   := 100


::SetContentType("application/json")
cAlias := GetNextAlias()

cQuery := " SELECT "
cQuery += "  DA1.DA1_FILIAL , "
cQuery += "  MAX(DA1.DA1_ITEM) DA1_ITEM , "
cQuery += "  DA1.DA1_CODPRO, "
cQuery += "  SB1.B1_DESC, "
cQuery += "  SB1.B1_UM, "
cQuery += "  DA1.DA1_CODTAB, "
cQuery += "  DA1.DA1_GRUPO, "
cQuery += "  SB1.B1_PRV1 B1_PRV1, "
cQuery += "  SB1.B1_GRUPO, "
cQuery += "  SB1.B1_TS, "
cQuery += "  DA1_PRCVEN, "
cQuery += "  DA1.DA1_VLRDES, "
cQuery += "  DA1.DA1_PERDES, "
cQuery += "  DA1.DA1_ATIVO, "
cQuery += "  DA1.DA1_QTDLOT, "
cQuery += "  DA1.DA1_MOEDA, "
cQuery += "  MAX(DA1.DA1_DATVIG) AS DA1_DATVIG, "
cQuery += "  SB2.B2_QATU B2_QATU,"
cQuery += "  SB2.B2_RESERVA B2_RESERVA,"
cQuery += "  SB2.B2_QACLASS B2_QACLASS,"
cQuery += "  SB1.B1_TIPO"
cQuery += " FROM  " + RetSqlName("DA1") + " DA1 "                     
cQuery += " INNER JOIN   " + RetSqlName("SB1") + " SB1 "
cQuery += " ON   SB1.B1_FILIAL  = DA1.DA1_FILIAL "
cQuery += " AND SB1.B1_COD = DA1_CODPRO "
cQuery += " AND SB1.B1_XPORTAL = '1' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
cQuery += " ON SB2.B2_COD= DA1_CODPRO "
cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
cQuery += " AND SB2.B2_LOCAL=SB1.B1_LOCPAD "
cQuery += " WHERE DA1.D_E_L_E_T_ <> '*' "
cQuery += " AND DA1_ATIVO= '1' "

//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( DA1.DA1_CODTAB LIKE '%" +cCod+ "%')"//  or DA1.DA1_CODPRO LIKE  '%" +cCod+ "%' ) "
endIF
cQuery += " GROUP BY "
cQuery += "  DA1.DA1_FILIAL, "
cQuery += "  DA1.DA1_CODPRO, "
cQuery += "  SB1.B1_DESC, "
cQuery += "  SB1.B1_UM, "
cQuery += "  DA1.DA1_CODTAB, "
cQuery += "  DA1.DA1_GRUPO, "
cQuery += "  SB1.B1_PRV1, "
cQuery += "  SB1.B1_GRUPO, "
cQuery += "  SB1.B1_TS, "
cQuery += "  DA1.DA1_VLRDES, "
cQuery += "  DA1.DA1_PERDES, "
cQuery += "  DA1.DA1_ATIVO, "
cQuery += "  DA1.DA1_QTDLOT, "
cQuery += "  DA1.DA1_MOEDA, "
cQuery += "  SB2.B2_QATU, "
cQuery += "  SB2.B2_RESERVA, "
cQuery += "  SB2.B2_QACLASS,"
cQuery += "  DA1_PRCVEN,"
cQuery += "  B1_TIPO"
cQuery += "  ORDER BY DA1_DATVIG DESC"


cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,cAlias)

//
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

            
            If ( Ascan( aItens, {|x| x[1]+x[2] == (cAlias)->DA1_CODPRO+(cAlias)->DA1_CODTAB } ) ) == 0
                aAdd( aItens, {(cAlias)->DA1_CODPRO,(cAlias)->DA1_CODTAB})
                nAux++
                Stock := (cAlias)->B2_QATU - (cAlias)->B2_RESERVA - (cAlias)->B2_QACLASS 
                oTask := JsonObject():New()
                oTask['branch']             :=  AllTrim((cAlias)->DA1_FILIAL)
                oTask['item']               :=  AllTrim((cAlias)->DA1_ITEM)
                oTask['code_lp']               :=  AllTrim((cAlias)->DA1_CODTAB)
                oTask['code']          :=  AllTrim(EncodeUTF8((cAlias)->DA1_CODPRO))
                oTask['grupop']          :=  AllTrim((cAlias)->B1_GRUPO)
                oTask['name']        :=  AllTrim(EncodeUTF8((cAlias)->B1_DESC))
                oTask['unidad']        :=  AllTrim(EncodeUTF8((cAlias)->B1_UM))
                oTask['group']              :=  AllTrim((cAlias)->DA1_GRUPO)
                oTask['baseprice']          :=  (cAlias)->B1_PRV1
                oTask['tes']          :=  (cAlias)->B1_TS
                oTask['saleprice']          :=  (cAlias)->DA1_PRCVEN
                oTask['discountvalue']      :=  AllTrim((cAlias)->DA1_VLRDES)
                oTask['discountpercentage'] :=  AllTrim((cAlias)->DA1_PERDES)
                oTask['isactive']           :=  AllTrim((cAlias)->DA1_ATIVO)
                oTask['intervalvalue']      :=  AllTrim((cAlias)->DA1_QTDLOT)
                oTask['currency']           :=  AllTrim((cAlias)->DA1_MOEDA)
                oTask['vigencydate']        :=  AllTrim((cAlias)->DA1_DATVIG)            
                oTask['StockAct']           := Stock
                oTask['tipo']               := AllTrim((cAlias)->B1_TIPO)
                oTask['FecVer']    := "27/07/2024"                       //Version Api
                AAdd(aTasks, oTask)
            EndIf
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
oResponse['LisPreDet'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

