#Include "Totvs.Ch"


/*/{Protheus.doc} PG650SG2
CONSULTA PADRAO SG2002 - PERSONALIZADA
@type       function
@version    001
@author     Larson zordan
@since      28/11/2022
@return     variant, .T. ou .F.
/*/
User Function PG650SG2()
Local oDlg
Local oLbx
Local aCpos  := {}
Local aRet   := {}
Local cQuery := ""
Local cAlias := GetNextAlias()
Local lRet   := .F.
Local cFilSG2 := xFilial("SG2")

DEFAULT l650Auto	   := .F.
DEFAULT lAutomacao  := .F.

cQuery := " SELECT DISTINCT SG2.G2_CODIGO, SG2.G2_PRODUTO, SG2.G2_XOBS "
cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
cQuery +=  " WHERE SG2.D_E_L_E_T_ = ' ' "
cQuery +=    " AND SG2.G2_FILIAL  = '" + cFilSG2 + "' "
If !Empty(M->C2_PRODUTO)
    cQuery += " AND SG2.G2_PRODUTO = '" + M->C2_PRODUTO + "' "
EndIf
cQuery += " ORDER BY 2,1 "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While (cAlias)->(!Eof())
    aAdd(aCpos,{(cAlias)->(G2_CODIGO), (cAlias)->(G2_PRODUTO), (cAlias)->(G2_XOBS) })
    (cAlias)->(dbSkip())
End
(cAlias)->(dbCloseArea())

If Len(aCpos) < 1
    aAdd(aCpos,{" "," "})
EndIf

If !l650Auto .and. !lAutomacao
    DEFINE MSDIALOG oDlg TITLE "Procedimiento y Operaciones"  FROM 0,0 TO 240,500 PIXEL 

    @ 10,10 LISTBOX oLbx FIELDS HEADER SG2->(RetTitle("G2_CODIGO")), SG2->(RetTitle("G2_PRODUTO")), SG2->(RetTitle("G2_XOBS"))  SIZE 230,95 OF oDlg PIXEL

    oLbx:SetArray( aCpos )
    oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}
    oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

    DEFINE SBUTTON FROM 107,213 TYPE  1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
    DEFINE SBUTTON FROM 107,180 TYPE 15 ACTION ( PGVIEWOPER(oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]) )  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER
EndIF

If Len(aRet) > 0 .And. lRet
    If Empty(aRet[1])
        lRet := .F.
    Else
        SG2->(dbSetOrder(1))
        SG2->(dbSeek(cFilSG2+aRet[2]+aRet[1]))
    EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} PGVIEWOPER
VISUALIZA AS OPERACOES 
@type       function
@version    001
@author     Larson Zordan
@since      03/12/2022
@param      cCod, character, Codigo
@param      cProd, character, Produto
@return     variant, Sem Retorno
/*/
Static Function PGVIEWOPER(cCod,cProd)
Local oDlg
Local oGetD

Local aAreaAnt      := GetArea()
Local aColsSG2      := {}
Local aHeadSG2      := {}
Local aSG2          := FWSX3Util():GetAllFields("SG2",.T.)

Local cCadAtu       := cCadastro

Local nX 

cCadastro := "Proceso Productivo Por Operación: "+cCod

////////////////////// MONTA aHEADSG2 /////////////////////////////////
For nX := 1 To Len(aSG2)
    SX3->(dbSetOrder(2))
    If SX3->(dbSeek(aSG2[nX])) .And. cNivel >= SX3->X3_NIVEL .And. X3USO(SX3->X3_USADO)
         
        aAdd(aHeadSG2 , {   Trim(GetSx3Cache(aSG2[nX],"X3_TITULO"))     ,;
                            AllTrim(GetSx3Cache(aSG2[nX],"X3_CAMPO"))   ,;
                            GetSx3Cache(aSG2[nX],"X3_PICTURE")          ,;
                            GetSx3Cache(aSG2[nX],"X3_TAMANHO")          ,;
                            GetSx3Cache(aSG2[nX],"X3_DECIMAL")          ,;
                            GetSx3Cache(aSG2[nX],"X3_VALID")            ,;
                            GetSx3Cache(aSG2[nX],"X3_USADO")            ,;
                            GetSx3Cache(aSG2[nX],"X3_TIPO")             ,;
                            GetSx3Cache(aSG2[nX],"X3_F3")               ,;
                            GetSx3Cache(aSG2[nX],"X3_CONTEXT")          })
    EndIf
Next nX
////////////////////// MONTA aCOLS ///////////////////////////////////
SG2->(dbSetOrder(1))
If SG2->(dbSeek(FWxFilial("SG2")+cProd+cCod))
    While !SG2->(Eof()) .And. FWxFilial("SG2")+cProd+cCod == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
        aAdd(aColsSG2,Array(Len(aHeadSG2)+1))

        For nX := 1 To Len(aHeadSG2)
            aColsSG2[Len(aColsSG2)][nX] := SG2->(FieldGet(FieldPos(aHeadSG2[nx][2])))
        Next nX
        aColsSG2[Len(aColsSG2),Len(aHeadSG2)+1] := .F.

        SG2->(dbskip())
    EndDo
EndIf
If Len(aColsSG2) == 0
    aAdd(aColsSG2,Array(Len(aHeadSG2)+1))
    For nX := 1 To Len(aHeadSG2)
        aColsSG2[Len(aColsSG2)][nX]:= CriaVar(aHeadSG2[nX,2],.T.)
    Next nX	
    aColsSG2[Len(aColsSG2),Len(aHeadSG2)+1] := .F.
EndIf
//////////////////////////////////////////////////////////////////////

Define MsDialog oDlg Title cCadastro Of oMainWnd Pixel From 0,0 To 450,950

oGetD := MsNewGetDados():New(1,1,200,200,0,"AllwaysTrue","AllwaysTrue",,,,,,,,oDlg, aHeadSG2, aColsSG2 )
oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg Center On Init EnchoiceBar(oDlg, { || oDlg:End() }, { || oDlg:End() })

cCadastro := cCadAtu

RestArea(aAreaAnt)
Return
