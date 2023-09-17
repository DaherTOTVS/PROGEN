#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH" 


/*/{Protheus.doc} MATA632
GRAVA O CAMPO DE OBSERVACAO DO CABECALHO DA ROTINA - VER P.E. M632ADDFLD.PRW
@type       function
@version    001
@author     Larson Zordan
@since      28/11/2022
@return     variant, .T. Sempre
/*/
User Function PCPA124()
//User Function MATA63P2()
Local oObj     := ""
Local aParam   := PARAMIXB
Local cIdModel := ""
Local cIdPonto := ""
Local cQry     := ""
Local xRet     := .T.
Local cCod 
Local cPrd 
Local cObs 

If aParam <> NIL
     
    oObj     := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]

    If (cIdPonto == "MODELCOMMITNTTS") 
        cCod := oObj:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")
        cPrd := oObj:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
        cObs := oObj:GetModel("PCPA124_CAB"):GetValue("G2_XOBS")

        cQry := "UPDATE "+RetSqlName("SG2")+" SET G2_XOBS = '"+cObs+"' 
        cQry += " WHERE G2_FILIAL = '"+FWxFilial("SG2")+"' AND G2_CODIGO = '"+cCod+"' 
        cQry += " AND G2_PRODUTO = '"+cPrd+"' "
        TcSqlExec(cQry)

  EndIf
EndIf
Return xRet
