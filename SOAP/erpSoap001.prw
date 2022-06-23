#Include 'protheus.ch'
#Include 'totvs.ch'

//A classe TWsdlManager faz o tratamento para arquivos WSDL (Web Services Description Language). 
//Esta classe implementa métodos para identificação das informações de envio e resposta das operações definidas, além de métodos para envio e recebimento do documento SOAP.
//https://tdn.totvs.com/display/tec/Classe+TWsdlManager


//Acesso a Web Services que exigem certificados de CA
//https://tdn.totvs.com/display/tec/Acesso+a+Web+Services+que+exigem+certificados+de+CA

//Extrai o certificado de autorização (Certificate Authorith) de um arquivo com extensão .PFX (formato padrão do IIS - Internet Information Services), e gera como saída um arquivo no formato .PEM (Privacy Enhanced Mail).
//https://tdn.totvs.com/display/tec/PFXCA2PEM


//Webservice receita(download xml)
//https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx

//WS TWsdlManager com certificado digital
//https://devforum.totvs.com.br/353-ws-twsdlmanager-com-certificado-digital


User Function erpSoap001()
  Local oWsdl
  Local xRet
  Local aOps := {}
  Local aComplex := {}
  Local aSimple := {}
  Local nPos := 0, nOccurs := 0
 
  oWsdl := TWsdlManager():New()
 
  oWsdl:cSSLCACertFile := "\certs\myconectaca.pem"
  oWsdl:cSSLCertFile := "\certs\000001_cert.pem"
  oWsdl:cSSLKeyFile := "\certs\000001_key.pem"
 
  xRet := oWsdl:ParseURL( "https://homextservicos-siafi.tesouro.gov.br/siafi2014he/services/cpr/manterContasPagarReceber?wsdl" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  endif
 
  aOps := oWsdl:ListOperations()
  if Len( aOps ) == 0
    conout( "Erro: " + oWsdl:cError )
    Return
  endif
 
  xRet := oWsdl:SetOperation( "cprDHCadastrarDocumentoHabil" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  endif
 
  aComplex := oWsdl:NextComplex()
  while ValType( aComplex ) == "A"
    varinfo( "aComplex", aComplex )
 
    if ( aComplex[2] == "docOrigem" ) .And. ( aComplex[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" )
      nOccurs := 1
    elseif ( aComplex[2] == "pco" ) .And. ( aComplex[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1" )
      nOccurs := 2
    elseif ( aComplex[2] == "pcoItem" ) .And. ( aComplex[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1" )
      nOccurs := 2
    elseif ( aComplex[2] == "pcoItem" ) .And. ( aComplex[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2" )
      nOccurs := 1
    else
      nOccurs := 0
    endif
 
    xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
    if xRet == .F.
      conout( "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrencias" )
      return
    endif
 
    aComplex := oWsdl:NextComplex()
  enddo
 
  if xRet == .F.
    return
  endif
 
  aSimple := oWsdl:SimpleInput()
  varinfo( "aSimple", aSimple )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmit" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "158122" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "anoDH" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "2014" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codTipoDH" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "NP" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "dtEmis" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "26/12/2014" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "dtVenc" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "03/01/2015" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "dtPgtoReceb" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "03/01/2015" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "dtAteste" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "26/12/2014" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "2000.00" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgPgto" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "158122" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codCredorDevedor" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "06981180000116" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "txtObser" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "TESTE INCLUSAO DH TOTVS" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numDocOrigem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1.docOrigem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "123456" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "dtEmis" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1.docOrigem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "20/01/2010" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codIdentEmit" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1.docOrigem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "654321" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.dadosBasicos#1.docOrigem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "100.00" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "1" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "AAA111" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "7" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "1" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "123456123456" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "123" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "20.00" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "2" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "654321654321" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "321" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#1.pcoItem#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "30.00" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "99" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codSit" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "ABCDEF" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codUgEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "99" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numSeqItem" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "88" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "numEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "111222333444" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "codSubItemEmpe" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "444" )
 
  nPos := aScan( aSimple, {|aVet| aVet[2] == "vlr" .AND. aVet[5] == "cprDHCadastrarDocumentoHabil#1.cprDHCadastrar#1.pco#2.pcoItem#1" } )
  xRet := oWsdl:SetValue( aSimple[nPos][1], "50.00" )
 
  conout( oWsdl:GetSoapMsg() )
 
Return


user function getCA()
  Local cPFX      := "\certificado\GP_VENC-2023_SENHA-1234.pfx"
  Local cCA       := "\certificado\ca.pem"
  Local cError    := ""
  Local cContent  := ""
  Local lRet
  lRet := PFXCA2PEM( cPFX, cCA, @cError, "123" )
  If( lRet == .F. )
    conout( "Error: " + cError )
  Else
    cContent := MemoRead( cCA )
    varinfo( "CA", cContent )
  Endif
Return
