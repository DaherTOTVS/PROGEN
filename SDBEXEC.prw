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


User Function SDBEXEC()
  _SDBEXEC()
Return

Static Function _SDBEXEC()
    
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

oApunte := TCBrowse():New(050, 005,560, 120,,,,oDlCargEX,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oApunte:AddColumn(TCColumn():New(" "       	,     {|| If(aApunte[oApunte:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
oApunte:AddColumn(TCColumn():New("DOC "  	    , {|| aApunte[oApunte:nAt,02]},"@!",,,"CENTER", 002,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("ITEM "  	    , {|| aApunte[oApunte:nAt,03]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("PRODUCTO"     , {|| aApunte[oApunte:nAt,04]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("LOCAL"     	, {|| aApunte[oApunte:nAt,05]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("LOCALIZ"     	, {|| aApunte[oApunte:nAt,06]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("NUMSERI"     	, {|| aApunte[oApunte:nAt,07]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )

oApunte:SetArray(aApunte)  //Define um array para o browse
oApunte:bWhen      := { || Len(aApunte) > 0 } //Se o array estiver vazio, o browse fica desabilitado
oApunte:Refresh()

@ 181, 150 BUTTON oButton1 PROMPT "Importar" SIZE 037, 012 OF oDlCargEX ACTION ImpoSql2() PIXEL
@ 181, 250 BUTTON oButton1 PROMPT "Grabar" SIZE 037, 012 OF oDlCargEX ACTION  Processa({|| GrabSql(aApunte)}, "Processando ... Por favor espere ...") PIXEL
@ 181, 350 BUTTON oButton2 PROMPT "Cerrar" SIZE 037, 012 OF oDlCargEX ACTION oDlCargEX:End() PIXEL

ACTIVATE MSDIALOG oDlCargEX CENTERED

Return

//-----------------------------------------------------------------------------
// carga los datos de extracto en grid
//-----------------------------------------------------------------------------
static Function ImpoSql2()
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

            aadd(aApunte,{lLege,;
            (aItens[i][1]),;            // DB_DOC
            (aItens[i][2]),;            // DB_ITEM 
            (aItens[i][3]),;            // DB_PRODUTO
            (aItens[i][4]),;            // DB_LOCAL
            (aItens[i][5]),;            // DB_LOCALIZ
            (aItens[i][6]),;            // DB_NUMSERI
            })
    Next
    oApunte:SetArray(aApunte)
    Ferase(GetSrvProfString("Startpath","")+cArquivo)
Return

static Function GrabSql(aApunte)

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
    cNumIDOper := GetSx8Num('SDB','DB_IDOPERA'); ConfirmSX8()

        Reclock('SDB', .T.)

        Replace DB_FILIAL    With xFilial('SDB')

        Replace DB_DOC       With aDados[nI,2]
        Replace DB_ITEM      With aDados[nI,3]
        Replace DB_PRODUTO   With aDados[nI,4]
        Replace DB_LOCAL     With aDados[nI,5]
        Replace DB_LOCALIZ   With aDados[nI,6]
        Replace DB_NUMSERI   With aDados[nI,7]

        Replace DB_QUANT     With 1
        Replace DB_ORIGEM    With 'SB9'
        Replace DB_DATA      With CtoD('31/12/2022')
        Replace DB_HRINI     With Time()
        Replace DB_NUMSEQ    With '000001'
        Replace DB_TM        With '499'
        Replace DB_TIPO      With 'D'
        Replace DB_ATIVID    With 'ZZZ'
        Replace DB_ORDATIV   With 'ZZ'
        Replace DB_IDOPERA   With cNumIDOper
        Replace DB_STATUS  With 'M'

    SDB->( MsUnlock() )

    


next nI
    
 IF !Empty(cLogTxt)
    FWAlertError("Hay sentencias que no ejecutaron , revisar el LOG  en la siguiente direccion " + cArquivo, "SBH - EXEC")
    ShellExecute("OPEN", cPasta, "", 'C:\TOTVS\', 1)
 Else
    FWAlertSuccess("Carga sin Errores","SBH - INSERT")
 ENDIF
    
    oDlCargEX:End() 

Return(.T.)


