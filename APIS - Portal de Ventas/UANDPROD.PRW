#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#include 'fileio.ch'
/*---------------------------------------------------------------------------+
! FICHA TECNICA DEL PROGRAMA !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA !
+------------------+---------------------------------------------------------+
!Tipo ! API UANDPROD !
+------------------+---------------------------------------------------------+
!Modulo ! API REST !
+------------------+---------------------------------------------------------+
!Descripcion ! API UANDALMAC encargada de realizar la consulta !
! ! Productos !
! ! Funcionalidades Adicionadas. !
! ! 1. Consulta !
! ! * Filtra por Codigo, Descripcion !
! ! !
! ! !
! ! !
! ! !
! ! !
! ! !
+------------------+---------------------------------------------------------+
!Autor ! Gabriel Alejandro Pulido !
+------------------+---------------------------------------------------------+
!Fecha creacion ! 01-2022 !
+------------------+---------------------------------------------------------+
! ATUALIZACIONES !
+-------------------------------------------+-----------+-----------+--------+
!Descripcion detallada de la actualizacion !Nombre del ! Analista !FEcha de!
! !Solicitante! Respons. !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! ! ! ! !
! ! ! ! !
! ! ! ! !
+-------------------------------------------+-----------+-----------+--------+
|________________________________________________________________________________________|
| ////// ////// ////// // // ////// | Developed For Protheus by TOTVS |
| // // // // // // // | ADVPL |
| // // // // // // ////// | TOTVS Technology |
| // // // // //// // | Gabriel Alejandro Pulido -TOTVS Colombia.|
| // ////// // // ////// | gabriel.pulido@totvs.com |
|_____________________________________________|__________________________________________|
| _______ _______ _________ _______ _______ _______ _________ |
| ( ___ ) ( ____ ) \__ __/ ( ____ ) ( ____ \ ( ____ \ \__ __/ |
| | ( ) | | ( )| ) ( | ( )| | ( \/ | ( \/ ) ( |
| | (___) | | (____)| | | | (____)| | (__ | (_____ | | |
| | ___ | | _____) | | | __) | __) (_____ ) | | |
| | ( ) | | ( | | | (\ ( | ( ) | | | |
| | ) ( | | ) ___) (___ | ) \ \__ | (____/\ /\____) | | | |
| |/ \| |/ \_______/ |/ \__/ (_______/ \_______) )_( |
|________________________________________________________________________________________|
| |
| ## ## ######## ######## ####### ######## ####### ###### ## |
| ### ### ## ## ## ## ## ## ## ## ## ## #### |
| #### #### ## ## ## ## ## ## ## ## ## ## |
| ## ### ## ###### ## ## ## ## ## ## ## ###### |
| ## ## ## ## ## ## ## ## ## ## ## ## |
| ## ## ## ## ## ## ## ## ## ## ## ## #### |
| ## ## ######## ## ####### ######## ####### ###### ## |
| |
| |
| ###### ######## ######## |
| ## ## ## ## |
| ## ## ## |
| ## #### ###### ## |
| ## ## ## ## |
| ## ## ## ## ### |
| ###### ######## ## ### |
| |
|----------------------------------------------------------------------------------------|
| _==/ \== |
| /XX/ |\___/| \XX\ |
| /XXXX\ |XXXXX| /XXXX\ |
| |XXXXXX\_ _XXXXXXX_ _/XXXXXX| |
| XXXXXXXXXXXxxxxxxxXXXXXXXXXXXxxxxxxxXXXXXXXXXXX |
| |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| |
| XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
| |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| |
| XXXXXX/^^^^"\XXXXXXXXXXXXXXXXXXXXX/^^^^^\XXXXXX |
| |XXX| \XXX/^^\XXXXX/^^\XXX/ |XXX| |
| \XX\ \X/ \XXX/ \X/ /XX/ |
| "\       " \X/ "       /" |
|________________________________________________________________________________________|
| // //// // // ////// // |
| // // // // // // // // // |
| // // // // // // ////// // |
| /////// // // //// // // |
| // // //// // // /////// |
|_______________________________________________________________________________________*/


