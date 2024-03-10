#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*-------------------------------------------------!
!RUTINA MVC PARA REGISTRO DE USUARIOS PORTAL VENTAS!
!                 JAVIER ROCHA                     !
--------------------------------------------------*/


// User Function DIRZZE()
// 	Local oBrowse
	
// 	oBrowse := FWMBrowse():New()
// 	oBrowse:SetAlias('ZZE')
// 	oBrowse:SetDescription('Dirección de clientes')
// 	oBrowse:Activate()
	
// RETURN

USER FUNCTION DIRZZE()
PRIVATE cCadastro  := "Dirección de clientes"
PRIVATE aRotina     := {}
AxCadastro("ZZE", OemToAnsi(cCadastro), '')
Return Nil
