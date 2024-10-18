# LBchecker
Powershell script to check the operation of the load balancer 

# function
It has the following functions.

- It runs on a Windows terminal running Powershell.

- Check the response from multiple IP addresses (secondary IP addresses) set on the terminal to the virtual address set on the load balancer.

- The Powershell console will display communication success in green text and communication failure in red text.

- If communication fails, you will be notified by a beep.

- Records logs in a file.

- Since it is a PowerShell script, it can circumvent the customer environment's "free software is prohibited" policy.

# Cautionary Notes
The following cautionary notes apply:

- Since sufficient testing has not been conducted in the author's environment, it is technically impractical to use this script with load balancers on the cloud that have global addresses.

- Because the script judges communication success based on the HTTP return code 200, the target service for load balancing must be using either HTTP or HTTPS.

- If there is a router between the load balancer and the device running the script that converts IP addresses from private to global, the script will not function properly.

- If the session persistence method uses cookies, the session will not be maintained, and load distribution will occur.

- The load balancing is achieved by accessing with different IP addresses from the device running the script, so the environment must allow the assignment of multiple secondary ports to the network port of the device.

# procedure

In this guide, we assume the IP address of the device is 192.168.1.1/25 and the gateway is 192.168.1.254. Please modify the IP address according to your specific environment.

Fix the network interface and open the "Advanced Settings" in the IPv4 properties of the interface.

Press the "Add(A)..." button.

Set "192.168.1.2/24" as the secondary address and press "Add(A)".

Repeat the same process to add additional secondary addresses. In this example, 10 addresses were added. These 10 addresses will be used as the source addresses for accessing the load balancer. Once all settings are done, press "OK" on all dialogs to close the settings screen.

Run ipconfig from the command prompt to verify that all IP addresses have been configured.

Create a script file for ease of use and save it in a location you can easily access. In this example, the file is saved as "lbchecker.ps1" in the "C:\temp" folder.

Launch PowerShell.
Enter the following command to change the policy so that the script can be executed:

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

Move to the folder where the script is located. (In this example, the script is in the "C:\temp" folder.)

cd c:\temp

Execute the script. (In this example, the script is named lbchecker.ps1.)
Enter the destination server name as an argument.

.\lbchecker.ps1 google.com

If the execution is successful, it will be displayed as follows:

To stop the script, press "Ctrl+C".
Please check the actual load balancing status from the load balancer's management interface.
