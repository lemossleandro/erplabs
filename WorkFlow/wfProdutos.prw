#Include "TOTVS.ch"
/*/{Protheus.doc} User Function wfProdutos
  (Fonte para envio de WorkFlow para Fluxo de Cadastro de Produto)
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
	Local lOk := .T.
	if MsgNoYes("Iniciar Teste?",'Teste')
		MsgInfo(cProduto,"Teste")
	endif

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
User Function wfPrdRet()

Return lOk
