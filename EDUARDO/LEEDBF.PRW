#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"  

//+-----------------------------------------------------------------------------------+
//|-----------------------------------------------------------------------------------|
//|     Función | LEEDBF        Autor | Edwin Lina               Fecha | 2012/01/05   |
//|-----------------------------------------------------------------------------------|
//| Descripción | Carga de lay out para para producción(SB1,SH1,SG1,SG2,SGF)          |   
//|             | Validando las relacione con otras tablas y validando en             |
//|             | contenido de campos claves para SIGAPCP.                            |
//|             | Crear un índex en la SG1 que la llave sea G1_FILIAL+G1_COD          |
//|-----------------------------------------------------------------------------------|
//|         Uso | Fabrica de Brochas Perfec    Módulo | SIGAPCP    Tipo | User Función|
//+-----------------------------------------------------------------------------------+

user function LEEDBF()
Static oDlg
Local oButton1,oButton2,oButton3,oButton4,oButton5,oButton6
Local oGet1,oGet2,oGet3,oGet4,oGet5                                                    
Local oSay1,oSay2,oSay3,oSay4,oSay5
private cGet2 := ""
private cGet3 := ""
private cGet1 := ""
private cGet4 := ""
private cGet5 := "" 
PRIVATE _cFimLin	:= Chr(13)+Chr(10)
PRIVATE aLOGsb1:={}
  DEFINE MSDIALOG oDlg TITLE "Carga de lay out de producción" FROM 000,000  TO 450, 400 COLORS 0,16777215 PIXEL
    @ 023, 040 SAY   oSay1 PROMPT "SB1-PRODUCTOS" SIZE 0,080 OF oDlg PIXEL
    //@ 016, 066 MSGET oGet1    VAR cGet1 SIZE 079, 012 OF oDlg PIXEL
    @ 045, 040 SAY   oSay2 PROMPT "SH1-RECURSOS" SIZE 0,80 OF oDlg PIXEL
    //@ 044, 066 MSGET oGet2    VAR cGet2 SIZE 079, 012 OF oDlg PIXEL
    @ 074, 040 SAY   oSay3 PROMPT "SG1-ESTRUCTURAS" SIZE 00, 080 OF oDlg PIXEL
    //@ 072, 066 MSGET oGet3    VAR cGet3 SIZE 079, 012 OF oDlg PIXEL
    @ 107, 040 SAY   oSay4 PROMPT "SG2-OPERACIONES" SIZE 00, 080 OF oDlg PIXEL
    //@ 104, 066 MSGET oGet4    VAR cGet4 SIZE 079, 012 OF oDlg PIXEL
    @ 140, 040 SAY   oSay5 PROMPT "SGF-OPER. vs COMP." SIZE 00, 080 OF oDlg PIXEL
    //@ 137, 066 MSGET oGet5    VAR cGet5 SIZE 079, 012 OF oDlg PIXEL 
    //
    @ 015, 154 BUTTON oButton1 PROMPT "Importar" action Processa({|| importasb1() },"Procesando SB1-PRODUCTOS...") SIZE 029, 013 OF oDlg PIXEL
    @ 043, 154 BUTTON oButton2 PROMPT "Importar" action Processa({|| importasH1() },"Procesando SH1-RECURSOS...") SIZE 029, 013 OF oDlg PIXEL
    @ 074, 154 BUTTON oButton3 PROMPT "Importar" action Processa({|| importasG1() },"Procesando SG1-ESTRUCTURAS...") SIZE 029, 013 OF oDlg PIXEL
    @ 105, 154 BUTTON oButton4 PROMPT "Importar" action Processa({|| importasG2() },"Procesando SG2-Operaciones...") SIZE 029, 013 OF oDlg PIXEL 
    @ 138, 154 BUTTON oButton5 PROMPT "Importar" action Processa({|| importasGF() },"Procesando SGF-Oper vs Comp....") SIZE 029, 013 OF oDlg PIXEL
    @ 160, 085 BUTTON oButton6 PROMPT "Salir"    action oDlg:End()   SIZE 038, 013 OF oDlg PIXEL
  ACTIVATE MSDIALOG oDlg CENTERED
