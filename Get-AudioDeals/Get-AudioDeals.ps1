﻿##Function
function Get-AudioDeals ($Filter)
{
    ##URL to Check Deals
    $URL = "http://www.audiot.co.uk/clearance-all/"
    ##Web Request
    $Results = Invoke-WebRequest -Uri $URL
    ##Grabs Name of Product
    $Name = $Results.ParsedHtml.getElementsByTagName("p") | where {$_.getAttributeNode("class").Value -eq "description"} 
    [array]$Name = $Name.outerText.Split([Environment]::NewLine)
    ##Grabs Price Info (Parsed Later)
    $Prices = $Results.ParsedHtml.getElementsByTagName("p") | where {$_.getAttributeNode("class").Value -eq "price"}
    [array]$Prices = $Prices.outerText.Split([Environment]::NewLine)
    ##Arrays
    $Now = @()
    $Was = @()
    $DiffValue = @()
    $DiffPercent = @()
    ##Split Delimiter for Prices
    $Delimiter = " was "
    ##Loop to Build Output Table
    Foreach ($Price in $Prices)
    {
        ##Temp Variables for Calculating Differences
        $TempNow = $Price.Split($Delimiter)[0].Trim().TrimStart("£")
        $TempWas = $Price.Split($Delimiter)[5].Trim().TrimStart("£")
        ##Math for Differences
        $DiffValue += [Decimal]$TempWas - [Decimal]$TempNow
        #$DiffPercent += ([Decimal]$TempNow/[Decimal]$TempWas).ToString("P")
        $DiffPercent += (([Decimal]$TempWas - [Decimal]$TempNow) / [Decimal]$TempWas).ToString("P")
        ##Split for Price Now/Was
        $Now += $Price.Split($Delimiter)[0].Trim().TrimStart("£")
        $Was += $Price.Split($Delimiter)[5].Trim().TrimStart("£")
        
    }
    ##Output Table
    $Table = 0..($Name.Length-1) | Select-Object @{name="Name";expression={$Name[$_]}},
                                                 @{name="Now";expression={$Now[$_]}},
                                                 @{name="Was";expression={$Was[$_]}},
                                                 @{name="Difference";expression={$DiffValue[$_]}},
                                                 @{name="% Saving";expression={$DiffPercent[$_]}}
    ##Output
    $Table | Where-Object {$_.Name -like "*$Filter*"} | Format-Table -AutoSize
}