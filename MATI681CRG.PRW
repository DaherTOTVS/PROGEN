	
#Include 'Protheus.ch'

User Function MATI681CRG()
Local aRet := {} 
Local nPos := aScan(PARAMIXB,{|aX| AllTrim(aX[1]) == "H6_TIPO"})
Local RealCrew := ""
CONOUT('RealCrew_dh',RealCrew )
IF Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text") != "U" .And. ;
    !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text)
    CONOUT('MATI681CRG_PARAMIXB',PARAMIXB[nPos,2] )
    If PARAMIXB[nPos,2] == "P"
        RealCrew:=oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text
        CONOUT('MATI681CRG_RealCrew',RealCrew )
        aAdd(aRet,{"H6_CERQUA",RealCrew, Nil}) 

    EndIf
EndIf

Return aRet
