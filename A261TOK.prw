#INCLUDE "RWMAKE.CH"
#Include "Protheus.Ch"

User Function A261TOK()
Local aArea      := GetArea()
Local aSD3Area   := SD3->(GetArea())
Local i           
Local lRet       := .T.

// Local nPosCODOri	:= 1 	//Codigo do Produto Origem
// Local nPosLoTCTL	:= 12	//Lote de Controle
// Local nPosLOCOri 	:= 4	//Armazem Origem
Local nPosDirOri 	:= 5	//Armazem Origem

// Local nPosCODDes	:= 6	//Codigo do Produto Destino
// Local nPosLOCDes	:= 9	//Armazem Destino
Local nPosDirDes 	:= 10	//Armazem Origem
// Local nPosLotDes	:= 20	//Lote Destino
// Local nPosQUANT	    := 16	//Quantidade
// Local nPosDtVldD	:= 21	//Data Valida de Destino
// Local nPosDTVAL	    := 14	//Data Valida


For i := 1 to len(aCols)
    If !Empty(Alltrim(aCols[i][nPosDirOri]))
        If Empty(Alltrim(aCols[i][nPosDirDes]))
            aCols[i][nPosDirDes]:=aCols[i][nPosDirOri]
        EndIF
    EndIF
Next

RestArea(aSD3Area)
RestArea(aArea)
Return lRet
