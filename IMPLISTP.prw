#include 'protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "DBINFO.CH"
#include "Fileio.ch"
#DEFINE CRLF Chr(13)+Chr(10)
#DEFINE TAB  Chr(09)

/*
+===========================================================================+
|  Programa  IMPLISTP BusReg Autor  M&H   Fecha 06/10/2022   	            |
|                                                                           |
|  Uso  Actualizar lista de precios      |                                  |
+===========================================================================+
*/

User Function IMPLISTP()
	Local cMsgAux
    cMsgAux := 'Rutina de Importacion de listas de Precios<br>'
    cMsgAux += '<br>'
    cMsgAux += 'NOTA IMPORTANTE <br>'
    cMsgAux += '1. Los campos del archivo de importación deben tener como separador TABULADOR<br>'
    cMsgAux += '2. Los archivos a importar deben tener extension TXT:<br>'
    cMsgAux += '3. Las líneas de encabezado de la lista se repetirá tantas veces como ítems de productos sean agregados para cada lista.  <br>'
    cMsgAux += '4. Los campos que contienen valores númericos NO DEBEN TENER SEPARADORES DE MILES<br> '
    cMsgAux += '5. Los campos que contienen valores númericos con decimales, debe usar como separador PUNTO (.) <br> '
    cMsgAux += '<br>'
    cMsgAux += 'Ejemplo: <br> '
    cMsgAux += '<br>'
    cMsgAux += 'INCORRECTO-> 1,234,567.89 <BR>(Separador de Miles no usar)<br> '
    cMsgAux += 'INCORRECTO-> 1.234.567,89 <BR>(Separador de Miles y Coma "," como separado de Décimales no usar)<br> '
    cMsgAux += 'INCORRECTO->   1234567,89 <BR>(Coma como separado)<br> '
    cMsgAux += '<b>CORRECTO  ->   1234567.89</b><br> '
	cMsgAux += '<br>'
	cMsgAux += '¿Continuar?'
IF MsgNoYes(cMsgAux,"Importación de listas de Precios")
	MsAguarde({|| IMPLISTP2()},"IMPORTANDO", "Leyendo archivos, por favor espere.")
EndIf
Return

