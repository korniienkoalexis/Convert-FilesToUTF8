$folderNameForConvertedFiles = "ConvertedFiles" #Specifie folder name for converted files

Function Convert-FilesToUTF8 {

Param (
[parameter (Mandatory=$true)][string]$path
)

function Get-Encoding {
param([Parameter(ValueFromPipeline=$True)] $filename)      
process {
  $reader = [System.IO.StreamReader]::new($filename, [System.Text.Encoding]::default,$true)
  $peek = $reader.Peek()
  $encoding = $reader.currentencoding
  $reader.close()
  [pscustomobject]@{Name=split-path $filename -leaf
                BodyName=$encoding.BodyName
                EncodingName=$encoding.EncodingName
                FullPath=$filename}
}

}


Get-ChildItem $path -File *.sql | foreach { $file = $_.FullName

 
 $file = "'" + $file + "'"
 $code = 'Get-Encoding' +" " + $file
 Invoke-Expression $code | where {$_.BodyName -ne "utf-8"} | foreach {

    $fileToConvert = $_.FullPath #Full path to original file for converting

    #$fileAfterConverting = $fileToConvert.Insert(($fileToConvert.LastIndexOf('.')),"_UTF8") #path to the file after converting, this line add _UTF8 to the end in file name

    #####################Creating Folder for converted files (Comment next 5 lines if using filename with _UTF8 in the end)##############################################################################################
    $fileAfterConverting = $path + "\" + $folderNameForConvertedFiles + "\" +$_.Name #Generate a path for saving converted files in specified folser
    if (-not (Test-Path -LiteralPath $path)) 
        {
            New-Item -Path $path -Name $folderNameForConvertedFiles -ItemType "directory" #Check for existing and create folder for converted files
        }
   ########################################################################################################################################################
   
    try 
        {
        Get-Content -Path $fileToConvert | Out-File -FilePath $fileAfterConverting -Encoding UTF8 -ErrorAction Stop #convertig File and saving to path from variable $fileAfterConverting
        Write-Host "File " $fileAfterConverting "converted" -ForegroundColor Green
        }
            Catch
            {
            $_.Exception
            }
    }
}

}

Convert-FilesToUTF8

    #$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    #[System.IO.File]::WriteAllLines($fileAfterConverting, (Get-Content -Path $fileToConvert), $Utf8NoBomEncoding)