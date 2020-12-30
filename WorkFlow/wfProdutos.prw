#Include "TOTVS.ch"
/*/{Protheus.doc} User Function wfProdutos
  (Fonte para envio de WorkFlow para Fluxo de Cadastro de Produto
	Layouts HTML
	notificacao.html
	wfProdutos.html)
  @type  Function
  @author Leandro Lemos
  @since 16/12/2020
  @version P12
  @param cProduto, param_type, param_descr
  @return lOk, bool, confirmação ou não da operação
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function wfProdutos(cProduto)
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'wfProdutos.html'
	Local lAtivWFPro	 	:= SUPERGETMV("MV_ZATIVWFP", .F., .F.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000006') //Usuario aprovador do processo, codigo e não nome de usuario
	Local cMailAprov    := UsrRetMail(cUserAprov)
	Local cContaWF      := SUPERGETMV("MV_YCONTA", .T., "workflow@erplabs.com.br") //Conta de email para recebimento da resposta do WF
	Local cUsrProcess   := '000000'
	Local cLink         := ''
  Local cWSLink       := 'http://localhost:8090/'

	Private oHtml
	//Se o e-mail do aprovador for valido entra na condição
	IF ISEMAIL(cMailAprov) .and. lAtivWFPro
		oProcess := TWFProcess():New( "WFWPRO", "WorkFLow Produtos" )
		oProcess:NewTask( "WorkFLow aprovação de Cadastro de Produtos", cFolderLyt+cLayoutHTML )
		oProcess:cTo		  :=  cUsrProcess	  //Codigo do usuario ou email
		oProcess:bReturn	:= "U_wfPrdRet()"
		oProcess:cSubject	:= "WorkFLow aprovação de Cadastro de Produto, Produto  " + alltrim(SB1->B1_COD) + '-' + alltrim(SB1->B1_DESC)
		oProcess:UserSiga	:= cUserAprov     //"000000"
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "cCodPro"   , SB1->B1_COD  )
		oHtml:ValByName( "cProDesc"  , EncodeUtf8(alltrim(SB1->B1_DESC)))
		oHtml:ValByName( "cProUmc"   , SB1->B1_UM   )
		oHtml:ValByName( "cProTipo"  , SB1->B1_TIPO )


		oProcess:nEncodeMime := 0
		//Iniciando e gravando aquivo do processo
		cProcess := oProcess:Start("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\")
		//Carregando nome do arquivo html gerado
		cHtmlFile  := cProcess + ".htm"
		cMailTo    := "mailto:" + cContaWF

		//Lendo arquivo e armazenando na variavel
		cHtml := wfloadfile("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile )
		//Substituido o email no corpo do form pelo WFHTTPRET.APL
		cHtml := strtran( cHtml, cMailTo, "WFHTTPRET.APL" )

		//Gerando HTML para ser acessado via Link
		wfsavefile("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile+"l", cHtml)
		//Apagando  o arquivo gerado
		fErase("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile)

		//Link do processo, ainda faltando o endereço/dominio do WS
		cLink := cWSLink+'/workflow/messenger/emp' +cEmpAnt  + '/' + cUsrProcess + '/' + alltrim(cProcess) + '.html


		//Notificando aprovador
		wfNotifica(cUserAprov,cMailAprov,oProcess:cSubject,cLink)


	Else
		MsgInfo('E-mail cadastrado para o usuario '+FwGetUserName(cUserAprov)+' é invalido, favor verificar')
	EndIF

Return lOk

/*/{Protheus.doc} wfNotifica
  (long_description)
  @type  Static Function
  @author Leandro Lemos
  @since 29/12/2020
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function wfNotifica(cUserAprov,cTo,cSubject,cLink)
	Local lOk         := .T.
	Local cHtml       := ''
	Local cFolderLyt  := 'workflow\html\'
	Local cLayoutHTML := 'notificacao.html'

	//Carregando arquivo
	cHtml := wfloadfile(cFolderLyt+cLayoutHTML)


	cHtml := strtran( cHtml, '%cLink%', cLink )                                 //Link para aprovaçao
	cHtml := strtran( cHtml, '%cNomeAprov%',FwGetUserName(cUserAprov)  )        //Nome do Usuario
	cHtml := strtran( cHtml, '%dDataAlc%', cValToChar(dDatabase)  )                          //Data da notificação


	WFNotifyAdmin( cTo , cSubject, cHtml )

Return lOk

/*/{Protheus.doc} User Function wfPrdRet
  (long_description)
  @type  Function
  @author Leandro Lemos
  @since 16/12/2020
  @version P12
  @param , , 
  @return lOk, bool, confirmação ou não da operação
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function wfPrdRet(oProcess)
	Local cMessage  := ""
	Local cStatusRet:= IIF(alltrim(oProcess:oHtml:RetByName("Aprovacao")) == 'S','03','04')
	Local cCodPro   := alltrim(oProcess:oHtml:RetByName("cCodPro"))
	Local nX        := 0
  Local lOk       := .T.

	//variável de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	DBSetOrder(1)
	IF (DBSeek(xFilial('SB1')+cCodPro))
		//Para o exemplo do post, vou usar o execauto para alterar o cadastro, mas dependendo do cadastro pode
		//não haver rotina automatica disponivel
		aProd:= { {"B1_COD" , cCodPro,NIL},;
			{"B1_ZSITUA" ,cStatusRet,NIL}}

		MSExecAuto({|x,y| Mata010(x,y)},aProd,4)
		//Tratando erros caso ocorram
		IF lMsErroAuto
			aLog        := GetAutoGRLog()
			//Tratamento para o retorno do erro
			For nX := 1 to len(aLog)
				cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
			Next
			cSubject := 'Erro alçada produto '+ cCodPro
			wfNoticaError("suporte@erplabs.com.br",cSubject,cErrorAuto)
		EndIF
	Else
		//Notificação caso haja algum problema ao posicionar o produto no retorno
		cSubject := 'Erro alçada produto '+ cCodPro
		cMessage := "Não foi possivel posicionar no produto para atualização</br>"
		wfNoticaError("suporte@erplabs.com.br",cSubject,cMessage)
	EndIF

Return lOk


/*/{Protheus.doc} NotifaErro
  (Notifica adm de erro no processo)
  @type  Static Function
  @author Leandro Lemos
  @since 30/12/2020
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function wfNoticaError(cTo , cSubject, cMessage)
	Local aHtml     := {}
	Local cHtml     := ''
	Local nI        := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"<head>")
	aAdd(aHtml,"<meta charset='utf-8' />")
	aAdd(aHtml,"<title>Notificação WorkFlow alçada de produtos - ERPLabs</title>")
	aAdd(aHtml,"</head>")
	aAdd(aHtml,"<body>")
	aAdd(aHtml,"<table>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cSubject)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cMessage)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"</body>")
	aAdd(aHtml,"</html>")

	For nI := 1 to len(aHtml)
		cHtml += aHtml[nI]
	Next
	WFNotifyAdmin( 'suporte@erplabs.com.br' , , cHtml )
Return return_var
