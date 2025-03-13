#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "pcpa200.ch"

User Function PCA200MD()
    Local cOpcx     := ParamixB[1] //Model ou View
    Local oStrMaster:= ParamixB[2] //Struct Header
    // Local oStrCmp   := ParamixB[3] //Struct Componente
    // Local oStrDet   := ParamixB[4] //Struct Detalhe
    Local cOrdem    := Iif(cOpcx == "VIEW",ParamixB[5],"0") //Ordem, somente enviado para view
 
<<<<<<< HEAD

	If cOpcx == "MODEL"  
		oStrMaster:AddField("Revisión Bloq."									,;	// [01]  C   Titulo do campo  //"Quantidade Base"
							"Revisión Bloq."									,;	// [02]  C   ToolTip do campo //"Quantidade Base"
							"MSBLQL"								,;	// [03]  C   Id do Field
							"N"										,;	// [04]  C   Tipo do campo
							GetSx3Cache("G1_XMSBLQL","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
							GetSx3Cache("G1_XMSBLQL","X3_DECIMAL")		,;	// [06]  N   Decimal do campo
							{||.F.}									,;	// [07]  B   Code-block de validação do campo
							NIL										,;	// [08]  B   Code-block de validação When do campo
							NIL										,;	// [09]  A   Lista de valores permitido do campo
							.F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
							{||IniBloq()}							,;	// [11]  B   Code-block de inicializacao do campo
							NIL										,;	// [12]  L   Indica se trata-se de um campo chave
							NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.										)	// [14]  L   Indica se o campo é virtual
	EndIf
    If cOpcx == "VIEW"   
		cOrdem := Soma1(cOrdem)
		oStrMaster:AddField("MSBLQL"						,;	// [01]  C   Nome do Campo
	        cOrdem							,;	// [02]  C   Ordem
	        "Revisión Bloq."							,;	// [03]  C   Titulo do campo    //"Quantidade base"
	        "Revisión Bloq."							,;	// [04]  C   Descricao do campo //"Quantidade base"
	        { "Revisión Bloqueada"}						,;	// [05]  A   Array com Help
	        "C"								,;	// [06]  C   Tipo do campo
	        AllTrim(GetSX3Cache("G1_XMSBLQL", "X3_PICTURE")),;	// [07]  C   Picture
	        NIL								,;	// [08]  B   Bloco de Picture Var
	        NIL								,;	// [09]  C   Consulta F3
	        .F.								,;	// [10]  L   Indica se o campo é alteravel
	        NIL								,;	// [11]  C   Pasta do campo
	        NIL								,;	// [12]  C   Agrupamento do campo
	        NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	        NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	        NIL								,;	// [15]  C   Inicializador de Browse
	        .T.								,;	// [16]  L   Indica se o campo é virtual
	        NIL								,;	// [17]  C   Picture Variavel
	        NIL								)	// [18]  L   Indica pulo de linha após o campo
EndIf
=======
    If cOpcx == "MODEL"   
	oStrMaster:AddField('STR0017'									,;	// [01]  C   Titulo do campo  //"Quantidade Base"
	                    'STR0017'									,;	// [02]  C   ToolTip do campo //"Quantidade Base"
	                    "NQTBASE1"								,;	// [03]  C   Id do Field
	                    "N"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_QB","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_QB","X3_DECIMAL")		,;	// [06]  N   Decimal do campo
	                    {||VldBase()}							,;	// [07]  B   Code-block de validao do campo
	                    NIL										,;	// [08]  B   Code-block de validao When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatrio
	                    {||IniBase()}							,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operao de update.
	                    .T.										)	// [14]  L   Indica se o campo  virtual

							oStrCmp:AddField('STR0016'								,;	// [01]  C   Titulo do campo  //"Unidade"
	                 'STR0016'								,;	// [02]  C   ToolTip do campo //"Unidade"
	                 "CUMCMP1"								,;	// [03]  C   Id do Field
	                 "C"									,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("B1_UM","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                 0										,;	// [06]  N   Decimal do campo
	                 NIL									,;	// [07]  B   Code-block de validao do campo
	                 NIL									,;	// [08]  B   Code-block de validao When do campo
	                 NIL									,;	// [09]  A   Lista de valores permitido do campo
	                 .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatrio
	                 {||IniUm()}							,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operao de update.
	                 .T.									)	// [14]  L   Indica se o campo  virtual
    EndIf
>>>>>>> 1e362897c9910f546296ec47ddafc40110b7951c
 
Return Nil

Static Function IniBloq()
	Local cProduto  := SG1->G1_COD
	Local cRevision := SG1->G1_COD

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
Return RetFldProd(cProduto,"B1_QB")

Static Function IniUm(cProduto)
	Local cUnidade := ""
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cUnidade := SB1->B1_UM
	Else
		cUnidade := CriaVar('B1_UM')
	EndIf
<<<<<<< HEAD
Return cUnidade

=======
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
>>>>>>> 1e362897c9910f546296ec47ddafc40110b7951c
