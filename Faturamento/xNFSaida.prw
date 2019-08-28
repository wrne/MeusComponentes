#INCLUDE "Protheus.ch"

User Function NFSaida()
Return Nil

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 26/01/2019|
=====================================================================================
|Descrição: Classe para inclusão e exclusão de notas fiscais, inclusive sua Trans-  |
| missão ao Sefaz.                                                                  |
=====================================================================================
*/
Class NFSaida From ExecAuto

	Data Pedido
	Data Filial
	Data Serie
	Data Documento
	Data Cliente
	Data Loja
	Data Emissao
	
	Data erro
	Data Retorno

	Method New()
	Method Gravacao()
	Method Estorna()
	Method AddCabec(cCampo, xValor)
	Method Transmite()
	Method TransColab()

EndClass

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Instancia novo objeto                                                   |
|                                                                                   |
=====================================================================================
*/
Method New() Class NFSaida
	_Super:New()

	::Pedido   := ""
	::Filial    := ""
	::Serie    := ""
	::Documento     := ""
	::Cliente  := ""
	::Loja     := ""
	::Emissao  := CToD("")

Return Self

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Adiciona os campos do cabeçalho                                         |
|                                                                                   |
=====================================================================================
*/
Method AddCabec(cCampo, xValor) Class NFSaida

	If AllTrim(cCampo) == "F2_FILIAL"
		::Filial	:= xValor
	ElseIf AllTrim(cCampo) == "F2_SERIE"
		::Serie	:= xValor
	ElseIf AllTrim(cCampo) == "F2_DOC"
		::Documento 	:= xValor
	ElseIf AllTrim(cCampo) == "F2_CLIENTE"
		::Cliente	:= xValor
	ElseIf AllTrim(cCampo) == "F2_LOJA"
		::Loja		:= xValor
	ElseIf AllTrim(cCampo) == "F2_EMISSAO"
		::Emissao	:= xValor
	EndIf

	_Super:AddCabec(cCampo, xValor)

Return Nil

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Gera NF com base em pedido liberado. Rotina baseada na Preparação de DOc|
| do pedido de venda.                                                               |
=====================================================================================
*/
Method Gravacao() Class NFSaida

Local aPvlNfs 	:= {}
Local dDataBkp	:= dDataBase		//Backup da Data Base do Sistema
Local lRetorno	:= .T.				//Retorno da Rotina de Gravacao
Local Documento     := ""

Private	lMsErroAuto	:= .F.			//Determina se houve algum erro durante a Execucao da Rotina Automatica

	//Altera a Data da Gravacao
	If !Empty(::Emissao)
		dDataBase := ::Emissao
	EndIf

	aPvlNfs := MontaArrPV(::Pedido)

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³MaPvlNfs  ³ Autor ³Eduardo Riera ³ Data   ³28.08.1999       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Inclusao de Nota fiscal de Saida atraves do PV liberado     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os itens a serem gerados 				  ³±±
	±±³ ³ExpC2: Serie da Nota Fiscal                                          ³±±
	±±³ ³ExpL3: Mostra Lct.Contabil                                           ³±±
	±±³ ³ExpL4: Aglutina Lct.Contabil 										  ³±±
	±±³ ³ExpL5: Contabiliza On-Line 										  ³±±
	±±³ ³ExpL6: Contabiliza Custo On-Line    	 							  ³±±
	±±³ ³ExpL7: Reajuste de preco na nota fiscal 							  ³±±
	±±³ ³ExpN8: Tipo de Acrescimo Financeiro 				   			      ³±±
	±±³ ³ExpN9: Tipo de Arredondamento                                        ³±±
	±±³ ³ExpLA: Atualiza Amarracao Cliente x Produto                          ³±±
	±±³ ³ExplB: Cupom Fiscal                                                  ³±±
	±±³ ³ExpCC: Numero do Embarque de Exportacao                              ³±±
	±±³ ³ExpBD: Code block para complemento de atualizacao dos titulos financeiros.
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	::Documento := MaPvlNfs(aPvlNfs, ::Serie, .F., .F., .F., .T., .F., 0, 0, .F.)

	dDataBase  := dDataBkp


Return lRetorno

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Método de estorno da nota fiscal                                        |
|                                                                                   |
=====================================================================================
*/
Method Estorna() Class NFSaida

Local dDataBkp	:= dDataBase		//Backup da Data Base do Sistema

	DbSelectArea("SF2")
	DbSetOrder(1)

	//Altera a Data da Gravacao
	If !Empty(::Emissao)
		dDataBase := ::Emissao
	EndIf

	MSExecAuto({|a| MATA520(a)}, ::aCabec)

	If lMsErroAuto
		lRetorno := .F.

		If ::lExibeTela
			MostraErro()
		EndIf

		If ::lGravaLog
			::cMensagem := MostraErro(::cPathLog, ::cFileLog)
			//Para tratar bug do execauto
			If "Pesquisa nao encontrada com dados acima" $ ::cMensagem
				::cMensagem := ""
				lRetorno := .T.
			EndIf
		EndIf
	EndIf

	dDataBase  := dDataBkp
