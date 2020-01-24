#Include 'Protheus.ch'

#Define LOG_FILIAL		1
#Define LOG_PRODUTO		2
#Define LOG_DOCUMENTO	3
#Define LOG_DATA		4
#Define LOG_ARMORI		5
#Define LOG_ARMDES		6
#Define LOG_QUANTIDADE	7
#Define LOG_USUARIO		8
#Define LOG_ROTINA 		9
#Define LOG_SUCESSO		10
#Define LOG_OBSERVACAO	11

/*
=====================================================================================
|Programa: TransfArm    |Autor: Wanderley R. Neto                  |Data: 16/10/2019|
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
User Function transfArm();Return Nil

Class TransfArm

	Data cProduto
	Data cArmOri
	Data cArmDes
	Data cLote
	Data nQtd
	Data dValidL
	Data dFabricL
	Data cMensagem

	Method New(cProduto,cArmOri,cArmDes,cLote,nQtd,lLog) Constructor
	Method Clear()
	Method ObtemVldLote()
	MEthod ObtemMsg() 
	Method VldLocal()
	Method VldQuant()

EndClass


/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Construtor da Transferencia entre Armazens, define as propriedades      |
|                                                                                   |
=====================================================================================
*/
Method New(cProduto,cArmOri,cArmDes,cLote,nQtd) Class TransfArm

	::cProduto	:= cProduto
	::cArmOri	:= cArmOri
	::cArmDes	:= cArmDes
	::cLote		:= cLote
	::nQtd		:= nQtd
	::cMensagem	:= ''
	::obtemVldLote() // Busca validade do lote

Return Self

/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                   |Data: 16/10/2019|
=====================================================================================
|Descrição: Limpa as propriedades do objeto quando o mesmo não for mais utilizado   |
|                                                                                   |
=====================================================================================
*/
Method Clear() Class TransfArm

	::cProduto		:= Nil
	::cArmOri		:= Nil
	::cArmDes		:= Nil
	::cLote			:= Nil
	::nQtd			:= Nil
	::dValidL		:= Nil

Return Self

/*
=====================================================================================
|Programa: uTransfArm    |Autor: Wanderley R. Neto                  |Data: 16/10/2019|
=====================================================================================
|Descrição: Obtem a data de validade do lote indicado                               |
|                                                                                   |
=====================================================================================
*/
Method obtemVldLote() Class TransfArm

Local dValid	:= dDataBase
Local cMsg		:= ''
Local aAreas		:= {;
							 SB8->(GetArea()),;
							 GetArea()}

	SB8->(DbSetOrder(5)) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->( DbSeek( xFIlial('SB8') + ::cProduto + ::cLote ) )

		::dValidL	:= SB8->B8_DTVALID
		::dFabricL	:= SB8->B8_DFABRIC
	Else

		cMsg := 'Não foi possível posicionar lote para obter validade do produto'
		
		Conout('TRARM'+' - '+DToC(dDataBase)+' '+Time()+'| '+cMsg)
		::cMensagem += cMsg

	EndIf

	Aeval( aAreas, {|x| RestArea(x) })

Return 

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Verifica se existe arm criado para o destino. Caso não exista tenta     |
| criar um                                                                          |
=====================================================================================
*/
Method VldLocal() Class TransfArm

Local lValid		:= .T.
Local aSB9		:= {}
Local aAreas	:= {;
					 SB9->(GetArea()),;
					 SB2->(GetArea()),;
					 GetArea()}

Private lMsErroAuto	:= .F.	

	DbSelectArea('SB2')
	SB2->(DbSetOrder(1))
	If !SB2->( DbSeek( xFilial('SB2') + ::cProduto + ::cArmDes ) )

		DbSelectArea("SB9")
		SB9->(DbSetOrder(1)) //B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
		 	
		aSB9 :={;
				{"B9_FILIAL"	,cFilAnt  	,Nil},;
				{"B9_COD"		,::cProduto	,Nil},;
				{"B9_LOCAL"		,::cArmDes 	,Nil},;
				{"B9_DATA"		,dDataBase	,Nil},;
				{"B9_QINI"		,0   		,Nil}}
		 
		//Iniciando transação e executando saldos iniciais
		Begin Transaction
			MSExecAuto({|x,y| Mata220(x,y)}, aSB9)
			 
			//Se houve erro, mostra mensagem
			If lMsErroAuto
				lValid := .F.
				// MostraErro()
				DisarmTransaction()
				::cMensagem += 'Não existe armazém para a transferência. Não foi possível incluir automaticamente.'
			Else	
				::cMensagem += 'Um saldo inicial foi incluido automaticamente para permitir a transferência.'
			EndIf
		End Transaction

	EndIf

Aeval( aAreas, {|x| RestArea(x) })
Return lValid

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Verifica se existe saldo suficiente para a transferencia no armazem ori |
|                                                                                   |
=====================================================================================
*/
Method VldQuant() Class TransfArm

Local lValid	:= .T.
Local aAreas		:= {;
							 SB2->(GetArea()),;
							 GetArea()}

	DbSelectArea('SB2')
	SB2->(DbSetOrder(1))

	If SB2->( DbSeek( xFilial('SB2') + ::cProduto + ::cArmOri ) )
	
		// Gustavo indicou que preferia que não fosse validado as quantidades 
		//  de "reserva". Preferindo tansferir todo o saldo possível

		If SB2->(B2_QATU-B2_QEMP-B2_RESERVA-B2_QPEDVEN) < ::nQtd
			lValid := .F.
			::cMensagem += 'Saldo insuficiente no armazém para a transferência.'
		EndIf
	
	EndIf

Aeval( aAreas, {|x| RestArea(x) })
Return lValid

Method ObtemMsg() Class TransfArm
Return ::cMensagem

/*
=====================================================================================
|Programa: uTransfArm   |Autor: Wanderley R. Neto                  |Data: 17/10/2019|
=====================================================================================
|Descrição: Teste do componente.                                                    |  
|                                                                                   |
=====================================================================================
*/
User Function uTST001()
Local oTransf := TransfArm():New('I212.200.SP.002','20','40','AUTO014380',1000)

oTransf:Transferir()
MsgAlert('Finalizou')

Return


