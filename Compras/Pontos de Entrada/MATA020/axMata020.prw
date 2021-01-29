#include "protheus.ch"
/*/{Protheus.doc} User Function axMata020
  (long_description)
  @type  Function
  @author Leandro Lemos
  @since 28/01/2021
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
USER FUNCTION axMata020()

	LOCAL cFiltro   := ""
	LOCAL aCores  := {{ ;
		'Empty(SA2->A2_MSBLQL) .OR. SA2->A2_MSBLQL $ "2"' , 'BR_VERDE'  },;     // Ativo
	{ 'SA2->A2_MSBLQL=="1"' , 'BR_VERMELHO' }}    // Inativo

	PRIVATE cAlias   := 'SA2'

	PRIVATE _cCpo  := "SA2_FILIAL/SA2_COD/SA2_LOJA"

	PRIVATE cCadastro := "Cadastro de Fornecedores"

	PRIVATE aRotina     := {{"Pesquisar" , "AxPesqui"         , 0, 1 },;
		{"Visualizar"   , "AxVisual"   , 0, 2 },;
		{"Incluir"      , "AxInclui"   , 0, 3 },;
		{"Alterar"      , "AxAltera"   , 0, 4 },;
		{"Excluir"      , "AxDeleta"   , 0, 5 },;
    {"Legenda"      , "U_axMt20Leg" , 0, 6 }}       //"Legenda"

	dbSelectArea("SA2")
	dbSetOrder(1)

	mBrowse( ,,,,"SA2",,,,,,aCores,,,,,,,,cFiltro)

RETURN NIL


USER FUNCTION axMt20Leg()

	Local aLegenda := {}

	aAdd(aLegenda,{'BR_VERMELHO' ,"Bloqueado"})
	aAdd(aLegenda,{'BR_VERDE' ,"Ativo"})
	BrwLegenda("Legendas","Legenda de acordo com o Status", aLegenda )

Return
