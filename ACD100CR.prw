#INCLUDE "Acda100.ch" 
#INCLUDE "PROTHEUS.CH"

User Function ACD100CR()

aCores := {	{ "CB7->CB7_DIVERG == '1'", "DISABLE"  },;
			{ "CB7->CB7_STATPA == '1'", "BR_CINZA" },;
			{ "CB7->CB7_STATUS $ '249'", "ENABLE"   },;
			{ "CB7->CB7_STATUS $ '135678'","BR_AMARELO" },;
			{ "CB7->CB7_STATUS == '0'", "BR_AZUL"  } }

Return aCores
