function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameter -ComputerName 'Moinsen'

Read-Host -Prompt "Press Enter to exit"
