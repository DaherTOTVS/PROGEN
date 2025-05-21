#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  CRMA980TOK                                                                                    |
 | Desc:  Função chamada na validação do cadastro de clientes                                           |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6784252                                  |
 *------------------------------------------------------------------------------------------------------*/
    /*----------------------------------------------*
	|Mod.                                           |
    |             © Javier Rocha®                   |
	|                                               |	
	*----------------------------------------------*/
 
User Function CRMA980TOK()
    Local lCadFor := .T.

//Punto de Entrada para cuando se Agrega Cliente
	If inclui
	    IF Alltrim(M->A1_PESSOA)=="F"
			U_xCTBA060(M->A1_PFISICA, M->A1_NOME, "3")
		else
			U_xCTBA060(M->A1_CGC, M->A1_NOME, "3")
		Endif	
	Endif

	GravaZZE()

Return lCadFor



static function GravaZZE()
	Local aArea    := GetArea()
	Local aSvZZE   := ZZE->(GetArea())
	Local cCli  := PADR(M->A1_COD,TAMSX3("ZZE_CODCL")[1])
	Local cLoj  := PADR(M->A1_LOJA,TAMSX3("ZZE_LOJC")[1])
	Local cNom  := PADR(M->A1_NREDUZ,TAMSX3("ZZE_NOMCL")[1])
	Local cDir  := PADR(M->A1_ENDENT,TAMSX3("ZZE_DIRECC")[1])
	Local cEst  := PADR(M->A1_XESTENT,TAMSX3("ZZE_EST")[1])
	Local cMun  := PADR(M->A1_XCDMUEN,TAMSX3("ZZE_MUN")[1])

		dbSelectArea( "ZZE" )
		ZZE->(dbSetOrder(1))
		IF !(ZZE->(DBSEEK(cCli+cLoj+cEst+cMun+cDir)))
			Reclock("ZZE",.T.)
				Replace ZZE_FILIAL    With xFilial('ZZE')
				Replace ZZE_COD   With GETSXENUM("ZZE","ZZE_COD")
				Replace ZZE_CODCL With cCli
				Replace ZZE_LOJC With cLoj
				Replace ZZE_NOMCL With cNom
				Replace ZZE_EST With cEst
				Replace ZZE_NOMEST With Posicione('SX5',1,xFilial('SX5')+"12"+cEst,'X5DESCRI()')
				Replace ZZE_MUN With cMun
				Replace ZZE_NOMMUN With POSICIONE("CC2",1,xfilial("CC2")+cEst+cMun,"CC2_MUN")
				Replace ZZE_DIRECC With cDir
			ZZE->(MsUnlock())
		EndIf

	RestArea( aSvZZE )
	RestArea(aArea)

RETURN .T. 
