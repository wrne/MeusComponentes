#Include 'Protheus.ch'

#Define LOG_FILIAL		1
#Define LOG_PRODUTO		2
#Define LOG_DOCUMENTO	3
#Define LOG_DATA		4
#Define LOG_ARMORI		5
#Define LOG_ARMDES		6
#Define LOG_QUANTIDADE	7
#Define LOG_USUARIO		8
#Define LOG_LOTE		9
#Define LOG_VALID		10
#Define LOG_FABRIC		11
#Define LOG_ROTINA 		12
#Define LOG_SUCESSO		13
#Define LOG_OBSERVACAO	14

/*
=====================================================================================
|Programa: TransfArm2    |Autor: Wanderley R. Neto                  |Data: 16/10/2019|
=====================================================================================
|Descrição: Classe que realiza uma transferencia entre armazens de um determinado   |
| produto                                                                           |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function trfArm2();Return Nil

Class TransfArm2

	Data aTransfs

	Data lHabilitaLog
	Data lLog
	Data aLog


	Method New() Constructor
	Method AddTransf(cProduto,cArmOri,cArmDes,cLote,nQtd)
	Method Clear()
	Method Transferir()
	Method HabilitaLog()
	Method ObtemLog()

EndClass


/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Construtor da Transferencia entre Armazens, define as propriedades      |
|                                                                                   |
=====================================================================================
*/
Method New() Class TransfArm2

	::aTransfs	:= {}
	::lLog		:= .F.
	::aLog		:= {}

Return Self

/*
=====================================================================================
|Programa: uTransfArm2    |Autor: Wanderley R. Neto                   |Data: 24/10/2019|
=====================================================================================
|Descrição: Adiciona uma nova transferencia para ser processada em lote             |
|                                                                                   |
=====================================================================================
*/
Method AddTransf(cProduto,cArmOri,cArmDes,cLote,nQtd) Class TransfArm2


	oTrf := TransfArm():New(cProduto,cArmOri,cArmDes,cLote,nQtd)

	AAdd(::aTransfs, oTrf)

	AAdd(::aLog, Array(14))

	::aLog[Len(::aLog),LOG_FILIAL]		:= cFilAnt
	::aLog[Len(::aLog),LOG_PRODUTO] 	:= cProduto
	::aLog[Len(::aLog),LOG_DATA]		:= dDataBase
	::aLog[Len(::aLog),LOG_ARMORI]		:= cArmOri
	::aLog[Len(::aLog),LOG_ARMDES]		:= cArmDes
	::aLog[Len(::aLog),LOG_QUANTIDADE]	:= nQtd
	::aLog[Len(::aLog),LOG_LOTE]		:= cLote
	::aLog[Len(::aLog),LOG_VALID]		:= SToD('')
	::aLog[Len(::aLog),LOG_FABRIC]		:= SToD('')
	::aLog[Len(::aLog),LOG_USUARIO]		:= RetCodUsr()+'-'+UsrRetName(RetCodUsr())
	::aLog[Len(::aLog),LOG_ROTINA]		:= FunName() //TODO: VErificar FUnname() - No log aparece RPC

Return Self
/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Limpa as propriedades do objeto quando o mesmo não for mais utilizado   |
|                                                                                   |
=====================================================================================
*/
Method Clear() Class TransfArm2

	::aTransfs		:= aSize(::aTransfs,0)	
	::lHabilitaLog	:= Nil
	::aLog			:= aSize(::aLog,0)	

Return Self

