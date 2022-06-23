#Include "protheus.ch"
#Include "totvs.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} User Function OMSA010
  (Ponto de entrada MVC da rotina OMSA010(Tabela de preços))
  @type  Function
  @author Leandro Lemos
  @since 07/04/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function OMSA010()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.

	Local nLinAtual     := 0
	Local nQtdLinhas := 0
	Local cMsg       := ''

	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )

		If lIsGrid

		EndIf


		IF cIdPonto == 'FORMLINEPOS'
			nQtdLinhas 	:= oObj:GetQtdLine()
			nLinAtual		:= oObj:nLine

			If (ApMsgYesNo( cMsg + 'Deseja replicar o produto para proxima linha ?' ) )
				LinePos(oObj,nQtdLinhas,nLinAtual)
			EndIf



		EndIf

	EndIf

Return xRet



/*/{Protheus.doc} LinePos
    (Replica dados da linha atual para a proxima)
    @type  Static Function
    @author Leandro Lemos
    @since 07/04/2022
    @version P12
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function LinePos(oObj,nQtdLinhas,nLinAtual)
	Local oModel      := oObj
	Local nOperation 	:= oModel:GetOperation()
	Local oView				:= FWViewActive() //Objeto da View, adicionado para dar refresh após adicioar uma nova linha
	Local lRet 			 	:= .T.
	Local nProxLinha  := nLinAtual+1

	If nOperation == 3 .or. nOperation == 4

		oModel:GoLine(nLinAtual)
		//Verifica se a linah atual não está deletada
		If !(oModel:IsDeleted())

			IF(EMPTY(oModel:GetValue('DA1_TIPPRE')))
				Help(,,'Atenção',,'Tipo de preço obrigatório',1,0,,,,,,{'Consulta umas das opções disponiveis para o tipo de preço'})
				lRet := .F.

				//Se estiver na primeira linha, verifica se deseja repicar os dados do inspetor a demais linhas
			Else
			//Carregando valores da linha atual
				cTpPreco := oModel:GetValue('DA1_TIPPRE')
				cProduto := oModel:GetValue('DA1_CODPRO')

				oModel:GoLine(nProxLinha)
				oModel:SetValue('DA1_TIPPRE', cTpPreco)
				oModel:SetValue('DA1_CODPRO', cProduto)
				
				
			EndIF		
	EndIF

EndIF
oView:Refresh("VIEW_DA1")//oView:ACURRENTSELECT[1]

Return lRet

