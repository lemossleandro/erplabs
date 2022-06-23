#include 'totvs.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} pedAdapter
  (Classe de criação do adapter)
  @author Leandro Lemos
  @since 22/06/2022
  @version P12
  /*/
CLASS pedAdapter FROM FWAdapterBaseV2
	METHOD New()
	METHOD GetListPed()
EndClass

Method New( cVerb ) CLASS pedAdapter
	_Super:New( cVerb, .T. )
return

Method GetListPed( ) CLASS pedAdapter
	Local aArea     AS ARRAY
	Local cWhere    AS CHAR
	aArea   := FwGetArea()
	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self )
	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery() )
	//Informa a clausula Where da Query
	cWhere := " C5_FILIAL = '"+ FWxFilial('SC5') +"' AND SC5.D_E_L_E_T_ = ' '"
	::SetWhere( cWhere )
	//Informa a ordenação padrão a ser Utilizada pela Query
	::SetOrder( "C5_NUM DESC" )
	//Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::Execute()
		// Gera o arquivo Json com o retorno da Query
		::FillGetResponse()
	EndIf
	FwrestArea(aArea)
Return

Static Function AddMapFields( oSelf )

	oSelf:AddMapFields( 'NUM'             , 'C5_NUM'  , .T., .T., { 'C5_NUM', 'C', TamSX3( 'C5_NUM' )[1], 0 } )
	oSelf:AddMapFields( 'TIPO'            , 'C5_TIPO' , .T., .F., { 'C5_TIPO', 'C', TamSX3( 'C5_TIPO' )[1], 0 } )
	oSelf:AddMapFields( 'CLIENTE'         , 'C5_CLIENTE', .T., .F., { 'C5_CLIENTE', 'C', TamSX3( 'C5_CLIENTE' )[1], 0 } )
	oSelf:AddMapFields( 'LOJA'            , 'C5_LOJACLI' , .T., .F., { 'C5_LOJACLI', 'C', TamSX3( 'C5_LOJACLI' )[1], 0 } )
	oSelf:AddMapFields( 'CLIENTE_ENTREGA' , 'C5_CLIENT', .T., .F., { 'C5_CLIENT', 'C', TamSX3( 'C5_CLIENT' )[1], 0 } )
	oSelf:AddMapFields( 'LOJA_ENTREGA'    , 'C5_LOJAENT' , .T., .F., { 'C5_LOJAENT', 'C', TamSX3( 'C5_LOJAENT' )[1], 0 } )
  oSelf:AddMapFields( 'NOME'            , 'A1_NOME' , .T., .F., { 'A1_NOME', 'C', TamSX3( 'A1_NOME' )[1], 0 } )
  oSelf:AddMapFields( 'NREDUZ'          , 'A1_NREDUZ' , .T., .F., { 'A1_NREDUZ', 'C', TamSX3( 'A1_NREDUZ' )[1], 0 } )
Return

Static Function GetQuery()
	Local cQuery AS CHARACTER

	//Obtem a ordem informada na requisição, a query exterior SEMPRE deve ter o id #QueryFields# ao invés dos campos fixos
	//necessáriamente não precisa ser uma subquery, desde que não contenha agregadores no retorno ( SUM, MAX... )
	//o id #QueryWhere# é onde será inserido o clausula Where informado no método SetWhere()
	cQuery := " SELECT #QueryFields#"
	cQuery += " FROM " + RetSqlName( 'SC5' ) + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName( 'SA1' ) + " SA1 ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA "
	cQuery += " AND A1_FILIAL = '"+ FWxFilial( 'SA1' ) +"'"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE #QueryWhere#"
Return cQuery
