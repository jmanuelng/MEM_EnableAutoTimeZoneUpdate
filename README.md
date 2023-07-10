# MEM_EnableAutoTimeZoneUpdate

## Overview

Scripts to manage **"Auto Time Zone Updater"** 'tzautoupdate' service on a Windows device. Intended to be used as part of a "Proactive Remediations", now just "Remediations", in Microsoft Intune to automatically adjust the system's time zone.

In a scenario where a Windows device has been deployed using Autopilot, the automatic adjustment of the system's time zone becomes very important. By default, every Windows device starts out with the time zone set to Pacific Time (UTC-08:00), which is not ideal for devices deployed in different time zones. This can cause confusion and potential issues with time-dependent functions and applications.

The 'tzautoupdate' service, when enabled, allows Windows to automatically adjust the system's time zone based on the device's location. Particularly useful for devices that move between different time zones.

However, during an Autopilot deployment, the 'tzautoupdate' service is not always enabled. This is where the `Detect_EnableAutoTimeZoneUpdate.ps1` and `Fix_EnableAutoTimeZoneUpdate.ps1` scripts come into play. They ensure that 'tzautoupdate' service is set to Manual, allowing the system to automatically adjust its time zone based on its location. This avoids potential issues caused by incorrect time zone settings, should be important part of any Autopilot deployment.

## Scripts

- **`Detect_EnableAutoTimeZoneUpdate.ps1`** Checks if the 'tzautoupdate' service is set to Manual. It is the detection script. Stores the name of the service and the desired start-up setting in variables. It then tries to get the service object, suppressing errors if the service is not found. If the service exists, it compares its StartType with the desired action. Returns the appropriate message and exits based on the comparison.

- **`Fix_EnableAutoTimeZoneUpdate.ps1`** Sets 'tzautoupdate' service to Manual. This is the remediation script. It enables the "Automatic Time Zone" service (tzautoupdate) which fixes the time zone to be automatically configured using location services when Autopilot has been set up to hide Privacy Settings. Remember to also configure a Configuration Profile to enable "Location Services".
The script defines a function to manage services, which takes the service name and the action to be performed as parameters. It then calls this function to manage the 'tzautoupdate' service, setting it to Manual. It finally returns the appropriate message and exits with a success status code (0).

## Usage

The `Detect_EnableAutoTimeZoneUpdate.ps1` and `Fix_EnableAutoTimeZoneUpdate.ps1` scripts are designed to be used with Microsoft Intune's "Remediations" feature nos in the "Devices" section or space. 

Here's a step-by-step guide on how to use these scripts:

1. **Create a new Remediations script in Microsoft Intune.** Navigate to the "Devices" section. Select "Remediations" and click on "+ Create script package".

2. **Fill in the basic information.** Provide a name and description for the script package. Could be something like "Enable Auto Time Zone Update".

3. **Upload the scripts.** In the "Detection script" field, upload the `Detect_EnableAutoTimeZoneUpdate.ps1` script. In the "Remediation script" field, upload the `Fix_EnableAutoTimeZoneUpdate.ps1` script. 

4. **Configure script settings.** Set the script type to "PowerShell", and set "Run this script using the logged-on credentials" to "No". Also, set "Enforce script signature check" to "No".

5. **Assign the script package.** Assign the script package to a group of devices where you want to enable the automatic time zone update.

6. **Monitor script performance.** Once the script package is assigned, you can monitor its performance in the "Remediations" dashboard. You can see how many devices have successfully enabled the 'tzautoupdate' service, and how many devices have failed. Scripts generate useful Output, select columns "Pre-remediation detection output" and "Post-remediation detection output" for execution details.

Remember, remediation script will only run if the detection script exits with a non-zero exit code, indicating that the 'tzautoupdate' service is not set to Manual.

## Credits

Full credit for the original scripts goes to Adam Gross (Twitter: @AdamGrossTX) and Ben Reader (Twitter: @powers_hell). The original scripts can be found at https://github.com/IntuneTraining/TimezoneTurnOn.

## License

Based on other script, please notify Adam and Ben.

## Disclaimer
This script is provided as-is with no warranties or guarantees of any kind. Always test scripts and tools in a controlled environment before deploying them in a production setting.


