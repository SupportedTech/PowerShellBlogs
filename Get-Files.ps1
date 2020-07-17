# By Andrew Wilson
# 18/02/2019
#
#.Description
#
# This function will scan the provided or current directory and provide size 
# information on folders.
#
#.Notes
#
# The more contents in the folders the longer this script will run. Do not
# recommend running on root or top tier folders.
#
#.Parameters
#
# -Location provide the full path to scan. If not provided the script will take the
# current location the PS environment is running in.
#
# -SortBySize provide "Ascending" or "Descending" to sort by size
#
# -Bypass skips the sorting of information and displays it raw. This way the function can be incorperated into a script
# Provide a True parameter to this switch, otherwise no results will be returned.
#
#.Improvements
# Swap out the $Size conversion for a more efficient function
#


Function Get-Files
    {
    [CmdletBinding()]
    # Parameters:
    Param(
    [String]$Location,
    [String]$SortBySize,
    [String]$Bypass
    )

    # Empty Parameter action
    If (!$Location)
        {$Location = (Get-Location).Path}

    # Check Location is valid
    If (!(Get-ChildItem -Path $Location)) {throw "Error: Either you do not have access to the location or the provided location is invalid"}

    # Configure the array for containing results. This will be called at the end of the script
    $Array = @()

    # Get the files and folders for the chosen location
    $Files = Get-ChildItem -Path $Location -force

    # Seperate the files and folders so we can look at each result
    Foreach ($File in $Files)
        {
        # Folders contain "d" in there mode parameter so we search mode for "d"
        If ($File.mode -like "*d*")
            {
            # Create the folder location for each folder we have found. This will be passed to Get-Childitem
            $FolderLocation = $Location + "\" + $File.Name
            # Use Get-Childitem -recruse to get all files in the folder. Pass this into a variable for later
            $FolderContents = Get-ChildItem $FolderLocation -Force -Recurse -ErrorAction SilentlyContinue 
            # Reset Variable to ensure previous information is not passed into the $Size loop
            $Size = $Null
            # For each file found within the current folder.
            Foreach ($FolderFile in $FolderContents)
                {
                # $Size will contain our overall size for the folder. We add every files lengh together to get the total size of all files within the folder
                $size = $size + $FolderFile.Length
                }
            $HiddenSize = $Size
            #######################################
            ########### Convert Size ##############
            If ($Size -gt 2 -and $Size -lt 1024)
                {
                $Size = [String]$Size + " B"
                }
            Elseif ($Size -gt 1023 -and $Size -lt 1048576)
                {
                $Size = $Size / 1024
                $Size = [Math]::Round($Size)
                $Size = [String]$Size + " KB"
                }
            Elseif ($Size -gt 1048575 -and $Size -lt 1073741824)
                {
                $Size = $Size / 1048576
                $Size = [Math]::Round($Size,1)
                $Size = [String]$Size + " MB"
                }
            Elseif ($Size -gt 1073741823)
                {
                $Size = $Size / 1073741824
                $Size = [Math]::Round($Size,2)
                $Size = [String]$Size + " GB"
                }
            Elseif ($Size -lt 1)
                {$Size = "0 B"}
            Else
                {$Size = "Not Available"}
            #######################################
            #######################################
            #============================================
            #============== Collect Data ================
            $Result = "" | select Name,Size,Type,Lastwritetime,HiddenSize
            $Result.Name = $File.Name
            $Result.Size = $Size
            $Result.Type = "File Folder"
            $Result.LastWriteTime = $file.LastWriteTime
            $Result.HiddenSize = $HiddenSize
            $Array += $Result
            }
            #============================================
            #============================================
        
        # If we didn't find a "d" in the mode then we believe it is a file and so we dont need to look within and can take the information right from get-childitem

        #######################################
        ########### Convert Size ##############
        Else
            {
            $Size = $File.Length
            $HiddenSize = $Size
            If ($Size -gt 2 -and $Size -lt 1024)
                {
                $Size = [String]$Size + " B"
                }
            Elseif ($Size -gt 1023 -and $Size -lt 1048576)
                {
                $Size = $Size / 1024
                $Size = [Math]::Round($Size)
                $Size = [String]$Size + " KB"
                }
            Elseif ($Size -gt 1048575 -and $Size -lt 1073741824)
                {
                $Size = $Size / 1048576
                $Size = [Math]::Round($Size,1)
                $Size = [String]$Size + " MB"
                }
            Elseif ($Size -gt 1073741823)
                {
                $Size = $Size / 1073741824
                $Size = [Math]::Round($Size,2)
                $Size = [String]$Size + " GB"
                }
            Elseif ($Size -lt 1)
                {$Size = "0 B"}
            Else
                {$Size = "Not Available"}
            #######################################
            #######################################

            ##
            If ($File.Name -like "*.exe")
                {$Type = "Application"}
            ElseIf ($File.Name -like "*.log")
                {$Type = "Log File"}
            ElseIf ($File.Name -like "*.txt")
                {$Type = "Text File"}
            ElseIf ($File.Name -like "*.sys")
                {$Type = "System File"}
            ElseIf ($File.Name -like "*.bat")
                {$Type = "Batch File"}
            ElseIf ($File.Name -like "*.ps1")
                {$Type = "PowerShell Script"}
            Else {$Type = "File"}
            ##

            #============================================
            #============== Collect Data ================
            $Result = "" | select Name,Size,Type,Lastwritetime,HiddenSize
            $Result.Name = $File.Name
            $Result.Size = $Size
            $Result.Type = $Type
            $Result.LastWriteTime = $File.LastWriteTime
            $Result.HiddenSize = $HiddenSize
            $Array += $Result
            }
            #============================================
            #============================================
        }

    # Empty location veriable before we exit, prevents issues with validation on re-use
    
    # Display the collected information
    If ($SortBySize -eq "Ascending")
        {$Array | Sort-Object HiddenSize | Select Name,Size,Type,Lastwritetime | Format-Table}
    ElseIf ($SortBySize -eq "Descending")
        {$Array | Sort-Object HiddenSize -Descending | Select Name,Size,Type,Lastwritetime | Format-Table}
    ElseIf ($Bypass -eq $True)
        {$Array}
    Else {$Array | Select Name,Size,Type,Lastwritetime | Format-Table}
    $Location = $Null
    $SortBySize = $Null
    $Bypass = $Null
    }
