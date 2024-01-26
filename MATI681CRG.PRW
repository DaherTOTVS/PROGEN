	
#Include 'Protheus.ch'

User Function MATI681CRG()
Local aRet := {} 
Local nPos := aScan(PARAMIXB,{|aX| AllTrim(aX[1]) == "H6_TIPO"})

Local RealCrew := ""


IF type(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text) != "U"
    If PARAMIXB[nPos,2] == "P"

        RealCrew:=oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text
        aAdd(aRet,{"H6_FERRAM",RealCrew, Nil}) 

    EndIf
EndIf

Return aRet
