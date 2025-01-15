#include "protheus.ch"
#INCLUDE "rwmake.ch"                                 
#INCLUDE "RPTDEF.CH"

User Function A175ALMO()
	
	Local aArea 	:= GetArea()
	
	Local cLocPad    := PARAMIXB[1] 
	Local cLocPe     := Ascan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST" } ) 
	cLocPad:= SD1->D1_XLOCAL
	       	

	RestArea( aArea )



Return cLocPad

