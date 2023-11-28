#Include "Protheus.ch"
 
User Function MATI681INT()
    Local aArea := getArea()
    Local aAreaB1 := SB1->(GetArea()) //Área da tabela SB1 para restaurar no fim do processamento.
    Local cProd   := "" //Variável para armazenar o código do produto.
	Local cBodega := ""
    Local nCont      := 0
    Local cPosition  := ""
    local aRet := {}
    Local _oXml := PARAMIXB //Referência do objeto contendo as informações que foram recebidas no XML.
    conout("Time-I",time())
    cProd := _oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
    nCont := XmlChildCount( _oXml:_TotvsMessage:_BusinessMessage:_BusinessContent)
    If !nCont < 39
        cPosition := XmlGetChild( _oXml:_TotvsMessage:_BusinessMessage:_BusinessContent, 39 )
        If UPPER(cPosition:REALNAME) == "WAREHOUSECODE"
            If Type("_oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") != "U" .And. ;
                !Empty(_oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)

                SB1->(dbSetOrder(1))
                If SB1->(dbSeek(xFilial("SB1")+cProd))
                    IF Empty(SB1->(B1_XALM))
                        cBodega := SB1->B1_LOCPAD // Usar el valor del campo B1_LOCPAD  o la bodega default del Pto
                    else
                        cBodega := SB1->B1_XALM // Usar el valor del campo B1_XALM  o Almacen de Produccion
                    End If
                EndIf
                conout("cBodega",cbodega)

                _oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text:=cBodega
            EndIf
        EndIf
    EndIf
    conout("Time-F",time())
    aAdd(aRet, .T.) // Não Irá executar a rotina padrão
    aAdd(aRet, .T.) // XML importado com sucesso
    aAdd(aRet, " ") // Como não houve erro, o terceiro parâmetro deve estar em branco.

    //Restaura o posicionamento da tabela SB1.
    SB1->(RestArea(aAreaB1))
    RestArea(aArea)  

Return aRet


// Static Function GeraXML()

// Local cScript

