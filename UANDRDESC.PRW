#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"


/*------------------------------------------------!
!API PARA CONSULTAR CLIENTES ASIGNADOS AL USUARIO !
!                 JAVIER ROCHA                    !
--------------------------------------------------*/


WSRESTFUL UANDRDESC DESCRIPTION "Servicio API Rest Para la consulta de descuento para cliente por ufncion propia de protheus |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA cProduto          AS STRING OPTIONAL
    WSDATA cPreci          AS STRING OPTIONAL
    WSDATA cCliente          AS STRING OPTIONAL
    WSDATA cLojaCli          AS STRING OPTIONAL
    WSDATA cTabela          AS STRING OPTIONAL
    WSDATA cFaixa          AS STRING OPTIONAL
    WSDATA cCondpag          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de todos los usuarios Filtra por un Dato."          WSSYNTAX "/ReglaDescon"     PATH "/ReglaDescon"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE cProduto,cPreci,cCliente,cLojaCli,cTabela,cFaixa,cCondpag, Page, PageSize  WSREST UANDRDESC
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0
Local aRegrasExc := {}

Default Self:cProduto   := ''
Default Self:cPreci     := ''
Default Self:cCliente   := ''
Default Self:cLojaCli   := ''
Default Self:cTabela    := ''
Default Self:cFaixa     := ''
Default Self:cCondpag   := ''
Default Self:Page       := 1
//Default Self:PageSize   := 10

::SetContentType("application/json")

If (!empty(cProduto))
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
        nCount++
        IF nCount >= nStart
            nAux++
            oTask := JsonObject():New()

            
            SE4->(dbSetOrder(1))
            SE4->(DbSeek(xFilial()+cCondpag))
            nDesconto := MaRgrDesc(cProduto,cCliente,cLojaCli,cTabela,cFaixa,cCondpag,SE4->E4_FORMA,2,,aRegrasExc,/*cCodRegDe*/,cPreci)
            oTask['nDesconto'] := nDesconto
            oTask['FecVer']    := "08/09/2023"
            AAdd(aTasks, oTask)
    End
Else
    oResponse['hasNext'] := .F.
    cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
    ::SetResponse(cResponse)
EndIf
oResponse['nDesconto'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
RestArea(aArea)
Return lPost

