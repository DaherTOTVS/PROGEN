
#Include "Protheus.ch"
#Include "TopConn.ch"



User Function EXCEL1()


    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := "TABLAS TRANSACCIONES"
    Local oGroup1
    Local oMultiGe1
    Local cMultiGe1 := "SQL"
    Local oSay1
    Local oSay2
    Static oDlg




    DEFINE MSDIALOG oDlg TITLE "Exportar a Excel consulta SQL. " FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL
    @ 009, 007 GROUP oGroup1 TO 239, 440 PROMPT "Generador de Consulta SQL a EXCEL..." OF oDlg COLOR 0, 16777215 PIXEL
    @ 022, 013 SAY oSay1 PROMPT "Indique por favor una consulta en formato SQL para importarla en Excel." SIZE 211, 009 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 023 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 400, 159 COLORS 0, 16777215 HSCROLL PIXEL
    @ 217, 021 BUTTON oButton1 PROMPT "Exportar" SIZE 048, 014 action processa({|| fProcessa(cMultiGe1, cGet1) }, "Processando...") OF oDlg PIXEL
    @ 215, 230 BUTTON oButton2 PROMPT "Salir" SIZE 044, 016 ACTION   oDlg:End() OF oDlg PIXEL
    @ 037, 017 SAY oSay2 PROMPT "Titulo de la Consulta:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 037, 071 MSGET oGet1 VAR cGet1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL
    ACTIVATE MSDIALOG oDlg CENTERED
Return




Return




Static Function fProcessa(cQryAux, cTitAux)
    Local aArea       := GetArea()
    Local aAreaX3     := SX3->(GetArea())
    Local nAux        := 0
    Local oFWMsExcel
    Local oExcel
    Local cDiretorio  := GetTempPath()
    // Local cArquivo    := 'zQry2Excel.xml'
    Local dData := DTOC(DATE())
    Local dtime := Time()
    Local cArquivo    := alltrim(cTitAux) +"_"+ dData +"_"+ dtime+".xml"
    cArquivo := replace(cArquivo,"/","")
    cArquivo := replace(cArquivo,":","")
    Local cArqFull    := cDiretorio + cArquivo
    Local cWorkSheet  := "Hoja Principal"
    Local cTable      := ""
    Local aColunas    := {}
    Local aEstrut     := {}
    Local aLinhaAux   := {}
    Local cTitulo     := ""
    Local nTotal      := 0
    Local nAtual      := 0
    Default cQryAux   := ""
    Default cTitAux   := "Tutulo de la consulta"

    cTable := cTitAux

    cQryAux = ""

    cQryAux +=" SELECT "
    cQryAux +=" E2_VALOR,E2_VLCRUZ,CT2_VALOR,E2_TXMOEDA,E2_PREFIXO,E2_NUM,E2_FORNECE,E2_EMISSAO,F1_DTDIGIT,CT2_VALOR"
    cQryAux +=" FROM SE2010 E2"
    cQryAux +=" INNER JOIN SF1010 F1"
    cQryAux +=" ON F1_DOC=E2_NUM "
    cQryAux +=" AND F1.D_E_L_E_T_='' "
    cQryAux +=" INNER JOIN CT2010 CT2 "
    cQryAux +=" ON F1_DTDIGIT=CT2_DATA "
    cQryAux +=" AND  CT2_SBLOTE ='NFP' AND CT2_MOEDLC='01' "
    cQryAux +=" AND CT2_ORIGEM='660-301' "
    cQryAux +=" AND CT2_HIST LIKE  '%' || TRIM(E2_NUM) || '%' "
    cQryAux +=" AND CT2.D_E_L_E_T_='' "
    cQryAux +=" WHERE E2.D_E_L_E_T_='' AND E2_MOEDA  ='1' "
    cQryAux +=" AND E2_VALOR != E2_VLCRUZ "

    

    if (cQryAux) $"UPDATE" .OR. (cQryAux) $"Update" .OR. (cQryAux) $"update"
        //  TCSQLEXEC(cQryAux)
        Return
    EndIf


    if cQryAux $"DELETE" .OR. cQryAux $"Delete" .OR. cQryAux $"delete"
        Alert("NO PUEDE EJECUTAT CONSULTAS DE TIPO DELETE")
        Return
    EndIf
    if cQryAux $"INSERT" .OR. cQryAux $"Insert" .OR. cQryAux $"insert"
        Alert("NO PUEDE EJECUTAT CONSULTAS DE TIPO INSERT ")
        Return
    EndIf

    n1Statu :=TCSqlExec(cQryAux)
    if (n1Statu < 0)
        MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
    Else

        //Se tiver a consulta
        If !Empty(cQryAux)
            TCQuery cQryAux New Alias "QRY_AUX"
            DbSelectArea('SX3')
            SX3->(DbSetOrder(2)) //X3_CAMPO
            //Percorrendo a estrutura
            aEstrut := QRY_AUX->(DbStruct())
            ProcRegua(Len(aEstrut))
            For nAux := 1 To Len(aEstrut)
                IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
                cTitulo := ""
                If SX3->(DbSeek(aEstrut[nAux][1]))
                    cTitulo := Alltrim(SX3->X3_TITULO)
                    If SX3->X3_TIPO == 'D'
                        TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
                    EndIf
                Else
                    cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
                EndIf

                aAdd(aColunas, cTitulo)
            Next
            oFWMsExcel := FWMSExcel():New()
            oFWMsExcel:AddworkSheet(cWorkSheet)
            oFWMsExcel:AddTable(cWorkSheet, cTable)
            For nAux := 1 To Len(aColunas)
                oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
            Next
            DbSelectArea("QRY_AUX")
            QRY_AUX->(DbGoTop())
            Count To nTotal
            ProcRegua(nTotal)
            nAtual := 0
            QRY_AUX->(DbGoTop())
            While !QRY_AUX->(EoF())
                nAtual++
                IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

                aLinhaAux := Array(Len(aColunas))
                For nAux := 1 To Len(aEstrut)
                    aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
                Next
                oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
                QRY_AUX->(DbSkip())
            EndDo
            oFWMsExcel:Activate()
            oFWMsExcel:GetXMLFile(cArqFull)
            If ApOleClient("msexcel")
                oExcel := MsExcel():New()
                oExcel:WorkBooks:Open(cArqFull)
                oExcel:SetVisible(.T.)
                oExcel:Destroy()
            Else
                If ExistDir("C:\Program Files (x86)\LibreOffice 5")
                    WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 1)

                    //Senão, abre o XML pelo programa padrão
                Else
                    ShellExecute("open", cArquivo, "", cDiretorio, 1)
                EndIf
            EndIf

            QRY_AUX->(DbCloseArea())
        EndIf
    EndIf
    RestArea(aAreaX3)
    RestArea(aArea)
Return
