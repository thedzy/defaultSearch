# defaultSearch.ps1

Set Cortana to use your default browser and your choice of search engine

## NAME
    C:\Users\thedz\git\PowerShell\scripts\defaultSearch.ps1

## SYNOPSIS
    Set Cortana to use your default browser and your choice of search engine

## SYNTAX
    C:\Users\thedz\git\PowerShell\scripts\defaultSearch.ps1 [[-url] <String>] [-unisntall] [-install] [-engine <String>] [-searchurl <String>] [<CommonParameters>]


## DESCRIPTION
    When searching in cortana and recieving web results, the results will use your deafult browser
    You can configure the search engine that is used by deafult


## PARAMETERS
    -url <String>
        URL to parse, this this given by Windows and is not required

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Accept wildcard characters?  false

    -unisntall [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -install [<SwitchParameter>]
        If the install switch is present, the script will install itself using its current location

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -engine <String>
        "Google", "Bing", or "DuckDuckGo"

        Required?                    false
        Position?                    named
        Default value                Google
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -searchurl <String>
        A custom url.  Use "%s" in place of search termas.
        ex. https://www.google.nl/search?q=%s"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -direct [<SwitchParameter>]
        When using the Cortana search go direct to url and bypass bing (for credit in the search)
        ex. https://www.bing.com/WS/redirect/?q=bing&url=aHR0cHM6Ly9lbi53aWt...
        vs
        https://en.wikipedia.org/wiki/Bing_(search_engine)

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

## NOTES
    Basically just a modification of
    http://www.winhelponline.com/blog/cortana-web-results-google-search-default-browser/

    Converted to PowerShell, added custom search engines and skipping redirection

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>defaultSearch.ps1 -install -engine duckduckgo

    Installs the script with using the DuckDuckGo Engine




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>defaultSearch.ps1 -install -searchurl "https://search.yahoo.com/search?p=%s"

    Configure the deafult search engine to yahoo





## RELATED LINKS
    http://www.winhelponline.com/blog/cortana-web-results-google-search-default-browser/