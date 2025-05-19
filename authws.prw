#Include "Protheus.ch"


User Function DIRENTCJ()
Local Msg := ""
Msg :=  RC4Crypt("protmes" + ":" + "Totvs@2025", "AuthWS#ReceiptID", .T.)
MSGALERT(Msg)
Return 
