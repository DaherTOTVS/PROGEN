#INCLUDE "rwmake.ch"
#include "totvs.ch"
#include "protheus.ch"
#include 'topconn.ch'
#INCLUDE "TbiConn.ch"
#include 'parmtype.ch'
#Include 'FWMVCDEF.ch'

/* **********************************************************

         _.-'~~~~~~'-._            | Funcion: 		MT311ROT()                                        
        /      ||      \           |                                        
       /       ||       \          | Descripcion: 	Punto de entrada agregar botones a la pantalla de  
      |        ||        |         | 			    	    Solicitud de transferencia                      
      | _______||_______ |         |                                        
      |/ ----- \/ ----- \|         | Parametros:    	                                        
     /  (     )  (     )  \        | 				                                       
    / \  ----- () -----  / \       |                                        
   /   \      /||\      /   \      | Retorno:       aRet := Array con los botones a agregar		                                        
  /     \    /||||\    /     \     |
 /       \  /||||||\  /       \    |                                        
/_        \o========o/        _\   | Autor:  Victor Limaco H.                                     
  '--...__|'-._  _.-'|__...--'     |                                        
          |    ''    |             |
************************************************************** */


User Function MA650BUT()
    Local aRet := Paramixb // Array contendo os botoes padroes da rotina.
    // Tratamento no array aRet para adicionar novos botoes e retorno do novo array.
    ADD OPTION aRet TITLE "Imprime OP" ACTION "U_XMATR820()" OPERATION 4 ACCESS 0
Return aRet