Return 
//-----------------------------------SH1-RECURSOS---------------------------------------
static Function importaSH1()											  
local archi 
LOCAL cFilCCT:=xFILIAL("CTT")  
LOCAL cFilCH7:=xFILIAL("SH7") 
local aRaylog1:={}
LOCAL iOk:=0
LOCAL iOk2:=0
local iFail:=0
local aTMP:={}
local aTMP2:={} 
LOCAL aDUPI:={}
LOCAL nCONT:=0
local aCampo:={} 
local aTMeSX3:={}
local i := 0
local y := 0
local nX := 0

archi:=Open_dbf("SH1-RECURSOS")
if !empty(archi)	
dbUseArea( .T.,"dbfcdxads",archi,"TSH1", .T., .F. ) 
TSH1->(dbGoTop()) 
if substr(TSH1->(FieldName(1)),1,3)=="H1_"
ProcRegua(RecCount()) 
  
for i:=1 to FCount()
AADD(aTMP,TSH1->(FieldName(i)))
next 

aTMeSX3:=geraSX3("SH1")
  
for i:=1 to len(aTMP)
	for y:=1 to len(aTMeSX3)
		if alltrim(aTMP[i])==alltrim(aTMeSX3[y])
		aadd(aCampo,aTMeSX3[y]) 
		endif
	next
next
TSH1->(dbGoTop())
WHILE !TSH1->(EOF())
	AADD(aTMP,TSH1->H1_CODIGO)
TSH1->(DBSKIP())
ENDDO 
TSH1->(dbgotop()) 
WHILE !TSH1->(EOF())   
	INCPROC()
	FOR I:=1 TO LEN(aTMP)
	  IF alltrim(aTMP[I])==alltrim(TSH1->H1_CODIGO)
	  nCONT++
	  ENDIF
	NEXT 
	IF nCONT>=2
	AADD(aRaylog1,"Registro duplicado: " +TSH1->H1_CODIGO)
	ENDIF
	nCONT:=0 
TSH1->(DBSKIP())
ENDDO

IF !EMPTY(aRaylog1)
	    MSGALERT("REGISTROS DUPICADOS ")  
ELSE
TSH1->(dbgotop())
WHILE !TSH1->(EOF()) 
		INCPROC()
		dbSelectArea("CTT")
		dbSetOrder(1)
		If dbSeek(cFilCCT+TSH1->H1_CCUSTO)
		    if CTT->CTT_CLASSE=="2"   
		    	if CTT->CTT_NORMAL=="1"	
					dbSelectArea("SH7")
					dbSetOrder(1)
					If dbSeek(cFilCH7+TSH1->H1_CALEND)
						dbSelectArea("SH1")
						dbSetOrder(1)
						If !dbSeek(xFILIAL("SH1")+TSH1->H1_CODIGO)			 
							RECLOCK("SH1",.T.)
							For nX := 1 to Len(aCampo)
							SH1->&(aCampo[NX]):=TSH1->&(aCampo[NX])	
						    next
							iOk++
							MSUNLOCK()
						else
							RECLOCK("SH1",.F.) 
							For nX := 1 to Len(aCampo)
							SH1->&(aCampo[NX]):=TSH1->&(aCampo[NX])	
						    next	
							iOk2++
							MSUNLOCK()
						endif	 
					//aadd(aRaylog1,TSH1->H1_CODIGO+" corecto")	 
					else 
					iFail++
						if empty(TSH1->H1_CALEND)
						aadd(aRaylog1,TSH1->H1_CODIGO+" el Calendario esta Vacío H1_CALEND")
						else
						aadd(aRaylog1,TSH1->H1_CODIGO+" el Calendario "+TSH1->H1_CALEND+" es incorecto")
						endif		
					endif
				else
			iFail++
			aadd(aRaylog1,TSH1->H1_CODIGO+" la condicion normal no es gasto es:<> 1")
			endif 
			else
			iFail++
			aadd(aRaylog1,TSH1->H1_CODIGO+" centro de costo "+TSH1->H1_CCUSTO+" no es analitico ")
			endif 	 
		else
		iFail++ 
			if empty(TSH1->H1_CCUSTO)
			aadd(aRaylog1,TSH1->H1_CODIGO+" centro de costo Vacío H1_CCUSTO")
			else  
			aadd(aRaylog1,TSH1->H1_CODIGO+" centro de costo "+TSH1->H1_CCUSTO+" incorecto")
			endif		
		endif 
