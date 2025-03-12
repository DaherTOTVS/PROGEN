/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE Seria autiamtica º Autor ³ M&H º Data ³  01/10/22	      º±±
±± para rutina "Generacion Notas FV"                                       ±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ 										                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Progen                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/ 
#include "rwmake.ch"
#include 'protheus.ch'

USER Function M468ASER()

 Local aArea := GetArea()
 Local cAlias1	:= " "
 Local cF2Filial := xfilial("SF2")
 Local cDoc := ""

    cSerieFact := Alltrim(Getnewpar("MV_SERNFCO","FVE"))
    dbSelectArea("SX5")
	IF MsSeek(xFilial("SX5")+"01"+AllTrim(cSerieFact))
        cAlias1	:= GetNextAlias()
        BeginSQL Alias cAlias1
            SELECT TOP 1 (T1.F2_DOC + 1) AS Numfal
            FROM SF2010 T1
            LEFT JOIN SF2010 T2
            ON T1.F2_DOC + 1 = T2.F2_DOC
            AND T1.F2_FILIAL=T2.F2_FILIAL
            AND T1.F2_SERIE=T2.F2_SERIE
            AND T1.F2_ESPECIE=T2.F2_ESPECIE
            WHERE T2.F2_DOC IS NULL
            AND T1.F2_FILIAL = %Exp:cF2Filial%
            AND T1.F2_SERIE=%Exp:cSerieFact%
            AND T1.F2_ESPECIE='NF'
        EndSQL

        IF (cAlias1)->(!Eof())
            cDoc := PADL((cAlias1)->Numfal,TamSX3("F2_DOC")[1],'0')
            RecLock("SX5",.F.)
                Replace X5_DESCRI  with cDoc
                Replace X5_DESCSPA with cDoc
                Replace X5_DESCENG with cDoc
            SX5->(MsUnlock())
        EndIf
        (cAlias1)->(dbCloseArea())
    EndIf

RestArea(aArea)
Return (cSerieFact)
