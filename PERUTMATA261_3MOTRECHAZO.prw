User Function MA261IN()
Local nxMOT	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D3_XMOT"})
Local nxmdes  := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_XMDES"})
 
 /*aCols[Len(aCols)][nxMOT]  := SD3->D3_XMOT
 aCols[Len(aCols)][nxmdes] := SD3->D3_XMDES*/

Return nil