Return Self

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Método que direciona a transmissão da nota de acordo com a ferramenta   |
| utilizada                                                                         |
=====================================================================================
*/
Method Transmite() Class NFSaida

Local lRetorno			:= .F.

Private lUsaColab		:= UsaColaboracao("1")
Private cUSACOLAB		:= GetNewPar("MV_SPEDCOL","N")

If lUsaColab
	lRetorno := ::TransColab()
Else
	/* Implementar transmissão via TSS */
	lRetorno := .F.
EndIf

Return lRetorno

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 29/01/2019|
=====================================================================================
|Descrição: Monta arrau para a função maPvlNfs, baseadano fonte veixx01.prw         |
|                                                                                   |
=====================================================================================
*/
Static Function MontaArrPV(cNumPV)

Local aRet := {}
Local cFilSC6			:= xFilial('SC6')
Local cFilSC5			:= xFilial('SC5')
Local cFilSC9			:= xFilial('SC9')
Local cFilSE4			:= xFilial('SE4')
Local cFilSB1			:= xFilial('SB1')
Local cFilSB2			:= xFilial('SB2')
Local cFilSF4			:= xFilial('SF4')

DbSelectArea("SC5")
SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5") + cNumPV))

DbSelectArea("SC6")
SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial("SC6") + cNumPV))

DbSelectArea('SC9')
DbSelectArea('SE4')
DbSelectArea('SB1')
DbSelectArea('SB2')
DbSelectArea('SF4')

SC9->(DbSetOrder(1))
SE4->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1))
SF4->(DbSetOrder(1))

While SC6->(!EoF());
		.And. SC6->(C6_FILIAL + C6_NUM) == cFilSC6 + cNumPV

	SC9->(DbSeek(cFilSC9 + SC6->(C6_NUM + C6_ITEM)))
	nPrcVen := C9_PRCVEN

	SE4->(DbSeek(cFilSE4 + SC5->C5_CONDPAG))
	SB1->(DbSeek(cFilSB1 + SC6->C6_PRODUTO))
	SB2->(DbSeek(cFilSB2 + SC6->(C6_PRODUTO + C6_LOCAL)))
	SF4->(DbSeek(cFilSF4 + SC6->C6_TES))

	If SC5->C5_MOEDA <> 1
		nPrcVen := xMoeda(nPrcVen, SC5->C5_MOEDA, 1, dDataBase)
	EndIf

	aAdd(aRet, {SC9->C9_PEDIDO,;
		SC9->C9_ITEM,;
		SC9->C9_SEQUEN,;
		SC9->C9_QTDLIB,;
		nPrcVen,;
		SC9->C9_PRODUTO,;
		.F.,;
		SC9->(RecNo()),;
		SC5->(RecNo()),;
		SC6->(RecNo()),;
		SE4->(RecNo()),;
		SB1->(RecNo()),;
		SB2->(RecNo()),;
		SF4->(RecNo())})

	SC6->(DbSkip())
EndDo

Return aRet

/*
=====================================================================================
|Programa: cNFSaida    |Autor: Wanderley R. Neto                   |Data: 28/01/2019|
=====================================================================================
|Descrição: Realiza a transmissão da nota pelo Totvs Colaboração. Baseado no algo-  |
|  ritmo do fonte SPEDNFE.PRX                                                       |
=====================================================================================
*/
Method TransColab() Class NFSaida

Local cIdEnt 					:= ''
Local cAmbiente				:= ''
Local cModalidade				:= ''
Local cVersao					:= ''
Local lEnd						:= .F.
Local cRetorno					:= ''
Local lRetorno 				:= .F.

dbSelectArea('SF2')

lUsaColab := UsaColaboracao("1")

If ColCheckUpd()//IsReady(,,,lUsaColab)

	cIdEnt 		:= "000000"//GetIdEnt(lUsaColab)
	cAmbiente	:= ColGetPar("MV_AMBIENT","")+" - " +ColDescOpcao("MV_AMBIENT", ColGetPar("MV_AMBIENT","") )			
	cModalidade	:= ColGetPar("MV_MODALID","")+" - " +ColDescOpcao("MV_MODALID", ColGetPar("MV_MODALID","") )
	cVersao		:= ColGetPar("MV_VERSAO","")

	// SpedNFeTrf(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,	,		,aParam[04],aParam[05])
	// SpedNFeTrf(cAlias,  Serie,   DocumentoIni,DocumentoFim,  cIDEnt,cAmbiente,cModalidade,cVersao,lEnd,lCte,lAuto,dDataDe		,dDataAte,lAutomato)
	cRetorno :=;
	SpedNFeTrf( 'SF2',;
					::Serie,;
					::Documento,;
					::Documento,;
					cIDEnt,;
					cAmbiente,;
					cModalidade,;
					cVersao,;
					,,;
					.T.)
	
	If !Empty(cRetorno)
		::Retorno := cRetorno
		lRetorno := .T.
	Else	
		lRetorno := .F.
	EndIf

EndIf

Return lRetorno