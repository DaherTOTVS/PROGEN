#include "PROTHEUS.CH"
#include "FOLDER.CH"                       
#include "Tbiconn.ch"                     
#INCLUDE "tcbrowse.ch"
#include "FileIO.ch"                                     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GENLAY   ºAutor  ³                    º Data ³  16/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Generacion de Layout para migracion de archivos            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS   ³  Motivo da Alteracao                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³        ³        ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GenLayCsv()    

Local oFolder, oGet
Local aTitles 		:= {"TABLA"} //"Cliente"###"Titulo"
Local aPages  		:= Aclone(aTitles)
Local lConfirm   := .F.
Local aButtons   := {} 
Local aTamFoldeR := {}   
Private cTable := ""       

Private aCpos	:= {}

Private oDlg                                  
Private cAlias  := ""
Private aCols   := {}                              

Private aHeader := {}           

//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "GPE"
//MsgRun( "Aguarde. Preparando Ambiente..." , "Iniciando" , { || RpcSetEnv( "99" ,"01","Admin","","GPE" ) } )


Aadd(aHeader,{""      ,"CHECKBOL","@BMP"    , 07, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{""      ,"CHECK"   ,"@BMP"    , 05, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{"Order" ,"ORDEM"   ,"@E 9,999", 04, 00, , ,"N", ,"V", , , , "A", , , })
Aadd(aHeader,{"Nombre","NOMCAMPO", ""       , 12, 00, , ,"C", ,"V", , , , "V", , , })
Aadd(aHeader,{"Campo" ,"CAMPO"   , ""       , 10, 00, , ,"C", ,"V", , , , "V", , , }) 


DEFINE MSDIALOG oDlg TITLE "Genera Layout CSV" FROM 0,0 TO 285,620 of oMainWnd PIXEL //"Configurador de ordem e campos para browse de Recibos"

                 
aTamFolder := {014,002,oDlg:nHeight-5,129}
oFolder    := TFolder():New(aTamFolder[1],aTamFolder[2],aTitles,aPages,oDlg,,,,.T.,.F.,aTamFolder[3],aTamFolder[4])	


nGetd := GD_UPDATE                                                                   
oGet  := MsNewGetDados():New(0, 0, oFolder:aDialogs[1]:nClientHeight/2, oFolder:aDialogs[1]:nClientWidth/2,nGetd,,,,,,9999,,,,oFolder:aDialogs[1],aHeader,aCols)       
oGet:oBrowse:bEditCol   := {|| GenLayOrd(oGet:oBrowse:nAt,@oGet,.T.) }
oGet:oBrowse:blDblClick := {|| If( oGet:oBrowse:nColPos == 3 , GenLayOrd(oGet:oBrowse:nAt,@oGet,.F.), GenLaybmp(oGet:oBrowse:nAt,@oGet) ) }

Aadd( aButtons, {"NOVACELULA",{ || cTable := GenLaylst(), Populate(@oGet,cTable)		},"Sel. Tabla","Tabla"} ) 
Aadd( aButtons, {"PARAMETROS",{ || GenLayleg()      	},"Leyenda"} ) 
Aadd( aButtons, {"CHECKED"   ,{ || GenLaySel(@oGet,1)	},"Seleccionar todos los campos","Sel.Todos"} ) 
Aadd( aButtons, {"UNCHECKED" ,{ || GenLaySel(@oGet,2)	},"Limpiar Seleccion","Limpiar"} ) 


ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg,{|| IF(GenLaySave(@oGet)==0,oDlg:End(),oDlg:End())} , {|| If(MsgYesNo("¿Desea Salir?"),oDlg:End(),) }, , aButtons  )) CENTERED 



Return .F.        


Static Function GenLayleg()

BrwLegenda("Leyenda", "Status",{{"DISABLE", "Obligatorio"} ,;
								{"ENABLE" , "Opcional"} ,;
								{""		  , " ------------------------ "} ,;
								{"LBTIK"  , "Seleccionado"} ,;
								{"LBNO"	  , "No Seleccionado"}  ; 
							} )

