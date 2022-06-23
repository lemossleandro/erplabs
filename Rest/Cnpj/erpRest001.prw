#Include "protheus.ch"
#Include "totvs.ch"
#include "restful.ch"

User Function erpRest001()
	Local oRestCnpj := restCnpj():new()
	Local oCliente

	RpcSetType(3)
	RpcSetEnv('99','01')

	oCliente := oRestCnpj:getEmp('33000167000101')

	RpcClearEnv()

Return
