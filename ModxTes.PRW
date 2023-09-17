#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include "TOTVS.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

/*
  ________  ________  _________  ___      ___ ________           ________  ________   ________  ___  ________   ________
  |\___   ___\\   __  \|\___   ___\\  \    /  /|\   ____\         |\   __  \|\   ___  \|\   ___ \|\  \|\   ___  \|\   __  \
  \|___ \  \_\ \  \|\  \|___ \  \_\ \  \  /  / | \  \___|_        \ \  \|\  \ \  \\ \  \ \  \_|\ \ \  \ \  \\ \  \ \  \|\  \
       \ \  \ \ \  \\\  \   \ \  \ \ \  \/  / / \ \_____  \        \ \   __  \ \  \\ \  \ \  \ \\ \ \  \ \  \\ \  \ \   __  \
        \ \  \ \ \  \\\  \   \ \  \ \ \    / /   \|____|\  \        \ \  \ \  \ \  \\ \  \ \  \_\\ \ \  \ \  \\ \  \ \  \ \  \
         \ \__\ \ \_______\   \ \__\ \ \__/ /      ____\_\  \        \ \__\ \__\ \__\\ \__\ \_______\ \__\ \__\\ \__\ \__\ \__\
          \|__|  \|_______|    \|__|  \|__|/      |\_________\        \|__|\|__|\|__| \|__|\|_______|\|__|\|__| \|__|\|__|\|__|
                                                  \|_________|
  -----------------------------------------------------------------------------------------------------------------------------
    BROWSE MVC PARA REGISTRAR INFORMACIÒN EN LAS TABLAS ZZC(Modalidades X TES Encabezado) TABLA ZZD(Modalidades X TES Detalle)
                                                      AUTOR: JAVIER ROCHA
													  FECHA:  30/05/2023                                                     */


User Function ModxTes()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZC')
	oBrowse:SetDescription('Modalidades x TES')
	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ModxTes' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ModxTes' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ModxTes' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Borrar'     ACTION 'VIEWDEF.ModxTes' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.ModxTes' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.ModxTes' OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local bVldAct := {|| u_xMxtAct()}
	Local oModel
	Local oStruZZC := FWFormStruct(1,"ZZC")
	Local oStruZZD := FWFormStruct(1,"ZZD")
	Local aZZDRel		:= {}


	oModel := MPFormModel():New("TESXMODAL",bVldAct)
	oModel:addFields('ZZCMASTER',,oStruZZC)
	oModel:addGrid('ZZDDETAIL','ZZCMASTER',oStruZZD)

	aAdd(aZZDRel, {'ZZD_FILIAL'	, 'xFilial( "ZZD" )'})
	aAdd(aZZDRel, {'ZZD_CODMOD'	, 'ZZC_CODMOD'		})
	oModel:SetRelation('ZZDDETAIL', aZZDRel, ZZD->(IndexKey(1))) // IndexKey -> Quiero ordenar y luego filtrar
	oModel:GetModel('ZZDDETAIL'):SetOptional(.F.)  //Se indica que la tabla relacionada puede ir sin registros para guardar

	oModel:GetModel('ZZDDETAIL'):SetUniqueLine({"ZZD_CODMOD","ZZD_CODTES"})	// No repita informaciï¿½n o combinaciones {"CAMPO1", "CAMPO2", "CAMPOX"}

	oModel:GetModel('ZZDDETAIL'):SetDescription( 'MODALIDADES' )
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel := ModelDef()
	Local oView
	Local oStrZZC:= FWFormStruct(2, 'ZZC')
	Local oStrZZD:= FWFormStruct(2, 'ZZD', {|cField| !(AllTrim(Upper(cField)) $ "ZZD_CODMOD")})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_MOD' , oStrZZC,'ZZCMASTER' )
	oView:AddGrid('FORM_TES' , oStrZZD,'ZZDDETAIL')

	oView:CreateHorizontalBox( 'BOX_FORM_MOD', 40)
	oView:CreateHorizontalBox( 'BOX_FORM_TES', 60)

	oView:SetOwnerView('FORM_MOD','BOX_FORM_MOD')
	oView:SetOwnerView('FORM_TES','BOX_FORM_TES')

Return oView

User Function xMxtAct()
	Local oModelPad  := FWModelActive()	
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.
	Local cModalidad := Alltrim(ZZC->ZZC_CODMOD)

	lBand := xMovSC5(cModalidad)

	if lBand
		/*Se for Inclusão
		 If nOpc == MODEL_OPERATION_INSERT
			Aviso('Atenção', 'Inclusão realizada!', {'OK'}, 03)
		*/
		/*Se for Alteração
		ElseIf nOpc == MODEL_OPERATION_UPDATE
			Aviso('Atenção', 'Alteração realizada!', {'OK'}, 03)
		*/
		//Se for Exclusão
		If nOpc == MODEL_OPERATION_DELETE
			MSGSTOP( "MODALIDAD YA TIENE MOVIEMIENTOS","ERROR DE BORRADO" )			
			//Aviso('Atenção', 'Exclusão realizada!', {'OK'}, 03)
			__Quit()
		EndIf
	ENDIF
Return lRet

//Funciòn para validar si la modalidad ya tiene movimientos en Pedidos
Static Function xMovSC5(cModalidad)
	Local lRet
	Local cMod := cModalidad


	_cAQuery := "SELECT COUNT (*) AS TOTAL  FROM " +RetSQLName('SC5')+ " WHERE D_E_L_E_T_ <> '*' AND  C5_NATUREZ = '"+cMod+"' AND C5_FILIAL='" + xFilial("SRD") +  "' "
	TcQuery _cAQuery New Alias "_aQRY"
	dbSelectArea("_aQRY")
	While !_aQRY->(EOF())
		nTotal := _aQRY->TOTAL
		_aQRY->(dbSkip())
	EndDo
	_aQRY->(dbCloseArea())

	If nTotal >= 1
		lRet := .T.  //Existe
	Else
		lRet := .F.  // No Existe
	EndIF

Return lRet
