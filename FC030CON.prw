#include "protheus.ch"
#include "rwmake.ch"
#include "PRTOPDEF.CH"

User Function FC030CON()
    Local aArea := GetArea()
    Local cNumDoc := ""                // Variable para el número de documento
    Local aResult := {}                // Array para almacenar los resultados filtrados
    Local cQry := ""                   // Variable para la consulta SQL
    Local oBrw := Nil                  // Objeto TcBrowse
    Local oDlg := Nil                  // Diálogo para mostrar resultados
    Local oPanel := Nil                // Objeto TPanel
    Local oBtnOk := Nil                // Botón OK
    Local oBtnCancel := Nil            // Botón Cancelar
    Local lRet := .F.                  // Resultado de la acción del usuario.

    // Solicita al usuario que ingrese el número de documento a filtrar
    cNumDoc := Alltrim(FWInputBox("Digite número de documento:", cNumDoc))

    If !Empty(cNumDoc)
        // Construye la consulta SQL
        cQry := "SELECT E2_NUM, E2_FORNECE, E2_VALOR , E2_SALDO , E2_MOEDA , E2_ORDPAGO FROM " + RetSqlName("SE2") + " SE2 " + CRLF
        cQry += "WHERE E2_FORNECE = '" + SA2->A2_COD + "'" + CRLF
        cQry += "AND E2_LOJA = '" + SA2->A2_LOJA + "'" + CRLF
        cQry += "AND E2_NUM = '" + cNumDoc + "'" + CRLF
        cQry += "AND SE2.D_E_L_E_T_ = ''" + CRLF

        // Cambia el nombre de la consulta en caso de necesidad
        cQry := ChangeQuery(cQry)

        // Cierra el área actual si está en uso
        If Select("StrSQL") > 0
            StrSQL->(DbCloseArea())
        EndIf

        // Usa el área de consulta
        DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), "StrSQL", .F., .T.)
        DbSelectArea("StrSQL")
        DbGoTop()

        // Procesa los resultados del cursor
        While !StrSQL->(Eof())
            AAdd(aResult, {StrSQL->E2_NUM, StrSQL->E2_FORNECE, StrSQL->E2_VALOR , StrSQL->E2_SALDO , StrSQL->E2_MOEDA , StrSQL->E2_ORDPAGO })
            StrSQL->(DbSkip())
        EndDo

        // Cierra el área de consulta
        StrSQL->(DbCloseArea())
        
        // Restaura el área de trabajo original
        RestArea(aArea)

        // Verifica si se encontraron registros
        If Len(aResult) > 0
            // Define el diálogo
            DEFINE DIALOG oDlg TITLE "Resultado del Filtro" FROM 180, 180 TO 550, 700 PIXEL

            // Crea el objeto TcBrowse
            oBrw := TCBrowse():New(001, 001 , 560 , 150  , , , ,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

              // Configura las columnas del TcBrowse
            oBrw:AddColumn(TCColumn():New("Número Documento", { || aResult[ oBrw:nAt, 1 ] }, , , , "LEFT", 30, .F., .F.))
            oBrw:AddColumn(TCColumn():New("Proveedor", { || aResult[ oBrw:nAt, 2 ] }, , , , "LEFT", 30 , .F., .F.))
            oBrw:AddColumn(TCColumn():New("Valor", { || Transform(aResult[ oBrw:nAt, 3 ], "@E 999,999,999.99") }, , , , "LEFT", 15, .F., .F.))
            oBrw:AddColumn(TCColumn():New("Saldo", { || Transform(aResult[ oBrw:nAt, 4 ], "@E 999,999,999.99") }, , , , "LEFT", 15, .F., .F.))
            oBrw:AddColumn(TCColumn():New("Moeda", { || aResult[ oBrw:nAt, 5 ]}, , , , "LEFT", 15, .F., .F.))
            oBrw:AddColumn(TCColumn():New("Ord.Pago", { || aResult[ oBrw:nAt, 6 ] }, , , , "LEFT", 10, .F., .F.))
           
            // Asigna los datos al TcBrowse
            oBrw:SetArray(aResult)

            // Crea un panel para los botones 
            oPanel := TPanel():New(160, 160, , oDlg, , , , , , , , , , , , 020, 060, .F., .F.)
            oPanel:Align := CONTROL_ALIGN_BOTTOM
            oPanel:NCLRPANE := RGB(233, 233, 233) // Color de fondo del panel  

            // Define los botones en el panel
            DEFINE SBUTTON oBtnOk FROM 170, 088 TYPE 1 ENABLE OF oPanel ACTION (lRet := .T., oDlg:End())
            DEFINE SBUTTON oBtnCancel FROM 170, 121 TYPE 2 ENABLE OF oPanel ACTION (lRet := .F., oDlg:End())

            // Activa el diálogo con el TcBrowse y el panel de botones
            ACTIVATE DIALOG oDlg CENTERED

        Else
            ConOut("Nenhum documento encontrado com o número: " + cNumDoc)
        EndIf

    Else
        ConOut("Número de documento no informado.")
    EndIf

Return lRet
