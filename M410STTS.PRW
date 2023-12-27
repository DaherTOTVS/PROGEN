#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function M410STTS()

Local aArea     := GetArea()
Local cUsuarPd  :=  CUSERNAME
if INCLUI
    RecLock("SC5",.F.)
    
    SC5->C5_ZUSERIN :=  cUsuarPd
  
    SC5->(MsUnlock())
ENDIF

RestArea( aArea )
Return
