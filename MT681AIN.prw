#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MT681INC                                                                                      |
 | Desc:  Validação do usuário (Confirmação), na inclusão de Produção PCP Modelo 2                      |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6089415                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function MT681AIN()
    Local aArea:= GetArea()
    Local aAreaB1 := SB1->(GetArea()) //Área da tabela SB1 para restaurar no fim do processamento.
    Local cProd := SH6->H6_PRODUTO

    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1")+cProd))
        IF !Empty(SB1->(B1_XALM))

            RecLock("SH6", .F.)
                SH6->H6_LOCAL := SB1->B1_XALM
            SH6->(MsUnlock())

        EndIf
    EndIf

    SB1->(RestArea(aAreaB1))
    RestArea(aArea)  

Return Nil