/*
+===========================================================================+
|  Programa  IMPLISTP BusReg Autor  M&H   Fecha 06/10/2022   	            |
|                                                                           |
|  Uso  IMPORTAR listaS DE ENTRADA     |                                  |
+===========================================================================+
*/
STATIC Function IMPLISTP2()
Local nHandle
Local nTimer
Local nLines 	:= 0
Local aRegs 	:= {}
Local aRegs2	:= {}
Local aRet		:= {}
Local aCab		:= {}
Local aItems	:= {}
Local cselect 	:= "select "
Local nDecimal	:= 0
Local nII		:= 0
Local nIX		:= 0
Local nIY		:= 0 // para el bucle de archivos
Local cFilal	:= ''
Local cCodTab		:= ''
Local cDescr	:= ''
Local dDataInic	:= ''
Local cHoraDe		:= ''
Local cHoraAte		:= ''
Local nDupli	:= 0
Local lValid	:= .T.
Local lValidtmp	:= .T.
Local aFiles 	:= {}   	// listado de archivos
Local nFiles	:= 0		// Cantidad de archivos encontrados
Local aPfiles	:= {}
Local cMSG		:= ''
Local lLimpia	:= .F.
Local cLineaTMP	:= ''
local Cname := ''
Private aLogComp	:= {}
Private cLogMsg		:= ''
Private cPathLog  	:= SuperGetMV('MV_XARQLOG' 	,,'\nfc\logs\')   // ubicacion de logs en el servidor
Private cPathOk   	:= SuperGetMV('MV_XARQOK' 	,,'\nfc\procesados\') // ubicacion de archivos procesados en el servidor
// Private cPathArq 	:= SuperGetMV('MV_XARQPEN'	,,'C:\implistp\') // ubicaciones de archivos a leer

Private cPathArq    := cGetFile("Arquivo TXT|*.TXT","Selecione o arquivo",0,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD,.F.)

Private cPathAP		:= SuperGetMV('MV_XARQPRO'	,,'C:\implistp\procesados\') // archivos procesados en la estaciones de trabajo
Private cPathAPL	:= SuperGetMV('MV_XARQPRL'	,,'C:\implistp\logs\') // archivos de logs en la estaciones de trabajo
Private CDecimal 	:= "."
Private CMiles		:= ","




IF !ExistDir(cPathLog)
	MakeDir( cPathLog )
EndIf
IF !ExistDir(cPathOk)
	MakeDir( cPathOk )
EndIf
IF !ExistDir(cPathAP)
	MakeDir( cPathAP )
EndIf
IF !ExistDir(cPathAPL)
	MakeDir( cPathAPL)
EndIf
aFiles 		:= Directory(cPathArq)   	// listado de archivos
nFiles		:= Len(aFiles)						// Cantidad de archivos encontrados
nTimer 		:= seconds()
Cname := 'lpreci_'+DTOS(dDataBase)+'_'+Time()
Cname := StrTran(cValToChar(Cname),":","")
AXMSG( "Inicio de Importación lista de Precios" )
IF nFiles == 0
	AXMSG( "Ningún archivo fue encontrado")
	MsgStop("Ningún archivo fue encontrado en: "+cPathArq)
	Grabamsg(FUNNAME(),aLogComp)
	Return
EndIf

FOR nIY:= 1 to nFiles   // Procesamiento de cada archivo ubicado en la carpeta MV_XARQPEN
	aRegs 	:= {}
	aRegs2	:= {}
	MsProcTxt("Leyendo "+aFiles[nIY,1])	
	AXMSG("Abriendo Archivo: " + aFiles[nIY,1] + " -")
	nHandle := FT_FUSE(cPathArq)
	If nHandle < 0
		AXMSG( "Falla al abrir el archivo "+ aFiles[nIY,1] + " ")
		aadd(aPfiles,aFiles[nIY,1]," Falla al abrir archivo")
		Grabamsg(Cname,aLogComp)
	ELSE
		While !FT_FEOF() // Lectura de registros del archivo
			nLines++
			cLine := ALLTRIM(FT_FReadLN())
			cLine := StrTran( cLine, TAB, ";" )  // Cambia los TAB por punto y coma
			IF !EMPTY(cLine)
				While !lLimpia
					cLineaTMP:= StrTran( cLine, " ;", ";" )
					cLineaTMP:= StrTran( cLineaTMP, "; ", ";" )
					IF cLineaTMP == cLine
						cLine := cLineaTMP
						lLimpia:= .T.
					Else
						cLine := cLineaTMP
					EndIf
				Enddo
				
				cLine:= "{'"+StrTran( cLine, ";", "','" )+"'}"
				
				aAdd(aRegs,&cLine)  // Crea la linea de registros
			EndIF
			FT_FSkip()
		Enddo
		FT_FUSE()
		aAdd(aRegs2,aRegs[1])
		For nII:=2 to Len(aRegs) // revisa campos esenciales de cada registro 
			MsProcTxt("Leyendo "+aFiles[nIY,1]+" Registro" + cValToChar(nII-1) )
			lValid		:= .T.
			cFilal		:= BusReg(aRegs,nII,'DA0_FILIAL')
			cCodTab		:= BusReg(aRegs,nII,'DA0_CODTAB')
			cDescr		:= BusReg(aRegs,nII,'DA0_DESCRI')
			dDataInic	:= BusReg(aRegs,nII,'DA0_DATDE')
			cHoraDe		:= BusReg(aRegs,nII,'DA0_HORADE')
			cHoraAte		:= BusReg(aRegs,nII,'DA0_HORATE')
			IF  EMPTY(cFilal)   .OR. ;
			    EMPTY(cCodTab)    // .OR. ;
			    //EMPTY(dDataInic) .OR. ;
			    //EMPTY(cHoraDe)
				nDupli		:= 999
			ELSE			     
			   AXMSG( "Procesando "+ cFilal+":"+cCodTab+":"+cDescr+" del archivo:"+aFiles[nIY,1] )	
			   //nDupli		:= DUPLIC(cFilal,cCodTab,cDescr,dDataInic,cHoraDe)
			ENDIF

			IF nDupli == 999
				AXMSG( "REGISTRO INVALIDO " + cValToChar(nII-1)+" EN " +aFiles[nIY,1] )	
				aadd(aPfiles,{aFiles[nIY,1]," Archivo Invalido"})
			ELSEIF nDupli==1
				AXMSG( "REGISTRO YA EXITE EN PROTHEUS (DUPLICADO) REGISTRO No:"+cValToChar(nII-1))
				//aadd(aPfiles,{aFiles[nIY,1]," Registro(s) Duplicado(s)"})
			ELSEIF nDupli==2
				AXMSG( "LA FILIAL NO CORRESPONDE CON EL SISTEMA, REGISTRO No:"+cValToChar(nII-1))
				//aadd(aPfiles,{aFiles[nIY,1]," Filial errada en regitro(s)"})
			ELSE
				/*lValidTmp	:= VALIDFOR(BusReg(aRegs,nII,'DA0_DATDE'))
				lValid		:= IIF(lValidTmp,lValid,.F.)
				IF !lValidTmp 
					AXMSG("Código de proveedor no encontrado, REGISTRO No:"+cValToChar(nII-1))
				Endif
				*/
				lValidTmp	:= VALIDPROD(BusReg(aRegs,nII,'DA1_CODPRO'))
				lValid		:= IIF(lValidTmp,lValid,.F.)
				IF !lValidTmp
					AXMSG("Código de producto no encontrado ("+BusReg(aRegs,nII,'DA1_CODPRO')+"), REGISTRO No:"+cValToChar(nII-1))
				Endif
				
				If !EMPTY(ALLTRIM(BusReg(aRegs,nII,'DA1_GRUPO')))
					lValidTmp	:= VALIDGRUP(BusReg(aRegs,nII,'DA1_GRUPO'))
					lValid		:= IIF(lValidTmp,lValid,.F.)
					IF !lValidTmp
						AXMSG( "Grupo  ("+BusReg(aRegs,nII,'DA1_GRUPO')+") no encontrada o se encuentra bloqueada, REGISTRO No:"+cValToChar(nII-1))
					Endif
				Endif
				
				IF lValid	  // Revisión primaria satisfactoria del registro, se procede a agregar a segundo arreglo de registros buenos
					aAdd(aRegs2,aRegs[nII])
					AXMSG( "VALIDACION PRIMARIA SASTISFACTORIA, REGISTRO No:"+cValToChar(nII-1))
				ELSE
					aadd(aPfiles,{aFiles[nIY,1]," Validación primaria de registro(s) tuvo error(es), registro "+ cValToChar(nII-1)})
				EndIf
			Endif
			
		Next
		
		IF len(aRegs2)>1
			AXMSG("-------------------------------------------------------------------------------------------")
			AXMSG("INICIO VALIDACION SECUNDARIA")
			AXMSG("-------------------------------------------------------------------------------------------")
			AddFats(aRegs2,aFiles[nIY,1])
			AXMSG("===========================================================================================")
			AXMSG("Se leyeron " + cValToChar(nLines)+" linea(s) del archivo: "+aFiles[nIY,1]+" y procesaron "+ cValToChar(len(aRegs2)-1)+" en "+str(seconds()-nTimer,12,3)+' s.'," ")
			AXMSG("-------------------------------------------------------------------------------------------")
			AXMSG("-------------------------------------------------------------------------------------------")
			//MsgInfo("Se leyeron " + cValToChar(nLines)+" linea(s) y procesaron "+ cValToChar(len(aRegs2)-1)+" en "+str(seconds()-nTimer,12,3)+' s.'," ")
			aadd(aPfiles,{aFiles[nIY,1],"Se leyeron " + cValToChar(nLines)+" linea(s) y procesaron "+ cValToChar(len(aRegs2))+" en "+str(seconds()-nTimer,12,3)+' s.'})
		else
			AXMSG("-------------------------------------------------------------------------------------------")
			AXMSG("Se leyeron " + cValToChar(nLines)+" linea(s) en "+str(seconds()-nTimer,12,3)+' s.'," NO SE INCLUYERON listaS")
			aadd(aPfiles,{aFiles[nIY,1],"Se leyeron " + cValToChar(nLines)+" linea(s) NINGUN DATO FUE PROCESADO"})
			//MsgInfo("Se leyeron " + cValToChar(nLines)+" linea(s) en "+str(seconds()-nTimer,12,3)+' s.'," NO SE INCLUYERON listaS")			

		EndIf
		
		Grabamsg(Cname,aLogComp)
		aLogComp	:= {}


		If __CopyFile(cPathArq, cPathAP+Cname+'.TXT',,,.F.)
			// MsgStop("Error al copiar el archivo "+cPathArq+" al servidor" )
		ELSE
			MsgStop("Error al copiar el archivo "+cPathArq+" a la carpeta: " + cPathAP )
		ENDIF

		// IF frename(cPathArq, cPathAP+Cname+'.TXT')
		// 	IF CpyT2S(cPathAP+aFiles[nIY,1], cPathOk)
		// 		MsgStop("Error al copiar el archivo "+cPathArq+" al servidor" )
		// 	EndIf
		// 	MsgStop("Error al mover el archivo "+cPathArq+" a la carpeta: " + cPathAP )
		// Endif
	Endif

NEXT
/* PARA MEJORAR
For nII:=1 to LEN(aPfiles)
	cMSG += "Archivo:"+aPfiles[1] + "Mensaje:" + aPfiles[2]+CRLF
Next
MsgSTOP(cMSG)
*/
If FWAlertNoYes("Desea revisar el LOG generado para corregir cualquier error ocurrido durante el proceso", "La importacion ha culminado")
	ShellExecute("OPEN",Cname+'.log', "", 'C:\implistp\logs\', 1)
EndIf
// MsgINFO("La importacion ha culminado, favor revise archivos de LOG generados para corregir cualquier error ocurrido durante el proceso")
Return
/*
+===========================================================================+
|  Programa  BusReg Autor  M&H   Fecha 06/10/2022            	            |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/
STATIC FUNCTION BusReg(aArrDataBase,nRegArr,cRegBusc) // Arreglo, posicion, cadena a buscar
	Local aRet		:= {}
	Local nIX		:= 0
	Local cRegEncon	:= " "
	for nIX:=1 to Len(aArrDataBase[1])
		if ALLTRIM(aArrDataBase[1][nIX]) == cRegBusc
			aRet := TamSX3(ALLTRIM(aArrDataBase[1][nIX]))
			IF aRet[3]=='C'
				cRegEncon:=ALLTRIM(aArrDataBase[nRegArr][nIX])
				IF LEN(cRegEncon) < aRet[1]
					cRegEncon:=SUBSTR(cRegEncon+SPACE(aRet[1]),1,aRet[1])
				ENDIF
			Else
				cRegEncon:=aArrDataBase[nRegArr][nIX]
			EndIf
		endif
	next
return cRegEncon

/*
+===========================================================================+
|  Programa  DUPLIC Autor  M&H   Fecha 06/10/2022            	            |
|                                                                           |
|  Uso BUSCA Max item    de la lista    |                                   |
+===========================================================================+
*/
/*/{Protheus.doc} MaxDA1
//TODO Descrio auto-gerada.
@author totvsremote
@since 02/06/2016
@version undefined
@param _cCodTab, , descricao
@type function
/*/
Static Function MaxDA1(_cCodTab)
Local _cAlias := GetNextalias()
Local _cMaxItem := '0'

BeginSql Alias _cAlias

select MAX(DA1_ITEM)  AS cMAXITEM
// FROM DA1010
FROM %Table:DA1% (Nolock) // DJALMA BORGES 14/12/2016
WHERE D_E_L_E_T_ = ''
AND DA1_CODTAB = %Exp:_cCodTab%


EndSql

(_cAlias)->(dbGoTop())
if ! (_cAlias)->(eof())

	_cMaxItem := (_cAlias)->cMAXITEM

Endif

_cMaxItem := val((_cAlias)->cMAXITEM)
_cMaxItem += 1
_cMaxItem := strzero(_cMaxItem,4)

(_cAlias)->(dbCloseArea())


Return(_cMaxItem)


/*
+===========================================================================+
|  Programa  VALIDPROD Autor  M&H   Fecha 06/10/2022         	            |
|                                                                           |
|  Uso  VALIDA PRODUCTO      |                                              |
+===========================================================================+
*/
STATIC FUNCTION VALIDPROD(cPROD)
	Local lValidPROD := .F.
	Local cQuery	:= ''
	Local nCantReg	:= 0
	Local cAlias	:= GetNextAlias()
	cQuery := "SELECT B1_COD "  
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE D_E_L_E_T_ = ' ' " 
	cQuery += "AND B1_COD = '" + cPROD + "' "
	cQuery += "AND B1_FILIAL = '" + XFILIAL("SB1") + "' "
	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQuery) ,cAlias,.T.,.T.)
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	lValidPROD := iif(alltrim((cAlias)->B1_COD) == alltrim(cPROD),.T.,.F.)
	(cAlias)->(DbCloseArea()) 
RETURN lValidPROD
/*
+===========================================================================+
|  Programa  VALIDGRUP Autor  M&H Fecha 06/10/2022		                    |
|                                                                           |
|  Uso   VALIDA GRUPO    |                                                  |
+===========================================================================+
*/
STATIC FUNCTION VALIDGRUP(cCodGrup)
	Local lValidaGrup := .F.
	Local cQuery	:= ''
	Local nCantReg	:= 0
	Local cAlias	:= GetNextAlias()
	cQuery := "SELECT DA0_CODTAB "  
	cQuery += "FROM " + RetSqlName("DAO") + " DA0 "
	cQuery += "WHERE D_E_L_E_T_ = ' ' " 
	cQuery += "AND DA0_CODTAB = '" + cCodGrup + "' "
	cQuery += "AND DA0_FILIAL = '" + XFILIAL("DA0") + "' "
	//cQuery += "AND F4_MSBLQL <> '1' "
	dbUseArea(.T.,"TOPCONN", TcGenQry(nil,nil,cQuery) ,cAlias,.T.,.T.)
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	lValidaGrup := iif(alltrim((cAlias)->F4_CODIGO) == alltrim(cCodGrup),.T.,.F.)
	(cAlias)->(DbCloseArea()) 
RETURN lValidaGrup

/*
+===========================================================================+
|  Programa  AddFats   Autor  M&H   Fecha 06/10/2022     	                |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/
STATIC FUNCTION AddFats(aRegs2,cNomArch)
Local aCab		:= {}
Local aItems	:= {}
Local aIten		:= {}
Local aRet		:= {}
Local lCab		:= .F.
Local nIX		:= 0
Local nII		:= 2
Local cCampoNom	:= ""
Local nCampoVal	:= 0
Local dCampoDat	
Local cCampoCar	:= ""
Local cFilal	:= ""
Local cCodTab	:= ""
Local cDescr	:= ""
Local dDataInic	:= ""
Local cHoraDe	:= "" 
Local cHoraAte	:= ""
Private aAreaDA0  := DA0->(GetArea())
Private aAreaDA1  := DA1->(GetArea())
cFilal		:= BusReg(aRegs2,nII,'DA0_FILIAL')
cCodTab		:= BusReg(aRegs2,nII,'DA0_CODTAB')
cDescr		:= BusReg(aRegs2,nII,'DA0_CODTAB')
dDataInic	:= BusReg(aRegs2,nII,'DA0_DATDE')
cHoraDe		:= BusReg(aRegs2,nII,'DA0_HORADE')
cHoraAte	:= BusReg(aRegs2,nII,'DA0_HORATE')
For nII:=2 to Len(aRegs2)

	IF 	!(cFilal == BusReg(aRegs2,nII,'DA0_FILIAL') .AND. cCodTab == BusReg(aRegs2,nII,'DA0_CODTAB')  .AND. cDescr == BusReg(aRegs2,nII,'DA0_CODTAB')  .AND. dDataInic == BusReg(aRegs2,nII,'DA0_DATDE')  .AND. cHoraDe == BusReg(aRegs2,nII,'DA0_HORADE') )
		AGREGAFAT(aCab,aItems,cFilal,cCodTab,cDescr,dDataInic,cHoraDe,cHoraAte,cNomArch)
		cFilal		:= BusReg(aRegs2,nII,'DA0_FILIAL')
		cCodTab		:= BusReg(aRegs2,nII,'DA0_CODTAB')
		cDescr		:= BusReg(aRegs2,nII,'DA0_CODTAB')
		dDataInic	:= BusReg(aRegs2,nII,'DA0_DATDE')
		cHoraDe		:= BusReg(aRegs2,nII,'DA0_HORADE')
		aCab		:= {}
		aItems		:= {}
		lCab		:= .F.
	endif
	
	IF !lCab
		For nIX:=1 to Len(aRegs2[1])

			IF nIX = 1
				//aItems
			ENDIF
			IF SUBSTR(aRegs2[1][nIX],1,4) == "DA0_"
				cCampoNom := aRegs2[1][nIX]
				
				aRet := TamSX3(aRegs2[1][nIX])

				IF aRet[3]=='D'
					dCampoDat := CToD(aRegs2[nII][nIX])
					aadd(aCab,{cCampoNom,dCampoDat,Nil})
				ELSEIF aRet[3]=='N'
					cCampoCar := StrTran(aRegs2[nII][nIX],CMiles,"")  // Corrección que elimina los "." separadores de Miles
					nCampoVal := VAL(cCampoCar)
					aadd(aCab,{cCampoNom,nCampoVal,Nil})
				ELSE 
					aRet := TamSX3(ALLTRIM(cCampoNom))
					cCampoCar := aRegs2[nII][nIX]
					IF LEN(cCampoCar) < aRet[1]
						cCampoCar:=SUBSTR(cCampoCar+SPACE(aRet[1]),1,aRet[1])
					ENDIF
					IF Empty(cCampoCar) .AND. aRegs2[1][nIX] == "DA0_DESCRI"
						DbSelectArea("DA0")
						DA0->( dbSetOrder( 1 ) )
						cCampoCar:= DA0->DA0_DESCRI
					ENDIF
					aadd(aCab,{cCampoNom,cCampoCar,Nil})
				EndIf


			ENDIF
		Next
	EndIf
	lCab := .T.

	For nIX:=1 to Len(aRegs2[1])
		IF SUBSTR(aRegs2[1][nIX],1,4) == "DA1_"
			cCampoNom := aRegs2[1][nIX]
			aRet := TamSX3(aRegs2[1][nIX])
			
			IF aRet[3]=='D'
				dCampoDat := CToD(aRegs2[nII][nIX])
				aadd(aIten,{cCampoNom,dCampoDat,Nil})
			ELSEIF aRet[3]=='N'
				cCampoCar := StrTran(aRegs2[nII][nIX],CMiles,"")  // Corrección que elimina los "." separadores de Miles
				nCampoVal := VAL(cCampoCar)
				aadd(aIten,{cCampoNom,nCampoVal,Nil})
			ELSE 
				cCampoCar := aRegs2[nII][nIX]
				aRet := TamSX3(ALLTRIM(cCampoNom))
				IF LEN(cCampoCar) < aRet[1]
					cCampoCar:=SUBSTR(cCampoCar+SPACE(aRet[1]),1,aRet[1])
				ENDIF
				aadd(aIten,{cCampoNom,cCampoCar,Nil})
			EndIf
		ENDIF
	Next
	aadd(aItems,aIten)
	aIten		:= {}
	IF nII==Len(aRegs2)
		cFilal		:= BusReg(aRegs2,nII,'DA0_FILIAL')
		cCodTab		:= BusReg(aRegs2,nII,'DA0_CODTAB')
		cDescr		:= BusReg(aRegs2,nII,'DA0_CODTAB')
		dDataInic	:= BusReg(aRegs2,nII,'DA0_DATDE')  // Modificacion dado que no encuentra el fornecedor
		cHoraDe		:= BusReg(aRegs2,nII,'DA0_HORADE')
		AGREGAFAT(aCab,aItems,cFilal,cCodTab,cDescr,dDataInic,cHoraDe,cHoraAte,cNomArch)
	EnDIF 
Next

DA1->(RestArea(aAreaDA1))
DA0->(RestArea(aAreaDA0))

Return .T.
/*
+===========================================================================+
|  Programa  AGREGAFAT Autor  M&H   Fecha 06/10/2022     	                |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/

STATIC FUNCTION AGREGAFAT(aCabF1,aItemsD1,cFilal,cCodTab,cDescr,dDataInic,cHoraDe,cHoraAte,cNomArch)
Local cMes		:= cValToChar( MONTH(Date()) )
Local cDia		:= cValToChar( DAY(Date())   )
Local cAnio		:= cValToChar( YEAR(Date())  )
Local ctiempo	:= StrTran(cValToChar( Time() ),":","")
Local cfechaTmp	:= cAnio+cMes+cDia+ctiempo
Local nII		:= 0
Local nIX		:= 0
Local cDA1_CODPRO	:= ""
Local cDA1_DESC	:= ""
Local cNATUREZ	:= ""
Local cYBNSER	:= ""
Local cYTPOPER	:= ""   
Local cCONDIC	:= ""
Local cCodItem	:= ""
local cNomArTmp	:= StrTran(UPPER(cNomArch),".TXT","")
Local nOpc := 4 			// alteracao
Local cCodTabSopor := ""
Local cDescr2	:= ""
Local lDocSopor := .F.
Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .f. //necessario a criacao, pois sera //atualizado quando houver	
MsProcTxt("Agregando lineas de la Lista Número: "+ cDescr+cCodTab)
//MSExecAuto({|x, y, z| MATA101N(x, y, z)}, aCabF1,aItemsD1, 3)
DbSelectArea("DA0")
DA0->( dbSetOrder( 1 ) )
cMemo:=""
If dbSeek(xFilial("DA0")+cCodTab,.T.)

	//Omsa010(aCabF1,aItemsD1,nOpc)
	cCodItem := MaxDA1(cCodTab)

	FOR nII := 1 TO LEN(aItemsD1)
	Reclock('DA1',.t.)
	DA1->DA1_FILIAL := xfilial('DA1')
	DA1->DA1_CODPRO := aItemsD1[nII][1][2]
	DA1->DA1_CODTAB := cCodTab
	DA1->DA1_PRCVEN := aItemsD1[nII][2][2]
	DA1->DA1_ATIVO 	:= aItemsD1[nII][5][2]
	DA1->DA1_TPOPER := aItemsD1[nII][6][2]
	DA1->DA1_MOEDA  := aItemsD1[nII][9][2]
	DA1->DA1_QTDLOT := 999999.99
	DA1->DA1_INDLOT := aItemsD1[nII][8][2]
	DA1->DA1_DATVIG := aCabF1[3][2]
	DA1->DA1_ITEM   := cCodItem
	DA1->(MsUnlock())
	cCodItem	:= soma1(cCodItem)
	Next nII
ELSE
	cMemo:="No se localiza La lista de prod "+cCodTab
	AXMSG("Lista: "+cCodTab+" DEscrip: "+cDescr+" Fecha inicio:"+dDataInic+" Hora Inicio:"+cHoraDe+" No fue agregado. Archivo:"+cNomArch)
		AXMSG("Detalle del Error a continuacion :---------------------------------------------------------")
		AXMSG(CRLF+cMemo)
		AXMSG("Fin del Detalle ---------------------------------------------------------------------------")
		AXMSG("-------------------------------------------------------------------------------------------")
		lOK:=.F.
ENDIF
If lMsErroAuto
	//MostraErro()
	
	MostraErro(cPathAPL,cNomArTmp+"-"+cfechaTmp+".tmp")
	cMemo:=MemoRead(cPathAPL+cNomArTmp+"-"+cfechaTmp+".tmp")
	IF !BusTexto(cPathAPL+cNomArTmp+"-"+cfechaTmp+".tmp","La serie informada demandará el mantenimiento en el Libro fiscal.")
		//RollBackSX8()
		DisarmTransaction()
		AXMSG("Documento:"+cCodTab+" Serie:"+cDescr+" Proveedor:"+dDataInic+" Tienda:"+cHoraDe+" No fue agregado. Archivo:"+cNomArch)
		AXMSG("Detalle del Error a continuacion :---------------------------------------------------------")
		AXMSG(CRLF+cMemo)
		AXMSG("Fin del Detalle ---------------------------------------------------------------------------")
		AXMSG("-------------------------------------------------------------------------------------------")
		lOK:=.F.
	EndIF
	If FERASE(cPathAPL+cNomArTmp+"-"+cfechaTmp+".tmp") == -1
		MsgStop('No se pudo borrar archivo temporal: '+cPathAPL+cNomArTmp+"-"+cfechaTmp+".tmp")
	Endif

	
EndIf
Return .T.

/*
+===========================================================================+
|  Programa  AXMSG Autor  M&H   Fecha 06/10/2022         		            |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/
STATIC FUNCTION AXMSG(cMSG)
	LOCAL cLogMs	:= ""
	cLogMs := cValToChar( Date() )+" - " +cValToChar( Time() )+ " " + cMSG
	conout( cLogMs )
	aadd(aLogComp,cLogMs)
return NIL

/*
+===========================================================================+
|  Programa  Grabamsg Autor  M&H   Fecha 06/10/2022      	                |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/
STATIC FUNCTION Grabamsg(cNomArch,aLogComp)
    Local nHandle
    Local cMes		:= cValToChar( MONTH(Date()) )
    Local cDia		:= cValToChar( DAY(Date())   )
    Local cAnio		:= cValToChar( YEAR(Date())  )
    Local ctiempo	:= StrTran(cValToChar( Time() ),":","")
    Local cfecha	:= cAnio+cMes+cDia+ctiempo
    Local nII		:= 0
    Local cNombArh	:= StrTran(UPPER(cNomArch),".TXT","")
    nHandle 	:= FCREATE(cPathAPL+cNombArh+'.LOG')
    if nHandle = -1
        AXMSG("Error al crear archivo en: "+cPathAPL+cNombArh+cfecha+".LOG"+"-> ferror: " + Str(Ferror()))
        MsgStop("Error al crear archivo en: "+cPathAPL+cNombArh+cfecha+".LOG"+"-> ferror: " + Str(Ferror()))
    else
    	FOR nII:=1 TO LEN(aLogComp)
    		FWrite(nHandle, aLogComp[nII] + CRLF)
        NEXT
        FClose(nHandle)
    endif
    CpyT2S(cPathArq+cNombArh+cfecha+".LOG", cPathLog)
Return NIL
/*
+===========================================================================+
|  Programa  BusTexto Autor  M&H   Fecha 06/10/2022      	                |
|                                                                           |
|  Uso       |                                                              |
+===========================================================================+
*/
Static Function BusTexto(cNombArh,cTexto)
Local nHandle
Local lEncontro := .F.
  nHandle := FT_FUse(cNombArh)
  if nHandle = -1
    return
  endif
  FT_FGoTop()
  While !FT_FEOF()
    cLine  := FT_FReadLn()
    IF ALLTRIM(cLine) == cTexto
    	lEncontro := .T.
    EndIf
    FT_FSKIP()
  End
  FT_FUSE()
return lEncontro
