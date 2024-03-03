<#
.SYNOPSIS
Este script apresenta soluções para coletar evidencias e monitorar um sistema que possui RDP.

.DESCRIPTION
Além de trazer soluções para coletar evidencias e monitorar um sistema que possui RDP, este script também traz ferramentas adicionais para filtrar logs e exportar os resultados da pesquisa.

.AUTHOR
Vinícius Rodrigues - 24872
#>


# Solicitar localização para salvar os logs e relatórios
param(
    [string]$LogFolder = $(Read-Host "Por favor, insira o caminho para salvar os logs e relatorios")
)


# Garantindo que as aspas não são necessárias na entrada do usuário
$LogFileName = "$LogFolder\24872-TILPS-EN.log"
$ReportFileName = "$LogFolder\24872-TILPS-EN.html"


# Verificar se o script está sendo executado como administrador
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Este script deve ser executado como Administrador." -ForegroundColor Red
    Exit
}


# Inicializa o log
$startTime = Get-Date
"Script iniciado em: $startTime" | Out-File -FilePath $LogFileName -Append
"<p>Script iniciado em: $startTime</p>" | Out-File -FilePath $ReportFileName -Append


# Funções de informação do sistema
function Informacoes-Sistema {
    $infosistema = "1- Informacoes do Sistema"
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append


    $computerSystem = Get-CimInstance -ClassName CIM_ComputerSystem
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $processor = Get-CimInstance -ClassName Win32_Processor
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $architecture = If ([System.Environment]::Is64BitOperatingSystem) { '64-bit' } Else { '32-bit' }

    $systemInfo = @"
Device Name: $($computerSystem.Name)
Device Model: $($computerSystem.Model)
Domain Name: $($computerSystem.Domain)
Processor Name: $($processor.Name)
Number Of Processors: $($computerSystem.NumberOfProcessors)
Number Of Cores: $($processor.NumberOfCores)
Number Of Logical Processors: $($processor.NumberOfLogicalProcessors)
Processor Manufacturer: $($processor.Manufacturer)
Total Physical Memory: $([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB
Architecture: $architecture
Computer Model: $($computerSystem.Model)
Serial Number: $($bios.SerialNumber)
Computer Manufacturer: $($computerSystem.Manufacturer)
System Install Date: $($os.InstallDate)
OS Name: $($operatingSystem.Caption)
OS Version: $($operatingSystem.Version)
"@

    Write-Host $systemInfo -ForegroundColor Green
    $systemInfo | Out-File -FilePath $LogFileName -Append
    $systemInfo -replace "`n", "<br>" | Out-File -FilePath $ReportFileName -Append
}


function GetSuccessfulRDPConnections {
    Clear-host

    $infosistema = "2- Lista Número de Acessos Locais e Remotos por RDP`n"
    Write-host = $infosistema
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append

    # Buscar eventos de logon bem-sucedidos por RDP no log de segurança
    $RDPConnections = Get-EventLog security -after (Get-date -hour 0 -minute 0 -second 0) | Where-Object { $_.eventid -eq 4624 -and $_.Message -match 'logon type:\s+(10)\s' }

    if ($RDPConnections) {
        # Salvar informações em arquivo de log
        $RDPConnections | Out-File -FilePath $LogFileName -Append

        # Formatar informações para relatório HTML
        $HTMLHeader = @"
<!DOCTYPE html>
<html>
<head>
<title>Relatório de Conexões RDP Bem-Sucedidas</title>
</head>
<body>
<h1>Relatório de Conexões RDP Bem-Sucedidas</h1>
<table border="1">
<tr>
<th>TimeGenerated</th>
<th>Message</th>
</tr>
"@

        $HTMLFooter = @"
</table>
</body>
</html>
"@

        $RDPConnectionsHTML = $RDPConnections | Select-Object TimeGenerated, Message | ConvertTo-Html -Fragment

        # Salvar informações em arquivo de relatório HTML
        $HTMLHeader | Out-File -FilePath $ReportFileName -Append
        $RDPConnectionsHTML | Out-File -FilePath $ReportFileName -Append
        $HTMLFooter | Out-File -FilePath $ReportFileName -Append

        # Exibir informações na tela
        $RDPConnections
    }
    else {
        Write-Host "Nenhum acesso remoto por RDP bem-sucedido encontrado.`n"
    }
}


function GetRDPConnectionCount {
    Clear-host

    $infosistema = "3- Lista Número de Acessos Locais e Remotos por RDP + Filtragem`n"
    Write-host $infosistema
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append

    # Filtrar eventos de logon bem-sucedidos (Evento ID 4624) nos logs de segurança
    $RDPLogonEvents = Get-WinEvent -LogName Security | Where-Object { $_.Id -eq 4624 }

    # Contadores para acessos locais e remotos por RDP
    $LocalRDPCount = 0
    $RemoteRDPCount = 0

    # Iterar sobre os eventos de logon bem-sucedidos para contar acessos por RDP
    foreach ($event in $RDPLogonEvents) {
        # Verificar se o logon foi realizado por RDP
        if ($event.Properties[8].Value -like "*rdp*") {
            # Verificar se o logon foi local ou remoto
            if ($event.Properties[10].Value -like "*local*") {
                $LocalRDPCount++
            } else {
                $RemoteRDPCount++
            }
        }
    }


    function MonitorRDP {
        # Definir a condição de saída do loop
        $exit = $false
    
        # Loop infinito
        while (-not $exit) {
            # Verificar eventos de logon remoto
            $RDPLogonEvents = Get-WinEvent -LogName Security | Where-Object { $_.Id -eq 4624 -and $_.Message -match 'logon type:\s+(10)\s' }
    
            # Se houver eventos de logon remoto, alertar o usuário
            if ($RDPLogonEvents) {
                $message = "Novo logon remoto detectado!"
                Write-Host $message
            }
    
            # Aguardar 1 minuto antes de verificar novamente
            Start-Sleep -Seconds 60
        }
    }
    
    # Exibir resultados
    Write-Host "Número de Acessos Locais por RDP: $LocalRDPCount"
    Write-Host "Número de Acessos Remotos por RDP: $RemoteRDPCount"

    # Salvar informações em arquivo de log
    "Número de Acessos Locais por RDP: $LocalRDPCount" | Out-File -FilePath $LogFileName -Append
    "Número de Acessos Remotos por RDP: $RemoteRDPCount" | Out-File -FilePath $LogFileName -Append

    # Formatar informações para relatório HTML
    $HTMLHeader = @"
<!DOCTYPE html>
<html>
<head>
<title>Relatório de Conexões RDP</title>
</head>
<body>
<h1>Relatório de Conexões RDP</h1>
<p>Número de Acessos Locais por RDP: $LocalRDPCount</p>
<p>Número de Acessos Remotos por RDP: $RemoteRDPCount</p>
</body>
</html>
"@

    # Salvar informações em arquivo de relatório HTML
    $HTMLHeader | Out-File -FilePath $ReportFileName -Append
}


function ExportPowerShellHistoryToBase64 {
    Clear-Host

    $infosistema = "7- Salvar Histórico de Comandos em Base64`n"
    Write-host $infosistema
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append

    $HistoryFileName = "history.log"  # Nome do arquivo de histórico

    # Obter o histórico de comandos do PowerShell
    $PowerShellHistory = Get-History | Select-Object -ExpandProperty CommandLine

    # Verificar se o histórico de comandos não está vazio
    if ($PowerShellHistory -ne $null) {
        # Converter o histórico de comandos para Base64
        $Base64EncodedHistory = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PowerShellHistory))

        # Caminho completo para o arquivo de histórico
        $HistoryFilePath = Join-Path -Path $LogFolder -ChildPath $HistoryFileName

        # Salvar a história codificada em Base64 no arquivo
        $Base64EncodedHistory | Out-File -FilePath $HistoryFilePath -Encoding utf8 -Append

        Write-Host "`nFunção finalizada, verifique se o arquivo codificado em Base64 foi criado" -ForegroundColor Cyan
    } else {
        Write-Host "O histórico de comandos do PowerShell está vazio. Nenhum arquivo de histórico foi criado." -ForegroundColor Yellow
    }
    Read-Host
}


