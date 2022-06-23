#Include 'protheus.ch'

/*/{Protheus.doc} User Function ITMT120
  (long_description)
  @type  Function
  @author Leandro Lemos
  @since 23/06/2022
  @version P12
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
User Function ITMT120()
Local aCab := PARAMIXB[1]
Local aItens := PARAMIXB[2]
Local aRateio := PARAMIXB[3]
Local aPrj := PARAMIXB[4]
Local aRet := {}

//Customizações do cliente

aRet := {aCab,aItens,aRateio,aPrj}

Return aRet
