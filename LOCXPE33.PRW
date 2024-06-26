#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOCXPE33  �Autor  �Microsiga           �Fecha �  20/05/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     �   Carga campos personalizados en encabezado de documentos  ���
���          �   de entrada y salida.                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������   
// ===================================================================================== //
// 1	NF	Nota fiscal de Vendas	Cliente	Faturamento
// 2	NDC	Nota de d�bito cliente	Cliente	Faturamento                         
// 3	NCE	Nota de cr�dito externa	Cliente	Faturamento
// 4	NCC	Nota de cr�dito cliente	Cliente	Faturamento
// 5	NDE	Nota de d�bito externa	Cliente	Faturamento
// 6	NDI	Nota de d�bito interna	Fornecedor	Compras
// 7	NCP	Nota de cr�dito fornecedor	Fornecedor	Compras
// 8	NCI	Nota de cr�dito Interna	Fornecedor	Compras
// 9	NDP	Nota de d�bito fornecedor	Fornecedor	Compras
// 10	NF	Nota Fiscal de compras	Fornecedor	Compras
// 11	NF	Nota fiscal de Beneficiamento	Fornecedor	Faturamento
// 12	NF	Nota fiscal de Beneficiamento	Cliente	Compras
// 13	NF	Nota Fiscal de despesas de importa��o	Fornecedor	Compras
// 14	NF	Nota Fiscal de frete	Fornecedor	Compras
// 15	REC	Recibo	Fornecedor	Compras
// 50	RFN	Remito faturamento normal	Cliente	Faturamento
// 51	RFD	Remito faturamento Devolu��o (Documento pr�prio)	Cliente	Faturamento
// 52	RFB	Remito faturamento Beneficiamento	Fornecedor	Faturamento
// 53	RFD	Remito faturamento Devolu��o (Documento n�o pr�prio)	Cliente	Faturamento
// 54	RTS	Envio de remito de transferencia	Fornecedor	Estoques
// 60	RCN	Remito compras normal	Fornecedor	Compras
// 61	RCD	Remito compras Devolu��o	Fornecedor	Compras
// 62	RCB	Remito compras Beneficiamento	Cliente	Compras
// 63	RET	Retorno Simb�lico (consigna��o)	Cliente	Faturamento
// 64	RTE	Recebemento de remito de transferencia	Fornecedor	Estoques
// ===================================================================================== //
*/


User function LOCXPE33()
Local aArea := GetArea()
Local aCposNF := ParamIxb[1]
Local nTipo := ParamIxb[2]
Local aDetalles := {}
Local nNuevoElem := 0
Local nPosCpo := 0
Local nL      := 0

 
//�����������������������������������������������������������������Ŀ
//� Usuario debe definir nuevos Tipos...                            �
//�������������������������������������������������������������������

/*If nTipo == 1 .or. nTipo ==2 
	SX3->(MsSeek("F2_XOBERV2"))
	AAdd(aCposNF,{X3Titulo(),X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "", X3_USADO, X3_TIPO, "SF2", X3_CONTEXT,,,,,, X3_F3,""})
EndIF*/


If nTipo == 10   // Factura de entrada proveedor normal
	//   Detalles,      Campo       Usado  Obligatorio   Visual
	AADD(aDetalles,{"F1_XFAT_DE"    ,.T.      	,.F.      ,.F.   })  	
	AADD(aDetalles,{"F1_XOBS"       ,.T.      	,.F.      ,.F.   })  
	AADD(aDetalles,{"F1_XREMBOL"    ,.T.      	,.F.      ,.F.   })  
	AADD(aDetalles,{"F1_SOPORT"     ,.T.      	,.F.      ,.F.   })  
Endif

If nTipo == 13   // Factura de entrada proveedor normal
	//   Detalles,      Campo       Usado  Obligatorio  Visual
	AADD(aDetalles,{"F1_HAWB"    ,.T.      	,.F.      ,.F.   })
	AADD(aDetalles,{"F1_XFAT_DE" ,.T.      	,.F.      ,.F.   })  	
	AADD(aDetalles,{"F1_XOBS"    ,.T.      	,.F.      ,.F.   })  	
