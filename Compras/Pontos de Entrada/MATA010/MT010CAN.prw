#Include "TOTVS.ch"
#Include 'Protheus.ch'
/*/{Protheus.doc} User Function MT010CAN
  (LOCALIZAÇÃO: Este ponto está localizado nas funções  
  A010Inclui (Inclusão do Produto), 
  A010Altera (Alteração do Produto) e 
  A010Deleta (Deleção do Produto).
  EM QUE PONTO: No final das funções citadas, após  atualizar ou não os dados do Produto; 
  Pode ser utilizado para executar customizações conforme o tipo de retorno: Execução OK ou Execução Cancelada.)
  @type  Function
  @author Leandro Lemos
  @since 16/12/2020
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function MT010CAN()

	//TRATAMENTOS DO USUÁRIO 1- Alteração
	IF (INCLUI .OR. (ALTERA .and. !(SB1->B1_ZSITUA $ '03,04')))

		u_wfProdutos(SB1->B1_COD)
	EndIF


Return Nil
