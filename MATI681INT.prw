#Include "Protheus.ch"
 
User Function MATI681INT()

        local aRet := {}
        Local oXML := PARAMIXB //Referência do objeto contendo as informações que foram recebidas no XML.      
        Local tipe := ""
        // Private oXML := oXMLEnv //

  

        tipe := Type("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartReportDateTime:Text")
        CONOUT('MATI681INT','pe_MATI681INT__StartReportDateTime' )
        CONOUT('TYPE',tipe )




        If Type("oXML:_TotvsMessage:_BusinessMessage:_BusinessContent:_RealCrew:Text") != "U"

            CONOUT('MATI681INT','pe_MATI681INT_REALCREW' ) 

        EndIf

        aAdd(aRet, .T.) // XML importado com sucesso


Return aRet
