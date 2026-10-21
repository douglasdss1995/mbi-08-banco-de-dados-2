# 1. Is there a PostgreSQL service?
Get-Service -Name "postgresql*" | Format-Table Name, Status, StartType

# 2. Installed program entry (shows the real version)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object DisplayName -like "*PostgreSQL*" |
    Select-Object DisplayName, DisplayVersion, InstallLocation

# 3. Real data directory (it may not be the default)
Get-CimInstance Win32_Service -Filter "Name like 'postgresql%'" |
    Select-Object Name, State, PathName

# 4. Binary and version
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" --version

# 5. Is something listening on the port?
Get-NetTCPConnection -LocalPort 5432 -State Listen -ErrorAction SilentlyContinue