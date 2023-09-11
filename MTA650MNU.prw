#Include "Totvs.Ch"

/*/{Protheus.doc} MTA650MNU
P.E. Acrescenta rotina no menu de Outras Opções do Browse
@type       function
@version    001
@author     Larson Zordan
@since      17/05/2022
@return     variant, sem retorno
/*/
User Function MTA650MNU()
    aAdd( aRotina, { "# Saldo del Producto"         ,"U_PGSLDB1" , 0 , 7, 0, nil} )
    aAdd( aRotina, { "# Saldo del Producto por referencia"         ,"U_PGSLDB2" , 0 , 7, 0, nil} )
    aAdd( aRotina, { "# Asignación Multiple"        ,"U_PGEMPD4" , 0 , 7, 0, nil} )
    aAdd( aRotina, { "# Detalle Por OP"             ,"MATR860"   , 0 , 7, 0, nil} )
    aAdd( aRotina, { "# Actualiza Fechas Previstas" ,"U_PGFHSH8" , 0 , 7, 0, nil} )
    aAdd( aRotina, { "# Control Apunte Produccion"  ,"PCPA115" , 0 , 7, 0, nil} )
    // aAdd( aRotina, { "# Imprime Orden de Producion" ,"MATR820  " , 0 , 7, 0, nil} )
Return


/*/{Protheus.doc} PGSLDB1
VISUALIZA A POSICAO DO SALDO DO PRODUTO
@type       function
@version    001
@author     Larson Zordan
@since      29/11/2022
@return     variant, Sem Retorno
/*/
User Function PGSLDB1()
    MaViewSB2(SC2->C2_PRODUTO)
Return


User Function PGSLDB2()
    Local aPergs := {}
    aAdd( aPergs ,{1,"Producto",Space(TamSx3("B1_COD")[1])   ,"@!",,,'.T.',80,.T.})

    While .T.
        If ParamBox(aPergs ,"Producto",@aPergs,,,,,,,,.f.)
            If !Empty(aPergs[1])
                exit


            EndIf
        Else
            MsgAlert("Proceso cancelado por el usuario","TERMINADO")
            return
        EndIf
    EndDo
    MaViewSB2(aPergs[1])

Return