TSH1->(DBSKIP())
ENDDO 
endif//dupli 
TSH1->(dbCloseArea())

msgalert("Finalizo la importación! "+_cFimLin+"Ítems correctos Subidos: "+str(iOk)+_cFimLin+"Ítems Modificados: "+str(iOk2)+_cFimLin+"Ítems con errores: "+str(iFail)+_cFimLin+"Total de Ítems : "+str(iOk2+iOk+iFail)+_cFimLin+"Consultar el archivo log!")
crealog(@aRaylog1,2)
WinExec('NOTEPAD '+GetClientDir()+'log_SH1.txt',1)
else
alert("Lay out incorrecto!!!")
endif 
endif
		
Return  
//----------------------------------SG2-Operaciones----------------------------------------
static Function importasG2()											 
local archi 
LOCAL cFilSH1:=xFILIAL("SH1")  
LOCAL cFilSH4:=xFILIAL("SH4") 
LOCAL cFilSG1:=xFILIAL("SG1")
LOCAL cFilSX5:=xFILIAL("SX5") 
LOCAL cFilSB1:=xFILIAL("SB1")  
local aRaylog1:={}
LOCAL iOk:=0
LOCAL iOk2:=0
local iFail:=0 
local aTMP:={}
local aTMP2:={} 
LOCAL aDUPI:={}
LOCAL nCONT:=0
local aCampo:={} 
local aTMeSX3:={}
local i := 0
local y := 0
local nX := 0

archi:=Open_dbf("SG2-operaciones")	
if !empty(archi)
dbUseArea( .T.,"dbfcdxads",archi,"TSG2", .T., .F. ) 
TSG2->(dbGoTop())
if substr(TSG2->(FieldName(1)),1,3)=="G2_"
ProcRegua(RecCount())

for i :=1 to FCount()
AADD(aTMP,TSG2->(FieldName(i)))
next 

aTMeSX3:=geraSX3("SG2")
  
for i:=1 to len(aTMP)
	for y:=1 to len(aTMeSX3)
		if alltrim(aTMP[i])==alltrim(aTMeSX3[y])
		aadd(aCampo,aTMeSX3[y]) 
		endif
	next
next
/*
TSG2->(dbGoTop())
WHILE !TSG2->(EOF())
	AADD(aTMP,TSG2->G2_PRODUTO)
TSG2->(DBSKIP())
ENDDO 
TSG2->(dbgotop()) 
WHILE !TSG2->(EOF())
	FOR I:=1 TO LEN(aTMP)
	  IF alltrim(aTMP[I])==alltrim(TSG2->G2_PRODUTO)
	  nCONT++
	  ENDIF
	NEXT 
	IF nCONT>=2
	AADD(aRaylog1,"Registro duplicado: " +TSG2->G2_PRODUTO)
	ENDIF
	nCONT:=0 
TSG2->(DBSKIP())
ENDDO

IF !EMPTY(aRaylog1)
	    MSGALERT("REGISTROS DUPICADOS ")  
ELSE*/
TSG2->(dbgotop())
  
