#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
// desarrollo de Axel Diaz
// Este fuente busca la TRM (Tasa de Cambio de USD vs COP) tasa de cambio colombia Dolares
// Funcion para colocar en el APPSERVER como un servicio.
// fUNCION	

USER Function TRMCOL()
	// Local cquery		:= ""
	Local cTrmhoy		:= ""
	Local cfecha		:= ""
	Local cEmp      	:= "01"  		//codigo da empresa
	Local cFil      	:= "01"  			//codigo da filial
    Local lEncont       := .F.
    Local nTRM          := 0
	Private cRutEje		:= "TRMCOL"
	

	RPCSetType(3)  						//Nao consome licensas

//	RpcSetEnv(cEmp,cFil,"ADMIN","totvs@123",,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas
	RpcSetEnv(cEmp,cFil,"webservices","XQY8ZIAW",,GetEnvServer(),{ })

	cfecha 		:= dtos(ddatabase)

	IF POSICIONE("CTO",1,XFILIAL("CTO")+'02',"CTO_MOEDA")=='02'
		dbSelectArea( "CTP" )
		// dbSetOrder(1)							//ANTES
		// MSSEEK(XFILIAL("CTP")+cfecha+'02')		//ANTES	
		CTP->(DbSetOrder(1))						//DESPUES
		CTP->(MsSeek(xFilial("CTP")+cfecha+'02'))	//DESPUES

		lEncont:=Found()
		conout(Alltrim(FunName()))
        cTrmhoy		:= alltrim(StrTran( U_TRMCOP(cfecha), "\n\t\n", "" ))
		if !lEncont
			RecLock("CTP",.T.)
			CTP->CTP_FILIAL 	:= XFILIAL("CTP")
			CTP->CTP_DATA 	:= ddatabase
			CTP->CTP_MOEDA  := '02'
			CTP->CTP_TAXA	:= VAL(ctrmhoy)
			CTP->CTP_BLOQ	:= '2'
			MsUnlock()
		ElseIF 	CTP->CTP_TAXA==0
			RecLock("CTP",.F.)
			CTP->CTP_FILIAL := XFILIAL("CTP")
			CTP->CTP_DATA 	:= ddatabase
			CTP->CTP_MOEDA  := '02'
			CTP->CTP_TAXA	:= VAL(ctrmhoy)
			CTP->CTP_BLOQ	:= '2'
			MsUnlock()
		endif
	ENDIF

	dbSelectArea('SM2')
	SM2->(DbSetOrder(1))
	SM2->(MsSeek(cfecha))

    lEncont:=Found()
    nTRM:=SM2->M2_MOEDA2
	
	If !lEncont .OR. nTRM==0
		conout(Alltrim(FunName()))
		cTrmhoy		:= alltrim(StrTran( U_TRMCOP(cfecha), "\n\t\n", "" ))
		if (!(empty(cTrmhoy)))
                if !lEncont
                    RecLock("SM2",.T.)
                    SM2->M2_DATA 	:= ddatabase
                    SM2->M2_MOEDA2  := VAL(ctrmhoy)
                    //SM2->M2_MOEDA3 	:= 0
                    //SM2->M2_MOEDA4 	:= 0
                    //SM2->M2_MOEDA5 	:= 0
                    //SM2->M2_INFORM	:= "S"
                    MsUnlock()
                else
                    RecLock("SM2",.F.)
                    //SM2->M2_DATA 	:= ddatabase
                    SM2->M2_MOEDA2  := VAL(ctrmhoy)
                    //SM2->M2_MOEDA3 	:= 0
                    //SM2->M2_MOEDA4 	:= 0
                    //SM2->M2_MOEDA5 	:= 0
                    //SM2->M2_INFORM	:= "S"
                EndIf
                MsUnlock()
		else
			conout("No se pudo obtener la tasa del:"+cValToChar(ddatabase)+". Favor revise la conexión")
		ENDIF
	ENDIF
		conout(	"llamada desde TRM-RUTINE ->Fecha     - "+ dToC(dDataBase) + "Hora      - "+ Time() +" ENTRADO en CBCGMES1")
		//U_CBCGMES1(.T.)
		conout(	"llamada desde TRM-RUTINE ->Fecha     - "+ dToC(dDataBase) + "Hora      - "+ Time() +" SALIENDO en CBCGMES1")
	RpcClearEnv()   //Libera o Ambiente
return .t.

// Funcion que puede ser agregada al Menu de Protheus para bucar la TRM de Hoy y agregarla a SM2
USER Function TRMMENU()
	Local cTrmhoy		:= ""
	Local cfecha		:= ""
    Local lEncont       := .F.
    Local nTRM          := 0
	Private cRutEje		:= "TRMMENU"
	
	cfecha 		:= dtos(ddatabase)
	
	IF POSICIONE("CTO",1,XFILIAL("CTO")+'02',"CTO_MOEDA")=='02'
		dbSelectArea( "CTP" )
		CTP->(DbSetOrder(1))
		CTP->(MsSeek(xFilial("CTP")+cfecha+'02'))
		
		lEncont:=Found()
		conout(Alltrim(FunName()))
        cTrmhoy		:= alltrim(StrTran( U_TRMCOP(cfecha), "\n\t\n", "" ))
		if !lEncont
			RecLock("CTP",.T.)
			CTP->CTP_FILIAL 	:= XFILIAL("CTP")
			CTP->CTP_DATA 	:= ddatabase
			CTP->CTP_MOEDA  := '02'
			CTP->CTP_TAXA	:= VAL(ctrmhoy)
			CTP->CTP_BLOQ	:= '2'
			MsUnlock()
		ElseIF 	CTP->CTP_TAXA==0
			RecLock("CTP",.F.)
			CTP->CTP_FILIAL := XFILIAL("CTP")
			CTP->CTP_DATA 	:= ddatabase
			CTP->CTP_MOEDA  := '02'
			CTP->CTP_TAXA	:= VAL(ctrmhoy)
			CTP->CTP_BLOQ	:= '2'
			MsUnlock()
		endif
	ENDIF
	

	dbSelectArea('SM2')
	
    IF !(ddatabase>date())
        MSSeek(cfecha)
        lEncont:=Found()
        nTRM:=SM2->M2_MOEDA2
        If lEncont .AND. nTRM >0
            msgalert("LA TRM está ya actualizada a la fecha " +cValToChar(SM2->M2_DATA)+ ":" + cValToChar(SM2->M2_MOEDA2),"Actualizacion TRM" )
        ELSE
            conout(Alltrim(FunName()))
            cTrmhoy		:= alltrim(StrTran( U_TRMCOP(cfecha), "\n\t\n", "" ))
            if (!(empty(cTrmhoy)))
                if MSGYESNO( "Se actualizará "+cValToChar(ddatabase)+" "+cTrmhoy, "Actualizacion TRM" )
                    if !lEncont
                        RecLock("SM2",.T.)
                        SM2->M2_DATA 	:= ddatabase
                        SM2->M2_MOEDA2  := VAL(ctrmhoy)
                        //SM2->M2_MOEDA3 	:= 0
                        //SM2->M2_MOEDA4 	:= 0
                        //SM2->M2_MOEDA5 	:= 0
                        //SM2->M2_INFORM	:= "S"
                        MsUnlock()
                    else
                        RecLock("SM2",.F.)
                        //SM2->M2_DATA 	:= ddatabase
                        SM2->M2_MOEDA2  := VAL(ctrmhoy)
                        //SM2->M2_MOEDA3 	:= 0
                        //SM2->M2_MOEDA4 	:= 0
                        //SM2->M2_MOEDA5 	:= 0
                        //SM2->M2_INFORM	:= "S"
                    EndIf
                    MsUnlock()
                endif
            else
                conout("No se pudo obtener la tasa del:"+cValToChar(ddatabase)+". Favor revise la conexión")
                msgAlert("No se pudo obtener la tasa del:"+cValToChar(ddatabase)+". Favor revise la conexión","Actualizacion TRM" )
            ENDIF
        ENDIF
    Else
        msgAlert("La fecha de ingreso al sistema es superior a la fecha real","Actualizacion TRM NEGADA" )
    EndIf

return .t.



// funcion que busca via Ws la trm del días
// desarrollado Axel Diaz

User Function TRMCOP(cFechaS)
	Local oWsdl
	Local xRet
	Local cMsg	:= ""
	Local cfecha:= ""
	Local cvalor:= ""

	cfecha := cFechaS
    cfecha := substr(cfecha,1,4)+"-"+substr(cfecha,5,2)+"-"+substr(cfecha,7,2)

	cMsg := '<?xml version="1.0" encoding="UTF-8"?>'
	cMsg += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '
	cMsg += 'xmlns:ns1="http://action.trm.services.generic.action.superfinanciera.nexura.sc.com.co/">'
	cMsg += '<SOAP-ENV:Body>'
	cMsg += '<ns1:queryTCRM>'
	cMsg += '<tcrmQueryAssociatedDate>'
	cMsg += cfecha
	cMsg += '</tcrmQueryAssociatedDate>'
	cMsg += '</ns1:queryTCRM>'
	cMsg += '</SOAP-ENV:Body>'
	cMsg += '</SOAP-ENV:Envelope>'


	oWsdl:= TWsdlManager():New()
	// oWsdl:lVerbose := .T.
	oWsdl:lSSLInsecure := .T.


	xRet := oWsdl:ParseURL( "https://www.superfinanciera.gov.co/SuperfinancieraWebServiceTRM/TCRMServicesWebService/TCRMServicesWebService?wsdl" )
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return ""
	endif

	xRet := oWsdl:SetOperation( "queryTCRM" )
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return ""
	endif


	xRet := oWsdl:SetValue( 0, "2018-07-08" )
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return ""
	endif

	//conout( oWsdl:GetSoapMsg() )


	oWsdl:cLocation := "https://www.superfinanciera.gov.co/SuperfinancieraWebServiceTRM/TCRMServicesWebService/TCRMServicesWebService"

	// Envia uma mensagem SOAP personalizada ao servidor
	// conout( oWsdl:GetSoapMsg() )
	xRet := oWsdl:SendSoapMsg( cMsg )
	if xRet == .F.
		conout( "Erro: " + oWsdl:cError )
		Return ""
	endif

	//conout( oWsdl:GetSoapResponse() )
	cvalor:=oWsdl:GetParsedResponse()
	cvalor:=alltrim(substr(cvalor,AT("value:",cvalor)+6,15))
    conout("TRM->"+cvalor)
Return cvalor

