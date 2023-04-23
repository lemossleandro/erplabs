#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function SalesOrder
    (Api REST para consulta de pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 08/05/2020
    @version P12 
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    https://tdn.totvs.com/pages/releaseview.action?pageId=6784012

Data        Analista        Alteração
20/092020   Leandro Lemos   POST - Alterado tratamento do retorno de erros, removido tratamento para numeração dos pedidos, 
                            o campo C5_NUM ja tem GETSXENUM() no iniciador 
                            Adicionado verbo PUT
    /*/

WSRESTFUL SalesOrder DESCRIPTION "Api REST para consulta de pedidos de venda"

	WSDATA page AS INTEGER OPTIONAL
	WSDATA pageSize AS INTEGER OPTIONAL
	WSDATA cSalesOrder AS STRING OPTIONAL

	WSMETHOD GET    getSales  DESCRIPTION 'Consulta pedidos de venda'     WSSYNTAX '/api/v3/salesorder' PATH '/api/v3/salesorder' PRODUCES APPLICATION_JSON
	WSMETHOD POST   postSales DESCRIPTION 'Submete pedidos de venda'      WSSYNTAX '/api/v3/salesorder' PATH '/api/v3/salesorder' PRODUCES APPLICATION_JSON
	WSMETHOD PUT    putSales  DESCRIPTION 'Edita pedidos de venda'        WSSYNTAX '/api/v3/salesorder' PATH '/api/v3/salesorder' PRODUCES APPLICATION_JSON
	WSMETHOD DELETE delSales  DESCRIPTION 'Exclui pedidos de venda'       WSSYNTAX '/api/v3/salesorder' PATH '/api/v3/salesorder' PRODUCES APPLICATION_JSON
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / salesorder
Retorna a lista de pedidos.

@param cSearchKey , caracter, chave de pesquisa utilizada em diversos campos
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina

@return cResponse , caracter, JSON contendo a lista de pedidos
/*/
//-------------------------------------------------------------------

WSMETHOD GET getSales WSRECEIVE cSalesOrder, page, pageSize WSREST SalesOrder

Local aListSales := {}
Local aLast := {}
Local cQrySC5       := GetNextAlias()
Local cJsonCli      := ''
Local cWhere        := ""
Local cPedido       := ''
Local lRet          := .T.
Local nCount        := 0
Local nStart        := 1
Local nReg          := 0
Local oJsonSales := JsonObject():New()

Default self:page := 1
Default self:pageSize := 100

//-------------------------------------------------------------------
// Tratativas para a chave de busca
//Existem outras maneira de trabalhar com filtro, por hora vou manter dessa forma
//-------------------------------------------------------------------

If !Empty(self:cSalesOrder)
	cWhere += " AND ( SC5.C5_NUM = " + AllTrim( Self:cSalesOrder ) + ")
EndIf

cWhere := '%'+cWhere+'%'

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

BeginSQL Alias cQrySC5
SELECT C5_CLIENTE,C5_LOJACLI,C5_CONDPAG,C5_TPFRETE,C5_MENNOTA,C5_NATUREZ,SC5.R_E_C_N_O_ C5_RECNO,
C5_FILIAL ,C5_NUM,C5_LIBEROK,C5_NOTA,C5_BLQ
FROM %Table:SC5% SC5
WHERE 
C5_FILIAL = %exp:xFilial("SC5")%
AND SC5.%NotDel%
%exp:cWhere%
ORDER BY SC5.C5_NUM
EndSQL

//conout(cQrySC5)

If ( cQrySC5 )->( ! Eof() )

	//-------------------------------------------------------------------
	// Identifica a quantidade de registro no alias temporário
	//-------------------------------------------------------------------
	COUNT TO nRecord

	//-------------------------------------------------------------------
	// nStart -> primeiro registro da pagina
	// nReg -> numero de registros do inicio da pagina ao fim do arquivo
	//-------------------------------------------------------------------
	If self:page > 1
		nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
		nReg := nRecord - nStart + 1
	Else
		nReg := nRecord
	EndIf

	//-------------------------------------------------------------------
	// Posiciona no primeiro registro.
	//-------------------------------------------------------------------
	( cQrySC5 )->( DBGoTop() )

	//-------------------------------------------------------------------
	// Valida a exitencia de mais paginas
	//-------------------------------------------------------------------
	If nReg > self:pageSize
		oJsonSales['hasNext'] := .T.
	Else
		oJsonSales['hasNext'] := .F.
	EndIf
Else
	//-------------------------------------------------------------------
	// Nao encontrou registros
	//-------------------------------------------------------------------
	oJsonSales['hasNext'] := .F.
EndIf


//-------------------------------------------------------------------
// Alimenta array de pedidos
//-------------------------------------------------------------------
While ( cQrySC5 )->( ! Eof() )
	cPedido := ''
	cPedido := (cQrySC5)->C5_NUM

	nCount++

	If nCount >= nStart

		aAdd( aListSales , JsonObject():New() )
		nPos := Len(aListSales)
		aListSales[nPos]['NUM']       := (cQrySC5)->C5_NUM
		aListSales[nPos]['CLIENTE']   := TRIM((cQrySC5)->C5_CLIENTE)
		aListSales[nPos]['LOJACLI']   := TRIM((cQrySC5)->C5_LOJACLI)
		aListSales[nPos]['CONDPAG']   := TRIM((cQrySC5)->C5_CONDPAG)
		aListSales[nPos]['TPFRETE']   := TRIM((cQrySC5)->C5_TPFRETE)
		aListSales[nPos]['MENNOTA']   := TRIM(EncodeUTF8((cQrySC5)->C5_MENNOTA))
		aListSales[nPos]['NATUREZ']   := TRIM((cQrySC5)->C5_NATUREZ)
		aListSales[nPos]['RECNO']     := cValtoChar((cQrySC5)->C5_RECNO)

		DbSelectArea("SC6")
		SC6->(DBSetOrder(1))
		cSeek := xFilial("SC6")+(cQrySC5)->C5_NUM
		SC6->(MsSeek(cSeek))

		While SC6->(!EoF()) .and. SC6->(C6_FILIAL+C6_NUM) == cSeek
			Aadd(aLast,JsonObject():new())
			nPosItem := Len(aLast)
			aLast[nPosItem]['NUM']      := SC6->C6_NUM
			aLast[nPosItem]['ITEM']     := SC6->C6_ITEM
			aLast[nPosItem]['PRODUTO']  := TRIM(SC6->C6_PRODUTO)
			aLast[nPosItem]['DESCRI']   := TRIM(EncodeUTF8(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")))
			aLast[nPosItem]['QTDVEN']   := SC6->C6_QTDVEN
			aLast[nPosItem]['PRCVEN']   := SC6->C6_PRCVEN
			aLast[nPosItem]['VALOR']    := SC6->C6_VALOR
			aLast[nPosItem]['TES']      := TRIM(SC6->C6_TES)
			aLast[nPosItem]['NOTA']     := TRIM(SC6->C6_NOTA)
			aLast[nPosItem]['SERIE']    := TRIM(SC6->C6_SERIE)
			aLast[nPosItem]['CONTA']    := TRIM(SC6->C6_CONTA)
			aLast[nPosItem]['CC']       := TRIM(SC6->C6_CC)
			aLast[nPosItem]['PROJPMS']  := TRIM(SC6->C6_PROJPMS)
			aLast[nPosItem]['RECNO']    := cValtoChar(SC6->(Recno()))
			SC6->(DBSkip())
		End
		
		(cQrySC5)->(DBSkip())
		//Adiciono o Iten na ultima posição do array aListSales, em seguida limpo array temporario de itens
		aListSales[Len(aListSales)]['ITENS'] := aLast
		aLast := {}

		If Len(aListSales) >= self:pageSize
			Exit
		EndIf
		//Se estiver buscando por paginas, sera skipado os registros até iniciar a pagina passada pelo parâmetro Page
	Else
		(cQrySC5)->(DBSkip())
	EndIf

End

( cQrySC5 )->( DBCloseArea() )

oJsonSales['SALES'] := aListSales

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonCli:= FwJsonSerialize( oJsonSales )

//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonSales)

Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )

/*/{Protheus.doc} User Function postSales
    (Verbo POST para adição de pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 20/09/2020
    @version P12
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

/*/

WSMETHOD POST postSales WSRECEIVE WSRESTFUL SalesOrder
Local lRet      := .T.
Local aArea     := GetArea()
Local aCabec
Local aItens    := {}
Local aLinha    := {}
Local oJson
Local oItems
Local cJson     := Self:GetContent()
Local cError    := ''
Local nX     := 0
Local cAlias    := ''
Local nOpc      := 3

// variável de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsErroAuto := .F.
// força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T.

//Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
//Se tiver algum erro no Parse, encerra a execução
IF !Empty(cError)
	SetRestFault(500,'Parser Json Error')
	lRet    := .F.
Else

	IF (AllTrim(oJson:GetJsonObject('TIPO')) == 'N')
		cAlias := 'SA1'
	ElseIF (AllTrim(oJson:GetJsonObject('TIPO')) == 'B')
		cAlias := 'SA2'
	Else
		cJsonRet := '{"RETURN":false';
			+ ',"MESSAGE":"Tipo de pedido invalido, informe N ou B"}'

		self:setStatus(404)
		self:setResponse(cJsonRet)
		lRet := .F.

		RestArea(aArea)
		Return(lRet)
	EndIF

	//Antes de iniciar é validade se o cliente ou fornecedor existe
	DbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
	IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('CLIENTE'),TamSX3("A1_COD")[1])+PadR(oJson:GetJsonObject('LOJACLI'),TamSX3("A1_LOJA")[1]))))
		aCabec  := {}
		aItens  := {}

        /*
        N-> Pedidos Normais.
        B-> Apres. Fornec. qdo material p/Benef.
        */
		//Numeração removida para geração automatica da rotina
		//O inicializador padrão do campo C5_NUM já tenha a função GetSXENum()
		//aAdd(aCabec,{"C5_NUM",  cPedido,    NIL})
		aAdd(aCabec,{"C5_TIPO",     AllTrim(oJson:GetJsonObject('TIPO'))   ,        NIL})
		aAdd(aCabec,{"C5_CLIENTE",  AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
		aAdd(aCabec,{"C5_LOJACLI",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
		aAdd(aCabec,{"C5_CLIENT",   AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
		aAdd(aCabec,{"C5_LOJAENT",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
		aAdd(aCabec,{"C5_TPFRETE",  AllTrim(oJson:GetJsonObject('TPFRETE')),        NIL})
		aAdd(aCabec,{"C5_CONDPAG",  AllTrim(oJson:GetJsonObject('CONDPAG')),        NIL})
		aAdd(aCabec,{"C5_MENNOTA",  AllTrim(oJson:GetJsonObject('MENNOTA')),        NIL})
		aAdd(aCabec,{"C5_NATUREZ",  AllTrim(oJson:GetJsonObject('NATUREZ')),        NIL})

//Busca os itens no JSON, percorre eles e adiciona no array da SC6
		oItems  := oJson:GetJsonObject('ITENS')
		For nX  := 1 To Len (oItems)
			aLinha  := {}
			aAdd(aLinha,{"C6_ITEM",     AllTrim(oItems[nX]:GetJsonObject('ITEM')),              NIL})
			aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oItems[nX]:GetJsonObject('PRODUTO')),           NIL})
			aAdd(aLinha,{"C6_QTDVEN",   oItems[nX]:GetJsonObject('QTDVEN'),                     NIL})
			aAdd(aLinha,{"C6_PRCVEN",   oItems[nX]:GetJsonObject('PRCVEN'),                     NIL})
			aAdd(aLinha,{"C6_VALOR",    oItems[nX]:GetJsonObject('VALOR'),                      NIL})
			aAdd(aLinha,{"C6_TES",      AllTrim(oItems[nX]:GetJsonObject('TES')),               NIL})
			aAdd(aLinha,{"C6_ENTREG",   (ddatabase +30),                                        NIL})
			//Campos opcionais
			IIF(!EMPTY(oItems[nX]:GetJsonObject('CONTA')),  aAdd(aLinha,{"C6_CONTA",     AllTrim(oItems[nX]:GetJsonObject('CONTA')),         NIL}),)
			IIF(!EMPTY(oItems[nX]:GetJsonObject('CC')),     aAdd(aLinha,{"C6_CC",        AllTrim(oItems[nX]:GetJsonObject('CC')),            NIL}),'')
			//Só grava os dados de projeto se for enviado projeto, tarefa e edt
			IF (!EMPTY(oItems[nX]:GetJsonObject('PROJPMS')) .and. !EMPTY(oItems[nX]:GetJsonObject('REVISAO')) .and. !EMPTY(oItems[nX]:GetJsonObject('TASKPMS')))
				aAdd(aLinha,{"C6_PROJPMS",   AllTrim(oItems[nX]:GetJsonObject('PROJPMS')),       NIL})
				aAdd(aLinha,{"C6_REVISAO",    AllTrim(oItems[nX]:GetJsonObject('REVISAO')),      NIL})
				aAdd(aLinha,{"C6_TASKPMS",   AllTrim(oItems[nX]:GetJsonObject('TASKPMS')),       NIL})
			EndIF

			aAdd(aItens,aLinha)
		Next nX
		//Chama a inclusão automática de pedido de venda
		MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)
		//Caso haja erro inicia o tratamento e retorno do mensagem
		IF lMsErroAuto
			cErro := u_retErroAuto(GetAutoGRLog())
			self:setStatus(404)
			self:setResponse(cErro)
			lRet := .T.
		ELSE
			cJsonRet := '{"NUM":"' + SC5->C5_NUM	+ '"';
				+ ',"RETURN":true';
				+ ',"MESSAGE":"Cadastrado com sucesso."}'
			Self:SetResponse(cJsonRet)
		EndIF
	ELSE
		cJsonRet := '{"RETURN":false';
			+ ',"MESSAGE":"'  + EncodeUTF8("Cliente não encontrado") +'"}'

		self:setStatus(404)
		self:setResponse(cJsonRet)
		lRet := .T.
	EndIF
EndIf

RestArea(aArea)
FreeObj(oJson)

Return(lRet)


/*/{Protheus.doc} User Function putSales
    (Verbo POST para cadastro de novos pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 14/05/2020
    @version P12
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
Data        Analista        Alteração

/*/

WSMETHOD PUT putSales WSRECEIVE WSRESTFUL SalesOrder
Local lRet      := .T.
Local aArea     := GetArea()
Local aCabec
Local aItens    := {}
Local aLinha    := {}
Local oJson
Local oItems
Local cJson     := Self:GetContent()
Local cError    := ''
Local nX        := 0
Local cAlias    := ''
Local nOpc      := 4

// variável de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsErroAuto := .F.
// força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T.

//Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
//Se tiver algum erro no Parse, encerra a execução
IF !Empty(cError)
	SetRestFault(500,'Parser Json Error')
	lRet    := .F.
elseif Empty(self:cSalesOrder)
	self:setStatus(404)
	self:setResponse('{"ERROR":"Pedido não informado "}')
Else
	cAlias := 'SC5'
	//Antes de iniciar é validade se o cliente ou fornecedor existe
	DbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
	//Se  o pedido existir entra no loop
	IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('NUM'),TamSX3("C5_NUM")[1]))))
		aCabec  := {}
		aItens  := {}
        /*
        N-> Pedidos Normais.
        B-> Apres. Fornec. qdo material p/Benef.
        */
		//Numeração removida para geração automatica da rotina
		//O inicializador padrão do campo C5_NUM já tenha a função GetSXENum()
		aAdd(aCabec,{"C5_NUM",      AllTrim(oJson:GetJsonObject('NUM'))   ,         NIL})
		aAdd(aCabec,{"C5_TIPO",     AllTrim(oJson:GetJsonObject('TIPO'))   ,        NIL})
		aAdd(aCabec,{"C5_CLIENTE",  AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
		aAdd(aCabec,{"C5_LOJACLI",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
		aAdd(aCabec,{"C5_CLIENT",   AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
		aAdd(aCabec,{"C5_LOJAENT",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
		aAdd(aCabec,{"C5_TPFRETE",  AllTrim(oJson:GetJsonObject('TPFRETE')),        NIL})
		aAdd(aCabec,{"C5_CONDPAG",  AllTrim(oJson:GetJsonObject('CONDPAG')),        NIL})
		aAdd(aCabec,{"C5_MENNOTA",  AllTrim(oJson:GetJsonObject('MENNOTA')),        NIL})
		aAdd(aCabec,{"C5_NATUREZ",  AllTrim(oJson:GetJsonObject('NATUREZ')),        NIL})

		//Busca os itens no JSON, percorre eles e adiciona no array da SC6
		oItems  := oJson:GetJsonObject('ITENS')
		For nX  := 1 To Len (oItems)
			aLinha  := {}
			aadd(aLinha,{"LINPOS",     "C6_ITEM",                                               AllTrim(oItems[nX]:GetJsonObject('ITEM')),})
			aadd(aLinha,{"AUTDELETA",  "N",                                                     Nil})
			aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oItems[nX]:GetJsonObject('PRODUTO')),           NIL})
			aAdd(aLinha,{"C6_QTDVEN",   oItems[nX]:GetJsonObject('QTDVEN'),                     NIL})
			aAdd(aLinha,{"C6_PRCVEN",   oItems[nX]:GetJsonObject('PRCVEN'),                     NIL})
			aAdd(aLinha,{"C6_VALOR",    oItems[nX]:GetJsonObject('VALOR'),                      NIL})
			aAdd(aLinha,{"C6_TES",      AllTrim(oItems[nX]:GetJsonObject('TES')),               NIL})
			aAdd(aLinha,{"C6_ENTREG",   (ddatabase +30),                                        NIL})
			//Campos opcionais
			IIF(!EMPTY(oItems[nX]:GetJsonObject('CONTA')),  aAdd(aLinha,{"C6_CONTA",     AllTrim(oItems[nX]:GetJsonObject('CONTA')),         NIL}),)
			IIF(!EMPTY(oItems[nX]:GetJsonObject('CC')),     aAdd(aLinha,{"C6_CC",        AllTrim(oItems[nX]:GetJsonObject('CC')),            NIL}),'')
			//Só grava os dados de projeto se for enviado projeto, tarefa e edt
			IF (!EMPTY(oItems[nX]:GetJsonObject('PROJPMS')) .and. !EMPTY(oItems[nX]:GetJsonObject('REVISAO')) .and. !EMPTY(oItems[nX]:GetJsonObject('TASKPMS')))
				aAdd(aLinha,{"C6_PROJPMS",   AllTrim(oItems[nX]:GetJsonObject('PROJPMS')),       NIL})
				aAdd(aLinha,{"C6_REVISAO",    AllTrim(oItems[nX]:GetJsonObject('REVISAO')),      NIL})
				aAdd(aLinha,{"C6_TASKPMS",   AllTrim(oItems[nX]:GetJsonObject('TASKPMS')),       NIL})
			EndIF

			aAdd(aItens,aLinha)

		Next nX
		//Chama a inclusão automática de pedido de venda
		MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)
		//Caso haja erro inicia o tratamento e retorno do mensagem
		IF lMsErroAuto
			cErro := u_retErroAuto(GetAutoGRLog())
			self:setStatus(404)
			self:setResponse(cErro)
			lRet := .T.
		ELSE
			cJsonRet := '{"NUM":"' + SC5->C5_NUM	+ '"';
				+ ',"RETURN":true';
				+ ',"MESSAGE":"Alterado com sucesso."}'
			Self:SetResponse(cJsonRet)
		EndIF
	ELSE
		self:setStatus(404)
		self:setResponse('{"ERROR":"Pedido '+self:cSalesOrder+' não localizado "}')
		lRet := .T.
	EndIF
EndIf

RestArea(aArea)
FreeObj(oJson)

Return(lRet)


/*/{Protheus.doc} delSales
    (Responsavel por excluir o PV)
    @author user
    @since 22/03/2023
    @version P12
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
WSMETHOD DELETE delSales WSRECEIVE cSalesOrder WSRESTFUL SalesOrder
Local nOpc              := 5
Local aCabec            := {}
Local aItens            := {}
Local aLinha            := {}
Local lRet              := .T.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .F.

//Se tiver algum erro no Parse, encerra a execução
IF Empty(self:cSalesOrder)
//retorna 404 se não enviar o numero do PV
//500 se houver erro no json
	self:setStatus(500)
	self:setResponse('{"ERROR":"Pedido nao informado"}')
Else
	DbSelectArea("SC5")
	SC5->(DBSetOrder(1))
	cSeek := xFilial('SC5')+self:cSalesOrder

	if SC5->(MsSeek(cSeek))

		aadd(aCabec, {"C5_NUM",     SC5->C5_NUM     ,   Nil})
		aadd(aCabec, {"C5_TIPO",    SC5->C5_TIPO    ,   Nil})
		aadd(aCabec, {"C5_CLIENTE", SC5->C5_CLIENTE ,   Nil})
		aadd(aCabec, {"C5_LOJACLI", SC5->C5_LOJACLI ,   Nil})
		aadd(aCabec, {"C5_LOJAENT", SC5->C5_LOJAENT ,   Nil})
		aadd(aCabec, {"C5_CONDPAG", SC5->C5_CONDPAG ,   Nil})

		DbSelectArea("SC6")
		SC6->(DBSetOrder(1))//PV+ITEM
		cSeek := xFilial('SC6')+self:cSalesOrder
		SC6->(MsSeek(cSeek))

		while SC6->(!EoF()) .and. SC6->(C6_FILIAL+C6_NUM) == cSeek
			aLinha := {}
			aadd(aLinha,{"C6_ITEM",    SC6->C6_ITEM , Nil})
			aadd(aLinha,{"C6_PRODUTO", SC6->C6_PRODUTO,        Nil})
			aadd(aLinha,{"C6_QTDVEN",  SC6->C6_QTDVEN,        Nil})
			aadd(aLinha,{"C6_PRCVEN",  SC6->C6_PRCVEN,        Nil})
			aadd(aLinha,{"C6_PRUNIT",  SC6->C6_PRUNIT,        Nil})
			aadd(aLinha,{"C6_VALOR",   SC6->C6_VALOR,        Nil})
			aadd(aLinha,{"C6_TES",     SC6->C6_TES,        Nil})
			aadd(aItens, aLinha)
			SC6->(DBSkip())

		enddo

		MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, nOpc)

		IF lMsErroAuto
			cErro := u_retErroAuto(GetAutoGRLog())
			self:setStatus(404)
			self:setResponse(cErro)
		ELSE
			cJsonRet := '{"NUM":"' + self:cSalesOrder	+ '"';
				+ ',"RETURN":true';
				+ ',"MESSAGE":"'  + "Excluido com sucesso."+ '"'+'}'
			Self:SetResponse(cJsonRet)

		EndIF
	else
		self:setStatus(404)
		self:setResponse('{"ERROR":"Pedido '+self:cSalesOrder+' não localizado "}')
	endif
endif

Return lRet
