User Function MT415EFT()
Local lRet           := .T.
Local aArea          := GetArea()
//Local aPrdInd        := {}
Local cMsg           :=""
Local cNumopc       := PARAMIXB[1] 

//SCK->(DbSetOrder(1))
//SCK->(DbSeek(xFilial("SCK")+SCJ->CJ_NUM))
SCJ->(DbSetOrder(1))
SCJ->(DbSeek(xFilial("SCJ")+SCJ->CJ_NUM))




//Verifica todos os itens do orçamento
/*While !SCK->(EOF()) .And. SCK->CK_NUM==SCJ->CJ_NUM
     If Alltrim(SCK->CK_LOCAL)=="02"
          aAdd(aPrdInd,SCK->CK_ITEM)
     Endif
     SCK->(DbSkip())
EndDo
*/

//Exibe o erro na tela da efetivação do orçamento
//If Len(aPrdInd)>0
If cNumopc == 4
     IF alltrim(SCJ->CJ_CLIENTE) == "111111" 

     //     lRet := .F.
          //prepara msg
          cMsg := ""
          //aEval(aPrdInd, {|x| cMsg += x +', ' })
          
          //cMsg := Left(cMsg, Len(cMsg)-2)
          cMsg :=  SCJ->CJ_NUM
          cMsg := "No es posble Aprobar el presupesto ("+cMsg+") porque tiene el nit de progen"
          Alert(cMsg)

          lRet := .F.
     Endif
Endif

RestArea(aArea)
Return lRet
