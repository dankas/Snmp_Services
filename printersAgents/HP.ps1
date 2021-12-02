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
    $pathLog = 'E:\APP\Snmp_Services\Logs\Log_HP'+$perfilPrinter.patrimonio+'.txt'
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
            "HP DesignJet T930 Printer" {
                $printerWeb = 'http://'+ $perfilPrinter.config.ip +'/hp/device/webAccess/index.htm?content=usage'
                $printerWakeup = 'http://'+ $perfilPrinter.config.ip+'/wakeup.htm/config'
                $crawlerPrinter = Invoke-WebRequest -Uri $printerWakeup -Method POST -Body 'WakeUp=Ativar'
                Start-Sleep -Seconds 8
                $crawlerPrinter = Invoke-WebRequest -Uri $printerWeb
                $tableData = $crawlerPrinter.AllElements | Where-Object {$_.tagname -eq 'td'}
                $lifeMeters = $tableData[12].innerText
                $lifeFoots = $tableData[14].innerText
                $lifeMeters = $lifeMeters.Split()
                $lifeFoots = $lifeFoots.Split()
                $nivelK =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriK
                $nivelKp =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriKp
                $nivelG =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriG
                $nivelY =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriY
                $nivelM =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriM
                $nivelC =  E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidSupriC  
                $capK = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapK
                $capKp = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapKp
                $capG = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapG
                $capY = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapY
                $capM = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapM
                $capC = E:\APP\Snmp_Services\SnmpGet.exe -r:$perfilPrinter.config.ip  -v:2c -q -o:$modelPrinter.codigosSnmp.oidCapC
                [int]$nivelK = ($nivelK / $capK)*100
                [int]$nivelKp = ($nivelKp / $capKp)*100
                [int]$nivelG = ($nivelG / $capG)*100
                [int]$nivelY = ($nivelY / $capY)*100
                [int]$nivelM = ($nivelM / $capM)*100
                [int]$nivelC = ($nivelC / $capC)*100
                $dadosCounters = '{"life(m)":"'+ $lifeMeters[0] +'","life(ft)":"' + $lifeFoots[0] + '","origem":"printerAgente"}'                      
                $dadosSupply = '{ "suprimentoK":'+ $nivelK + ',"suprimentoY":'+ $nivelY + ',"suprimentoM":'+ $nivelM +',"suprimentoC":'+ $nivelC +',"suprimentoKphoto":'+ $nivelKp +',"suprimentoG":'+ $nivelG +',"origem":"printerAgente"}'
              
            }
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
