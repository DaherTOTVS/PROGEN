#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"


/*------------------------------------------------!
!API PARA CONSULTAR CLIENTES ASIGNADOS AL VENDEDOR!
!                 JAVIER ROCHA                    !
--------------------------------------------------*/


WSRESTFUL UANDCLIEXV DESCRIPTION "Servicio API Rest Para la consulta de clientes por usuario del portal 'Lugares de Stock' |TOTVS Andina| Bogota Colombia **Developed For Protheus by TOTVS ** "
    WSDATA Cod          AS STRING OPTIONAL
    WSDATA Page         AS INTEGER      OPTIONAL
    WSDATA PageSize     AS INTEGER      OPTIONAL

    //Metodos
    WSMETHOD GET         DESCRIPTION "Retorna listado de todos los usuarios Filtra por un Dato."          WSSYNTAX "/VerCliexVen"     PATH "/VerCliexVen"    // Obtiene Todos los Prodcutos o filtra un producto

END WSRESTFUL

//1. METODO Retorna Listado de todos los Productos
WSMETHOD GET  WSRECEIVE Cod, Page, PageSize  WSREST UANDCLIEXV
Local aArea     := GetArea()
Local lPost     := .T.
Local oResponse := JsonObject():New()
Local aTasks    := {}
Local nCount := 0
Local nStart := 1
Local nReg   := 0
Local nAux   := 0

Default Self:Cod        := ''
Default Self:Page       := 1
//Default Self:PageSize   := 10

// A1_LC - (A1_SALDUP + A1_SALPEDL)

::SetContentType("application/json")
cAlias := GetNextAlias()
 cQuery := "SELECT  "
cQuery += "(SELECT SUM(E1_SALDO) FROM "+ RetSQLName('SE1') +" WHERE E1_SALDO > 0 AND E1_TIPO IN ('NF', 'NDC') AND E1_LOJA=A1_LOJA AND A1_COD=E1_CLIENTE AND D_E_L_E_T_ <> '*') TOTALD , "
cQuery += "(SELECT SUM(E1_SALDO) FROM "+ RetSQLName('SE1') +" WHERE E1_SALDO > 0 AND E1_TIPO IN ('NCC', 'RA') AND E1_LOJA=A1_LOJA AND A1_COD=E1_CLIENTE AND D_E_L_E_T_ <> '*') TOTALC , "
cQuery += " SA1.A1_COD,  "
cQuery += " SA1.A1_LOJA , "
cQuery += " SA1.A1_NOME , "
cQuery += " SA1.A1_NREDUZ , " 
cQuery += " SA1.A1_CGC , "
cQuery += " SA1.A1_PFISICA, " 
cQuery += " SA1.A1_EMAIL  , "
cQuery += " SA1.A1_TEL   , "
cQuery += " SA1.A1_VEND  , "
cQuery += " SA1.A1_FILIAL, "
cQuery += " SA1.A1_DESC, "
cQuery += " SA1.A1_TABELA, " 
// cQuery += " SA1.A1_TIPDOC, "
cQuery += " SA1.A1_END, "
cQuery += " SA1.A1_SALDUP, "
cQuery += " SA1.A1_LC, "
cQuery += " SA1.A1_GRPVEN, " 
cQuery += " SA1.A1_ESTADO, "
cQuery += " SA1.A1_BAIRRO, "
cQuery += " SA1.A1_MUN, "
cQuery += " SA1.A1_COND, "
cQuery += " SA1.A1_EST, "
cQuery += " SA1.A1_COD_MUN, " 
cQuery += " SA1.A1_NATUREZ, "
cQuery += " SA1.A1_ENDENT, "
cQuery += " SA1.A1_EST, "
cQuery += " SA1.A1_COD_MUN, "
cQuery += " SA1.A1_MUN, "
cQuery += " SA1.A1_ESTADO, "
cQuery += " SA1.A1_CONTATO, "
cQuery += " SA3.A3_NOME, "
cQuery += " SA3.A3_EMAIL "
cQuery += " FROM "  + RetSQLName('SA1') + " SA1 "

