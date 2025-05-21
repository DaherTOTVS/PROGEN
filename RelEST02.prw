#INCLUDE "rwmake.ch"
#include "totvs.ch"
#include "protheus.ch"
#include 'topconn.ch'
#INCLUDE "TbiConn.ch"
#include 'parmtype.ch'

#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#INCLUDE "COLORS.CH"
#include "report.ch"


/* **********************************************************

         _.-'~~~~~~'-._            | Funcion:  			RelEST02()
        /      ||      \           |
       /       ||       \          | Descripcion: 	 	Impresión transferencia
      |        ||        |         |
      | _______||_______ |         |
      |/ ----- \/ ----- \|         | Parametros:
     /  (     )  (     )  \        |
    / \  ----- () -----  / \       |
   /   \      /||\      /   \      | Retorno:
  /     \    /||||\    /     \     |
 /       \  /||||||\  /       \    |
/_        \o========o/        _\   | Autor: Victor Limaco                                        
  '--...__|'-._  _.-'|__...--'     |
          |    ''    |             |
************************************************************** */

/*
Tabela de cores
CLR_BLACK         // RGB( 0, 0, 0 )
CLR_BLUE           // RGB( 0, 0, 128 )
CLR_GREEN        // RGB( 0, 128, 0 )
CLR_CYAN          // RGB( 0, 128, 128 )
CLR_RED            // RGB( 128, 0, 0 )
CLR_MAGENTA    // RGB( 128, 0, 128 )
CLR_BROWN       // RGB( 128, 128, 0 )
CLR_HGRAY        // RGB( 192, 192, 192 )
CLR_LIGHTGRAY // RGB( 192, 192, 192 )
CLR_GRAY          // RGB( 128, 128, 128 )
CLR_HBLUE        // RGB( 0, 0, 255 )
CLR_HGREEN      // RGB( 0, 255, 0 )
CLR_HCYAN        // RGB( 0, 255, 255 )
CLR_HRED          // RGB( 255, 0, 0 )
CLR_HMAGENTA  // RGB( 255, 0, 255 )
CLR_YELLOW      // RGB( 255, 255, 0 )
CLR_WHITE        // RGB( 255, 255, 255 )

*/



user function RelEST02(cDoc)
    //msginfo(cvaltochar(cDoc))
    Private cNroTran := cDoc
    //Private cDestino := NNT->NNT_LOCDL
    //msginfo(cvaltochar(cDestino))
    Processa( {|| relpdf() }, "Espere...", "Generando reporte...",.F.)


    //SF2 ESPECIE RTS
    // UNIDADES SEGUNDA UNIDAD DE MEDIDA
    // PESO PRIMERA UNIDAD DE MEDIDA
    //DESCRIPCION := LOTE + DESCRIPCION PRODUCTO
Return