WHILE !TSG2->(EOF())
		INCPROC()
		dbSelectArea("SG1")
		dbSetOrder(5)
		If dbSeek(cFilSG1+TSG2->G2_PRODUTO)
			//IF TSG2->G2_LOTEPAD==SG1->G1_QUANT
					dbSelectArea("SB1")
					dbSetOrder(1)
					If dbSeek(cFilSB1+TSG2->G2_PRODUTO)
						IF TSG2->G2_LOTEPAD==SB1->B1_QB 
							dbSelectArea("SH1")
							dbSetOrder(1)
							If dbSeek(cFilSH1+TSG2->G2_RECURSO)		
								//dbSelectArea("SH4")
								//dbSetOrder(1)
								//If dbSeek(cFilSH4+TSG2->G2_FERRAM)  
									//dbSelectArea("SX5")
									//dbSetOrder(1)
									//If dbSeek(cFilSX5+"OP"+TSG2->G2_DEPTO)
										dbSelectArea("SG2")
										dbSetOrder(1)
										If !dbSeek(XFILIAL("SG2")+TSG2->G2_PRODUTO+TSG2->G2_CODIGO+TSG2->G2_OPERAC)	
											RECLOCK("SG2",.T.)
												For nX := 1 to Len(aCampo)
													SG2->&(aCampo[NX]):=TSG2->&(aCampo[NX])	
											    next	
											iOk++
											MSUNLOCK()
										ELSE 
											RECLOCK("SG2",.F.)	
											For nX := 1 to Len(aCampo)
												SG2->&(aCampo[NX]):=TSG2->&(aCampo[NX])	
											 next
											iOk2++
											MSUNLOCK()
										ENDIF 	
									//else 
									//iFail++
									//aadd(aRaylog1,TSG2->G2_PRODUTO+": "+TSG2->G2_DEPTO+" Departamento incorrecto")
									//ENDIF
								//else
								//iFail++
								//aadd(aRaylog1,TSG2->G2_PRODUTO+": "+TSG2->G2_FERRAM+" Herramienta incorrecta")
								//ENDIF
							else
							iFail++  
								if empty(TSG2->G2_RECURSO)
								aadd(aRaylog1,TSG2->G2_PRODUTO+": Recurso Vacío G2_RECURSO")
								else
								aadd(aRaylog1,TSG2->G2_PRODUTO+": "+TSG2->G2_RECURSO+" Recurso incorrecto")
							    endif
							ENDIF 
						//aadd(aRaylog1,TSG2->G2_PRODUTO+" centro de costo incorecto")
						else
						iFail++
						aadd(aRaylog1,TSG2->G2_PRODUTO+"La cantidad base "+TSG2->G2_LOTEPAD+" es diferente ala informada en el catálogo de productos")
						ENDIF
						else
						iFail++
							if empty(TSG2->G2_PRODUTO)
							aadd(aRaylog1,TSG2->G2_PRODUTO+" El código Vacío G2_PRODUTO")
							else 
							aadd(aRaylog1,TSG2->G2_PRODUTO+" El código no está en el catálogo de productos")
							endif
					ENDIF
				//else
				//iFail++
				//aadd(aRaylog1,TSG2->G2_PRODUTO+" La cantidad informada en la estructura es diferente")
			//ENDIF 
			else
			iFail++
			aadd(aRaylog1,TSG2->G2_PRODUTO+" El código de producto no pertenece a una estructura")
		endif		  			 
TSG2->(DBSKIP())
ENDDO 
TSG2->(dbCloseArea()) 
msgalert("Finalizo la importación! "+_cFimLin+"Ítems correctos Subidos: "+str(iOk)+_cFimLin+"Ítems Modificados: "+str(iOk2)+_cFimLin+"Ítems con errores: "+str(iFail)+_cFimLin+"Total de Ítems : "+str(iOk2+iOk+iFail)+_cFimLin+"Consultar el archivo log!")
crealog(@aRaylog1,4)
WinExec('NOTEPAD '+GetClientDir()+'log_SG2.txt',1)
else
alert("Lay out incorrecto!!!")
endif 
endif		
Return 
//----------------------------------SG1-ESTRUCTURAS----------------------------------------
static Function importasG1()											 
local archi 
LOCAL cFilSB1:=xFILIAL("SB1")  
LOCAL cFilSH7:=xFILIAL("SH7") 
local aRaylog1:={}
LOCAL iOk:=0
LOCAL iOk2:=0
local iFail:=0  
local aTMP:={}
local aTMP2:={}  
LOCAL aDUPI:={}
LOCAL nCONT:=0
local aCampo:={} 
local aTMeSX3:={}
local i := 0
local y := 0 
local nX :=0

archi:=Open_dbf("SG1-ESTRUCTURAS")	
if !empty(archi)
dbUseArea( .T.,"dbfcdxads",archi,"TSG1", .T., .F. ) 
TSG1->(dbGoTop()) 
if substr(TSG1->(FieldName(1)),1,3)=="G1_"
ProcRegua(RecCount())  

for i:=1 to FCount()
AADD(aTMP,TSG1->(FieldName(i)))
next 

aTMeSX3:=geraSX3("SG1")
  
