#include "Protheus.ch"  
#include "FileIO.ch"


Class TLog 
    
    Data cName
    Data hFile                   
    Data cHeadTxt

	Method New(cFileName) CONSTRUCTOR
	
	Method WriteLog(cText)
	Method IsOpen()
	Method Close()
	
EndClass      

Method New(cFileName) Class TLog
	::cName := cFileName 
	
	if File( ::cName )
       ::hFile = FOpen( ::cName, FO_READWRITE )
       FSeek( ::hFile, 0, FS_END )
    else
       ::hFile = FCreate( ::cName, FC_NORMAL )
    endif       
    
    If ( ::hFile < 0)
          Return NIL
    EndIf                
    
    ::cHeadTxt := DToC( Date() ) + " " + Time()
	
	::WriteLog('----------Init Log '+::cHeadTxt+'-------------------')
Return Self

Method WriteLog(cText) Class TLog
    cText := cText + CRLF
    FWrite(::hFile, cText, Len(cText) )
Return           

Method IsOpen() Class TLog
Return (::hFile > 0)


Method Close() Class TLog  
    If ::IsOpen()
	  ::WriteLog('----------End Log '+::cHeadTxt+'--------------------')
	  FClose(::hFile)
	  ::hFile := 0
    EndIf
Return       

User Function DummyFTLog() 
    local cNome
    cNome := 'Nothing Tlog'
Return



