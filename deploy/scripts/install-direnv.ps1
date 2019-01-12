<#
Downloads and installs most recent direnv cli app to your user profile.
Default location will be $HOME/.local/bin (which is also added to your environment path)

https://github.com/direnv/direnv/releases/download/

#>

Function Update-SystemPath {            

    Param(
        [array]$PathToAdd
    )
    $VerifiedPathsToAdd = $Null
    Foreach ($Path in $PathToAdd) {            

        if ($env:Path -like "*$Path*") {
            Write-Output "Currnet item in path is: $Path"
            Write-Output "$Path already exists in Path statement" 
        }
        else {
            $VerifiedPathsToAdd += ";$Path"
            Write-Output "`$VerifiedPathsToAdd updated to contain: $Path"
        }            

        if ($null -ne $VerifiedPathsToAdd) {
            Write-Output "`$VerifiedPathsToAdd contains: $verifiedPathsToAdd"
            Write-Output "Adding $Path to Path statement now..."
            [Environment]::SetEnvironmentVariable("Path", $env:Path + $VerifiedPathsToAdd, "Process")          

        }
    }
}

Update-SystemPath "$HOME\.local\bin"

# Download latest direnv/direnv release from github

$repo = "direnv/direnv"
$file = "direnv.windows-amd64.exe"
$filepath = "$HOME\.local\bin"
$outfile = Join-Path $filepath 'direnv.exe'

$releases = "https://api.github.com/repos/$repo/releases"

Write-Output "Determining latest release of $file"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

Write-Output "Tag retrieved: $tag"
$download = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]

Write-Output "Download URL: $download"
Write-Output "File Name: $name"

Write-Output "Downloading to $name"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $download -Out $name

Remove-Item $outfile -Force -ErrorAction:SilentlyContinue
Move-Item $name $outfile

Write-Output "Installed to $outfile"