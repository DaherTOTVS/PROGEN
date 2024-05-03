#Include "Totvs.Ch"

/*/{Protheus.doc} MA650TOK
VALIDA EL SALDOS DE LA ESTRCUTURA DE PRODUCTO DE LA ORDENE DE PRODUCTION
@type       function
@version    001
@author     Larson Zordan
@since      11/04/2022
@return     logical, .T. Hay Saldo Disponible  .F. No Hay Saldo Disponible
/*/

User Function MA650TOK()

Local oDlg
Local oLbx1
Local oLbx2
Local oVerd	   := LoadBitmap( GetResources(), "ENABLE"  )
Local oVerm	   := LoadBitmap( GetResources(), "DISABLE" )
Local oAzul	   := LoadBitmap( GetResources(), "BR_AZUL" )

Local aAreaAnt := GetArea()
Local aSaldos  := {}
Local aSldPrd  := {}
Local aSG1     := {}
Local cCadAnt  := cCadastro
Local nTamPrd  := Len(SG1->G1_COD)+Len(SG1->G1_COMP)
Local nBase    := 0         // Modificado Juan Pablo 07.03.2024
Local aRetorOpc:= {}        // Juan Pablo 31.03.2023
Local lRet     := .T.
Local nX

SG1->(dbSetOrder(6))        // Juan Pablo 31.03.2023     
//SG1->(dbSetOrder(1))
If SG1->(MsSeek(FWxFilial("SG1")+M->C2_PRODUTO+M->C2_REVISAO))
    While !SG1->(Eof()) .And. FWxFilial("SG1")+M->C2_PRODUTO+M->C2_REVISAO == SG1->(G1_FILIAL+G1_COD+G1_REVINI)
        // Modificado Juan Pablo 07.03.2024
        if Posicione("SB1",1,xFilial("SB1")+M->C2_PRODUTO,"B1_QB") = 0
            nBase   := 1
        Else
            nBase   := Posicione("SB1",1,xFilial("SB1")+M->C2_PRODUTO,"B1_QB")
        EndIf
        // Modificado Juan Pablo 07.03.2024
        If Left(SG1->G1_COMP,3) <> "MOD"
            SB1->(dbSeek(FWxFilial("SB1")+SG1->G1_COMP))
            If Empty(SG1->G1_GROPC)
               aAdd( aSG1, { 1, SG1->G1_COMP, AllTrim(SB1->B1_DESC),SB1->B1_UM,If(!Empty(SG1->G1_XBODEGA),SG1->G1_XBODEGA,SB1->B1_LOCPAD), (SG1->G1_QUANT/nBase)*M->C2_QUANT, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
                // aAdd( aSG1, { 1, SG1->G1_COMP, AllTrim(SB1->B1_DESC), SB1->B1_UM, SG1->G1_LOCCONS, (M->C2_QUANT*SG1->G1_QUANT), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
            Else
                If aScan( aRetorOpc , { |x| Left(x[1],nTamPrd) == M->C2_PRODUTO+SG1->G1_COMP }) > 0
                 aAdd( aSG1, { 1, SG1->G1_COMP, AllTrim(SB1->B1_DESC), SB1->B1_UM, If(!Empty(SG1->G1_XBODEGA),SG1->G1_XBODEGA,SB1->B1_LOCPAD), (SG1->G1_QUANT/nBase)*M->C2_QUANT, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
                // aAdd( aSG1, { 1, SG1->G1_COMP, AllTrim(SB1->B1_DESC), SB1->B1_UM, SG1->G1_LOCCONS, (M->C2_QUANT*SG1->G1_QUANT), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
                Else
                aAdd( aSG1, {  3, SG1->G1_COMP, AllTrim(SB1->B1_DESC), SB1->B1_UM, If(!Empty(SG1->G1_XBODEGA),SG1->G1_XBODEGA,SB1->B1_LOCPAD), (SG1->G1_QUANT/nBase)*M->C2_QUANT, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
                // aAdd( aSG1, { 3, SG1->G1_COMP, AllTrim(SB1->B1_DESC), SB1->B1_UM, SG1->G1_LOCCONS, (M->C2_QUANT*SG1->G1_QUANT), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }  )
                EndIf
            EndIf    
        EndIf
        SG1->(dbSkip())
    EndDo
//EndIf

If Len(aSG1) > 0
    For nX := 1 To Len(aSG1)
        // mv_par02 - Considera saldo apenas Local Padrao ? 1-sim  2-nao   
        If  aSav650[02] == 1   // Modificado 30.04.2024 Juan Pablo Astorga - mv_par02 == 1
            nSaldo := RetSaldo(aSG1[nX,2],M->C2_LOCAL,M->C2_LOCAL,@aSG1[nX],@aSaldos)
        Else
	        // mv_par03 - Almoxarifado De (Usado p/compor o estoque atual)
	        // mv_par04 - Almoxarifado Ate 
            nSaldo := RetSaldo(aSG1[nX,2],aSav650[03],aSav650[04],@aSG1[nX],@aSaldos)  // Modificado 30.04.2024 Juan Pablo Astorga - nSaldo := RetSaldo(aSG1[nX,2],mv_par03,mv_par04,@aSG1[nX],@aSaldos)
        EndIf
        If aScan( aRetorOpc , { |x| Left(x[1],nTamPrd) == M->C2_PRODUTO+aSG1[nX,2] }) > 0
            aSG1[nX,1] := If(nSaldo >= aSG1[nX,6], 1, 2)
            If lRet .And. nSaldo < aSG1[nX,6]
                lRet := .F.
            EndIf
        Else
            aSG1[nX,1] := If(nSaldo >= aSG1[nX,6], 1, 2)
        EndIf

    Next nX
EndIf

If lRet
    // Carrega a ListBox 2 com os saldos do primeiro produto posicionado
    For nX := 1 To Len(aSaldos)
        If aSaldos[nX,1] == aSG1[1,2]
            aAdd( aSldPrd , aSaldos[nX] )
        EndIf
    Next nX
    If Len(aSldPrd) == 0
        aAdd( aSldPrd, { " ", " ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
    EndIf

    cCadastro := "Saldos Indisponible"
    Define MsDialog oDlg Title cCadastro Pixel From 0,0 To 500,1000

	@  33,1  ListBox oLbx1 Fields Header "",SG1->(RetTiTle("G1_COMP")),SB1->(RetTitle("B1_DESC")),SB1->(RetTitle("B1_UM")), SG1->(RetTitle("G1_LOCCONS")) ,"Qtd. OP","Sld Dispon.", SB2->(RetTitle("B2_QATU")) ,SB2->(RetTitle("B2_RESERVA")),;
    SB2->(RetTitle("B2_QEMP")),SB2->(RetTitle("B2_QACLASS")),SB2->(RetTitle("B2_QEMPSA")),SB2->(RetTitle("B2_QEMPPRJ")),SB2->(RetTitle("B2_SALPEDI")),SB2->(RetTitle("B2_QTNP")),SB2->(RetTitle("B2_QNPT")),SB2->(RetTitle("B2_QEMPPRE")) ;
    Size 500,100 Of oDlg Pixel 

    oLbx1:SetArray(aSG1)
	oLbx1:aColSizes := { 5,15,40,5,10,10,10,10,10,10,10,10,10,10,10,10 }
    oLbx1:bChange   := { || RetArmaz(aSG1[oLbx1:nAt,02],aSaldos,@oLbx2,aSG1[oLbx1:nAt,05])  }
	oLbx1:bLine     := { || {	If(aSG1[oLbx1:nAt,01]==1,oVerd,If(aSG1[oLbx1:nAt,01]==2,oVerm,oAzul))    ,;
                                aSG1[oLbx1:nAt,02]										        ,;
                                aSG1[oLbx1:nAt,03]												,;
                                aSG1[oLbx1:nAt,04]												,;
                                aSG1[oLbx1:nAt,05]												,;
                                Transform( aSG1[oLbx1:nAt,06],AllTrim(X3Picture("B2_QATU")) )	,;
                                Transform( Posicione("SB2",1,xFilial("SB2")+aSG1[oLbx1:nAt,02]+aSG1[oLbx1:nAt,05],"B2_QATU")-Posicione("SB2",1,xFilial("SB2")+aSG1[oLbx1:nAt,02]+aSG1[oLbx1:nAt,05],"B2_QEMP"),AllTrim(X3Picture("B2_QATU")) )	,;  // 2 Juan Pablo Astorga 31.03.2023 - B2_FILIAL+B2_COD+B2_LOCAL                                                                                                                                       
                                Transform( Posicione("SB2",1,xFilial("SB2")+aSG1[oLbx1:nAt,02]+aSG1[oLbx1:nAt,05],"B2_QATU"),AllTrim(X3Picture("B2_QATU")) )	,;  // 3 Juan Pablo Astorga 31.03.2023 - B2_FILIAL+B2_COD+B2_LOCAL                                                                                                                                       
                                Transform( Posicione("SB2",1,xFilial("SB2")+aSG1[oLbx1:nAt,02]+aSG1[oLbx1:nAt,05],"B2_RESERVA"),AllTrim(X3Picture("B2_RESERVA")))	,;  // 4 Juan Pablo Astorga 31.03.2023 - B2_FILIAL+B2_COD+B2_LOCAL                                                                                                                                       
                                Transform( Posicione("SB2",1,xFilial("SB2")+aSG1[oLbx1:nAt,02]+aSG1[oLbx1:nAt,05],"B2_QEMP"),AllTrim(X3Picture("B2_QEMP")) )   ,;          // Juan Pablo Astorga 03.04.2023
                                Transform( aSG1[oLbx1:nAt,10],AllTrim(X3Picture("B2_QACLASS")))	,;
                                Transform( aSG1[oLbx1:nAt,11],AllTrim(X3Picture("B2_QEMPSA")) )	,;
                                Transform( aSG1[oLbx1:nAt,12],AllTrim(X3Picture("B2_QEMPPRJ")))	,;
                                Transform( aSG1[oLbx1:nAt,13],AllTrim(X3Picture("B2_SALPEDI")))	,;
                                Transform( aSG1[oLbx1:nAt,14],AllTrim(X3Picture("B2_QTNP")) )	,;
                                Transform( aSG1[oLbx1:nAt,15],AllTrim(X3Picture("B2_QNPT")) )	,;
                                Transform( aSG1[oLbx1:nAt,16],AllTrim(X3Picture("B2_QEMPPRE")))	}}
                                //  Transform( aSG1[oLbx1:nAt,07],AllTrim(X3Picture("B2_QATU")) )	,; // 2
                                //  Transform( aSG1[oLbx1:nAt,17],AllTrim(X3Picture("B2_QATU")) )	,; // 3
                                //  Transform( aSG1[oLbx1:nAt,08],AllTrim(X3Picture("B2_RESERVA")))	,; // 4
                                //  Transform( aSG1[oLbx1:nAt,09],AllTrim(X3Picture("B2_QEMP")) )   ,; // 5

	@  140,1  ListBox oLbx2 Fields Header SB2->(RetTitle("B2_LOCAL")), "Sld Dispon.",SB2->(RetTitle("B2_QATU")),SB2->(RetTitle("B2_RESERVA")),;
    SB2->(RetTitle("B2_QEMP")),SB2->(RetTitle("B2_QACLASS")),SB2->(RetTitle("B2_QEMPSA")),SB2->(RetTitle("B2_QEMPPRJ")),SB2->(RetTitle("B2_SALPEDI")),SB2->(RetTitle("B2_QTNP")),SB2->(RetTitle("B2_QNPT")),SB2->(RetTitle("B2_QEMPPRE")) ;
    Size 500,100 Of oDlg Pixel 

    oLbx2:SetArray(aSldPrd)
	oLbx2:aColSizes := { 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15 }
	oLbx2:bLine   := { || {	aSldPrd[oLbx2:nAt,02]										        ,;
                            Transform( aSldPrd[oLbx2:nAt,13],AllTrim(X3Picture("B2_QATU")) )	,;
							Transform( aSldPrd[oLbx2:nAt,03],AllTrim(X3Picture("B2_QATU")) )	,;
							Transform( aSldPrd[oLbx2:nAt,04],AllTrim(X3Picture("B2_RESERVA")))	,;
							Transform( aSldPrd[oLbx2:nAt,05],AllTrim(X3Picture("B2_QEMP")) )    ,;
							Transform( aSldPrd[oLbx2:nAt,06],AllTrim(X3Picture("B2_QACLASS")))	,;
							Transform( aSldPrd[oLbx2:nAt,07],AllTrim(X3Picture("B2_QEMPSA")) )	,;
							Transform( aSldPrd[oLbx2:nAt,08],AllTrim(X3Picture("B2_QEMPPRJ")))	,;
							Transform( aSldPrd[oLbx2:nAt,09],AllTrim(X3Picture("B2_SALPEDI")))	,;
							Transform( aSldPrd[oLbx2:nAt,10],AllTrim(X3Picture("B2_QTNP")) )	,;
							Transform( aSldPrd[oLbx2:nAt,11],AllTrim(X3Picture("B2_QNPT")) )	,;
							Transform( aSldPrd[oLbx2:nAt,12],AllTrim(X3Picture("B2_QEMPPRE")))	}}

    Activate MsDialog oDlg Center On Init EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

    lRet := FWAlertNoYes("¿Desea generar la orden de producción de todos modos?","Aviso")
  EndIf
EndIf

cCadastro := cCadAnt
RestArea(aAreaAnt)
Return(lRet)

/*/{Protheus.doc} RetArmaz
CARREGA OS ARMAZENS DE CADA PRODUTO POSICIONADO
@type       function
@version    001
@author     Larson zordan
@since      12/04/2022
@param      cProduto, character, Produto
@param      aSaldos, array, Saldos
@param      oLbx2, object, Objeto da Listbox dos Saldos (Por Referencia)
@return     variant, sem retorno
/*/
Static Function RetArmaz(cProduto,aSaldos,oLbx2,cLocal)   
Local aSldPrd := {}
Local nX

aSldPrd := {}
For nX := 1 To Len(aSaldos)
    If aSav650[02] == 1  // Juan Pablo Astorga modificado 30.04.2024 mv_par02 == 1
        If aSaldos[nX,1]+aSaldos[nX,2] == cProduto+cLocal
            aAdd( aSldPrd , aSaldos[nX] )
        EndIf
    Else  
        If aSaldos[nX,1] == cProduto
            aAdd( aSldPrd , aSaldos[nX] )
        EndIf
    EndIf
Next nX

If Len(aSldPrd) == 0
    aAdd( aSldPrd, { " ", " ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
EndIf

oLbx2:SetArray(aSldPrd)
oLbx2:bLine   := { || {	aSldPrd[oLbx2:nAt,02]										        ,;
                        Transform( aSldPrd[oLbx2:nAt,13],AllTrim(X3Picture("B2_QATU")) )	,;
                        Transform( aSldPrd[oLbx2:nAt,03],AllTrim(X3Picture("B2_QATU")) )	,;
                        Transform( aSldPrd[oLbx2:nAt,04],AllTrim(X3Picture("B2_RESERVA")))	,;
                        Transform( aSldPrd[oLbx2:nAt,05],AllTrim(X3Picture("B2_QEMP")) )    ,;
                        Transform( aSldPrd[oLbx2:nAt,06],AllTrim(X3Picture("B2_QACLASS")))	,;
                        Transform( aSldPrd[oLbx2:nAt,07],AllTrim(X3Picture("B2_QEMPSA")) )	,;
                        Transform( aSldPrd[oLbx2:nAt,08],AllTrim(X3Picture("B2_QEMPPRJ")))	,;
                        Transform( aSldPrd[oLbx2:nAt,09],AllTrim(X3Picture("B2_SALPEDI")))	,;
                        Transform( aSldPrd[oLbx2:nAt,10],AllTrim(X3Picture("B2_QTNP")) )	,;
                        Transform( aSldPrd[oLbx2:nAt,11],AllTrim(X3Picture("B2_QNPT")) )	,;
                        Transform( aSldPrd[oLbx2:nAt,12],AllTrim(X3Picture("B2_QEMPPRE")))	}}
oLbx2:Refresh()

Return


/*/{Protheus.doc} RetSaldo
VOLVER EL SALDOS DE LOS ALMACEN DE ACUERDO CON LOS PARAMETROS
@type       function
@version    001
@author     Larson Zordan
@since      11/04/2022
@param      cProd, character, Producto
@param      cLocINI, character, Almacen Inicial
@param      cLocFIM, character, Almacen Final
@return     numeric, Saldo Disponibble
/*/
Static Function RetSaldo(cProd, cLocINI, cLocFIM, aSG1, aSaldos)
Local aAreaAnt := GetArea()
Local nQtde    := 0
Local nSaldo   := 0

If SB2->(dbSeek(FWxFilial("SB2")+cProd))
    While !SB2->(Eof()) .And. FWxFilial("SB2")+cProd == SB2->(B2_FILIAL+B2_COD)
        nQtde := 0
        If cLocINI <= SB2->B2_LOCAL .And. cLocFIM >= SB2->B2_LOCAL
            nQtde := SaldoSB2() 
            nQtde -= SB2->B2_QNPT
            nQtde += SB2->B2_QTNP

            If aSav650[14] == 2  // Modificado 30.04.2024 Juan Pablo Astorga mv_par14 == 2
                // mv_par14 - Qtd. Nossa Poder 3o.  1-Ignora / 2-Soma
                nQtde += SB2->B2_QNPT
            EndIf
            If aSav650[14] == 2 // Modificado 30.04.2024 Juan Pablo Astorga mv_par14 == 2
                // mv_par15 - Qtd. 3o. Nosso Poder  1-Ignora / 2-Subtrai
                nQtde -= SB2->B2_QTNP
            EndIf

            aSG1[07] += nQtde
            aSG1[08] += SB2->B2_RESERVA
            aSG1[09] += SB2->B2_QEMP
            aSG1[10] += SB2->B2_QACLASS
            aSG1[11] += SB2->B2_QEMPSA
            aSG1[12] += SB2->B2_QEMPPRJ
            aSG1[13] += SB2->B2_SALPEDI
            aSG1[14] += SB2->B2_QTNP
            aSG1[15] += SB2->B2_QNPT
            aSG1[16] += SB2->B2_QEMPPRE
            aSG1[17] += SB2->B2_QATU

            aAdd( aSaldos, { SB2->B2_COD, SB2->B2_LOCAL, SB2->B2_QATU, SB2->B2_RESERVA, SB2->B2_QEMP, SB2->B2_QACLASS, SB2->B2_QEMPSA, SB2->B2_QEMPPRJ, SB2->B2_SALPEDI, SB2->B2_QTNP, SB2->B2_QNPT, SB2->B2_QEMPPRE, nQtde  } )

            nSaldo += nQtde

        EndIf

        SB2->(dbSkip())    

    EndDo
EndIf

RestArea(aAreaAnt)
Return(nSaldo)
