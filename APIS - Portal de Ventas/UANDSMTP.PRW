#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDVMAIL                                           !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST PORTAL VENTAS                                  !
+------------------+---------------------------------------------------------+
!Descripcion       ! API PARA LA VALIDACION DE EMAIL EXISTENTE               !
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


WSRESTFUL UANDSMTP DESCRIPTION "Servicio API Rest Para la validación de SMTP  |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos

    WSMETHOD GET         DESCRIPTION "Retorna información correspondiente a los parametros SMTP" WSSYNTAX "/GETSMTP"     PATH "/GETSMTP"

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod,Page, PageSize  WSREST UANDSMTP
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nStart := 1
Local nReg   := 0

Default Self:Cod        := ''
Default Self:Page       := 1
//Default Self:PageSize   := 100


::SetContentType("application/json")
cAlias := GetNextAlias()

    Count To nRecord
    IF Self:Page > 1
        nStart  := ((Self:Page-1)*Self:PageSize)+1
        nReg    := nRecord-nStart+1
    ELSE
        nReg := nRecord
    EndIF
  
    IF nReg > Self:PageSize
        oResponse['hasNext'] := .T.
    ELSE
        oResponse['hasNext'] := .F.
    EndIF

    oTask := JsonObject():New()
    
    oTask['cRelAcnt']  := alltrim(supergetMV("MV_RELACNT",.f.,,))
    oTask['cRelServ']  := alltrim(supergetMV("MV_RELSERV",.f.,,))
    oTask['cRelFrom']  := alltrim(supergetMV("MV_RELFROM",.f.,,))
    oTask['cRelPsw']   := alltrim(supergetMV("MV_RELPSW",.f.,,))
    oTask['cRelAuth']  := supergetMV("MV_RELAUTH",.f.,,)
    oTask['cRelSSL']   := supergetMV("MV_RELSSL",.f.,,)
    oTask['cRelTLS']   := supergetMV("MV_RELTLS",.f.,,)
     
    oTask['FecVer']    := "18/02/2023"                       //Version Api

 
    AAdd(aTasks, oTask)


oResponse['smtp'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
RestArea(aArea)
Return lPost

