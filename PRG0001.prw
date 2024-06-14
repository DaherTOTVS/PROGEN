#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#Define STR_PULA    Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRG0001ºAutor  ³Juan Pablo Astorga  ºFecha ³   03/05/2024   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impresión de reporte de comisiones PROGEN                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PRG0001()
Private cPerg 		:= "PRG0001"
AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf

RptStatus({|| U_Genreport()}, "Aguarde...", "Ejecutando el reporte de comisiones...")

Return

User Function Genreport()

Local CQry      	:= ""
Local cQuery  		:= ""
Local cQrys			:= ""
Local cQuerys		:= ""
Local cQuerySE5		:= ""
Local aArea         := GetArea()
Local cArquivo    	:= GetTempPath()+'comisionprogen.xml'
Local cAlisTrb 		:= GetNextAlias()
Local cAliasSel		:= GetNextAlias()
Local cSelCmp		:= GetNextAlias()
Local cSelAnt		:= GetNextAlias()
Local cAliasSe5		:= GetNextAlias()
Local cValorIva		:= 0
Local cTotalIva		:= 0
Local cIva          := 0
Local cTotalIva1	:= 0
Local cIva1         := 0
Local cRetIvaSF2	:= 0
Local cRetIvaSF1	:= 0
Local oFWMsExcel
Local oExcel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: 
Descripcion : Query para recaudos serie REC
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
  
CQry:="SELECT EL_RECIBO, EL_EMISSAO, EL_FILIAL, EL_TIPODOC, EL_NATUREZ, EL_NUMERO, EL_PARCELA, EL_BANCO, EL_AGENCIA, EL_CONTA, EL_DESCONT, EL_SERIE , EL_PREFIXO , EL_CLIORIG , EL_LOJORIG , EL_DTDIGIT , EL_DTVCTO, "
CQry+="EL_CLIENTE , EL_LOJA , EL_PARCELA , EL_TIPO , CASE WHEN EL_PREFIXO IN ('NCC','DC') THEN (EL_VALOR*-1) ELSE EL_VALOR END AS VALOR "
CQry+="FROM "+RetSqlName("SEL")+" SEL 
CQry+="WHERE EL_SERIE =  'REC' "
CQry+="AND SEL.D_E_L_E_T_ = '' "
CQry+="AND EL_DTDIGIT >= '"+Dtos(MV_PAR01)+"' " 
CQry+="AND EL_DTDIGIT <= '"+DtoS(MV_PAR02)+"' " 
CQry+="AND EL_TIPODOC NOT IN ('TF','EF','CH') " 
CQry+="ORDER BY EL_RECIBO " 
cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TopCann",TcGenQry(,,cQry ),cAlisTrb,.T.,.T.)

//Criando o objeto que irá gerar o conteúdo do Excel

oFWMsExcel := FWMSExcel():New()
oFWMsExcel:AddworkSheet("Comisiones-REC")
oFWMsExcel:AddworkSheet("Comisiones-CMP") 
oFWMsExcel:AddworkSheet("Comisiones-ANT") 
oFWMsExcel:AddworkSheet("Comisiones-CEC") 

//Criando a Tabela COMISIONES - REC 
oFWMsExcel:AddTable("Comisiones-REC","Comisiones Progen-REC")
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Cliente",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Nombre Cliente",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Fecha Digitalizacion",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Serie",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Numero Recibo",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Valor total con IVA",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Valor Aplicado",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Emision Doc.",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Vencimiento Doc",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Prefixo",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Numero Doc",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Total",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Val Iva",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Total mas Iva",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","RetIva",1)
oFWMsExcel:AddColumn("Comisiones-REC","Comisiones Progen-REC","Valor sin Retencion",1)
		
