#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "TopConn.ch"

/*----------------------------------------------!
!API PARA ENVIAR CREDENCIALES DE USUARIOS       !
!                                               !
------------------------------------------------*/

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

WSRESTFUL UANDMDLIN DESCRIPTION "Servicio REST para manipula�o de usuarios/vendedores"
    WSDATA USR As String //String que vamos receber via URL
    //WSDATA PWD As String //String que vamos receber via URL

    WSMETHOD PUT DESCRIPTION "Retorna o usuario autenticado na URL" WSSYNTAX "/UANDMDLIN || /UANDMDLIN/{USR}" PATH "/UANDMDLIN"

END WSRESTFUL



WSMETHOD PUT WSRECEIVE USR WSSERVICE UANDMDLIN
    //--> Recuperamos o usuário informado via URL
    //--> Podemos fazer dessa forma ou utilizando o atributo ::aUrlParms, que é um array com os parâmetros recebidos via URL (QueryString)
    Local cUsr 		:= Self:USR
    Local aArea		:= GetArea()
    Local cAlias 	:= GetNextAlias()
    Local oResponse := JsonObject():New()
    Local lRet := .T.
    Local cJson		:= ""
    Local aTasks 	:= {}
    Local cQryAux 	:= ""


    // define o tipo de retorno do método
    FWJsonDeserialize(cJson, @oParseJSON)


    cUsr  := oParseJson:Usuario
    lFlag := .F.

    xVaLcUser(cUser, @lFlag)
    //Montando consulta de dados
    cQryAux += " SELECT ZZ5_FILIAL,ZZ5_CODUSU,ZZ5_LOGIN,ZZ5_PSW,ZZ5_NOME,ZZ5_VEND,ZZ5_EMAIL FROM "
    cQryAux += RetSqlName("ZZ5")+" ZZ5 WHERE D_E_L_E_T_ <>'*' "
    cQryAux += " AND ZZ5_FILIAL='"+xFilial("ZZ5")+"' "
    cQryAux += " AND ZZ5_EMAIL ='"+cUsr+"' "
    conout(cQryAux)
    cQryAux := ChangeQuery(cQryAux)
    MPSysOpenQuery(cQryAux,cAlias)

    (cAlias)->(DbGoTop())
    oTask := JsonObject():New()
    IF !(cAlias)->(Eof())
        IF lFlag
            aUsuario  := {}
            aAdd(aUsuario,{"ZZ5_PSW",  AllTrim(oParseJson:Pass),         NIL})
            MsExecAuto({|x, y| AdmPort(x, y)},aUsuario,4)
            If lMsErroAuto
                ConOut( "A V I S O *************** Error en la Rutina Automatica ")
                lRet := .F.
            ENDIF
        Else
            SetRestFault(400, "Usuario No registrado en el sistema, o se encuentra Bloqueado. ")
            lRet := .F.
        EndIf
    ELSE
        conout("noexiste!! Intento de Login desde el Portal")
    EndIF
    aAdd(aTasks, oTask)
    (cAlias)->(dbCloseArea())
    oResponse['ModPass'] := aTasks
    cJson := FwJsonSerialize(oResponse)

    ::SetResponse(cJson)
    FreeObj(oResponse)
    RestArea(aArea)
Return(lRet)

Static Function xVaLcUser(cUser,lFlag)
    _cAQuery:= " SELECT "
    _cAQuery+= " count(*) AS TOTAL "
    _cAQuery+= " FROM " + RetSqlName("ZZ5") + " ZZ5 "
    _cAQuery+= " WHERE "
    _cAQuery+= " ZZ5.ZZ5_FILIAL   = '"+xFilial("ZZ5")+"' "
    _cAQuery+= " AND ZZ5.D_E_L_E_T_ <> '*' "
    _cAQuery+= " AND ZZ5.ZZ5_EMAIL  = '"+UPPER(cUsr)+"' "
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