Return Nil                                   


Static Function GenLayLst()                                                      

Local aTables := {}
Local aHeader := {}
Local cSearch := Space(20)
Local cCol := Space(1)
Local cRet := ""
Local nFrom := 0        
Private oTblDlg
Private oTables,oGetT,oButton,oBtnOk,oBtnCn,oCombo,oBtnClr
Private nSType := 1 




LoadSX2(@aTables)    

aAdd(aHeader,"Tabla")
aAdd(aHeader,"Descripcion")

DEFINE MSDIALOG oTblDlg TITLE "Seleccionar Tabla" FROM 0,0 TO 340,420 of oDlg PIXEL //"Configurador de ordem e campos para browse de Recibos"

	@ 2,1  BROWSE oTables FIELDS SIZE 200,120 OF oTblDlg
	ADD COLUMN TO oTables HEADER aHeader[1] OEM ALIGN LEFT SIZE 50 PIXELS
	ADD COLUMN TO oTables HEADER aHeader[2] OEM ALIGN LEFT SIZE 50 PIXELS
	oTables:aColumns[1]:bData := {|| aTables[oTables:nAt,1] }
	oTables:aColumns[2]:bData := {|| aTables[oTables:nAt,2] }          
	oTables:SetArray(aTables)
	oTables:Refresh()
	
	@ 1,1	MSGET oGetT VAR cSearch SIZE 80,10 OF oTblDlg PICTURE "@!"
	
	@ 1,12  COMBOBOX oCombo VAR  cCol ITEMS aHeader SIZE 40,10  OF oTblDlg ON CHANGE ( nSType := oCombo:nAt) 

	
	@ 1,35	BUTTON oButton PROMPT 'Buscar' OF oTblDlg ;
			SIZE 32,10 ;
			ACTION (nFrom:=IF(oTables:nAt=1,0,oTables:nAt),browseSearch(@oTables,AllTrim(UPPER(cSearch)),nSType,nFrom))
			
	@ 1,44	BUTTON oBtnClr PROMPT 'Limpiar' OF oTblDlg ;
			SIZE 32,10 ;
			ACTION (cSearch := Space(20), oTables:nAt := 1, oTables:Refresh())			

	@ 15,35	BUTTON oBtnOk PROMPT 'Ok' OF oTblDlg ;
			SIZE 32,10 ;
			ACTION ( cRet := aTables[oTables:nAt,1], oTblDlg:End()  )			
			
	@ 15,44	BUTTON oBtnCn PROMPT 'Cancelar' OF oTblDlg ;
			SIZE 32,10 ;
			ACTION ( cRet := "", oTblDlg:End() )						
			
	
ACTIVATE MSDIALOG oTblDlg  CENTERED 	
Return cRet

Static Function browseSearch(oBrowse,uVal, nPos, nFrom)
	Local nAt :=0,nSFrom :=0  
	Local aTmp := Array(LEN(oBrowse:aArray)-nFrom)
	//Local aTmp := aClone(oBrowse:aArray)
	nSFrom := nFrom + 1
	aCopy(oBrowse:aArray,aTmp,nSFrom)
	nAt := Search(aTmp,uVal,nPos)
	nAt += nFrom
	posicione(@oBrowse,nAt)
Return     

Static Function posicione(oBrowse,nPos)
	If nPos == 0 .OR. nPos > oBrowse:nLen
		Alert('No existe')
	Else
		oBrowse:nAt := nPos
		oBrowse:Refresh()
	EndIf
Return 

Static Function Search(aArray,uVal,nPos)
	Local nAt
	If Len(aArray) == 0
		Return 0
	Elseif Len(aArray[1]) < nPos
		Return 0
	EndIf
	nAt := aScan(aArray, { | X |  uVal $ UPPER(X[nPos])  })
Return nAt  


