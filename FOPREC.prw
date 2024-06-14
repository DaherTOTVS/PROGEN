#include 'totvs.ch'
#include 'rptdef.ch'
#include 'rwmake.ch'
#include 'FWPrintSetup.ch'
#include 'FWMVCDEF.CH'
#include 'AcmeDef.ch'
#include 'TOPCONN.CH'

/*
+---------------------------------------------------------------------------+
| Programa  #    ACMRP1A       |Autor  |                |Fecha |  |
+---------------------------------------------------------------------------+
| Desc.     #  Función  Remision de salida de Productos DESPACHO A CLIENTES |
|           #                                                               |
+---------------------------------------------------------------------------+
| Uso       # u_ACMRP2A()                                                   |
+---------------------------------------------------------------------------+
*/
User Function FOPREC()
	//Local cQryBw, cArqTrb			:= ""
	Local cAliasTMP					:= GetNextAlias()
	Local oTempTable 
	Local aStrut					:= {}
	Local aCampos					:= {}
	
	//Local aSeek						:= {}
	Local aIndexSCO					:= {}
	Private opcionmark				:= 0
	Private cMarca					:= cValToChar(Randomize(10,99))
	Private cFiltro					:= ""
	Private cRealNames				:= ""
	// fFilAcm2(@cFiltro)
	Private cCadastro := "Planilla Formación de precios"
	Private aRotina := {}

	
	
	// If EMPTY(cFiltro)
	// 	Return
	// EndIf

	//--------------------------
	//Crear Campos Temporales
	//--------------------------

	AAdd( aStrut,{ "COK"			,"C",02						,0	} ) //01
	AAdd( aStrut,{ "FILIAL"		,"C",TamSX3("CO_FILIAL")[1],0	} ) //02
	AAdd( aStrut,{ "CODIGO"		,"C",TamSX3("CO_CODIGO")[1],0	} ) //02
	AAdd( aStrut,{ "REVISAO"			,"C",TamSX3("CO_REVISAO")[1]	,0	} ) //03
	AAdd( aStrut,{ "LINHA"			,"C",TamSX3("CO_LINHA")[1]	,0	} ) //04
	AAdd( aStrut,{ "NOME"			,"C",TamSX3("CO_NOME")[1]	,0	} ) //04
	AAdd( aStrut,{ "PRODUTO"		,"C",TamSX3("CO_PRODUTO")[1]	,0	} ) //05
	AAdd( aStrut,{ "RECNO"		,"N",TamSX3("CO_PRODUTO")[1]	,0	} ) //05
	AAdd( aStrut,{ "CODATA"			,"D",TamSX3("CO_DATA")[1]	,2	} ) //06
	
	oTempTable := FWTemporaryTable():New( cAliasTMP )
	oTemptable:SetFields( aStrut )
	oTempTable:AddIndex("indice1", {"CODIGO"} ) 
	oTempTable:AddIndex("indice2", {"PRODUTO", "CODATA"} ) 
	oTempTable:Create()

	//------------------------------------
	//Executa query para RELLENADO da tabla temporal
	//------------------------------------
	
	//alert(oTempTable:GetRealName())
	
	cQryBw  := " INSERT INTO "+ oTempTable:GetRealName()
	cQryBw  += " (FILIAL, CODIGO, REVISAO, LINHA, NOME, PRODUTO, CODATA, RECNO) "
	cQryBw	+= " SELECT "
	cQryBw	+= " CO_FILIAL AS FILIAL,"
	cQryBw	+= " CO_CODIGO AS CODIGO,"
	cQryBw	+= " CO_REVISAO  AS REVISAO, "
	cQryBw	+= " CO_LINHA AS LINHA, "
	cQryBw	+= " CO_NOME  AS NOME, "
	cQryBw	+= " CO_PRODUTO AS PRODUTO,"
	cQryBw	+= " R_E_C_N_O_ AS RECNO,"
	cQryBw	+= " CO_DATA AS CODATA "											+ CRLF
	cQryBw	+= " FROM "			+ InitSqlName("SCO") 							+ CRLF
	cQryBw	+= " WHERE D_E_L_E_T_<>'*' " + CRLF								
	

	TcSqlExec(cQryBw)
	
	aCampos := {}
	AAdd( aCampos,{ "FILIAL"		,"C","Filial"		    ,"@!S"+cValToChar(TamSX3("CO_FILIAL")[1])		,"0"	} )
	AAdd( aCampos,{ "CODIGO"		,"C","Codigo"		    ,"@!S"+cValToChar(TamSX3("CO_CODIGO")[1])		,"0"	} )
	AAdd( aCampos,{ "REVISAO"		,"C","Revision"		,"@!S"+cValToChar(TamSX3("CO_REVISAO")[1])			,"0"	} )
	AAdd( aCampos,{ "LINHA"		,"C","Linea"		,"@!S"+cValToChar(TamSX3("CO_LINHA")[1])			,"0"	} )
	AAdd( aCampos,{ "NOME"		,"C","Nombre"			,"@!S"+cValToChar(TamSX3("CO_NOME")[1])			,"0"	} )
	AAdd( aCampos,{ "PRODUTO"		,"C","Producto"			,"@!S"+cValToChar(TamSX3("CO_PRODUTO")[1])		,"0"	} )
	AAdd( aCampos,{ "CODATA"			,"D","Fecha"		,"@!S"+cValToChar(TamSX3("CO_DATA")[1]	)		,"0"	} )

	aRotina := {{"Eliminar "		, 	'U_DELTE()',	0,3}}
	AADD( aRotina,{"[Marcar/Desmarcar todo", 	'U_fmark()',	0,3})


	cRealAlias:=oTempTable:GetAlias()
	cRealNames:=oTempTable:GetRealName()
	dbSelectArea(cRealAlias)
	dbSetOrder(1)
	cMarca:=GETMARK(,cRealAlias,"COK")
	cFiltroSCO 	:= ""
	bFiltraBrw	:=	{|| FilBrowse(cRealAlias,@aIndexSCO,@cFiltroSCO)}
	Eval(bFiltraBrw)
	
	MarkBrow(cRealAlias,"COK",,aCampos,.F.,cMarca)
	EndFilBrw(cRealAlias,@aIndexSCO)
	oTempTable:Delete()
	