for i:=1 to len(aTMP)
	for y :=1 to len(aTMeSX3)
		if alltrim(aTMP[i])==alltrim(aTMeSX3[y])
		aadd(aCampo,aTMeSX3[y]) 
		endif
	next
next   

TSG1->(dbGoTop())
WHILE !TSG1->(EOF())
	AADD(aTMP2,{TSG1->G1_COD,TSG1->G1_COMP,TSG1->G1_TRT})
TSG1->(DBSKIP())
ENDDO 
TSG1->(dbgotop()) 
WHILE !TSG1->(EOF()) 
	INCPROC()
	FOR I:=1 TO LEN(aTMP2)   
	  cDES1:=aTMP2[I][1]
	  cDES2:=aTMP2[I][2] 
	  cDES3:=aTMP2[I][3]
	  IF alltrim(cDES1)==alltrim(TSG1->G1_COD) .AND. alltrim(cDES2)==alltrim(TSG1->G1_COMP) .AND. alltrim(cDES3)==alltrim(TSG1->G1_TRT)
	  nCONT++
	  ENDIF
	NEXT 
	IF nCONT>=2
	AADD(aRaylog1,"Registro duplicado: " +TSG1->G1_COD+" "+TSG1->G1_COMP+" "+TSG1->G1_TRT)
	ENDIF
	nCONT:=0 
TSG1->(DBSKIP())
ENDDO

IF !EMPTY(aRaylog1)
	    MSGALERT("REGISTROS DUPICADOS ")  
ELSE
TSG1->(dbgotop())
WHILE !TSG1->(EOF())   
		INCPROC()
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(cFilSB1+TSG1->G1_COD) 
				If dbSeek(cFilSB1+TSG1->G1_COMP) 
					If (TSG1->G1_QUANT <> 0) 
						IF TSG1->G1_COMP <>	TSG1->G1_COD
							dbSelectArea("SG1")
							dbSetOrder(1)
							IF !DBSEEK(XFILIAL("SG1")+TSG1->G1_COD+TSG1->G1_COMP+TSG1->G1_TRT)	
								RECLOCK("SG1",.T.)
									For nX := 1 to Len(aCampo)
										SG1->&(aCampo[NX]):=TSG1->&(aCampo[NX])	
									next
							
								iOk++
								MSUNLOCK()
							ELSE
								RECLOCK("SG1",.F.)
									For nX := 1 to Len(aCampo)
										SG1->&(aCampo[NX]):=TSG1->&(aCampo[NX])	
									 next
								iOk2++
								MSUNLOCK()
							ENDIF 
						else
						iFail++
						aadd(aRaylog1,TSG1->G1_COD+" "+TSG1->G1_COMP+" looping ")
						ENDIF					
					else
					iFail++
					aadd(aRaylog1,TSG1->G1_COD+" "+TSG1->G1_COMP+" "+ str(TSG1->G1_QUANT) +" La cantidad no puede ser cero")
					ENDIF
				else
				iFail++  
					if empty(TSG1->G1_COMP)
					aadd(aRaylog1," El código de componente Vacío G1_COMP")
					else
					aadd(aRaylog1,TSG1->G1_COMP+" El código de componente no existe en el catálogo de productos SB1")
					endif
				ENDIF
		else
		iFail++
			IF EMPTY(TSG1->G1_COD)
			aadd(aRaylog1," El código de producto PADRE Vacío G1_COD")
			else
			aadd(aRaylog1,TSG1->G1_COD+" El código de producto PADRE no existe en el catálogo de productos SB1")
		    endif
		ENDIF			  			 
