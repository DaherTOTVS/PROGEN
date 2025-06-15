#include "totvs.ch"

User Function AddFieldsSB1()
    Local aCampos := {}
    Local nx      := 0
    Local cOrdem  := ""
    Local cEmp    := cEmpAnt // Obtiene el código de la empresa actual
    Local cQuery  := ""
    Local cTabela := "SX3X31" + cEmp // Nombre de la tabla con código de empresa
    Local nRecno  := 0

    // Lista de campos a agregar - Formato: {Campo, Título, Descripción, Tipo, Tamaño, Decimal}
    aAdd(aCampos, {"B1_XCONTAV", "Cuenta Venta", "Cuenta Contable para Ventas e Ingresos", "C", 20, 0})
    aAdd(aCampos, {"B1_XCONTAC", "Cuenta Costo", "Cuenta Contable para Costo de Venta Nacional", "C", 20, 0})
    aAdd(aCampos, {"B1_XCONTAD", "Cuenta Devol", "Cuenta Contable para Devolución de Ventas", "C", 20, 0})
    aAdd(aCampos, {"B1_XCONCO", "Cuenta Costo Exp", "Cuenta Contable para Costo de Venta Exportación", "C", 20, 0})
    aAdd(aCampos, {"B1_XCTADTO", "Cuenta Dcto", "Cuenta Contable para Descuento de Ventas Nacional", "C", 20, 0})
    aAdd(aCampos, {"B1_XDESEXT", "Cuenta Dcto Exp", "Cuenta Contable para Descuento de Ventas Exportación", "C", 20, 0})
    aAdd(aCampos, {"B1_XCTAEXT", "Cuenta Vta Exp", "Cuenta Contable para Venta Exportación", "C", 20, 0})
    aAdd(aCampos, {"B1_XDEVEXT", "Cuenta Dev Exp", "Cuenta Contable para Devolución Exportación", "C", 20, 0})
    aAdd(aCampos, {"B1_XCUSING", "Cuenta Costo", "Cuenta Contable para Costo de Producto", "C", 20, 0})
    aAdd(aCampos, {"B1_XCUSGAS", "Cuenta Proceso", "Cuenta Contable para Procesos", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTADM", "Cuenta Gto Adm", "Cuenta Contable para Gasto Administrativo", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTCOM", "Cuenta Gto Vta", "Cuenta Contable para Gasto de Ventas", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTOPE", "Cuenta Gto Ope", "Cuenta Contable para Costo Operacional", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTINN", "Cuenta Gto Inn", "Cuenta Contable para Gastos Innovación", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTATF", "Cuenta Activo", "Cuenta Contable para Activo", "C", 20, 0})
    aAdd(aCampos, {"B1_XGTPRY", "Cuenta Proy", "Cuenta Contable para Proyecto", "C", 20, 0})

    // Obtener el orden inicial de SX3 una sola vez
    DbSelectArea('SX3')
    SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
    SX3->(DbSeek("SB1"))
    While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "SB1"
        cOrdem  := SX3->X3_ORDEM
        SX3->(DbSkip())
    End
    cOrdem := Soma1(cOrdem)

    For nx := 1 To Len(aCampos)
        DbSelectArea('SX3')
        DbSetOrder(2)
        If !DbSeek(aCampos[nx][1])
            // Obtener el siguiente R_E_C_N_O_
            cQuery := "SELECT ISNULL(MAX(R_E_C_N_O_), 0) + 1 AS NEXT_RECNO FROM " + cTabela
            DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
            nRecno := TRB->NEXT_RECNO
            DbCloseArea("TRB")
            
            // INSERT unificado con todos los campos y validación de existencia
            cQuery := "INSERT INTO " + cTabela + " ("
            cQuery += "R_E_C_N_O_, X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, "
            cQuery += "X3_TITULO, X3_TITSPA, X3_TITENG, X3_DESCRIC, X3_DESCSPA, X3_DESCENG, "
            cQuery += "X3_PICTURE, X3_USADO, X3_RESERV, X3_PROPRI, "
            cQuery += "X3_BROWSE, X3_VISUAL, X3_CONTEXT, X3_ORDEM, PM_0_E_M_P, D_E_L_E_T_, "
            cQuery += "PF_L_A_G, R_E_C_D_E_L_) "
            cQuery += "SELECT "
            cQuery += alltrim(Str(nRecno)) + ", "
            cQuery += "'SB1', '" + aCampos[nx][1] + "', '" + aCampos[nx][4] + "', " + alltrim(Str(aCampos[nx][5])) + ", " + alltrim(Str(aCampos[nx][6])) + ", "
            cQuery += "'" + PadR(aCampos[nx][2], 12) + "', '" + PadR(aCampos[nx][2], 12) + "', '" + PadR(aCampos[nx][2], 12) + "', "
            cQuery += "'" + PadR(aCampos[nx][3], 25) + "', '" + PadR(aCampos[nx][3], 25) + "', '" + PadR(aCampos[nx][3], 25) + "', "
            cQuery += "'@!', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', "
            cQuery += "'xxxxxx x        ',  'U', "
            cQuery += "'S', 'S', 'S', '" + cOrdem + "', '" + cEmp + "', ' ', "
            cQuery += "'0', 0 "
            cQuery += "WHERE NOT EXISTS (SELECT 1 FROM " + cTabela + " WHERE X3_ARQUIVO = 'SB1' AND X3_CAMPO = '" + aCampos[nx][1] + "')"

            n1Statu := TCSqlExec(cQuery)

            if (n1Statu < 0)
                MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
            Else
                MsgInfo("Exito campos: "+aCampos[nx][1])
                cOrdem := Soma1(cOrdem) // Incrementar el orden para el siguiente campo
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
