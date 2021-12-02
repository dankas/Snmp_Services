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
    $pathLog = 'E:\APP\Snmp_Services\Logs\Log_EPSON'+$perfilPrinter.patrimonio+'.txt'
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
        switch ($modelPrinter.modelo) {
            "WF C20590" {
                [int]$totalPb = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPb
                [int]$totalColor = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrColor
                $nivelK1 =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK1
                $nivelK2 =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK2
                $nivelY =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriY
                $nivelM =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriM
                $nivelC =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriC  
                $total = $totalPb + $totalColor
                $dadosSupply = '{"suprimentoK":'+ $nivelK1 + ',"suprimentoK2":'+ $nivelK2 + ',"suprimentoY":'+ $nivelY + ',"suprimentoM":'+ $nivelM +',"suprimentoC":'+ $nivelC +',"origem":"printerAgente"}'
                $dadosCounters = '{"totalColor":'+ $totalColor +',"totalMono":'+ $totalPb +',"life":'+ $total +',"origem":"printerAgente"}'                      

              }
            "WF C869r" {
                [int]$totalPb = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrPb
                [int]$totalColor = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCtdrColor
                $nivelK =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK
                $nivelY =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriY
                $nivelM =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriM
                $nivelC =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriC    
                $total = $totalPb + $totalColor
                $dadosCounters = '{"totalColor":'+ $totalColor +',"totalMono":'+ $totalPb +',"life":'+ $total +',"origem":"printerAgente"}'                      
                $dadosSupply = '{ "suprimentoK":'+ $nivelK + ',"suprimentoY":'+ $nivelY + ',"suprimentoM":'+ $nivelM +',"suprimentoC":'+ $nivelC +',"origem":"printerAgente"}'

            }
            "WF SC T5400" {
                $nivelK =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK
                $nivelY =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriY
                $nivelM =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriM
                $nivelC =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriC  
                $total = 0
                $dadosCounters = '{"life(m)":'+ $total +',"origem":"printerAgente"}'                      
                $dadosSupply = '{ "suprimentoK":'+ $nivelK + ',"suprimentoY":'+ $nivelY + ',"suprimentoM":'+ $nivelM +',"suprimentoC":'+ $nivelC +',"origem":"printerAgente"}'

            }

            Default {}
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