TSG1->(DBSKIP())
ENDDO      
ENDIF
TSG1->(dbCloseArea())
msgalert("Finalizo la importación! "+_cFimLin+"Ítems correctos Subidos: "+str(iOk)+_cFimLin+"Ítems Modificados: "+str(iOk2)+_cFimLin+"Ítems con errores: "+str(iFail)+_cFimLin+"Total de Ítems : "+str(iOk2+iOk+iFail)+_cFimLin+"Consultar el archivo log!")
crealog(@aRaylog1,3)
WinExec('NOTEPAD '+GetClientDir()+'log_SG1.txt',1)
else
alert("Lay out incorrecto!!!")
endif 
endif		
Return  
//------------------------------------SB1-PRODUCTOS--------------------------------------
static Function importasb1()											 
local archi 
LOCAL cFilSBM:=xFILIAL("SBM")  
LOCAL cFilSAH:=xFILIAL("SAH") 
LOCAL cFilSX5:=xFILIAL("SX5") 
local aRaylog1:={} 
LOCAL iOk:=0
LOCAL iOk2:=0   
local aTMP:={}
local aTMP2:={} 
local iFail:=0   
LOCAL aDUPI:={}
LOCAL nCONT:=0
local aCampo:={} 
local aTMeSX3:={}
local i := 0
local y := 0
local nX := 0

archi:=Open_dbf("SB1-PRODUCTOS")	
if !empty(archi)
dbUseArea( .T.,"dbfcdxads",archi,"TSB1", .T., .F. ) 
TSB1->(dbGoTop())
if substr(TSB1->(FieldName(1)),1,3)=="B1_"
ProcRegua(RecCount())     

for i:=1 to FCount()
AADD(aTMP,TSB1->(FieldName(i)))
next 

aTMeSX3:=geraSX3("SB1")
  
for i:=1 to len(aTMP)
	for y:=1 to len(aTMeSX3)
		if alltrim(aTMP[i])==alltrim(aTMeSX3[y])
		aadd(aCampo,aTMeSX3[y]) 
		endif
	next
next
TSB1->(dbGoTop())
WHILE !TSB1->(EOF())
	AADD(aTMP,TSB1->B1_COD)
TSB1->(DBSKIP())
ENDDO 
TSB1->(dbgotop()) 
WHILE !TSB1->(EOF())     
	INCPROC()
	FOR I:=1 TO LEN(aTMP)
	  IF alltrim(aTMP[I])==alltrim(TSB1->B1_COD)
	  nCONT++
	  ENDIF
	NEXT 
	IF nCONT>=2
	AADD(aRaylog1,"Registro duplicado: " +TSB1->B1_COD+" "+TSB1->B1_DESC)
	ENDIF
	nCONT:=0 
TSB1->(DBSKIP())
ENDDO

IF !EMPTY(aRaylog1)
	    MSGALERT("REGISTROS DUPICADOS ")  
ELSE
TSB1->(dbgotop())
WHILE !TSB1->(EOF())
INCPROC()
		dbSelectArea("SBM")
		dbSetOrder(1)
		If dbSeek(cFilSBM+TSB1->B1_GRUPO)  
			dbSelectArea("SAH")
			dbSetOrder(1)
			If dbSeek(cFilSAH+TSB1->B1_UM)  
				dbSelectArea("SX5")
				dbSetOrder(1)
				If dbSeek(cFilSX5+"02"+TSB1->B1_TIPO) 
					If dbSeek(cFilSX5+"AL"+TSB1->B1_LOCPAD)  
						dbSelectArea("SB1")
						dbSetOrder(1)
						If !dbSeek(XFILIAL("SB1")+TSB1->B1_COD) 
						    RECLOCK("SB1",.T.)
						    For nX := 1 to Len(aCampo)
								SB1->&(aCampo[nX]) := TSB1->&(aCampo[nX])
							Next nX					     
							iOk++
							MSUNLOCK()
						ELSE
							RECLOCK("SB1",.F.)
						    For nX := 1 to Len(aCampo)
								SB1->&(aCampo[nX]) := TSB1->&(aCampo[nX])
							Next nX						     
							iOk2++
							MSUNLOCK() 
						ENDIF	 
					   else  
					   iFail++
					   	if empty(TSB1->B1_COD)
					   	aadd(aRaylog1,TSB1->B1_COD+" local Vacío B1_LOCPAD")
					   	else
					   	aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" no esta el local:"+TSB1->B1_LOCPAD)
					    endif
					endif
				else 
				iFail++  
				    if empty(TSB1->B1_TIPO)
			    	aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" el tipo de prod. esta Vacío B1_TIPO")
			    	else
			    	aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" no esta el tipo de prod:"+TSB1->B1_TIPO)
			    	endif 
				endif
			else
			iFail++
				if empty(TSB1->B1_UM)
				aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" unidad de medida Vacía B1_UM ")
				else
				aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" no esta la unidad de medida:"+TSB1->B1_UM)
				endif	
			endif 
		else
		iFail++ 
		    if empty(TSB1->B1_GRUPO)
		    aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" el grupo de producto esta Vacío B1_GRUPO")
		    else
			aadd(aRaylog1,TSB1->B1_COD+" "+TSB1->B1_DESC+" no esta el grupo de producto:"+TSB1->B1_GRUPO)
			endif		
		endif 
