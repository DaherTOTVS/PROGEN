#include 'protheus.ch'
#Include "Topconn.ch"
user Function MC030PRJ()  
Local ExpA2 := PARAMIXB[2]  
Local ExpA3 := PARAMIXB[3] //Customização do usuário para manipulação dos campos do array na visualização da consulta do Kardex
Local cUsuariolog := upper(cusername)
Local cUsuariossincosto := upper(SuperGetMV("PG_USUNOCO",.F.,"")) 
//SACAR LA POSICION DE LOS CAMPOS DEL COSTO QUE SE ENCUENTRAN EN EL ARREGLO ExpA2 
nPosCProm := Ascan(ExpA2,{|x| AllTrim(x[1]) == "Costo Prom."})
nPoscTotal := Ascan(ExpA2,{|x| AllTrim(x[1]) == "Costo Total"})

//PARA LUEGO MODIFICAR LA DATA DE ESOS CAMPOS QUE SE ENCUENTRAN EN ExpA3
if !(cUsuariolog $ cUsuariossincosto)
    ExpA3[nPosCProm] := Replicate("*",TamSX3("D3_CUSTO1")[1])
    ExpA3[nPoscTotal] := Replicate("*",TamSX3("D3_CUSTO1")[1])
endif

Return {ExpA2, ExpA3}
