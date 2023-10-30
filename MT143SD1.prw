#Include "PROTHEUS.CH"
#include "Totvs.ch"

/*/
====================================================================================================
Data      : 17/08/2022
----------------------------------------------------------------------------------------------------
Autor     : Juan Pablo Astorga
----------------------------------------------------------------------------------------------------
Descricao : Copiar campos de lote y vencimiento para entrada de itens de invoice (DBC x SD1)
====================================================================================================
/*/

User Function MT143SD1()

	Local _aItens := PARAMIXB[1]

	aAdd( _aItens[Len( _aItens )], { "D1_LOTECTL", DBC->DBC_XLOTE  , Nil } )
	aAdd( _aItens[Len( _aItens )], { "D1_DTVALID", DBC->DBC_XVILOT , Nil } )
	aAdd( _aItens[Len( _aItens )], { "D1_XUNIDAD", DBC->DBC_XUNIDAD, Nil } )
	aAdd( _aItens[Len( _aItens )], { "D1_XLOCAL" , "097"			   , Nil } )

Return _aItens
