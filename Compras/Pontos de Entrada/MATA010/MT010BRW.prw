#Include "TOTVS.ch"
#Include 'Protheus.ch'
/*/{Protheus.doc} User Function MT010BRW
  (Adiciona mais op��es de menu na Mbrowse ( ) --> aRotUser
  Deve retornar um Array contendo as novas op��es no menu)
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
USER FUNCTION MT010BRW ()

	Local aLegMnu:={}

	aAdd(aLegMnu,{"Legenda","U_MT010LEG", 0, 3, 0, Nil })
  aAdd(aLegMnu,{"Aprova��o","U_wfProdutos(SB1->B1_COD)", 0, 3, 0, Nil })

RETURN aLegMnu

USER FUNCTION MT010LEG()

	Local aLegenda := {}

	aAdd(aLegenda,{'BR_VERMELHO' ,"N�o Enviado"})
	aAdd(aLegenda,{'BR_VERDE' ,"Aprovado"})
	aAdd(aLegenda,{'BR_AZUL' ,"Aprova��o Pendente"})
	aAdd(aLegenda,{'BR_LARANJA' ,"Reprovado"})
	BrwLegenda("Legendas","Legenda de acordo com o Status", aLegenda )

Return
