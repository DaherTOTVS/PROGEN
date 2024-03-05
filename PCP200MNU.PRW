#INCLUDE "Protheus.ch"
#INCLUDE "XPCPA200.CH"
 
User Function PCP200MNU()

    // aRotina := {}
 
    /*Estrutura do array aRotina:
        1. Nome da opção no menu
        2. Função executada pela opção
        3. Reservado
        4. Tipo de Transação a ser efetuada
        5. Nivel de acesso
        6. Habilita Menu Funcional*/
    AADD(aRotina, {"Sustituir NEW", "U_XA200Subst()", 0, 1, 0, NIL})


	// ADD OPTION aRotina TITLE STR0002 ACTION "PCPA200MNU(2)" OPERATION OP_VISUALIZAR ACCESS 0 //"Visualizar"
	// ADD OPTION aRotina TITLE STR0003 ACTION "PCPA200MNU(3)" OPERATION OP_INCLUIR    ACCESS 0 //"Incluir"
	// ADD OPTION aRotina TITLE STR0004 ACTION "PCPA200MNU(4)" OPERATION OP_VISUALIZAR ACCESS 13 //"Alterar" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0005 ACTION "PCPA200MNU(5)" OPERATION OP_VISUALIZAR ACCESS 14 //"Excluir" - OP_EXCLUIR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0079 ACTION 'A200CEstN()'   OPERATION OP_VISUALIZAR ACCESS 0 //"Comparar"
	// ADD OPTION aRotina TITLE STR0131 ACTION 'A200Subst()'   OPERATION OP_VISUALIZAR ACCESS 0 DISABLE MENU //"Substituir" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0164 ACTION 'A200Copia()' 	OPERATION OP_VISUALIZAR ACCESS 0 //"Estrutura Similar" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0181 ACTION 'P200Oper()'    OPERATION OP_VISUALIZAR ACCESS 0 //"Operações x Componente" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0243 ACTION 'P200MapDiv()'  OPERATION OP_VISUALIZAR ACCESS 0 //"Mapa de Divergências" - OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	// ADD OPTION aRotina TITLE STR0250 ACTION 'P200Recur()'   OPERATION OP_VISUALIZAR ACCESS 0 // "Recursividade"

 
Return Nil
