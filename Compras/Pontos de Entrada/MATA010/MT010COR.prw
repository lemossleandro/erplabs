#Include "TOTVS.ch"
#Include 'Protheus.ch'
/*/{Protheus.doc} User Function MT010COR
  (Ponto de Entrada para adicionar legenda de cores na tela de cadastro de produtos Mata010)
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
USER FUNCTION MT010COR ()

	Local aCores:={}
  aAdd(aCores,{'B1_ZSITUA == ""','BR_VERMELHO',Nil})  //Não Enviado
	aAdd(aCores,{'B1_ZSITUA == "01"','BR_VERMELHO',Nil})  //Não Enviado
	aAdd(aCores,{'B1_ZSITUA == "02"','BR_AZUL',Nil})     //Aguardando aprovação
  aAdd(aCores,{'B1_ZSITUA == "03"','BR_VERDE',Nil})    //Aprovado
	aAdd(aCores,{'B1_ZSITUA == "04"','BR_LARANJA',Nil})  //Recusado

RETURN aCores
