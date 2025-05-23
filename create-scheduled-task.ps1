# PowerShell script to create a scheduled task
param(
    [string]$TaskName = "DemoTask",
    [string]$TaskDescription = "Demo scheduled task created by Terraform"
)

# Log function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
    Add-Content -Path "C:\temp\scheduled-task-log.txt" -Value "[$timestamp] $Message"
}

try {
    # Create temp directory if it doesn't exist
    if (!(Test-Path "C:\temp")) {
        New-Item -ItemType Directory -Path "C:\temp" -Force
        Write-Log "Created temp directory"
    }

    Write-Log "Starting scheduled task creation process"

    # Define the action (what the task will do)
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"Write-Output 'Hello from scheduled task!' | Out-File -FilePath 'C:\temp\task-output.txt' -Append`""

    # Define the trigger (when the task will run) - every 5 minutes for demo
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5)

    # Define task settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    # Create the scheduled task
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Description $TaskDescription

    # Register the task
    Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force

    Write-Log "Successfully created scheduled task: $TaskName"
    
    # Verify the task was created
    $createdTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($createdTask) {
        Write-Log "Task verification successful. Task state: $($createdTask.State)"
    }
    else {
        Write-Log "ERROR: Task verification failed"
    }

}
catch {
    Write-Log "ERROR: Failed to create scheduled task: $($_.Exception.Message)"
    throw
}

Write-Log "Script execution completed"