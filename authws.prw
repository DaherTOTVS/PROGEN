#Include "Protheus.ch"

User Function AUTHWS()
    Local cCredenciales := "adjuntos:Totvs2024"
    Local cValor       := RC4Crypt(cCredenciales, "AuthWS#ReceiptID", .T.)
    Local cFilial      := xFilial("SX6")
    
    // Intenta actualizar directamente en SX6
    DbSelectArea("SX6")
    DbSetOrder(1) // X6_FILIAL+X6_VAR
    
    If SX6->(DbSeek(cFilial + "MV_AUTHWS"))
        RecLock("SX6", .F.)
        SX6->X6_CONTEUD := cValor
        MsUnlock()
        MsgAlert("Parámetro actualizado correctamente")
    Else
        MsgAlert("No se encontró el parámetro MV_AUTHWS")
    EndIf
    
Return
