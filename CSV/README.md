<h1>Importador CSV</h1>
Facilitador de importação de CSV

Exemplo de Uso:

```
Local oCSV 			:= impCSV():New(/*cPathArq, nMaxColunas*/)
Local aCab			:= {}
Local aDados		:= {}

// Solicita o arquivo a ser processado para o usuário
oCSV:SelArquivo()

// Se arquivo tiver sido informado:
If !Empty(oCSV:cArquivo)

  // Realiza importação do arquivo
	If oCSV:Importar()

		aCab	:= oCSV:aColunas
		aDados	:= oCSV:aDados

		Processa({|| MinhaRotina(aCab, aDados)},'Minha rotina','Processando registros do CSV...',.F.)

	EndIf
EndIf
```
