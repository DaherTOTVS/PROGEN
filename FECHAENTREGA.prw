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
Local nDSB5      := 0
Local nDSA51     := 0
Local nDSA52     := 0
Local aAreaSC5   := SC5->( GetArea() )
Local aAreaSC6   := SC6->( GetArea() )
Local aAreaSB1   := SB1->( GetArea() )
Local aAreaSB5   := SB5->( GetArea() )

SB2->(dbSetOrder(1))  
SB2->(dbSeek(xFilial("SB2")+Producto+Deposito))
nSaldoDis := SALDOSB2()                             // Calcula el disponible actual

IF CantVta > nSaldoDis                              // Valida que el saldo disponible 
    SB1->(dbSeek(xFilial("SB1")+Producto)) 
    IF !EMPTY(AllTrim(SB1->B1_PROC))                // Valida que tenga Proveedor Estandar
        dbSelectArea("SB5")
		dbSetOrder(1)
        If MsSeek(xFilial("SB5") + SB1->B1_COD )
			nDSB5 := SB5->B5_PRZCQ
		EndIf
        dbclosearea("SB5")

        dbSelectArea("SA5")
		dbSetOrder(2)
        If MsSeek(xFilial("SA5") + SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC)
			nDSA51 := SA5->A5_PE
            nDSA52 := SA5->A5_TEMPTRA
		EndIf
        dbclosearea("SA5")

        nDias:= nDSB5 + nDSA51 + nDSA52
    ELSEIF SB1->B1_PE > 0                           // Si no tiene proveedor estandar 
        nDias := SB1->B1_PE                         // Fecha Entrega Producto
    ELSE
        nDias := 1               
    ENDIF

   /* SB1->(dbSeek(xFilial("SB1")+Producto)) 
    IF !EMPTY(AllTrim(SB1->B1_PROC))                // Valida que tenga Proveedor Estandar
        nDias := POSICIONE("SA5",2,XFILIAL("SA5")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC,"A5_PE") 
        nDias := nDias + POSICIONE("SA5",2,XFILIAL("SA5")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC,"A5_TEMPTRA")
        nDias := nDias + POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_PRZCQ")
        
                                                    // Fecha Entrega + Tiempo Trasporte
    ELSEIF SB1->B1_PE > 0                           // Si no tiene proveedor estandar 
        nDias := SB1->B1_PE                         // Fecha Entrega Producto
    ELSE
        nDias := 1               
    ENDIF*/
 ELSE   
//     SB1->(dbSeek(xFilial("SB1")+Producto)) 
//     IF !EMPTY(AllTrim(SB1->B1_PROC))                // Valida que tenga Proveedor Estandar
//         dbSelectArea("SB5")
// 		dbSetOrder(1)
//         If MsSeek(xFilial("SB5") + SB1->B1_COD )
// 			nDSB5 := SB5->B5_PRZCQ
// 		EndIf
//         dbclosearea("SB5")

//         dbSelectArea("SA5")
// 		dbSetOrder(2)
//         If MsSeek(xFilial("SA5") + SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC)
// 			nDSA51 := SA5->A5_PE
//             nDSA52 := SA5->A5_TEMPTRA
// 		EndIf
//         dbclosearea("SA5")

//         nDias:= nDSB5 + nDSA51 + nDSA52
//     ELSEIF SB1->B1_PE > 0                           // Si no tiene proveedor estandar 
//         nDias := SB1->B1_PE                         // Fecha Entrega Producto
//     ELSE
        nDias := 1               
//     ENDIF
//     // nDias := 1  13.09.2024                
ENDIF

RestArea( aAreaSC5 )
RestArea( aAreaSC6 )
RestArea( aAreaSB1 )
RestArea( aAreaSB5 )

Return nDias



