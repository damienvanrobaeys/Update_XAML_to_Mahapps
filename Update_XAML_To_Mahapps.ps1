#========================================================================
#
# Tool Name	: MDT Profile Generator
# Author 	: Damien VAN ROBAEYS
# Date 		: 08/06/2016
# Website	: http://www.systanddeploy.com/
# Twitter	: https://twitter.com/syst_and_deploy
#
#========================================================================

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("Update_XAML_To_Mahapps.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

#************************************************************************** PROJECT SOURCES PART ***********************************************************************************************
$Browse_Sources = $Form.findname("Browse_Sources") 
$Sources_Textbox = $Form.findname("Sources_Textbox") 
$Choose_XAML = $Form.findname("Choose_XAML") 
$Choose_PS1 = $Form.findname("Choose_PS1") 
#************************************************************************** GUI STYLE PART - THEME ***********************************************************************************************
$Choose_BaseLight = $Form.findname("Choose_BaseLight")
$Choose_BaseDark = $Form.findname("Choose_BaseDark")
#************************************************************************** GUI STYLE PART - ACCENT ***********************************************************************************************
$Accent_Red = $Form.findname("Accent_Red")
$Accent_Blue = $Form.findname("Accent_Blue")
$Accent_Yellow = $Form.findname("Accent_Yellow")
$Accent_Green = $Form.findname("Accent_Green")
$Accent_Purple = $Form.findname("Accent_Purple")
$Accent_Orange = $Form.findname("Accent_Orange")
$Accent_Lime = $Form.findname("Accent_Lime")
$Accent_Teal = $Form.findname("Accent_Teal")
$Accent_Cyan = $Form.findname("Accent_Cyan")
$Accent_Magenta = $Form.findname("Accent_Magenta")
$Accent_Pink = $Form.findname("Accent_Pink")
$Accent_Violet = $Form.findname("Accent_Violet")
$Accent_Indigo = $Form.findname("Accent_Indigo")
$Accent_Crimson = $Form.findname("Accent_Crimson")
$Accent_Brown = $Form.findname("Accent_Brown")
$Accent_Olive = $Form.findname("Accent_Olive")
$Accent_Sienna = $Form.findname("Accent_Sienna")
#************************************************************************** GUI STYLE PART - TESTING GUI BUTTON ***********************************************************************************************
$Testing_GUI = $Form.findname("Testing_GUI") 
#************************************************************************** UPDATE BUTTONS ***********************************************************************************************
$Update_XAML = $Form.findname("Update_XAML") 
$Update_PS1 = $Form.findname("Update_PS1") 
$Test_my_project = $Form.findname("Test_my_project")


########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		VARIABLES INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Global:String_Theme = "mytheme"	
$Global:String_Accent = "myaccent"	
$object = New-Object -comObject Shell.Application  
$Global:Current_Folder =(get-location).path 
$Global:Mahapps_sources = "$Current_Folder\mahhaps_sources\*"
$Global:XAML_file = "$Current_Folder\Testing_GUI.xaml"
$Global:XAML_file_txt = "$Current_Folder\Testing_GUI.txt"
$Global:Temp_XAML_file_txt = "$Current_Folder\Testing_GUI_temp.txt"

$Temp = $env:Temp
$Date = get-date -format "G"

If (test-path $XAML_file)
	{
		remove-item $XAML_file -force	
	}

If (test-path $Temp_XAML_file_txt)
	{
		remove-item $Temp_XAML_file_txt -force	
	}	
	

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
#************************************************************************** Browse project folder Button ***********************************************************************************************	
$Browse_Sources.Add_Click({		
	$folder = $object.BrowseForFolder(0, $message, 0, 0) 
	If ($folder -ne $null) 
		{ 		
			$global:Project_Folder = $folder.self.Path 
			$Sources_Textbox.Text = $Project_Folder
			$Global:Project_Folder_name = Split-Path -leaf -path $Project_Folder					
			$Global:Backup_Folder = $Temp + "\" + "Backup_$Project_Folder_name"    
			$Global:Log_File = "$Project_Folder\Mahapps_Upgrader_Log.log"
				
			If (test-path $Log_File)
				{
					remove-item $Log_File -force -recurse
				}
				
			New-Item $Log_File -type file
			Add-Content $Log_File "$Date - # POWERSHELL TO MAHAPPS UPGRADER"		
			Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"												
			If (test-path $Backup_Folder)
				{
					remove-item $Backup_Folder -force -recurse
					Add-Content $Log_File "$Date - An existing backup folder has been deleted"								
				}

			New-Item "$Backup_Folder" -type directory
			copy-item "$Project_Folder\*" $Backup_Folder -Exclude @($Backup_Folder) -recurse	
			Add-Content $Log_File "$Date - Your folder content $Project_Folder has been copied in $Backup_Folder"		
			Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"					
										
			$Global:Dir_Project_Folder = get-childitem $Project_Folder -recurse
			$List_All_PS1 = $Dir_Project_Folder | where {$_.extension -eq ".ps1"}				
			foreach ($ps1 in $List_All_PS1)
				{
					$Choose_PS1.Items.Add($ps1)	
					$Global:PS1_To_Run = $Choose_PS1.SelectedItem						
				}			
			$Choose_PS1.add_SelectionChanged({
			$Global:PS1_To_Run = $Choose_ps1.SelectedItem				
			})	
			
			
			$List_All_XAML = $Dir_Project_Folder | where {$_.extension -eq ".xaml"}				
			foreach ($xaml in $List_All_XAML)
				{
					$Choose_XAML.Items.Add($xaml)	
					$Global:XAML_To_Run = $Choose_XAML.SelectedItem						
				}			
			$Choose_XAML.add_SelectionChanged({
			$Global:XAML_To_Run = $Choose_XAML.SelectedItem		
			})								
			Add-Content $Log_File "$Date - Your project folder is $Project_Folder"					
			Add-Content $Log_File "$Date - The PS1 file to update is $PS1_To_Run"					
			Add-Content $Log_File "$Date - The XAML file to update is $XAML_To_Run"	
			
			# Copy the mahhaps pre-requisites assembly and ressources to your project	
			$Assembly_folder = "$Project_Folder\assembly"
			$Resources_folder = "$Project_Folder\resources"
			If (test-path $Assembly_folder)
				{
					remove-item $Assembly_folder -force -recurse
				}
			If (test-path $Resources_folder)
				{
					remove-item $Resources_folder -force -recurse
				}	
				
			copy-item $Mahapps_sources $Project_Folder -Recurse -Force
			Add-Content $Log_File "$Date - Mahapps folder resources and assembly have been copied"					
		}						
})	


#************************************************************************** Apply this style Button ***********************************************************************************************	
$Testing_GUI.Add_Click({		

	# Choose a Theme
	If($Choose_BaseLight.IsSelected -eq $true)
		{
			$My_theme = "BaseLight"	
		}
	ElseIf($Choose_BaseDark.IsSelected -eq $true)
		{
			$My_theme = "BaseDark"		
		}

	# Choose an Accent	
	If($Accent_Red.IsSelected -eq $true)
		{
			$Global:My_accent = "Red"	
		}
	ElseIf($Accent_Blue.IsSelected -eq $true)
		{
			$Global:My_accent = "Blue"			
		}	
	ElseIf($Accent_Yellow.IsSelected -eq $true)
		{
			$My_accent = "Yellow"			
		}	
	ElseIf($Accent_Green.IsSelected -eq $true)
		{
			$My_accent = "Green"			
		}		
	ElseIf($Accent_Purple.IsSelected -eq $true)
		{
			$My_accent = "Purple"			
		}		
	ElseIf($Accent_Orange.IsSelected -eq $true)
		{
			$My_accent = "Orange"			
		}
	ElseIf($Accent_Lime.IsSelected -eq $true)
		{
			$My_accent = "Lime"			
		}		
	ElseIf($Accent_Teal.IsSelected -eq $true)
		{
			$My_accent = "Teal"			
		}		
	ElseIf($Accent_Cyan.IsSelected -eq $true)
		{
			$My_accent = "Cyan"			
		}		
	ElseIf($Accent_Magenta.IsSelected -eq $true)
		{
			$My_accent = "Magenta"			
		}		
	ElseIf($Accent_Pink.IsSelected -eq $true)
		{
			$My_accent = "Pink"			
		}		
	ElseIf($Accent_Violet.IsSelected -eq $true)
		{
			$My_accent = "Violet"			
		}		
	ElseIf($Accent_Indigo.IsSelected -eq $true)
		{
			$My_accent = "Indigo"			
		}	
	ElseIf($Accent_Crimson.IsSelected -eq $true)
		{
			$My_accent = "Crimson"			
		}			
	ElseIf($Accent_Brown.IsSelected -eq $true)
		{
			$My_accent = "Brown"			
		}			
	ElseIf($Accent_Olive.IsSelected -eq $true)
		{
			$My_accent = "Olive"			
		}			
	ElseIf($Accent_Sienna.IsSelected -eq $true)
		{
			$My_accent = "Sienna"			
		}		

	# Test if xaml file already exist. If yes it'll be deleted
	If (test-path $XAML_file)
		{
			remove-item $XAML_file -force	
		}		
		
	# Copy the file Testing_GUI.txt and rename it as Testing_GUI_temp.txt	
	copy-item $XAML_file_txt $Temp_XAML_file_txt

	(Get-Content $Temp_XAML_file_txt) | ForEach-Object {
		$_.replace('mytheme', $My_theme).replace('myaccent', $My_accent)
	 } | Set-Content $XAML_file	
	sleep 5
	remove-item $Temp_XAML_file_txt -force
	powershell -sta .\Testing_GUI.ps1
})	



#************************************************************************** Update my XAML Button ***********************************************************************************************	
$Update_XAML.Add_Click({
	# This part will update your XAML file
	# 1 / It'll first copy your XAML as "Temp_yourXAML.xaml"
	# 2 / Then it'll add the corresponding part to use Mahapps
	# 3 / Finally, it'll rename your file as your original XAML file

	# Choose a Theme
	If($Choose_BaseLight.IsSelected -eq $true)
		{
			$My_theme = "BaseLight"	
		}
	ElseIf($Choose_BaseDark.IsSelected -eq $true)
		{
			$My_theme = "BaseDark"		
		}


	# Choose an Accent	
	If($Accent_Red.IsSelected -eq $true)
		{
			$My_accent = "Red"	
		}
	ElseIf($Accent_Blue.IsSelected -eq $true)
		{
			$My_accent = "Blue"			
		}	
	ElseIf($Accent_Yellow.IsSelected -eq $true)
		{
			$My_accent = "Yellow"			
		}	
	ElseIf($Accent_Green.IsSelected -eq $true)
		{
			$My_accent = "Green"			
		}		
	ElseIf($Accent_Purple.IsSelected -eq $true)
		{
			$My_accent = "Purple"			
		}		
	ElseIf($Accent_Orange.IsSelected -eq $true)
		{
			$My_accent = "Orange"			
		}
	ElseIf($Accent_Lime.IsSelected -eq $true)
		{
			$My_accent = "Lime"			
		}		
	ElseIf($Accent_Teal.IsSelected -eq $true)
		{
			$My_accent = "Teal"			
		}		
	ElseIf($Accent_Cyan.IsSelected -eq $true)
		{
			$My_accent = "Cyan"			
		}		
	ElseIf($Accent_Magenta.IsSelected -eq $true)
		{
			$My_accent = "Magenta"			
		}		
	ElseIf($Accent_Pink.IsSelected -eq $true)
		{
			$My_accent = "Pink"			
		}		
	ElseIf($Accent_Violet.IsSelected -eq $true)
		{
			$My_accent = "Violet"			
		}		
	ElseIf($Accent_Indigo.IsSelected -eq $true)
		{
			$My_accent = "Indigo"			
		}	
	ElseIf($Accent_Crimson.IsSelected -eq $true)
		{
			$My_accent = "Crimson"			
		}			
	ElseIf($Accent_Brown.IsSelected -eq $true)
		{
			$My_accent = "Brown"			
		}			
	ElseIf($Accent_Olive.IsSelected -eq $true)
		{
			$My_accent = "Olive"			
		}			
	ElseIf($Accent_Sienna.IsSelected -eq $true)
		{
			$My_accent = "Sienna"			
		}		
		
	Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"								
	Add-Content $Log_File "$Date - # UPDATE MY XAML PART"		
	Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"								
	Add-Content $Log_File "$Date - Your theme is: $My_theme"									
	Add-Content $Log_File "$Date - Your accent is: $My_accent"									
				
	# Copy the selected XAML file and rename it as Temp_yourxaml.xaml
	$Global:Your_Temp_XAML_file = "$Project_Folder\Temp_$XAML_To_Run"
	copy-item "$Project_Folder\$XAML_To_Run" $Your_Temp_XAML_file
	Add-Content $Log_File "$Date - The XAML temp file has been copied: Temp_$XAML_To_Run"										

	$xaml_xmlns_1 = 'xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" ' 
	$xaml_xmlns_mahapps = "`t`t" + 'xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"' 	

	# 1st test initialization: Looking for the "<Controls:MetroWindow" string in your XAML file	
	$XAML_MetroWindow_string = '<Controls:MetroWindow'
	$Search_MetroWindow_String = select-string $Your_Temp_XAML_file -Pattern $XAML_MetroWindow_string 
	$XAML_MetroWindow_string_Linenumber = $Search_MetroWindow_String.linenumber 			
	
	# 2nd test initialization: Looking for the "assembly=MahApps.Metro" string in your XAML file
	$XAML_Mahapps_string = "assembly=MahApps.Metro" 														
	$Search_XAML_mahapps_string = select-string $Your_Temp_XAML_file -Pattern $XAML_Mahapps_string 
	$XAML_Mahapps_string_Linenumber = $Search_XAML_mahapps_string.linenumber 			

	# 3rd test initialization: Looking for the "<ResourceDictionary.MergedDictionaries>" string in your XAML
	$XAML_ResourceDictionary_string = "<ResourceDictionary.MergedDictionaries>"														
	$Search_ResourceDictionary_string = select-string $Your_Temp_XAML_file -Pattern $XAML_ResourceDictionary_string 
	$XAML_ResourceDictionary_string_Linenumber = $Search_ResourceDictionary_string.linenumber 		
		
	# 4th test initialization: Looking for the "pack://application:,,,/MahApps.Metro;component/Styles/Accents/" string in your XAML file
	$XAML_Mahapps_Resources_string = "pack://application:,,,/MahApps.Metro;component/Styles/Accents/"														
	$Search_XAML_mahapps_Resources_string = select-string $Your_Temp_XAML_file -Pattern $XAML_Mahapps_Resources_string 
	$XAML_Mahapps_Resources_string_Linenumber = $Search_XAML_mahapps_Resources_string.linenumber 			
	
	# Window Resources to copy in your XAML file
	$xaml_windows_ressources_1 = "`t<Window.Resources>`n`t`t<ResourceDictionary>`n`t`t`t<ResourceDictionary.MergedDictionaries>"
	$xaml_windows_ressources_2 = "`t`t`t`t" + '<ResourceDictionary Source=".\resources\Icons.xaml"/>'
	$xaml_windows_ressources_3 = "`t`t`t`t" + '<ResourceDictionary Source=".\resources\custom.xaml"/>'
	$xaml_windows_ressources_4 = "`t`t`t`t" + '<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml"/>'
	$xaml_windows_ressources_5 = "`t`t`t`t" + '<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml"/>'
	$xaml_windows_ressources_6 = "`t`t`t`t" + '<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml"/>'
	$xaml_windows_ressources_7 = "`t`t`t`t" + '<ResourceDictionary Source="' + "pack://application:,,,/MahApps.Metro;component/Styles/Accents/" + "$My_accent.xaml" + '" />'
	$xaml_windows_ressources_8 = "`t`t`t`t" + '<ResourceDictionary Source="' + "pack://application:,,,/MahApps.Metro;component/Styles/Accents/" + "$My_theme.xaml" + '" />'
	$xaml_windows_ressources_9 = "`t`t`t</ResourceDictionary.MergedDictionaries>`n`t`t</ResourceDictionary>`n`t</Window.Resources>`n"
	$xaml_mahapps_ressources_All = ">`n`n$xaml_windows_ressources_1`n$xaml_windows_ressources_2`n$xaml_windows_ressources_3`n$xaml_windows_ressources_4`n$xaml_windows_ressources_5`n$xaml_windows_ressources_6`n$xaml_windows_ressources_7`n$xaml_windows_ressources_8`n$xaml_windows_ressources_9"
	$xaml_mahapps_ressources_Mahapps_components = "$xaml_windows_ressources_2`n$xaml_windows_ressources_3`n$xaml_windows_ressources_4`n$xaml_windows_ressources_5`n$xaml_windows_ressources_6`n$xaml_windows_ressources_7`n$xaml_windows_ressources_8"
	
	# 1/ Test if the "<Controls:MetroWindow " exists
	# If not "<Window" will be replaced with "<Controls:MetroWindow" and </Window> with "</Controls:MetroWindow>"
	If ($XAML_MetroWindow_string_Linenumber -ne $null) 															
		{
			Add-Content $Log_File "$Date - Mahapps seems to be already integrated in your XAML file"													
		}
	Else
		{ 	
			(Get-Content $Your_Temp_XAML_file) | ForEach-Object {
				$_.replace('<Window', '<Controls:MetroWindow').replace('</Window>', '</Controls:MetroWindow>')
			} | Set-Content $Your_Temp_XAML_file	
			Add-Content $Log_File "$Date - The controls:¨MetroWindow part has been added"																
		}
	
	
	# 2 / Test if the string "assembly=MahApps.Metro" exists in your XAML
	# If not it'll be added
	If ($XAML_Mahapps_string_Linenumber -ne $null) 															
		{
			Add-Content $Log_File "$Date - Mahapps seems to be already integrated in your XAML file"													
		}
	Else
		{ 																									
			(Get-Content $Your_Temp_XAML_file) | ForEach-Object {
				$_.replace(
				'xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"', 
				"$xaml_xmlns_1 `n$xaml_xmlns_mahapps")
			} | Set-Content $Your_Temp_XAML_file	
		}


	# 3 / Test if the string "<ResourceDictionary.MergedDictionaries>" exists in your XAML
	# If it already exists, test if Mahapps resources exists, if not it'll be added
	# If not it'll be added
	If ($XAML_ResourceDictionary_string_Linenumber -ne $null) 															
		{
			Add-Content $Log_File "A <ResourceDictionary.MergedDictionaries> part is already integrated in your XAML file"	
			If ($XAML_Mahapps_Resources_string_Linenumber -ne $null)
				{
					Add-Content $Log_File "$Date - Mahapps resources seems to be already integrated in your XAML file"																	
				}
			Else
				{
					(Get-Content $Your_Temp_XAML_file) | ForEach-Object {
						$_.replace(
						$XAML_ResourceDictionary_string, 
						"$XAML_ResourceDictionary_string`n$xaml_mahapps_ressources_Mahapps_components")
					} | Set-Content $Your_Temp_XAML_file							
				}
		}
	Else
		{ 			
			$resources_add = [regex]'>'
			$resources_add.Replace([string]::Join("`n", (gc $Your_Temp_XAML_file)), $xaml_mahapps_ressources_All, 1) | set-content $Your_Temp_XAML_file		
			Add-Content $Log_File "$Date - The resources Mahapps part has been added"	
		}
				
		remove-item "$Project_Folder\$XAML_To_Run" -force -recurse
		Add-Content $Log_File "$Date - The $XAML_To_Run file has been deleted"															
		copy-item $Your_Temp_XAML_file "$Project_Folder\$XAML_To_Run" -Recurse 		
		Add-Content $Log_File "$Date - The $Your_Temp_XAML_file file has been renamed as $XAML_To_Run"																
		remove-item $Your_Temp_XAML_file -force -recurse			
})


#************************************************************************** Update my PS1 Button ***********************************************************************************************	
$Update_PS1.Add_Click({
	# This part will update your PS1 file to add the Mahapps part
	# 1 / It'll first copy your PS1 as "Temp_yourXAML.xaml"
	# 2 / Then it'll add the corresponding part to use Mahapps
	# 3 / Finally, it'll rename your file as your original PS1 file

	Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"					
	Add-Content $Log_File "$Date - # UPDATE MY PS1 PART"	
	Add-Content $Log_File "------------------------------------------------------------------------------------------------------------------------------"					
	
	$Global:Your_PS1_file_temp = "$Project_Folder\Temp_$PS1_To_Run"
	copy-item "$Project_Folder\$PS1_To_Run" $Your_PS1_file_temp
	Add-Content $Log_File "$Date - The PS1 temp file has been copied: Temp_$PS1_To_Run"											
						
	$Mahapps_DLL = "MahApps.Metro.dll" 	
	$Search_Mahapps_DLL = select-string $Your_PS1_file_temp -Pattern $Mahapps_DLL | select LineNumber -first 1
	$PS1_Mahhaps_DLL_Linenumber = $Search_Mahapps_DLL.linenumber 
	$PS1_Mahhaps_DLL_Line = $Search_Mahapps_DLL.line 
	
	$PresentationFramework_To_Add = "[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')" 		
	$Presentation_Framework_String = "presentationframework"	
	$Search_Presentation_Framework_String = select-string $Your_PS1_file_temp -Pattern $Presentation_Framework_String | select LineNumber, Line -first 1
	$Presentation_Framework_Linenumber = $Search_Presentation_Framework_String.linenumber 

	$PS1_Mahapps_DLL_ToAdd = "[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll') | out-null" 		
	$Reflection_Assembly_String = "Reflection.assembly"	
	$Add_Type_Assembly_String = "Add-type AssemblyName"		
	$Search_Reflection_Assembly_String = select-string $Your_PS1_file_temp -Pattern $Reflection_Assembly_String | select LineNumber, Line -first 1
	$Search_Add_Type_Assembly_String = select-string $Your_PS1_file_temp -Pattern $Add_Type_Assembly_String | select LineNumber, Line -first 1	
	$Reflection_Assembly_Linenumber = $Search_Reflection_Assembly_String.linenumber 
	$Add_Type_Assembly_Linenumber = $Search_Add_Type_Assembly_String.linenumber 	
	$Reflection_Assembly_Line = $Search_Reflection_Assembly_String.line	
	$Add_Type_Assembly_Line = $Search_Add_Type_Assembly_String.line	
	
	function Insert-Content 
	{
		param ( [String]$Path )
		process {
		$( ,$_; Get-Content $Path -ea SilentlyContinue) | Out-File $Your_PS1_file_temp
		}
	}	
	
	If ($PS1_Mahhaps_DLL_Linenumber -ne $null)
		{
			Add-Content $Log_File "$Date - Mahapps is already integrated in your PS1 file"		
			If ($Presentation_Framework_Linenumber -ne $null)
				{
					Add-Content $Log_File "$Date - The presentationframework assembly is already integrated in your PS1 file"				
				}
			Else
				{
					Add-Content $Log_File "$Date - The presentationframework doesn't exist."								
					$PresentationFramework_To_Add | Insert-Content $Your_PS1_file_temp				
					Add-Content $Log_File "$Date - The presentationframework assembly has been integrated"								
				}
		}
	Else
		{	
			If ($Presentation_Framework_Linenumber -ne $null)
				{
					Add-Content $Log_File "$Date - The presentationframework assembly is already integrated in your PS1 file"				
				}
			Else
				{
					$PresentationFramework_To_Add | Insert-Content $Your_PS1_file_temp				
					Add-Content $Log_File "$Date - The presentationframework assembly has been integrated"								
				}
				
			If ($Reflection_Assembly_Linenumber -ne $null) 
				{
					(Get-Content $Your_PS1_file_temp) | ForEach-Object{$_.replace($Reflection_Assembly_Line, "$Reflection_Assembly_Line`n$PS1_Mahapps_DLL_ToAdd")} | Set-Content $Your_PS1_file_temp	
					Add-Content $Log_File "$Date - Mahapps has been integrated in your PS1 file"					
				}
			
			ElseIf ($Add_Type_Assembly_Linenumber -ne $null)
				{
					(Get-Content $Your_PS1_file_temp) | ForEach-Object{$_.replace($Add_Type_Assembly_Line, "$Add_Type_Assembly_Line`n$PS1_Mahapps_DLL_ToAdd")} | Set-Content $Your_PS1_file_temp	
					Add-Content $Log_File "$Date - Mahapps has been integrated in your PS1 file"					
				}
			Else
				{
					$PS1_Mahapps_DLL_ToAdd | Insert-Content $Your_PS1_file_temp
					Add-Content $Log_File "$Date - Mahapps has been integrated in your PS1 file"										
				}
								
		}

	remove-item "$Project_Folder\$PS1_To_Run" -force -recurse
	Add-Content $Log_File "$Date - The $PS1_To_Run file has been deleted"																
	copy-item $Your_PS1_file_temp "$Project_Folder\$PS1_To_Run" -Recurse 	
	Add-Content $Log_File "$Date - The $Your_PS1_file_temp file has been renamed as $PS1_To_Run"																
	remove-item $Your_PS1_file_temp -force -recurse	
})

#************************************************************************** Test my project Button ***********************************************************************************************	
$Test_my_project.Add_Click({
	powershell -sta ".\$Project_Folder\$PS1_To_Run"
	cd $Project_Folder
	powershell -sta ".\$PS1_To_Run"
})


# Show FORM
$Form.ShowDialog() | Out-Null