cQuery += " INNER JOIN "+ RetSQLName('ZZ5') + " ZZ5  "
cQuery += " ON SA1.A1_VEND= ZZ5.ZZ5_VEND "
cQuery += " AND ZZ5.ZZ5_VEND <> '' "
cQuery += " LEFT JOIN " + RetSQLName('SE1') + " SE1 "
cQuery += " ON SA1.A1_COD = SE1.E1_CLIENTE "
cQuery += " AND  SE1.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN " + RetSQLName('SA3') + " SA3 "
cQuery += " ON SA1.A1_VEND = SA3.A3_COD "
cQuery += " AND  SA3.D_E_L_E_T_ <> '*' "
cQuery += " WHERE  "
cQuery += " SA1.A1_FILIAL   = '"+xFilial("SA1")+"'"
cQuery += " AND SA1.D_E_L_E_T_ <> '*' AND SA1.A1_MSBLQL = '2'   AND  ZZ5.D_E_L_E_T_ <> '*'  "


//Filtros
IF !Empty(Self:Cod)
    cCod := AllTrim(Upper(Self:Cod))
    cQuery += " AND ( ZZ5.ZZ5_CODUSU = '" + cCod + "' OR "
    cQuery += " ZZ5.ZZ5_VEND = '" + cCod + "' ) "
