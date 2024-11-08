//Modificado 12/08/09 GSantacruz 
//-Seguir las etiquetas GSA
//-Se agrego validacion de que contenga info en campos que son obligatorios
//-Se agregaron parametros para la ruta del archivo a seleccionar y log de errores
//-Saltar registro en blanco (no validar)
//-Se eliminó la vaidacion If __CUSERID
//-13/08/09 Se quitaron las funcion AnyToStr y ValidReg, se agrego la funcion InsertaRegistro para uso de aXCadastro

#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fileio.ch"                                                                                       
#INCLUDE "tcbrowse.ch"

#DEFINE MAXPREVIEW 100
#DEFINE CAMPO   1
#DEFINE TIPO    2
#DEFINE TAMANO  3
#DEFINE DECIMAL 4
#DEFINE OBRIGAT 5 
#DEFINE VALIDA   6
#DEFINE CONTENT 7

Static oDialog
Static oSayPath,oGetPath,oBtnPath,oSayLog,oGetLog,oBtnLog,oSayValid,oSayFormat
Static oSayNom,oSaynReg,oSaynFi,oRbxSep
Static cName:='',cNReg:='',cNFi:=''
Static oBtnCancel,oBtnNext,oBtnMgr,oSaySep,oGetSep,oBtnFin,oBtnLay,oCombo,oCmbDt

Static aObjects := {{'oSayPath','oGetPath','oBtnPath','oSayLog','oBtnLog','oGetLog','oBtnNext','oBtnMgr'},;
                     {'oRbxSep'},;
                     {'oSayNom','oSaynReg','oSaynFi'}}
                     
Static oLog,oLogSeg




Static cSX2 := "SX2"
Static cSX3 := "SX3"     



