<# 
------------------ CONFIGURAÇÃO DOS HEADERS E LOGIN NA API ----------------
   * PRNT_LIST baixa da api a lista das impressoras no parque
   * AUTH guarda o token 
 #>
 $loginUsr =$args[0]
 $senhaUsr =$args[1]
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

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$credenciais = '{ "email": "'+ $loginUsr +'", "'+ $senhaUsr +'": "avenidaaberta"}'
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
    $prnt_model_detalhes[0].modelo
    $prnt_list[$i].config.ip
       #$prnt_list[$i].printerModeloId
       <#Verifica no se o modelo é mono ou color e busca os OIDs no perfil do equipamento para o acesso por SNMP.
          As Opções do snmpget significam:
               -r Endereço do equipamento.
               -v Qual versão do snmp.
               -q Retorna só o valor, sem os detalhes e formatações.
               -o É o OID. 
          #> 
    switch ($prnt_model_detalhes[0].modelo) {
      "MPC 300sr" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $nivelY =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriY)
        $nivelM =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriM)
        $nivelC =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriC)
        
        
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK + ',"suprimento Y":'+ $nivelY + ',"suprimento M":'+ $nivelM +',"suprimento C":'+ $nivelC +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "MPC 400" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $nivelY =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriY)
        $nivelM =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriM)
        $nivelC =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriC)

        $suprimentos_dados = '{ "suprimento K":'+ $nivelK + ',"suprimento Y":'+ $nivelY + ',"suprimento M":'+ $nivelM +',"suprimento C":'+ $nivelC +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "SP 431N" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $nivelY =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriY)
        $nivelM =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriM)
        $nivelC =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriC)
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK + ',"suprimento Y":'+ $nivelY + ',"suprimento M":'+ $nivelM +',"suprimento C":'+ $nivelC +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "MPC 2200w" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $nivelY =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriY)
        $nivelM =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriM)
        $nivelC =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriC)

        $suprimentos_dados = '{ "suprimento K":'+ $nivelK + ',"suprimento Y":'+ $nivelY + ',"suprimento M":'+ $nivelM +',"suprimento C":'+ $nivelC +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "MP 201sp" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "SP 4510SF" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "Aficio SP5200s" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      "Aficio SP5210s" {
        $nivelK =  CodigosSuprimentosRicoh(E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$prnt_model_detalhes[0].codigosSnmp.oidSupriK)
        $suprimentos_dados = '{ "suprimento K":'+ $nivelK +',"origem":"ScriptColeta"}'
        $monitor_suprimentos = '{"dados":' + $suprimentos_dados + '}'
        $perfil_suprimentos ='{ "statusSuprimentos":'+ $suprimentos_dados+'}'
        $api_rota_suprimentos = "http://localhost:8002/printers/"+ $prnt_perfil[0].id +"/Monitoramento-suprimentos"
        $api_rota_suprimentos
        $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'POST' -Headers $headers -Body $monitor_suprimentos
        $retorno
        $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfil_suprimentos
        $retorno
      }
      Default {
        Write-Output "ERRO"
      }
    }
  }

}




 
