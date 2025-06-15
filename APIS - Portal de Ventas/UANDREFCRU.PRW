#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*----------------------------------------------!
!API PARA CONSULTAR REFERENCIAS CRUZADAS        !
!                 JAVIER ROCHA                  !
------------------------------------------------*/


WSRESTFUL UANDREFCRU DESCRIPTION "Servicio API Rest Para la consulta de Reglas de Descuento Encabezado |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de Cartera de Reglas de Descuento Encabezado."          WSSYNTAX "/VerRefCru"     PATH "/VerRefCru"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDREFCRU
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

cQuery := " SELECT "

cQuery += " A7_FILIAL,"
cQuery += " A7_CLIENTE, "
cQuery += " A7_LOJA, "
cQuery += " A7_PRODUTO, "
cQuery += " A7_CODCLI, "
cQuery += " A7_DESCCLI, "
cQuery += " A7_PRECO01 "
cQuery += " FROM " + RetSqlName("SA7") + " SA7"
cQuery += " WHERE SA7.D_E_L_E_T_ <> '*' "
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND A7_CLIENTE LIKE '%" + cCod + "%' OR "
    cQuery += " A7_PRODUTO LIKE '%" + cCod + "%'"
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
            oTask['branch']             := AllTrim((cAlias)->A7_FILIAL)
            oTask['cliente']               := AllTrim((cAlias)->A7_CLIENTE)
            oTask['branch']               := AllTrim(EncodeUTF8((cAlias)->A7_LOJA))
            oTask['codepro']        := AllTrim(EncodeUTF8((cAlias)->A7_PRODUTO))
            oTask['codecli']           := AllTrim(EncodeUTF8((cAlias)->A7_CODCLI))
            oTask['descripcli']      := AllTrim(EncodeUTF8((cAlias)->A7_DESCCLI))
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
oResponse['RefCruzada'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

