#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*------------------------------------------!
!API PARA CONSULTAR REGLAS DE DESCUENTO     !
!                 JAVIER ROCHA              !
-------------------------------------------*/


WSRESTFUL UANDREDDET DESCRIPTION "Servicio API Rest Para la consulta de Reglas de Descuento Detalle |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de Cartera de Reglas de Descuento Detalle."          WSSYNTAX "/VerRegDDet"     PATH "/VerRegDDet"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDREDDET
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

cQuery := " SELECT  "
cQuery += " ACO.ACO_FILIAL , "
cQuery += " ACO.ACO_CODREG , "
cQuery += " ACO.ACO_DESCRI , "
cQuery += " ACO.ACO_CODCLI , "
cQuery += " ACO.ACO_LOJA , "
cQuery += " ACO.ACO_CONDPG , "
cQuery += " ACO.ACO_FAIXA , "
cQuery += " ACO.ACO_MOEDA , "
cQuery += " ACO.ACO_PERDES , "
cQuery += " ACO.ACO_TPHORA , "
cQuery += " ACO.ACO_GRPVEN , "
cQuery += " ACO.ACO_VLRDES ,  "
cQuery += " ACO.ACO_DATATE ,  "
cQuery += " ACP.ACP_FILIAL , "
cQuery += " ACP.ACP_CODREG  , "
cQuery += " ACP.ACP_ITEM, "
cQuery += " ACP.ACP_CODPRO, "
cQuery += " ACP.ACP_GRUPO, "
cQuery += " ACP.ACP_PERDES, "
cQuery += " ACP.ACP_VLRDES, "
cQuery += " ACP.ACP_TPDESC, "
cQuery += " ACP.ACP_FAIXA "
cQuery += " FROM  "  + RetSQLName('ACO') + " ACO  " + " INNER JOIN  "  + RetSQLName('ACP') + " ACP    ON ACO.ACO_CODREG = ACP.ACP_CODREG "
cQuery += " WHERE "
cQuery += " ACO.ACO_FILIAL   = '"+xFilial("ACO")+"' "
cQuery += " AND ACO.D_E_L_E_T_ <> '*' AND ACP.D_E_L_E_T_ <> '*'" //AND ACO.ACO_DATATE <= " + Date()
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ACP.ACP_CODREG LIKE '%" + cCod + "%' OR "
    cQuery += " ACO.ACO_CODCLI LIKE '%" + cCod + "%' "
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
            oTask['branch']             := AllTrim((cAlias)->ACP_FILIAL)
            oTask['code']               := AllTrim((cAlias)->ACO_CODREG)
            oTask['codecli']            := AllTrim((cAlias)->ACO_CODCLI)
            oTask['item']               := AllTrim((cAlias)->ACP_ITEM)
            oTask['productid']          := AllTrim((cAlias)->ACP_CODPRO)
            oTask['group']              := AllTrim((cAlias)->ACP_GRUPO)
            oTask['discountvalue']      := (cAlias)->ACP_VLRDES
            oTask['discountpercentage'] := (cAlias)->ACP_PERDES
            oTask['discounttype']       := (cAlias)->ACP_TPDESC
            oTask['intervalvalue']      := (cAlias)->ACP_FAIXA
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
oResponse['RegDtoDet'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

