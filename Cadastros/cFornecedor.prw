#Include 'Protheus.ch'

#Define  CAMPOS_SN_CHAR	'B1_IMPORT|B1_INDUSTR'
#Define  CAMPOS_SN_NUM	'B1_GARANT'
/*
=====================================================================================
|Programa: CFATA010    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Classe para cadastro de novo myFornecedor                                    |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function cFornecedor()
Return Nil

Class myFornecedor From ExecAuto
	Data cCodigo
	Data nOperacao
	Data lSucesso
	Data cErro

	Method New(nOpc) Constructor
	Method ValidaCod()
	Method AddCampo(cCampo,xValor)
	Method Gravar()
	Method InfoErro()

EndClass

/*
=====================================================================================
|Programa: cFornecedor    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Instancia novo objeto para cadastro de produtos                         |
|                                                                                   |
=====================================================================================
*/
Method New(nOpc) Class myFornecedor

	_Super:New()

	::nOperacao := nOpc
	::lSucesso	:= .T.

Return Self

/*
=====================================================================================
|Programa: cFornecedor |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Valida se código informado é valido par inclusão                        |
|                                                                                   |
=====================================================================================
|Parametros|cCodigo: Código a ser validado. Verifica se código não existe na tabela |
|          |lSobrepor: Se o cód ja existir, muda a operação paa ALTERAÇÃO           |
=====================================================================================
*/
Method ValidaCod(cCodigo, lSobrepor) Class myFornecedor

Local lValido 			:= .F.
Local aAreas		:= {;
							 SA2->(GetArea()),;
							 GetArea()}
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(1))

	If !Empty(cCodigo)
		
		// Verifica chave única
		lValido := ExistChav('SA2',cCodigo)
		
		// -----------------------------------------------------------------------------
		// Se código ja existir durante uma inclusão e 
		// usuario definir que o produto deve ser sobreposto, 
		// muda operação para alteração
		// -----------------------------------------------------------------------------
		If ! lValido;
				.And. ::nOperacao == 3;
				.And. lSobrepor

			::nOperacao := 4
			lValido := .T.

		EndIf
		
		If !lValido
			::cErro := 'Código já existe na base'
		EndIf

	EndIf

	Aeval( aAreas, {|x| RestArea(x) })

Return lValido

/*
=====================================================================================
|Programa: cFornecedor |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Adiciona campo ao array usado no ExecAuto                               |
|                                                                                   |
=====================================================================================
*/
Method AddCampo(cCampo, xValor) Class myFornecedor

	// Verifica se combo de Sim/Não do campo é representada por números (1=Sim;2=Nao)
	If AllTrim(cCampo) $ 'A2_RECPIS|A2_RECCOFI|A2_RECFET|A2_RECCSLL|A2_RECSEST|A2_COMI_SO|A2_VINCULA|A2_ID_REPR|A2_RET_PAI'+;
								'|A2_TPESSOA|A2_B2B|A2_PLCRRES|A2_PLFIL|A2_CIVIL|A2_PAGAMEN|A2_MSBLQL|A2_FRETISS|A2_CTARE|A2_SIMPNAC|A2_CALCIRF|A2_INSCMU|A2_ENDNOT|A2_FOMEZER|A2_FABRICA'+;
								'|A2_RECCIDE|A2_IRPROG|A2_INCULT|A2_RFACS|A2_RFABOV|A2_MINIRF|A2_CONTPRE|A2_REGESIM|A2_INCLTMG|A2_CPOMSP|A2_IMPIP|A2_MJURIDI|A2_CONFFIS|A2_SITESBH|A2_TPJ'+;
								'|A2_TRIBFAV|A2_RETISI|A2_CCICMS|A2_TPCONTA|A2_TPRNTRC|A2_STRNTRC|A2_EQPTAC|A2_LOCQUIT|A2_RECFMD|A2_TIPCTA|A2_XCOMTER|A2_INOVAUT|A2_CONTRIB|A2_MINPUB'+;
								'|A2_INDRUR|A2_UFFIC|A2_ISSRSLC|A2_TPREG|A2_SUBCON|A2_RFASEMT|A2_RIMAMT|A2_RFUNDES|A2_CALCINP|A2_DESPORT|A2_DEDBSPC|A2_CPRB|A2_PAGGFE|A2_FORNEMA|A2_REGPB'

		if AllTrim(xValor) == 'S'
			xValor := '1'
		Else
			xValor := '2'
		EndIf

	EndIf

	// VErifica se o combo [sim/nao] tem o padrão invertido graças a um desgraçado qualquer..
	If AllTrim(cCampo) $ 'A2_PAGAMEN'

		if AllTrim(xValor) == 'S'
			xValor := '2'
		Else
			xValor := '1'
		EndIf

	EndIf


	_Super:AddCabec(cCampo, xValor)

	If AllTrim(cCampo) == 'A2_COD'
		::cCodigo = xValor
	EndIf

Return Self


/*
=====================================================================================
|Programa: cFornecedor    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Grava myFornecedor de acordo com a operação definida                       |
|                                                                                   |
=====================================================================================
*/
Method Gravar() Class myFornecedor

Local nProd				:= 0
Local nPosProd			:= 0
Local nOpBkp			:= 0
Local lAltOpc			:= .F.

Private	lMsErroAuto	:= .F.
Private Inclui
Private Altera

	If ::nOperacao == 3
		Inclui := .T.
		Altera := .F.
	Else
		Inclui := .F.
		Altera := .T.
	EndIf

	::cErro := ''

	MSExecAuto({|x,y| Mata020(x,y)},::aCabec,::nOperacao)

	If lMsErroAuto
		::cErro := MostraErro('\logs\','log_cadfornecedor.txt')
		::lSucesso	:= .F.
		
	EndIf

Return ::lSucesso


/*
=====================================================================================
|Programa: cFornecedor |Autor: Wanderley R. Neto                   |Data: 31/01/2019|
=====================================================================================
|Descrição: Retorna mensagem de erro.                                               |
|                                                                                   |
=====================================================================================
*/
Method InfoErro() Class myFornecedor
Return ::cErro