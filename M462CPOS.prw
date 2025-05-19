#Include 'RwMake.ch'
#Include 'Protheus.ch'
#Include "TOPCONN.CH"
#INCLUDE "Acda100x.ch"

/*-----------------------------------------------------------------------!
!   Punto de entrada para mostrar campos adicionales en el browse al     !
!    seleccionar pedidos en la rutina MATA462AN Generación de Remitos    !
!                           Duvan Hernandez                  		     !
!                             08/05/2025                          		 !
------------------------------------------------------------------------*/

User Function M462CPOS()

Local   aArea := getarea()
Local   aCampos := {"C9_XSTATOS"} // Array de nombres de campo virtuales a incluir en el MarkBrow.

RestArea(aArea)
Return aCampos

User Function RetStatus(cOrdSep)
	Local cDescri := ""
    If !Empty(cOrdSep)
        cStatus := POSICIONE("CB7",1,XFILIAL("CB7")+cOrdSep,"CB7_STATUS")     

        If Empty(cStatus) .or. cStatus == "0"
            cDescri:= STR0073 //"Nao iniciado"
        ElseIf cStatus == "1"
            cDescri:= STR0074 //"Em separacao"
        ElseIf cStatus == "2"
            cDescri:= STR0075 //"Separacao finalizada"
        ElseIf cStatus == "3"
            cDescri:= STR0076 //"Em processo de embalagem"
        ElseIf cStatus == "4"
            cDescri:= STR0077 //"Embalagem Finalizada"
        ElseIf cStatus == "5"
            cDescri:= STR0078 //"Nota gerada"
        ElseIf cStatus == "6"
            cDescri:= STR0079 //"Nota impressa"
        ElseIf cStatus == "7"
            cDescri:= STR0080 //"Volume impresso"
        ElseIf cStatus == "8"
            cDescri:= STR0081 //"Em processo de embarque"
        ElseIf cStatus == "9"
            cDescri:=  STR0082 //"Finalizado"
        EndIf
    EndIf

Return(cDescri)
