#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  MA330FIN   บAutor  ณTdeP Bolivia บ Data ณ03/04/17บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Punto de entrada que es ejecutado Antes del procesamiento  บฑฑ
ฑฑบ          ณ del recalculo de Costo Medio                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARIMEX Argentina                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function MA330FIM()
	
	Local StrSql:=""

	StrSql := " UPDATE D11 SET D11.D1_CUSTO = D12.D1_CUSTO "
	StrSql += " FROM " + RETSQLNAME('SD1')+ " D11 "
	StrSql += " INNER JOIN " + RETSQLNAME('SD1')+ " D12 "
	StrSql += " ON D12.D1_DOC=D11.D1_REMITO "
	StrSql += " AND D12.D1_ESPECIE='RFD' "
	StrSql += " AND D12.D_E_L_E_T_ <>'*' "
	StrSql += " AND D12.D1_CUSTO <> D11.D1_CUSTO "
	StrSql += " AND D11.D1_ITEMREM = D12.D1_ITEM "
	StrSql += " WHERE D11.D_E_L_E_T_ <>'*'  AND D11.D1_ESPECIE IN ('NCC') AND LEN(TRIM(D11.D1_REMITO))>0 "
	StrSql += " AND D11.D1_DTDIGIT >= '" + DTOS(GetMv("MV_ULMES")+1) + "'"


	If tcSQLexec(StrSql) < 0   //para verificar si el query funciona
		MsgAlert("ERROR AL ACTUALIZAR COSTO NCC")
		return .F.
	EndIf

Return .T.
