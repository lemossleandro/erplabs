/*/{Protheus.doc} User Function MA030VINC
  (long_description)
  @type  Function
  @author Leandro Lemos
  @since 21/06/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function MA030VINC()
	Local lOk := .F.

	IF MsgNoYes('Tem certeza?','Certeza?')
		lOk := .T.
	EndIF
  
Return lOk
