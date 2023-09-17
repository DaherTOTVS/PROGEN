#INCLUDE "PROTHEUS.CH"
User Function XLIBEROS()

    Local lRet := .T.
    Local lOrdSep := CB7->CB7_ORDSEP

    IF CB7_STATUS == '0'
        MsgStop("La Orden de separación esta en estado Iniciada.")
        ACDA100()
        Return
    Endif

    If MsgYesNo("¿Liberar Orden de Separacion "+lOrdSep+"  ?")

        CB8->(DbSetOrder(1))
		CB8->(DbSeek(xFilial('CB8')+lOrdSep))
		While CB8->(!Eof()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP)==xFilial("CB8")+lOrdSep

            SC9->(DbSetOrder(1))
            SC9->(DbSeek(xFilial('CB8')+CB8->(CB8_PEDIDO+CB8_ITEM+CB8_SEQUEN+CB8_PROD)))
            While SC9->(!Eof()) .AND. SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO)==xFilial("CB8")+CB8->(CB8_PEDIDO+CB8_ITEM+CB8_SEQUEN+CB8_PROD)
                If Alltrim(SC9->C9_REMITO) <>'' .OR. Alltrim(SC9->C9_NFISCAL) <>''
                    lRet := .F.
                    MsgStop("La Orden de separción contiene items con documentos de salida.")
                    ACDA100()
                    return
                Endif
                SC9->(DbSkip())	
            EndDo

            If Localiza(CB8->CB8_PROD)
                lRet := .F.
                MsgStop("La Orden de separación contiene items con ubicación.")
                ACDA100()
                return
            Endif
            CB8->(DbSkip())	
		EndDo
        
        

        CB9->(DbSetOrder(9))
        CB9->(DbSeek(xFilial("CB9")+lOrdSep))
        While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+lOrdSep)
            RecLock("CB9")
            CB9->(DbDelete())
            CB9->(MsUnlock())
            CB9->(DbSkip())
        EndDo


        While CB8->(!Eof()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP)==xFilial("CB8")+lOrdSep
            RecLock("CB8",.F.) 
            CB8->CB8_SALDOS := CB8->CB8_QTDORI
            CB8->(MsUnlock())
            CB8->(DbSkip())	
		EndDo


        CB7->(RecLock("CB7"))
        CB7->CB7_STATUS := "0"  // Iniciado
        CB7->(MsUnlock())


        MsgAlert("Orden de Separación "+lOrdSep+" Liberada.")
        ACDA100()
    EndIf

Return
