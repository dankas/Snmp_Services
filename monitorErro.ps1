<# 
------------------ CONFIGURAÇÃO DOS HEADERS E LOGIN NA API ----------------
   * PRNT_LIST baixa da api a lista das impressoras no parque
   * AUTH guarda o token 
 #>
 $loginUsr =$args[0]
 $senhaUsr =$args[1]
while(1){
   $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
   $headers.Add("Content-Type", "application/json")
   $credenciais = '{ "email": "'+ $loginUsr +'", "password": "'+ $senhaUsr+'"}'
   $credenciais
   $auth = Invoke-RestMethod 'http://localhost:8002/users/login' -Method 'POST' -Headers $headers -Body $credenciais
   $auth
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
         $perfilErro = '{"msgErro":{'
         for ($ii = 0; $ii -lt 10; $ii++) {
               $dadosAlert = ' '
               $endereco = $prnt_model_detalhes[0].codigosSnmp.oidAlertCod+$ii
               $alertCod = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$endereco
               $endereco = $prnt_model_detalhes[0].codigosSnmp.oidAlertMsg+$ii
               $alertMsg = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$endereco
               $endereco = $prnt_model_detalhes[0].codigosSnmp.oidAlertLevel+$ii
               $alertLevel = E:\APP\Snmp_Services\SnmpGet.exe -r:$prnt_perfil[0].config.ip -v:2c -q -o:$endereco

               if ($alertCod) { 
                  if ($alertLevel -eq 3) {
                     $flag = '{"flagErro":true}'
                     $res = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $flag
                     $res 
                  }
                  $dadosAlert = '"Erro['+$ii+']":{'
                  $dadosAlert = $dadosAlert +'"codigo":'+$alertCod+',"menssagem":"'+ $alertMsg+'","severidade":'+$alertLevel+'}'
                  $perfilErro = $perfilErro + $dadosAlert+','
               }
               else {
                  $dadosAlert = ' '
            }
            
         }
         <# $dadosAlert #>
         $perfilErro = $perfilErro + '"origem":"scriptColeta"}}'
         $perfilErro 
         $retorno = Invoke-RestMethod $api_rota_perfil -Method 'PATCH' -Headers $headers -Body $perfilErro
         $retorno 
      }
   }
}