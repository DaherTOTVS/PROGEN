#INCLUDE "totvs.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#include 'fileio.ch'

#DEFINE LOG_DIRECTORY               "\log_integ"
#DEFINE LOG_DIRECTORY               "\log_integ"
#DEFINE TYPE_OF_NORMAL_REQUEST      "N"
#DEFINE OPEN_REQUEST                "pedido em aberto"
#DEFINE APPLICATION_CLOSED          "pedido encerrado"
#DEFINE REQUEST_RELEASED            "pedido liberado"
#DEFINE REQUEST_BLOCKED_BY_RULE     "pedido bloqueado por regra"
#DEFINE REQUEST_BLOCKED_BY_FUNDS    "pedido bloqueado por verba"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DEL PROGRAMA                           !
+----------------------------------------------------------------------------+
!DATOS DEL PROGRAMA                                                          !
+------------------+---------------------------------------------------------+
!Tipo              ! API UANDPVPRU                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! API REST Clientes                                       !
+------------------+---------------------------------------------------------+
!Descripcion       ! API UANDALMAC encargada de realizar la consulta         !
!                  ! y adicion de Clientes                                   !
!                  !                                                         !
!                  !   1. Consulta de Cartera                                !
!                  !   * Filtra por RUC, Nombre                              !
                   !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
