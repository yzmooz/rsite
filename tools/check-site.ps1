$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$indexPath = Join-Path $root 'index.html'
$contestsPath = Join-Path $root 'contests.html'
$stylesPath = Join-Path $root 'styles.css'
$backgroundPath = Join-Path $root 'assets\future-settlement.png'

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Utf8FromBase64 {
    param([string]$Value)
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$mainTitle = Utf8FromBase64 '0KDQsNC30LLQuNGC0LjQtSDQoNC+0YHRgdC40Lgg0L3QsCAxMDAg0LvQtdGC'
$goalsTitle = Utf8FromBase64 '0KbQtdC70Lgg0L3QsNGG0LjQvtC90LDQu9GM0L3QvtCz0L4g0L/RgNC+0LXQutGC0LA='
$newsTitle = Utf8FromBase64 '0J3QvtCy0L7RgdGC0Lg='
$contestsTitle = Utf8FromBase64 '0JrQvtC90LrRg9GA0YHRiw=='
$directionsLink = Utf8FromBase64 '0J/QvtGB0LzQvtGC0YDQtdGC0Ywg0L3QsNC/0YDQsNCy0LvQtdC90LjRjw=='
$directionsTitle = Utf8FromBase64 '0J3QsNC/0YDQsNCy0LvQtdC90LjRjyDQutC+0L3QutGD0YDRgdC+0LI='
$eyebrowText = Utf8FromBase64 '0LjQvdGE0L7RgNC80LDRhtC40L7QvdC90YvQuSDQv9GA0L7QtdC60YI='

Assert-True (Test-Path -LiteralPath $indexPath) 'Missing index.html'
Assert-True (Test-Path -LiteralPath $contestsPath) 'Missing contests.html'
Assert-True (Test-Path -LiteralPath $stylesPath) 'Missing styles.css'
Assert-True (Test-Path -LiteralPath $backgroundPath) 'Missing contest background image'
Assert-True (Test-Path -LiteralPath (Join-Path $root 'script.js')) 'Missing script.js'
Assert-True (Test-Path -LiteralPath (Join-Path $root 'assets\lucide.min.js')) 'Missing local icon library'

$html = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
$contestHtml = Get-Content -LiteralPath $contestsPath -Raw -Encoding UTF8

Assert-True ($html -match '<!doctype html>') 'index.html should declare HTML5 doctype'
Assert-True ($html -match 'lang="ru"') 'index.html should use Russian language metadata'
Assert-True ($html.Contains($mainTitle)) 'Missing main title'
Assert-True ($html.Contains($goalsTitle)) 'Missing goals section'
Assert-True ($html.Contains($newsTitle)) 'Missing news section'
Assert-True ($html -match 'href="contests.html"') 'Missing navigation to contests page'
Assert-True (-not ($html -match 'class="contest-hero"|<dialog')) 'Contest details should be on the separate page'
Assert-True ($contestHtml -match 'href="index.html"') 'Missing navigation back to homepage'
Assert-True ($contestHtml -match 'id="contest"') 'Missing contest section'
Assert-True (-not $html.ToLowerInvariant().Contains($eyebrowText)) 'Hero eyebrow text should be removed'
Assert-True ($contestHtml.Contains($directionsLink)) 'Missing directions link text'
Assert-True ($contestHtml -match 'href="#directions"') 'Directions link should target the directions section'
Assert-True ($contestHtml -match 'id="directions"') 'Missing directions target section'
Assert-True ($contestHtml.Contains($directionsTitle)) 'Missing directions section title'
Assert-True (([regex]::Matches($html, 'class="goal-item"')).Count -ge 8) 'Expected at least 8 goals'
Assert-True (([regex]::Matches($html, 'class="[^"]*\bnews-card\b')).Count -ge 3) 'Expected at least 3 news cards'
Assert-True ($contestHtml -match 'id="jury"') 'Missing jury section'
Assert-True ($contestHtml -match 'id="questions"') 'Missing questions section'

foreach ($page in @($html, $contestHtml)) {
    Assert-True ($page -match '<!doctype html>') 'Page should declare HTML5 doctype'
    Assert-True ($page -match 'lang="ru"') 'Page should use Russian metadata'
    Assert-True (([regex]::Matches($page, '<h1\b')).Count -eq 1) 'Each page should have one main heading'
    $ids = [regex]::Matches($page, '\bid="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    Assert-True (@($ids | Select-Object -Unique).Count -eq @($ids).Count) 'Duplicate HTML ids'
    foreach ($anchor in [regex]::Matches($page, 'href="#([^"]+)"')) {
        Assert-True ($ids -contains $anchor.Groups[1].Value) ('Broken anchor: ' + $anchor.Value)
    }
    foreach ($trigger in [regex]::Matches($page, 'data-dialog="([^"]+)"')) {
        $dialogId = [regex]::Escape($trigger.Groups[1].Value)
        Assert-True ($page -match ('<dialog id="' + $dialogId + '"')) ('Missing dialog: ' + $dialogId)
    }
    foreach ($resource in [regex]::Matches($page, '(?:src|href)="([^"#]+)"')) {
        Assert-True (Test-Path -LiteralPath (Join-Path $root $resource.Groups[1].Value)) ('Missing local asset: ' + $resource.Groups[1].Value)
    }
}

'site checks passed'
