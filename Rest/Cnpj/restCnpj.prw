#Include "totvs.ch"
#Include "protheus.ch"

CLASS restCnpj

	//Declaracao das propriedades da Classe
	Data cUrl 		as String
	Data aHeader  as Array
	Data aRetorno as Array
	Data oRetorno as Object
	Data cRetorno as String
	Data cError		as String

	//cnpj.ws
	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD getEmp( cCnpj )

ENDCLASS


// Criação do construtor, onde atribuimos os valores default
// para as propriedades e retornamos Self
METHOD New() Class restCnpj
	::cUrl 				:= "https://receitaws.com.br/v1"
	::aHeader 		:= {"Accept-Encoding: UTF-8","Content-Type: application/json; charset=utf-8"}
	default lTest:= .T.

Return Self


/*/{Protheus.doc} setDadosEmp
  (Metodo responsavel por retornar os dados da empresa)
  @author Leandro Lemos
  @since 09/06/2022
  @version P12
  @param param_name, param_type, param_descr
  cTpEntidade, Char, Tipo de Entidade = CUSTOMER,USER, 
  cChave, Char, Codigo da Entidade
  @return return_var, return_type, return_description
  /*/
METHOD getEmp( cCnpj ) Class restCnpj
	local oRest
	local nStatus   := 0
	local cError    := ""
	Local jJson
	Local cPath			:= "/cnpj/"+cCnpj

	jJson := JsonObject():new()

	oRest := FWRest():New(::cUrl)

	//Setando o path
	oRest:setPath(cPath)

	//Efetuando o GET e buscando o retorno
	oRest:Get(::aHeader)
	cError := ""
	nStatus := HTTPGetStatus(@cError)

	IF cValToChar(nStatus) == '200'

		::cRetorno := FWNoAccent(DecodeUtf8(oRest:GetResult()))

		//Efetua o parser do JSON que está na string
		cParser := jJson:fromJson(::cRetorno)

		::oRetorno	:= jJson
	Else
		::cError := oRest:GetLastError()
	EndIF

Return ::oRetorno
