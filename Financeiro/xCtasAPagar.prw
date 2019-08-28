#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function ContaAPagar()
Return Nil

/*
=====================================================================================
|Programa: cContaAPagar    |Autor: Wanderley R. Neto               |Data: 18/01/2019|
=====================================================================================
|Descrição: Classe resposável pela geração de titulos de contas a pagar.            |
|                                                                                   |
=====================================================================================
*/
Class ContaAPagar From ExecAuto

	Data nOpcao
	Data cErro
	Data lPaMovBco
	
   Method New(nOpc) Constructor
	Method AddCampo(cCampo, xValor)
	Method Baixar()
	Method EstBaixa()
   Method Gravacao()
	Method InfoErro()

EndClass

/*
=====================================================================================
|Programa: ContaAPagar    |Autor: Wanderley R. Neto                |Data: 18/01/2019|
=====================================================================================
|Descrição: Construtor, inicializa as propriedades                                  |
|                                                                                   |
=====================================================================================
*/
Method New(nOpc) Class ContaAPagar

_Super:New()
::nOpcao		:= nOpc
::lPaMovBco	:= .F.

Return Self


/*
=====================================================================================
|Programa: ContaAPagar    |Autor: Wanderley R. Neto                |Data: 18/01/2019|
=====================================================================================
|Descrição: Adiciona informações ao array que será utilizado no execAuto para       |
| interação do título                                                               |
=====================================================================================
*/
Method AddCampo(cCampo, xValor) Class ContaAPagar

_Super:AddCabec(cCampo, xValor)

Return Nil          

/*
=====================================================================================
|Programa: cContaAPagar    |Autor: Wanderley R. Neto                   |Data: 18/01/2019|
=====================================================================================
|Descrição: Realiza gravação do pedido                                              |
|                                                                                   |
=====================================================================================
*/
Method Gravacao() Class ContaAPagar

Local lRetorno		:= .T.

Private	lMsErroAuto	:= .F.

::cErro := ''

/*
// CAMPOS OBRIGATORIOS PARA EXECAUTO
			{"E2_NUM"		,cNum		,Nil},;
			{"E2_PREFIXO"	,cPrefixo	,Nil},;
			{"E2_PARCELA"	,cParc		,Nil},;
			{"E2_TIPO"		,cTipo		,Nil},; 
			{"E2_NATUREZ"	,cNaturez	,Nil},;
			{"E2_FORNECE"	,cFornec	,Nil},; 
			{"E2_LOJA"		,cLoja		,Nil},; 
			{"E2_EMISSAO"	,dDataBase	,NIL},;
			{"E2_VENCTO"	,dDataBase	,NIL},;
			{"E2_VENCREA"	,dDataBase	,NIL},;
			{"E2_VALOR"		,1100		,Nil}}
*/

//Gravacao do Titulo de Contas a Pagar
MSExecAuto({|x,y,z| Fina050(x,y,z)},::aCabec,,::nOpcao,,,,,,,,::lPaMovBco)
	
If lMsErroAuto
	//TODO: Indicar caminho para log do MostraErro
	lRetorno := .F.
	::cErro := MostraErro()                                              

EndIf
	
	
Return lRetorno          

/*
=====================================================================================
|Programa: cContaAPagar    |Autor: Wanderley R. Neto               |Data: 18/01/2019|
=====================================================================================
|Descrição: Realiza a baixa do título.                                              |
|                                                                                   |
=====================================================================================
*/
Method Baixar() Class ContaAPagar

/* Implementação da baixa a Pagar do título. */

Return ::Self

/*
=====================================================================================
|Programa: ContaAPagar    |Autor: Wanderley R. Neto                |Data: 18/01/2019|
=====================================================================================
|Descrição: MEtodo para estornar a baixa do título.                                 |
|                                                                                   |
=====================================================================================
*/
Method EstBaixa() Class ContaAPagar

/* Implementação do estorno da baixa a Pagar do título. */

Return ::Self

/*
=====================================================================================
|Programa: xCtasAPagar    |Autor: Wanderley R. Neto                |Data: 26/01/2019|
=====================================================================================
|Descrição: Retorna a mensagem de erro após algum procedimento                      |
|                                                                                   |
=====================================================================================
*/
Method InfoErro() Class ContaAPagar
Return ::cErro