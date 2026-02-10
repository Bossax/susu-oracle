# Script to replace the Unicode character 'ψ' (Psi) with 'psi' in all Oracle Skills files
# This fixes path resolution errors on Windows environments.

$skillsPath = "$env:USERPROFILE\.roo\skills"

# Check if the skills directory exists
if (-not (Test-Path $skillsPath)) {
    Write-Error "Could not find Roo Code skills directory at: $skillsPath"
    Write-Warning "Please ensure you have installed the skills using 'oracle-skills' or manual copy."
    exit
}

Write-Host "🔍 Scanning for 'ψ' in: $skillsPath" -ForegroundColor Cyan

# Find all files recursively
$files = Get-ChildItem -Path $skillsPath -Recurse -File

$count = 0

foreach ($file in $files) {
    try {
        # Read the content
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        
        # Check if it contains the Greek Psi character
        if ($content -match "ψ") {
            Write-Host "🔧 Patching: $($file.Name)" -ForegroundColor Yellow
            
            # Replace Psi with 'psi'
            $newContent = $content -replace "ψ", "psi"
            
            # Write the content back to the file (utf8 to be safe)
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            
            $count++
        }
    }
    catch {
        Write-Warning "Could not read/write $($file.Name). Skipping."
    }
}

Write-Host "`n✅ Complete! Updated $count files." -ForegroundColor Green
Write-Host "👉 Action Required: Please RENAME your local folder from 'ψ' to 'psi' manually in File Explorer." -ForegroundColor White