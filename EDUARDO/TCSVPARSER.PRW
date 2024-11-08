#include "Protheus.ch"

Class TCsvParser   
      Data cSep     
      
      Method New(cSep) CONSTRUCTOR
              
      Method SetSep(cSep)  
      Method GetSep()
      
      Method ParseLine(cLine) 
           
      Method AdvPlain(cLine, cBuffer, iIIndex)      
      Method AdvQuoted(cLine, cBuffer, iIIndex)      
      
EndClass   

Method New( cSep ) Class TCsvParser 
	 DEFAULT cSep := ','
     ::SetSep(cSep)
Return Self                        

Method SetSep(cSep) Class TCsvParser
     If Len(cSep) < 1
        ::cSep := ','              
     Else                           
        ::cSep := SubStr(cSep,1,1)
     EndIF
Return               

Method GetSep() Class TCsvParser
Return ::cSep

Method ParseLine(cLine) Class TCsvParser
   local aList := {}         
   local cBuffer := ''
   local iIndex := 1
   
   
   local nLSize := Len(cLine)
   local cChar := ''
    
   If Len(cLine) = 0 
      aAdd(aList,cLine)
      Return aList
   EndIf

   WHILE iIndex <= nLSize
      cBuffer := ''
      If iIndex < nLSize .AND. SubStr(cLine,iIndex,1) = '"'  
          iIndex++
          iIndex := ::AdvQuoted(cLine,@cBuffer,iIndex)  // skip quote
      Else
          iIndex := ::AdvPlain(cLine,@cBuffer, iIndex)
      EndIf                      
      aAdd(aList,cBuffer)
      iIndex++
   EndDo
   
   
Return aList           

 /** advQuoted: quoted field; return index of next separator */
Method advQuoted(cLine,cBuffer,iIIndex) Class TCsvParser
    local iJindex
    local iLen := Len(cLine)
    
    For iJindex := iIIndex  TO iLen
        If SubStr(cLine,iJIndex,1) = '"' .AND. (iJIndex < iLen)
                If SubStr(cLine,iJIndex+1,1) = '"'
                    iJIndex++ // skip escape char
                Else 
                    If SubStr(cLine,iJIndex+1,1) = ::cSep  //next delimeter
                       iJIndex++ // skip end quotes
                       Exit
                    EndIf
                EndIf
        Else 
          If SubStr(cLine,iJIndex,1) = '"' .AND. iJIndex = iLen  // end quotes at end of line
            Exit
          EndIf
        EndIf
        
      cBuffer := cBuffer + SubStr(cLine,iJIndex,1)  // regular character.
    Next iJIndex
Return iJIndex


  /** advPlain: unquoted field; return index of next separator */
Method advPlain(cLine, cBuffer,iIIndex) Class TCsvParser
    local iJIndex
    iJIndex = At(::cSep,SubStr(cLine,iIIndex,Len(cLine))) // look for separator
        If iJIndex = 0                 // none found
            cBuffer := cBuffer + SubStr(cLine,iIIndex,Len(cLine))
            Return Len(cLine)
        Else 
            iJIndex := iJIndex - 1
            cBuffer := cBuffer + SubStr(cLine,iIIndex,iJIndex)
            Return iIIndex + iJIndex
        EndIf    
Return        

User Function DummyFTCsv() 
    local cNome
    cNome := 'Nothing TCsvParser'
Return