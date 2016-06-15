[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null

# Add-Type -AssemblyName "System.Windows.Forms"
# Add-Type -AssemblyName "System.Drawing"

# Load a xml file
function LoadXml ($filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("Testing_GUI.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

$CompName = $env:COMPUTERNAME
$object = New-Object -comObject Shell.Application  

$Form.ShowDialog() | Out-Null