# Script to add footer to all HTML pages in the ASP.NET Core Mastery learning guide

$footerHTML = @'

        <footer class="page-footer">
          Built with 💜 by <a href="https://akwasi.dev" target="_blank" rel="noopener noreferrer">Akwasi Adu-Kyeremeh</a> for developers who want to truly understand what they're building.
        </footer>
'@

# Get all part directories
$partDirs = Get-ChildItem -Path "." -Directory -Filter "part-*"

$totalFiles = 0
$updatedFiles = 0

foreach ($dir in $partDirs) {
    # Get all HTML files in the directory
    $htmlFiles = Get-ChildItem -Path $dir.FullName -Filter "*.html"
    
    foreach ($file in $htmlFiles) {
        $totalFiles++
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check if footer already exists
        if ($content -notmatch "Built with") {
            # Find the closing </nav> tag for page-nav and add footer before the closing </div>
            $pattern = '(\s*</nav>\s*)(</div>\s*</main>)'
            $replacement = '$1' + $footerHTML + "`n`n      " + '$2'
            
            $newContent = $content -replace $pattern, $replacement
            
            # Write back to file
            Set-Content -Path $file.FullName -Value $newContent -NoNewline
            $updatedFiles++
            Write-Host "Updated: $($file.FullName)" -ForegroundColor Green
        }
        else {
            Write-Host "Skipped (already has footer): $($file.FullName)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n========================================"
Write-Host "Total files processed: $totalFiles"
Write-Host "Files updated: $updatedFiles"
Write-Host "Files skipped: $($totalFiles - $updatedFiles)"
Write-Host "========================================"
