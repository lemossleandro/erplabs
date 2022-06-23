/*/{Protheus.doc} User Function mata131
  (Ponto de entrada para validar a geração de Cotação no Mata131)
  @type  Function
  @author Leandro Lemos
  @since 11/04/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function mata131()
	Local aParam      := PARAMIXB
	Local lRet        := .T.
	Local cUsrGerCot  := 'teste'

	If aParam <> NIL
		oObj        := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]

		If cIdPonto == 'FORMPOS'

			If !(cUserName $ cUsrGerCot)			
				Help(NIL,NIL,'PE MVC MATA131' ,NIL,"Usuario sem permissão para lançar a SC "+SC1->C1_NUM,1,0,NIL,NIL,NIL,NIL,NIL,{"Solicite permissão ao supervisor"})
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet
