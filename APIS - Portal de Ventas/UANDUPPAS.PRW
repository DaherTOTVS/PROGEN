#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Rwmake.ch"
#Include "Topconn.ch"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDUPPAS                                           !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST PORTAL VENTAS                                  !
+------------------+---------------------------------------------------------+
!Descripcion       ! API PARA LA MODIFICACION DE LA CONTRASEÑA               !
!                  ! EN LA TABLA ZZ5 USUARIOS PORTAL                         !
+------------------+---------------------------------------------------------+
!Autor             ! Duvan Arley Hernandez Niño                              !  
                   !    (\_(\                                                !
                   !    (=':')                                               !
                   !    (,(" )(" )                                           !
+------------------+---------------------------------------------------------+
!Fecha creacion    !  01-2023                                                !
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
|__________________________________________________________________________________________|
|   //////  //////  //////  //    //  //////  | Developed For Protheus by TOTVS            |
|    //    //  //    //     //   //  //       | ADVPL                                      |
|   //    //  //    //      // //   //////    | TOTVS Technology                           |
|  //    //  //    //       ////       //     | Duvan Arley Hernandez Niño -TOTVS Colombia.|
| //    //////    //        //    //////      | duvan.nino@totvs.com                       |
|_____________________________________________|____________________________________________|
|                                           $$$$$$                                           |
|                                         .$$$**$$                                           |
|                                         $$$"  `$$                                          |
|                                        $$$"    $$                                          |
|                                        $$$    .$$                                          |
|                                        $$    ..$$                                          |
|                                        $$    .$$$                                          |
|                                        $$   $$$$                                           |
|                                         $$$$$$$$                                           |
|                                         $$$$$$$                                            |
|                                       .$$$$$$*                                             |
|                                      $$$$$$$"                                              |
|                                    .$$$$$$$                                                |
|                                   $$$$$$"`$                                                |
|                                 $$$$$     $$.$..                                           |
|                                $$$$$    $$$$$$$$$$.                                        |
|                                $$$$   .$$$$$$$$$$$$$                                       |
|                                $$$    $$$* `$  $*$$$$                                      |
|                                $$$   `$$"   $$   $$$$                                      |
|                                3$$    $$    $$    $$$                                      |
|                                 $$$   $$$   `$    $$$                                      |
|                                 `*$$    $$$  $$  $                                         |
|                                   $$$$       $$ $$"                                        |
|                                     $$*$$$$$$$$$"                                          |
|                                          ```` $$                                           |
|                                               `$                                           |
|                                        ..      $$                                          |
|                                      $$$$$$    $$                                          |
|                                     $$$$$$$$   $$                                          |
|                                     $$$$$$$$   $$                                          |
|                                      $$$$$"  .$$                                           |
|                                       "*$$$$$$                                             |
|___________________________________________________________________________________________*/

WSRESTFUL UANDUPPAS DESCRIPTION "Servicio API Rest Para la validación de Email  |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Mail          AS STRING OPTIONAL
    WSDATA Pass          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos

    WSMETHOD GET         DESCRIPTION "Retorna información correspondiente al email Filtra por un Dato."          WSSYNTAX "/UpdPass"     PATH "/UpdPass"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod,Mail,Pass,Page, PageSize  WSREST UANDUPPAS
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

IF !Empty(Self:Mail)
    cCod := AllTrim(Upper(Self:Cod))
    cMail := AllTrim(Upper(Self:Mail))
    cPass := AllTrim(Self:Pass)

    cUpdSX3 := " UPDATE "+RetSqlName("ZZ5")+" SET ZZ5_PSW = '"+cPass+"' "
    cUpdSX3 += " WHERE ZZ5_EMAIL =  '"+cMail+"'   "
    cUpdSX3 += " AND ZZ5_CODUSU = '"+cCod+"'  "
    cUpdSX3 += " AND D_E_L_E_T_ = ''"

    TcSqlExec(cUpdSX3)
    lResult           := TCSQLEXEC(cUpdSX3)

endIF

cQuery := " SELECT ZZ5_CODUSU,ZZ5_LOGIN,ZZ5_NOME,ZZ5_EMAIL,ZZ5_PSW "
cQuery += " FROM " + RetSqlName("ZZ5")+" ZZ5 WHERE D_E_L_E_T_ <>'*' "

IF !Empty(Self:Mail)
    cCod := AllTrim(Upper(Self:Cod))
    cMail := AllTrim(Upper(Self:Mail))
    cQuery += " AND ZZ5_EMAIL  LIKE '%" + cMail + "%' "
    cQuery += " AND ZZ5_CODUSU  LIKE '%" + cCod + "%' "
endIF

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

            oTask['CODUSU']          := AllTrim((cAlias)->ZZ5_CODUSU) // Codigo Cliente
            oTask['LOGIN']        := Alltrim(EncodeUTF8((cAlias)->ZZ5_LOGIN)) //Tienda
            oTask['NOME']         := Alltrim(EncodeUTF8((cAlias)->ZZ5_NOME)) // Cuotas
            oTask['EMAIL']         := AllTrim((cAlias)->ZZ5_EMAIL) //Numero Doc
            oTask['PASS']         := AllTrim((cAlias)->ZZ5_PSW) //Numero Doc
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
oResponse['RecMail'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost
