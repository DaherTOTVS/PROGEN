#Include "Protheus.ch"
#Include "TopConn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtaOrdPrCC  ºAutor  ³Microsiga           º Data ³  11/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene la cuenta contable del producto de acuerdo         º±±
±±º          ³ al centro de costos informado en el detalle del documento  º±±
±±º          ³ del Modulo Producción.                        		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CtaOrdPrCC(ccCostos,cCodPro,cBodega)

Local cCuenta:= ""
Local aArea  := GetArea()
Local TM	 := SD3->D3_TM

DBSelectArea("SB1")
DBSetOrder(1)
DBSeek(xFilial("SB1")+cCodPro)  
 	
DBSelectArea("CTT")
DBSetOrder(1)
DBSeek(xFilial("CTT")+ccCostos)
CtpGto:=CTT->CTT_XTPCC     

IF Alltrim(TM)$'001/501/003/503'	// //IF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'001/501/003/503'
    cCuenta := GETMV("MV_XVARI1")
ElseIf Alltrim(TM)$'012/510'
	cCuenta := GETMV("MV_XVARI2")
Elseif Alltrim(TM)$'603/033'		// Modificado 06.03.2024 por Indicacion de Daniel , Juan Pablo A.
	cCuenta := GETMV("MV_XVARI3") 	// Modificado 06.03.2024 por Indicacion de Daniel , Juan Pablo A.
ElseIf Alltrim(TM)$'035/605'
	cCuenta := GETMV("MV_XVARI4")
ElseIF Alltrim(TM)$'601/031/607/609/611/037/038/039'  // Se agrego el 603/033 que estaba en la seccion 033 , Modificado 06.03.2024 Indicacion de Daniel,Juan Pablo A.
		IF CtpGto=='51' //Costos de operaciones de administración o compras generales
			cCuenta:= SB1->B1_XGTADM
		ElseIf CtpGto=='52' //Costos de operaciones comerciales     
			cCuenta:= SB1->B1_XGTCOM
		ElseIf CtpGto=='73' //Costos de operaciones operativos      
			cCuenta:= SB1->B1_XGTOPE
		ElseIf CtpGto=='55' //Costos asociados a innovacion
			cCuenta:= SB1->B1_XGTINN
		ElseIf CtpGto=='15' //Costos asociados a activos en curso
			cCuenta:= SB1->B1_XGTATF
		ELSEIF CtpGto=='17' //Costos asociados a proyectos
			cCuenta:= SB1->B1_XGTPRY
		ENDIF
ELSE
			cCuenta := SB1->B1_XCUSGAS
EndIf

RestArea(aArea)

Return(cCuenta)
