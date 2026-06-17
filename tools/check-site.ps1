$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$indexPath = Join-Path $root 'index.html'
$stylesPath = Join-Path $root 'styles.css'
$backgroundPath = Join-Path $root 'assets\background.png'

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
Assert-True (Test-Path -LiteralPath $stylesPath) 'Missing styles.css'
Assert-True (Test-Path -LiteralPath $backgroundPath) 'Missing assets/background.png'

$html = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
$css = Get-Content -LiteralPath $stylesPath -Raw -Encoding UTF8

Assert-True ($html -match '<!doctype html>') 'index.html should declare HTML5 doctype'
Assert-True ($html -match 'lang="ru"') 'index.html should use Russian language metadata'
Assert-True ($html.Contains($mainTitle)) 'Missing main title'
Assert-True ($html.Contains($goalsTitle)) 'Missing goals section'
Assert-True ($html.Contains($newsTitle)) 'Missing news section'
Assert-True ($html.Contains($contestsTitle)) 'Missing contests section'
Assert-True (-not $html.ToLowerInvariant().Contains($eyebrowText)) 'Hero eyebrow text should be removed'
Assert-True ($html.Contains($directionsLink)) 'Missing directions link text'
Assert-True ($html -match 'href="#directions"') 'Directions link should target the directions section'
Assert-True ($html -match 'id="directions"') 'Missing directions target section'
Assert-True ($html.Contains($directionsTitle)) 'Missing directions section title'
Assert-True (([regex]::Matches($html, 'class="goal-item"')).Count -ge 8) 'Expected at least 8 goals'
Assert-True (([regex]::Matches($html, 'class="[^"]*\bnews-card\b')).Count -ge 3) 'Expected at least 3 news cards'
Assert-True ($css -match 'assets/background\.png') 'CSS should use the provided background image'
Assert-True ($css -match '#fff|white|rgba\(255,\s*255,\s*255') 'CSS should include a white visual layer'
Assert-True ($css -match '--paper:\s*rgba\(255,\s*255,\s*255,\s*0\.78\)') 'Panel white layer should be less opaque'
Assert-True ($css -match 'linear-gradient\(90deg,\s*rgba\(255,\s*255,\s*255,\s*0\.84\),\s*rgba\(255,\s*255,\s*255,\s*0\.52\)\)') 'Page overlay should reveal more of the background image'

'site checks passed'
