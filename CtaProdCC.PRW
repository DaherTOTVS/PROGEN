#Include "Protheus.ch"
#Include "TopConn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtaProdC    ºAutor  ³Microsiga           º Data ³  11/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene la cuenta contable del producto de acuerdo         º±±
±±º          ³ al centro de costos informado en el detalle del documento  º±±
±±º          ³ de compra/devolucion en compra.              		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CtaProdCC(ccCostos,cCodPro,cBodega)

Local cCuenta:= ""
Local aArea  := GetArea()
Local TES	 := SD1->D1_TES

	DBSelectArea("SB1")
	DBSetOrder(1)
    DBSeek(xFilial("SB1")+cCodPro)  
 	

   	DBSelectArea("CTT")
   	DBSetOrder(1)
  	DBSeek(xFilial("CTT")+ccCostos)
    CtpGto:=CTT->CTT_XTPCC     

IF Posicione("SF4",1,xFilial("SF4")+TES,"F4_ESTOQUE")=='N' .AND. Posicione("SF4",1,xFilial("SF4")+TES,"F4_ATUATF")=='N' 

		IF '51'$CtpGto //Costos de operaciones de administración o compras generales
			cCuenta:= SB1->B1_XGTADM
		ELSEIF '52'$CtpGto //Costos de operaciones comerciales     
			cCuenta:= SB1->B1_XGTCOM
		ELSEIF '73'$CtpGto //Costos de operaciones operativos      
			cCuenta:= SB1->B1_XGTOPE
		ELSEIF '55'$CtpGto //Costos asociados a innovacion
			cCuenta:= SB1->B1_XGTINN
		ELSEIF '15'$CtpGto //Costos asociados a activos en curso
			cCuenta:= SB1->B1_XGTATF
		ELSEIF '17'$CtpGto //Costos asociados a proyectos
			cCuenta:= SB1->B1_XGTPRY
		ENDIF
else
			cCuenta := SB1->B1_CONTA
EndIf

RestArea(aArea)

Return(cCuenta)
