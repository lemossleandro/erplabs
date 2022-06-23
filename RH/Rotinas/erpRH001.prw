#Include "protheus.ch"
#Include "totvs.ch"

User Function erpRH001()
	RpcSetType(3)
	RpcSetEnv('99','01')

	processaXml()
	//processaJson()
	RpcClearEnv()

Return

/*/{Protheus.doc} processaXml
	(long_description)
	@type  Static Function
	@author Leandro Lemos
	@since 16/06/2022
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function processaXml()
	//Local cFolder			:= '\eSocial\'
	//Local cFile 			:= 'eSocial_Evento_14583491105.xml'
	Local cReplace		:= ""
	Local cErros			:= ""
	Local cAvisos			:= ""
	Local oXml				:= Nil
	Local cCPFTrab 		:= ''
	local tmp 				:= getTempPath()
	local cFile
	Local cRecibo			:= ''
	Local cEvento			:= ''
	Local nI					:= 0
	Local aFiles			:= {}

	cFile := tFileDialog( "All files (*.xml) | All Text files (*.xml) ",;
		'Selecao de Arquivos',, tmp, .F., GETF_MULTISELECT )

	aFiles := StrTokArr(cFile,';')

	For nI := 1 to Len(aFiles)
		IF File(aFiles[nI])
			oXml := XmlParser(MemoRead(aFiles[nI]), cReplace, @cErros, @cAvisos)
			cCPFTrab := oXml:_ESOCIAL:_EVTBASESTRAB:_IDETRABALHADOR:_CPFTRAB:TEXT
			cEvento := oXml:_ESOCIAL:_EVTBASESTRAB:REALNAME

			//Tratamento para recibo de acordo com o Evento
			IF cEvento == 'evtBasesTrab'
				cRecibo 			:= oXml:_ESOCIAL:_EVTBASESTRAB:_IDEEVENTO:_NRRECARQBASE:TEXT
				cCentroCusto 	:= oXml:_ESOCIAL:_EVTBASESTRAB:_INFOCP:_IDEESTABLOT:_CODLOTACAO:TEXT
				Conout(cCentroCusto)
			Else
				MsgInfo('Evento '+cEvento+'Não disponivel para tratamento','Atenção')
			EndIF
			IF Empty(cRecibo)
				IF MsgYesNo('Erro no retorno, evento sem recibo ,gostaria de Visualizar a estrutura do Arquivo?', 'Atenção')
					xmlThree(aFiles[nI])
				EndIF
			Else
				MsgInfo("Recibo: "+cRecibo,'Recibo')
			EndIF

		EndIF
	Next
Return

User Function TXMLViewer(cFile)



Return

/*/{Protheus.doc} xmlThree
	(Função responsavel por visualizar o xml em arvore)
	@type  Static Function
	@author Leandro Lemos
	@since 17/06/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function xmlThree(cFile)
	oDlg := TDialog():New(0,0,600,800,'',,,,,,,,,.T.)

	oXml := TXMLViewer():New(05, 05, oDlg , cFile, 590, 790, .T. )

	IF oXml:setXML(cFile)
		MsgAlert("Arquivo não encontrado",'Erro')
	EndIf

	oDlg:Activate()
Return

/*/{Protheus.doc} processaJson
	(Função responsavel por acessar as informações do json)
	@type  Static Function
	@author Leandro Lemos
	@since 17/06/2022
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function processaJson()
	Local oJson
	Local cParser
	Local cJson		:= ''
	Local oResult
	Local oStatus
	Local oMetadata

	oJson := JsonObject():new()

	//Efetua o parser do JSON que está na string
	montaJson(@cJson)
	cParser := oJson:fromJson(cJson)

	IF ValType(cParser) == "U"

		//Acessando diretamente
		cId := oJson['id']

		//Acessando conteudo da propriedade changes
		ret := oJson:GetJsonObject("changes")
		cField 		:= ret[1]['field']

		oResult 	:= ret[1]['value']['results'][1]
		//Acessando algumas propriedades do results
		cPersName := oResult['personal']['name']
		cPersID		:= oResult['id_personal']

		oStatus 	:= ret[1]['value']['status'][1]
		cTimeStamp := oStatus['timestamp']

		oMetadata := ret[1]['value']['metadata']
		nNumber 	:= oMetadata['number']
		nNumberID	:= oMetadata['number_id']

	Else
		Conout("Erro: " + cParser)
	EndIF

	FreeObj(oJson)
	FreeObj(oResult)
	FreeObj(oStatus)
	FreeObj(oMetadata)


Return


/*/{Protheus.doc} montaJson
	(Função responsavel por retornar json no formato string)
	@type  Static Function
	@author Leandro Lemos
	@since 17/06/2022
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function montaJson(cJson)

	cJson := '{ "id": "4546565767", "changes": [{ "value": { "line": "tecnology", "metadata": { "number": "45459839483", "number_id": "343432226674365576" },'+;
		'"results": [{ "personal": { "name": "Joyce" }, "id_personal": "HHSGskf84849jkh49hhhHSJHD" }], "status": [{ "from": "90384509485", "id": "YFDNFQjBFNUUzM0VGOTRBNjE4Q0U3AA==",'+;
		'"timestamp": "1655315715", "text": { "body": "aaa ff" }, "type": "text" }] },"field": "status" }] }

Return

