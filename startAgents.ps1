$loginUsr =$args[0]
$senhaUsr =$args[1]
$rotaRoot = 'http://localhost:8002'
while(1){
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$credenciais = '{ "email": "'+ $loginUsr +'", "password": "'+ $senhaUsr+'"}'
$auth = Invoke-RestMethod 'http://localhost:8002/users/login' -Method 'POST' -Headers $headers -Body $credenciais
$headers.Add("Authorization", "Bearer "+$auth.token)
$listPrinters = Invoke-RestMethod -Method Get -Headers $headers -Uri "http://localhost:8002/parques/2/printers"
#Percorre a lista, todo script precisa ser executado em menos de 5 minutos.
foreach ($i in $listPrinters) {
    $rotaModel = $rotaRoot+"/printer-modelos/"+$printerModeloId
    $modelPrinter = Invoke-RestMethod -Method Get -Headers $headersAuth -Uri $rotaModel
    switch ($modelPrinter.fabricante){
        "RICOH"{
            Start-Job -FilePath E:\APP\Snmp_Services\printersAgents\RICOH.ps1 -ArgumentList $headers,$i.id,$i.printerModeloId,$rotaRoot
            Start-Sleep -Milliseconds 100
        }
        "HP"{
            Start-Job -FilePath E:\APP\Snmp_Services\printersAgents\HP.ps1 -ArgumentList $headers,$i.id,$i.printerModeloId,$rotaRoot
            Start-Sleep -Milliseconds 100
        }
        "EPSON"{
            Start-Job -FilePath E:\APP\Snmp_Services\printersAgents\EPSON.ps1 -ArgumentList $headers,$i.id,$i.printerModeloId,$rotaRoot
            Start-Sleep -Milliseconds 100
        }
    }

}
Get-Job | Wait-Job

}
