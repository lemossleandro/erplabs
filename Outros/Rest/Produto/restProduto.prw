#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"


/*/{Protheus.doc} User Function erpRestProd
    (Api REST para consulta de pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 23/03/2023
    @version P12 
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

WSRESTFUL restProduto DESCRIPTION "Api REST para entidade Produto

	WSDATA page AS INTEGER OPTIONAL
	WSDATA pageSize AS INTEGER OPTIONAL

	WSMETHOD GET    getProduto  DESCRIPTION 'Consulta Produto'     WSSYNTAX '/v3/restProduto' PATH '/v3/restProduto' PRODUCES APPLICATION_JSON
	WSMETHOD GET    getPaginacao  DESCRIPTION 'Consulta Produto'     WSSYNTAX '/v3/restProduto/pag/' PATH '/v3/restProduto/pag/' PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET getProduto WSRECEIVE WSREST restProduto
Local lRet      := .T.
Local aItens    := {}
Local oJRetorno := JsonObject():New()
Local cRetorno  := ''

DbSelectArea("SB1")
SB1->(DBSetOrder(1))

while SB1->(!EoF())


	oJLinha := JsonObject():New()
	oJLinha['codigo']       := SB1->B1_COD
	oJLinha['descricao']    := SB1->B1_DESC
	oJLinha['um']           := SB1->B1_UM
	oJLinha['grupo']        := SB1->B1_GRUPO

	AAdd(aItens,oJLinha)//Adiciona o objeto no array de retorno

	FreeObj(oJLinha) //Elimina o objeto

	SB1->(DBSKIP())
enddo
//Alimentando objeto de retorno
oJRetorno['itens'] := aItens

//Serializa objeto Json
cRetorno := FwJsonSerialize( oJRetorno )

//excluindo objeto
FreeObj(oJRetorno)

//Seta resposta
Self:SetResponse( cRetorno ) //automaticamente retorna 200

return lRet


WSMETHOD GET getPaginacao WSRECEIVE WSREST restProduto
Local lRet      := .T.
Local aItens    := {}
Local oJRetorno := JsonObject():New()
Local cRetorno  := ''

//Estrutuara de retorno
oJRetorno['itens']      := {}
oJRetorno['registros']  := 0
oJRetorno['hasNext'] := .F.

DbSelectArea("SB1")
SB1->(DBSetOrder(1))

if SB1->(!EoF())
	//Identifica a quantidade de registro no alias temporário
	COUNT TO nRecord

	// nStart -> primeiro registro da pagina
	// nReg -> numero de registros do inicio da pagina ao fim do arquivo
	If self:page > 1
		nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
		nReg := nRecord - nStart + 1
	Else
		nReg := nRecord
	EndIf


	// Valida a exitencia de mais paginas
	If nReg > self:pageSize
		oJRetorno['hasNext'] := .T.
	Else
		oJRetorno['hasNext'] := .F.
	EndIf

	//Voltando para o inicio do Arquivo SB1
	SB1->(DBGoTop())
	while SB1->(!EoF())


		oJLinha := JsonObject():New()
		oJLinha['codigo']       := SB1->B1_COD
		oJLinha['descricao']    := SB1->B1_DESC
		oJLinha['um']           := SB1->B1_UM
		oJLinha['grupo']        := SB1->B1_GRUPO

		AAdd(aItens,oJLinha)//Adiciona o objeto no array de retorno

		FreeObj(oJLinha) //Elimina o objeto

		SB1->(DBSKIP())
	enddo

//Alimentando objeto de retorno
	oJRetorno['itens'] := aItens
	oJRetorno['registros'] := len(aItens)
endif


if Len(aItens) == 0
	self:setStatus(404)
endif

//Serializa objeto Json
cRetorno := FwJsonSerialize( oJRetorno )

//Seta resposta
Self:SetResponse( cRetorno ) //automaticamente retorna 200

//excluindo objeto
FreeObj(oJRetorno)

return lRet
