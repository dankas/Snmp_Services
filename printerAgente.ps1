$headersAuth =$args[0]
$id =$args[1]
$printerModeloId = $args[2]
$rotaRoot = $args[3]
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
$pathLog = 'E:\APP\Snmp_Services\Logs\Log_'+$perfilPrinter.patrimonio+'.txt'
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
    switch ($modelPrinter.fabricante){
        "RICOH" {
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
            
        }
        "EPSON"{
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
        
            
        }

        "Hewlett-Packard"{
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
Out-File -FilePath $pathLog -InputObject:$perfilErro -append
Out-File -FilePath $pathLog -InputObject:$perfilStatusContadores -append
Out-File -FilePath $pathLog -InputObject:$perfilStatusSuprimentos -append
Out-File -FilePath $pathLog -InputObject:$statusOnline -append
Out-File -FilePath $pathLog -InputObject:$tempExec -append