While (cAlisTrb)->(!eof())
	cQuery := " SELECT SUM(EL_VALOR) AS TOTAL FROM SEL010 SEL  WHERE  EL_SERIE = 'REC' AND  SEL.D_E_L_E_T_ = ' ' "
	cQuery += " AND EL_DTDIGIT >='"+Dtos(MV_PAR01)+"' AND EL_DTDIGIT <= '"+Dtos(MV_PAR02)+"' AND EL_TIPODOC='TF' AND EL_RECIBO ='"+(cAlisTrb)->EL_RECIBO+"' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TopCann",TcGenQry(,,cQuery ),cAliasSel,.T.,.T.)
	if (cAliasSel)->(!EOF())
		cValorIva:= (cAliasSel)->TOTAL
	EndIf
	(cAliasSel)->(DbCloseArea())
	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   indice(1)                                                                                                               
	cTotalIva 		:= Posicione("SE1",1,Xfilial("SE1")+(cAlisTrb)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALOR") 
	cIva	  		:= IF(Alltrim((cAlisTrb)->EL_PREFIXO)=='NCC',Posicione("SE1",1,Xfilial("SE1")+(cAlisTrb)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALIMP1")*-1,Posicione("SE1",1,Xfilial("SE1")+(cAlisTrb)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALIMP1"))
	cRetIvaSF2		:= Posicione("SF2",1,xFilial("SF2")+(cAlisTrb)->(EL_NUMERO+EL_PREFIXO+EL_CLIORIG),"F2_VALIMP2")	// Juan Pablo Astorga 24.05.2024
	cRetIvaSF1		:= Posicione("SF1",1,xFilial("SF1")+(cAlisTrb)->(EL_NUMERO+EL_PREFIXO+EL_CLIORIG),"F1_VALIMP2")	// Juan Pablo Astorga 24.05.2024
	oFWMsExcel:AddRow("Comisiones-REC","Comisiones Progen-REC",{;
	(cAlisTrb)->EL_CLIORIG			,;
	Posicione("SA1",1,xFilial("SA1")+(cAlisTrb)->EL_CLIORIG	+(cAlisTrb)->EL_LOJORIG	,"A1_NOME")	,;
	Stod((cAlisTrb)->EL_DTDIGIT)	,;
	(cAlisTrb)->EL_SERIE			,;
	(cAlisTrb)->EL_RECIBO			,;
	cValorIva						,;
	(cAlisTrb)->VALOR 				,;
	Stod((cAlisTrb)->EL_EMISSAO)	,;
	Stod((cAlisTrb)->EL_DTVCTO)		,;
	(cAlisTrb)->EL_PREFIXO			,;
	(cAlisTrb)->EL_NUMERO			,;
	cTotalIva-cIva					,;
	cIva							,;
	IF(Alltrim((cAlisTrb)->EL_PREFIXO)=='NCC',cTotalIva*-1,cTotalIva)			,;
	IF(Alltrim((cAlisTrb)->EL_PREFIXO)=='NCC',cRetIvaSF1*-1,cRetIvaSF2)			,;
	IF(Alltrim((cAlisTrb)->EL_PREFIXO)=='NCC',(cTotalIva+cRetIvaSF1)*-1,cTotalIva+cRetIvaSF2);
	})
	(cAlisTrb)->(DbSkip())
EndDo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: 
Descripcion : Query para la generacion de cruce de documentos serie CMP
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

cQrys:="SELECT EL_RECIBO, EL_EMISSAO, EL_FILIAL, EL_TIPODOC, EL_NATUREZ, EL_NUMERO, EL_PARCELA, EL_BANCO, EL_AGENCIA, EL_CONTA, EL_DESCONT, EL_SERIE , EL_PREFIXO , EL_CLIORIG , EL_LOJORIG , EL_DTDIGIT , EL_DTVCTO, "
cQrys+="EL_CLIENTE , EL_LOJA , EL_PARCELA , EL_TIPO , CASE WHEN EL_TIPO IN('NCC','RA') THEN (EL_VALOR*-1) ELSE EL_VALOR END AS VALOR "
cQrys+="FROM "+RetSqlName("SEL")+" SEL 
cQrys+="WHERE EL_SERIE =  'CMP' "
cQrys+="AND SEL.D_E_L_E_T_ = '' "
cQrys+="AND EL_DTDIGIT >= '"+Dtos(mv_par01)+"' " 
cQrys+="AND EL_DTDIGIT <= '"+Dtos(mv_par02)+"' " 
cQrys+="AND EL_TIPODOC NOT IN ('TF','EF','CH') " 
cQrys+="ORDER BY EL_RECIBO " 
cQrys := ChangeQuery(cQrys)
DbUseArea(.T.,"TopCann",TcGenQry(,,cQrys ),cSelCmp,.T.,.T.)

oFWMsExcel:AddTable("Comisiones-CMP","Comisiones Progen-CMP")
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Cliente",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Nombre Cliente",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Fecha Digitalizacion",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Serie",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Numero Recibo",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Valor total con IVA",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Valor Aplicado",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Emision Doc.",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Vencimiento Doc",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Prefixo",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Numero Doc",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Tipo Doc",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Total",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Val Iva",1)
oFWMsExcel:AddColumn("Comisiones-CMP","Comisiones Progen-CMP","Total mas Iva",1)

