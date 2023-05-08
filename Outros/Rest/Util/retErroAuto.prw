#Include 'protheus.ch'
#Include 'totvs.ch'
/*/{Protheus.doc} User Function retErroAuto
  (Retorna erro de execauto formatado como Json(Texto))
  @type  Function
  @author Leandro Lemos
  @since 22/03/2023
  @version version
  @param GetAutoGRLog(), função/array, deve ser enviado o array gerado na função GetAutoGRLog
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function retErroAuto(aErro)
Local nW := 0

	cErro := '{"ERROR": [{'
	For nW := 1 to len(aErro)
		cErro += '"LINHA'+cValToChar(nW)+'":"'+aErro[nW]+'"'+iif(len(aErro) > nW,",","")
	next
	cErro := cErro + '}]}'

Return cErro
