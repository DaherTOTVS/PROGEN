#Include "PROTHEUS.CH"
#include "fileIO.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include 'totvs.ch'


Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE_ESCURO")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_AZUL")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PINK")
Static oOk			:= LoadBitmap( GetResources(), "LBOK" )
Static oNo			:= LoadBitmap( GetResources(), "LBNO" )


User Function SQLEXEC()
  _SQLEXEC()
Return

Static Function _SQLEXEC()
    
Local oButton1
Local oButton2
Local oSim          := LoadBitmap(GetResources(), "ENABLE")
Local oNao          := LoadBitmap(GetResources(), "DISABLE")
Private oApunte
Private aApunte     := {}
Private aItens      := {}
Private lMsErroAuto :=.F.
Private lMsHelpAuto :=.T.
Private cFontUti   := "Tahoma"
Private oFontAno   := TFont():New(cFontUti,,-38)
Private oFontSub   := TFont():New(cFontUti,,-20)
Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
Private oDlCargEX

DEFINE MSDIALOG oDlCargEX TITLE "EXEC Sentencias SQl " FROM 000, 000  TO 400, 1200 PIXEL
@ 005, 007 SAY "Seleccione el archivo .CSV para la carga " SIZE 200, 030 FONT oFontSub  OF oDlCargEX COLORS RGB(031,073,125) PIXEL

DEFINE MSDIALOG oDlg TITLE "Actualizacion Masiva de Datos" FROM 000, 000  TO 400, 1200 PIXEL
@ 005, 007 SAY "Seleccione el archivo .CSV para la carga " SIZE 200, 030 FONT oFontSub OF oDlg COLORS RGB(031,073,125) PIXEL