Endif

if FunName()=='MATA102DN'.and. alltrim(CESPECIE)='NCD'
	AADD(aDetalles,{"F2_XOBS"    ,.T.      	,.T.      ,.F.   })  	
EndIf

if FunName()=='MATA462DN'.and. alltrim(CESPECIE)='RFD'
	//AADD(aDetalles,{"F2_XOBS"      ,.T.      	,.F.      ,.F.   }) 
	AADD(aDetalles,{"F1_XOBS"      ,.T.      	,.F.      ,.F.   }) 
	AADD(aDetalles,{"F1_XLOCDEV"   ,.T.      	,.F.      ,.T.   }) 	
EndIf

//Felipe Gonzalez 20/09/2023
//Validacion de condiciones ya que entra para doc de salida y de entrada
//If nTipo == 4 
If nTipo == 4 .and. alltrim(CESPECIE)='NCC' 
	AADD(aDetalles,{"F1_XRZDEV" 	,.T.      	,.F.      ,.F.   })  	
	AADD(aDetalles,{"F1_XFTANTE"    ,.T.      	,.F.      ,.F.   })
	AADD(aDetalles,{"F1_XOBSENC"    ,.T.      	,.F.      ,.F.   })  
	//AADD(aDetalles,{"F1_XLOCDEV"    ,.T.      	,.F.      ,.F.   })
	//AADD(aDetalles,{"F1_XOBS"       ,.T.      	,.F.      ,.F.   })   
EndIF
If nTipo == 4 .and. alltrim(CESPECIE)='NDP' 
	//AADD(aDetalles,{"F1_XOBSNCC"    ,.T.      	,.F.      ,.F.   })
	AADD(aDetalles,{"F1_XRZDEV" 	,.T.      	,.F.      ,.F.   })  	
	AADD(aDetalles,{"F1_XFTANTE"    ,.T.      	,.F.      ,.F.   })  
	//AADD(aDetalles,{"F1_XLOCDEV"    ,.T.      	,.F.      ,.F.   })
	AADD(aDetalles,{"F1_XOBS"       ,.T.      	,.F.      ,.F.   })   
EndIF

If nTipo == 7 .and. Alltrim(CESPECIE)='NCP' // NCP - Nota de Credito Compras - Proveedores
    //Detalles,      Campo       Usado  Obligatorio  Visual
    AADD(aDetalles,{"F2_XOBSNC" , .T.      ,.F.      ,.F.   })
Endif

//�����������������������������������������������������������������Ŀ
//� No cambiar dentro del Loop For...Next, llamar AC/Localizaciones �
//�������������������������������������������������������������������
For nL := 1 To Len(aDetalles)
	If (nPosCpo := Ascan(aCposNF,{|x| x[2] == aDetalles[nL][1] })) > 0
		aCposNF[nPosCpo][13] := aDetalles[nL][3] 				   // Obligatorio
		If Len(aCposNF[nPosCpo]) == 16
			SX3->(DbSetOrder(2))
			SX3->(DbSeek(AllTrim(aDetalles[nL][1])))
			aCposNF[nPosCpo] := {X3Titulo(),X3_CAMPO,,,,,,,,,,,aDetalles[nL][3],,,,If(aDetalles[nL][4],".F.",".T.")}
		EndIf
		aCposNF[nPosCpo][17] := If(aDetalles[nL][4],".F.",".T.")   // Desabilita el campo
		If !aDetalles[nL][2]
			ADel(aCposNF,nPosCpo) 								   // Quita el campo
			ASize(aCposNF,Len(aCposNF)-1)                          // Ajusta Array
		EndIf
	Else
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek( aDetalles[nL][1] )
			nNuevoElem := Len(aCposNF)+1
			aCposNF := aSize(aCposNF,nNuevoElem)
			aIns(aCposNF,nNuevoElem)
			aCposNF[nNuevoElem] := {X3Titulo(),X3_CAMPO,,,,,,,,,,,aDetalles[nL][3],,,,If(aDetalles[nL][4],".F.",".T.")}
		EndIf
	EndIf
	
Next nL
RestArea(aArea)

Return( aCposNF )
