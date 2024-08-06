#Include "Protheus.ch"

User Function SCOBROW()
    Local cAlias := "SCO"
    Local cFiltra := "CO_FILIAL == '"+xFilial('SCO')+"' "
    Private cCadastro := "Planilla Formación de precios"
    Private aRotina := {}
    Private aIndexSA2 := {}
    Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSA2,@cFiltra) }

    AADD(aRotina,{"Borrar" ,"U_BInclui" ,0,5})

    dbSelectArea(cAlias)
    dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
    Eval(bFiltraBrw)
    dbSelectArea(cAlias)
    dbGoTop()
    mBrowse(6,1,22,75,cAlias,,,,,,)
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
    EndFilBrw(cAlias,aIndexSA2)
Return Nil
//+---------------------------------------
//|Função: BInclui - Rotina de Inclusão
//+---------------------------------------
User Function BInclui(cAlias,nReg,nOpc)
    Local Seek := ""
    (cAlias)->((nReg))

    Seek := (cAlias)->CO_CODIGO+(cAlias)->CO_REVISAO

    SCO->(DbSetOrder(1))
	SCO->(DbSeek(xFilial("SCO")+Seek))
    While !SCO->(Eof()) .AND. SCO->(CO_CODIGO+CO_REVISAO) == Seek

        RecLock("SCO",.F.)
        SCO->(DbDelete())
        SCO->(MsUnlock())

       SCO->(dbSkip())
    EndDo
    

Return Nil
