<#
.SYNOPSIS
    This script checks if the 'tzautoupdate' service is set to Manual.

.DESCRIPTION
    For use as a detection script in "Remediations" within Microsoft Intune. It checks whether the Windows Time Zone Auto Update service (tzautoupdate) is configured to start manually.
    This is part of a Proactive Remediation setup to automatically adjust the system's time zone. Full credit to Adam Gross (Twitter: @AdamGrossTX) and Ben Reader (Twitter: @powers_hell).

.NOTES
    If you've set up Windows Autopilot to skip the privacy page, this script can be useful. You should couple this script with a Configuration Policy to force Location Services on the device 
            (System > Allow Location: Force Location On).
    
    For more information, refer to Michael Niehaus's blog post: https://oofhours.com/2020/08/11/time-time-time-and-location-services/
    and the Intune Training's YouTube video: https://www.youtube.com/watch?v=49c1tVdzwVQ
    Original script: https://github.com/IntuneTraining/TimezoneTurnOn

    To allow granular app control by the user, create a Configuration Profile for Privacy/LetAppsAccessGazeInput_UserInControlOfTheseApps.
        Privacy > Let apps access location: Force Allow
        Privacy > Let apps access location User in control of these apps: <List of apps, one per line>
    Microsoft Docs: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-privacy#privacy-letappsaccesslocation
#>

# Store the name of the service and the desired start-up setting in variables.
$ServiceName = 'tzautoupdate'
$Action = 'Manual'
$txtResult = "" # Stores script execution status

# Try to get the service object, and suppress errors if the service is not found.
$Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

# Define a variable to store the script exit code.
$exitCode = $null

# Check if the service exists
if ($null -eq $Service) {
    $txtResult = "Service $ServiceName does not exist."
    $exitCode = -2
}
# If the service exists, compare its StartType with the desired action.
elseif ($service.StartType -eq $Action) {
    $txtResult = "$ServiceName already configured correctly."
    $exitCode = 0
}
else {
    $txtResult = "$ServiceName NOT configured correctly."
    $exitCode = 1
}

Write-Host "`n`n" # just to make it easier to read in AgentExecutor log.

# Return result. Last line of script is automatically uploaded to Intune, 
# can be seen in the "Output" columns of Remediation Device Status.
#
# Based on the exitCode, return the appropriate message and exit the script.
if ($exitCode -eq 0) {
    Write-Host "OK $([datetime]::Now) : $txtResult"
    Exit 0
}
elseif ($exitCode -eq 1) {
    Write-Host "FAIL $([datetime]::Now) : $txtResult"
    Exit 1
}
else {
    Write-Host "WARNING $([datetime]::Now) : $txtResult"
    Exit 0
}