User Function MGR002       
   

   Local  cLog := SUPERGETMV(ALLTRIM("ES_MGDILO"), .T. ,  'C:\mp_migration_log.txt') //GSA 'C:\mp8_migration_log.txt'
   Private cPath :=SUPERGETMV(ALLTRIM("ES_MGDIAR") , .T. ,  'C:\')   //GSA 'C:\'
   Public oTable
   Private nRbx := SUPERGETMV(ALLTRIM("ES_MGSEPA"), .T. , 1)                                                  
   Private nVal :=  SUPERGETMV(ALLTRIM("ES_MGVALI"), .T. , 1)
   Private nTpDt := SUPERGETMV(ALLTRIM("ES_MGFOFE"), .T. , 1)
   Private cOtSep := SUPERGETMV(ALLTRIM("ES_MGSIMB"), .T. , ",")
   DBSELECTAREA("RGC") //GSA
//  MsgRun( "Aguarde. Preparando Ambiente..." , "Iniciando" , { || RpcSetEnv( "99" ,"01","Admin","","GPE" ) } )

   DEFINE MSDIALOG oDialog TITLE 'Importacion de Archivos CSV a Tablas de Protheus V2' FROM 0,0 TO 445,710 PIXEL

   @ 1,1 SAY oSayPath PROMPT 'Archivo' OF oDialog
   @ 1,4 MSGET oGetPath VAR cPath SIZE 180,10 OF oDialog
   @ 1,54 BUTTON oBtnPath PROMPT 'Buscar' OF oDialog ;
	       SIZE 32,10 ;
	       ACTION (nMasc:=SelArc(cPath),cPath:=cGetFile('Archivos de Texto|*.txt|Archivos CSV|*.csv','Seleccione un Archivo',nMasc,cPath))
   
   @ 2,1 SAY oSayLog PROMPT 'Log' OF oDialog
   @ 2,4 MSGET oGetLog VAR cLog SIZE 180,10 OF oDialog
   @ 2,54 BUTTON oBtnLog PROMPT 'Buscar' OF oDialog ;
	       SIZE 32,10 ;
	       ACTION (cLog:=cGetFile('Archivos de Texto|*.txt','Seleccione un Archivo',2,cLog))
           
        
   @ 1,1 SAY oSayNom PROMPT cName OF oDialog  SIZE 200,10
   @ 2,1 SAY oSaynReg PROMPT cNReg OF oDialog SIZE 200,10
   @ 3,1 SAY oSaynFi PROMPT cNfi OF oDialog   SIZE 200,10

   toggleSh(aObjects[3])   // Hide Status Labels {'oSayNom','oSaynReg','oSaynFi'}

   @ 1,35 SAY oSaySep PROMPT 'Separador' OF oDialog   
   @ 22,270 RADIO oRbxSep VAR nRbx 3D OF oDialog ;
           PROMPT ', (Coma)','; (Punto y Coma)','Otro';
           SIZE 60,10 ON CHANGE (RadChange()) PIXEL
           
   @ 3,37 MSGET oGetSep VAR cOtSep SIZE 10,10 OF oDialog CENTERED VALID validSep(cOtSep) 
   
   oGetSep:Disable()
   
   aOpt := {}
   
   aAdd(aOpt,"Si")
   aAdd(aOpt,"No")

   @ 3,9 SAY oSayValid PROMPT 'Validacion' OF oDialog   	
   @ 3,12  COMBOBOX oCombo VAR nVal ITEMS aOpt SIZE 30,10  OF oDialog ON CHANGE ( nVal := oCombo:nAt )

/* gsa  If __CUSERID <> "000000"
       oSayValid:Disable()
       oSayValid:Hide()
   	   oCombo:Disable()
	   oCombo:Hide()
   EndIf                      
  */ 
   aOptDT := {}
                    
   aAdd(aOptDt,"DD/MM/AA")
   aAdd(aOptDt,"DD/MM/AAAA")
   aAdd(aOptDt,"DDMMAA")
   aAdd(aOptDt,"DDMMAAAA")
   aAdd(aOptDt,"AAMMDD")
   aAdd(aOptDt,"AAAAMMDD")            

   @ 3,17 SAY oSayFormat PROMPT 'Formato Fecha' OF oDialog   	           
   @ 3,23  COMBOBOX oCmbDt VAR nTpDt  ITEMS aOptDt SIZE 40,10  OF oDialog ON CHANGE ( nTpDt := oCmbDt:nAt )
   

   @ 4,1  BROWSE oTable FIELDS SIZE 340,150 OF oDialog                                  
   
   @ 21,03 BUTTON oBtnLay PROMPT 'Generar Layout' OF oDialog ;
           SIZE 48,10 ;
           ACTION U_GenLayCsv()
   
   @ 21,20 BUTTON oBtnCancel PROMPT 'Cancelar' OF oDialog ;
           SIZE 32,10 ;
	       ACTION oDialog:end()	  	       
	       
   @ 21,60 BUTTON oBtnNext PROMPT 'Siguiente' OF oDialog ;
	       SIZE 32,10 ;
	       ACTION  Processa({|| TblPreview(cPath,cLog)},"Generando Vista Previa, Espere...")

   @ 21,60 BUTTON oBtnMgr PROMPT 'Comenzar' OF oDialog ;
	       SIZE 32,10 ;
	       ACTION  Processa({|| TblMgr(cPath,cLog)},"Migrando, Espere...")

   oBtnMgr:Hide()
	       
   @ 21,60 BUTTON oBtnFin PROMPT 'Finalizar' OF oDialog ;
	       SIZE 32,10 ;
	       ACTION  oDialog:end()    
   
   oBtnFin:Hide()
   

  
  
   ACTIVATE MSDIALOG oDialog CENTERED
   //GSA  graba los parametros
       GrbParam("ES_MGDIAR" ,cPath)
       GrbParam("ES_MGDILO" ,cLog)       
       GrbParam("ES_MGVALI" ,nVal)       
       GrbParam("ES_MGFOFE" ,nTpDt)       
       GrbParam("ES_MGSEPA" ,nRbx)       
       GrbParam("ES_MGSIMB" ,cOtSep)              
    //GSA
  
   
Return                                      

static function GrbParam(cParam,uVal)       
SX6->(DBSETORDER(1))
IF SX6->(DBSEEK("  "+CPARAM))
	   PUTMV(cParam, uVal)  
ENDIF 	                 
Return	         

Static Function TblPreview(cFile,cLog)
   Local fCsv
   Local iIndex,nLines                     
   Local aHeader := {}
   Local cLine := '',cSep :='', cData := ''
   Local  aFRate := {}, aRow := {}
   Public aTable := {} 

   Private oCsv        

   
   If !File(cFile)
       msgInfo('Nombre de Archivo Invalido: ' + cFile,'Error') 
       Return
   EndIf      
   
   toggleSh(aObjects[1])
   toggleEn(aObjects[2])   
   toggleEn(aObjects[3])   
   toggleSh(aObjects[3])   
//   oGetSep:Disable()
   
   cSep := GetUSep()
   
   fCsv := TTxtFile():New(cFile,FO_READ)  
   oCsv := TCsvParser():New(cSep)
   oLog := TLog():New(cLog)                                 

   
   //Log de seguridad                                    
   
   cStartPath:= GetSrvProfString("Startpath","")
   oLogSeg := TLog():New(cStartPath+"hmg_bitacora.log") 
   
   ProcRegua(MIN(MAXPREVIEW,fCsv:nTLines)+2)


   oLog:WriteLog("***********Iniciando Log de Preview")                     
   /* Read Header */
   aHeader := DetectHeader(@fCsv)
   
   If aHeader == Nil
		msgInfo('Error al procesar.'+CRLF+'Revise el Log')
  		fCsv:Close()
    	oLog:Close()
     	Return
   EndIf
   
   /* Capitalize Headers*/
   aHeader := CapArray(aHeader)
       
   aFRate := validSameAlias(aHeader)    
   
   cName := 'Archivo : ' + cFile
   cNReg := 'Numero de Registros: ' + AllTrim(Str(fCsv:RecCount()-fCsv:RecNo()) + ;
            ' , Visibles Prev. : ' + AllTrim(Str(MIN(MAXPREVIEW,fCsv:RecCount()-fCsv:RecNo()))))
   cNFi := 'No. de Campos: ' + AllTrim(Str(Len(aHeader)))  
   aObjRef(aObjects[3])   
   IncProc()
   /* Get the Alias for the File*/ 
   cAlias := fieldAlias(aFRate[1,1])
   oLog:WriteLog('Tabla detectada : "'+cAlias+'"')    
   
   /*Report Invalid Fields*/
   If Len(aFRate) > 1       
      msgInfo('Se detecto un error al procesar, Revise el Log','Error') 
      oLog:WriteLog('Se han detectado '+AllTrim(Str(Len(aFRate)-1))+' campos Invalidos:')
      For iIndex := 2 to Len(aFRate)
          oLog:WriteLog(aFRate[iIndex,1])           
      Next iIndex 
      fCsv:Close()
      oLog:Close()
      Return 
   EndIf          
   /*Read Preview*/                       
   For iIndex := 1 to MIN(MAXPREVIEW,fCsv:RecCount()-fCsv:RecNo())
   	   fCsv:Skip(1)
       cLine := fCsv:ReadLn()
       aRow := oCsv:ParseLine(cLine)  
       if Len(aRow)==Len(aHEader)
	       aAdd(aTable,aRow)
	   EndIf
       IncProc()
   Next iIndex 

   /*Verify each line have same number of fields*/
   for iIndex := 1 To MIN(MAXPREVIEW,fCsv:RecCount()-fCsv:RecNo())//FIXME: It should verify ALL Rows
       if Len(aTable[iIndex]) <> Len(aHeader)
          MsgInfo('Error en el numero de campos, Vea el Log','Error')
          oLog:WriteLog('Error en el número de Campos') 
          oLog:WriteLog('Campos encabezado: '+Str(Len(aHeader))+', Campos Renglon: '+ Str(Len(aTable[iIndex])) +'No. de Renglon: '+ Str(iIndex + 1))
          fCsv:Close()
          oLog:Close()
          Return 
       Endif       
   Next iIndex                          
   
   IncProc()
   
   For iIndex := 1 TO Len(aHeader)           
	   ADD COLUMN TO oTable HEADER aHeader[iIndex] OEM ALIGN LEFT SIZE 50 PIXELS
	   cData := '{|| aTable[oTable:nAt,'+AllTrim(Str(iIndex))+'] }'
	   oTable:aColumns[iIndex]:bData := &cData
   Next iIndex      
   
   IncProc()
   
   oTable:SetArray(aTable)
   oTable:Refresh()

   oLog:WriteLog("**********Terminando Log de Preview")                     	 
   oLog:Close()
   fCsv:Close()
   
Return                

Static Function TblMgr(cFile,cLog)
   Local fCsv
   Local iIndex
   Local cLine := '',cSep :='', cObr := '', cTIndex := ''
   Local aFRate := {}, aRow := {}, aHeader := {}
   Local aNEFis := {}, aFiObr := {}, aFiVld := {}, aSizes := {}, aTypes := {}
   Local aTmp := {}
   Local cIndex
   Local lCheckDup := .T.,lErr := .F.

   Private oCsv         
   
   lAutoSave := .F.
   
   
   If !File(cFile)
       msgInfo('Nombre de Archivo Invalido: ' + cFile,'Error') 
       Return
   EndIf      
     
   cSep := GetUSep()            
  
   fCsv := TTxtFile():New(cFile,FO_READ)  
   oCsv := TCsvParser():New(cSep)
   oLog := TLog():New(cLog)
   
   ProcRegua(fCsv:RecCount())

   oLog:WriteLog("***********Iniciando Log de Migracion")                     
   /* Read Header */  
   aHeader := DetectHeader(@fCsv)
   If aHeader == Nil
	  msgInfo('Error al procesar.'+CRLF+'Revise el Log')
	  oLog:WriteLog("Error Fatal: No se ha detectado un encabezado Valido")
      fCsv:Close()
      oLog:Close()
      Return
   EndIf                  
   
   /* Capitalize Headers*/   
   aHeader := CapArray(aHeader)                                      

   aFRate := validSameAlias(aHeader)    
   IncProc()
   /* Get the Alias for the File*/ 
   cAlias := fieldAlias(aFRate[1,1])
   oLog:WriteLog('Tabla detectada : ('+cAlias+')')    
   
   /*Report Invalid Fields*/
   If Len(aFRate) > 1       
      MsgInfo('Se ha detectado un error, Revise el Log')
      oLog:WriteLog('Se han detectado Campos Invalidos:')
      For iIndex := 2 to Len(aFRate)
          oLog:WriteLog(aFRate[iIndex,1])           
      Next iIndex 
      fCsv:Close()
      oLog:Close()
      Return 
   EndIf
   
   /*Table exists in DB validation*/          
   If !existSX2(cAlias)
      msgInfo('Error al procesar:'+CRLF+'Revise el Log')
      oLog:WriteLog("Error Fatal:")
      oLog:WriteLog("La Tabla "+cAlias+", No existe en la Base de Datos")
      oLog:Close()
      fCsv:Close()
      Return 
   EndIf
//gsa   
   if cAlias=="SRC"
      MsgStop("Esta tabla no debe ser migrada por esta rutina!!")
      oLog:Close()
      fCsv:Close()
      Return
   endif     
///gsa   
   /*Fields in Table Validation*/
   dbSelectArea(cSX3)
   dbSetOrder(2)
   For iIndex = 1 To Len(aHeader)  
     dbGoTop()
     If dbSeek(aHeader[iIndex]) == .F.
        aAdd(aNEFis,aHeader[iIndex])
     Else    
        If Len(AllTrim(X3_CAMPO)) <> Len(AllTrim(aHeader[iIndex]))
            aAdd(aNEFis,aHeader[iIndex])        
        EndIf
     EndIf                          
   Next iIndex     
   
   If Len(aNEFis) > 0
      msgInfo('Error al procesar:'+CRLF+'Revise el Log')
      oLog:WriteLog("Error Fatal:")      
      oLog:WriteLog("Los siguientes campos no existen en la tabla "+cAlias+" :")
      For iIndex = 1 To Len(aNEFis)         
          oLog:WriteLog(aNEFis[iIndex])
      Next iIndex      
      oLog:Close()
      fCsv:Close()                
      Return
   EndIf                      
                 
   /*Validate Required Fields*/
   dbSelectArea(cSX3)
   dbSetOrder(1)
   dbGotop()
   If dbSeek(cAlias)
     While !EOF() .And. (X3_ARQUIVO = cAlias)
	    IF X3Uso(SX3->X3_USADO) .AND. X3Obrigat(SX3->X3_CAMPO) .AND. SX3->X3_CONTEXT <> "V"     //GSA
		   IF !InArray(aHeader,AllTrim(X3_CAMPO)) 
				   aAdd(aFiObr,AllTrim(X3_CAMPO))
	       EndIF
		EndIF
		DbSkip()
	 EndDo
   Endif    
   
   If Len(aFiObr) > 0                 
     msgInfo('Error al procesar:'+CRLF+'Revise el Log')
     oLog:WriteLog("Error Fatal")
     oLog:WriteLog("Faltan los Siguientes Campos Obligatorios: ")
     For iIndex = 1 To Len(aFiObr)         
         oLog:WriteLog(aFiObr[iIndex])
     Next iIndex                      
     oLog:Close() 
     fCsv:Close()
     Return
   EndIf      
   
   
   /*Load Fields Properties*/
   dbSelectArea(cSX3)
   dbSetOrder(2)
   For iIndex = 1 To Len(aHeader)  
     dbGoTop()
     dbSeek(aHeader[iIndex])
     cObr := Iif(X3Obrigat(X3_CAMPO),'.T.','.F.')    
     aTmp := {AllTrim(X3_CAMPO),;
              AllTrim(X3_TIPO),;
              AllTrim(Str(X3_TAMANHO)),;
              AllTrim(Str(X3_DECIMAL)),;
              cObr}
     aAdd(aFiVld,aTmp)                       
   Next iIndex

   dbSelectArea(cAlias)          

   For iIndex := 1 to Len(aFiVld)
      aAdd(aSizes,Val(aFiVld[iIndex,3]))
      aAdd(aTypes,aFiVld[iIndex,2])
   Next iIndex 

   cIndex := getUniq(cAlias)
   lCheckDup := AllTrim(cIndex) <> ""

   oLog:WriteLog('Indice utilizado en la migración: '+ cIndex )

	aRotAuto := {}	
	aRotAuto := makeHead(cAlias)   
	
	If !( Len(aRotAuto) > 0 )
		oLog:WriteLog('Error: Encabezado Vacio '+ cIndex )
	    msgInfo('Error al procesar:'+CRLF+'Revise el Log') //gsa
		Return 
	EndIf
	
	If Type("lMSErroAuto") == "U"
		Private lMSErroAuto := .F.
	EndIf
	If Type("lMsHelpAuto") == "U"
		Private lMsHelpAuto := .T.
	EndIf                  
	aPair := {}
	aAdd(aPair,aHeader)

	Private INCLUI := .T.
   
   /*Start Migration Loop */
   nTotreg:=0;nRegTra:=0;nRegError:=0
   For iIndex := fCsv:RecNo() to fCsv:RecCount()
   	   fCsv:Skip(1)
       cLine := fCsv:ReadLn()
       aRow := oCsv:ParseLine(cLine)  
       if empty(alltrim(cLine)) //gsa
          loop //gsa
       endif   //gsa
       if Len(aRow) = Len(aHeader)
	       cTIndex := CreateIndex(cIndex,aHeader,aSizes,aTypes,aRow)          
       EndIf
       If lCheckDup .AND. RegExists(cAlias,cTIndex,1)  
          oLog:WriteLog('Error, Registro duplicado, Linea : '+Alltrim(Str(iIndex))) 
          oLog:WriteLog('Indice Generado: ('+ cTIndex + ')')
          oLog:WriteLog('Registro Linea :('+Alltrim(Str(iIndex))+ ') No migrado')
          lErr:= .t. //gsa
       Else
         If Len(aRow) <> Len(aHeader)
            oLog:WriteLog('Error en Numero de Campos Linea: '+Alltrim(Str(iIndex))) 
            oLog:WriteLog('Registro Linea ('+Alltrim(Str(iIndex))+ '): No migrado')
	        lErr:= .t. //gsa            
         Else       
         	If lAutoSave
				Alert("Autosave: DO NOTHING")
	            lErr:= .t. //gsa
	       	Else
	       		aSize(aPair,1)     
	       		aAdd(aPair,aRow)
	       		DefCont(@aRotAuto)
				HeaderFill(@aRotAuto,aPair)	       			
				if nVal == 1 //con validaciones
					If !InsertaRegistro(cAlias,aRotAuto,aHeader,iIndex)
						lErr := .T.
						nRegTra++
					else
					   nRegError++
					EndIf
				Else
					AddReg(cAlias,aRotAuto,aHeader)             
				EndIf	           
	        EndIf
         EndIf
       Endif  
       IncProc()                  
          nTotreg++
   Next iIndex                        
   If lErr == .T.
	   msgInfo('Error al procesar:'+CRLF+'Revise el Log')   
	Else	
	   msgInfo("La migracion a Finalizado con Exito"+CRLF+"Pulse para Terminar")                                                    
	EndIf
   oLog:WriteLog("Migracion Finalizada.")
   oLog:WriteLog("Terminando!!!")
   oLog:WriteLog("**********Terminando Log de Migracion")                     	 
   oLog:Close()
   fCsv:Close()                       

   //log de seguridad

	oLogSeg:WriteLog("Usuario,Fecha,Hora,Tabla,Archivo,Log,Validacion,Formato_Fecha,Separador,Registros_Transferidos,Registros_con_error,Total_registros")    
	oLogSeg:WriteLog(cUsername+","+dtoc(ddatabase)+","+time()+","+cAlias+","+cPath+","+cLog+","+aOpt[nVal]+","+aOptDt[nTpDt]+","+oRbxSep:aItems[nRbx]+","+str(nRegTra)+","+str(nRegError)+","+str(nTotreg))    	
    oLogSeg:Close()   
      
    oBtnFin:Show()   
Return                
         



Static Function RadChange()
    If nRbx = 3
       oGetSep:Enable()
    Else
       oGetSep:Disable()
    EndIf
Return 
                    
              
Static Function GetUSep()
    If nRbx = 1
       Return ','
    EndIf
    If nRbx = 2
       Return ';'
    EndIf
Return cOtSep
            

/*BEGINDOC
Check if the alias Exist in the Data dictionary
ENDDOC*/
Static Function existSX2(cAlias)
	Local aArea
	Local lExist := .F.
	
	aArea := GetArea()
	dbSelectArea(cSX2)
 	dbSetOrder(1)              
  	lExist := dbSeek(cAlias)
  	RestArea(aArea)  	
  	
Return lExist
                    


/*BEGINDOC
Cambia el estado de los objectos que en envia, Habilita o desabilita segun su estado actual
ENDDOC*/
Static Function toggleEn(aObj)
    Local iIndex
    For iIndex := 1 To Len(aObj)
  	  If &(aObj[iIndex]):lActive
	     &(aObj[iIndex]):Disable()
	  Else                       
	     &(aObj[iIndex]):Enable()
	  EndIf 
    Next iIndex                
Return

Static Function toggleSh(aObj)
    Local iIndex
    For iIndex := 1 To Len(aObj)
  	  If &(aObj[iIndex]):lVisible
	     &(aObj[iIndex]):Hide()
	  Else           
	     &(aObj[iIndex]):Show()
	  EndIf
    Next iIndex
Return

Static Function aObjRef(aObj)
    Local iIndex
    For iIndex := 1 To Len(aObj)
	     &(aObj[iIndex]):Refresh()
    Next iIndex
Return

Static Function validSep(cBuff)

  If Len(cBuff) = 1
     Return .T.
  EndIf
         
Return .F.       



/*BEGINDOC
Check if all field names have the Microsiga Protheus format
XX_XXXXX OR XXX_XXXX
ENDDOC*/

Static Function validMp8Header(aHeader)
 
   local aFiErr := {}
   local iIndex  
  
   
   For iIndex := 1 to Len(aHeader)
     If At('_',aHeader[iIndex]) < 3 .OR. At('_',aHeader[iIndex]) > 4
        aAdd(aFiErr,aHeader[iIndex])
     EndIf
   Next iIndex
    
   If Len(aFiErr) > 0
       oLog:WriteLog('Los siguientes campos son invalidos:')
       For iIndex := 1 to Len(aFiErr)
           oLog:WriteLog(aFiErr[iIndex])           
       Next iIndex
       Return .F.
    EndIf
    
Return .T.                                                  

/*BEGINDOC
Detect the header Line
ENDDOC*/
Static Function DetectHeader(oFile)
    Local cLine := ""	
    Local aArray := {}
	cLine := oFile:ReadLn()
	aArray := oCsv:ParseLine(cLine)
	While .NOT. IsHeader(aArray) .AND. oFile:Skip(1)
	 	cLine := oFile:ReadLn()
		aArray := oCsv:ParseLine(cLine)
	End            
	If oFile:lEof()
		Return Nil
	EndIf
Return aArray                


/*BEGINDOC
Check if all the elements of the array are in the header format
ENDDOC*/
Static function IsHeader(aArray)
	Local iIndex
	Local cElem := ""
	For iIndex := 1 to Len(aArray)
		cElem := AllTrim(aArray[iIndex])
	 	If At('_',cElem) < 3 .OR. At('_',cElem) > 4
   			Return .F.
   		Else             
   			Return validMp8Header(aArray)
	    EndIf
   Next iIndex
Return .T. 



/*BEGINDOC
Capitalize all Chacacter elements of aunidimensional array
ENDDOC*/
Static Function CapArray(aArray)
	Local iIndex
	Local aReturn := Array(Len(aArray))
	for iIndex := 1 To Len(aArray)
		If ValType(aArray[iIndex]) == "C"
			aReturn[iIndex] := Upper(aArray[iIndex]) 
		Else 
			aReturn[iIndex] := aArray[iIndex]
		EndIf
	Next iIndex	
Return aReturn

/*BEGINDOC
Makes a Different Fields Count to detect Invalid Fields and Alias for the File
Check if al header names belogns to the same alias
ENDDOC*/
Static Function validSameAlias(aHeader)

   local aFiCount := {}
   local iIndex,iJIndex  
   local iFound := 0
   
   For iIndex := 1 to Len(aHeader)
      For iJIndex := 1 to Len(aFiCount)
          If SubStr(aHeader[iIndex],1,3) = SubStr(aFiCount[iJindex,1],1,3) 
             iFound := 1
             aFiCount[iJindex,2]++
             Exit   
          EndIf
      Next iJIndex                
      If iFound = 0
          aAdd(aFiCount,{aHeader[iIndex],1})
      EndIf                                     
      iFound := 0
   Next iIndex   
Return aFiCount                         


/*BEGINDOC
Given a Field Name, return the alias name
ENDDOC*/
Static Function fieldAlias(cField)
    cField := Upper(cField)
    If At('_',cField) = 3
       Return ('S'+ SubStr(cField,1,2))
    EndIf
Return SubStr(cField,1,3)


Static Function InArray(aArray,cStr)
    Local nIndex
//GSA    nIndex := aScan(aArray,{|cEl| cEl == cStr})
    nIndex := aScan(aArray,{|cEl| ALLTRIM(cEl) == ALLTRIM(cStr)})    
    If nIndex = 0
       Return .F.
    EndIf   
//GSA    If Len(aArray[nIndex]) = Len(cStr)
    If Len(ALLTRIM(aArray[nIndex])) = Len(ALLTRIM(cStr))    
        Return .T.        
    EndIF                    
Return .F.            

Static Function CreateIndex(cIndex,aFields,aSizes,aTypes,aRow)          

   local oCsv
   local aIndFi := {}
   local cIndStr := '', cCurFi := ''
   local iIndex, nCurLen, nFiLen, iTmp
   local aLF := {}

   oCsv := TCsvParser():New('+')

   aIndFi := oCsv:ParseLine(AllTrim(cIndex))
   
   If ! InArray(aFields,aIndFi[1])
       cIndStr:=&('xFilial(cAlias)')
   Else
//GSA       aAdd(aLF,aScan(aFields,aIndFi[1]))
       aAdd(aLF,aScan(aFields,ALLTRIM(aIndFi[1])))       
   EndIF

   For iIndex := 2 To Len(aIndFi)
       iTmp := aScan(aFields,ALLTRIM(aIndFi[iIndex]))
//       iTmp := aScan(aFields,aIndFi[iIndex])       
       If iTmp = 0
          If SubStr(aIndFi[iIndex],1,5) = 'DTOS('
             aIndFi[iIndex] := SubStr(aIndFi[iIndex],6,Len(aIndFi[iIndex])-6)
//GSA             iTmp := aScan(aFields,aIndFi[iIndex])
             iTmp := aScan(aFields,ALLTRIM(aIndFi[iIndex]))             
             aAdd(ALF,iTmp)
          EndIf
       Else
         aAdd(aLF,iTmp)
       EndIf
   Next iIndex

   For iIndex := 1 To Len(aLF)     
       If aTypes[aLF[iIndex]] = 'D'
          cCurFi := DTOS(CTOD(aRow[aLF[iIndex]]))
       Else    
         cCurFi := aRow[aLF[iIndex]]
         nCurLen := aSizes[aLF[iIndex]]
         nFiLen := Len(cCurFi)
         If nFiLen >= nCurLen
            cCurFi := SubStr(cCurFi,1,nCurLen)
         Else                                  
            cCurFi := cCurFi + Space(nCurLen-nFiLen)
         EndIf                       
       EndIf
       cIndStr := cIndStr + cCurFi
   Next iIndex          

Return cIndStr   


/*BEGINDOC
Obtiene el numero de indice indicado en el parametro nIndex para el alias cAlias
ENDDOC*/

/* Static Function getIndex(cAlias,nIndex)          

   local cIndex := '' 
     
   dbSelectArea(cSIX)
   dbSetOrder(nIndex)     
   dbSeek(cAlias+AllTrim(Str(nIndex)))
   cIndex := SIX->CHAVE 

Return cIndex */
      
/*Return the UNIQ for the especified alias*/
Static Function getUniq(cAlias)
	Local aArea
	Local cIndex
	aArea := GetArea()        
	dbSelectArea(cSX2)
	dbSetOrder(1)
	dbSeek(cAlias)
	cIndex := SX2->X2_UNICO
	RestArea(aArea)
Return cIndex

/*BEGINDOC
Chek for unique registers
ENDDOC*/

Static Function RegExists(cAlias,cIndex,nIndex)
	dbSelectArea(cAlias)
	dbSetOrder(nIndex)
	dbGoTop()
	If dbSeek(cIndex)
	   Return .T.
    EndIF	  
Return .F.
                  

/*
Static Function ValidReg(aRotAuto)
Local nCnt0,nCnt1, nCnt2, bBlock, nOrderSX3
Local AutoReadVar, lObrigat ,cConteudo,uVar,cErro
Local lInit := .F., lValid := .T.
Local cAlias

lMsHelpAuto := .T.

If  aRotAuto # NIL
	nOrderSX3 := SX3->(IndexOrd())
	SX3->(DbSetOrder(2))                                      
	For nCnt1 := 1 To Len( aRotAuto )		
		AutoReadVar  := "M->" + Upper( aRotAuto[nCnt1,CAMPO] )
		&AutoReadVar := aRotAuto[nCnt1,CONTENT]		
	Next
	For nCnt1 := 1 To Len( aRotAuto )
		AutoReadVar := "M->" + Upper(aRotAuto[nCnt1, CAMPO])
		SX3->(DbSetOrder(2))
		SX3->(DbSeek(Upper(AllTrim(Subs(AutoReadVar,4)))))		
		&AutoReadVar := aRotAuto[nCnt1,CONTENT]
 		If &AutoReadVar== NIL .OR. Empty(&AutoReadVar) .OR. Empty(aRotAuto[ nCnt1,CONTENT])
			lInit := .F.
			If ExistIni(Subs(AutoReadVar,4))
				lInit := .t.                            

				&AutoReadVar := InitPad(SX3->X3_RELACAO)
				If ValType(&AutoReadVar) = "C"
					&AutoReadVar := PADR(&AutoReadVar,SX3->X3_TAMANHO)
				EndIf
				If &AutoReadVar == NIL .or. Empty(aRotAuto[ nCnt1,CONTENT])
					lInit := .f.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Manter a variavel de memoria caso uma validacao as atualize e nao tenha   ³
			//³sido mensionada no arquivo texto, somente no caso de inclusao             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aRotAuto[ nCnt1,CONTENT]) .and. !Empty(&AutoReadVar)
				lInit := .T.
			EndIf
			If !lInit
				&AutoReadVar := aRotAuto[ nCnt1,CONTENT ]
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso alguma validacao atualize a variavel manter o que foi passado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( &AutoReadVar != aRotAuto[ nCnt1,CONTENT] .and. !Empty(aRotAuto[ nCnt1,CONTENT]) )
			&AutoReadVar := aRotAuto[ nCnt1,CONTENT]
		EndIf
		__READVAR := Upper(AllTrim(AutoReadVar))
		If !( aRotAuto[ nCnt1,VALIDA] == NIL )			
			lObrigat := x3uso(SX3->X3_USADO) .and. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .or. VerByte(SX3->x3_reserv,7))
			If (lObrigat .or. ! Empty(&AutoReadVar))
			    if lObrigat .and. Empty(&AutoReadVar)  //gsa
				    oLog:WriteLog("Campo vacio y es obligatorio '"+ aRotAuto[nCnt1,CAMPO] ) //gsa
					lValid := .F.  //gsa
			    else    //gsa
					bBlock := &( "{ || " + AllTrim( aRotAuto[nCnt1,VALIDA] ) + " }" )
					If SX3->X3_VISUAL # "V"
						If !Eval( bBlock )
							//AutoGRLog("Tabela "+cAlias+" "+Dtoc(MsDate())+' '+Time() )
							ConOut("Error Tabela Campo invalido '"+ aRotAuto[nCnt1,CAMPO] + ":"+AnyToStr(aRotAuto[nCnt1,CONTENT])+"'")
	 		  	  	        oLog:WriteLog("Valor Invalido para campo '"+ aRotAuto[nCnt1,CAMPO] + ":"+AnyToStr(aRotAuto[nCnt1,CONTENT])+"'")
							lValid := .F.
						EndIf 
						if "FREEFORUSE"$UPPER(aRotAuto[nCnt1,VALIDA])
							freeusedcode()
						EndIF
						If SX3->(X3_TRIGGER) == "S"
							RunTrigger(1)
						EndIf
					EndIf
				endif   //gsa
			EndIf
		EndIf
	Next
	SX3->(DbSetOrder(nOrderSX3))
	EndIf
	
lMsHelpAuto := .F.

Return lValid
  */

/*
	nPosTemp := aScan(aVetor1,{ |x| AllTrim(Upper(x[1])) == AllTrim(SX3->X3_CAMPO)})
	If Valtype(uConteudo) == "C"
		uConteudo := PadR(uConteudo,Sx3->X3_TAMANHO)
	EndIf
*/
/*
Prepares the Array with the Alias Fields 
*/
Static Function makeHead(cAlias)

Local nOrderSX3
Local uContenido := NIL
Local cValid := ""
Local cOblig := .F.
Local aRet := {}

nOrderSX3:= SX3->(IndexOrd())
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))


