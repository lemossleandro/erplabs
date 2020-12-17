#Include "TOTVS.ch"
#Include 'Protheus.ch'
/*/{Protheus.doc} User Function MT010CAN
  (LOCALIZA��O: Este ponto est� localizado nas fun��es  
  A010Inclui (Inclus�o do Produto), 
  A010Altera (Altera��o do Produto) e 
  A010Deleta (Dele��o do Produto).
  EM QUE PONTO: No final das fun��es citadas, ap�s  atualizar ou n�o os dados do Produto; 
  Pode ser utilizado para executar customiza��es conforme o tipo de retorno: Execu��o OK ou Execu��o Cancelada.)
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

	//TRATAMENTOS DO USU�RIO 1- Altera��o
	IF (INCLUI .OR. (ALTERA .and. !(SB1->B1_ZSITUA $ '03,04')))

		u_wfProdutos(SB1->B1_COD)
	EndIF


Return Nil