// cScript := ' <TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="">'
// cScript += '    <MessageInformation version="2.000">'
// cScript += "        <UUID>1feacf9f-40d9-47a7-bc66-a515edabbe0e</UUID>"
// cScript += "        <Type>BusinessMessage</Type>"
// cScript += "        <Transaction>productionappointment</Transaction>"
// cScript += "        <StandardVersion>2.0</StandardVersion>"
// cScript += "        <SourceApplication>PPI</SourceApplication>"
// cScript += "        <BranchId>01</BranchId>"
// cScript += "        <CompanyId>01</CompanyId>"
// cScript += '        <Product version="12" name="PPI"></Product>'
// cScript += "        <GeneratedOn>2023-11-14T13:48:45.6345288-05:00</GeneratedOn>"
// cScript += "    </MessageInformation>"
// cScript += "    <BusinessMessage>"
// cScript += "        <BusinessEvent>"
// cScript += "            <Entity>productionappointment</Entity>"
// cScript += "            <Identification>"
// cScript += '                <key name="IDPCFactory">e53b5bc2-3dda-4286-b56f-bc85406efbd9</key>'
// cScript += "            </Identification>"
// cScript += "            <Event>upsert</Event>"
// cScript += "        </BusinessEvent>"
// cScript += "        <BusinessContent>"
// cScript += "            <MachineCode>6INY1</MachineCode>"
// cScript += "            <MachineDescription></MachineDescription>"
// cScript += "            <ProductionOrderNumber>01954601001</ProductionOrderNumber>"
// cScript += "            <ActivityID>5311</ActivityID>"
// cScript += "            <Split></Split>"
// cScript += "            <ExternalSplit></ExternalSplit>"
// cScript += "            <ActivityCode>01</ActivityCode>"
// cScript += "            <ItemCode>PR01M_RC-929-01</ItemCode>"
// cScript += "            <ItemDescription></ItemDescription>"
// cScript += "            <ReportQuantity>500.0000</ReportQuantity>"
// cScript += "            <ApprovedQuantity>500.0000</ApprovedQuantity>"
// cScript += "            <ScrapQuantity>0.0</ScrapQuantity>"
// cScript += "            <ReworkQuantity>0.0</ReworkQuantity>"
// cScript += "            <StartSetupDateTime></StartSetupDateTime>"
// cScript += "            <StartCentSetupTime></StartCentSetupTime>"
// cScript += "            <EndSetupDateTime></EndSetupDateTime>"
// cScript += "            <EndCentSetupTime></EndCentSetupTime>"
// cScript += "            <StartReportDateTime></StartReportDateTime>"
// cScript += "            <EndReportDateTime></EndReportDateTime>"
// cScript += "            <StartCentReportTime></StartCentReportTime>"
// cScript += "            <EndCentReportTime></EndCentReportTime>"
// cScript += "            <OpTimeDec></OpTimeDec>"
// cScript += "            <OpTimeInt></OpTimeInt>"
// cScript += "            <ExtraTime></ExtraTime>"
// cScript += "            <StopTime></StopTime>"
// cScript += "            <MODTime></MODTime>"
// cScript += "            <IsProductionControlReport>false</IsProductionControlReport>"
// cScript += "            <CQLiberated>false</CQLiberated>"
// cScript += "            <ReversedReport>false</ReversedReport>"
// cScript += "            <ReversalDate></ReversalDate>"
// cScript += "            <UpdateReport>false</UpdateReport>"
// cScript += "            <ProductionShiftCode></ProductionShiftCode>"
// cScript += "            <ProductionShiftDescription></ProductionShiftDescription>"
// cScript += "            <ProductionShiftNumber></ProductionShiftNumber>"
// cScript += "            <ReportDateTime>2023-11-14T13:47:27.0000000</ReportDateTime>"
// cScript += "            <ReportCentlTime>0.0</ReportCentlTime>"
// cScript += "            <DocumentCode></DocumentCode>"
// cScript += "            <DocumentSeries></DocumentSeries>"
// cScript += "            <WarehouseCode></WarehouseCode>"
// cScript += "            <LotCode></LotCode>"
// cScript += "            <LotDueDate></LotDueDate>"
// cScript += "            <ReferenceCode></ReferenceCode>"
// cScript += "            <LocationCode></LocationCode>"
// cScript += "            <SingleOutflowLocation></SingleOutflowLocation>"
// cScript += "            <WasteWarehouseCode></WasteWarehouseCode>"
// cScript += "            <WasteLocationCode></WasteLocationCode>"
// cScript += "            <ReportSequence></ReportSequence>"
// cScript += "            <IntegrationReport></IntegrationReport>"
// cScript += "            <ToolCode></ToolCode>"
// cScript += "            <ToolDescription></ToolDescription>"
// cScript += "            <SetupCode></SetupCode>"
// cScript += "            <SetupDescription></SetupDescription>"
// cScript += "            <CounterStart></CounterStart>"
// cScript += "            <FinalAccountant></FinalAccountant>"
// cScript += "            <CloseOperation>false</CloseOperation>"
// cScript += "            <ListOfWasteAppointments>"
// cScript += "                <WasteAppointment>"
// cScript += "                    <AddressCode></AddressCode>"
// cScript += "                    <AddressCodeTo></AddressCodeTo>"
// cScript += "                    <NumberSeries></NumberSeries>"
// cScript += "                    <NumberSeriesTo></NumberSeriesTo>"
// cScript += "                    <LotCode></LotCode>"
// cScript += "                    <SubLotCode></SubLotCode>"
// cScript += "                    <LotDueDate></LotDueDate>"
// cScript += "                    <CostCenterCode></CostCenterCode>"
// cScript += "                    <ScrapProduct></ScrapProduct>"
// cScript += "                    <WasteCode></WasteCode>"
// cScript += "                    <WasteDescription></WasteDescription>"
// cScript += "                    <ScrapQuantity>0.0</ScrapQuantity>"
// cScript += "                    <ReworkQuantity>0.0</ReworkQuantity>"
// cScript += "                </WasteAppointment>"
// cScript += "            </ListOfWasteAppointments>"
// cScript += "            <ListOfResourceAppointments>"
// cScript += "                <ResourceAppointment>"
// cScript += "                    <OperatorCode>36577478</OperatorCode>"
// cScript += "                </ResourceAppointment>"
// cScript += "            </ListOfResourceAppointments>"
// cScript += "        </BusinessContent>"
// cScript += "    </BusinessMessage>"
// cScript += "</TOTVSMessage>"
// Return cScript
