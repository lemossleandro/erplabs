#include "totvs.ch"
#include "restful.ch"
/*/{Protheus.doc} User Function pedidoerp
  (long_description)
  @type  WSRESTFUL
  @author Leandro Lemos
  @since 22/06/2022
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
WSRESTFUL pedidoerp DESCRIPTION 'endpoint pedidoerp - Pedidos de Vendas(SC5/SC6)' FORMAT "application/json,text/html"
    WSDATA Page     AS INTEGER OPTIONAL
    WSDATA PageSize AS INTEGER OPTIONAL
    WSDATA Order    AS CHARACTER OPTIONAL
    WSDATA Fields   AS CHARACTER OPTIONAL
 
    WSMETHOD GET ProdList;
        DESCRIPTION "Retorna uma lista de produtos";
        WSSYNTAX "/api/v1/pedidoerp" ;
        PATH "/api/v1/pedidoerp" ;
        PRODUCES APPLICATION_JSON
     
END WSRESTFUL
 
WSMETHOD GET ProdList QUERYPARAM Page WSREST pedidoerp
Return GetListPed(self)
 
Static Function GetListPed( oWS )
   Local lRet  as logical
   Local oProd as object
   DEFAULT oWS:Page      := 1 
   DEFAULT oWS:PageSize  := 10
   DEFAULT oWS:Fields    := ""
   lRet                  := .T.
   //PedAdapter ser� nossa classe que implementa fornecer os dados para o WS
   // O primeiro parametro indica que iremos tratar o m�todo GET
   oProd := pedAdapter():new( 'GET' ) 
   //o m�todo setPage indica qual p�gina deveremos retornar
   //ex.: nossa consulta tem como resultado 100 produtos, e retornamos sempre uma listagem de 10 itens por p�gina.
   // a p�gina 1 retorna os itens de 1 a 10
   // a p�gina 2 retorna os itens de 11 a 20
   // e assim at� chegar ao final de nossa listagem de 100 produtos
   oProd:setPage(oWS:Page)
   // setPageSize indica que nossa p�gina ter� no m�ximo 10 itens
   oProd:setPageSize(oWS:PageSize)
   // SetOrderQuery indica a ordem definida por querystring
   oProd:SetOrderQuery(oWS:Order)
   // setUrlFilter indica o filtro querystring recebido (pode se utilizar um filtro oData)
   oProd:SetUrlFilter(oWS:aQueryString )
   // SetFields indica os campos que ser�o retornados via querystring
   oProd:SetFields( oWS:Fields )  
   // Esse m�todo ir� processar as informa��es
   oProd:GetListPed()
   //Se tudo ocorreu bem, retorna os dados via Json
   If oProd:lOk
       oWS:SetResponse(oProd:getJSONResponse())
   Else
   //Ou retorna o erro encontrado durante o processamento
       SetRestFault(oProd:GetCode(),oProd:GetMessage())
       lRet := .F.
   EndIf
   //faz a desaloca��o de objetos e arrays utilizados
   oProd:DeActivate()
   oProd := nil  
Return lRet
