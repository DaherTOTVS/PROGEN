#include "protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDA100F ³ Autor ³ Duvan Hernandez      ³ Data ³ 05/06/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ PE para actualziación de STATUS OS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function ACDA100F()
    Local aArea    := GetArea()
    Local lREt     := .t.
    Local nCant    := 0
    Local OS    :=alltrim(Paramixb[1])


    _cAQuery := " SELECT COUNT(*) AS DATO FROM  "+RetSQLName('CB8')+"  CB8 "
    _cAQuery += " INNER JOIN " +RetSQLName('SB1')+" SB1 "
    _cAQuery += " ON B1_COD = CB8_PROD "
    // _cAQuery += " AND B1_LOCPAD = CB8_LOCAL "
    _cAQuery += " AND B1_LOCALIZ ='S' "
    _cAQuery += " AND SB1.D_E_L_E_T_ <> '*' "
    _cAQuery += " WHERE CB8.D_E_L_E_T_ <> '*' "
    _cAQuery += " AND CB8_ORDSEP =  '"+OS+"' "
    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    While !_aQRY->(EOF())
        nCant := _aQRY->DATO
        _aQRY->(dbSkip())
    EndDo
    _aQRY->(dbCloseArea())

    If nCant == 0
        CB7->(DbSeek(xFilial("CB7")+OS))
        CB7->(RecLock("CB7"))
        CB7->CB7_STATUS := "2"  // Finalizado
        CB7->CB7_DTINIS := dDataBase
	    CB7->CB7_HRINIS := StrTran(Time(),":","")
        CB7->CB7_DTFIMS := dDataBase
		CB7->CB7_HRFIMS := StrTran(Time(),":","")
        CB7->(MsUnlock())


        CB8->(DbSetOrder(1))
		CB8->(DbSeek(xFilial('CB8')+OS))
		While CB8->(!Eof()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP)==xFilial("CB8")+OS
			If !Localiza(CB8->CB8_PROD)
                GravarCB9(CB8->CB8_SALDOS,CB8->CB8_LCALIZ,CB8->CB8_LOTECT,CB8->CB8_NUMLOT,"",CB8->CB8_NUMSER,CB8->CB8_SEQUEN)
                RecLock("CB8",.F.) 
                CB8->CB8_SALDOS := 0
                CB8->(MsUnlock())
                CB8->(DbSkip())	
            Endif
		EndDo

    Endif

    // Customização de usuário...
   RestArea(aArea)
Return lRet



Static Function GravarCB9(nQtde,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen,lApp)
Default cCodCB0 := Space(10)
Private cVolume     := Space(TamSX3("CB9_VOLUME")[1])

If lApp
	cVolume := ''
Endif
CB9->(DbSetOrder(10))
If !CB9->(DbSeek(xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+cLoteNew+cSLoteNew+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER+cVolume+cCodCB0+CB8_PEDIDO)))
	RecLock("CB9",.T.)
	CB9->CB9_FILIAL := xFilial("CB9")
	CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
	CB9->CB9_CODETI := cCodCB0
	CB9->CB9_PROD   := CB8->CB8_PROD
	CB9->CB9_CODSEP := CB7->CB7_CODOPE
	CB9->CB9_ITESEP := CB8->CB8_ITEM
	CB9->CB9_SEQUEN := cSequen
	CB9->CB9_LOCAL  := CB8->CB8_LOCAL
	If lApp	// Funcionalidade para troca de lote / endereco nao disponivel pelo App, serao mantidos os dados da CB8
		CB9->CB9_LCALIZ := CB8->CB8_LCALIZ
		CB9->CB9_LOTECT := CB8->CB8_LOTECT
		CB9->CB9_NUMLOT := CB8->CB8_NUMLOT
		CB9->CB9_NUMSER := CB8->CB8_NUMSER
	Else
		CB9->CB9_LCALIZ := cEndNew
		CB9->CB9_LOTECT := cLoteNew
		CB9->CB9_NUMLOT := cSLoteNew
		CB9->CB9_NUMSER := cNumSerNew
	EndIf
	CB9->CB9_LOTSUG := CB8->CB8_LOTECT
	CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
	CB9->CB9_NSERSU := CB8->CB8_NUMSER
	CB9->CB9_PEDIDO := CB8->CB8_PEDIDO

	If '01' $ CB7->CB7_TIPEXP .Or. !Empty(cVolume)
		If !('02' $ CB7->CB7_TIPEXP)
			CB9->CB9_VOLUME := cVolume
		Else
			CB9->CB9_SUBVOL := cVolume
		EndIf
	EndIf
	If CB9->(ColumnPos("CB9_TRT")) > 0 .And. CB8->(ColumnPos("CB8_TRT")) > 0
		CB9->CB9_TRT	:= CB8->CB8_TRT
	EndIf

Else
	RecLock("CB9",.F.)
EndIf
CB9->CB9_QTESEP += nQtde
CB9->CB9_STATUS := "1"  // separado
CB9->(MsUnlock())


Return