While ( !SX3->(eof()) .AND. SX3->X3_ARQUIVO == cAlias )
	If (SX3->X3_CONTEXT == "V" .OR. !X3USO(SX3->X3_USADO)) .and. !("_FILIAL" $ SX3->X3_CAMPO)
		SX3->(DbSkip())
		Loop
	EndIf
	cValid := Upper(AllTrim( SX3->X3_VALID ))
	If ( Empty(cValid) )
		cValid := ".T."
	EndIf          
    cOblig := IIf(X3Obrigat(SX3->X3_CAMPO), .T., .F.)    
    
	uContenido := EmptyVal(SX3->X3_TIPO,SX3->X3_TAMANHO)
            
	aAdd(aRet,{AllTrim(SX3->X3_CAMPO),; // CAMPO
				AllTrim(SX3->X3_TIPO),; // TIPO
				SX3->X3_TAMANHO,;       // TAMANO
				SX3->X3_DECIMAL,;       // DECIMAL
				cOblig,;                // OBRIGAT
				cValid,;                // VALIDA
				uContenido})			// CONTENT

	
	SX3->(DbSkip())
End
SX3->(DbSetOrder(nOrderSX3))
Return aRet                             

Static function EmptyVal(cType,nSize)
	Local uEmpty := Nil             
	If nSize == Nil
		nSize := 1
	EndIf
	
	DO CASE
    CASE cType == "C"
   		uEmpty := SPACE(nSize)
    CASE cType == "D"
     	uEmpty := CTOD("")
    CASE cType == "N"
     	uEmpty := 0
    OTHERWISE
        uEmpty := ""
    END CASE 
