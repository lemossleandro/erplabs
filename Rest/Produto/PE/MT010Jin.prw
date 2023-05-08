#include 'totvs.ch'
/*/{Protheus.doc} User Function MT010Jin
	(long_description)
	@type  Function
	@author Leandro Lemos
	@since 14/12/2021
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function MT010Jin()
	Local cJson  			:= ''
	Local ret    			:= nil
	Local oModel 			:= FWModelActive()
	Local lMVC   			:= /* TableInDic("G3Q", .F.) .And.  */oModel <> Nil .And. oModel:cSource == "MATA010"
	Local cDescProd 	:= ''
	Local aArea   		:= GetArea()
	Local lOk					:= .T.

	If lMVC
		cDescProd := Alltrim(oModel:GetValue("SB1MASTER","B1_YCEME"))
	else
		cDescProd := Alltrim(M->B1_YCEME)
	Endif

	If Empty(cDescProd)
		lOk := .F.
		//Retirando caracteres
	Else
		cDescProd := limpaDesc(cDescProd)
	Endif

	IF lOk
		//Tratando a descrição
		cJson += '{'
		cJson += '"TcOrthers": {'
		cJson +=     '"_YCEME" : "' + cDescProd + '",'
		cJson +=     '"_YCEME_UTF8" : "' + EncodeUTF8(cDescProd) + '"'
		cJson +=   '}'
		cJson += '}'

		oJson := JsonObject():New()
		ret := oJson:FromJson(cJson)

		if ValType(ret) == "C"
			//Falha ao transformar texto em objeto json
			cJson := ''
		Endif

	EndIF

	RestArea(aArea)
Return cJson


/*/{Protheus.doc} limpaDesc
	(Retorna string sem caracteres especiais)
	@type  Static Function
	@author Leandro Lemos
	@since 14/12/2021
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function limpaDesc(cValue)

	cValue := StrTran(cValue, "'", "")
	cValue := StrTran(cValue, '"', "Pol")
	cValue := StrTran(cValue, '”', "Pol")	
	cValue := StrTran(cValue, '°', '.')
	cValue := StrTran(cValue, 'ª', '.')
	cValue := StrTran(cValue, "#", "")
	cValue := StrTran(cValue, "%", "")
	cValue := StrTran(cValue, "*", "")
	cValue := StrTran(cValue, "&", "E")
	cValue := StrTran(cValue, ">", "")
	cValue := StrTran(cValue, "<", "")
	cValue := StrTran(cValue, "!", "")
	cValue := StrTran(cValue, "@", "")
	cValue := StrTran(cValue, "$", "")
	cValue := StrTran(cValue, "(", "")
	cValue := StrTran(cValue, ")", "")
	cValue := StrTran(cValue, "_", "")
	cValue := StrTran(cValue, "=", "")
	cValue := StrTran(cValue, "+", "")
	cValue := StrTran(cValue, "{", "")
	cValue := StrTran(cValue, "}", "")
	cValue := StrTran(cValue, "[", "")
	cValue := StrTran(cValue, "]", "")
	cValue := StrTran(cValue, "?", "")
	cValue := StrTran(cValue, "|", "")
	cValue := StrTran(cValue, ":", "")
	cValue := StrTran(cValue, ";", "")

Return cValue