EndIF
cQuery += "GROUP BY "
cQuery += " SA1.A1_COD,  "
cQuery += " SA1.A1_LOJA , "
cQuery += " SA1.A1_NOME , "
cQuery += " SA1.A1_NREDUZ , " 
cQuery += " SA1.A1_CGC , "
cQuery += " SA1.A1_PFISICA, " 
cQuery += " SA1.A1_EMAIL  , "
cQuery += " SA1.A1_TEL   , "
cQuery += " SA1.A1_VEND  , "
cQuery += " SA1.A1_FILIAL, "
cQuery += " SA1.A1_DESC, "
cQuery += " SA1.A1_TABELA, "
// cQuery += " SA1.A1_TIPDOC, "
cQuery += " SA1.A1_END,"
cQuery += " SA1.A1_SALDUP," 
cQuery += " SA1.A1_LC, "
cQuery += " SA1.A1_GRPVEN," 
cQuery += " SA1.A1_ESTADO, "
cQuery += " SA1.A1_BAIRRO, "
cQuery += " SA1.A1_MUN, "
cQuery += " SA1.A1_COND, "
cQuery += " SA1.A1_EST, "
cQuery += " SA1.A1_COD_MUN, "
cQuery += " SA1.A1_NATUREZ, "
cQuery += " SA1.A1_ENDENT, "
cQuery += " SA1.A1_EST, "
cQuery += " SA1.A1_COD_MUN, "
cQuery += " SA1.A1_MUN, "
cQuery += " SA1.A1_ESTADO, "
cQuery += " SA1.A1_CONTATO, "
cQuery += " SA3.A3_NOME, "
cQuery += " SA3.A3_EMAIL, "
cQuery += " SE1.D_E_L_E_T_ "
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery, cAlias)
If (cAlias)->(!Eof())
    Count To nRecord
    IF Self:Page > 1
        nStart  := ((Self:Page-1)*Self:PageSize)+1
        nReg    := nRecord-nStart+1
    ELSE
        nReg := nRecord
    EndIF
    (cAlias)->(dbGoTop())
    IF nReg > Self:PageSize
        oResponse['hasNext'] := .T.
    ELSE
        oResponse['hasNext'] := .F.
    EndIF
    While (cAlias)->(!Eof())
        nCount++
        IF nCount >= nStart
            nAux++
            oTask := JsonObject():New()
            oTask['branch']          := (cAlias)->A1_FILIAL                          //Filial
            oTask['code']            := (cAlias)->A1_COD                             //Codigo
            oTask['name']            := Alltrim( EncodeUTF8((cAlias)->A1_NOME))   //Nombre
            oTask['namefan']            := Alltrim( EncodeUTF8((cAlias)->A1_NREDUZ))   //Nombre Fantasia
            oTask['store']           := Alltrim( EncodeUTF8((cAlias)->A1_LOJA))   //Tienda
            oTask['nit']             := (cAlias)->A1_CGC                             //RUC
            oTask['ced']             := (cAlias)->A1_PFISICA                            //Cedula
            oTask['email']           := Alltrim( EncodeUTF8((cAlias)->A1_EMAIL))    //correo electronico
            oTask['phone']           := (cAlias)->A1_TEL                             //Telefono
            oTask['seller']          := (cAlias)->A1_VEND                            //Vendedor
            oTask['descuent']       := (cAlias)->A1_DESC                          //Descuento
            oTask['pricelist']       := ALLTRIM((cAlias)->A1_TABELA)                          //Tabla Precios
            // oTask['doctype']         := (cAlias)->A1_TIPDOC                          //Tipo Documento
            oTask['customeraddress'] := Alltrim( EncodeUTF8((cAlias)->A1_END))                             //Direccion
            oTask['unpaidbalance']   := (cAlias)->A1_SALDUP                          //Saldo Pendiente
            oTask['creditlimit']     := (cAlias)->A1_LC                              //Limite de Credito
            //oTask['salesgroup']      := (cAlias)->A1_GRPVEN                          // Grupo de Ventas
            oTask['depa']           := (cAlias)->A1_EST                         //Cod Estado
            oTask['state']           := EncodeUTF8((cAlias)->A1_ESTADO)                          //Estado
            oTask['muni']        := (cAlias)->A1_COD_MUN                             //Cod Municipio
            oTask['province']        := EncodeUTF8((cAlias)->A1_MUN)                             //Municipio
            oTask['district']        := Alltrim( EncodeUTF8((cAlias)->A1_BAIRRO))                          //Barrio
            oTask['contact']         := (cAlias)->A1_CONTATO                         //Contacto
            oTask['paymentterms']    := (cAlias)->A1_COND                            //Condicion Pago
            oTask['groupven']    := Alltrim((cAlias)->A1_GRPVEN)
            oTask['modalidad']    := Alltrim((cAlias)->A1_NATUREZ)                         //Modalidad
            oTask['direntrega']    := Alltrim(EncodeUTF8((cAlias)->A1_ENDENT))                        //Direcciòn EntregaS
            oTask['depdirentre']    := (cAlias)->A1_EST                        //Departamento entrega
            oTask['mundirentre']    := (cAlias)->A1_COD_MUN                         //Municipio de entrega
            oTask['nommunentre']    := Alltrim(EncodeUTF8((cAlias)->A1_MUN))   //Nombre municipio entrega
            oTask['nomdepentre']    := Alltrim(EncodeUTF8((cAlias)->A1_ESTADO))  //Nombre Depto entrega
            oTask['totaldeb']    := (cAlias)->TOTALD                       //Total Debitos
            oTask['totalcre']    := (cAlias)->TOTALC                       //Total Creditos
            oTask['vendeName']    := Alltrim(EncodeUTF8((cAlias)->A3_NOME))                     //Name Vend
            oTask['vendeMail']    := (cAlias)->A3_EMAIL                   //Mail Vend
            oTask['FecVer']    := "16/09/2023"                       //Version Api
            AAdd(aTasks, oTask)
            IF Len(aTasks) >= Self:PageSize
                Exit
            EndIF
        EndIF
        (cAlias)->(DbSkip())
    End
Else
    oResponse['hasNext'] := .F.
    cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
    ::SetResponse(cResponse)
EndIf
oResponse['ClientxU'] := aTasks
cResponse:= FwJsonSerialize(oResponse)
FreeObj(oResponse)
Self:SetResponse(cResponse)
(cAlias)->(DbCloseArea())
RestArea(aArea)
Return lPost

