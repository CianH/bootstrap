### Configure settings ###
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -name BingSearchEnabled -value 0 # Web Search in Start
sp -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection -name AllowTelemetry -value 0 # Telemetry

# Privacy/General
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -name Enabled -value 0 # Let apps use my advertising ID
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -name EnableWebContentEvaluation -value 0 # SmartScreen Filter
sp -path HKCU:\SOFTWARE\Microsoft\Input\TIPC -name Enabled -value 0 # Send MSFT info about typing/writing
sp -path "HKCU:\Control Panel\International\User Profile\" -name HttpAcceptLanguageOptOut -value 1 # Share language list to websites (1 is disable)

# Privacy/Location
sp -path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System -name AllowLocation -value 0 # Location for this device