oApunte := TCBrowse():New(050, 005,560, 120,,,,oDlCargEX,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oApunte:AddColumn(TCColumn():New(" "       	, {|| If(aApunte[oApunte:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
oApunte:AddColumn(TCColumn():New("TIPO "  	        , {|| aApunte[oApunte:nAt,02]},"@!",,,"CENTER", 002,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("TABLA "  	, {|| aApunte[oApunte:nAt,03]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("CAMPOS"         , {|| aApunte[oApunte:nAt,04]},"@!",,,"CENTER", 025,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("CONDICION"     	, {|| aApunte[oApunte:nAt,05]},"@!",,,"CENTER", 002,.F.,.F.,,{|| .F. },,.F., ) )

oApunte:SetArray(aApunte)  //Define um array para o browse
oApunte:bWhen      := { || Len(aApunte) > 0 } //Se o array estiver vazio, o browse fica desabilitado
oApunte:Refresh()

@ 181, 150 BUTTON oButton1 PROMPT "Importar" SIZE 037, 012 OF oDlCargEX ACTION u_ImpoSql() PIXEL
@ 181, 250 BUTTON oButton1 PROMPT "Grabar" SIZE 037, 012 OF oDlCargEX ACTION  Processa({|| U_GrabSql(aApunte)}, "Processando ... Por favor espere ...") PIXEL
@ 181, 350 BUTTON oButton2 PROMPT "Cerrar" SIZE 037, 012 OF oDlCargEX ACTION oDlCargEX:End() PIXEL

ACTIVATE MSDIALOG oDlCargEX CENTERED

Return

//-----------------------------------------------------------------------------
// carga los datos de extracto en grid
//-----------------------------------------------------------------------------
USer Function ImpoSql()
    Local nCont             := 0
    Local i                 := 0
    Local nLinhas           := 0
    Local _aStr             := {{"Texto","C",1000,0}}
    Local _cTmp             := CriaTrab(NIL,.F.)
    Local lEnd              := .F.
    Private cArquivo        := cGetFile("Arquivos CSV|*.CSV|Arquivo TXT|*.TXT","Selecione o arquivo",0,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD,.F.)
    if !file(Alltrim(cArquivo))
        Alert("Arquivo "+Alltrim(cArquivo)+" Archivo no Valido!"+CRLF+"Cancelando Importe !")
        Return
    Endif
    dbCreate(_cTmp,_aStr)
    IF SELECT("TRB") # 0
        TRB->(dbCloseArea())
    ENDIF
    DBUseArea(.T.,,_cTmp,"TRB",.F.,.F.)
    if AT(":\",cArquivo)>0
        CpyT2S( cArquivo, GetSrvProfString("Startpath",";") )
    Else
        CpyT2S( cArquivo, GetSrvProfString("Startpath","") )
    endif
    Append From &cArquivo SDF
    TRB->(dbGoTop())
    nLinhas             := TRB->(RecCount())
    ProcRegua(nLinhas)
    aApunte             := {}
    While TRB->(!Eof())
        nCont++
        If lEnd
            MsgInfo("Cancelado!","Finalizado")
            exit
        Endif
        IF nCont > nLinhas
            exit
        endif
        IncProc("Leyendo Archivo...Linea No "+Alltrim(str(nCont)))
        cLinha              := ALLTRIM(UPPER(TRB->Texto))
        if !empty(cLinha)
            aadd(aItens,Separa(cLinha,";",.T.))
        endif
        DbSkip()
    EndDo
    TRB->(dbCloseArea())
    Ferase(_cTmp+".DBF")
    For i := 1 to len(aItens)
        IncProc("Insertando registros item "+ Alltrim(aItens[i,1])+"...")
        
        lLege               := .T.

        If (Alltrim(aItens[i][1])) # "UPDATE"
            lLege := .F.
        EndIf
            aadd(aApunte,{lLege,;
            (aItens[i][1]),;            // TIPO
            (RetSqlname(aItens[i][2])),;            // TABLA 
            (aItens[i][3]),;            // CAMPOS
            (aItens[i][4]),;            // CONDICION
            " AND D_E_L_E_T_ <>'*' ",;            // DELETE
            })
    Next
    oApunte:SetArray(aApunte)
    Ferase(GetSrvProfString("Startpath","")+cArquivo)
Return

User Function GrabSql(aApunte)

Local nI            := 0
Local aDados        :=  aApunte
Local aLogAuto      := {}
Local cLogTxt       := ""
Local cArquivo      := 'C:\TOTVS\'+DTOS(dDataBase)+'_'+'BOGO.txt'
Local cPasta        := DTOS(dDataBase)+'_'+'log.txt'
Local nRet          := 0
Local SQL           := ""
Private lMsErroAuto :=.F.
Private lMsHelpAuto :=.T.
private lAutoErrNoFile:= .T.


ProcRegua(len(aDados))
For nI := 1 to len(aDados)
    aLogAuto :=""
    SQL := (aDados[nI,2])+' '+ (aDados[nI,3])+' '+ (aDados[nI,4])+' '+(aDados[nI,5])

    If Alltrim((aDados[nI,2])) # "UPDATE"

        aLogAuto := "*************************"+CRLF+;
                     "Sentencia diferente a UPDATE"+CRLF+;
                     "*************************"+CRLF+;
                     SQL+CRLF

        SQL := "UPDATE SB1010 SET B1_CODBAR='12345', B1_LOCALIZ='N' WHERE B1_COD='TR01M_CO-67' AND B1_LOCPAD='01'"

            nRet = TCSqlExec(SQL)
			
		If nRet < 0
			aLogAuto := "*************************"+CRLF+;
            "ERROR SQL "+CRLF+;
            "*************************"+CRLF+;
            SQL+CRLF+ ;
            TCSQLError()
		EndIf
   
   
   
    Else
        nRet = TCSqlExec(SQL)
			
		If nRet < 0
			aLogAuto := "*************************"+CRLF+;
            "ERROR SQL "+CRLF+;
            "*************************"+CRLF+;
            SQL+CRLF+ ;
            TCSQLError()
		EndIf
    EndIf

        IncProc("Procesando registro " + CvalToChar(nI) + " de " + CvalToChar(len(aDados)))

    If !EMPTY( aLogAuto )
        cLogTxt += aLogAuto + CRLF
        MemoWrite(cArquivo, cLogTxt)
        U_XCREABAT("C:\TOTVS\")
    EndIf
next nI
    
 IF !Empty(cLogTxt)
    FWAlertError("Hay sentencias que no ejecutaron , revisar el LOG  en la siguiente direccion " + cArquivo, "SQL - UPDATE")
    ShellExecute("OPEN", cPasta, "", 'C:\TOTVS\', 1)
 Else
    FWAlertSuccess("Carga sin Errores","SQL - UPDATE")
 ENDIF
    
    oDlCargEX:End() 

Return(.T.)