Static Function relpdf()
    //MsgInfo("Informe en PDF","title")
    Local lAdjustToLegacy := .F.
    Local lDisableSetup  := .T.
    Local cLocal          := "c:\tmp\"
    Local cFilePrint := ""
    Local dtime := Time()

    PRIVATE oPrinter
    PRIVATE oFont1 := TFont():New('Courier new',,-18,.T.)


    IF !ExistDir( "c:\tmp\")
        MakeDir( "c:\tmp\" )
    ENDIF

    oPrinter := FWMSPrinter():New('SolTransferencia'+dtime+'.PD_', IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
    //oPrinter := TMSPrinter():New(OemToAnsi('Reporte especial proyectos'))
    //oPrinter:Say(10,10,"Teste")

    pdf()
    cFilePrint := cLocal+"SolTransferencia"+dtime+".PD_"
    File2Printer( cFilePrint, "PDF" )
    oPrinter:cPathPDF:= cLocal
    oPrinter:Preview()

Return

Static function pdf()
    //Local aDatos := {}
    //Local aDet := {}
    //Local aDatZZF := {}
    Local iy := 0
    Local nRegs := 0
    //Local nLinha := 0
    //Local cFech := ''
    //Local cUsr := ''
    //Local nTotc := 0 , nTotp := 0



    // ( <nRed> + ( <nGreen> * 256 ) + ( <nBlue> * 65536 ) )
    PRIVATE oBrushA := TBrush():New( , 11206656 ) //RGB (azul: RGB 0/51/171)
    PRIVATE oBrushN := TBrush():New( , 39423 ) //RGB (naranja: 255/153/0)
    PRIVATE oBrushV := TBrush():New( , 9437096 )
    PRIVATE oBrushR := TBrush():New( , 9027071 )
    PRIVATE oBrushG := TBrush():New( , 12107714 ) //RGB (gris: 194/191/184)

    PRIVATE oBrushNE := TBrush():New( , 52479 ) //RGB (naranja: 255/204/0)
    PRIVATE oBrushVE := TBrush():New( , 4697456 ) //RGB (VERDE: 112/173/71)
    PRIVATE oBrushRE := TBrush():New( , 5263615 ) //RGB (ROJO: 255/80/80)
    PRIVATE oBrushND := TBrush():New( , 13434879 ) //RGB (naranja: 255/255/204)
    PRIVATE oBrushVD := TBrush():New( , 13434828 ) //RGB (VERDE: 204/255/204)
    PRIVATE oBrushRD := TBrush():New( , 13421823 ) //RGB (ROJO: 255/204/204)



    Private oFont06 := TFont():New("Courier New",,-6,.T.)
    Private oFont07 := TFont():New("Courier New",,-7,.T.)
    Private oFont08 := TFont():New("Courier New",,-8,.T.)
    Private oFont10 := TFont():New("Courier New",,-10,.T.)
    Private oFont12 := TFont():New("Courier New",,-12,.T.)
    Private oFont14 := TFont():New("Courier New",,-14,.T.)

    Private oFont08b := TFont():New("Courier New",,-8,.T.,.T.)
    Private oFont10b := TFont():New("Courier New",,-10,.T.,.T.)
    Private oFont12b := TFont():New("Courier New",,-12,.T.,.T.)
    Private oFont14b := TFont():New("Courier New",,-14,.T.,.T.)

    Private cFileLogo	:= GetSrvProfString('Startpath','') + 'LGMID' + '.png'
    Private cFileLog2	:= GetSrvProfString('Startpath','') + 'LGMID' + '.png'

    oPrinter:SetLandscape()
    // oPrinter:SetPortrait()

    //PRIMERA PAGINA
    Private aDat := consdat()
    Private aDet := consdet()
    Private nPagatu := 0
    Private nPag := 1
    for iy := 1 to len(aDet)
        nRegs += 1
        if nRegs > 10
            nPag += 1
            nRegs := 0
        endif
    next

    Encab()
    detalle(1,len(aDet))
    // Pie()


Return

Static function Encab()
    oPrinter:StartPage()
    nPagatu += 1


    oPrinter:Box( 0035,0110, 0110, 0230, "-4") //Espacio logo izquierda
    oPrinter:SayBitmap(40,0111,cFileLogo,117,067) //LOGO IZQUIERDA

    oPrinter:Box( 0040, 0230, 0070, 0380, "-4")
    oPrinter:Box( 0070, 0230, 0100, 0380, "-4")

    oPrinter:Box( 0040, 0380, 0055, 0530, "-4")
    oPrinter:Box( 0055, 0380, 0070, 0530, "-4")
    oPrinter:Box( 0070, 0380, 0085, 0530, "-4")
    oPrinter:Box( 0085, 0380, 0100, 0530, "-4")

    oPrinter:Box( 0035, 0650, 0110, 0530, "-4") //Espacio logo derecha
    oPrinter:SayBitmap(40,0531,cFileLog2,117,067) //LOGO DERECHA

    oPrinter:Say(0050,0240,UPPER("PROCESO DE DESPACHOS"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0080,0240,UPPER("TRASLADO ENTRE BODEGAS"),oFont08,1400,CLR_BLACK)

    oPrinter:Say(0050,0390,UPPER("Empresa: PROGEN S.A."),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0065,0390,UPPER("Cra. 3 # 56-07"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0080,0390,UPPER("Soacha, Cundinamarca"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0095,0390,UPPER("Página: " + cvaltochar(nPagatu) + " de " + cvaltochar(nPag)),oFont08,1400,CLR_BLACK)

    oPrinter:Box(0120,0110, 0170, 0285, "-4")
    oPrinter:Box(0120,0285, 0170, 0480, "-4")
    oPrinter:Box(0120,0480, 0170, 0560, "-4")
    oPrinter:Box(0120,0560, 0170, 0650, "-4")
    oPrinter:Fillrect({0121,0561,0169,0649},oBrushG)


    oPrinter:Say(0130,0120,UPPER("Origen"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0290,UPPER("Destino"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0485,UPPER("Fecha"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0570,UPPER("No.Solicitud"),oFont14b,1400,CLR_BLACK)



    oPrinter:Say(0140,0120,cvaltochar("CRA. 3 # 56-07"),oFont12,1400,CLR_BLACK)
    oPrinter:Say(0150,0120,UPPER("Soacha, Cundinamarca"),oFont10,1400,CLR_BLACK)
    if len(alltrim(aDat[1][2]))>=33
        oPrinter:Say(0140,0290,cvaltochar(substr(aDat[1][2],1,33)),oFont12,1400,CLR_BLACK)
        oPrinter:Say(0150,0290,cvaltochar(substr(aDat[1][2],34,68)),oFont12,1400,CLR_BLACK)
        oPrinter:Say(0160,0290,cvaltochar(substr(aDat[1][2],69,100)),oFont12,1400,CLR_BLACK)
        //oPrinter:Say(0160,0190,cvaltochar(substr(aDat[1][2],24,30)),oFont12,1400,CLR_BLACK)
    else
        oPrinter:Say(0140,0290,cvaltochar(aDat[1][2]),oFont12,1400,CLR_BLACK)
    ENDIF
    oPrinter:Say(0140,0485,cvaltochar(stod(aDat[1][3])),oFont12,1400,CLR_BLACK)
    oPrinter:Say(0140,0570,cvaltochar(cNroTran),oFont12b,1400,CLR_RED)

Return

Static function Pie()

    oPrinter:Say(0515,0040,UPPER("Observaciones"),oFont14b,1400,CLR_BLACK)

    if len(alltrim(aDat[1][7]))>115
        oPrinter:Say(0530,0040,cvaltochar(substr(aDat[1][10],1,115)),oFont08,1400,CLR_BLACK)
        oPrinter:Say(0540,0040,cvaltochar(substr(aDat[1][10],116,200)),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(0530,0040,cvaltochar(aDat[1][7]),oFont08,1400,CLR_BLACK)
    endif

    oPrinter:Say(0560,0040,"Enviado Por",oFont12b,1400,CLR_BLACK)
    oPrinter:Say(0560,0310,"Recibido Por",oFont12b,1400,CLR_BLACK)
    oPrinter:Say(0575,0040,cvaltochar(aDat[1][4]),oFont08,1400,CLR_BLACK)



    nLinha := 370

    oPrinter:EndPage()
Return

Static function relleno(id,nLinha)

    local ix :=id
    local code :=alltrim(aDet[ix][6])
    local desc :=alltrim(aDet[ix][1])
    local unio := alltrim(code)+' - '+alltrim(desc)
    Local Xubica1 :=''
    Local Xubica2 :=''

    Local XBoOr :=alltrim(aDet[ix][13])+'-'+alltrim(aDet[ix][14])
    Local XBoDe :=alltrim(aDet[ix][9])+'-'+alltrim(aDet[ix][10])

    if(alltrim(aDet[ix][15])==alltrim(aDet[ix][13]))
        Xubica1 := alltrim(aDet[ix][11])
        Xubica2 := alltrim(aDet[ix][12])
    endif

    if(alltrim(aDet[ix][15])==alltrim(aDet[ix][9]))
        Xubica1 := alltrim(aDet[ix][11])
        Xubica2 := alltrim(aDet[ix][12])
    endif

    // no
    oPrinter:Say(nLinha+15,0030,cvaltochar(ix),oFont08b,1400,CLR_BLACK)



    // Descripción Producto
    if len(alltrim(unio))>33
        if len(alltrim(unio))>76
            oPrinter:Say(nLinha+10,0053,alltrim(substr(unio,1,38)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+20,0053,alltrim(substr(unio,39,38)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+30,0053,alltrim(substr(unio,69,38)),oFont07,1400,CLR_BLACK)
        else
            oPrinter:Say(nLinha+12,0053,alltrim(substr(unio,1,38)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+22,0053,alltrim(substr(unio,39,38)),oFont07,1400,CLR_BLACK)

        ENDIF
    else
        oPrinter:Say(nLinha+15,0053,unio,oFont08,1400,CLR_BLACK)
    ENDIF


    // Cant
    // oPrinter:Say(nLinha+10,0205,aDet[ix][2],oFont08,1400,CLR_BLACK)
    if len(alltrim(aDet[ix][2]))>4
        oPrinter:Say(nLinha+10,0202,aDet[ix][2],oFont08,1400,CLR_BLACK)

    else
        oPrinter:Say(nLinha+10,0208,aDet[ix][2],oFont08,1400,CLR_BLACK)
    ENDIF

    //"Alm Origen"
    if len(alltrim(XBoOr))>15
        if len(alltrim(XBoOr))>30
            oPrinter:Say(nLinha+10,0235,alltrim(substr(alltrim(XBoOr),1,15)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+20,0235,alltrim(substr(alltrim(XBoOr),16,15)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+30,0235,alltrim(substr(alltrim(XBoOr),31,15)),oFont07,1400,CLR_BLACK)
        else
            oPrinter:Say(nLinha+10,0235,alltrim(substr(alltrim(XBoOr),1,15)),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+20,0235,alltrim(substr(alltrim(XBoOr),16,15)),oFont07,1400,CLR_BLACK)
        endif

    else
        oPrinter:Say(nLinha+10,0235,XBoOr,oFont08,1400,CLR_BLACK)
    ENDIF

    //"Alm Dest"
    if len(alltrim(XBoDe))>15
        if len(alltrim(XBoDe))>30
            oPrinter:Say(nLinha+10,0300,substr(alltrim(XBoDe),1,15),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+20,0300,substr(alltrim(XBoDe),16,15),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+30,0300,substr(alltrim(XBoDe),31,15),oFont07,1400,CLR_BLACK)
        else
            oPrinter:Say(nLinha+10,0300,substr(alltrim(XBoDe),1,15),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+20,0300,substr(alltrim(XBoDe),16,15),oFont07,1400,CLR_BLACK)
        endif
    else
        oPrinter:Say(nLinha+10,0300,XBoDe,oFont08,1400,CLR_BLACK)
    ENDIF



    //"Serie"
    if len(alltrim(aDet[ix][3]))>15
        oPrinter:Say(nLinha+10,0365,substr(aDet[ix][3],1,15),oFont07,1400,CLR_BLACK)
        oPrinter:Say(nLinha+20,0365,substr(aDet[ix][3],16,15),oFont07,1400,CLR_BLACK)
    else
        oPrinter:Say(nLinha+10,0365,aDet[ix][3],oFont07,1400,CLR_BLACK)
    ENDIF


    //"Lote"
    if len(alltrim(aDet[ix][4]))>15
        oPrinter:Say(nLinha+10,0435,substr(aDet[ix][4],1,15),oFont07,1400,CLR_BLACK)
        oPrinter:Say(nLinha+20,0435,substr(aDet[ix][4],16,15),oFont07,1400,CLR_BLACK)
    else
        oPrinter:Say(nLinha+10,0435,aDet[ix][4],oFont07,1400,CLR_BLACK)
    ENDIF



    //"Ubica 1"
    if len(alltrim(Xubica1))>14
        oPrinter:Say(nLinha+10,0505,substr(alltrim(Xubica1),1,13),oFont07,1400,CLR_BLACK)
        oPrinter:Say(nLinha+20,0505,substr(alltrim(Xubica1),14,15),oFont07,1400,CLR_BLACK)

    else
        oPrinter:Say(nLinha+10,0505,Xubica1,oFont08,1400,CLR_BLACK)
    ENDIF


    //"Ubica 2"
    if len(alltrim(Xubica2))>14
        oPrinter:Say(nLinha+10,0565,substr(alltrim(Xubica2),1,13),oFont07,1400,CLR_BLACK)
        oPrinter:Say(nLinha+20,0565,substr(alltrim(Xubica2),14,15),oFont07,1400,CLR_BLACK)

    else
        oPrinter:Say(nLinha+10,0565,Xubica2,oFont08,1400,CLR_BLACK)
    ENDIF



    //"Observación"
    if len(alltrim(aDet[ix][5]))<=44
        oPrinter:Say(nLinha+10,0625,cvaltochar(aDet[ix][5]),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(nLinha+10,0625,cvaltochar(substr(aDet[ix][5],1,44)),oFont08,1400,CLR_BLACK)
        oPrinter:Say(nLinha+20,0625,cvaltochar(substr(aDet[ix][5],45,44)),oFont08,1400,CLR_BLACK)
    endif
return

Static function filas(cab,nLinha)

    local ca :=cab
    local Lori:=nLinha+10
    local arr:=nLinha
    local abj:=nLinha+35
    if  ca==1
        abj:=nLinha+25
    endif

    oPrinter:Box( arr, 0020, abj, 0045, "-4")//"No"
    oPrinter:Box( arr, 0045, abj, 0200, "-4")//"Descripción Producto",
    oPrinter:Box( arr, 0200, abj, 0230, "-4")//"Cant"
    oPrinter:Box( arr, 0230, abj, 0295, "-4")//"Dep Estandar"
    oPrinter:Box( arr, 0295, abj, 0360, "-4")//"Alm Dest"
    oPrinter:Box( arr, 0360, abj, 0430, "-4")//"Serie"
    oPrinter:Box( arr, 0430, abj, 0500, "-4")//"Lote"
    oPrinter:Box( arr, 0500, abj, 0560, "-4")//"Ubicación 1"
    oPrinter:Box( arr, 0560, abj, 0620, "-4")//"Ubicación 2"
    oPrinter:Box( arr, 0620, abj, 0820, "-4")//"Observaciòn"


    if  ca==1
        oPrinter:Say(Lori,0025,"No",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0065,"Descripción Producto",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0205,"Cant",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0235,"Alm Orig",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0300,"Alm Dest",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0370,"Serie",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0440,"Lote",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0510,"Ubica_1",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0570,"Ubica_2",oFont12b,500,CLR_BLACK)
        oPrinter:Say(Lori,0650,"Observaciòn",oFont12b,500,CLR_BLACK)



    endif

Return nLinha

Static Function detalle(nIni, nFin)
    Local ix      := 0
    Local nLinha  := 0
    Local nTotc   := 0
    Local nTotp   := 0

    For ix := nIni To nFin
        nLinha := 0170 + ((ix-1) * 50)
        If (ix > 10)
            oPrinter:EndPage()
            oPrinter:StartPage()
            nPagatu += 1
            Encab()
            nLinha := 0170
        EndIf

        oPrinter:Box(nLinha, 0110, nLinha+50, 0285, "-4")
        oPrinter:Box(nLinha, 0285, nLinha+50, 0480, "-4")
        oPrinter:Box(nLinha, 0480, nLinha+50, 0560, "-4")
        oPrinter:Box(nLinha, 0560, nLinha+50, 0650, "-4")

        oPrinter:Say(nLinha+10, 0120, UPPER("Código"), oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+10, 0295, UPPER("Descripción"), oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+10, 0490, UPPER("Cantidad"), oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+10, 0570, UPPER("Unidad"), oFont08, 1400, CLR_BLACK)

        oPrinter:Say(nLinha+30, 0120, aDet[ix][1], oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+30, 0295, aDet[ix][2], oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+30, 0490, aDet[ix][4], oFont08, 1400, CLR_BLACK)
        oPrinter:Say(nLinha+30, 0570, aDet[ix][3], oFont08, 1400, CLR_BLACK)
    Next ix
Return(NIL)

Static function pagadi(id,Long,falt)

    local nLinha :=0180
    local ca:=1
    local ix:=0
    local de:=id
    local en:=id-1
    local con:=1
    local res:=0
    // local fal:=falt



    // Pie()
    Encab()

    for ix := en to Long
        if con<=11
            filas(ca,nLinha)
            if  ca==1
                nLinha-=10
            endif
            ca:=0
            nLinha +=35
            con+=1

        endif
    next ix

    con:= 0
    nLinha := 0205

    for ix := de to Long
        if con<=9
            relleno(ix,nLinha)
            nLinha +=35
            con+=1
            res+=1

        endif

    next ix
    con:=0
return nLinha


Static function consdat()
    Local cSql := ""
    Local cAlias := GetNextAlias()
    Local aRet := {}
    Local aDatos := {}

    cSql := " SELECT  NNT.*,NNRD.NNR_DESCRI DESTINO, NNRL.NNR_DESCRI BLOCAL,SB1.B1_LOCPAD LOCPAD,SMO.MO_DESC EMPRESA,SMO.MO_END EMPDIR,SMO.MO_BAIRRO EMPCIU   "
    cSql += " FROM "+RetSqlName("NNT")+" NNT "
    cSql += " LEFT JOIN "+RetSqlName("NNR")+" NNRL ON NNRL.NNR_FILIAL = NNT.NNT_FILIAL AND NNRL.NNR_COD = NNT.NNT_LOCAL AND NNRL.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN "+RetSqlName("NNR")+" NNRD ON NNRD.NNR_FILIAL = NNT.NNT_FILIAL AND NNRD.NNR_COD = NNT.NNT_LOCDL AND NNRD.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = NNT.NNT_FILIAL AND SB1.B1_COD = NNT.NNT_PROD AND SB1.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN "+RetSqlName("SMO")+" SMO ON SMO.MO_FILIAL = NNT.NNT_FILIAL AND SMO.D_E_L_E_T_ = ' ' "
    cSql += " WHERE NNT.NNT_FILIAL = '"+xFilial("NNT")+"' "
    cSql += " AND NNT.NNT_NUM = '"+cNroTran+"' "
    cSql += " AND NNT.D_E_L_E_T_ = ' ' "

    TcQuery cSql New Alias (cAlias)
    aadd(aDatos,{;
        cvaltochar((cAlias)->NNT_NUM),;
        cvaltochar((cAlias)->NNT_LOCAL),;
        cvaltochar((cAlias)->NNT_LOCDL),;
        cvaltochar((cAlias)->NNT_EMISSAO),;
        cvaltochar((cAlias)->NNT_EMISSOR),;
        cvaltochar((cAlias)->NNT_OBS),;
        cvaltochar((cAlias)->BLOCAL),;
        cvaltochar((cAlias)->DESTINO),;
        cvaltochar((cAlias)->EMPRESA),;
        cvaltochar((cAlias)->EMPDIR),;
        cvaltochar((cAlias)->EMPCIUD)
    })
    (cAlias)->(dbCloseArea())
    aRet := aDatos[1]
Return aRet

Static function consdet()
    Local cSql := ""
    Local cAlias := GetNextAlias()
    Local aRet := {}
    Local aDatos := {}

    cSql := " SELECT  NNT.*,NNRD.NNR_DESCRI DESTINO, NNRL.NNR_DESCRI BLOCAL,SB1.B1_LOCPAD LOCPAD,SB1.B1_DESC PROD,SB1.B1_UM UM   "
    cSql += " FROM "+RetSqlName("NNT")+" NNT "
    cSql += " LEFT JOIN "+RetSqlName("NNR")+" NNRL ON NNRL.NNR_FILIAL = NNT.NNT_FILIAL AND NNRL.NNR_COD = NNT.NNT_LOCAL AND NNRL.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN "+RetSqlName("NNR")+" NNRD ON NNRD.NNR_FILIAL = NNT.NNT_FILIAL AND NNRD.NNR_COD = NNT.NNT_LOCDL AND NNRD.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = NNT.NNT_FILIAL AND SB1.B1_COD = NNT.NNT_PROD AND SB1.D_E_L_E_T_ = ' ' "
    cSql += " WHERE NNT.NNT_FILIAL = '"+xFilial("NNT")+"' "
    cSql += " AND NNT.NNT_NUM = '"+cNroTran+"' "
    cSql += " AND NNT.D_E_L_E_T_ = ' ' "

    TcQuery cSql New Alias (cAlias)
    While (cAlias)->(!Eof())
        aadd(aDatos,{;
            cvaltochar((cAlias)->NNT_PROD),;
            cvaltochar((cAlias)->PROD),;
            cvaltochar((cAlias)->NNT_UM),;
            cvaltochar((cAlias)->NNT_QUANT),;
            cvaltochar((cAlias)->NNT_LOCAL),;
            cvaltochar((cAlias)->NNT_LOCDL),;
            cvaltochar((cAlias)->NNT_LOTE),;
            cvaltochar((cAlias)->NNT_OBS),;
            cvaltochar((cAlias)->BLOCAL),;
            cvaltochar((cAlias)->DESTINO),;
            cvaltochar((cAlias)->LOCPAD)
        })
        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
    aRet := aDatos
Return aRet