!
+------------------+---------------------------------------------------------+
!Autor             ! Gabriel Alejandro Pulido                                !
+------------------+---------------------------------------------------------+
!Fecha creacion    !  01-2022                                                !
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
|________________________________________________________________________________________|
|   //////  //////  //////  //    //  //////  | Developed For Protheus by TOTVS          |
|    //    //  //    //     //   //  //       | ADVPL                                    |
|   //    //  //    //      // //   //////    | TOTVS Technology                         |
|  //    //  //    //       ////       //     | Gabriel Alejandro Pulido -TOTVS Colombia.|
| //    //////    //        //    //////      | gabriel.pulido@totvs.com                 |
|_____________________________________________|__________________________________________|
|          _______   _______  _________    _______   _______   _______  _________        |
|         (  ___  ) (  ____ ) \__   __/   (  ____ ) (  ____ \ (  ____ \ \__   __/        |
|         | (   ) | | (    )|    ) (      | (    )| | (    \/ | (    \/    ) (           |
|         | (___) | | (____)|    | |      | (____)| | (__     | (_____     | |           |
|         |  ___  | |  _____)    | |      |     __) |  __)    (_____  )    | |           |
|         | (   ) | | (          | |      | (\ (    | (             ) |    | |           |
|         | )   ( | | )       ___) (___   | ) \ \__ | (____/\ /\____) |    | |           |
|         |/     \| |/        \_______/   |/   \__/ (_______/ \_______)    )_(           |
|________________________________________________________________________________________|
|                                                                                        |
|           ##     ## ######## ########  #######  ########   #######   ######    ##      |
|           ###   ### ##          ##    ##     ## ##     ## ##     ## ##    ##  ####     |
|           #### #### ##          ##    ##     ## ##     ## ##     ## ##         ##      |
|           ## ### ## ######      ##    ##     ## ##     ## ##     ##  ######            |
|           ##     ## ##          ##    ##     ## ##     ## ##     ##       ##   ##      |
|           ##     ## ##          ##    ##     ## ##     ## ##     ## ##    ##  ####     |
|           ##     ## ########    ##     #######  ########   #######   ######    ##      |
|                                                                                        |
|                                                                                        |
|                                                                                        |
|               ########   #######   ######  ########                                    |
|               ##     ## ##     ## ##    ##    ##                                       |
|               ##     ## ##     ## ##          ##                                       |
|               ########  ##     ##  ######     ##                                       |
|               ##        ##     ##       ##    ##                                       |
|               ##        ##     ## ##    ##    ##    ###                                |
|               ##         #######   ######     ##    ###                                |
|                                                                                        |
|                                                                                        |
|                                                                                        |
|----------------------------------------------------------------------------------------|
|                          _==/                             \==                          |
|                         /XX/            |\___/|            \XX\                        |
|                       /XXXX\            |XXXXX|            /XXXX\                      |
|                      |XXXXXX\_         _XXXXXXX_         _/XXXXXX|                     |
|                      XXXXXXXXXXXxxxxxxxXXXXXXXXXXXxxxxxxxXXXXXXXXXXX                   |
|                     |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|                  |
|                     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                  |
|                     |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|                  |
|                      XXXXXX/^^^^"\XXXXXXXXXXXXXXXXXXXXX/^^^^^\XXXXXX                   |
|                      |XXX|       \XXX/^^\XXXXX/^^\XXX/       |XXX|                     |
|                        \XX\       \X/    \XXX/    \X/       /XX/                       |
|                           "\       "      \X/      "       /"                          |
|________________________________________________________________________________________|
|                          //       ////    //   //   //////   //                        |
|                        // //     //  //   //  //   //  //   //                         |
|                       //  //    //  //    // //   //////   //                          |
|                      ///////   //  //     ////   //       //                           |
|                     //    //  ////        //    //       ///////                       |
|_______________________________________________________________________________________*/



WSRESTFUL UANDPVCRE DESCRIPTION "Servicio API Rest Para la Inclusion de Pedidos de Venta |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "

    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD POST        DESCRIPTION "Crea un nuevo Pedido de Venta  en el sistema Protheus  "                          WSSYNTAX "/CrePedido"     PATH "/CrePedido"   // Crea un Nuevo Producto
    // WSMETHOD PUT      DESCRIPTION "Actualiza la informacin de un Pedido de Venta - Aprobacion"              WSSYNTAX "/ActPedido"     PATH "/ActPedido"    // Modifica un Producto

END WSRESTFUL



WSMETHOD POST WSRECEIVE   WSSERVICE UANDPVCRE
    Local cJSON := Self:GetContent() // Pega a string do JSON
    Local oParseJSON := Nil
    Local cJsonRet := ""
    Local cArqLog := ""
    Local cErro := ""
    Local nX := 0
    Local lRet := .T.
    Local DireccionEnt := ""
    // Local cCodCli := ""
    // Local cLoja  := ""

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.



    // –> Cria o diretório para salvar os arquivos de log
    If !ExistDir("_RESTLOG\log_cli")
        MakeDir("_RESTLOG\log_cli")
    EndIf

    // –> Deserializa a string JSON

    FWJsonDeserialize(cJson, @oParseJSON)

    //Validaciones adicionadas si faltan datos:#INCLUDE
    IF Empty( AllTrim(oParseJson:Client))
        SetRestFault(400, "O cliente não foi informado.")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:Store))
        SetRestFault(400, "No se informo la Tienda del Cliente.")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:DeliveryStore))
        SetRestFault(400, "No se informo la tienda de entrega.")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:PaymentTerms))
        SetRestFault(400, "No se informo la condicion de Pago.")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:Cliente))
        SetRestFault(400, "Nenhuma entrega do cliente foi relatada.")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:DireccionEnt))
        SetRestFault(400, "No se informo la direcciòn de entrega")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:DepartamentonEnt))
        SetRestFault(400, "No se informo Departamento de entrega")
        Return .F.
    ElseIf Empty(AllTrim(oParseJson:MunicipioEnt))
        SetRestFault(400, "No se informo la Municipio de entrega")
        Return .F.
    EndIf

    cClie  := oParseJson:Client
    cLoj  := oParseJson:Store
    lFlag := .F.

    xVaLcLI(cClie, cLoj, @lFlag)

    cQryI :="SELECT MAX(C5_NUM) Num"
    cQryI +=" FROM "+RetSqlName("SC5")
    cQryI +=" WHERE  D_E_L_E_T_<>'*' "
    cQryI  := ChangeQuery(cQryI )
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryI),"QRYITM",.F.,.T.)
    if !QRYITM->(EOF())
        cNum:=IIF(VAL(QRYITM->Num)>0,soma1(QRYITM->Num),"000001")
        QRYITM->(dbCloseArea())
    endif


    IF lFlag
        aCabec  := {}
        aItens  := {}
        cNumItem := 0

        //cPedido := GetSXENum("SC5","C5_NUM")
        aAdd(aCabec,{"C5_NUM",  cNum,    NIL})
        aAdd(aCabec,{"C5_TIPO",     TYPE_OF_NORMAL_REQUEST,             NIL})
        aAdd(aCabec,{"C5_NATUREZ",  AllTrim(oParseJson:Nature),         NIL})
        aAdd(aCabec,{"C5_CLIENTE",  AllTrim(oParseJson:Client),         NIL}) 
        aAdd(aCabec,{"C5_LOJAENT",  AllTrim(oParseJson:DeliveryStore),  NIL})    
        
        aAdd(aCabec,{"C5_CLIENT",  AllTrim(oParseJson:Cliente),         NIL})
        IF "01" $ cEmpAnt
            aAdd(aCabec,{"C5_TIPOPE",  '10', NIL})
        ELSE
            aAdd(aCabec,{"C5_TIPOPE",  '', NIL})
        ENDIF
        aAdd(aCabec,{"C5_DOCGER",  '2', NIL})

        DireccionEnt := AllTrim(DecodeUTF8(oParseJson:DireccionEnt))
        If (EMPTY(DireccionEnt))
            DireccionEnt := AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oParseJson:Client+oParseJson:Store, "A1_ENDENT"))
        EndIf
        
        aAdd(aCabec,{"C5_LOJACLI",  AllTrim(oParseJson:Store),          NIL}) 
        aAdd(aCabec,{"C5_DESC1",  oParseJson:Descuent, NIL})
        aAdd(aCabec,{"C5_XUSERPT",  UPPER(oParseJson:Usuario), NIL})
        aAdd(aCabec,{"C5_XENDENT",  DireccionEnt, NIL})
        aAdd(aCabec,{"C5_XEST",  AllTrim(oParseJson:DepartamentonEnt), NIL})
        aAdd(aCabec,{"C5_XCOD_MU",  AllTrim(oParseJson:MunicipioEnt), NIL})
        aAdd(aCabec,{"C5_XNOME",  AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oParseJson:Client+oParseJson:Store, "A1_NOME")),         NIL})
        aAdd(aCabec,{"C5_XNCLIEN",  AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oParseJson:Cliente+oParseJson:DeliveryStore, "A1_NREDUZ")),         NIL})
        aAdd(aCabec,{"C5_XMUN",  AllTrim(POSICIONE("CC2", 1, xFilial("CC2") + padr(oParseJson:DepartamentonEnt,TamSx3("CC2_EST")[1])+padr(oParseJson:MunicipioEnt,TamSx3("CC2_CODMUN")[1]), "CC2_MUN")),         NIL})
        aAdd(aCabec,{"C5_CONDPAG",  AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oParseJson:Client+oParseJson:Store, "A1_COND")),         NIL})

        aAdd(aCabec,{"C5_XEMAIL",  AllTrim(POSICIONE("SA1", 1, xFilial("SA1") + oParseJson:Client+oParseJson:Store, "A1_EMAIL")),         NIL})
        aAdd(aCabec,{"C5_TPDOC",  '01', NIL})
        
        aAdd(aCabec,{"C5_MENNOTA",  AllTrim(DecodeUTF8(oParseJson:MessageForNote)), NIL})
        //Busca os itens no JSON, percorre eles e adiciona no array da SC6
        cNumItem := StrZero(0,TamSX3("C6_ITEM")[1])

        EDesc := .F.

        If oParseJson:EDesc != Nil 
            If oParseJson:EDesc == '2'
                EDesc := .T.
            EndIf
        EndIf
        
        For nX  := 1 To Len (oParseJson:Items)
            alinha  := {}
            
            cNumItem :=Soma1(cNumItem)
            aRegrasExc:={}
            // nDesconto := MaRgrDesc(cProduto,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_TABELA,aCols[n,nPQtdVen],M->C5_CONDPAG,SE4->E4_FORMA,1,,aRegrasExc,/*cCodRegDe*/,nPrcBase)

            // nDesconto := MaRgrDesc(AllTrim(oParseJson:Items[nX]:Product),AllTrim(oParseJson:Client),AllTrim(oParseJson:DeliveryStore),'101',2,AllTrim(oParseJson:PaymentTerms),'',1,,aRegrasExc,/*cCodRegDe*/, oParseJson:Items[nX]:SalesPrice)

            aAdd(aLinha,{"C6_ITEM",     cNumItem,                                  NIL})
            aAdd(aLinha,{"C6_CLI",     AllTrim(oParseJson:Client),                                  NIL})
            aAdd(aLinha,{"C6_LOJA",     AllTrim(oParseJson:DeliveryStore),                                  NIL})
            aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oParseJson:Items[nX]:Product),          NIL})
            aAdd(aLinha,{"C6_QTDVEN",   oParseJson:Items[nX]:SalesQuantity,             NIL})
            if oParseJson:Items[nX]:SalesPrice > 0
             aAdd(aLinha,{"C6_PRCVEN",   oParseJson:Items[nX]:SalesPrice,                NIL})

            EndIF
            

            // nDesconto := MaRgrDesc(AllTrim(oParseJson:Items[nX]:Product), AllTrim(oParseJson:Client), AllTrim(oParseJson:DeliveryStore),AllTrim(oParseJson:Lpreci),oParseJson:Items[nX]:SalesQuantity,AllTrim(oParseJson:PaymentTerms),'      ',1,,{},,0)
            
            If EDesc
            // IF oParseJson:Items[nX]:Pordesc <= 0 
            //     nDesconto := MaRgrDesc(AllTrim(oParseJson:Items[nX]:Product), AllTrim(oParseJson:Client), AllTrim(oParseJson:DeliveryStore),AllTrim(oParseJson:Lpreci),oParseJson:Items[nX]:SalesQuantity,AllTrim(oParseJson:PaymentTerms),'      ',1,,{},,0)
            // Else
                 aAdd(aLinha,{"C6_DESCONT",   oParseJson:Items[nX]:Pordesc,                NIL})
            // EndIF
            EndIF

            // aAdd(aLinha,{"C6_TES",    AllTrim(oParseJson:Items[nX]:InputTypeOutPut),  NIL})
            aAdd(aLinha,{"C6_TES",    AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + oParseJson:Items[nX]:Product, "B1_TS")),  NIL})

            aAdd(aLinha,{"C6_VDOBS",      AllTrim(DecodeUTF8(oParseJson:Items[nX]:Infoadicional)),  NIL})

            nCC   := ""
            nNaturez := AllTrim(oParseJson:Nature)
            nCli  := AllTrim(oParseJson:Client)
            nLoj  := AllTrim(oParseJson:DeliveryStore)
            nProd := AllTrim(oParseJson:Items[nX]:Product)

            IF "01" $ cEmpAnt

                IF alltrim(nNaturez)$"0300102/0300113/0300114"
                    nCC := Posicione("SA1",1,xFilial("SA1")+nCli+nLoj,"A1_XCC")            
                elseif  alltrim(nNaturez)$"0300103"
                    nCC := "VT17"
                Else
                    nCC := Posicione("SB1",1,xFilial("SB1")+nProd,"B1_CC")
                EndIf

            ELSE
                nCC := Posicione("SA1",1,xFilial("SA1")+padr(nCli,TamSx3("C5_CLIENTE")[1])+nLoj,"A1_XCC") 
            ENDIF
            // conout("portal",padr(nCli,TamSx3("C5_CLIENTE")[1]),nCC)

            aAdd(aLinha,{"C6_CC", nCC,  NIL})


            aAdd(aItens,aLinha)
        Next nX
        MsExecAuto({|x, y, z| MATA410(x, y, z)},aCabec,aItens,3)
        If lMsErroAuto

            ConOut( "A V I S O *************** Error en la Rutina Automatica ")
            ConOut( "A V I S O *************** Error en la Rutina Automatica ")


            cArqLog := +oParseJson:Client+oParseJson:Store + "-" +SubStr(Time(),1,5)+dTOS(Date()) + ".log"
            cErro := MostraErro("_RESTLOG\log_cli", cArqLog)
            SetRestFault(400, cErro)
            lRet := .F.
        Else
            //ConfirmSX8()
            cJSONRet := "Pedido de venta creado con exito, No Pedido: " +cNum + ". "
            ::SetResponse( cJSONRet )
        EndIf
    Else
        SetRestFault(400, "Cliente No registrado en el sistema, o se encuentra Bloqueado. ")
        lRet := .F.
    EndIf
Return(lRet)




Static Function xVaLcLI(cClie,cLoja,lFlag)
    _cAQuery:= " SELECT "
    _cAQuery+= " count(*) AS TOTAL "
    _cAQuery+= " FROM " + RetSqlName("SA1") + " SA1 "
    _cAQuery+= " WHERE "
    _cAQuery+= " SA1.A1_FILIAL   = '"+xFilial("SA1")+"' "
    _cAQuery+= " AND SA1.D_E_L_E_T_ <> '*' AND SA1.A1_MSBLQL =  '2' "
    _cAQuery+= " AND SA1.A1_COD  = '"+cClie+"'  AND SA1.A1_LOJA = '"+cLoja+"'  "
    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    While !_aQRY->(EOF())
        nTot := _aQRY->TOTAL
        _aQRY->(dbSkip())
    EndDo
    _aQRY->(dbCloseArea())

    If nTot >= 1
        lFlag := .T.
    Else
        lFlag := .F.
    EndIf


Return (lFlag)