Return uEmpty


/*
DESCRIPTION
Clean the array header content values
PARAMETERS
@aHeader : The header structure passes by reference
*/
Static Function DefCont(aHeader)
	aEval(aHeader,{|X,nIndex| aHeader[nIndex][CONTENT] := EmptyVal(aHeader[nIndex][TIPO],aHeader[nIndex][TAMANO]) })
Return Nil   

/*                       
DESCRIPTION
fill aHeader content field with the content specified by the values array
PARAMETERS
@aHeader: the header structure to fill with the values passes bye reference
@aValues: the values structure, aValues[1] field name array, aValues[2] value Array
*/                                                                       
Static Function HeaderFill(aHeader,aValues)
	Local nIndex,cTipo
	Local nPos := 0
	Local uContenido 
	If Len(aValues) <> 2
		ConOut("Invalid aValues Array Size")
		Return .F.                           
	EndIf
	If Len(aValues[1]) <> Len(aValues[2])
		ConOut("Inconsisten aValues<->aHeader Sizes")
		Return .F.
	EndIf                                       
	For nIndex := 1 To Len(aValues[1])
		nPos := aScan(aHeader, {|X| X[CAMPO] == aValues[1][nIndex]})		
		If nPos > 0   
			cTipo := aHeader[nPos][TIPO]
			Do Case 
				Case cTipo == "C"
					uContenido := PADR(AllTrim(aValues[2][nIndex]),aHeader[nPos][TAMANO])
				Case cTipo == "D"
					uContenido := StrToD(aValues[2][nIndex],nTpDt)
				Case cTipo == "N"
					uContenido := VAL(aValues[2][nIndex])
				Case cTipo == "L"
					uContenido := if(UPPER(aValues[2][nIndex])$"/.T./TRUE/1/",.T.,.F.)
				OtherWise
					uContenido := aValues[2][nIndex]
			End Case		
			aHeader[nPos][CONTENT] := uContenido
		EndIf		
	Next iIndex
