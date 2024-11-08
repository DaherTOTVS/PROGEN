#include "protheus.ch"
#INCLUDE "rwmake.ch"                                 
#INCLUDE "RPTDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2460I   ºAutor  Juan Pablo Astorga   ºFecha ³  26/05/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para modificar el tipo de doc gerado na facturacion     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SF2460I()
	
	Local aArea 	:= GetArea()  
	Local aAreaSF2  := SF2->( GetArea() ) 
	Local aAreaSE1  := SE1->( GetArea() ) 
	Local cPaisCl	
	       	
IF (FunName()=="MATA468N")
	dbselectarea("SE1")
	dbsetorder(2)
	If dbseek(xfilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
		cPaisCl:=Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_PAIS")  // Modificado 24.07.2024 Juan P. Astorga
		IF INCLUI .and. (POSICIONE("SF4",1,xfilial("SF4")+SD2->D2_TES,"F4_AGREG") == 'N')
				RecLock("SE1",.F.)
			if Alltrim(cPaisCl)=='169' .and. SF2->F2_MOEDA==2					// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_MOEDA 	:= 1											// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_TXMOEDA := 1											// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_VALOR :=  Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)		// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_SALDO :=  Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)		// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_VLCRUZ:=  Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)		// Modificado 24.07.2024 Juan P. Astorga
				SE1->E1_HIST  := "VALOR DOLAR " + Alltrim(Str(SF2->F2_VALBRUT)) // Modificado 24.07.2024 Juan P. Astorga
			else
				SE1->E1_VALOR :=  SF2->F2_VALBRUT
				SE1->E1_SALDO :=  SF2->F2_VALBRUT
				SE1->E1_VLCRUZ:=  SF2->F2_VALBRUT
			Endif
				SE1->E1_CCUSTO:=  Posicione("SA1",1,Xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_XCC")
				MsUnLock()
		Else
				RecLock("SE1",.F.)
				SE1->E1_XDESCFI	:= Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XDESCFI")
				SE1->E1_XDIADES	:= Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XDIADES")
				SE1->E1_CCUSTO	:= Posicione("SA1",1,Xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_XCC")
				SE1->E1_VALIMP1 := SF2->F2_VALIMP1
				SE1->E1_VALIMP2 := SF2->F2_VALIMP2
				SE1->E1_XVALBRU := SF2->F2_VALBRUT + SF2->F2_VALIMP2
				if Alltrim(cPaisCl)=='169' .and. SF2->F2_MOEDA==2						// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_MOEDA 	:= 1												// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_TXMOEDA := 1												// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_VALOR 	:= Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)			// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_SALDO 	:= Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)			// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_VLCRUZ	:= Round(SF2->F2_VALBRUT*SF2->F2_TXMOEDA,2)			// Modificado 24.07.2024 Juan P. Astorga
					SE1->E1_HIST  	:= "VALOR DOLAR " + Alltrim(Str(SF2->F2_VALBRUT)) 	// Modificado 24.07.2024 Juan P. Astorga
				EndIf
				MsUnLock()
		EndIF
	EndIF		

	RestArea( aAreaSE1)  
	RestArea( aAreaSF2)
	RestArea( aArea )

EndIF
		

Return .T.

