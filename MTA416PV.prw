#include 'Protheus.ch'
#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA416PV  ºAutor  ³Felipe Gonzalez º Data ³  13/07/2023     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona campos que el estandar no lleva cuando el         º±±
±±º          ³ presupuesto se convierte en PV                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA416PV()

	Local nAux			:= PARAMIXB
	Local nPosCusto	:= aScan(_aHeader,{|x| AllTrim(x[2])=="C6_CC" 	   })    // Juan Pablo 14.02.2024
	Local nPosItemC	:= aScan(_aHeader,{|x| AllTrim(x[2])=="C6_ITEMCTA" })    // Juan Pablo 14.02.2024
	
    M->C5_XNOME		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME")
	M->C5_XNCLIEN	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENT+M->C5_LOJAENT,"A1_NOME")   
	M->C5_XEMAIL	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EMAIL")
	// M->C5_XENDENT 	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ENDENT") // Javier Rocha 16.02.2024
	// M->C5_XEST		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XESTENT") // Javier Rocha 19.02.2024
	// M->C5_XCOD_MU	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XCDMUEN") // Javier Rocha 19.02.2024
	// M->C5_XESTNOM	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ESTACLI") // Javier Rocha 19.02.2024
	// M->C5_XMUN   	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XMUNENT") // Javier Rocha 19.02.2024
	M->C5_XENDENT 	:= SCJ->CJ_XENDEN  // Duvan Hernandez 05.04.2024
	M->C5_XEST		:= SCJ->CJ_XESTDEP  // Duvan Hernandez 05.04.2024
	M->C5_XCOD_MU	:= SCJ->CJ_XCODMUN  // Duvan Hernandez 05.04.2024
	M->C5_XESTNOM	:= Posicione('SX5',1,xFilial('SX5')+"12"+SCJ->CJ_XESTDEP,'X5DESCRI()') // Duvan Hernandez 05.04.2024
	M->C5_XMUN   	:= POSICIONE("CC2",1,xfilial("CC2")+SCJ->CJ_XESTDEP+SCJ->CJ_XCODMUN,"CC2_MUN") // Duvan Hernandez 05.04.2024


	//Felipe Gonzalez 20/09/2023 Adicion para agregar modalidad
	M->C5_NATUREZ	:= SCJ->CJ_XNATURE
	// _aCols[nAux][nPosCusto] := SCK->CK_XCUSTO 	 // Juan Pablo 14.02.2024
	// _aCols[nAux][nPosItemC] := SCK->CK_XITEMC    // Juan Pablo 14.02.2024
	//("SFP")->(DBCloseArea())	

Return Nil
