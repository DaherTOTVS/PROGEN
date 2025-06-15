#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ARRFA005  ≥ Autor ≥ Juan Pablo Astorga    ≥ Data ≥30/06/2021≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Generacion del informe listado de ventas Facturas , nota de≥±±
±±≥          ≥ Credito y Debito                                           ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function ARRFA005()

Local oReport
Local oSection
Local cPerg := "ARRFA005"
Local cAlias := GetNextAlias()
AjustaSX1()

Pergunte(cPerg,.F.)
		DEFINE REPORT oReport NAME "ARRFA005" TITLE "Listado de Ventas" PARAMETER "ARRFA005" ACTION {|oReport| PrintReport(oReport, cAlias)}
				DEFINE SECTION oSection OF oReport TITLE "Ventas" TABLES "SD2", "SD1"
				DEFINE CELL NAME "EMPRESA" OF oSection //ALIAS "SD2
				DEFINE CELL NAME "FILIAL" OF oSection //ALIAS "SD2
				DEFINE CELL NAME "FECHA" OF oSection block {||stod(FECHA)}//ALIAS "SD2"
				DEFINE CELL NAME "CLIENTE" OF oSection SIZE 20//ALIAS "SD2"
				DEFINE CELL NAME "LOJA" OF oSection
				DEFINE CELL NAME "NOMBRE_FANTASIA" OF oSection   //"RAZON_SOCIAL" OF oSection Modificado 28.01.2025
				DEFINE CELL NAME "DIRECCION_ENTREGA" OF oSection  block {|| DirecEntrg(ESPECIE,PEDIDO,CLIENTE,LOJA) }  
				DEFINE CELL NAME "DEPARTAMENTO_ENTREGA" OF oSection  block {|| DepEntrg(ESPECIE,PEDIDO,CLIENTE,LOJA) }  
				DEFINE CELL NAME "MUNICIPIO_ENTREGA" OF oSection  block {|| MunEntrg(ESPECIE,PEDIDO,CLIENTE,LOJA) } 
				DEFINE CELL NAME "CODVENDEDOR" OF oSection
				DEFINE CELL NAME "VENDEDOR" OF oSection //ALIAS "SC5" SIZE 40
				DEFINE CELL NAME "SERIE" OF oSection SIZE 5
				DEFINE CELL NAME "COMPROBANTE" OF oSection SIZE 13
				DEFINE CELL NAME "PEDIDO" OF oSection SIZE 6
				DEFINE CELL NAME "USER_PEDIDO" OF oSection  block {|| usrPedido(ESPECIE,PEDIDO) } 
				DEFINE CELL NAME "PRODUCTO" OF oSection SIZE 15//ALIAS "SD2"
				DEFINE CELL NAME "DESCRIPCION" OF oSection //ALIAS "SD2"
				DEFINE CELL NAME "UM" OF oSection //ALIAS "SD2"
				DEFINE CELL NAME "CANT" OF oSection Picture PesqPict("SD2","D2_QUANT")
				DEFINE CELL NAME "PRECIO" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_TOTAL")
				DEFINE CELL NAME "TOTAL" OF oSection Picture  "@E 999999999999999999.99" //PesqPict("SD2","D2_TOTAL")//block {||(cAlias)}//Iif(ESPECIE == "NCC",TOTAL*(-1),TOTAL)}
				DEFINE CELL NAME "VALIVA" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_TOTAL")
				DEFINE CELL NAME "TOTAL_MAS_IVA" OF oSection block {|| IF(ALLTRIM(ESPECIE)='NCC',(TOTAL+VALIVA),TOTAL+VALIVA) }  Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_TOTAL") 
			If FWCodEmp() = '01'
				DEFINE CELL NAME "AUTO_RETENCION_ESPECIAL" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_VALIMP9")
				DEFINE CELL NAME "AUTORETENCION_VENTA" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_VALIMP6")
				DEFINE CELL NAME "AUTORETENCION_HONORARIOS" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_VALIMP5")
				DEFINE CELL NAME "AUTORETENCION_ICA" OF oSection Picture "@E 999999999999999999.99" //PesqPict("SD2","D2_VALIMPA")
			EndIf
				DEFINE CELL NAME "MODALIDAD" OF oSection //ALIAS "SC5"
				DEFINE CELL NAME "DESC.MODALIDAD" OF oSection block {||UPPER(Posicione("SED",1,xfilial("SED")+MODALIDAD,"ED_DESCRIC"))}
				DEFINE CELL NAME "CCOSTO" OF oSection //ALIAS "SC5"
				DEFINE CELL NAME "DESC.CCOSTO" OF oSection block {||UPPER(Posicione("CTT",1,xfilial("CTT")+CCOSTO,"CTT_DESC01"))}
				DEFINE CELL NAME "ESPECIE" OF oSection //ALIAS "SC5"
				DEFINE CELL NAME "DESCESP" OF oSection block {||buDesEsp(ESPECIE)}
				DEFINE CELL NAME "SERORI" OF oSection SIZE 3
				DEFINE CELL NAME "NFORI " OF oSection SIZE 13
				DEFINE CELL NAME "DESCUENTO" OF oSection Picture "@E 999999999999999999.99"//PesqPict("SD2","D2_DESCON")
				DEFINE CELL NAME "GRUPO" OF oSection
				DEFINE CELL NAME "DESCGRUP" OF oSection block {||UPPER(Posicione("SBM",1,xFilial("SBM")+GRUPO,"BM_DESC"))}
				DEFINE CELL NAME "TES" OF oSection block {|| TES }
				DEFINE CELL NAME "DESCTES" OF oSection block {||UPPER(Posicione("SF4",1,xFilial("SF4")+TES,"F4_TEXTO"))}
				DEFINE CELL NAME "CONDPAGO" OF oSection block {||UPPER(Posicione("SE4",1,xfilial("SE4")+CONDPAGO,"E4_DESCRI"))}
				DEFINE CELL NAME "CATEGORIA1" OF oSection block {||UPPER(Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG1"))}
				DEFINE CELL NAME "DESC.CATEGORIA1" OF oSection block {||Upper(POSICIONE("ZZ3",1,xFilial("ZZ3")+"CATEGORIA I    "+Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG1"),"ZZ3_XNOMCA")) }
				DEFINE CELL NAME "CATEGORIA2" OF oSection block {||UPPER(Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG2"))}
				DEFINE CELL NAME "DESC.CATEGORIA2" OF oSection block {||Upper(POSICIONE("ZZ3",1,xFilial("ZZ3")+"CATEGORIA II   "+Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG2"),"ZZ3_XNOMCA")) }				
				DEFINE CELL NAME "CATEGORIA3" OF oSection block {||UPPER(Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG3"))}
				DEFINE CELL NAME "DESC.CATEGORIA3" OF oSection block {||Upper(POSICIONE("ZZ3",1,xFilial("ZZ3")+"CATEGORIA III  "+Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG3"),"ZZ3_XNOMCA")) }
				DEFINE CELL NAME "CATEGORIA4" OF oSection block {||UPPER(Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG4"))}
				DEFINE CELL NAME "DESC.CATEGORIA4" OF oSection block {||Upper(POSICIONE("ZZ3",1,xFilial("ZZ3")+"CATEGORIA IV   "+Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG4"),"ZZ3_XNOMCA")) }
				DEFINE CELL NAME "CATEGORIA5" OF oSection block {||UPPER(Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG5"))}
				DEFINE CELL NAME "DESC.CATEGORIA5" OF oSection block {||Upper(POSICIONE("ZZ3",1,xFilial("ZZ3")+"CATEGORIA V    "+Posicione("SB1",1,xfilial("SB1")+PRODUCTO,"B1_XCATEG5"),"ZZ3_XNOMCA")) }
				If FWCodEmp() = '01'
				DEFINE CELL NAME "FECHA CONTABILIDAD" OF oSection block {|| StoD(DTLANC) } // Modificado 05/06/2023
				EndIF
				DEFINE CELL NAME "MONEDA" OF oSection block {|| GETMV("MV_MOEDA"+cValToChar(MOEDA))}
				DEFINE CELL NAME "TASA DE CAMBIO" OF oSection block {|| TXMOEDA }  Picture "@E 999999999999999999.99"
				DEFINE CELL NAME "TOTAL ORIGINAL" OF oSection block {|| TOTAL/TXMOEDA }  Picture "@E 999999999999999999.99"



				oReport:PrintDialog()
Return

Static Function PrintReport(oReport, cAlias)

#IFDEF TOP

	MakeSqlExp("ARRFA005")

	BEGIN REPORT QUERY oReport:Section(1)

If FWCodEmp() = '01'

	BeginSql alias cAlias
	SELECT  %Exp:cEmpAnt% AS EMPRESA, D2_FILIAL AS FILIAL, D2_EMISSAO AS FECHA, D2_CLIENTE AS CLIENTE, A1_NOME AS RAZON_SOCIAL, A1_NREDUZ AS NOMBRE_FANTASIA ,A3_NOME AS VENDEDOR, A3_COD AS CODVENDEDOR,
	        D2_SERIE AS SERIE, D2_DOC AS COMPROBANTE, D2_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, (D2_TOTAL*F2_TXMOEDA) AS TOTAL, D2_QUANT AS CANT,
			F2_NATUREZ AS MODALIDAD , F2_MOEDA AS MOEDA , F2_TXMOEDA AS TXMOEDA, D2_ESPECIE AS ESPECIE, D2_ITEM AS ITEM, (D2_PRCVEN*F2_TXMOEDA) AS PRECIO , D2_NFORI AS NFORI , D2_SERIORI AS SERORI ,
			D2_DESCON AS DESCUENTO , D2_GRUPO AS GRUPO , D2_TES AS TES , F2_COND AS CONDPAGO , D2_CCUSTO AS CCOSTO , D2_UM AS UM , (D2_VALIMP1*F2_TXMOEDA) AS VALIVA,
			D2_PEDIDO AS PEDIDO , D2_LOJA AS LOJA  , (D2_VALIMP9*F2_TXMOEDA) AS AUTO_RETENCION_ESPECIAL ,(D2_VALIMP6*F2_TXMOEDA) AS AUTORETENCION_VENTA, 
			(D2_VALIMP5*F2_TXMOEDA) AS AUTORETENCION_HONORARIOS , (D2_VALIMPA*F2_TXMOEDA) AS AUTORETENCION_ICA , F2_DTLANC AS DTLANC 
		FROM %table:SD2% SD2
             inner join %table:SF2% SF2 on D2_SERIE = F2_SERIE AND D2_DOC = F2_DOC AND D2_ESPECIE = F2_ESPECIE AND D2_EMISSAO = F2_EMISSAO AND D2_CLIENTE= F2_CLIENTE AND D2_LOJA = F2_LOJA
             left outer join %table:SB1% SB1 on D2_COD = B1_COD AND SB1.%NotDel%
             left outer join %table:SA1% SA1 on D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA AND SA1.%NotDel%
             left outer join %table:SA3% SA3 on F2_VEND1 = A3_COD AND SA3.%NotDel%
           	WHERE F2_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
			  F2_CLIENTE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
		      F2_VEND1   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
		      AND SD2. D_E_L_E_T_ <>'*' AND SF2. D_E_L_E_T_ <>'*' AND
			  F2_ESPECIE IN ('NF ','CF ','NDC')
	UNION
   SELECT %Exp:cEmpAnt% AS EMPRESA,D1_FILIAL AS FILIAL,D1_EMISSAO AS FECHA,D1_FORNECE AS CLIENTE,A1_NOME AS RAZON_SOCIAL , A1_NREDUZ AS NOMBRE_FANTASIA , 
          A3_NOME AS VENDEDOR,A3_COD AS CODVENDEDOR,D1_SERIE AS SERIE, D1_DOC AS COMPROBANTE, D1_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, ( (D1_TOTAL*F1_TXMOEDA)* (-1)) AS TOTAL,D1_QUANT * (-1) AS CANT,
           *A3_NOME AS VENDEDOR,A3_COD AS CODVENDEDOR,D1_SERIE AS SERIE, D1_DOC AS COMPROBANTE, D1_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, ((D1_TOTAL  - D1_VALDESC)* (-1)) AS TOTAL,D1_QUANT * (-1) AS CANT,
		  F1_NATUREZ AS MODALIDAD ,F1_MOEDA AS MOEDA , F1_TXMOEDA AS TXMOEDA,D1_ESPECIE AS ESPECIE, D1_ITEM AS ITEM, ((D1_VUNIT*F1_TXMOEDA) * (-1)) AS PRECIO , D1_NFORI AS NFORI , D1_SERIORI AS SERORI ,
		  D1_VALDESC*(-1)AS DESCUENTO, D1_GRUPO AS GRUPO , D1_TES AS TES ,F1_COND AS CONDPAGO , D1_CC AS CCOSTO , D1_UM AS UM , ((D1_VALIMP1*F1_TXMOEDA)*(-1)) AS VALIVA ,
		  D1_PEDIDO AS PEDIDO , D1_LOJA AS LOJA , ((D1_VALIMP9*F1_TXMOEDA)*(-1)) AS AUTO_RETENCION_ESPECIAL , ((D1_VALIMP6*F1_TXMOEDA)*(-1)) AS AUTORETENCION_VENTA, 
		  ((D1_VALIMP5*F1_TXMOEDA)*(-1)) AS AUTORETENCION_HONORARIOS , ((D1_VALIMPA*F1_TXMOEDA)*(-1)) AS AUTORETENCION_ICA , F1_DTLANC AS DTLANC 
	 FROM %table:SD1% SD1
            inner join %table:SF1% SF1 on D1_SERIE = F1_SERIE AND D1_DOC = F1_DOC AND D1_ESPECIE = F1_ESPECIE AND D1_EMISSAO = F1_EMISSAO AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA
                 left outer join %table:SB1% SB1 on D1_COD = B1_COD AND SB1.%NotDel%
                 left outer join %table:SA1% SA1 on D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA AND SA1.%NotDel%
                 left outer join %table:SA3% SA3 on F1_VEND1 = A3_COD AND SA3.%NotDel%
    WHERE F1_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
		  F1_FORNECE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
	      F1_VEND1   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
	      F1_ESPECIE = 'NCC  '
	      AND SD1. D_E_L_E_T_ <>'*' AND SF1. D_E_L_E_T_ <>'*'
	ORDER BY ESPECIE, MODALIDAD , CLIENTE
	EndSql
else
	BeginSql alias cAlias
	SELECT  %Exp:cEmpAnt% AS EMPRESA, D2_FILIAL AS FILIAL, D2_EMISSAO AS FECHA, D2_CLIENTE AS CLIENTE, A1_NOME AS RAZON_SOCIAL, A1_NREDUZ AS NOMBRE_FANTASIA , A3_NOME AS VENDEDOR, A3_COD AS CODVENDEDOR,
	        D2_SERIE AS SERIE, D2_DOC AS COMPROBANTE, D2_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, (D2_TOTAL*F2_TXMOEDA) AS TOTAL, D2_QUANT AS CANT,
			F2_NATUREZ AS MODALIDAD ,F2_MOEDA AS MOEDA , F2_TXMOEDA AS TXMOEDA, D2_ESPECIE AS ESPECIE, D2_ITEM AS ITEM, (D2_PRCVEN*F2_TXMOEDA) AS PRECIO , D2_NFORI AS NFORI , D2_SERIORI AS SERORI ,
			D2_DESCON AS DESCUENTO , D2_GRUPO AS GRUPO , D2_TES AS TES , F2_COND AS CONDPAGO , D2_CCUSTO AS CCOSTO , D2_UM AS UM , (D2_VALIMP1*F2_TXMOEDA) AS VALIVA,
			D2_PEDIDO AS PEDIDO , D2_LOJA AS LOJA , F2_DTLANC AS DTLANC 
		FROM %table:SD2% SD2
             inner join %table:SF2% SF2 on D2_SERIE = F2_SERIE AND D2_DOC = F2_DOC AND D2_ESPECIE = F2_ESPECIE AND D2_EMISSAO = F2_EMISSAO AND D2_CLIENTE= F2_CLIENTE AND D2_LOJA = F2_LOJA
             left outer join %table:SB1% SB1 on D2_COD = B1_COD AND SB1.%NotDel%
             left outer join %table:SA1% SA1 on D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA AND SA1.%NotDel%
             left outer join %table:SA3% SA3 on F2_VEND1 = A3_COD AND SA3.%NotDel%
           	WHERE F2_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
			  F2_CLIENTE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
		      F2_VEND1   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
		      AND SD2. D_E_L_E_T_ <>'*' AND SF2. D_E_L_E_T_ <>'*' AND
			  F2_ESPECIE IN ('NF ','CF ','NDC')
	UNION
   SELECT %Exp:cEmpAnt% AS EMPRESA,D1_FILIAL AS FILIAL,D1_EMISSAO AS FECHA,D1_FORNECE AS CLIENTE,A1_NOME AS RAZON_SOCIAL, A1_NREDUZ AS NOMBRE_FANTASIA ,
          A3_NOME AS VENDEDOR,A3_COD AS CODVENDEDOR,D1_SERIE AS SERIE, D1_DOC AS COMPROBANTE, D1_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, ( (D1_TOTAL*F1_TXMOEDA)* (-1)) AS TOTAL,D1_QUANT * (-1) AS CANT,
           *A3_NOME AS VENDEDOR,A3_COD AS CODVENDEDOR,D1_SERIE AS SERIE, D1_DOC AS COMPROBANTE, D1_COD AS PRODUCTO, B1_DESC AS DESCRIPCION, ((D1_TOTAL  - D1_VALDESC)* (-1)) AS TOTAL,D1_QUANT * (-1) AS CANT,
		  F1_NATUREZ AS MODALIDAD , F1_MOEDA AS MOEDA , F1_TXMOEDA AS TXMOEDA , D1_ESPECIE AS ESPECIE, D1_ITEM AS ITEM, ((D1_VUNIT*F1_TXMOEDA) * (-1)) AS PRECIO , D1_NFORI AS NFORI , D1_SERIORI AS SERORI ,
		  D1_VALDESC*(-1)AS DESCUENTO, D1_GRUPO AS GRUPO , D1_TES AS TES ,F1_COND AS CONDPAGO , D1_CC AS CCOSTO , D1_UM AS UM , ((D1_VALIMP1*F1_TXMOEDA)*(-1)) AS VALIVA ,
		  D1_PEDIDO AS PEDIDO , D1_LOJA AS LOJA , F1_DTLANC AS DTLANC 
	 FROM %table:SD1% SD1
            inner join %table:SF1% SF1 on D1_SERIE = F1_SERIE AND D1_DOC = F1_DOC AND D1_ESPECIE = F1_ESPECIE AND D1_EMISSAO = F1_EMISSAO AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA
                 left outer join %table:SB1% SB1 on D1_COD = B1_COD AND SB1.%NotDel%
                 left outer join %table:SA1% SA1 on D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA AND SA1.%NotDel%
                 left outer join %table:SA3% SA3 on F1_VEND1 = A3_COD AND SA3.%NotDel%
    WHERE F1_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
		  F1_FORNECE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
	      F1_VEND1   BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
	      F1_ESPECIE = 'NCC  '
	      AND SD1. D_E_L_E_T_ <>'*' AND SF1. D_E_L_E_T_ <>'*'
	ORDER BY ESPECIE, MODALIDAD , CLIENTE
	EndSql
EndIf

	END REPORT QUERY oReport:Section(1)
	oReport:Section(1):Print()
#ENDIF

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcion   ≥ BuSigno   ≥ Autor ≥FS                     ≥ Data ≥ 02/12/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.  ≥                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
	Static Function BuSigno(cAlias)
		Local nTot := 0

		If (cAlias)->ESPECIE $GetSESTipos({|| ES_SINAL == "-"},"1")
			nTot := (cAlias)->TOT * (-1)
		Else
			nTot := (cAlias)->TOT
		EndIf

	return nTot


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcion   ≥ BuSigno   ≥ Autor ≥FS                     ≥ Data ≥ 02/12/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.  ≥                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function BuDesEsp(cEsp)
Local cDesc := " "

Do Case
	Case AllTrim(cEsp) == 'NF'
		cDesc := "Factura"
	Case AllTrim(cEsp) == 'CF'
		cDesc := "Cupon Fiscal"
	Case AllTrim(cEsp) == 'NDC'
		cDesc := "Nota de Debito"
	Case AllTrim(cEsp) == 'NCC'
		cDesc := "Nota de Credito"
	Otherwise
		cDesc := " "
EndCase

return cDesc    

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcion   ≥ DirecEntrg   ≥ Autor ≥FS                   ≥ Data ≥ 02/12/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.  ≥                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function DirecEntrg(cEsp,cPed,cCli,cLoja)
Local DescDirec:= ""

if Alltrim(cEsp)=='NF'
	DescDirec:=Posicione("SC5",1,xFilial("SC5")+cPed,"C5_XENDENT")
elseif Alltrim(cEsp)=='NDC'
	DescDirec:=Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_NOME")
Elseif Alltrim(cEsp)=='NCC'
	DescDirec:=Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_NOME")
EndIf
	 
Return DescDirec

Static Function usrPedido(cEsp,cPed)
Local cUser:= ""

if !empty(cPed)
	cUser:=Posicione("SC5",1,xFilial("SC5")+cPed,"C5_XUSERPT")
	If empty(cUser)
		cUser:=u_XUSRNAME(Posicione("SC5",1,xFilial("SC5")+cPed,"C5_ZUSERIN"))
	EndIF

EndIf
	 
Return cUser

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcion   ≥ DirecEntrg   ≥ Autor ≥FS                   ≥ Data ≥ 02/12/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.  ≥                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function DepEntrg(cEsp,cPed,cCli,cLoja)
Local DepDesc:= ""
Local DepSc5 := Posicione("SC5",1,xFilial("SC5")+cPed,"C5_XEST")
Local DepSA1 := Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_EST")

if Alltrim(cEsp)=='NF'
	DepDesc:=Posicione("SX5",1,xFilial("SX5")+"12"+DepSc5,"SX5->X5_DESCRI")
elseif Alltrim(cEsp)=='NDC'
	DepDesc:=Posicione("SX5",1,xFilial("SX5")+"12"+DepSA1,"SX5->X5_DESCRI")
Elseif Alltrim(cEsp)=='NCC'
	DepDesc:=Posicione("SX5",1,xFilial("SX5")+"12"+DepSA1,"SX5->X5_DESCRI")
EndIf
	 
Return DepDesc

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcion   ≥ DirecEntrg   ≥ Autor ≥FS                   ≥ Data ≥ 02/12/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descrip.  ≥                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function MunEntrg(cEsp,cPed,cCli,cLoja)
Local DescMun:= ""
Local MunSc5 := Posicione("SC5",1,xFilial("SC5")+cPed,"C5_XCOD_MU")
Local MunSA1 := Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_COD_MUN")

if Alltrim(cEsp)=='NF'
	DescMun:=Posicione("CC2",3,xFilial("CC2") + MunSc5,"CC2_MUN")
elseif Alltrim(cEsp)=='NDC'
	DescMun:=Posicione("CC2",3,xFilial("CC2") + MunSA1,"CC2_MUN")
Elseif Alltrim(cEsp)=='NCC'
	DescMun:=Posicione("CC2",3,xFilial("CC2") + MunSA1,"CC2_MUN")
EndIf
	 
Return DescMun

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥AjustaSx1  ∫Autor ≥Yamila Mikati       ∫ Data ≥  11/01/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Parametros del Reporte							          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function AjustaSX1()
	Local aArea := GetArea()
	Local aRegs := {}, i, j
	Local cPerg := ""
		cPerg := Padr("ARRFA005",Len(SX1->X1_GRUPO))

	DbSelectArea("SX1")
	DbSetOrder(1)

	aAdd(aRegs,{cPerg,"01","De Fecha		","De Fecha		","De Fecha 	","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
	aAdd(aRegs,{cPerg,"02","A Fecha			","A Fecha		","A Fecha		","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
	aAdd(aRegs,{cPerg,"03","De Cliente		","De Cliente	","De Cliente	","mv_ch3","C",20,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" } )
	aAdd(aRegs,{cPerg,"04","A Cliente		","A Cliente	","A Cliente	","mv_ch4","C",20,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","" } )
	aAdd(aRegs,{cPerg,"05","De Vendedor  	","De Vendedor 	","De Vendedor 	","mv_ch5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","" } )
	aAdd(aRegs,{cPerg,"06","A Vendedor  	","A Vendedor 	","A Vendedor 	","mv_ch6","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","" } )

	For i:=1 to Len(aRegs)
	   If !dbSeek(cPerg+aRegs[i,2])
		  RecLock("SX1",.T.)
		  For j:=1 to FCount()
			 If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			 Endif
		  Next
		  MsUnlock()
		Endif
	Next
	RestArea(aArea)
Return
