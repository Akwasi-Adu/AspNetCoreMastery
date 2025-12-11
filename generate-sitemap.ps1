# PowerShell script to generate sitemap.xml for ASP.NET Core Mastery

$baseUrl = "https://aspnetcoremastery.akwasi.dev"
$currentDate = Get-Date -Format "yyyy-MM-dd"

# Start XML
$xml = '<?xml version="1.0" encoding="UTF-8"?>' + "`n"
$xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n"
$xml += '  <!-- Index Page -->' + "`n"
$xml += '  <url>' + "`n"
$xml += "    <loc>$baseUrl/</loc>`n"
$xml += "    <lastmod>$currentDate</lastmod>`n"
$xml += '    <changefreq>yearly</changefreq>' + "`n"
$xml += '    <priority>1.0</priority>' + "`n"
$xml += '  </url>' + "`n`n"

# Get all HTML files in part directories
$partDirs = Get-ChildItem -Path "." -Directory -Filter "part-*" | Sort-Object Name

foreach ($dir in $partDirs) {
  $htmlFiles = Get-ChildItem -Path $dir.FullName -Filter "*.html" | Sort-Object Name
    
  foreach ($file in $htmlFiles) {
    $relativePath = "$($dir.Name)/$($file.Name)"
    $xml += '  <url>' + "`n"
    $xml += "    <loc>$baseUrl/$relativePath</loc>`n"
    $xml += "    <lastmod>$currentDate</lastmod>`n"
    $xml += '    <changefreq>yearly</changefreq>' + "`n"
    $xml += '    <priority>0.6</priority>' + "`n"
    $xml += '  </url>' + "`n`n"
  }
}

# Close XML
$xml += '</urlset>'

# Write to file
Set-Content -Path "sitemap.xml" -Value $xml -Encoding UTF8

Write-Host "Generated sitemap.xml with all pages" -ForegroundColor Green
$urlCount = (Select-String -Path "sitemap.xml" -Pattern "<url>" -AllMatches).Matches.Count
Write-Host "Total URLs: $urlCount" -ForegroundColor Cyan