Static Function LoadSX2(aArray)
	Local aTmp := {} 
	Local cSX2 := "SX2"
	aArray := {}
	dbSelectArea(cSX2)
	dbSetOrder(1)
	dbGotop()
	While !EOF()
		aTmp := {(cSX2)->X2_CHAVE,(cSX2)->X2_NOMESPA}
		aAdd(aArray,aTmp)
		dbSkip()
	EndDo
Return                                             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  ³Autor ³     ³Data³  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Populate(oGet,cAlias)

///////
// Var:
Local aCposTMP		:= {}

Local cNomeArray	:= ""
Local c_Alias		:= ""
Local cAliasAnt 	:= Alias()
Local nOrdem		:= 0
Local lEnable		:= .F.
Local cBMP      	:= ""
Local nA			:= 0
Local aFolders		:= {}
Local lexist 		:= .F.

DbSelectArea("SX2")
DbSetOrder(1)
DbGotop()
If cAlias <> "" .AND. DbSeek(cAlias)
	lexist := .T.
EndIf

If lexist .AND. MsgYesNo("¿Desea Actualizar lista de campos?") 
                         
	aCpos 	:= {}
	/////////
	// Pastas
	aAdd(aFolders, cAlias)
	aAdd(aFolders,"aCpos")


		
	c_Alias		:= aFolders[1]
	cNomeArray	:= aFolders[2]

	////////////////////////////////
	// Pega a Lista de Campos de SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(c_Alias,.F.)
	Do While !EOF() .And. X3_ARQUIVO == Alltrim(c_Alias)
		If ( x3uso(X3_USADO) ) .And. ( cNivel >= X3_NIVEL ) .AND. (X3_CONTEXT <> "V")
		
			nOrdem++
			
			lEnable := !X3Obrigat(X3_CAMPO)
			
			If lEnable      
				cBMPBOL	:= "ENABLE"
				cBMP	:= "LBTIK"
			Else
				cBMPBOL	:= "DISABLE"
				cBMP	:= "LBTIK"
			Endif
			
			AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		Endif
		DbSkip()
	Enddo

	 
	oGet:aCols := Aclone( aCpos )
	oGet:oBrowse:Refresh()
	oGet:ForceRefresh()
						
	
	//oDlg:Refresh()
	
	DbSelectArea(cAliasAnt)

Endif

RETURN Nil                                                                    



Static Function GenLaySel(oGet,nOpcBMP)

Local nFor 	:= 0
Local nA	:= 0


	nFor := Len(oGet:aCols)
	For nA := 1 to nFor
		If ( oGet:aCols[nA][1] = "ENABLE" )
			If     ( nOpcBMP = 1 )
				oGet:aCols[nA][2] := "LBTIK"
			ElseIf ( nOpcBMP = 2 )
				oGet:aCols[nA][2] := "LBNO"
			Endif
		Endif
	Next nA

Return Nil                                    


Static Function GenLayOrd(nLin,oGet,lVld)

///////
// Var:
Local nPosNovo 	:= 0
Local nValNovo 	:= 0
Local nValAnti 	:= 0
Local nValMaior := Len(oGet:aCols)
Local nFor		:= 0
Local nA		:= 0
Local nOrdem	:= 0


If lVld
	nValNovo := M->ORDEM	
	nValAnti := nLin
Else
	nValAnti := oGet:aCols[nLin][3] 
	oGet:EditCell()
	nValNovo := oGet:aCols[nLin][3]
Endif


If ( nValNovo <= nValMaior ) .And. ( nValNovo > 0 ) 

	If ( nValAnti <> nValNovo )
	
		//If lVld
			nPosNovo := nValNovo
		//Else
		//	nPosNovo := Ascan( oGet:aCols, {|aVal| aVal[3] == nValNovo .AND. nLin <> nValNovo} )
		//Endif
		
		If ( nLin < nPosNovo )
			nFor := nPosNovo
			nLin++
			For nA := nLin to nFor
				nOrdem := nA
				nOrdem--
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Else
			nFor := ( (nLin-nPosNovo) + nPosNovo ) - 1
			For nA := nPosNovo to nFor
				nOrdem := nA
				nOrdem++
				oGet:aCols[nA][3] := nOrdem
			Next nA
		Endif
		
		oGet:aCols := Asort( oGet:aCols,,, { |x,y| x[3] < y[3] } )
		
	Endif

