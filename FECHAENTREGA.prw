#INCLUDE 'rwmake.ch'
#INCLUDE 'Protheus.ch'

// PROGRAMA PARA CALCULAR AL FECHA APROX DE ENTREGA DEL PRODUCTO
// CLIENTE : PROGEN
// AUTOR   : M&H - NSJ - ES
// FECHA   : 06-OCT-2022
// RETORNO : UNA FECHA CALCULADA DE ENTREGA APROX
// DESCRIP : SE TOMA LA FECHA DE ENTREGA DE LA TAVLA SB1 SI ES UN PRODUCTO PRODUCCIDO INTERNAMENTE
//           SI NO SE TOMA LAS INFORMAION DE LA TABLA SA5 

User Function FechaEntrega(Producto,Deposito,CantVta)

Local nSaldoDis  := 0
Local nDias      := 0

SB2->(dbSetOrder(1))  
SB2->(dbSeek(xFilial("SB2")+Producto+Deposito))
nSaldoDis := SALDOSB2()                             // Calcula el disponible actual

IF CantVta > nSaldoDis                              // Valida que el saldo disponible 
    SB1->(dbSeek(xFilial("SB1")+Producto)) 
    IF !EMPTY(AllTrim(SB1->B1_PROC))                // Valida que tenga Proveedor Estandar
        nDias := POSICIONE("SA5",2,XFILIAL("SA5")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC,"A5_PE") 
        nDias := nDias + POSICIONE("SA5",2,XFILIAL("SA5")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC,"A5_TEMPTRA")
        nDias := nDias + POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_PRZCQ")
        
                                                    // Fecha Entrega + Tiempo Trasporte
    ELSEIF SB1->B1_PE > 0                           // Si no tiene proveedor estandar 
        nDias := SB1->B1_PE                         // Fecha Entrega Producto
    ELSE
        nDias := 1               
    ENDIF
ELSE   
    nDias := 1                
ENDIF

Return nDias



