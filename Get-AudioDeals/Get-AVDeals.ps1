function Get-AVDeals ($Filter)
{
    ##URL to Check Deals
    $TempURL = "https://www.audiovisualonline.co.uk/warehousedeals/all/"
    ##Web Request
    $Results = Invoke-WebRequest -Uri $TempURL
    ##Collects Each Page# URL;
    $URLs = $Results.ParsedHtml.getElementsByTagName("a") | Where-Object {$_.href -like "*https://www.audiovisualonline.co.uk/warehousedeals/all/?page=*"} | select href -Unique
    $URLs = $URLs.href
    ##Arrays
    $Names = @()
    $PricesNow = @()
    ##Loop
    foreach ($URL in $URLs)
    {
        foreach ($Result in $Results)
        {
            $Result = Invoke-WebRequest -Uri $URL
            ##Grabs Name of Product
            $Name = $Result.ParsedHtml.getElementsByTagName("span") | where {$_.getAttributeNode("class").Value -eq "product-title-words"} 
            [array]$Names += $Name.outerText.Split([Environment]::NewLine)
            ##Grabs Current Price of Product and Adds to Array
            $PriceNow = $Result.ParsedHtml.getElementsByTagName("span") | where {$_.getAttributeNode("class").Value -eq "product-cost-now-price"} 
            [array]$PricesNow += $PriceNow.outerText.Split([Environment]::NewLine)
        }
    }

    ##Output Table
    $Table = 0..($Names.Length-1) | Select-Object @{name="Name";expression={$Names[$_]}},
                                                  @{name="Now";expression={$PricesNow[$_]}}
    ##Output
    $Table | Where-Object {$_.Name -like "*$Filter*"} | Sort-Object name | Format-Table -AutoSize
}