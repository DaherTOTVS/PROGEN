#Include "Protheus.Ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

User Function MT010ALT()
	Local aArea := getArea()
    Local lRet := .T.

    cFormula := SuperGetMv("PG_TMPENT",.F.,"")
    cFormprz := M->B1_FORPRZ
    CB1pe    := M->B1_PE
    cTemptra := SA5->A5_TEMPTRA
    cA5pe    := SA5->A5_PE
    nB5przcq := M->B5_PRZCQ

    If cFormprz$cFormula
        dbSelectArea( "SM4" )
        SM4->( DbSetOrder( 1 ))
        If SM4->( MsSeek( xFilial("SM4") + cFormprz ) )

            CB1pe := &(SM4->M4_FORMULA)
            SB1->B1_PE := CB1pe

        EndIf
        ("SM4")->(DBCloseArea())
    EndIF
        
    RestArea(aArea)  
Return(lRet)
