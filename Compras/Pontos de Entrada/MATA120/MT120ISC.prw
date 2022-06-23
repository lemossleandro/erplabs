/*/{Protheus.doc} User Function MT120ISC
  (MT120ISC - Manipula o acols do pedido de compras)
  @type  Function
  @author Leandro Lemos
  @since 23/06/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (https://tdn.totvs.com/display/PROT/MT120ISC+-++Manipula+o+acols+do+pedido+de+compras)
  /*/
User Function MT120ISC()

  //Pega posicção do Campo customizado C7_YPROGRA
	Local nPosProgram 	:= aScan(aHeader,{|x| Trim(x[2])=="C7_YPROGRA"}) 
  //Grava informação do C1_PROGRAMA no C7_YPROGRA
  //Variavel 'n' é do MATA120
	ACOLS[n,nPosProgram] := SC1->C1_PROGRAMA
	
Return .T.
