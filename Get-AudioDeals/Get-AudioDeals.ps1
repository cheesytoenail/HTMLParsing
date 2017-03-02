##Function
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
    ##Currency Variable
    $Currency = New-Object System.Globalization.CultureInfo("en-GB")
    ##Loop to Build Output Table
    Foreach ($Price in $Prices)
    {
        ##Temp Variable / Split
        $TempPrice = ($Price -Split $Delimiter).Trim().TrimStart("£")
        ##Math for Differences
        $DiffValue += "£" + ($TempPrice[1] - $TempPrice[0])
        $DiffPercent += (($TempPrice[1] - $TempPrice[0]) / $TempPrice[1]).ToString("P")
        ##Adding Prices to Arrays
        $Now += "£" + $TempPrice[0]
        $Was += "£" + $TempPrice[1]
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