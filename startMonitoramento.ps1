$loginUsr =$args[0]
$senhaUsr =$args[1]
$rota = 'http://localhost:8002'
while(1){
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$credenciais = '{ "email": "'+ $loginUsr +'", "password": "'+ $senhaUsr+'"}'
$auth = Invoke-RestMethod 'http://localhost:8002/users/login' -Method 'POST' -Headers $headers -Body $credenciais
$headers.Add("Authorization", "Bearer "+$auth.token)
$prnt_list = Invoke-RestMethod -Method Get -Headers $headers -Uri "http://localhost:8002/parques/2/printers"
#Percorre a lista, todo script precisa ser executado em menos de 5 minutos.
foreach ($i in $prnt_list) {
   Start-Job -FilePath E:\APP\Snmp_Services\printerAgente.ps1 -ArgumentList $headers,$i.id,$i.printerModeloId,$rota
   Start-Sleep -Milliseconds 100
}
Get-Job | Wait-Job

}