Else
	oGet:aCols[nLin][3] := nValAnti
	If ( nValNovo <= 0 )
		Alert("Valor no puede ser menor o igual a 0")
	Else
		Alert("Valor no puede ser mayor que el numero maximo de campos") 
	Endif
Endif   

oGet:oBrowse:Refresh()
oGet:ForceRefresh()


Return Nil                  


Static Function GenLaybmp(nLin,oGet)

If ( oGet:aCols[nLin][1] = "ENABLE" )
	If     ( oGet:aCols[nLin][2] = "LBTIK" )
		oGet:aCols[nLin][2] := "LBNO"		
	ElseIf ( oGet:aCols[nLin][2] = "LBNO" )
		oGet:aCols[nLin][2] := "LBTIK"
	Endif
Endif


Return Nil                            
               
Static Function GenLaySave(oGet)
	Local aArray :=	{}         
	Local aCampos := {}
	Local i,j
	Local cAliasAnt := Alias()
	Local cFileName := ""  
	Local nCount := 0
	
	aCampos := aClone(oGet:aCols)           
	
	AEVAL(aCampos,{|aVal| IF(aVal[2] == "LBTIK",nCount+=1,)})

		                             
	aArray := Array(5,nCount)
	If cTable <> ""	      
		cFileName := cGetFile('Archivos CSV|*.csv','Guardar Como',1,,.T.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT,.F.)
		DbSelectArea("SX3")
		DbSetOrder(2)
		j := 1
		For i := 1 to Len(aCampos)               
			If aCampos[i][2] == "LBTIK"
				DbGotop()
				DbSeek(AllTrim(aCampos[i][5]))		 		                           
				aArray[1][j] := AllTrim(X3DESCRIC(X3_CAMPO))//Nombre
				aArray[2][j] := DescType(AllTrim(X3_TIPO))//Tipo  
				aArray[3][j] := AllTrim(STR(X3_TAMANHO))//Tamaño
				aArray[4][j] := If(X3Obrigat(X3_CAMPO),"OBLIGATORIO","OPCIONAL")//Obligatoriedad
				aArray[5][j] := AllTrim(X3_CAMPO)//CAMPO
				j += 1
			EndIf
		Next i
		//AAdd(aCpos,{cBMPBOL,cBMP,nOrdem,RetTitle(X3_CAMPO),X3_CAMPO,.F.})
		DbSelectArea(cAliasAnt)
		Return Array2Csv(cFileName,aArray)
	EndIf
Return 1

Static Function Array2Csv(cFileName,aArray)
	Local n,m       
	Local lGrava := .T.
	Local hFile := 0    
	Local cLine := ""
		
	If lGrava 
		
		hFile = FCreate( cFileName+".CSV", FC_NORMAL )
	
	    If ( hFile < 0)
	    	Alert("Error creando el archivo: "+ cFileName+".CSV")
    		Return -1
	    EndIf                
	
		For n := 1 to Len(aArray)        
			cLine := ''
			For  m := 1 to Len(aArray[1])
				cLine +='"'+AllTrim(aArray[n][m]) +'"'
				if m <> Len(aArray[1])
					cLine+=','	        
				EndIf
			Next m     
			cLine += CRLF
    		FWrite(hFile, cLine, Len(cLine))
		Next n	  
		FClose(hFile)
	    hFile := 0                   
	    MsgInfo("Archivo Creado: "+cFileName)
	EndIf
Return 0       

Static Function DescType(cType)
	Local cDesc := ""
	                          
	DO CASE
		CASE cType == "C"
			cDesc := "CARACTER"
		CASE cType == "D"
			cDesc := "FECHA"
		CASE cType == "L"
			cDesc := "LOGICO"
		CASE cType == "N"
			cDesc := "NUMERICO"
		OTHERWISE
			cDesc := "DESCONOCIDO"
   	END CASE

	
Return cDesc