TSB1->(DBSKIP())
ENDDO     
ENDIF
TSB1->(dbCloseArea())
//MSAPPEND(dbSelectArea("SB1"),archi)
msgalert("Finalizo la importación! "+_cFimLin+"Ítems correctos Subidos: "+str(iOk)+_cFimLin+"Ítems Modificados: "+str(iOk2)+_cFimLin+"Ítems con errores: "+str(iFail)+_cFimLin+"Total de Ítems : "+str(iOk2+iOk+iFail)+_cFimLin+"Consultar el archivo log!")
crealog(@aRaylog1,1)
WinExec('NOTEPAD '+GetClientDir()+'log_SB1.txt',1)
else
alert("Lay out incorrecto!!!")
endif 
endif		
Return  
//------------------------------------SGF-operacion vs componente--------------------------------------
static Function importasGF() 
local archi 
LOCAL cFilSG1:=xFILIAL("SG1")  
LOCAL cFilSG2:=xFILIAL("SG2")  
local aRaylog1:={} 
LOCAL iOk:=0
LOCAL iOk2:=0
local iFail:=0  
local aTMP:={}
local aTMP2:={}  
LOCAL aDUPI:={}
LOCAL nCONT:=0
local aCampo:={} 
local aTMeSX3:={}
local i := 0
local y := 0
local nX := 0

archi:=Open_dbf("SGF-Operación vs Componente")	
if !empty(archi)
dbUseArea( .T.,"dbfcdxads",archi,"TSGF", .T., .F. ) 
TSGF->(dbGoTop())
if substr(TSGF->(FieldName(1)),1,3)=="GF_"
ProcRegua(RecCount()) 

for i :=1 to FCount()
AADD(aTMP,TSGF->(FieldName(i)))
next 

aTMeSX3:=geraSX3("SBF")
  
for i :=1 to len(aTMP)
	for y :=1 to len(aTMeSX3)
		if alltrim(aTMP[i])==alltrim(aTMeSX3[y])
		aadd(aCampo,aTMeSX3[y]) 
		endif
	next
next
/*TSGF->(dbGoTop())
WHILE !TSGF->(EOF())
	AADD(aTMP,TSGF->GF_PRODUTO)
TSGF->(DBSKIP())
ENDDO 
TSGF->(dbgotop()) 
WHILE !TSGF->(EOF())
	FOR I:=1 TO LEN(aTMP)
	  IF alltrim(aTMP[I])==alltrim(TSGF->GF_PRODUTO)
	  nCONT++
	  ENDIF
	NEXT 
	IF nCONT>=2
	AADD(aRaylog1,"Registro duplicado: " +TSGF->GF_PRODUTO)
	ENDIF
	nCONT:=0 
TSGF->(DBSKIP())
ENDDO

IF !EMPTY(aRaylog1)
	    MSGALERT("REGISTROS DUPICADOS ")  
ELSE
  */
