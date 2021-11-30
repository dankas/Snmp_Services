<# 
------------------ CONFIGURAÇÃO DOS HEADERS E LOGIN NA API ----------------
   * PRNT_LIST baixa da api a lista das impressoras no parque
   * AUTH guarda o token 
 #>
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$credenciais = '{ "email": "danksmoraes@gmail.com", "password": "avenidaaberta"}'
$auth = Invoke-RestMethod 'http://localhost:8002/users/login' -Method 'POST' -Headers $headers -Body $credenciais
$headers.Add("Authorization", "Bearer "+$auth.token)
$prnt_list = Invoke-RestMethod -Method Get -Headers $headers -Uri "http://localhost:8002/parques/2/printers"
#Percorre a lista, todo script precisa ser executado em menos de 5 minutos.
for ($i = 0; $i -lt $prnt_list.Count; $i++) {
  #testa se a multifuncional/impressora está on-line.
  if (Test-Connection $prnt_list[$i].config.ip -q -Count 1) {
    $api_rota_perfil = "http://localhost:8002/printers/"+$prnt_list[$i].id
    $api_rota_model = "http://localhost:8002/printer-modelos/"+$prnt_list[$i].printerModeloId
    $prnt_perfil = Invoke-RestMethod -Method Get -Headers $headers -Uri $api_rota_perfil
    $prnt_model_detalhes = Invoke-RestMethod -Method Get -Headers $headers -Uri $api_rota_model
    $prnt_list[$i].patrimonio
    $prnt_list[$i].config.ip
       #$prnt_list[$i].printerModeloId
       <#Verifica no se o modelo é mono ou color e busca os OIDs no perfil do equipamento para o acesso por SNMP.
          As Opções do snmpget significam:
               -r Endereço do equipamento.
               -v Qual versão do snmp.
               -q Retorna só o valor, sem os detalhes e formatações.
               -o É o OID. 
          #> 
    switch ($prnt_model_detalhes[0].especs.impressaoCor) {
      "Color" {
        $printer_pb =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        $printer_color =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntColor
        $copier_pb =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        $copier_color =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprColor
        $total_pb = ./SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPb
        $total_color = ./SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrColor
        $contador_dados = '{ "copy color":'+ $copier_color + ',"copy mono":'+ $copier_pb  +',"print color":'+ $printer_color + ',"print mono":'+$printer_pb + ',"totalcolor":'+ $total_color +',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
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
        $printer_pb =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrPrntPb
        $copier_pb =  ./SnmpGet.exe -r:$prnt_perfil[0].config.ip  -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidCtdrCprPb
        $contador_dados = '{ "copy mono":'+ $copier_pb  +',"print mono":'+$printer_pb + ',"totalmono":'+ $total_pb +',"origem":"ScriptColeta"}'
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
     
    
    
    
  }

}




 