While (cSelCmp)->(!eof())
	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   indice(1)                                                                                                               
	cTotalIva1 		:= Posicione("SE1",1,Xfilial("SE1")+(cSelCmp)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALOR")   
	cIva1	  		:= IF(Alltrim((cSelCmp)->EL_PREFIXO)$'NCC|RA',Posicione("SE1",1,Xfilial("SE1")+(cAlisTrb)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALIMP1")*-1,Posicione("SE1",1,Xfilial("SE1")+(cSelCmp)->(EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO),"E1_VALIMP1"))
	oFWMsExcel:AddRow("Comisiones-CMP","Comisiones Progen-CMP",{;
	(cSelCmp)->EL_CLIORIG			,;
	Posicione("SA1",1,xFilial("SA1")+(cSelCmp)->EL_CLIORIG	+(cSelCmp)->EL_LOJORIG	,"A1_NOME")	,;
	Stod((cSelCmp)->EL_DTDIGIT)	,;
	(cSelCmp)->EL_SERIE			,;
	(cSelCmp)->EL_RECIBO			,;
	0								,;
	(cSelCmp)->VALOR 				,;
	Stod((cSelCmp)->EL_EMISSAO)		,;
	Stod((cSelCmp)->EL_DTVCTO)		,;
	(cSelCmp)->EL_PREFIXO			,;
	(cSelCmp)->EL_NUMERO			,;
	(cSelCmp)->EL_TIPO				,;
	IF(Alltrim((cSelCmp)->EL_PREFIXO)$'NCC|RA',(cTotalIva1-cIva1)*-1,cTotalIva1-cIva1),;
	IF(Alltrim((cSelCmp)->EL_PREFIXO)$'NCC|RA',(cIva1)*-1,cIva1)			,;
	IF(Alltrim((cSelCmp)->EL_PREFIXO)$'NCC|RA',cTotalIva1*-1,cTotalIva1)	;
	})
	(cSelCmp)->(DbSkip())
EndDo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: 
Descripcion : Query para la generacion de Anticipo serie ANT
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

cQuerys:="SELECT EL_RECIBO, EL_EMISSAO, EL_FILIAL, EL_TIPODOC, EL_NATUREZ, EL_NUMERO, EL_PARCELA, EL_BANCO, EL_AGENCIA, EL_CONTA, EL_DESCONT, EL_SERIE , EL_PREFIXO , EL_CLIORIG , EL_LOJORIG , EL_DTDIGIT , EL_DTVCTO, "
cQuerys+="EL_CLIENTE , EL_LOJA , EL_PARCELA , EL_TIPO , EL_VALOR  "
cQuerys+="FROM "+RetSqlName("SEL")+" SEL 
cQuerys+="WHERE EL_SERIE =  'ANT' "
cQuerys+="AND SEL.D_E_L_E_T_ = '' "
cQuerys+="AND EL_DTDIGIT >= '"+Dtos(mv_par01)+"' " 
cQuerys+="AND EL_DTDIGIT <= '"+Dtos(mv_par02)+"' " 
cQuerys+="AND EL_TIPODOC NOT IN ('TF','EF','CH') " 
cQuerys+="ORDER BY EL_RECIBO " 
cQuerys := ChangeQuery(cQuerys)
DbUseArea(.T.,"TopCann",TcGenQry(,,cQuerys ),cSelAnt,.T.,.T.)

//Criando a Tabela COMISIONES - ANT
oFWMsExcel:AddTable("Comisiones-ANT","Comisiones Progen-ANT")
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Cliente",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Nombre Cliente",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Fecha Digitalizacion",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Serie",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Numero Recibo",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Tipo Doc",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Valor total con IVA",1)
oFWMsExcel:AddColumn("Comisiones-ANT","Comisiones Progen-ANT","Valor Aplicado",1)

While (cSelAnt)->(!eof())	
	oFWMsExcel:AddRow("Comisiones-ANT","Comisiones Progen-ANT",{;
	(cSelAnt)->EL_CLIORIG			,;
	Posicione("SA1",1,xFilial("SA1")+(cSelAnt)->EL_CLIORIG+(cSelAnt)->EL_LOJORIG,"A1_NOME")	,;
	Stod((cSelAnt)->EL_DTDIGIT)	,;
	(cSelAnt)->EL_SERIE			,;
	(cSelAnt)->EL_RECIBO		,;
	(cSelAnt)->EL_TIPO			,;
	(cSelAnt)->EL_VALOR 		,;
	(cSelAnt)->EL_VALOR 		;
	})
	(cSelAnt)->(DbSkip())
EndDo	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: 
Descripcion : Query para la generacion de cruce de carteres serie CEC
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

cQuerySE5:="SELECT E5_IDENTEE,E5_DATA,E5_TIPO,E5_VALOR,E5_RECPAG,E5_BENEF,E5_PREFIXO,E5_NUMERO,E5_CLIFOR,E5_LOJA "
cQuerySE5+="FROM "+RetSqlName("SE5")+" SE5 
cQuerySE5+="WHERE E5_MOTBX = 'CEC' "
cQuerySE5+="AND SE5.D_E_L_E_T_ = '' "
cQuerySE5+="AND E5_DATA >= '"+Dtos(mv_par01)+"' " 
cQuerySE5+="AND E5_DATA <= '"+Dtos(mv_par02)+"' "
cQuerySE5+="AND E5_SITUACA NOT IN ('C','X')  " 
cQuerySE5+="ORDER BY E5_IDENTEE " 
cQuerySE5:= ChangeQuery(cQuerySE5)
DbUseArea(.T.,"TopCann",TcGenQry(,,cQuerySE5),cAliasSe5,.T.,.T.)

oFWMsExcel:AddTable("Comisiones-CEC","Comisiones Progen-CEC")
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Cliente",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Nombre Cli/Prov",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Fecha Digitalizacion",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Serie",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Numero Recibo",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Valor Aplicado",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Recibo/Pago",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Emision Doc.",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Vencimiento Doc",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Prefixo",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Numero Doc",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Total",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Iva",1)
oFWMsExcel:AddColumn("Comisiones-CEC","Comisiones Progen-CEC","Total mas Iva",1)
While (cAliasSe5)->(!eof())	
	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO   (indice 1) 
	// E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO  (indice 6)                                                                                              
	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO (indice 2)     
	// E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO (indice 2)                                                                                                                                                                                         
	oFWMsExcel:AddRow("Comisiones-CEC","Comisiones Progen-CEC",{;
	(cAliasSe5)->E5_CLIFOR		,;
	(cAliasSe5)->E5_BENEF		,;
	Stod((cAliasSe5)->E5_DATA)	,;
	"CEC"						,;
	(cAliasSe5)->E5_IDENTEE		,;
	(cAliasSe5)->E5_VALOR		,;
	(cAliasSe5)->E5_RECPAG		,;
	IF(Alltrim((cAliasSe5)->E5_RECPAG)=="P",Posicione("SE2",6,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E2_EMISSAO"),Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_EMISSAO")) ,;
	IF(Alltrim((cAliasSe5)->E5_RECPAG)=="P",Posicione("SE2",6,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E2_VENCTO"),Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_VENCTO")) 	,;
	(cAliasSe5)->E5_PREFIXO		,;
	(cAliasSe5)->E5_NUMERO		,;
	IF(Alltrim((cAliasSe5)->E5_RECPAG)=="P",Posicione("SE2",6,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E2_VALOR")-Posicione("SF1",1,xFilial("SF1")+(cAliasSe5)->E5_NUMERO+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA,"F1_VALIMP1"),Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_VALOR")-Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_VALIMP1")) ,;
	IF(Alltrim((cAliasSe5)->E5_RECPAG)=="P",Posicione("SF1",1,xFilial("SF1")+(cAliasSe5)->E5_NUMERO+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA,"F1_VALIMP1"),Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_VALIMP1")) ,;
	IF(Alltrim((cAliasSe5)->E5_RECPAG)=="P",Posicione("SE2",6,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E2_VALOR"),Posicione("SE1",2,xFilial("SE2")+(cAliasSe5)->E5_CLIFOR+(cAliasSe5)->E5_LOJA+(cAliasSe5)->E5_PREFIXO+(cAliasSe5)->E5_NUMERO,"E1_VALOR")) ;
	})
	(cAliasSe5)->(DbSkip())
EndDo

//Ativando o arquivo e gerando o xml
oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArquivo)
//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()             	//Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArquivo)     	//Abre uma planilha
oExcel:SetVisible(.T.)                 	//Visualiza a planilha
oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
(cAlisTrb)->(DbCloseArea())
(cSelCmp)->(DbCloseArea())
(cSelAnt)->(DbCloseArea())
(cAliasSe5)->(DbCloseArea())
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Programa: AjustaSX1
Titulo	:
Fecha	: 08/05/2024
Autor 	: Juan Pablo Astorga
Descripcion : Pregunta para la reporte de comisiones de PROGEN
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Static Function AjustaSX1(cPerg)

Local aArea := GetArea()
Local aRegs := {}, i, j

cPerg := Padr(cPerg,Len(SX1->X1_GRUPO))
DbSelectArea("SX1")
DbSetOrder(1)
aAdd(aRegs,{cPerg,"01","Data de","Desde fecha","From Date","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data ate","Hasta fecha","To Date","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