/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Respnsavel por gerar a transferencia do produto entre os armazens       |  
| indicados.                                                                        |
=====================================================================================
*/
Method Transferir() Class TransfArm2

	Local lSucess	:= .F.
	Local cDoc		:= GetSxeNum('SD3', 'D3_DOC')
	Local cFilSB1	:= xFilial('SB1')
	Local nTrf		:= 0
	Local nQtd2U	:= 0
	Local aAutoTrf	:= {}
	Local aLinha	:= {}
	Local aAreas		:= {;
								 SD1->(GetArea()),;
								 SD2->(GetArea()),;
								 SD3->(GetArea()),;
								 GetArea()}

	Private lMsErroAuto	:= .F.

	AAdd(aAutoTrf, {cDoc, dDataBase})

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	For nTrf := 1 To Len(::aTransfs)
	

		// Valida se existe armazem para o produto, caso não tenha cria o saldo inicial
		If ::aTransfs[nTrf]:VldLocal() 
			lSucess := .T.
		Else	
			Conout('TRARM'+' - '+DToC(dDataBase)+' '+Time()+'| Tentativa de incluir Saldo Inicial no armazém '+::aTRansfs[nTrf]:cArmDes+' não foi concluida com sucesso.')
			If ::lLog
				::aLog[nTrf, LOG_SUCESSO] := 'NÃO'				
			EndIf
		EndIf

		If lSucess 
			If ! ::aTransfs[nTrf]:VldQuant()
				lSucess := .F.
				Conout('TRARM'+' - '+DToC(dDataBase)+' '+Time()+'| Saldo insuficiente no armazém '+::aTRansfs[nTrf]:cArmOri+' para transferencia.')
				If ::lLog
					::aLog[nTrf, LOG_SUCESSO] := 'NÃO'
				EndIf
			EndIf
		EndIf
		::aLog[nTrf, LOG_OBSERVACAO] := ::aTransfs[nTrf]:ObtemMsg() 
		::aLog[nTrf, LOG_VALID] 	 := ::aTransfs[nTrf]:dValidL 
		::aLog[nTrf, LOG_FABRIC] 	 := ::aTransfs[nTrf]:dFabricL 		

		If lSucess

			::aLog[nTrf, LOG_SUCESSO] := 'SIM'

			/** Montagem do execAuto do MAta261 */
			aLinha := {}
			AAdd(aLinha, {'ITEM', StrZero(nTrf,3)	, Nil})
			
			If SB1->( DbSeek( cFilSB1 + ::aTransfs[nTrf]:cProduto ) )
		
				nQtd2U := Round(QtdComp(ConvUm(SB1->B1_COD, ::aTransfs[nTrf]:nQtd, nQtd2U, 2)), TamSX3('D3_QTSEGUM')[2])

				// Origem
				AAdd(aLinha, {'D3_COD'		, SB1->B1_COD				,Nil})
				AAdd(aLinha, {'D3_DESCRI'	, SB1->B1_DESC				,Nil})
				AAdd(aLinha, {'D3_UM'		, SB1->B1_UM				,Nil})
				AAdd(aLinha, {'D3_LOCAL'	, ::aTransfs[nTrf]:cArmOri	,Nil})
				AAdd(aLinha, {'D3_LOCALIZ'	, ''						,Nil})
				
				//Destino
				AAdd(aLinha, {'D3_COD'		, SB1->B1_COD				,Nil})
				AAdd(aLinha, {'D3_DESCRI'	, SB1->B1_DESC				,Nil})
				AAdd(aLinha, {'D3_UM'		, SB1->B1_UM				,Nil})
				AAdd(aLinha, {'D3_LOCAL'	, ::aTransfs[nTrf]:cArmDes	,Nil})
				AAdd(aLinha, {'D3_LOCALIZ'	, ''						,Nil})

				// Complementos
				aadd(aLinha,{"D3_NUMSERI"	, ''						,Nil}) //Numero serie
			    aadd(aLinha,{"D3_LOTECTL"	, ::aTransfs[nTrf]:cLote	,Nil}) //Lote Origem
			    aadd(aLinha,{"D3_NUMLOTE"	, ''						,Nil}) //sublote origem
			    aadd(aLinha,{"D3_DTVALID"	, ::aTransfs[nTrf]:dValidL	,Nil}) //data validade
			    aadd(aLinha,{"D3_POTENCI"	, 0							,Nil}) // Potencia
			    aadd(aLinha,{"D3_QUANT"		, ::aTransfs[nTrf]:nQtd		,Nil}) //Quantidade
			    aadd(aLinha,{"D3_QTSEGUM"	, nQtd2U					,Nil}) //Seg unidade medida
			    aadd(aLinha,{"D3_ESTORNO"	, ''						,Nil}) //Estorno
			    aadd(aLinha,{"D3_NUMSEQ"	, ''						,Nil}) // Numero sequencia D3_NUMSEQ
			    
			    aadd(aLinha,{"D3_LOTECTL"	, ::aTransfs[nTrf]:cLote	,Nil}) //Lote Origem
			    aadd(aLinha,{"D3_NUMLOTE"	, ''						,Nil}) //sublote origem
			    aadd(aLinha,{"D3_DTVALID"	, ::aTransfs[nTrf]:dValidL	,Nil}) //data validade
			    aadd(aLinha,{"D3_ITEMGRD"	, ''						,Nil}) //Item Grade
			    
			    aadd(aLinha,{"D3_CODLAN"	, ''						,Nil}) //cat83 prod origem
			    aadd(aLinha,{"D3_CODLAN"	, ''						,Nil}) //cat83 prod destino

				AAdd(aAutoTrf, aLinha)

			EndIf
		EndIf
	
	Next nTrf

	If Len(aAutoTrf) > 1
		TrDocSeq()
		/** Chamado do ExecAuto */
		MsExecAuto({|x,y| mata261(x,y) }, aAutoTrf, 3) //Inclusão de Transferencia Mod. 2

		If lMsErroAuto
			lSucess := .F.
			Conout('TRARM2'+' - '+DToC(dDataBase)+' '+Time()+'| Falha ao gerar as transferencias.')
			
			AtuArrLog(@::aLog)

		Else
			Conout('TRARM2'+' - '+DToC(dDataBase)+' '+Time()+'| Transferencias concluidas.')		
		EndIf
	EndIf
	
	Aeval( aAreas, {|x| RestArea(x) })