Return .T.                 
/*
Static function AnyToStr(uValue)
	Local cRet := ""
	Local cType := "U"
	cType := ValType(uValue)
	Do Case
		Case cType == "C"
			cRet := uValue
		Case cType == "N"
			cRet := Str(uValue)
		Case cType == "L"
			cRet := if(uValue==.T.,".T.",".F.")
		Case cType == "M"
			cRet := "Memo"
		Case cType == "D"
			cRet := DTOC(uValue)
		Otherwise
			cRet := "UNKNOWN"
	End Case
		
Return  cRet  
  */
/*
Retorna una fecha desde una cadena de texto a un formato especificado
cStr: cadena de texto a converti a fecha
nType: typo de fecha que tiene la cadena a convertir
		1 : DD/MM/AA
		2 : DD/MM/AAAA
		3 : DDMMAA
		4 : DDMMAAAA
		5 : AAMMDD
		6 : AAAAMMDD
*/
Static Function StrToD(cStr, nType)
	Local dRet := CTOD("//")
	
	cStr := AllTrim(cStr)
	Do Case 
		Case nType == 1
			dRet := IF(Len(cStr) <> 8, dRet, cTOD(cStr))
		Case nType == 2       
			dRet := IF(Len(cStr) <> 10, dRet, cTOD(cStr))
		Case nType == 3	
			dRet := IF(Len(cStr) <> 6, dRet, CTOD(SubStr(cStr,1,2)+"/"+SubStr(cStr,3,2)+"/"+SubStr(cStr,5,2)))
		Case nType == 4	  
			dRet := IF(Len(cStr) <> 8, dRet, CTOD(SubStr(cStr,1,2)+"/"+SubStr(cStr,3,2)+"/"+SubStr(cStr,5,4)))
		Case nType == 5
			dRet := IF(Len(cStr) <> 6, dRet, CTOD(SubStr(cStr,5,2)+"/"+SubStr(cStr,3,2)+"/"+SubStr(cStr,1,2)))
		Case nType == 6       
			dRet := IF(Len(cStr) <> 8, dRet, CTOD(SubStr(cStr,7,2)+"/"+SubStr(cStr,5,2)+"/"+SubStr(cStr,1,4)))
	End Case
