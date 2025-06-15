#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*----------------------------------------------!
!API PARA CONSULTAR CATALOGO DE DEPARTAMENTOS   !
!                 JAVIER ROCHA                  !
------------------------------------------------*/

WSRESTFUL UANDDEPA DESCRIPTION "Servicio API Rest Para la consulta de Modalidades |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL
    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de las municipios Filtra por un Dato."          WSSYNTAX "/VerDeptos"     PATH "/VerDeptos"    // Obtiene Todos los Prodcutos o filtra un producto
END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDDEPA
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

cQuery := " SELECT SX5.X5_FILIAL,"
cQuery += " SX5.X5_TABELA, "
cQuery += " SX5.X5_CHAVE, "
cQuery += " SX5.X5_DESCSPA "
cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
cQuery += " WHERE "
cQuery += " SX5.X5_FILIAL   = '"+xFilial("SX5")+"' AND SX5.X5_TABELA='12'"
cQuery += " AND SX5.D_E_L_E_T_ <> '*'"
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( SX5.X5_CHAVE LIKE '%" + cCod + "%' OR "
    cQuery += " SX5.X5_DESCSPA LIKE '%" + FwNoAccent( cCod ) + "%')"
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
            //oTask['tabela']               :=  AllTrim((cAlias)->X5_TABELA)
            oTask['code']               :=  AllTrim((cAlias)->X5_CHAVE)
            oTask['descsri']            :=  UPPER(AllTrim(EncodeUTF8((cAlias)->X5_DESCSPA)))
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

