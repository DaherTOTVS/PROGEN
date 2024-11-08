#INCLUDE "PROTHEUS.CH"

User Function XUSRNAME(USR)

  	Local UserCod  	:= USR
  	Local UserNome 	:=""
	Local aArea 	:= GetArea() 
	Local cAlias 	:= GetNextAlias()
	
	BeginSql Alias cAlias
			SELECT USR_ID,USR_CODIGO,USR_NOME
			FROM sys_usr
					WHERE
						(USR_CODIGO = %Exp:UserCod%
						OR USR_ID = %Exp:UserCod%)
						AND D_E_L_E_T_ <> '*'
	EndSql
		
	dbSelectArea(cAlias)
	dbGoTop()
	If  !(cAlias)->(Eof())
    	UserNome:=(cAlias)->USR_NOME
	else
		UserNome:=""
	EndIf
	(cAlias)->(dbclosearea())
	RestArea(aArea)

Return(UserNome)