Return dRet
                                      
Static Function AddReg(cAlias,aArray,aHeader)
	Local nCnt,nPos
	Local aArea := GetArea()
	DbSelectArea(cAlias)
	
	RecLock(cAlias,.T.)
	For nCnt := 1 To Len(aHeader)             
		nPos := aScan(aArray,{|X| X[CAMPO] == aHeader[nCnt]})
		If nPos > 0
			&(aArray[nPos][CAMPO]) := aArray[nPos][CONTENT]
		EndIF
	Next nCnt               	    
    MsUnlock()    	           
	DbSkip()		
	RestArea(aArea)
Return

                                             
Static Function InsertaRegistro(cAlias,aDatos,aHeader,iIndex)
Local aArea    := GetArea()
Local aRotina  := {}
Local aAuto := {}
Local aDados   := {}                  
Local aButtons := {}
Local aErro    := {}
Local lRetorno := .T.
Local cNomFil:=''
Local nPos:=0

Local cErro    := ""
Local nX       := 0
Local nOpcAuto := 3 //3. Incluir 4.Alterar 5.Eliminar

PRIVATE lMsErroAuto := .F.
PRIVATE lAutoErrNoFile := .T.
	
dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek( cAlias )
	cTabela := X2Nome()
EndIf

dbSelectArea(cAlias)                                        
dbSetOrder(1)                     
dbGotop()
//cNomFil:=substr(aDatos[1,1],1,AT("_",aDatos[1,1]))
//aadd(aDados,{cNomFil+"FILIAL",xfilial(cAlias),})	//filial

