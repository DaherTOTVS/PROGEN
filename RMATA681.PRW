#Include "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include 'totvs.ch'

Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE_ESCURO")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_AZUL")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PINK")
Static oOk			:= LoadBitmap( GetResources(), "LBOK" )
Static oNo			:= LoadBitmap( GetResources(), "LBNO" )
Static _FiFlag      := "NO"

User Function UCARAPUN()
  _CarEXt()
Return

Static Function _CarEXt()
    
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

DEFINE MSDIALOG oDlCargEX TITLE "Cargue de Apunte de Produccion Modelo II. " FROM 000, 000  TO 400, 1200 PIXEL
@ 005, 007 SAY "Seleccione el archivo .CSV para la carga de " SIZE 200, 030 FONT oFontSub  OF oDlCargEX COLORS RGB(031,073,125) PIXEL
@ 018, 007 SAY "datos del Apunte Produccion Modelo II " SIZE 200, 030 FONT oFontSubN OF oDlCargEX COLORS RGB(031,073,125) PIXEL

oApunte := TCBrowse():New(050, 005,560, 120,,,,oDlCargEX,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oApunte:AddColumn(TCColumn():New(" "       	, {|| If(aApunte[oApunte:nAt,01],oSim,oNao) },,,,,,.T.,.F.,,,,.F., ) )
oApunte:AddColumn(TCColumn():New("Filial "  	        , {|| aApunte[oApunte:nAt,02]},"@!",,,"CENTER", 002,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Ord.Produccion "  	, {|| aApunte[oApunte:nAt,03]},"@!",,,"CENTER", 014,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Cod.Producto"         , {|| aApunte[oApunte:nAt,04]},"@!",,,"CENTER", 025,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Cod.Operacion"     	, {|| aApunte[oApunte:nAt,05]},"@!",,,"CENTER", 002,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Cod.Recurso "  	    , {|| aApunte[oApunte:nAt,06]},"@!",,,"CENTER", 006,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Ctd.Producida"       	, {|| aApunte[oApunte:nAt,07]},"@E 999,999.99",,,"LEFT", 011,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Fecha Apunte "  	    , {|| aApunte[oApunte:nAt,08]},"D",,,"CENTER", 008,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Operador.Recurso "  	, {|| aApunte[oApunte:nAt,09]},"@!",,,"CENTER", 010,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Almacen Apunte"   	, {|| aApunte[oApunte:nAt,10]},"@!",,,"CENTER", 003,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Fecha Inicial "  	    , {|| aApunte[oApunte:nAt,11]},"D",,,"CENTER", 008,.F.,.F.,,{|| .F. },,.F., ) )
oApunte:AddColumn(TCColumn():New("Fecha Final"  	    , {|| aApunte[oApunte:nAt,12]},"D",,,"CENTER", 008,.F.,.F.,,{|| .F. },,.F., ) )
//oApunte:AddColumn(TCColumn():New("Hora Inicio"  	    , {|| aApunte[oApunte:nAt,13]},"@!",,,, 005,.F.,.F.,,{|| .F. },,.F., ) )
//oApunte:AddColumn(TCColumn():New("Hora Final"  	    , {|| aApunte[oApunte:nAt,14]},"@!",,,, 005,.F.,.F.,,{|| .F. },,.F., ) )
    
oApunte:SetArray(aApunte)  //Define um array para o browse
oApunte:bWhen      := { || Len(aApunte) > 0 } //Se o array estiver vazio, o browse fica desabilitado
oApunte:Refresh()

@ 181, 150 BUTTON oButton1 PROMPT "Importar" SIZE 037, 012 OF oDlCargEX ACTION u_ImpoEXT() PIXEL
@ 181, 250 BUTTON oButton1 PROMPT "Grabar" SIZE 037, 012 OF oDlCargEX ACTION  Processa({|| U_GrabEXT(aApunte)}, "Processando ... Por favor espere ...") PIXEL
@ 181, 350 BUTTON oButton2 PROMPT "Cerrar" SIZE 037, 012 OF oDlCargEX ACTION oDlCargEX:End() PIXEL

ACTIVATE MSDIALOG oDlCargEX CENTERED

Return

//-----------------------------------------------------------------------------
// carga los datos de extracto en grid
//-----------------------------------------------------------------------------
USer Function ImpoEXT()
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
            (aItens[i][1]),;            // Filial
            (aItens[i][2]),;            // Ord.Produccion 
            (aItens[i][3]),;            // Cod.Producto
            (aItens[i][4]),;            // Cod.Operacion
            (aItens[i][5]),;            // Cod.Recurso 
            VAL((aItens[i][6])),;       // Ctd.Producida
            CTOD((aItens[i][7])),;      // Fecha Apunte
            (aItens[i][8]),;            // Operador.Recurso 
            (aItens[i][9]),;            // Almacen Apunte
            CTOD((aItens[i][10])),;
            CTOD((aItens[i][11])),;
            })
      //    (aItens[i][12]),;
      //    (aItens[i][13]);
      //    })
    Next
    oApunte:SetArray(aApunte)
    Ferase(GetSrvProfString("Startpath","")+cArquivo)
Return

User Function GrabEXT(aApunte)

Local aVetor        := {}
Local nOpc          := 3 
Local nI            := 0
Local aDados        :=  aApunte
Local aLogAuto      := {}
Local cLogTxt       := ""
Local cArquivo      := 'C:\TOTVS\'+DTOS(dDataBase)+'_'+'log.txt'
Local cPasta        := DTOS(dDataBase)+'_'+'log.txt'
Local nAux          := 0
Private lMsErroAuto :=.F.
Private lMsHelpAuto :=.T.
private lAutoErrNoFile:= .T.


ProcRegua(len(aDados))
For nI := 1 to len(aDados)
aVetor := {;
        {"H6_FILIAL"   ,xFilial("SH6")    ,NIL},;
        {"H6_OP"       , ((aDados[nI,3])) ,NIL},;
        {"H6_PRODUTO"  , ((aDados[nI,4])) ,NIL},;
        {"H6_OPERAC"   , ((aDados[nI,5])) ,NIL},;
        {"H6_RECURSO"  , ((aDados[nI,6])) ,NIL},;
        {"H6_QTDPROD"  , ((aDados[nI,7])) ,NIL},;
        {"H6_DTAPONT"  , aDados[nI,8] ,NIL},;
        {"H6_OPERADO"  , ((aDados[nI,9])) ,NIL},;
        {"H6_LOCAL"    , ((aDados[nI,10])) ,NIL},;
        {"H6_DATAINI"  , aDados[nI,11],NIL},;
        {"H6_DATAFIN"  , aDados[nI,12],NIL}}
    //  {"H6_HORAINI"  , ((aDados[nI,13])),NIL},;
    //  {"H6_HORAFIN"  , ((aDados[nI,14])),NIL}}

    MSExecAuto({|x| mata681(x)},aVetor, nOpc)
    IncProc("Procesando registro " + CvalToChar(nI) + " de " + CvalToChar(len(aDados)))

   If lMsErroAuto
        aLogAuto := GetAutoGRLog()
        For nAux := 1 To Len(aLogAuto)
            cLogTxt += aLogAuto[nAux] + CRLF
        Next
        MemoWrite(cArquivo, cLogTxt)
    ENDIF
next nI
    
 IF !Empty(cLogTxt)
    FWAlertError("Hay apuntes que no subieron , revisar el LOG  en la siguiente direccion " + cArquivo, "Apunte Produccion Modelo II")
    ShellExecute("OPEN", cPasta, "", 'C:\TOTVS\', 1)
 Else
    FWAlertSuccess("Carga sin Errores","Apunte Produccion Modelo II")
 ENDIF
    
    oDlCargEX:End() 

Return(.T.)


