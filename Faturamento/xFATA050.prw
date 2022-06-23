#Include "protheus.ch"
#Include "totvs.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} User Function Metas de Venda (FATA050 - SIGAFAT)
  (Ponto de entrada MVC da rotina Metas de Venda (FATA050 - SIGAFAT))
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
User Function FATA050()
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


		IF cIdPonto == 'FORMLINEPOS'
			//IF cIdPonto == 'FORMLINEPRE'
			nQtdLinhas 	:= oObj:GetQtdLine()
			nLinAtual		:= oObj:nLine

			If (ApMsgYesNo( cMsg + 'Deseja replicar o vendedor ?' ) )
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
	Local oModel      := oObj //oObj
	Local oModelGrid  := oModel:GetModel('SCTGRID') //oObj
	Local nOperation 	:= oModel:GetOperation()
	Local oView				:= FWViewActive() //Objeto da View, adicionado para dar refresh após adicioar uma nova linha
	Local lRet 			 	:= .T.
	Local nProxLinha  := nQtdLinhas+1
	Local aSaveLines:= FWSaveRows()

	If nOperation == 3 .or. nOperation == 4

		//Verifica se a linah atual não está deletada
		If !(oModel:IsDeleted())

			IF(EMPTY(oModel:GetValue('CT_VEND')))
				Help(,,'Atenção',,'Vendedor obrigatório',1,0,,,,,,{'Informe o codigo do vendedor ou Precione F3 para consulta'})
				lRet := .F.

				//Se estiver na primeira linha, verifica se deseja repicar os dados do inspetor a demais linhas
			Else
				//Carregando valores da linha atual
				cVendedor := oModel:GetValue('CT_VEND')
/* 
				IF oModelGrid:AddLine() == oModelGrid:Length(.F.)
					oModelGrid:SetValue('CT_VEND', cVendedor)
				EndIF
  */
 				oModel:GoLine(nProxLinha)				

				oModelGrid:SetValue('CT_VEND', cVendedor )
				//oModel:GoLine(nProxLinha)

				oModel:DeActivate()
				oModel:Activate()

				oView:Refresh()//oView:ACURRENTSELECT[1]
			EndIF
		EndIF

	EndIF

FWRestRows(aSaveLines)

Return lRet