for nx:=1 to len(aDatos)                           
    IF (nPos:=aScan(aHeader,{|X| alltrim(X) == alltrim(aDatos[nx,1])}))>0

	   /*	if  aDatos[nx][TIPO] == "D"
			aDatos[nx,7] := StrToD(aDatos[nx,7],nTpDt)
		endif	*/
		aadd(aDados,{aDatos[nx,1],aDatos[nx,7],})		    
	endif	
    
next    


aAuto := WsAutoOpc(aDados)		   

AxCadastro(cAlias,;
		cTabela,;
		/*cDel*/,;
		/*cOk*/,;
		aRotina,;
		/*bPre*/,;
		/*bVld*/,;
		/*bTTS*/,;
		/*bNoTTS*/,;
		aAuto,;
		nOpcAuto,;
		aButtons,;
		)

	//En caso de que ocurra un error lo muestra
	If lMsErroAuto
		aErro := GetAutoGRLog()
		For nX := 1 To Len(aErro)
			cErro += aErro[nX] + Chr(13)+Chr(10)
		Next nX	
		oLog:WriteLog('Registro Linea :('+Alltrim(Str(iIndex))+ ') No migrado')
		oLog:WriteLog(cErro)
		lRetorno := .F.                 
	EndIf		
                   

    dbCloseArea()
	RestArea(aArea)
Return(lRetorno)
//identifica la extensión del archivo y dependiendo de esta activa el tipo de archivos

static function SelArc(cpath)
Local nMasc:=1
Local nPosPun:=At(".",cPath)

if nPosPun<>0
    cExt:=substr(cPath,npospun+1,3)
    if UPPER(cExt)== "TXT"                         
	    nMasc := 1
	endif    
    
    if UPPER(cExt)== "CSV"                         
	    nMasc := 2
	endif    
endif

return nMasc