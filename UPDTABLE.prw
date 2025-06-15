#Include "PROTHEUS.CH"
#include "fileIO.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include 'totvs.ch'

//-----------------------------------------------------------------------------
// Programa: UPDTABLE
// Autor: Duvan Arley Hernandez Niño
// Data: 09/06/2025
// Descripcion: Programa para actualizacion masiva de datos mediante archivo CSV
//-----------------------------------------------------------------------------

User Function UPDTABLE()
    Local cUserPermi := upper(SuperGetMv("PG_UPDTABLE",.F.,"TOTVSADM"))
    Local cUserActua := upper(cusername)

    if !(cUserActua $ cUserPermi)
        msgalert("Usuario no autorizado","PERMISOS")
    Else
        _UPDTABLE()
    EndIF


Return

//-----------------------------------------------------------------------------
// Funcion: _UPDTABLE
// Descripcion: Funcion principal que crea la interfaz del programa
//-----------------------------------------------------------------------------
Static Function _UPDTABLE()
    Local oDlg
    Local oBrowse
    Local oBtnImport
    Local oBtnProcess
    Local oBtnClose
    Local aData := {}
    
    Private cFontUti := "Tahoma"
    Private oFontSub := TFont():New(cFontUti,,-20)
    
        DEFINE MSDIALOG oDlg TITLE "Actualizacion Masiva de Datos" FROM 000, 000  TO 400, 1200 PIXEL
        @ 005, 007 SAY "Seleccione el archivo .CSV para la carga " SIZE 200, 030 FONT oFontSub OF oDlg COLORS RGB(031,073,125) PIXEL

    
    // Ajustamos el tamaño del browse
    //oBrowse := TCBrowse():New(050, 005, 500, 700,,,,oDlg,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
    oBrowse := TCBrowse():New(050, 005,560, 120,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    oBrowse:AddColumn(TCColumn():New("No", {|| aData[oBrowse:nAt,1]},"@!",,,"LEFT", 015,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Tabla", {|| aData[oBrowse:nAt,2]},"@!",,,"LEFT", 015,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Indice", {|| aData[oBrowse:nAt,3]},"@!",,,"LEFT", 010,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Llave", {|| aData[oBrowse:nAt,4]},"@!",,,"LEFT",180,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Campos", {|| aData[oBrowse:nAt,5]},"@!",,,"LEFT", 120,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Valores", {|| aData[oBrowse:nAt,6]},"@!",,,"LEFT", 100,.F.,.F.,,{|| .F. },,.F.,))
    oBrowse:AddColumn(TCColumn():New("Status", {|| aData[oBrowse:nAt,7]},"@!",,,"LEFT", 015,.F.,.F.,,{|| .F. },,.F.,))
    
    oBrowse:SetArray(aData)
    oBrowse:bWhen := { || Len(aData) > 0 }
    oBrowse:Refresh()
    
    // Ajustamos la posición y tamaño de los botones
    @ 181, 150 BUTTON oBtnImport PROMPT "Importar" SIZE 037, 012 OF oDlg ACTION u_ImportCSV(@aData, oBrowse) PIXEL
    @ 181, 250 BUTTON oBtnProcess PROMPT "Grabar" SIZE 037, 012 OF oDlg ACTION  Processa({|| u_ProcessData(aData)}, "Processando ... Por favor espere ...") PIXEL
    @ 181, 350 BUTTON oBtnClose PROMPT "Cerrar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL   


    ACTIVATE MSDIALOG oDlg CENTERED
Return

//-----------------------------------------------------------------------------
// Funcion: ImportCSV
// Descripcion: Importa el archivo CSV y carga los datos en el grid
// Parametros: aData - Array que almacenara los datos
//             oBrowse - Objeto browse para visualizacion
//-----------------------------------------------------------------------------
User Function ImportCSV(aData, oBrowse)
    Local nCont             := 0
    Local nLinhas           := 0
    Local _aStr             := {{"Texto","C",1000,0}}
    Local _cTmp             := CriaTrab(NIL,.F.)
    Local lEnd              := .F.
    Local cFile := cGetFile("Arquivos CSV|*.CSV|Arquivo TXT|*.TXT","Selecione o arquivo",0,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD,.F.)
    
    If Empty(cFile)
        Return
    EndIf

    aData := {}

    if !file(Alltrim(cFile))
        Alert("Arquivo "+Alltrim(cFile)+" Archivo no Valido!"+CRLF+"Cancelando Importe !")
        Return
    Endif
    dbCreate(_cTmp,_aStr)
    IF SELECT("TRB") # 0
        TRB->(dbCloseArea())
    ENDIF
    DBUseArea(.T.,,_cTmp,"TRB",.F.,.F.)
    if AT(":\",cFile)>0
        CpyT2S( cFile, GetSrvProfString("Startpath",";") )
    Else
        CpyT2S( cFile, GetSrvProfString("Startpath","") )
    endif
    Append From &cFile SDF
    TRB->(dbGoTop())
    nLinhas             := TRB->(RecCount())
    ProcRegua(nLinhas)
    aApunte             := {}
    While TRB->(!Eof())
        nCont++
        IncProc("Leyendo Archivo...Linea No "+Alltrim(str(nCont)))
        If lEnd
            MsgInfo("Cancelado!","Finalizado")
            exit
        Endif
        IF nCont > nLinhas
            exit
        endif
        cLinha              := ALLTRIM(UPPER(TRB->Texto))
        if !empty(cLinha)
            aLine := StrTokArr(cLinha, ";")
            aAdd(aData, {nCont,aLine[1], aLine[2], aLine[3], aLine[4], aLine[5], "Pendiente"})
            
            // Actualizar el browse cada 10 registros
            if Mod(nCont, 2) == 0
                oBrowse:SetArray(aData)
                oBrowse:Refresh()
            endif
        endif
        DbSkip()
    EndDo
    TRB->(dbCloseArea())
    Ferase(_cTmp+".DBF")

    // Actualización final del browse
    oBrowse:SetArray(aData)
    oBrowse:Refresh()
Return

//-----------------------------------------------------------------------------
// Funcion: ProcessData
// Descripcion: Procesa los datos importados y realiza las actualizaciones
// Parametros: aData - Array con los datos a procesar
//-----------------------------------------------------------------------------
User Function ProcessData(aData)
    Local nX
    Local cTable
    Local nIndex
    Local cKey
    Local aFields
    Local aValues
    Local cLog := ""
    Local nSuccess := 0
    Local nError := 0
    Local lValid
    Local cInvalidField := ""
    Local cPasta := "UpdateLog_" + DTOS(dDataBase) + ".txt"
    Local cRuta:= "C:\spool\"
    
    ProcRegua(Len(aData))
    
    For nX := 1 To Len(aData)
        IncProc("Procesando registro " + Str(nX) + " de " + Str(Len(aData)))
        
        cTable := aData[nX,1]
        nIndex := Val(aData[nX,2])
        cKey := aData[nX,3]
        aFields := StrTokArr(aData[nX,4], ",")
        aValues := StrTokArr(aData[nX,5], ",")
        
        // Validar existencia de tabla y campos
        lValid := ValidateTableFields(cTable, aFields, @cInvalidField)
        
        If !lValid
            cLog += "Error en registro " + Str(nX) + CRLF
            cLog += "Tabla: " + cTable + CRLF
            cLog += "Error: El campo '" + cInvalidField + "' no existe en la tabla" + CRLF
            cLog += "------------------------" + CRLF
            nError++
            aData[nX,6] := "Error"
            Loop
        EndIf
        
        If !UpdateRecord(cTable, nIndex, cKey, aFields, aValues)
            cLog += "Error en registro " + Str(nX) + CRLF
            cLog += "Tabla: " + cTable + CRLF
            cLog += "Indice: " + Str(nIndex) + CRLF
            cLog += "Llave: " + cKey + CRLF
            cLog += "Error: No se encontró el registro" + CRLF
            cLog += "------------------------" + CRLF
            nError++
            aData[nX,6] := "Error"
        Else
            nSuccess++
            aData[nX,6] := "OK"
        EndIf
    Next nX

    If ExistDir("V:")
        If !ExistDir("V:\spool\")
            MakeDir("V:\spool\")
        EndIf
        cRuta := "V:\spool\"
        
    ElseIf ExistDir("C:")
        If !ExistDir("C:\spool\")
            MakeDir("C:\spool\")
        EndIf
        cRuta:= "C:\spool\"

    EndIf
    
    IF !Empty(cLog)
        MemoWrite(cRuta+cPasta, cLog)
        FWAlertError("Proceso finalizado con " + ALLTRIM(Str(nSuccess)) + " sucessos y " + ALLTRIM(Str(nError)) + " errores. Verifique el log para mas detalles.")
        ShellExecute("OPEN", cPasta, "", cRuta, 1)
    Else
        FWAlertSuccess("Todos los registros fueron actualziados con exito","MODIFICACION MASIVA")
    ENDIF

Return

//-----------------------------------------------------------------------------
// Funcion: ValidateTableFields
// Descripcion: Valida la existencia de la tabla y los campos
// Parametros: cTable - Nombre de la tabla
//             aFields - Array con los campos a validar
// Retorno: .T. si la tabla y campos existen, .F. en caso contrario
//-----------------------------------------------------------------------------
Static Function ValidateTableFields(cTable, aFields, cInvalidField)
    Local lRet := .T.
    Local nX
    
    // Verificar si los campos existen
    DbSelectArea(cTable)
    For nX := 1 To Len(aFields)
        If !FieldPos(AllTrim(aFields[nX])) > 0
            lRet := .F.
            cInvalidField := AllTrim(aFields[nX])
            Exit
        EndIf
    Next nX
    
Return lRet

//-----------------------------------------------------------------------------
// Funcion: GetIndexFields
// Descripcion: Obtiene los campos que componen un índice
// Parametros: cTable - Nombre de la tabla
//             nIndex - Número del índice
// Retorno: Array con los nombres de los campos del índice
//-----------------------------------------------------------------------------
Static Function GetIndexFields(cTable, nIndex)
    Local aFields := {}
    Local cIndex := ""
    Local cField := ""
    Local nPos := 0
    
    // Obtener la expresión del índice
    cIndex := (cTable)->(IndexKey(nIndex))
    
    // Separar los campos del índice
    While !Empty(cIndex)
        nPos := At("+", cIndex)
        If nPos > 0
            cField := Left(cIndex, nPos - 1)
            cIndex := SubStr(cIndex, nPos + 1)
        Else
            cField := cIndex
            cIndex := ""
        EndIf
        // Excluir campos que contengan _FILIAL
        If !("_FILIAL" $ cField)
            aAdd(aFields, AllTrim(cField))
        EndIf
    EndDo
    
Return aFields

//-----------------------------------------------------------------------------
// Funcion: UpdateRecord
// Descripcion: Actualiza un registro en la tabla especificada
// Parametros: cTable - Nombre de la tabla
//             nIndex - Numero del indice a usar
//             cKey - Valor de la llave a buscar
//             aFields - Array con los campos a actualizar
//             aValues - Array con los valores nuevos
// Retorno: .T. si la actualizacion fue exitosa, .F. en caso contrario
//-----------------------------------------------------------------------------
Static Function UpdateRecord(cTable, nIndex, cKey, aFields, aValues)
    Local lRet := .T.
    Local nX
    Local cSeekKey := ""
    Local aIndexFields := {}
    Local aUserKeys := {}
    Local cField
    Local aArea     := GetArea()
    // Abre la tabla
    DbSelectArea(cTable)
    (cTable)->(DbSetOrder(nIndex))
    
    // Obtener los campos del índice (excluyendo _FILIAL)
    aIndexFields := GetIndexFields(cTable, nIndex)
    
    // Separar las llaves del usuario
    aUserKeys := StrTokArr(cKey, "+")
    
    // Construir la llave de búsqueda solo con los valores que envía el usuario
    For nX := 1 To Len(aUserKeys)
        If nX <= Len(aIndexFields)
            cField := aIndexFields[nX]
            cSeekKey += PADR(aUserKeys[nX], TamSX3(cField)[1])
        EndIf
    Next nX
    
    cSeekKey := xfilial() + cSeekKey
    
    If !(cTable)->(DbSeek(cSeekKey))
        Return .F.
    EndIf
    
    // Atualiza os campos
    RecLock(cTable, .F.)
    For nX := 1 To Len(aFields)
        If nX <= Len(aValues)
            &(cTable + "->" + AllTrim(aFields[nX])) := ALLTRIM(aValues[nX])
        EndIf
    Next nX
    (cTable)->(MsUnlock())
    
    RestArea(aArea)
Return lRet


