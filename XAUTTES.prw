#INCLUDE "TOTVS.CH"
#INCLUDE "MATR820.CH"
#INCLUDE "PROTHEUS.CH"
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR820  ³ Autor ³ Felipe Gonzalez      ³ Data ³ 21/06/23  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion automatizacion de Tes en pedidos de venta          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function XAUTTES(cModalidad,cProducto)
Local nTesprod
Local cManstock
Local nTesfinal

IF alltrim(cModalidad) == '0300113' .OR. alltrim(cModalidad) == '0300114'

    nTesprod    := Posicione("SB1",1,xfilial("SB1")+cProducto,"B1_TS")
    cManstock   := Posicione("SF4",1,xfilial("SF4")+nTesprod,"F4_ESTOQUE")

    IF cManstock == "S"
        nTesfinal := "805"
    else
        nTesfinal := "806"
    Endif    

elseif alltrim(cModalidad) == '0300102'
    
        nTesprod    := Posicione("SB1",1,xfilial("SB1")+cProducto,"B1_TS")
        cManstock   := Posicione("SF4",1,xfilial("SF4")+nTesprod,"F4_ESTOQUE")

    IF cManstock == "S"    
        nTesfinal := "888"
    else
        nTesfinal := "889"
    Endif     
Endif    

Return nTesfinal