function Get-LogFileHash {
    param(
        [string]$LogFilePath
    )
    # Calcular e exibir o hash do arquivo .log
    $logFileHash = Get-FileHash -Path $LogFilePath -Algorithm SHA256
    Write-Host "Hash do arquivo log ($LogFilePath):" -ForegroundColor Cyan
    Write-Host $logFileHash.Hash -ForegroundColor Green
}


function Get-AccessTimeInterval {
    Clear-host

    $infosistema = "4- Calcula o Intervalo Temporal entre o Primeiro e o Ultimo Acesso de Cada Endereço`n"
    Write-host $infosistema
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append

    # Comando para obter o intervalo de tempo de acesso
    $AccessTimeIntervalAB = Get-EventLog -LogName Security | where {$_.EventId -eq 4624 -or $_.EventID -eq 4648 -or $_.EventID -eq 4672 -or $_.EventID -eq 4634 -or $_.EventID -eq 4647 } | Where {$_.Message -match "Tipo de Início de Sessão:\s+10"}

    # Salvar informações em arquivo de log
    $AccessTimeIntervalAB | Out-File -FilePath $LogFileName -Append
}


function Collect-SecurityLoginsBetweenDates {
    Clear-host

    $infosistema = "5- Função que Permite Filtrar a Pesquisa por Intervalo de Tempo`n"
    Write-host $infosistema
    $infosistema | Out-File -FilePath $LogFileName -Append
    "<p>$infosistema</p>" | Out-File -FilePath $ReportFileName -Append

    Write-Host "----------Introduza a 1ª data (dd/mm/aaaa)----------"
    $data1 = Read-Host
    $data1 = Get-Date $data1

    Write-Host "----------Introduza a 2ª data (dd/mm/aaaa)----------"
    $data2 = Read-Host
    $data2 = Get-Date $data2

    $logins = Get-EventLog -LogName Security | Where-Object { $_.TimeGenerated -ge $data1 -and $_.TimeGenerated -le $data2 -and ($_.EventId -eq 4624 -or $_.EventID -eq 4648 -or $_.EventID -eq 4672 -or $_.EventID -eq 4634 -or $_.EventID -eq 4647) }

    # Salvar informações em arquivo de log
    $logins | Out-File -FilePath $LogFileName -Append

    # Formatar informações para relatório HTML
    $HTMLHeader = @"
<!DOCTYPE html>
<html>
<head>
<title>Relatório de Logins de Segurança</title>
</head>
<body>
<h1>Relatório de Logins de Segurança</h1>
<table border="1">
<tr>
<th>TimeGenerated</th>
<th>EventID</th>
<th>Message</th>
</tr>
"@

    $loginsHTML = $logins | Select-Object TimeGenerated, EventID, Message | ConvertTo-Html -Fragment

    # Salvar informações em arquivo de relatório HTML
    $HTMLHeader | Out-File -FilePath $ReportFileName -Append
    $loginsHTML | Out-File -FilePath $ReportFileName -Append

}


