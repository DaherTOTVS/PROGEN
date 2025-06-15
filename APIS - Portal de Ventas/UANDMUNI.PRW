#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*----------------------------------------------!
!API PARA CONSULTAR CATALOGO DE MUNICIPIOS      !
!                 JAVIER ROCHA                  !
------------------------------------------------*/

WSRESTFUL UANDMUNI DESCRIPTION "Servicio API Rest Para la consulta de Modalidades |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL
    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de las municipios Filtra por un Dato."          WSSYNTAX "/VerMunicipios"     PATH "/VerMunicipios"    // Obtiene Todos los Prodcutos o filtra un producto
END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDMUNI
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




cQuery := " SELECT CC2.CC2_FILIAL,"
cQuery += " CC2.CC2_CODMUN, "
cQuery += " CC2.CC2_MUN, "
cQuery += " CC2.CC2_EST "
cQuery += " FROM " + RetSqlName("CC2") + " CC2 "
cQuery += " WHERE "
cQuery += " CC2.CC2_FILIAL   = '"+xFilial("CC2")+"'"
cQuery += " AND CC2.D_E_L_E_T_ <> '*'"
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( CC2.CC2_CODMUN LIKE '%" + cCod + "%' OR "
    cQuery += " CC2.CC2_EST LIKE '%" + FwNoAccent( cCod ) + "%')"
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
            //oTask['banch']              :=  (cAlias)->X5_FILIAL
            oTask['code']               :=  AllTrim((cAlias)->CC2_CODMUN)
            oTask['descsri']            :=  UPPER(AllTrim(EncodeUTF8((cAlias)->CC2_MUN)))
            oTask['dep']               :=  AllTrim((cAlias)->CC2_EST)
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
oResponse['Municipios'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

