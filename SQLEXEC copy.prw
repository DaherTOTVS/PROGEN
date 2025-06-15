#Include "PROTHEUS.CH"
#include "fileIO.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include 'totvs.ch'


Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE_ESCURO")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_AZUL")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PINK")
Static oOk			:= LoadBitmap( GetResources(), "LBOK" )
Static oNo			:= LoadBitmap( GetResources(), "LBNO" )


User Function SQLEXEC()
    _SQLEXEC()
Return

Static Function _SQLEXEC()
    Local oDlg
    Local oBrowse
    Local oBtnImport
    Local oBtnProcess
    Local oBtnClose
    Local aData := {}
    
    Private cFontUti := "Tahoma"
    Private oFontSub := TFont():New(cFontUti,,-20)
    
    DEFINE MSDIALOG oDlg TITLE "Actualizacion Masiva de Datos" FROM 000, 000 TO 400, 800 PIXEL
    
    @ 005, 007 SAY "Seleccione el archivo .CSV para la carga " SIZE 200, 030 FONT oFontSub OF oDlg COLORS RGB(031,073,125) PIXEL
    
    oBrowse := TCBrowse():New(050, 005, 560, 600,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    oBrowse:AddColumn(TCColumn():New("Tabla", {|| aData[oBrowse:nAt,1]},"@!",,,"CENTER", 010,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Llave", {|| aData[oBrowse:nAt,2]},"@!",,,"CENTER", 020,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Campos", {|| aData[oBrowse:nAt,3]},"@!",,,"CENTER", 030,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Valores", {|| aData[oBrowse:nAt,4]},"@!",,,"CENTER", 030,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Status", {|| aData[oBrowse:nAt,5]},"@!",,,"CENTER", 015,.F.,.F.,,{|| .F. },,.F.,))
    
    oBrowse:SetArray(aData)
    oBrowse:bWhen := { || Len(aData) > 0 }
    oBrowse:Refresh()
    
    @ 650, 150 BUTTON oBtnImport PROMPT "Importar" SIZE 037, 012 OF oDlg ACTION u_ImportCSV(@aData, oBrowse) PIXEL
    @ 650, 250 BUTTON oBtnProcess PROMPT "Procesar" SIZE 037, 012 OF oDlg ACTION Processa({|| u_ProcessData(aData)}, "Procesando actualizaciones...") PIXEL
    @ 650, 350 BUTTON oBtnClose PROMPT "Cerrar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
    
    ACTIVATE MSDIALOG oDlg CENTERED
Return

//-----------------------------------------------------------------------------
User Function ImportCSV(aData, oBrowse)
    Local nHandle
    Local cLine
    Local aLine
    Local cFile := cGetFile("Arquivos CSV|*.CSV|Arquivo TXT|*.TXT","Selecione o arquivo",0,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD,.F.)
    
    If Empty(cFile)
        Return
    EndIf
    
    nHandle := FOpen(cFile)
    If nHandle == -1
        Alert("Error al abrir el archivo!")
        Return
    EndIf
    
    aData := {}
    
    While !FEOF(nHandle)
        cLine := FReadLn(nHandle)
        If !Empty(cLine)
            aLine := StrTokArr(cLine, ";")
            If Len(aLine) >= 4
                aAdd(aData, {aLine[1], aLine[2], aLine[3], aLine[4], "Pendiente"})
            EndIf
        EndIf
    EndDo
    
    FClose(nHandle)
    oBrowse:SetArray(aData)
    oBrowse:Refresh()
Return

//-----------------------------------------------------------------------------
User Function ProcessData(aData)
    Local nX
    Local cTable
    Local cKey
    Local aFields
    Local aValues
    Local cLog := ""
    Local nSuccess := 0
    Local nError := 0
    
    ProcRegua(Len(aData))
    
    For nX := 1 To Len(aData)
        IncProc("Procesando registro " + Str(nX) + " de " + Str(Len(aData)))
        
        cTable := aData[nX,1]
        cKey := aData[nX,2]
        aFields := StrTokArr(aData[nX,3], ",")
        aValues := StrTokArr(aData[nX,4], ",")
        
        If !u_UpdateRecord(cTable, cKey, aFields, aValues)
            cLog += "Error en registro " + Str(nX) + CRLF
            cLog += "Tabla: " + cTable + CRLF
            cLog += "Llave: " + cKey + CRLF
            cLog += "------------------------" + CRLF
            nError++
            aData[nX,5] := "Error"
        Else
            nSuccess++
            aData[nX,5] := "OK"
        EndIf
    Next nX
    
    If !Empty(cLog)
        MemoWrite("C:\TOTVS\UpdateLog_" + DTOS(dDataBase) + ".txt", cLog)
        Alert("Proceso finalizado com " + Str(nSuccess) + " sucessos e " + Str(nError) + " erros. Verifique o log para mais detalhes.")
    Else
        Alert("Todos os registros foram atualizados com sucesso!")
    EndIf
Return

//-----------------------------------------------------------------------------
Static Function UpdateRecord(cTable, cKey, aFields, aValues)
    Local lRet := .T.
    Local cX2Unico
    Local cAlias := GetNextAlias()
    
    // Busca o X2_UNICO na SX2
    DbSelectArea("SX2")
    SX2->(DbSetOrder(1)) // X2_CHAVE
    If SX2->(DbSeek(cTable))
        cX2Unico := SX2->X2_UNICO
    Else
        Return .F.
    EndIf
    
    // Abre a tabela
    DbSelectArea(cTable)
    (cTable)->(DbSetOrder(1)) // Assume que a ordem 1 é a chave primária
    
    If !(cTable)->(DbSeek(cKey))
        Return .F.
    EndIf
    
    // Atualiza os campos
    RecLock(cTable, .F.)
    For nX := 1 To Len(aFields)
        If nX <= Len(aValues)
            &(cTable + "->" + AllTrim(aFields[nX])) := aValues[nX]
        EndIf
    Next nX
    (cTable)->(MsUnlock())
    
Return lRet


