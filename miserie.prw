#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"


user function miserie(cSerie,cEspecie,cTabla)

Local aArea := GetArea()
Local cAlias1 := ""
Local cDoc := ""

Default cSerie := "ZZZ"
Default Tabla :=  "ZZZ"
Default cEspecie := "ZZ"

dbSelectArea("SX5")
If MsSeek(xFilial("SX5")+"01"+ALLTRIM(cSerie))
    cDoc := X5_DESCSPA
    cTabla:=ALLTRIM(cTabla)
    cAlias1 := GetNextAlias()

    If (cTabla=='SF1')
        BeginSQL Alias cAlias1
            SELECT TOP 1 (T1.F1_DOC + 1) AS NumFal
            FROM  %table:SF1% T1
            LEFT JOIN %table:SF1% T2
            ON T1.F1_DOC + 1 = T2.F1_DOC
            AND T1.F1_FILIAL = T2.F1_FILIAL
            AND T1.F1_SERIE = T2.F1_SERIE
            AND T1.F1_ESPECIE = T2.F1_ESPECIE
            AND T2.%notDel%
            WHERE T2.F1_DOC IS NULL
            AND T1.F1_FILIAL = %Exp:xFilial(cTabla)%
            AND T1.F1_SERIE = %Exp:cSerie% 
            AND T1.F1_ESPECIE = %Exp:cEspecie%
            AND T1.%notDel%
        EndSQL
        If (cAlias1)->(!Eof())
            cDoc := PADL((cAlias1)->NumFal,TamSX3("F1_DOC")[1],'0')
        EndIf
    Else
        BeginSQL Alias cAlias1
            SELECT TOP 1 (T1.F2_DOC + 1) AS NumFal
            FROM  %table:SF2% T1
            LEFT JOIN %table:SF2% T2
            ON T1.F2_DOC + 1 = T2.F2_DOC
            AND T1.F2_FILIAL = T2.F2_FILIAL
            AND T1.F2_SERIE = T2.F2_SERIE
            AND T1.F2_ESPECIE = T2.F2_ESPECIE
            AND T2.%notDel%
            WHERE T2.F2_DOC IS NULL
            AND T1.F2_FILIAL = %Exp:xFilial(cTabla)%
            AND T1.F2_SERIE = %Exp:cSerie% 
            AND T1.F2_ESPECIE = %Exp:cEspecie%
            AND T1.%notDel%
        EndSQL
        If (cAlias1)->(!Eof())
            cDoc := PADL((cAlias1)->NumFal,TamSX3("F2_DOC")[1],'0')
        EndIf
    EndIf

    (cAlias1)->(dbCloseArea())

EndIf
RestArea(aArea)
Return (cDoc)

