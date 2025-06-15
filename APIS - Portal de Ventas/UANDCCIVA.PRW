#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "Topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*------------------------------------------------!
!API PARA CONSULTAR PORCENTAJE DE IVA POR PRODUCTO!
!               JAVIER ROCHA                      !
--------------------------------------------------*/

WSRESTFUL UANDCCIVA DESCRIPTION "Servicio API Rest Para la consulta de USUARIOs por usuario del portal 'Lugares de Stock' |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de todos los usuarios Filtra por un Dato."          WSSYNTAX "/VerIvaProd"     PATH "/VerIvaProd"    // Obtiene ecabezado de reglas de negocio.

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDCCIVA
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
//Default Self:PageSize   := 10
::SetContentType("application/json")
cAlias := GetNextAlias()
cQuery := " SELECT  "
cQuery += " SB1.B1_COD , "
cQuery += " SB1.B1_TS , "
cQuery += " SF4.F4_CODIGO , "
cQuery += " SF4.F4_FINALID, "
cQuery += " SFC.FC_IMPOSTO, "
cQuery += " SFC.FC_INCDUPL, "
cQuery += " SFB.FB_CODIGO, "
cQuery += " SFB.FB_DESCR, "
cQuery += " SFB.FB_ALIQ"
cQuery += " FROM " + RetSqlName("SB1") + " SB1,  " +  RetSqlName("SF4") + " SF4,  " +  RetSqlName("SFC") + " SFC,  " +  RetSqlName("SFB") + " SFB  "
cQuery += " WHERE "
cQuery += " SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
cQuery += " AND SB1.B1_TS = SF4.F4_CODIGO AND SF4.F4_CODIGO=SFC.FC_TES AND SFC.FC_INCDUPL='1' AND SFC.FC_IMPOSTO=SFB.FB_CODIGO"
cQuery += " AND SF4.F4_TIPO='S' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' AND SF4.D_E_L_E_T_ <> '*' AND SFC.D_E_L_E_T_ <> '*' AND SFB.D_E_L_E_T_ <> '*' "
//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND SB1.B1_COD='" + cCod + "' "
    //cQuery += " ACO.ACO_CODREG LIKE '%" + cCod + "%')"
EndIF
//cQuery += " GROUP BY SB1.B1_COD , SB1.B1_TS , SF4.F4_CODIGO , SF4.F4_FINALID, SFC.FC_IMPOSTO, SFC.FC_INCDUPL, SFB.FB_CODIGO, SFB.FB_DESCR, SFB.FB_ALIQ "
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
            oTask['codeprod']               := Alltrim(EncodeUTF8((cAlias)->B1_COD))
            oTask['tesprd']               := Alltrim((cAlias)->B1_TS)      
            oTask['nametes']               := Alltrim(EncodeUTF8(( cAlias )->F4_FINALID)) 
            oTask['imputes']               := Alltrim((cAlias)->FC_IMPOSTO)      
            oTask['descrimp']               := Alltrim(EncodeUTF8((cAlias)->FB_DESCR))
            oTask['porcimp']               := (cAlias)->FB_ALIQ
            oTask['FecVer']    := "24/12/2023"                       //Version Api
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
oResponse['IvaProd'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost


