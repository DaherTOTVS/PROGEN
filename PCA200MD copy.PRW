#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

User Function PCA200MD()
    Local cOpcx     := ParamixB[1] //Model ou View
    Local oStrMaster:= ParamixB[2] //Struct Header
    Local oStrCmp   := ParamixB[3] //Struct Componente
    Local oStrDet   := ParamixB[4] //Struct Detalhe
    Local cOrdem    := Iif(cOpcx == "VIEW",ParamixB[5],"0") //Ordem, somente enviado para view
 
    If cOpcx == "MODEL"   
			oStrMaster:AddField('STR0017'									,;	// [01]  C   Titulo do campo  //"Quantidade Base"
	                    'STR0017'									,;	// [02]  C   ToolTip do campo //"Quantidade Base"
	                    "NQTBASE"								,;	// [03]  C   Id do Field
	                    "N"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_QB","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_QB","X3_DECIMAL")		,;	// [06]  N   Decimal do campo
	                    {||VldBase()}							,;	// [07]  B   Code-block de valida��o do campo
	                    NIL										,;	// [08]  B   Code-block de valida��o When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigat�rio
	                    {||IniBase()}							,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
	                    .T.										)	// [14]  L   Indica se o campo � virtual

	oStrCmp:AddField('STR0016	'							,;	// [01]  C   Titulo do campo  //"Unidade"
	                 'STR0016'								,;	// [02]  C   ToolTip do campo //"Unidade"
	                 "CUMCMP"								,;	// [03]  C   Id do Field
	                 "C"									,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("B1_UM","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                 0										,;	// [06]  N   Decimal do campo
	                 NIL									,;	// [07]  B   Code-block de valida��o do campo
	                 NIL									,;	// [08]  B   Code-block de valida��o When do campo
	                 NIL									,;	// [09]  A   Lista de valores permitido do campo
	                 .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigat�rio
	                 {||IniUm()}							,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
	                 .T.									)	// [14]  L   Indica se o campo � virtual
    EndIf
 
Return Nil

Static Function IniBase(cProduto)
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
Return RetFldProd(cProduto,"B1_QB")

Static Function VldBase()
	Local lRet   := .T.
	Local oModel := FwModelActive()
	Local oMdlPai := oModel:GetModel("SG1_MASTER")

	If QtdComp(oMdlPai:GetValue("NQTBASE")) < QtdComp(0) .And. !SuperGetMv('MV_NEGESTR', .F., .F.)
		Help(' ',1,'MA200QBNEG')
		lRet := .F.
	EndIf
Return lRet

Static Function IniUm(cProduto)
	Local cUnidade := ""
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cUnidade := SB1->B1_UM
	Else
		cUnidade := CriaVar('B1_UM')
	EndIf
Return cUnidade

