
  $loginUsr =$args[0]
  $senhaUsr =$args[1]

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$credenciais = '{ "email": "'+ $loginUsr +'", "password": "'+ $senhaUsr+'"}'
$auth = Invoke-RestMethod 'http://localhost:8002/users/login' -Method 'POST' -Headers $headers -Body $credenciais
$headers.Add("Authorization", "Bearer "+$auth.token)
$prnt_list = Invoke-RestMethod -Method Get -Headers $headers -Uri "http://localhost:8002/parques/2/printers"
#Percorre a lista, todo script precisa ser executado em menos de 5 minutos.
for ($i = 0; $i -lt $prnt_list.Count; $i++) {
    $api_rota_perfil = "http://localhost:8002/printers/"+$prnt_list[$i].id
    $api_rota_model = "http://localhost:8002/printer-modelos/"+$prnt_list[$i].printerModeloId
  #testa se a multifuncional/impressora está on-line.
  if (Test-Connection $prnt_list[$i].config.ip -q -Count 1) {
    $prnt_perfil = Invoke-RestMethod -Method Get -Headers $headers -Uri $api_rota_perfil
    $prnt_model_detalhes = Invoke-RestMethod -Method Get -Headers $headers -Uri $api_rota_model
    $prnt_list[$i].patrimonio
    $prnt_list[$i].config.ip
    
    switch ($prnt_model_detalhes[0].especs.impressaoCor) {
      "Color" {
        $printer_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        $printer_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntColor
        $copier_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        $copier_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprColor
        $total_pb = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrColor
        $contador_dados = '{ "copyColor":'+ $copier_color + ',"copyMono":'+ $copier_pb  +',"printColor":'+ $printer_color + ',"printMono":'+$printer_pb + ',"totalColor":'+ $total_color +',"totalMono":'+ $total_pb +',"origem":"ScriptColeta"}'
        $monitor_counter = '{"dados":' + $contador_dados + '}'
        $perfil_contadores ='{ "statusContadores":'+ $contador_dados+'}'
        $api_rota_contadores = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/monitoramento-counters"
        $api_rota_contadores
        $retorno = Invoke-RestMethod $api_rota_contadores -Method 'POST' -Headers $headers -Body $monitor_counter
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_contadores
        $retorno


      }
      "Mono" {
        $printer_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        $copier_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
<<<<<<< HEAD:Scripts Antigos/coletaCounter.ps1
        $contador_dados = '{ "copyMono":'+ $copier_pb  +',"printMono":'+$printer_pb + ',"totalMono":'+ $total_pb +',"origem":"ScriptColeta"}'
=======
        $total_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = 0
        $contador_dados = '{ "copy mono":'+ $copier_pb  +',"print mono":'+$printer_pb + ',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
>>>>>>> ecc40e239bd825f5ea6ad0522c774422b874b6bc:coletaCounter.ps1
        $monitor_counter = '{"dados":' + $contador_dados + '}'
        $perfil_contadores ='{ "statusContadores":'+ $contador_dados+'}'
        $api_rota_contadores = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/monitoramento-counters"
        $retorno = Invoke-RestMethod $api_rota_contadores -Method 'POST' -Headers $headers -Body $monitor_counter
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_contadores
        $retorno


      }
              
      
      Default {
        Write-Output "ERRO"
      }
    }
    switch ($prnt_model_detalhes[0].modelo) {
      "WF C869r" {
        #$printer_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        #$printer_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntColor
        #$copier_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        #$copier_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprColor
        $total_pb = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrColor
<<<<<<< HEAD:Scripts Antigos/coletaCounter.ps1
        $contador_dados = '{"totalColor":'+ $total_color +',"totalMono":'+ $total_pb +',"origem":"ScriptColeta"}'
=======
        $contador_dados = '{ "copy color":'+ 0 + ',"copy mono":'+ 0 +',"print color":'+ 0 + ',"print mono":'+ 0 + ',"totalcolor":'+ $total_color +',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
>>>>>>> ecc40e239bd825f5ea6ad0522c774422b874b6bc:coletaCounter.ps1
        $monitor_counter = '{"dados":' + $contador_dados + '}'
        $contador_dados
        $monitor_counter
        $perfil_contadores ='{ "statusContadores":'+ $contador_dados+'}'
        $api_rota_contadores = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/monitoramento-counters"
        $api_rota_contadores
        $retorno = Invoke-RestMethod $api_rota_contadores -Method 'POST' -Headers $headers -Body $monitor_counter
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_contadores
        $retorno
      }
      "WF C20590" {
        #$printer_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        #$printer_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntColor
        #$copier_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        #$copier_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprColor
        $total_pb = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrColor
<<<<<<< HEAD:Scripts Antigos/coletaCounter.ps1
        $contador_dados = '{"totalColor":'+ $total_color +',"totalMono":'+ $total_pb +',"origem":"ScriptColeta"}'
=======
        $contador_dados = '{ "copy color":'+ 0 + ',"copy mono":'+ 0 +',"print color":'+ 0 + ',"print mono":'+ 0 + ',"totalcolor":'+ $total_color +',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
>>>>>>> ecc40e239bd825f5ea6ad0522c774422b874b6bc:coletaCounter.ps1
        $monitor_counter = '{"dados":' + $contador_dados + '}'
        $contador_dados
        $monitor_counter
        $perfil_contadores ='{ "statusContadores":'+ $contador_dados+'}'
        $api_rota_contadores = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/monitoramento-counters"
        $api_rota_contadores
        $retorno = Invoke-RestMethod $api_rota_contadores -Method 'POST' -Headers $headers -Body $monitor_counter
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_contadores
        $retorno
      }  
      "WF SC T5400" {
        #$printer_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        #$printer_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntColor
        #$copier_pb =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        #$copier_color =  E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprColor
        <# $total_pb = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrColor
        $contador_dados = '{"totalcolor":'+ $total_color +',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
        $monitor_counter = '{"dados":' + $contador_dados + '}'
        $perfil_contadores ='{ "statusContadores":'+ $contador_dados+'}'
        $api_rota_contadores = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/monitoramento-counters"
        $api_rota_contadores
        $retorno = Invoke-RestMethod $api_rota_contadores -Method 'POST' -Headers $headers -Body $monitor_counter
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_contadores
        $retorno #>
      } 
    }
  }

}




 
