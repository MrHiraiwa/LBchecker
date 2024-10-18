# Retrieve all IP addresses (only connected interfaces)
function Get-AllIPAddresses {
    # Get the network adapters that are connected (Up) and retrieve the interface index
    $connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty ifIndex
    # Based on the interface index, retrieve the IPv4 addresses
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceIndex -in $connectedAdapters } | Select-Object -ExpandProperty IPAddress
    return $ipAddresses
}

# Process command line arguments (specify the virtual IP address or URL to connect to)
if ($args.Count -eq 0) {
    # If no argument is specified, default to connecting to Google
    $virtualIP = "https://google.com"
} else {
    # If an argument is specified, use that value
    $virtualIP = $args[0]
    # If http/https is not specified, automatically prepend http
    if ($virtualIP -notmatch "^https?://") {
        $virtualIP = "http://$virtualIP"
    }
}

# Display connection information and log it to a file
Write-Host "Connecting to: $virtualIP" -ForegroundColor Cyan
Add-Content -Path "C:\log\load_balancer_check.log" -Value "$(Get-Date) - Connecting to: $virtualIP"

# Specify the path to the log file
$logFile = "C:\log\load_balancer_check.log"

# Function to display the result on the screen
function Show-Result {
    param (
        [string]$message,  # The message to display
        [bool]$success      # Flag indicating success or failure
    )

    # Display the message in green if successful, red if failed
    if ($success) {
        Write-Host $message -ForegroundColor Green
    } else {
        Write-Host $message -ForegroundColor Red
        # Play a beep sound if it fails
        [console]::beep()
    }
}

# Function to send HTTP/HTTPS requests
function Send-Request {
    param (
        [string]$sourceIP  # Source IP address for the request
    )

    try {
        # Execute curl command to send a request from the specified source IP
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "curl"  # Command to execute (curl)
        # Arguments for curl (source IP address and destination URL)
        $processInfo.Arguments = "--interface $sourceIP $virtualIP"
        # Redirect the standard output to get the response
        $processInfo.RedirectStandardOutput = $true
        # Do not use the shell and do not show a window
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        # Start the process
        $process = [System.Diagnostics.Process]::Start($processInfo)
        # Get the content of the standard output
        $output = $process.StandardOutput.ReadToEnd()
        # Wait for the process to exit
        $process.WaitForExit()

        # Check the curl exit code to determine success or failure
        if ($process.ExitCode -eq 0) {
            $status = "Success"  # If successful
            Show-Result "${sourceIP}: ${status}" $true  # Display success message
            Add-Content -Path $logFile -Value "$(Get-Date) - ${sourceIP}: ${status}"  # Log the result
        } else {
            $status = "Failed with exit code $($process.ExitCode)"  # If failed
            Show-Result "${sourceIP}: ${status}" $false  # Display failure message
            Add-Content -Path $logFile -Value "$(Get-Date) - ${sourceIP}: ${status}"  # Log the result
        }
    } catch {
        # Error message if an exception occurs
        $status = "Error: $_"
        Show-Result "${sourceIP}: ${status}" $false  # Display error message
        Add-Content -Path $logFile -Value "$(Get-Date) - ${sourceIP}: ${status}"  # Log the error
    }
}

# Main process (retrieve IP addresses and send requests sequentially)
$ipAddresses = Get-AllIPAddresses  # Retrieve the connected IP addresses

# Loop to send requests from each IP address
while ($true) {
    foreach ($ip in $ipAddresses) {
        # Send a request from each IP address
        Send-Request -sourceIP $ip
        Start-Sleep -Seconds 0  # Adjust wait time if necessary
    }

    $counter++  # Increment the counter (optional)
}
