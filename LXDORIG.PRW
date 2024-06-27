//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[24]%%%%%%//
//Programa: LXDORIG     ||Data: 08/11/2022 ||Empresa: Progen        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: M&H		                                                //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Modulo: Facturacion                                                 //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descripcion: Punto de entrada validar RD DEVOLUCION de VTA          //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*/{Protheus.doc} LXDORIG
description cambiar campos en la Nota Credito Moneda y descripcion 
@type function
@version 
@author M&H
@since 28/4/2023
@Ajuste descripcion producto dev.remision 17/06/2023 Felipe Gonzalez
@return return_type, return_description
/*/

User Function LXDORIG()
Local aArea    	:= GetArea()
Local aAreaSF2 	:= SF2->(GetArea())
Local aAreaSF1 	:= SF1->(GetArea())
Local aAreaSD2 	:= SD2->(GetArea())
Local aAreaSD1 	:= SD1->(GetArea())
Local nLenAcols	    := Len(aCols)
Local nPosxDescri	:= aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_XDESCRI"	})
Local nPosCod  	    := aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_COD"	})
Local nPosLocal     := aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_LOCAL"	})
Local nPosTes       := aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_TES"	})

Local nPosSer	:= GdFieldPos( "D1_SERIORI", aHeader )
Local nPosDoc  	:= GdFieldPos( "D1_NFORI", aHeader )
Local nPosCli  	:= GdFieldPos( "D1_FORNECE", aHeader )
Local nPosLoj  	:= GdFieldPos( "D1_LOJA", aHeader )
Local nPoCod   	:= GdFieldPos( "D1_COD", aHeader )
Local nPosIt   	:= GdFieldPos( "D1_ITEMORI", aHeader)

Local cCliFor  	:= aCols[n,nPosCli]
Local cLoja    	:= aCols[n,nPosLoj]
Local nMoneda  	:= ""
Local cNaturez  := ""
Local nRegSD1     := SD1->(RECNO()) //Variable para posicionarse en el registro de la SD1 F.GONZALEZ
Local nLenAcolsd  := Len(aCols)

If nPosCod > 0
  	cProduto	:= aCols[nLenAcols][nPosCod]
   	  If nPosxDescri > 0
	  	aCols[nLenAcols][nPosxDescri]	:= Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_DESC")
   	  Endif

    IF ALLTRIM(M->F1_XLOCDEV) == "1" .and. FUNNAME() == "MATA462DN"  // Solo par el remito de devolucion
        aCols[nLenAcols][nPosLocal] := ALLTRIM(GETNEWPAR("MV_LOCDEV","95"))
    Endif

Endif

SD1->(DbGoTo(nRegSD1))

If FUNNAME() $ "MATA462DN" .AND."RFD"$cEspecie  // solo para las Notas Credito

    //cMoneda       := POSICIONE("SF2",2,xFilial("SF2")+cCliFor+cLoja+aCols[nLenAcols,nPosDoc]+aCols[nLenAcols,nPosSer]+"N"+"NF ","F2_MOEDA")
	nMoneda       := POSICIONE("SF2",2,xFilial("SF2")+cCliFor+cLoja+aCols[nLenAcols,nPosDoc]+aCols[nLenAcols,nPosSer]+"N"+"RFN","F2_MOEDA")
    cNaturez      := POSICIONE("SF2",2,xFilial("SF2")+cCliFor+cLoja+aCols[nLenAcols,nPosDoc]+aCols[nLenAcols,nPosSer]+"N"+"RFN","F2_NATUREZ")
    nTxCambio     := POSICIONE("SM2",1,DTOS(dDatabase),"M2_MOEDA2")

    IF (nMoneda <> 1)
        M->F1_MOEDA    := nMoneda
        M->F1_TXMOEDA  := nTxCambio
    EndIf
   
    //Descripcion: Ajuste para cargue de Naturaleza desde la remision sin importar la moneda, realizando el remito de devolucion
    //Autor: Felipe Gonzalez
    //Fecha: 08/08/2023
    M->F1_NATUREZ  := cNaturez


    Dbselectarea("SB1")
    SB1->(Dbsetorder(1))
    If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))
            aCols[nLenAcolsd][aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_XDESCRI"})] := SB1->B1_DESC
    Endif

Endif

//Descripcion: Ajuste para nota credito , se obtenga la descripcion de cada producto 
//Autor: Felipe Gonzalez
//Fecha: 09/06/2023
If "NCC"$cEspecie

    Dbselectarea("SB1")
    SB1->(Dbsetorder(1))
    If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))
            aCols[nLenAcolsd][aScan(aHeader,{|x| Upper(AllTrim(x[2])) == "D1_XDESCRI"})] := SB1->B1_DESC
    Endif
    
    M->F1_MOEDA     := SF2->F2_MOEDA
    M->F1_TXMOEDA   := IIF(M->F1_MOEDA <> 1,xMoeda(1,M->F1_MOEDA,1,M->F1_EMISSAO,4),1)
    M->F1_NATUREZ   := SF2->F2_NATUREZ
    

ENDIF

Eval(bDoRefresh)
oGetDados:obrowse:refresh()

RestArea(aAreaSD2)
RestArea(aAreaSD1)
RestArea(aAreaSF2)
RestArea(aAreaSF1)
RestArea(aArea)

Return
