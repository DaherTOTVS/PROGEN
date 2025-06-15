#include "totvs.ch"

User Function INSERTSX3()
    Local aCampos := {}
    Local nx      := 0
    Local cOrdem  := ""
    Local cEmp    := cEmpAnt
    Local cQuery  := ""
    Local cTabela := "SX3X31" + cEmp
    Local nRecno  := 0
    Local aLetras := {"D", "E", "F", "F", "G"}
    Local nL      := 0

    // Lista de campos a agregar - Formato: {Campo, Título, Descripción, Tipo, Tamaño, Decimal, Tabla}
    For nL := 1 To Len(aLetras)
        // Campos para SF1
        aAdd(aCampos, {"F1_BASIMP" + aLetras[nL], "Base Imp " + aLetras[nL], "Base Impuesto " + aLetras[nL], "N", 14, 2, "SF1"})
        aAdd(aCampos, {"F1_VALIMP" + aLetras[nL], "Val Imp " + aLetras[nL], "Valor Impuesto " + aLetras[nL], "N", 14, 2, "SF1"})
        
        // Campos para SF2
        aAdd(aCampos, {"F2_BASIMP" + aLetras[nL], "Base Imp " + aLetras[nL], "Base Impuesto " + aLetras[nL], "N", 14, 2, "SF2"})
        aAdd(aCampos, {"F2_VALIMP" + aLetras[nL], "Val Imp " + aLetras[nL], "Valor Impuesto " + aLetras[nL], "N", 14, 2, "SF2"})
        
        // Campos para SF3
        aAdd(aCampos, {"F3_BASIMP" + aLetras[nL], "Base Imp " + aLetras[nL], "Base Impuesto " + aLetras[nL], "N", 14, 2, "SF3"})
        aAdd(aCampos, {"F3_VALIMP" + aLetras[nL], "Val Imp " + aLetras[nL], "Valor Impuesto " + aLetras[nL], "N", 14, 2, "SF3"})
        aAdd(aCampos, {"F3_ALQIMP" + aLetras[nL], "Alq Imp " + aLetras[nL], "Alícuota Impuesto " + aLetras[nL], "N", 6, 2, "SF3"})
        
        // Campos para SD1
        aAdd(aCampos, {"D1_BASIMP" + aLetras[nL], "Base Imp " + aLetras[nL], "Base Impuesto " + aLetras[nL], "N", 14, 2, "SD1"})
        aAdd(aCampos, {"D1_VALIMP" + aLetras[nL], "Val Imp " + aLetras[nL], "Valor Impuesto " + aLetras[nL], "N", 14, 2, "SD1"})
        aAdd(aCampos, {"D1_ALQIMP" + aLetras[nL], "Alq Imp " + aLetras[nL], "Alícuota Impuesto " + aLetras[nL], "N", 6, 2, "SD1"})
        
        // Campos para SD2
        aAdd(aCampos, {"D2_BASIMP" + aLetras[nL], "Base Imp " + aLetras[nL], "Base Impuesto " + aLetras[nL], "N", 14, 2, "SD2"})
        aAdd(aCampos, {"D2_VALIMP" + aLetras[nL], "Val Imp " + aLetras[nL], "Valor Impuesto " + aLetras[nL], "N", 14, 2, "SD2"})
        aAdd(aCampos, {"D2_ALQIMP" + aLetras[nL], "Alq Imp " + aLetras[nL], "Alícuota Impuesto " + aLetras[nL], "N", 6, 2, "SD2"})
    Next nL

    For nx := 1 To Len(aCampos)
        DbSelectArea('SX3')
        DbSetOrder(2)
        If !DbSeek(aCampos[nx][1])
            // Obtener el siguiente R_E_C_N_O_
            cQuery := "SELECT ISNULL(MAX(R_E_C_N_O_), 0) + 1 AS NEXT_RECNO FROM " + cTabela
            DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
            nRecno := TRB->NEXT_RECNO
            DbCloseArea("TRB")
            
            // Obtener el último orden de la tabla de inserción
            cQuery := "SELECT ISNULL(MAX(X3_ORDEM), '00') AS LAST_ORDEM FROM " + cTabela + " WHERE X3_ARQUIVO = '" + aCampos[nx][7] + "'"
            DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
            cOrdem := TRB->LAST_ORDEM
            DbCloseArea("TRB")
            
            // Si no hay registros en la tabla de inserción, obtener de SX3
            If Empty(cOrdem) .OR. cOrdem == "00"
                DbSelectArea('SX3')
                SX3->(DbSetOrder(1))
                SX3->(DbSeek(aCampos[nx][7]))
                cOrdem := "00"
                While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == aCampos[nx][7]
                    cOrdem := SX3->X3_ORDEM
                    SX3->(DbSkip())
                End
            EndIf
            
            cOrdem := Soma1(cOrdem)
            
            // INSERT unificado con todos los campos y validación de existencia
            cQuery := "INSERT INTO " + cTabela + " ("
            cQuery += "R_E_C_N_O_, X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, "
            cQuery += "X3_TITULO, X3_TITSPA, X3_TITENG, X3_DESCRIC, X3_DESCSPA, X3_DESCENG, "
            cQuery += "X3_PICTURE, X3_USADO, X3_RESERV, X3_PROPRI, "
            cQuery += "X3_BROWSE, X3_VISUAL, X3_CONTEXT, X3_ORDEM, PM_0_E_M_P, D_E_L_E_T_, "
            cQuery += "PF_L_A_G, R_E_C_D_E_L_) "
            cQuery += "SELECT "
            cQuery += alltrim(Str(nRecno)) + ", "
            cQuery += "'" + aCampos[nx][7] + "', '" + aCampos[nx][1] + "', '" + aCampos[nx][4] + "', " + alltrim(Str(aCampos[nx][5])) + ", " + alltrim(Str(aCampos[nx][6])) + ", "
            cQuery += "'" + PadR(aCampos[nx][2], 12) + "', '" + PadR(aCampos[nx][2], 12) + "', '" + PadR(aCampos[nx][2], 12) + "', "
            cQuery += "'" + PadR(aCampos[nx][3], 25) + "', '" + PadR(aCampos[nx][3], 25) + "', '" + PadR(aCampos[nx][3], 25) + "', "
            cQuery += "'@E 99,999,999,999.99', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', "
            cQuery += "'xxxxxx x        ',  'U', "
            cQuery += "'N', 'A', 'R', '" + cOrdem + "', '" + cEmp + "', ' ', "
            cQuery += "'0', 0 "
            cQuery += "WHERE NOT EXISTS (SELECT 1 FROM " + cTabela + " WHERE X3_ARQUIVO = '" + aCampos[nx][7] + "' AND X3_CAMPO = '" + aCampos[nx][1] + "')"

            n1Statu := TCSqlExec(cQuery)

            if (n1Statu < 0)
                MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
            Else
                MsgInfo("Exito campos: "+aCampos[nx][1] + " en tabla " + aCampos[nx][7])
            EndIf
        EndIf
    Next nx

Return


Static Function RetSX3Ord(cTabla)
Local cOrdem	:= "00"
Local aArea     := GetArea()


    DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
    SX3->(DbSeek(cTabla))
    While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cTabla
        cOrdem  := SX3->X3_ORDEM
        SX3->(DbSkip())
    End

cOrdem  := Soma1(cOrdem)

RestArea(aArea)

Return cOrdem
