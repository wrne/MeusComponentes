#Include 'Protheus.ch'

#Define  CAMPOS_SN_CHAR	'B1_IMPORT|B1_INDUSTR'
#Define  CAMPOS_SN_NUM	'B1_GARANT'
/*
=====================================================================================
|Programa: CFATA010    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Classe para cadastro de novo myProduto                                    |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function cProduto()
Return Nil

Class myProduto From ExecAuto
	Data cCodigo
	Data nOperacao
	Data lLote
	Data lSucesso
	Data cErro

	Method New(nOpc) Constructor
	Method ValidaCod()
	Method AddCampo(cCampo,xValor)
	Method FechaProduto()
	Method Gravar()
	Method InfoErro()

EndClass

/*
=====================================================================================
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Instancia novo objeto para cadastro de produtos                         |
|                                                                                   |
=====================================================================================
*/
Method New(nOpc,lLote) Class myProduto

Default lLote		:= .F.

	_Super:New()

	::nOperacao := nOpc
	::lLote 		:= lLote
	::lSucesso	:= .T.

Return Self

/*
=====================================================================================
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Valida se código informado é valido par inclusão                        |
|                                                                                   |
=====================================================================================
|Parametros|cCodigo: Código a ser validado. Verifica se código não existe na tabela |
|          |lSobrepor: Se o cód ja existir, muda a operação paa ALTERAÇÃO           |
=====================================================================================
*/
Method ValidaCod(cCodigo, lSobrepor) Class myProduto

Local lValido 			:= .F.
Local aAreas		:= {;
							 SB1->(GetArea()),;
							 GetArea()}
	
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	If !Empty(cCodigo)
		
		// Verifica chave única
		lValido := ExistChav('SB1',cCodigo)
		
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
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Adiciona campo ao array usado no ExecAuto                               |
|                                                                                   |
=====================================================================================
*/
Method AddCampo(cCampo, xValor) Class myProduto

	// Verifica se combo de Sim/Não do campo é representada por números (1=Sim;2=Nao)
	If AllTrim(cCampo) $ 'B1_GARANT|B1_MSBLQL|B1_IMPZFRC|B1_TIPCONV|B1_MCUSTD|B1_TIPE|B1_FAMILIA|B1_APROPRI|'+;
								'B1_TIPODEC|B1_FANTASM|B1_RASTRO|B1_AJUDIF|B1_PRODSBP|B1_MEPLES|B1_VALEPRE|B1_CARGAE|B1_GARANT|B1_TPDP|B1_PORCPRL|B1_INTEG'+;
								'B1_FORAEST|B1_MONO|B1_MRP|B1_CONTSOC|B1_GRADE|B1_IRRF|B1_CONTRAT|B1_LOCALIZ|B1_ANUENTE|B1_IMPORT|B1_INDUSTR|B1_BALANCA|B1_TIPOCQ|'+;
								'B1_SOLICIT|B1_AGREGCU|B1_QUADPRO|B1_INSS|B1_FLAGSUG|B1_QTDSER|B1_CLASSVE|B1_MIDIA|B1_ENVOBR|B1_REQUIS|B1_SELO|B1_USAFEFO|'+;
								'B1_CPOTENC|B1_PIS|B1_COFINS|B1_CSLL|B1_FRETISS|B1_RETOPER|B1_CALCFET|B1_TPREG|B1_IVAAJU|B1_ESCRIPI|B1_FUSTF|B1_DESPIMP|'+;
								'B1_FETHAB|B1_FECOP|B1_CRICMS|B1_CFEM|B1_CFEMS|B1_PRODREC|B1_RPRODEP|B1_TFETHAB|B1_REFBAS|B1_TPPROD|B1_PRN944I|B1_RICM65|B1_DCI|'+;
								'B1_REGESIM|B1_RSATIVO|B1_CRICMST|'

		if AllTrim(xValor) == 'S'
			xValor := '1'
		Else
			xValor := '2'
		EndIf

	EndIf

	// Verifica se combo de Sim/Não usa numeraçao fora do padrao (0=Sim;1=Nao)
	If AllTrim(cCampo) $ 'B1_ENVOBR'


		if AllTrim(xValor) == 'S'
			xValor := '0'
		Else
			xValor := '1'
		EndIf

	EndIf

	// Verifica se combo de Sim/Não usa numeraçao fora do padrao (1=Sim;0=Nao)
	If AllTrim(cCampo) $ 'B1_CRICMS'

		if AllTrim(xValor) == 'S'
			xValor := '1'
		Else
			xValor := '0'
		EndIf

	EndIf


	// ------------------------------------------------------------------------------------
	// Verifica se atualização ocorrerá em lote.
	// Caso seja, será utilizado o array de itens da ExecAuto e todos os registros
	// serão processados de uma vez pelo Usuario
	// ------------------------------------------------------------------------------------
	If ::lLote

		_Super:AddCampoItem(cCampo, xValor)

	Else

		_Super:AddCabec(cCampo, xValor)

	EndIf

	If AllTrim(cCampo) == 'B1_COD'
		::cCodigo = xValor
	EndIf

Return Self

/*
=====================================================================================
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Para a inclusão em lote, fecha o array de itens e o prepara para um     |
| novo Produto.                                                                     |
=====================================================================================
*/
Method FechaProduto() Class myProduto

	_Super:AddItem()

Return

/*
=====================================================================================
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Grava myProduto de acordo com a operação definida                       |
|                                                                                   |
=====================================================================================
*/
Method Gravar() Class myProduto

Local nProd				:= 0
Local nPosProd			:= 0
Local nOpBkp			:= 0
Local lAltOpc			:= .F.

Private	lMsErroAuto	:= .F.

	If ::lLote
		
		::cErro := ''

		For nProd := 1 To Len(::aItens)

			nPosProd := AScan(::aItens[nProd], {|x| AllTrim(x[1]) == 'B1_COD'} )
			If ::nOperacao == 3;
					.And. ! ::ValidaCod(aItens[nProd,nPosProd,1])
				
				lAltOpc		:= .T.
				nOpBkp		:= ::nOperacao
				::nOperacao := 4

			EndIf

			MSExecAuto({|x,y| Mata010(x,y)},::aItens[nProd],::nOperacao)

			If lMsErroAuto
				::cErro += MostraErro() + CRLF
				::lSucesso	:= .F.
				
			EndIf

		Next nProd

	Else

		::cErro := ''

		MSExecAuto({|x,y| Mata010(x,y)},::aCabec,::nOperacao)

		If lMsErroAuto
			::cErro := MostraErro('\logs\','log_cadproduto.txt')
			::lSucesso	:= .F.
			
		EndIf

	EndIf

Return ::lSucesso


/*
=====================================================================================
|Programa: cProduto    |Autor: Wanderley R. Neto                   |Data: 31/01/2019|
=====================================================================================
|Descrição: Retorna mensagem de erro.                                               |
|                                                                                   |
=====================================================================================
*/
Method InfoErro() Class myProduto
Return ::cErro