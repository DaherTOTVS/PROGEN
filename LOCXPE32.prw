/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBUSCASERIE บ Autor ณ M&H บ Data ณ  19/09/22				  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ 										                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ busca serie dependiendo el proceso                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/ 
#include 'protheus.ch'
#include 'parmtype.ch'

user function LOCXPE32()
Local aArea         := GetArea()
Local cFiltro       := ""

//Crear el parแmetro MV_XSERRMD, separar las serie por coma respetando el ancho del campo serie, estandar tamanho 3
If Funname() == "MATA462DN"		// Remito de dev de salida
	cFiltro := GetMV("MV_XSERRMD", .F., "DEV")                                                          
EndIf   

If Funname() == "MATA465N" .And. cEspecie = "NCC" //Notas de Credito  
	cFiltro := U_BUSCASERIE()   
Endif                                                                            

If Funname() == "MATA465N" .And. cEspecie = "NDC" //Notas de Debito
   cFiltro :=  U_BUSCASERIE() 
Endif  

If Funname() == "MATA467N"		// Factura Salida
	cFiltro := U_BUSCASERIE()                                                          
EndIf  

If Funname() == "Mata468n"		// Factura Salida
	cFiltro := U_BUSCASERIE()                                                          
EndIf  

If Funname()== 'MATA102DN'
	cFiltro := U_BUSCASERIE()  
EndIf

If Empty(cFiltro)

   MsgAlert("No hay serie asignada al tipo de Documento " + cEspecie + " o la serie no esta activa! Revisar tabla SFP - Control de Planillas")

Endif 

RestArea(aArea)

Return(cFiltro)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBUSCASERIE บ Autor ณ M&H บ Data ณ  19/09/22				  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ 										                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ busca serie dependiendo el proceso                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 

User Function BUSCASERIE()
Local cQuery  := ""
Local _cAlias := GetNextAlias()
Local cSerie  := ""
Local cSeries := "" 


cQuery:= " SELECT * FROM " + RetSqlName("SFP")
cQuery+= " WHERE D_E_L_E_T_ <> '*' "
cQuery+= " AND FP_FILUSO = '" + cFilAnt + "'"
 
If Funname() == "MATA465N" .And. cEspecie = "NDC"			   							
	cQuery += " AND FP_ATIVO = '1' "    
	cQuery+= "  AND FP_ESPECIE = '3'" 
EndIf
If Funname() == "MATA462DN"		   							
	cQuery += " AND FP_ATIVO = '1' "    
	cQuery+= "  AND FP_ESPECIE = '1'" 
EndIf    
If Funname() == "MATA467N"		   							
	cQuery += " AND FP_ATIVO = '1' "    
	cQuery+= "  AND FP_ESPECIE = '1'" 
EndIf  
//Mata468n
If Funname() == "Mata468n"		   							
	cQuery += " AND FP_ATIVO = '1' "    
	cQuery+= "  AND FP_ESPECIE = '1'" 
EndIf

If Funname() == "MATA102DN"
	cQuery += " AND FP_ATIVO = '1' "    
	cQuery+= "  AND FP_SERIE = 'RDV' " 
EndIF

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), _cAlias, .F., .T.)   
     
While (_cAlias)->(!EOF())
       
       cSerie:= (_cAlias)->FP_SERIE
       cSeries += cSerie + ","
    
dbSkip()

Enddo

Return(cSeries)