WSRESTFUL UANDPROD DESCRIPTION "Servicio API Rest Para la consulta / Modificacion de Productos Bienes o Servicios |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod AS STRING OPTIONAL
    WSDATA Page AS INTEGER OPTIONAL
    WSDATA PageSize AS INTEGER OPTIONAL

    //Metodos
    WSMETHOD GET DESCRIPTION "Retorna listado de todos los Productos o Filtra por un Dato." WSSYNTAX "/VerProducto" PATH "/VerProducto" // Obtiene Todos los Prodcutos o filtra un producto
    // WSMETHOD PUT DESCRIPTION "Actualiza la informacin de un Producto" WSSYNTAX "/ActProducto" PATH "/ActProducto" // Modifica un Producto
    // WSMETHOD POST DESCRIPTION "Crea un nuevo Producto" WSSYNTAX "/CreProducto" PATH "/CreProducto" // Crea un Nuevo Producto
    // WSMETHOD DELETE DESCRIPTION "Borra un Producto" WSSYNTAX "/BorProducto" PATH "//BorProducto" // Borra un Prodcuto
END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET WSRECEIVE Cod, Page, PageSize WSREST UANDPROD
Local aArea := GetArea()
Local lPost := .T.
Local oResponse := JsonObject():New()
Local aTasks := {}
Local nCount := 0
Local nStart := 1
Local nReg := 0
Local nAux := 0

Default Self:Cod := " "
Default Self:Page := 1
//Default Self:PageSize := 100



::SetContentType("application/json")
nTot := 0


cAlias := GetNextAlias()
cQuery := " SELECT "
cQuery += " SB1.B1_FILIAL, "
cQuery += " SB1.B1_COD, "
cQuery += " SB1.B1_DESC, "
cQuery += " SB1.B1_TIPO, "
cQuery += " SB1.B1_GRUPO, "
cQuery += " SB1.B1_UM, "
cQuery += " SB1.B1_LOCPAD, "
cQuery += " SB1.B1_TS, "
cQuery += " SB1.B1_PRV1 "
cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
cQuery += " WHERE "
cQuery += " SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
//cQuery += " AND SB1.B1_TIPO = 'PT' "
//Filtros
conout(Self:Cod)
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( SB1.B1_COD LIKE '%" +alltrim(cCod)+ "%' OR "
    cQuery += " SB1.B1_DESC LIKE '%" +alltrim(cCod)+ "%' OR "
    cQuery += " SB1.B1_GRUPO LIKE '%" +alltrim(cCod)+ "%' ) "
EndIF
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery, cAlias)
Count To nRecord
ProcRegua(nRecord)
If (cAlias)->(!Eof())
    Count To nRecord
    IF Self:Page > 1
        nStart := ((Self:Page-1)*Self:PageSize)+1
        nReg := nRecord-nStart+1
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


            oTask['TotItems'] := nRecord //Precio de Venta
            oTask['branch'] := AllTrim((cAlias)->B1_FILIAL) //Sucursal
            oTask['code'] := EncodeUTF8((cAlias)->B1_COD) //Codigo Producto
            oTask['name'] := AllTrim(EncodeUTF8( ( cAlias )->B1_DESC)) //Descripcion de Producto
            oTask['producttype'] := AllTrim((cAlias)->B1_TIPO) //Tipo de Producto
            oTask['productgroup'] := AllTrim((cAlias)->B1_GRUPO) //Grupo de Productos
            oTask['unit'] := AllTrim((cAlias)->B1_UM) //Unidad de Medida
            oTask['warehouse'] := AllTrim((cAlias)->B1_LOCPAD) //Almacen
            oTask['saleprice'] := (cAlias)->B1_PRV1 //Precio de Venta
            oTask['tes'] := (cAlias)->B1_TS //Tes De Salida
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



nTot := 0
cDat := ""
cDat := Self:Cod
xValCt(cDat,@nTot)



oResponse['product'] := aTasks
oResponse['Tot_Prod'] := nTot
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost




Static Function xValCt(cDat,nTot)
    _cAQuery:= " SELECT "
    _cAQuery+= " count(*) AS TOTAL "
    _cAQuery+= " FROM " + RetSqlName("SB1") + " SB1 "
    _cAQuery+= " WHERE "
    _cAQuery+= " SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
    _cAQuery+= " AND SB1.D_E_L_E_T_ <> '*' "
    _cAQuery+= " AND SB1.B1_TIPO = 'PT' "
    //Filtros
    IF !Empty(cDat)
        cCod := AllTrim(Upper(cDat))
        _cAQuery+= " AND ( SB1.B1_COD LIKE '%" +alltrim(cCod)+ "%' OR "
        _cAQuery+= " SB1.B1_DESC LIKE '%" +alltrim(cCod)+ "%' OR "
        _cAQuery+= " SB1.B1_GRUPO LIKE '%" +alltrim(cCod)+ "%' ) "
    EndIF
    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    While !_aQRY->(EOF())
        nTot := _aQRY->TOTAL
        _aQRY->(dbSkip())
    EndDo
    _aQRY->(dbCloseArea())

Return (nTot)
