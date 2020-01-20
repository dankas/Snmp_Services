<# 
------------------ CONFIGURAÇÃO DOS HEADERS E LOGIN NA API ----------------
   * PRNT_LIST baixa da api a lista das impressoras no parque
   * AUTH guarda o token 
 #>
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
$credenciais = "user=cpcadmin&pwd=meme%21vermelhojusto"
$auth = Invoke-RestMethod 'http://localhost:8001/login' -Method 'POST' -Headers $headers -Body $credenciais
$prnt_list = Invoke-RestMethod -Method Get -Uri "http://localhost:8001/parque_impressoras/cliente/ifsul%20campus%20pelotas"
$headers.Add("x-access-token", $auth.token)
#Percorre a lista, todo script precisa ser executado em menos de 5 minutos.
 for ($i = 0; $i -lt $prnt_list.data.Count; $i++) {
    #testa se a multifuncional/impressora está on-line.
    if (Test-Connection $prnt_list.data[$i].IP -q -Count 1) {
         $api_rota_perfil = "http://localhost:8001/perfil_impressora/"+$prnt_list.data[$i].Patrimonio_CPC+"/completo"
         $prnt_perfil = Invoke-RestMethod -Method Get -Uri $api_rota_perfil
         $prnt_list.data[$i].Patrimonio_CPC
         $prnt_list.data[$i].IP
         <#Verifica no se o modelo é mono ou color e busca os OIDs no perfil do equipamento para o acesso por SNMP.
          As Opções do snmpget significam:
               -r Endereço do equipamento.
               -v Qual versão do snmp.
               -q Retorna só o valor, sem os detalhes e formatações.
               -o É o OID. 
          #> 
         switch ($prnt_perfil.data[0].Impressao_Cor) {
            "Color" {
                $suprim_K =  ./SnmpGet.exe -r:$prnt_list.data[$i].IP -v:2c -q -o:$prnt_perfil.data[0].Oid_supri_k
                $suprim_m =  ./SnmpGet.exe -r:$prnt_list.data[$i].IP -v:2c -q -o:$prnt_perfil.data[0].Oid_supri_m
                $suprim_c =  ./SnmpGet.exe -r:$prnt_list.data[$i].IP -v:2c -q -o:$prnt_perfil.data[0].Oid_supri_c
                $suprim_y =  ./SnmpGet.exe -r:$prnt_list.data[$i].IP -v:2c -q -o:$prnt_perfil.data[0].Oid_supri_y
                $suprimentos_dados = "black="+$suprim_K+"&cian="+$suprim_c+"&magenta="+$suprim_m+"&yellow="+$suprim_y
                $api_rota_suprimentos = "http://localhost:8001/perfil_impressora/"+$prnt_list.data[$i].Patrimonio_CPC+"/suprimentos"
                $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'PUT' -Headers $headers -Body $suprimentos_dados
                $suprimentos_dados 
                $retorno | ConvertTo-Json
                }
             Default {
               $suprim_K =  ./SnmpGet.exe -r:$prnt_list.data[$i].IP -v:2c -q -o:$prnt_perfil.data[0].Oid_supri_k
               $suprim_m =  0
               $suprim_c =  0
               $suprim_y =  0
               $suprimentos_dados = "black="+$suprim_K+"&cian="+$suprim_c+"&magenta="+$suprim_m+"&yellow="+$suprim_y
               $api_rota_suprimentos = "http://localhost:8001/perfil_impressora/"+$prnt_list.data[$i].Patrimonio_CPC+"/suprimentos"
               $retorno = Invoke-RestMethod $api_rota_suprimentos -Method 'PUT' -Headers $headers -Body $suprimentos_dados
               $suprimentos_dados
               $retorno | ConvertTo-Json
                }
         }
   }
 
 }
 
