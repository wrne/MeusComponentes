#Include 'Protheus.ch'

#Define MONITOR_STATUS		1
#Define MONITOR_SERVICO		2
#Define MONITOR_IP			3
#Define MONITOR_PORTA		4
#Define MONITOR_URL			5
#Define MONITOR_OBS			6

/*
=====================================================================================
|Programa: monitorWeb    |Autor: Wanderley R. Neto                  |Data: 06/12/2019|
=====================================================================================
|Descrição: Rotina para monitorar conexoes dos Web Services.                        |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function monitorWeb()

// Define linhas dos serviços
Local aServicos		:= obtemDados()

	MontaTela(aServicos)
	// VErifica status do serviço
	// Monta a tela
	// Rotina de atualização.

Return Nil

/*
=====================================================================================
|Programa: monitorWeb    |Autor: Wanderley R. Neto                   |Data: 06/12/2019|
=====================================================================================
|Descrição: Define os serviços monitorados                                          |
|                                                                                   |
=====================================================================================
*/
Static Function obtemDados()
Local aDados	:= {}

	AAdd(aDados,{;	
				.F.,;								// Indica se serviço está ativo ou não
				'.TOTVS_P12_SCHEDULE_FLUIG',;		// Descrição do serviço
				'192.168.9.16',;					// IP do Serviço
				'8181',;							// Porta
				'http://192.168.9.16:8181/ws/',;	// URL de acesso
				'P12 - Soap (Fluig)';				// Obs
				})

	AAdd(aDados,{;
				.F.,;
				'.TOTVS_P12_SCHEDULE',;
				'192.168.9.16',;
				'7061',;
				'http://192.168.9.16:7061/rest/',;
				'P12 - Rest (Eiji)';
				})

	AAdd(aDados,{;
				.F.,;
				'.TOTVS_P12_desenv_FLUIG',;
				'192.168.9.17',;
				'8012',;
				'http://192.168.9.17:8012/api',;
				'P12 Desenv - Rest (Fluig Produtos)';
				})

Return aDados

/*
=====================================================================================
|Programa: monitorWeb    |Autor: Wanderley R. Neto                   |Data: 06/12/2019|
=====================================================================================
|Descrição: Verifica status e atualiza os serviços                                  |
|                                                                                   |
=====================================================================================
*/
Static Function AtuStatus(aServicos)

Local nServ		:= 0
Local cHtmlPage	:= ''
Local lStatus	:= .T.

	CursorWait()
	For nServ := 1 To Len(aServicos)

		lStatus := .T.
		cHtmlPage := Httpget(aServicos[nServ,MONITOR_URL],,10) // Aguarda 10 segundos
		
		Sleep(2000)

		If cHtmlPage == Nil
			lStatus := .F.
		Else
			If Empty(AllTrim(cHtmlPage)) .Or. 'invalid proc return' $ AllTrim(cHtmlPage)
				lStatus := .F.
			EndIf
		EndIf

		aServicos[nServ, MONITOR_STATUS] := lStatus

	Next nServ
	CursorArrow()
Return aServicos

/*
=====================================================================================
|Programa: monitorWeb    |Autor: Wanderley R. Neto                   |Data: 06/12/2019|
=====================================================================================
|Descrição: Monta tela de monitor com base nos serviços carregados                  |
|                                                                                   |
=====================================================================================
*/
Static Function MontaTela(aServicos)

Local oDlg		:= Nil
Local oLstServ	:= Nil
Local oBtn1		:= Nil
Local oBtn2		:= Nil
Local oBtn3		:= Nil
Local nTimer	:= 180000 // Disparo a cada 3 minutos
// Local nTimer	:= 10000 // Disparo a cada 10 minutos
Local oOk		:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oNo		:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local aCabec	:= {'','Serviço','IP','Porta','URL'}
Local bAtuStt	:= {|| AtuStatus(aServicos), oLstServ:Refresh() }
Local bReset	:= {|| ResetServ(aServicos, oLstServ:nAt), oLstServ:Refresh() }


	oDlg:= TDialog():New(000,000,700,1000,'MONITOR - SERVIÇOS WEB',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")
	
		oLstServ := TWBrowse():New(2,2,486,308,,aCabec,,oDlg,,,,,,,,,,,,,,.T.,,,,.T.,.T.)
			oLstServ:SetArray( aServicos )
			oLstServ:bLine := {|| {;
									iif(aServicos[oLstServ:nAt,MONITOR_STATUS],oOk,oNo),;
									aServicos[oLstServ:nAt,MONITOR_SERVICO	],;
									aServicos[oLstServ:nAt,MONITOR_IP		],;
									aServicos[oLstServ:nAt,MONITOR_PORTA	],;
									aServicos[oLstServ:nAt,MONITOR_URL		],;
									aServicos[oLstServ:nAt,MONITOR_OBS		],;
								}}
			
		Eval(bAtuStt)	    
	 
	    oTimer := TTimer():New(nTimer, bAtuStt, oDlg )
	    oTimer:Activate()

		oBtn1 := TButton():New( 320, 215, "Reiniciar",	oDlg,bReset,  80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn2 := TButton():New( 320, 315, "Atualizar",	oDlg,bAtuStt, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn3 := TButton():New( 320, 415, "Fechar", 	oDlg,{|| oDlg:End() }, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	oDlg:Activate()

Return


Static Function ResetServ(aServicos,nLinha)

Local cPrData		:= ''
Local cPasta		:= '\temp\'
Local cServer		:= ''

// If cFilAnt <> Nil
// 	cPrData := SuperGetMv('MV_XPATPR',,'D:\Protheus12\Protheus_Data\')
// Else	
	cPrData := 'D:\Protheus12\Protheus_Data\'
// EndIf

CursorWait()	
If aServicos[nLinha,MONITOR_IP]<>'192.168.9.16'
	cServer := aServicos[nLinha,MONITOR_IP]
	cPrData := 'D:\Protheus12_Homologacao\Protheus_Data\'
EndIf

u_ResetSrv(IsBlind(), aServicos[nLinha,MONITOR_URL], cPrData, cServer, '"'+AllTrim(aServicos[nLinha,MONITOR_SERVICO])+'"', cPasta)
CursorArrow()

Return