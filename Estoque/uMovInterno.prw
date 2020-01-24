
#Include 'Protheus.ch'

/*
=====================================================================================
|Programa: MovInterno    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Classe responsável por gerar um movimento interno no estoque.           |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function MovInterno();Return Nil

Class MovInterno From ExecAuto

	Data cDocumento
	Data dEmissao

	Method New()
	Method AddValues(cCampo, xValor)
	Method Gravacao(nOpcao)
	Method GetDocumento()

EndClass

/*
=====================================================================================
|Programa: MovInterno    |Autor: Wanderley R. Neto                 |Data: 16/10/2019|
=====================================================================================
|Descrição: Construtor da classe de movimento interno. Inicializa as propriedades   |
|                                                                                   |
=====================================================================================
*/
Method New() Class MovInterno

	_Super:New()

	::cDocumento	:= ''
	::dEmissao		:= CtoD('')

Return Self

/*
=====================================================================================
|Programa: MovInterno    |Autor: Wanderley R. Neto                 |Data: 16/10/2019|
=====================================================================================
|Descrição: Adiciona os valores para gravação do mov interno                        |
|                                                                                   |
=====================================================================================
*/
Method AddValues(cCampo, xValor) Class MovInterno

	If AllTrim(cCampo) == "D3_DOC"
		::cDocumento	:= xValor
	ElseIf AllTrim(cCampo) == "D3_EMISSAO"
		::dEmissao		:= xValor
	EndIf

	_Super:AddValues(cCampo, xValor)

Return Nil

/*
=====================================================================================
|Programa: MovInterno    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Descricao                                                               |
|                                                                                   |
=====================================================================================
*/
Method Gravacao(nOpcao) Class MovInterno

Local dDataBackup	:= dDataBase		//Backup da Data Base do Sistema
Local lReserva		:= .F.				//Determina se reservou o Documento para Inclusao
Local lRetorno		:= .T.				//Retorno da Rotina de Gravacao
Local nPosProd		:= 0
Local nPosUnMd		:= 0
Local cUnidMed		:= ""

Private	lMsErroAuto	:= .F.				//Determina se houve algum erro durante a Execucao da Rotina Automatica

	If !Empty(::dEmissao)
		dDataBase := ::dEmissao
	EndIf

	DbSelectArea("SD3")
	DbSetOrder(2)	//D3_FILIAL, D3_DOC, D3_COD

	If nOpcao == 3
		If Empty(::cDocumento)
			lReserva := .T.
			::AddValues("D3_DOC", GetSx8Num("SD3", "D3_DOC"))
		EndIf
	Else
		If Empty(::cDocumento)
			lRetorno	:= .F.
			::cMensagem	:= "Documento não informado."
		Else
			If !SD3->(DbSeek(xFilial("SD3") + ::cDocumento))
				lRetorno	:= .F.
				::cMensagem	:= "Documento não localizado."
			EndIf
		EndIf
	EndIf

	If lRetorno .and. Len(::aValues) > 0
		nPosProd := Ascan(::aValues, {|x| x[01] == "D3_COD"})
		nPosUnMd := Ascan(::aValues, {|x| x[01] == "D3_UM"})

		If nPosProd > 0
			DbSelectArea("SB1")
			DbSetOrder(1)

			If SB1->(DbSeek(xFilial("SB1") + ::aValues[nPosProd][02]))
				cUnidMed := SB1->B1_UM

				If nPosUnMd > 0
					::aValues[nPosUnMd][02] := cUnidMed
				Else
					Aadd(::aValues, {"D3_UM", cUnidMed, NIL})
				EndIf
			EndIf
		EndIf

		MSExecAuto({|a, b, c| MATA240(a, b)}, ::aValues, nOpcao)

		If lMsErroAuto

			lRetorno := .F.

			If lReserva
				RollBackSx8()
			EndIf

			If ::lExibeTela
				MostraErro()
			EndIf

			If ::lGravaLog
				::cMensagem := MostraErro(::cPathLog, ::cFileLog)
			EndIf
		Else
			If lReserva
				ConfirmSx8()
			EndIf
		EndIf
	EndIf

	//Restaura a Data Base Original
	dDataBase := dDataBackup

Return lRetorno

/*
=====================================================================================
|Programa: MovInterno    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Descricao                                                               |
|                                                                                   |
=====================================================================================
*/
Method GetDocumento() Class MovInterno
Return ::cDocumento