
<#
.SYNOPSIS
    Set Cortana to use your default browser and your choice of search engine
.DESCRIPTION
    When searching in cortana and recieving web results, the results will use your deafult browser
    You can configure the search engine that is used by deafult
.EXAMPLE
    PS C:\> defaultSearch.ps1 -install -engine duckduckgo
    Installs the script with using the DuckDuckGo Engine
.EXAMPLE
    PS C:\> defaultSearch.ps1 -install -searchurl "https://search.yahoo.com/search?p=%s"
    Configure the deafult search engine to yahoo
.PARAMETER url
    URL to parse, this this given by Windows and is not required
.PARAMETER uninstall
    If the uninstall switch is present, it will remove the defaultSearch as the deafault url handler
.PARAMETER install
    If the install switch is present, the script will install itself using its current location
.PARAMETER engine
    "Google", "Bing", or "DuckDuckGo"
.PARAMETER searchurl
    A custom url.  Use "%s" in place of search terms.
    ex. https://www.google.nl/search?q=%s"
.PARAMETER direct
    When using the Cortana search go direct to url and bypass bing (for credit in the search)
    ex. https://www.bing.com/WS/redirect/?q=bing&url=aHR0cHM6Ly9lbi53aWt...
    vs
    https://en.wikipedia.org/wiki/Bing_(search_engine)
.NOTES
    Basically just a modification of
    http://www.winhelponline.com/blog/cortana-web-results-google-search-default-browser/
#>
param (
    # URL to parse
    [Parameter(ValueFromPipeline, Position = 0)]
    [string] $url,

    [Parameter()]
    [switch] $uninstall = $false,

    [Parameter(ParameterSetName = "install")]
    [switch] $install = $false,

    [Parameter(ParameterSetName = "install")]
    [ValidateSet("Google", "Bing", "DuckDuckGo")]
    [string] $engine = "Google",

    [Parameter(ParameterSetName = "install")]
    [string] $searchurl,

    [Parameter(ParameterSetName = "install")]
    [switch] $direct = $false
)

$searchurls = @{
    "Google"     = "https://www.google.com/search?q=%s";
    "Bing"       = "https://www.bing.com/search?q=%s";
    "DuckDuckGo" = "https://duckduckgo.com/?q=%s"
}
Add-Type -AssemblyName System.Web

if ($install -or $uninstall) {
    $file = ([System.IO.DirectoryInfo] $MyInvocation.InvocationName)

    if ($install) {
        Write-Output "installing..."
    
        if ($searchurl) {
            Write-Output "Using custom search url $searchurl"
        } else {
            Write-Output ("Using search url {0}" -f $searchurls[$engine])
            $searchurl = $searchurls[$engine]
        }
    
        Write-Output "Creating regkeys HKCU:\Software\Clients\StartmenuInternet\defaultSearch"
        New-Item -Path HKCU:\Software\Clients\StartmenuInternet\ -Name "defaultSearch" -Value "defaultSearch" -Force | Out-Null
        New-Item -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch -Name "Capabilities" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch -PropertyType String -Name "ApplicationDescription" -Value "A custom script to redirect Cortana search results to default browser." -Force | Out-Null
        New-ItemProperty -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch -PropertyType String -Name "ApplicationName" -Value "defaultSearch" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch\Capabilities\ -PropertyType String -Name "microsoft-edge" -Value "defaultSearch" -Force | Out-Null
        New-Item -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch\Capabilities -Name "URLAssociations" -Force | Out-Null
        New-ItemProperty -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch\Capabilities\URLAssociations -PropertyType String -Name "microsoft-edge" -Value "defaultSearch" | Out-Null
    
        Write-Output "Creating HKCU:\Software\Classes\defaultSearch\shell\open\"
        try {
            New-Item -Path HKCU:\Software\Classes\defaultSearch\shell\open\ -Name "command" -Value `
            ('powershell.exe -WindowStyle Hidden -File {0} "%1"' -f $file.FullName) -Force | Out-Null
        } catch {
            Set-Item -Path HKCU:\Software\Classes\defaultSearch\shell\open\ -Name "command" -Value `
            ('powershell.exe -WindowStyle Hidden -File {0} "%1"' -f $file.FullName) -Force | Out-Null
        }
    
        # Set preferences
        Write-Output "Setting preferences"
        New-ItemProperty -Path HKCU:\Software\Classes\defaultSearch\ -Name "url" -PropertyType String -Value $searchurl -Force | Out-Null
        New-ItemProperty -Path HKCU:\Software\Classes\defaultSearch\ -Name "direct" -PropertyType DWord -Value ([int] $direct.ToBool()) -Force | Out-Null
    
        Write-Output "Setting URL choice applciation"
        New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge\UserChoice -Name "ProgId" -Value "defaultSearch" -Force | Out-Null
        Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge\UserChoice -Name "Hash"
        
        echo "You may need to set the default app for Microsft-Edge to Pwershell"
        Start-Process ms-settings:defaultapps
    }
    if ($uninstall) {
        Write-Output "Removing URL choice application"
        Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge\UserChoice -Name "ProgId"
        Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\microsoft-edge\UserChoice -Name "Hash"
    
        Remove-Item -Path HKCU:\Software\Classes\defaultSearch\ -Recurse
        Remove-Item -Path HKCU:\Software\Clients\StartmenuInternet\defaultSearch -Recurse
    }
} else {
    if ($url) {
        # Convert from "Percent-encoding"
        $decodedURL = [System.Web.HttpUtility]::UrlDecode($url)
                    
        # If a search, redirect to prefered search engine
        if ($url.Contains("search")) {
            try {
                $searchurl = Get-ItemPropertyValue -Path HKCU:\Software\Classes\defaultSearch\ -Name "url"
            } catch {
                $searchurl = $searchurls[0]
            }

            # Get serach terms
            $query = $decodedURL -replace '^(.*?)search\?q=(?<query>.*?)&(.*)$', '${query}'
        
            # Insert search terms into chossen search engine
            Start-Process ($searchurl -replace '%s', $query)
        }

        # If useing a search result from Cortana
        if ($url.Contains("redirect")) {
            # Get the stored settings
            try {
                [bool] $direct = Get-ItemPropertyValue -Path HKCU:\Software\Classes\defaultSearch\ -Name "direct"
            } catch {
                $direct = $false
            }

            if ($direct) {
                # Get the encoded url from Bing and convert to string
                $base64URL = $decodedURL -replace '^(.*)&url=(?<url>.*?)&(.*)$', '${url}'
                $newURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64url))
            } else {
                # Get Bing url
                $newURL = $decodedURL -replace '^(.*?)https(.*?)$', 'https${2}'
            }
            Start-Process $newURL
        }
    }
}