function Get-LogFileHash2 {
    param(
        [string]$LogFilePath2
    )
    # Calcular e exibir o hash do arquivo .html
    $logFileHash = Get-FileHash -Path $LogFilePath2 -Algorithm SHA256
    Write-Host "Hash do arquivo log ($LogFilePath2):" -ForegroundColor Cyan
    Write-Host $logFileHash.Hash -ForegroundColor Green
}


function Show-ExitMessage {
    Clear-Host
    $endTime = Get-Date
    $duration = $endTime - $startTime
    $formattedDuration = "{0:D2}:{1:D2}:{2:D2}" -f $duration.Hours, $duration.Minutes, $duration.Seconds

    "Script finalizado em: $endTime" | Out-File -FilePath $LogFileName -Append
    "<p>Script finalizado em: $endTime</p>" | Out-File -FilePath $ReportFileName -Append

    Write-Host "Tempo de execucao do Script: $formattedDuration" -ForegroundColor Green

    Get-LogFileHash -LogFilePath $LogFileName
    Get-LogFileHash2 -LogFilePath2 $ReportFileName

    $totalDuration = "Tempo de execucao: $formattedDuration`n`n"
    $totalDuration | Out-File -FilePath $LogFileName -Append
    "<p>$totalDuration</p>" | Out-File -FilePath $ReportFileName -Append

    Write-Host "`n`n`nFim do Programa." -ForegroundColor Cyan
    Read-Host
}


# Menu de opções
function Menu-Principal {
    do {
        Write-Host "`nPressione Enter para continuar..." -ForegroundColor Cyan
        Read-Host

        Clear-Host

        Write-Host "########## PowerShell-InfoGathering ##########" -ForegroundColor Cyan
        $adicionamenu = "########## MENU ##########"
        $adicionamenu | Out-File -FilePath $LogFileName -Append
        "<p>$adicionamenu</p>" | Out-File -FilePath $ReportFileName -Append

        Write-Host "1- Informacoes do Sistema (Módulo Adicional)"
        Write-Host "2- Lista Número de Acessos Locais e Remotos por RDP"
        Write-Host "3- Lista Número de Acessos Locais e Remotos por RDP + Filtragem"
        Write-Host "4- Calcula o Intervalo Temporal entre o Primeiro e o Ultimo Acesso de Cada Endereço"
        Write-Host "5- Função que Permite Filtrar a Pesquisa por Intervalo de Tempo"
        Write-Host "6- Monitorizar o Sistema em Background (Logon Remoto)"
        Write-Host "7- Salvar Histórico de Comandos em Base64"
        Write-Host "`n0- Sair`n`n"
        $option = Read-Host "Selecione uma opcao"
        
        switch ($option) {
            '1' { Informacoes-Sistema }
            '2' { GetSuccessfulRDPConnections }
            '3' { GetRDPConnectionCount }
            '4' { Get-AccessTimeInterval }
            '5' { Collect-SecurityLoginsBetweenDates }
            '6' { MonitorRDP }
            '7' { ExportPowerShellHistoryToBase64 }
            '0' {
                Show-ExitMessage
                Exit
            }
            default { Write-Host "Opcao Invalida!" -ForegroundColor Red }
        }
    } while ($option -ne '0')
}

Menu-Principal
