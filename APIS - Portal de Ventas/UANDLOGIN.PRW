#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
#Include "TopConn.ch"
 
/*----------------------------------------------!
!API PARA ENVIAR CREDENCIALES DE USUARIOS       !
!                 AXEL DIAZ                     !
------------------------------------------------*/

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
 
WSRESTFUL UANDLOGIN DESCRIPTION "Servicio REST para manipula�o de usuarios/vendedores"
WSDATA USR As String //String que vamos receber via URL
WSDATA PWD As String //String que vamos receber via URL
 
WSMETHOD POST DESCRIPTION "Retorna o usuario autenticado na URL" WSSYNTAX "/UANDLOGIN || /UANDLOGIN/{USR}{PWD}" PATH "/UANDLOGIN"

END WSRESTFUL
 
 

WSMETHOD POST WSRECEIVE USR,PWD WSSERVICE UANDLOGIN
//--> Recuperamos o usuário informado via URL 
//--> Podemos fazer dessa forma ou utilizando o atributo ::aUrlParms, que é um array com os parâmetros recebidos via URL (QueryString)
Local cUsr 		:= Self:USR
Local cPwd 		:= Self:PWD
Local aArea		:= GetArea()
Local cAlias 	:= GetNextAlias()
Local oResponse := JsonObject():New()
Local cJson		:= ""
Local aTasks 	:= {}
Local cQryAux 	:= ""

 
// define o tipo de retorno do método
::SetContentType("application/json")

 
//Montando consulta de dados
cQryAux := ""
cQryAux += " SELECT ZZ5_FILIAL,ZZ5_CODUSU,ZZ5_LOGIN,ZZ5_PSW,ZZ5_NOME,ZZ5_VEND,ZZ5_EMAIL,ZZ5_DESCUE,ZZ5_EDPREC FROM "
cQryAux += RetSqlName("ZZ5")+" ZZ5 WHERE D_E_L_E_T_ <>'*' "
cQryAux += " AND ZZ5_FILIAL='"+xFilial("ZZ5")+"' "
cQryAux += " AND ZZ5_PSW='"+cPwd+"' AND ZZ5_EMAIL ='"+cUsr+"' "
conout(cQryAux)
cQryAux := ChangeQuery(cQryAux)
MPSysOpenQuery(cQryAux,cAlias) 

(cAlias)->(DbGoTop())
oTask := JsonObject():New()
IF !(cAlias)->(Eof())
	conout("usuario portal auth:"+(cAlias)->ZZ5_CODUSU)
	oTask['CODUSU']   :=(cAlias)->ZZ5_CODUSU
	oTask['LOGIN']    :=Alltrim(EncodeUTF8((cAlias)->ZZ5_LOGIN))
	oTask['NOME']     :=Alltrim(EncodeUTF8((cAlias)->ZZ5_NOME))
	oTask['VEND']     :=(cAlias)->ZZ5_VEND
	oTask['EMAIL']    :=(cAlias)->ZZ5_EMAIL
	oTask['DESCUENTO']    :=(cAlias)->ZZ5_DESCUE
 	// oTask['MODPREC']    :=(cAlias)->ZZ5_MODPREC
	oTask['MODPREC']    := (cAlias)->ZZ5_EDPREC
//	oTask['CLIENT']    :=(cAlias)->ZZ5_CODCLI
//	oTask['STORE']    :=(cAlias)->ZZ5_LOJACL
	oTask['EXITO']    :="1"
ELSE
	oTask['CODUSU']   :=" "
	oTask['LOGIN']    :=" "
	oTask['NOME']     :=" "
	oTask['VEND']     :=" "
	oTask['EMAIL']    :=" "
	oTask['DESCUENTO']    :=" "
	oTask['MODPREC']    :="2"
//	oTask['CLIENT']    :=" "
//  oTask['STORE']    :=" "
	oTask['EXITO']    :="0"
	conout("noexiste!! Intento de Login desde el Portal")
	
EndIF
aAdd(aTasks, oTask)
(cAlias)->(dbCloseArea())
oResponse['UserData'] := aTasks
cJson := FwJsonSerialize(oResponse)

::SetResponse(cJson)
FreeObj(oResponse)
RestArea(aArea)
Return(.T.)
 


User Function LARESTA2()
Return
 
USER FUNCTION CLTVNPTAL()
PRIVATE cCadastro  := "Maestro de Usuarios del Portal"
PRIVATE aRotina     := {}
AxCadastro("ZZ5", OemToAnsi(cCadastro), '')
Return Nil
