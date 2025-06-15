#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"


/*------------------------------------------------!
!API PARA CONSULTAR CLIENTES ASIGNADOS AL USUARIO !
!                 JAVIER ROCHA                    !
--------------------------------------------------*/


WSRESTFUL UANDDIREC DESCRIPTION "Servicio API Rest Para la consulta de direccion de clientes por usuario del portal |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Loj          AS STRING OPTIONAL
    WSDATA Est          AS STRING OPTIONAL
    WSDATA Mun          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de todos los usuarios Filtra por un Dato."          WSSYNTAX "/VerDirCli"     PATH "/VerDirCli"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Loj,Est, Page, Mun, PageSize  WSREST UANDDIREC
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0

Default Self:Cod        := ''
Default Self:Loj        := ''
Default Self:Est        := ''
Default Self:Mun        := ''
Default Self:Page       := 1
//Default Self:PageSize   := 10

// A1_LC - (A1_SALDUP + A1_SALPEDL)
::SetContentType("application/json")
cAlias := GetNextAlias()
cQuery := "SELECT  "
cQuery += " ZZE_COD,  "
cQuery += " ZZE_CODCL, "
cQuery += " ZZE_LOJC,  "
cQuery += " ZZE_EST,  "
cQuery += " ZZE_MUN, "
cQuery += " ZZE_DIRECC  "
cQuery += " FROM "  + RetSQLName('ZZE') + " ZZE "
cQuery += " WHERE  "
cQuery += " ZZE_FILIAL   = '"+xFilial("ZZE")+"'"
cQuery += " AND D_E_L_E_T_ <> '*'
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cLoj := AllTrim(Upper(Self:Loj))
    cQuery += " AND ZZE_CODCL = '" + cCod + "'
    cQuery += " AND ZZE_LOJC = '" + cLoj + "'
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
            oTask['code']          := ALLTRIM((cAlias)->ZZE_COD)                          //Filial
            oTask['clie']            := ALLTRIM((cAlias)->ZZE_CODCL)                             //Codigo
            oTask['loja']             := ALLTRIM((cAlias)->ZZE_LOJC)                             //RUC
            oTask['est']    := (cAlias)->ZZE_EST                       //Total Debitos
            oTask['mun']    := (cAlias)->ZZE_MUN                       //Total Creditos        
            oTask['direc']    := Alltrim(EncodeUTF8((cAlias)->ZZE_DIRECC))   //Nombre municipio entrega
            oTask['FecVer']    := "14/04/2024"                       //Version Api
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
oResponse['Dirxclien'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

