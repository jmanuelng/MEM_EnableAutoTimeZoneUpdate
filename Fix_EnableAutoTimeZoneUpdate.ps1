<#
.SYNOPSIS
    Set timezone automatically.

.DESCRIPTION
    For use as remediation script in "Remediation" in Microsoft Intune.
    Enables "Automatic Time Zone" service (tzautoupdate)
    Fix Time zone automatically configured using location services when Autopilot has been setup to hide Privacy Settings.
    Full credit to Adam Gross (tw:@AdamGrossTX) and Ben Reader (tw:@powers_hell)

.NOTES
    
    Full credit to Adam Gross (tw:@AdamGrossTX) and Ben Reader (tw:@powers_hell), I didn't change a line, maybe added one.
    Soruce: https://github.com/IntuneTraining/TimezoneTurnOn

    You'll need this script (or similar) If you've setup Autopilot to skip privacy page.
    This script should be coupled with a Configuration Policy to enable Location Services in device. 
                System > Allow Location: Force Locatin On

    Read Micheal Niehaus's blog: https://oofhours.com/2020/08/11/time-time-time-and-location-services/
    Watch the following Intune Training's YT video: https://www.youtube.com/watch?v=49c1tVdzwVQ
    The original script: https://github.com/IntuneTraining/TimezoneTurnOn

    To allow granular control by app to user create a Configuration Profile to Privacy/LetAppsAccessGazeInput_UserInControlOfTheseApps
                Privacy > Let apps access location: Force Allow
                Privacy > Let apps access location User in control of these apps: <apps list, one app per line>
    MS Docs: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-privacy#privacy-letappsaccesslocation


#>

#region Functions
# Define the function to manage services
Function Manage-Services {
    # Define the parameters for the function: the service name and the action
    Param
    (
        [string]$ServiceName,
        [ValidateSet("Start", "Stop", "Restart", "Disable", "Auto", "Manual")]
        [string]$Action
    )

    # Start a try block to catch and handle exceptions
    try {
        # Start a transcript of all commands and output to a log file
        Start-Transcript -Path "C:\Windows\Temp\$($ServiceName)_Management.Log" -Force -ErrorAction SilentlyContinue

        # Output the current date and time
        Get-Date

        # Get the service object, and suppress errors if the service is not found
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

        # Output the service object
        $service

        # If the service exists, perform the specified action
        if ($service) {
            Switch ($Action) {
                "Start" { Start-Service -Name $ServiceName; Break; } # Start the service
                "Stop" { Stop-Service -Name $ServiceName; Break; } # Stop the service
                "Restart" { Restart-Service -Name $ServiceName; Break; } # Restart the service
                "Disable" { Set-Service -Name $ServiceName -StartupType Disabled -Status Stopped; Break; } # Disable the service
                "Auto" { Set-Service -Name $ServiceName -StartupType Automatic -Status Running; Break; } # Set the service to automatic
                "Manual" { Set-Service -Name $ServiceName -StartupType Manual -Status Running; Break; } # Set the service to manual
            }

            # Get the updated service object and output it
            $exitService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        }

        # Stop the transcript
        Stop-Transcript -ErrorAction SilentlyContinue

        Return $exitService
    }
    # Catch any exceptions and re-throw them
    catch {
        throw $_
    }
}
#endregion

#region Settings
# Define the service name and the action to be performed
$ServiceName = "tzautoupdate"
$Action = "Manual"

$txtResult = "" # Status or result summary
#endregion

Write-Host = "`n`n" # Easier read in AgentExecutore log.

#region Process
# Start a try block to catch and handle exceptions
try {
    # Output a message indicating that the script is fixing the time zone service startup type
    Write-Host "Fixing TimeZone service startup type to $Action."

    # Call the function to manage services
    # NOTE: In PowerShell, any value or object that is not captured or consumed will be sent to the pipeline, which is often the output stream.
    #       In Manage-Service function, a few command outputs are not assigned to a variable or consumed by another cmdlet.
    $txtResult = Manage-Services -ServiceName $ServiceName -Action $Action | Select-Object -Last 1 # Select-Object to only get last item.
    $txtResult = "Service = $($txtResult.DisplayName) ($($txtResult.Name)), Status = $($txtResult.Status)"

    # Exit the script with a success status code (0)
    Write-Host "RESULT $([datetime]::Now) : $txtResult"
    Exit 0
}
# Catch any exceptions and output the exception message
catch {
    Write-Error $_.Exception.Message
}
#endregion
