$headersAuth =$args[0]
$id =$args[1]
$printerModeloId = $args[2]
$rotaRoot = $args[3]
$contadorLoop = 0
while($contadorLoop -lt 3600){
    $startDate = Get-Date 
    $delay = Get-Random -Maximum 500
    Start-Sleep -Milliseconds $delay
    $statusOnline = ' '
    $perfilErro = '{"msgErro":{'
    function CodigosSuprimentosRicoh ($valorNivel) {
        switch($valorNivel) {
            "-100" {
                $valorNivel = 10
            }
            "-3"{
                $valorNivel = 100
            }
            "-2" {
                $valorNivel = '"Toner Desconhecido"'
            }
            "0" {
                $valorNivel = '"Toner Esgotado"'
            }  
        }
        return $valorNivel 
    }
    $retorno
    $rotaPerfil = $rotaRoot+"/printers/"+$id
    $rotaModel = $rotaRoot+"/printer-modelos/"+$printerModeloId
    $perfilPrinter = Invoke-RestMethod -Method Get -Headers $headersAuth -Uri $rotaPerfil
    $modelPrinter = Invoke-RestMethod -Method Get -Headers $headersAuth -Uri $rotaModel
    $pathLog = 'E:\APP\Snmp_Services\Logs\Log_RICOH'+$perfilPrinter.patrimonio+'.txt'
    $printPb = 0
    $printColor =  0
    $copierPb =  0
    $copierColor = 0
    $totalPb = 0
    $totalColor = 0
    $nivelK = 0
    $nivelY =  0
    $nivelM =  0
    $nivelC =  0
    if (Test-Connection $perfilPrinter.config.ip -q -Count 1) {
        $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
        $statusOnline = '{"statusOnline":{ "ultimaChecagem":"'+$timestamp+'"},"flagOnline":true}'
        if($modelPrinter.especs.impressaoCor -eq "Color"){
            [int]$printPb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPrntPb
            [int]$printColor =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPrntColor
            [int]$copierPb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrCprPb
            [int]$copierColor =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrCprColor
            [int]$totalPb = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPb
            [int]$totalColor = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrColor
            $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK)
            $nivelY =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriY)
            $nivelM =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriM)
            $nivelC =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriC)    
            $total = $totalPb + $totalColor
            $dadosCounters = '{ "copyColor":'+ $copierColor + ',"copyMono":'+ $copierPb  +',"printColor":'+ $printColor + ',"printMono":'+$printPb + ',"totalColor":'+ $totalColor +',"totalMono":'+ $totalPb +',"life":'+ $total +',"origem":"printerAgente"}'
            $dadosSupply = '{ "suprimentoK":'+ $nivelK + ',"suprimentoY":'+ $nivelY + ',"suprimentoM":'+ $nivelM +',"suprimentoC":'+ $nivelC +',"origem":"printerAgente"}'

        }
        else{
            [int]$copierPb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrCprPb
            [int]$printPb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPrntPb
            [int]$totalPb = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPb
            $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK)
            $total = $totalPb + $totalColor
            $dadosCounters = '{ "copyMono":'+ $copierPb  +',"printMono":'+$printPb + ',"totalMono":'+ $totalPb +',"life":'+ $total +',"origem":"printerAgente"}'
            $dadosSupply = '{ "suprimentoK":'+ $nivelK + ',"origem":"printerAgente"}'

        }
        
        for ($ii = 0; $ii -lt 10; $ii++) {
            $dadosAlert = ' '
            $endereco = $modelPrinter.codigosSnmp.oidAlertCod+$ii
            $alertCod = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip -v:2c -q -o:$endereco
            $endereco = $modelPrinter.codigosSnmp.oidAlertMsg+$ii
            $alertMsg = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip-v:2c -q -o:$endereco
            $endereco = $modelPrinter.codigosSnmp.oidAlertLevel+$ii
            $alertLevel = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip -v:2c -q -o:$endereco
            if ($alertCod) { 
                if ($alertLevel -eq 3) {
                $flagErro = 1
                }
                elseif (($alertLevel -ne 3) -and ($flagErro -eq 1)) {
                $flagErro = 1
                }
                else {
                $flagErro = 0

                }
                $dadosAlert = '"Erro['+$ii+']":{'
                $dadosAlert = $dadosAlert +'"codigo":'+$alertCod+',"menssagem":"'+ $alertMsg+'","severidade":'+$alertLevel+'}'
                $perfilErro = $perfilErro + $dadosAlert+','
            }
            else {
                $dadosAlert = ' '
            }
        }
    
        if($flagErro){
             $flag = '{"flagErro":true}'
        }
        else {
            $flag = '{"flagErro":false}'
        }
        $perfilErro = $perfilErro + '"origem":"printerAgente"}}'
        $perfilStatusContadores ='{ "statusContadores":'+ $dadosCounters+'}'
        $perfilStatusSuprimentos='{ "statusSuprimentos":'+ $dadosSupply+'}'
        $pathLog = 'E:\APP\Snmp_Services\Logs\Log_'+$perfilPrinter.patrimonio+'.txt'
        $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $perfilErro
        $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $perfilStatusContadores
        $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $perfilStatusSuprimentos
        $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $statusOnline
        $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $flag
    }    
    else{
    $perfilErro = $perfilErro + '"origem":"printerAgente"}}'
    $statusOnline = '{"flagOnline":false}'
    $retorno = Invoke-RestMethod $rotaPerfil -Method 'PATCH' -Headers $headersAuth -Body $statusOnline
    }
    $endDate = Get-Date
    $tempo = $endDate - $startDate
    $tempExec = '{"inicio":'+$startDate+',"fim":'+$endDate+',"tempo":'+$tempo+'}'
    Out-File -FilePath $pathLog -InputObject:$flag -append
    Out-File -FilePath $pathLog -InputObject:$statusOnline -append
    Out-File -FilePath $pathLog -InputObject:$tempExec -append
    Start-Sleep -Seconds 1
    $contadorLoop++
}