TSGF->(dbgotop())
WHILE !TSGF->(EOF())
	INCPROC() 
	dbSelectArea("SG1")
	dbSetOrder(1)
	If dbSeek(cFilSG1+TSGF->GF_PRODUTO+TSGF->GF_COMP+TSGF->GF_TRT)
		dbSelectArea("SG2")
		dbSetOrder(3)
		if dbSeek(cFilSG2+TSGF->GF_PRODUTO+TSGF->GF_OPERAC) 	
    			dbSelectArea("SGF")
				dbSetOrder(1)
    		IF !DBSEEK(XFILIAL("SGF")+TSGF->GF_PRODUTO+TSGF->GF_ROTEIRO+TSGF->GF_OPERAC+TSGF->GF_COMP+TSGF->GF_TRT)
    			RECLOCK("SGF",.T.)
				For nX := 1 to Len(aCampo)
				SGF->&(aCampo[nX]) := TSGF->&(aCampo[nX])
				Next nX
				iOk++
				MSUNLOCK() 
	    	ELSE 
	    		RECLOCK("SGF",.F.)
				For nX := 1 to Len(aCampo)
				SGF->&(aCampo[nX]) := TSGF->&(aCampo[nX])
				Next nX
				iOk2++
				MSUNLOCK() 
	    	ENDIF	    
	    ELSE 
	    iFail++  
	        IF EMPTY(TSGF->GF_OPERAC)
	        aadd(aRaylog1,"El producto "+alltrim(TSGF->GF_PRODUTO)+", componente "+alltrim(TSGF->GF_COMP)+" La operación esta Vacía GF_OPERAC")
	        ELSE
	    	aadd(aRaylog1,"El producto "+alltrim(TSGF->GF_PRODUTO)+", componente "+alltrim(TSGF->GF_COMP)+" La operación "+TSGF->GF_OPERAC+" no existe en el catálogo de operaciones")
	        ENDIF
	    ENDIF
	ELSE 
	iFail++
	if empty(TSGF->GF_PRODUTO)
	aadd(aRaylog1,"El producto esta Vacío GF_PRODUTO")
	elseif empty(TSGF->GF_COMP)
	aadd(aRaylog1,"El componente esta Vacío GF_COMP")
	elseif empty(TSGF->GF_TRT) 
	aadd(aRaylog1,"La secuencia esta Vacío GF_TRT")
	else
	aadd(aRaylog1,"El producto "+alltrim(TSGF->GF_PRODUTO)+", componente "+alltrim(TSGF->GF_COMP)+" o secuencia "+alltrim(TSGF->GF_TRT)+" son diferentes a los informados en la estructura SG1")
	endif
	ENDIF 
TSGF->(DBSKIP())
ENDDO 
TSGF->(dbCloseArea())
msgalert("Finalizo la importación! "+_cFimLin+"Ítems correctos Subidos: "+str(iOk)+_cFimLin+"Ítems Modificados: "+str(iOk2)+_cFimLin+"Ítems con errores: "+str(iFail)+_cFimLin+"Total de Ítems : "+str(iOk2+iOk+iFail)+_cFimLin+"Consultar el archivo log!")
crealog(@aRaylog1,5)
WinExec('NOTEPAD '+GetClientDir()+'log_SGF.txt',1)
else
alert("Lay out incorrecto!!!")
endif 
endif 
Return
//---------------------------------LOG------------------------------------------  
static Function crealog(aRaylog,opc) 
local cNoLog:=""
local nHandle
local cAuxLine:="" 
local i := 0

if opc==1
cNoLog:=GetClientDir()+"log_SB1.txt"
elseif opc==2
cNoLog:=GetClientDir()+"log_SH1.txt" 
elseif opc==3         
cNoLog:=GetClientDir()+"log_SG1.txt"
elseif opc==4         
cNoLog:=GetClientDir()+"log_SG2.txt" 
elseif opc==5         
cNoLog:=GetClientDir()+"log_SGF.txt"
endif  
nHandle	:= FCreate(cNoLog)
for i :=1 to len(aRaylog)
	cAuxLine :=aRaylog[i]  
	FWrite(nHandle,cAuxLine+_cFimLin)
next i 
fClose(nHandle)
return
//-----------------------------PIDE-ARC-DBF--------------------------------------------
static Function Open_dbf(cNomLa)											
	Local cNewPathArq	:=""									
	cNewPathArq	:=cGetFile (cNomLa+'|*.DBF',"Selecio el lay out: "+cNomLa,1,,.f.,1,.t.,)
		IF !Empty(cNewPathArq ) 
		     Return cNewPathArq   
		EndIF		
Return ""  
//----------------------------campos------------------------
static Function geraSX3(cAliasE) 
local aCpoEnch		:={}
local aAlterEnch	:={}  
DbSelectArea("SX3");DbSetOrder(1);DbSeek(cAliasE)
While !Eof() .And. SX3->X3_ARQUIVO == cAliasE
		AADD(aCpoEnch,SX3->X3_CAMPO)		 
	DbSkip()
End  
return aCpoEnch