Return lSucess

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Habilita a geração do log                                               |  
|                                                                                   |
=====================================================================================
*/
Method HabilitaLog() Class TransfArm2

	::lLog := .T.

Return

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Habilita a geração do log                                               |  
|                                                                                   |
=====================================================================================
*/
Method ObtemLog() Class TransfArm2
Return aClone(::aLog)

/*
=====================================================================================
|Programa: uTransfArm2    |Autor: Wanderley R. Neto                   |Data: 24/10/2019|
=====================================================================================
|Descrição: Devido à rotina MATA261, deve-se posicionar as tabelas SD1, SD2 e SD3 no|
| ultimo registro para que o campo de sequencia não seja afetado.                   |
=====================================================================================
*/
Static Function TrDocSeq()

DbSelectArea('SD1')
SD1->(DbGoTo(LastRec()))

DbSelectArea('SD2')
SD2->(DbGoTo(LastRec()))

DbSelectArea('SD3')
SD3->(DbGoTo(LastRec()))

Return 

/*
=====================================================================================
|Programa: uTransfArm2  |Autor: Wanderley R. Neto                  |Data: 25/10/2019|
=====================================================================================
|Descrição: Atualiza os registros do array de logs para que não seja exibido um     |
| "Sucesso" indevido.                                                               |
=====================================================================================
*/
Static Function AtuArrLog(aLog)

AEval(aLog, {|x| (x[LOG_SUCESSO] := 'Não', x[LOG_OBSERVACAO]+= 'Falha na Execução da Transferência') })

Return Nil

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Teste do componente.                                                    |  
|                                                                                   |
=====================================================================================
*/
User Function uTST002()
Local oTransf := TransfArm2():New('I212.200.SP.002','20','40','AUTO014380',1000)

oTransf:Transferir()
MsgAlert('Finalizou')

Return