Return 

// Funciones para seleccionar o desmarcar todos los items 
user Function fmark()
	Local cant_mark_all     := 0
	Local cant_desmark_all  := 0
	Local count_item 	:= 0

	(cRealAlias)->(DbGoTop())
	While (cRealAlias)->(!EOF())
		count_item++
		If EMPTY((cRealAlias)->COK)
			cant_desmark_all++
		elseif !EMPTY((cRealAlias)->COK)
			cant_mark_all++
		EndIf
		(cRealAlias)->(DbSkip())
	End

	If count_item == cant_desmark_all   // Todos desmarcados
		opcionmark = 0  
	ElseIf count_item == cant_mark_all // Todos marcados
		opcionmark = 1
	EndIf
	
	// reinicio conteo
	cant_mark_all     	= 0
	cant_desmark_all 	= 0
	count_item 		= 0
		
	If opcionmark == 0
		(cRealAlias)->(DbGoTop())
		While (cRealAlias)->(!EOF())
			If EMPTY((cRealAlias)->COK)
				(cRealAlias)->COK :=cMarca
			EndIf
			(cRealAlias)->(DbSkip())
		End	
		opcionmark := 1
	elseif opcionmark == 1
		(cRealAlias)->(DbGoTop())
		While (cRealAlias)->(!EOF())
			If !EMPTY((cRealAlias)->COK)
				(cRealAlias)->COK :=''
			EndIf
			(cRealAlias)->(DbSkip())
		End
		opcionmark := 0
	EndIf
Return 

user Function DELTE()
	Local cAliasImp	:= GetNextAlias()

	Local cQueryMarca := " SELECT RECNO  FROM  " + cRealNames + " COTMP  WHERE COK='"+cMarca+"'"
	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQueryMarca) ,cAliasImp,.T.,.T.)
	DbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())
	While (cAliasImp)->(!EOF())


		Upd := " UPDATE "+RetSqlName("SCO")+" SET D_E_L_E_T_ = '*' WHERE D_E_L_E_T_ <>'*' AND R_E_C_N_O_= '"+(cAliasImp)->RECNO+"'"
		n1Statud :=TCSqlExec(Upd)

		(cAliasImp)->(DbSkip())
	EndDO

	U_FOPREC()
Return
