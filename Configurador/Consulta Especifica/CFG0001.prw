#Include 'protheus.ch'
#Include 'totvs.ch'
#Include "FWMVCDEF.ch"

Static _CLIENTE As Character

/*/{Protheus.doc} User Function CFG0001
  (Função responasvel pela Consulta Padrão ERP001)
  @type  Function
  @author Leandro Lemos
  @since 22/04/23
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (https://centraldeatendimento.totvs.com/hc/pt-br/articles/360027506172-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Consulta-especifica-com-retorno-em-vari%C3%A1vel)
  /*/
User Function CFG0001()
	Local oDlg
	Local aRet      	:= {}
	Local lRet      	:= .F.
	Local cGetCli   	:= Space(TAMSX3("A1_NOME")[1])
	Local cGetCodCli	:= Space(TAMSX3("A1_NOME")[1])
	Local cGetDocCli	:= Space(TAMSX3("A1_CGC")[1])
	Local lHasButton	:= .T.
	Local cDescriSay 	:= 'Consulta'
	Local oSay 				:= NIL
	Local bProcessa 	:= {||FWMsgRun(, {|oSay| fMontaArray(oSay,cGetCli,cGetCodCli,cGetDocCli) }, cDescriSay, "Carregando dados...")}
	Private oLbx
	Private aCpos   	:= {}
	Private cRet 			:= ''

	FWMsgRun(, {|oSay| fMontaArray(oSay) }, cDescriSay, "Carregando dados...")

	DEFINE MSDIALOG oDlg TITLE "Consulta de Clientes" FROM 0,0 TO 320,700 PIXEL
	
	oTGetCli := TGet():New( 01,010,{ | u | If( PCount() == 0, cGetCli, cGetCli := u ) },oDlg,317,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,bProcessa,.F.,.F.,,/*24*/,,,,lHasButton/*28*/,,,'Nome'+Space(02)/*cLabelText*/,,,,/*cPlaceHold*/)

	oTGetCod	:= TGet():New( 015, 010, { | u | If( PCount() == 0, cGetCodCli, cGetCodCli := u ) },oDlg,317, 009, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,bProcessa,.F.,.F. ,,,,,,lHasButton,,,'Codigo'/*cLabelText*/,,,,/*cPlaceHold*/)

	oTGetCnpj	:= TGet():New( 030, 010, { | u | If( PCount() == 0, cGetDocCli, cGetDocCli := u ) },oDlg,317, 009, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,bProcessa,.F.,.F. ,,,,,,lHasButton,,,'Doc.'+Space(03)/*cLabelText*/,,,,/*cPlaceHold*/)

	@ 050,010 LISTBOX oLbx FIELDS HEADER 'Codigo','Loja' , 'Nome','CNPJ','Municipio' SIZE 335,95 OF oDlg PIXEL

	oLbx:SetArray( aCpos )
	oLbx:bLine     	:= {|| aCpos[oLbx:nAt]}
	oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T.,aRet := oLbx:aArray[oLbx:nAt]} }

	oTBtn1 := TButton():New( 148, 260, "Visualizar",oDlg,{||FwMsgRun(Nil,{ |oSay| fVisualiza(oSay,oLbx:aArray[oLbx:nAt]) }, cDescriSay, 'Carregando dados...')}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBtn2 := TButton():New( 148, 305, "Selecionar",oDlg,{|| oDlg:End(), lRet:=.T., aRet := oLbx:aArray[oLbx:nAt] }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )


	ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0 .And. lRet
		If Empty(aRet[1])
			lRet := .F.
		Else
			DBSelectArea('SA1')
			SA1->(DBSetOrder(1))
			cSeek := xFilial('SA1')+aRet[1]+aRet[2]
			SA1->(MsSeek(cSeek))
			_CLIENTE := SA1->A1_COD+'/'+SA1->A1_LOJA+'-'+A1_NOME
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} User Function CFG0001A
	(Retorna o resultado da pesquisa)
	@type  Function
	@author Leandro Lemos		
	@since 22/04/23
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function CFG0001A()
Return _CLIENTE

/*/{Protheus.doc} fVisualiza
	(Função responsavel pela visualização do cadastro do cliente posicionado no grid)
	@type  Static Function
	@author Leandro Lemos
	@since 22/04/23
	@version P12
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (https://tdn.totvs.com/display/framework/FWExecView)
/*/
Static Function fVisualiza(oSay,aForn)

	//Posiciona o cliente para visualização
	IF Len(aForn) > 0
		DBSelectArea('SA1')
		SA1->(DBSetOrder(1))
		SA1->(DBSeek(xFilial('SA1')+aForn[1]+aForn[2]))
	EndIF
	oSay:SetText("Carregando cliente "+SA1->A1_NOME)
	lOk := ( FWExecView('Visualização de Clientes','CRMA980', MODEL_OPERATION_VIEW,,	{ || .T. } ) == 0 )

Return

/*/{Protheus.doc} fMontaArray
  (Retorna array com os dados)
  @type  Static Function
  @author Leandro Lemos
  @since 22/04/23
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
/*/
Static Function fMontaArray(oSay,cCliNome,cCliCod,cGetDocCli)
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	aCpos := {}
	cQuery := " SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_MUN "+CRLF
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 "+CRLF
	cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "+CRLF
	cQuery += " AND A1_MSBLQL <> '1' "+CRLF

	IF !Empty(cCliNome)
		cQuery += " AND A1_NOME LIKE '%" + AllTrim(cCliNome) + "%' "+CRLF
	EndIF

	IF !Empty(cCliCod)
		cQuery += " AND A1_COD LIKE '%" + AllTrim(cCliCod) + "%' "+CRLF
	EndIf

	IF !Empty(cGetDocCli)
		cQuery += " AND A1_CGC LIKE '%" + AllTrim(cGetDocCli) + "%' "+CRLF
	EndIf

	cQuery += " ORDER BY 1,2 "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	While (cAlias)->(!Eof())
		oSay:SetText("Carregando cliente "+SA1->A1_NOME)
		aAdd(aCpos,{(cAlias)->(A1_COD),;
			AllTrim((cAlias)->(A1_LOJA)),;
			AllTrim((cAlias)->(A1_NOME)),;
			AllTrim((cAlias)->(A1_CGC)),;
			AllTrim((cAlias)->(A1_MUN));
			})
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Len(aCpos) < 1
		aAdd(aCpos,{" "," "," "," ", " "})
	EndIf

	IF ValType(oLbx) == 'O'
		oLbx:SetArray( aCpos )
		oLbx:bLine     := {|| aCpos[oLbx:nAt]}
		oLbx:nAt := 1
		oLbx:refresh()
	EndIF


Return
