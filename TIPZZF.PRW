#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

User Function TIPZZF()
  Private cCadastro  := "Clase de producto"
  Private aRotina   := MenuDef()
  dbSelectArea("ZZF")
  dbSetOrder(1)
  mBrowse(6,1,22,75,"ZZF")
  dbSelectArea("ZZF")
  dbSetOrder(1)
Return(nil)

Static Function MenuDef()
  Private aRotina     := {}
  aAdd( aRotina, {"Buscar"  ,'AxPesqui',0,1})
  aAdd( aRotina, {"Visualizar"  ,'AxVisual',0,2})
  aAdd( aRotina, {"Incluir"       ,'axInclui',0,3})
  aAdd( aRotina, {"Modificar"       ,'AxAltera',0,4})
  aAdd( aRotina, {"Borrar"        ,'AxDeleta',0,5})
Return(aRotina)
