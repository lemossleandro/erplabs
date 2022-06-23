/*/{Protheus.doc} User Function MT120VSC
  (Este Ponto de Entrada tem por objetivo manipular os campos do array na rotina de seleção da Solicitação de Compras ou Contrato de Parceria - F4 no Pedido de Compras.)
  @type  Function
  @author Leandro Lemos
  @since 22/06/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (
    https://tdn.totvs.com/pages/releaseview.action?pageId=6085488
    https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020181932-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Ponto-de-entrada-MT120VSC-
  )
  /*/
User Function MT120VSC()
	ExpA1 := ParamIxb[1]
	ExpN2 := ParamIxb[2]
	//Customização do usuário para manipulação dos campos do array na seleção da Solicitação de Compras
	//ou Contrato de Parceria - F4 no Pedido de Compras.
	aAdd(ExpA1,'C1_PROGRAM')
Return ExpA1
