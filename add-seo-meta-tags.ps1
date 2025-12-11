# PowerShell script to add SEO meta tags to all HTML pages
# This script adds meta descriptions, keywords, canonical URLs, and Open Graph tags

$baseUrl = "https://aspnetcoremastery.akwasi.dev"

# Meta descriptions and keywords for each section
$metaData = @{
    "index.html"                                            = @{
        title       = "ASP.NET Core Mastery - Complete Learning Guide"
        description = "Free comprehensive ASP.NET Core tutorial from beginner to advanced. Learn C#, Entity Framework, Web APIs, authentication, deployment with 122 sections across 20 parts."
        keywords    = "ASP.NET Core tutorial, C# learning, .NET development, web development course, Entity Framework Core, free programming tutorial"
        priority    = "1.0"
    }
    
    # Part 1: Foundations
    "part-01-foundations/01-what-is-programming.html"       = @{
        description = "Learn what programming is, how computers execute code, and why programming languages exist. Start your coding journey from absolute basics."
        keywords    = "what is programming, learn to code, programming basics, how computers work, coding for beginners"
    }
    "part-01-foundations/02-what-is-csharp-dotnet.html"     = @{
        description = "Understand C# programming language and the .NET ecosystem. Learn about .NET runtime, SDK, and how C# fits into modern development."
        keywords    = "C# programming, .NET framework, what is C#, .NET ecosystem, C# basics"
    }
    "part-01-foundations/03-variables-and-data-types.html"  = @{
        description = "Master C# variables and data types including int, string, bool, decimal. Learn type safety, value vs reference types, and type conversion."
        keywords    = "C# variables, data types C#, int string bool, value types, reference types"
    }
    "part-01-foundations/04-operators-and-expressions.html" = @{
        description = "Learn C# operators: arithmetic, comparison, logical, and assignment. Understand operator precedence and build complex expressions."
        keywords    = "C# operators, arithmetic operators, logical operators, comparison operators, expressions"
    }
    "part-01-foundations/05-control-flow.html"              = @{
        description = "Master control flow in C# with if statements, switch expressions, for loops, while loops, and foreach. Learn when to use each construct."
        keywords    = "C# control flow, if statement, switch case, for loop, while loop, foreach"
    }
    "part-01-foundations/06-methods-and-functions.html"     = @{
        description = "Learn to write C# methods and functions. Understand parameters, return types, method overloading, and optional parameters."
        keywords    = "C# methods, functions C#, method parameters, return types, method overloading"
    }
    "part-01-foundations/07-oop-classes-objects.html"       = @{
        description = "Master object-oriented programming in C#. Learn classes, objects, constructors, properties, encapsulation, and access modifiers."
        keywords    = "C# OOP, object-oriented programming, C# classes, objects, constructors, encapsulation"
    }
    "part-01-foundations/08-collections-and-generics.html"  = @{
        description = "Learn C# collections: List, Dictionary, HashSet, Queue, Stack. Understand generics and choose the right collection for your needs."
        keywords    = "C# collections, List Dictionary, generics C#, HashSet Queue Stack, collection types"
    }
    "part-01-foundations/09-linq.html"                      = @{
        description = "Master LINQ (Language Integrated Query) in C#. Learn to query collections with Where, Select, OrderBy, GroupBy, and aggregate functions."
        keywords    = "LINQ C#, Language Integrated Query, LINQ queries, Where Select, GroupBy"
    }
    "part-01-foundations/10-async-await.html"               = @{
        description = "Learn asynchronous programming in C# with async/await. Understand Task, async methods, and how to write non-blocking code."
        keywords    = "async await C#, asynchronous programming, Task C#, async methods, non-blocking code"
    }
}

# Function to create meta tags HTML
function Get-MetaTags {
    param(
        [string]$filePath,
        [string]$title,
        [string]$description,
        [string]$keywords,
        [string]$canonicalUrl
    )
    
    return @"
  <meta name="description" content="$description">
  <meta name="keywords" content="$keywords">
  <meta name="author" content="Akwasi Adu-Kyeremeh">
  <link rel="canonical" href="$canonicalUrl">
  
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="article">
  <meta property="og:url" content="$canonicalUrl">
  <meta property="og:title" content="$title">
  <meta property="og:description" content="$description">
  <meta property="og:image" content="$baseUrl/assets/og-image.png">
  
  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="$canonicalUrl">
  <meta property="twitter:title" content="$title">
  <meta property="twitter:description" content="$description">
  <meta property="twitter:image" content="$baseUrl/assets/og-image.png">
"@
}

Write-Host "Adding SEO meta tags to HTML files..." -ForegroundColor Cyan

$filesProcessed = 0
$filesUpdated = 0

# Process index.html
if (Test-Path "index.html") {
    $content = Get-Content "index.html" -Raw
    $meta = $metaData["index.html"]
    
    if ($content -notmatch 'meta name="description"') {
        $canonicalUrl = "$baseUrl/"
        $metaTags = Get-MetaTags -filePath "index.html" -title $meta.title -description $meta.description -keywords $meta.keywords -canonicalUrl $canonicalUrl
        
        # Insert after <head> tag
        $content = $content -replace '(<head>)', "`$1`n$metaTags"
        Set-Content "index.html" -Value $content -NoNewline
        $filesUpdated++
        Write-Host "  Updated: index.html" -ForegroundColor Green
    }
    $filesProcessed++
}

# Process all part directories
$partDirs = Get-ChildItem -Directory -Filter "part-*" | Sort-Object Name

foreach ($dir in $partDirs) {
    $htmlFiles = Get-ChildItem -Path $dir.FullName -Filter "*.html" | Sort-Object Name
    
    foreach ($file in $htmlFiles) {
        $relativePath = "$($dir.Name)/$($file.Name)"
        $content = Get-Content $file.FullName -Raw
        
        # Skip if already has meta description
        if ($content -match 'meta name="description"') {
            $filesProcessed++
            continue
        }
        
        # Extract title from HTML
        if ($content -match '<title>(.*?)</title>') {
            $pageTitle = $Matches[1]
        }
        else {
            $pageTitle = $file.BaseName
        }
        
        # Get or generate meta data
        if ($metaData.ContainsKey($relativePath)) {
            $meta = $metaData[$relativePath]
            $description = $meta.description
            $keywords = $meta.keywords
        }
        else {
            # Generate generic description based on title
            $description = "Learn $pageTitle in ASP.NET Core. Comprehensive tutorial with practical examples and best practices."
            $keywords = "ASP.NET Core, $pageTitle, C# tutorial, web development"
        }
        
        $canonicalUrl = "$baseUrl/$relativePath"
        $metaTags = Get-MetaTags -filePath $relativePath -title $pageTitle -description $description -keywords $keywords -canonicalUrl $canonicalUrl
        
        # Insert after <head> tag
        $content = $content -replace '(<head>)', "`$1`n$metaTags"
        Set-Content $file.FullName -Value $content -NoNewline
        $filesUpdated++
        Write-Host "  Updated: $relativePath" -ForegroundColor Green
        
        $filesProcessed++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SEO meta tags added successfully!" -ForegroundColor Green
Write-Host "Files processed: $filesProcessed" -ForegroundColor Cyan
Write-Host "Files updated: $filesUpdated" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
