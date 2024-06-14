#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

User Function FUNFM1()
  Private cCadastro  := "Funcionarios"
  Private aRotina   := MenuDef()
  dbSelectArea("FM1")
  dbSetOrder(1)
  mBrowse(6,1,22,75,"FM1")
  dbSelectArea("FM1")
  dbSetOrder(1)
Return(nil)

Static Function MenuDef()
  Private aRotina     := {}
  aAdd( aRotina, {"Buscar"  ,'AxPesqui',0,1})
  aAdd( aRotina, {"Visualizar"  ,'AxVisual',0,2})
  aAdd( aRotina, {"Incluir"       ,'axInclui',0,3})
  aAdd( aRotina, {"Modificar"       ,'AxAltera',0,4})
Return(aRotina)
