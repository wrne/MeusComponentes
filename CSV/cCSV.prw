#Include 'Protheus.ch'

/*
=====================================================================================
|Programa: cCSV        |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Classe para importação de dados via arquivo CSV                         |
|                                                                                   |
=====================================================================================
*/
User Function cCsv()
Return Nil

Class ImpCSV 

	Data cArquivo
	Data nColunas
	Data nMaxColunas
	Data aColunas
	Data aDados
	Data cErro

	Method New( cPathArq ) Constructor
	Method SelArquivo()
	Method Importar()
	Method InfoErro()

EndClass

/*
=====================================================================================
|Programa: cCSV    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Instancia objeto para importação de dados via CSV                       |
|                                                                                   |
=====================================================================================
*/
Method New( cPathArq, nMaxColunas )  Class ImpCSV

Default cPathArq 		:= ''	
Default nMaxColunas	:= 999

	::cArquivo		:= cPathArq
	::nColunas		:= 0
	::nMaxColunas	:= nMaxColunas
	::aColunas		:= {}
	::aDados			:= {}
	::cErro			:= ''

Return Self


/*
=====================================================================================
|Programa: cCSV        |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: MEtodo que auxilia na seleção de um arquivo para importação             |
|                                                                                   |
=====================================================================================
*/
Method SelArquivo() Class impCSV

Local cExtens			:= 'Arquivo Texto ( *.CSV ) |*.CSV|'
Local cTitle			:= 'Selecione arquivo' 
Local cFile				:= ''
Local lSucesso			:= .F.

	cFile := Alltrim(cGetFile(cExtens,cTitle,0,"", .T. ,, .F.))

	// ----------------------------------------------------------------------------
	// Verifica existencia do arquivo
	// ----------------------------------------------------------------------------
	lSucesso := File(cFile)


	If lSucesso

		::cArquivo := cFile
	
	Else

		::cErro := "Arquivo inexistente."+CRLF+"Verifique o diretório informado e tente novamente."

	EndIf  

Return lSucesso

/*
=====================================================================================
|Programa: cCSV        |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: MEtodo que realiza a leitura do arquivo CSV e monta os arrays para      |
| devolução ao usuário.                                                             |
=====================================================================================
*/
Method Importar() Class ImpCSV

Local cLinha			:= ''
Local nLinha			:= 0
Local lREt				:= .T.

	If !Empty(::cArquivo)
		FT_FUse(::cArquivo)  

		ProcRegua( FT_FLastRec() )
		FT_FGoTop()
		

		// ----------------------------------------------------------------------------
		// Varrendo arquivo e guardando informações
		// ----------------------------------------------------------------------------
		While !FT_FEOF()

			nLinha++
			
			// Lendo linhas do CSV
			cLinha := FT_FReadLn()

			aLinha := StrToKArr2(cLinha,';',.T.)
			cLinha := ''
			
			If Len(aLinha) > ::nMaxColunas

				::cErro := "Registro do arquivo '"+::cArquivo+"' inválido."+CRLF;
								+" Favor verificar a linha '"+cValToChar(nLinha)+"' do arquivo e tentar novamente."

				Return .F.

			EndIf
			
			If nLinha == 1

				// Adicionando informações do cabeçalho
				::aColunas := aLinha
				aLinha := {}
			
			Else

				// Adicionando no array de dados
				AAdd(::aDados,aLinha)
				aLinha := {}

			EndIf

			FT_FSKIP()
		End
	Else	
		::cErro := "Arquivo não informado"
		lRet := .F.
	EndIf
	
Return lREt

/*
=====================================================================================
|Programa: cCSV    |Autor: Wanderley R. Neto                   |Data: 30/01/2019|
=====================================================================================
|Descrição: Retorna erro ao usuário                                                 |
|                                                                                   |
=====================================================================================
*/
Method InfoErro() Class ImpCSV
Return ::cErro