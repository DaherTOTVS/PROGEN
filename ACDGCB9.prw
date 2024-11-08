#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


User Function ACDGCB9()
 Local aArea    := GetArea()
 Local nQtde    := paramixb[1]

    If CB9->CB9_QTESEP <= 0
        RecLock("CB9",.F.)
            CB9->CB9_QTESEP += 1
        CB9->(MsUnlock())
    EndIf
    
    RestArea(aArea)

Return 
