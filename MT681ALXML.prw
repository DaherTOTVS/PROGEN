#Include "Protheus.ch"
 
User Function MT681ALXML()
    Local aArea := getArea()
    Local aAreaB1 := SB1->(GetArea()) //�rea da tabela SB1 para restaurar no fim do processamento.
    Local cProd   := "" //Vari�vel para armazenar o c�digo do produto.
	Local cBodega := ""
 
    Private oXmlRcv   := PARAMIXB //Refer�ncia do objeto contendo as informa��es que foram recebidas no XML.
    Private aXmlWst   := {} //Array para manipular as informa��es de lista de refugos.
    Private aCmpBaixa := {} //Array para manipular as informa��es da lista de componentes.

 
  
    cProd := oXmlRcv:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
    //Ajusta o �ndice da tabela SB1

    IF type(oXmlRcv:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text) != "U"

        CONOUT("DIFERENTE DE U ")
        SB1->(dbSetOrder(1))
        If SB1->(dbSeek(xFilial("SB1")+cProd))
            IF Empty(SB1->(B1_XALM))
                cBodega := SB1->B1_LOCPAD // Usar el valor del campo B1_LOCPAD  o la bodega default del Pto
            else
                cBodega := SB1->B1_XALM // Usar el valor del campo B1_XALM  o Almacen de Produccion
            End If
        EndIf

        oXmlRcv:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text:=cBodega
    Else
        CONOUT("IGUAL A U ")
    EndIf
   
    //Restaura o posicionamento da tabela SB1.
    SB1->(RestArea(aAreaB1))
    RestArea(aArea)  

     
    // CONOUT(oXmlRcv:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
    // CONOUT(oXmlRcv:_TotvsMessage)
    // CONOUT(oXmlRcv)
    // CONOUT("*******************FIN - oXmlRcv************************")

    // __Quit()
Return Nil
