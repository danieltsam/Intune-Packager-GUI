Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

[xml]$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        Title='IntuneWinAppUtil Packager' Height='500' Width='700'
        WindowStartupLocation='CenterScreen' Background='#f3f3f3' FontFamily='Segoe UI' FontSize='14'>
    <Grid Margin='20'>
        <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='*'/>
            <RowDefinition Height='Auto'/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width='150'/>
            <ColumnDefinition Width='*'/>
            <ColumnDefinition Width='Auto'/>
        </Grid.ColumnDefinitions>

        <Label Grid.Row='0' Grid.Column='0' Content='Setup Folder:' VerticalAlignment='Center' Margin='0,5'/>
        <StackPanel Grid.Row='0' Grid.Column='1' Orientation='Vertical'>
            <TextBox Name='SetupFolderTextbox' Margin='0,5' AllowDrop='True' Background='#ffffff' BorderBrush='#ccc'/>
            <TextBlock Text='(Drag and drop a folder here)' FontStyle='Italic' FontSize='12' Foreground='Gray'/>
        </StackPanel>
        <Button Grid.Row='0' Grid.Column='2' Content='Browse' Margin='5' Name='SetupFolderButton'/>

        <Label Grid.Row='1' Grid.Column='0' Content='Setup File:' VerticalAlignment='Center' Margin='0,5'/>
        <TextBox Grid.Row='1' Grid.Column='1' Name='SetupFileTextbox' Margin='0,5' Background='#ffffff' BorderBrush='#ccc'/>
        <Button Grid.Row='1' Grid.Column='2' Content='Browse' Margin='5' Name='SetupFileButton'/>

        <Label Grid.Row='2' Grid.Column='0' Content='Output Folder:' VerticalAlignment='Center' Margin='0,5'/>
        <TextBox Grid.Row='2' Grid.Column='1' Name='OutputFolderTextbox' Margin='0,5' Background='#ffffff' BorderBrush='#ccc'/>
        <Button Grid.Row='2' Grid.Column='2' Content='Browse' Margin='5' Name='OutputFolderButton'/>

        <Label Grid.Row='3' Grid.Column='0' Content='Catalog Folder (optional):' VerticalAlignment='Center' Margin='0,5'/>
        <TextBox Grid.Row='3' Grid.Column='1' Name='CatalogFolderTextbox' Margin='0,5' Background='#ffffff' BorderBrush='#ccc'/>
        <Button Grid.Row='3' Grid.Column='2' Content='Browse' Margin='5' Name='CatalogFolderButton'/>

        <Label Grid.Row='4' Grid.Column='0' Content='Log Output:' VerticalAlignment='Top' Margin='0,5'/>
        <RichTextBox Grid.Row='4' Grid.Column='0' Grid.ColumnSpan='3' Name='LogTextbox' Margin='0,5' Background='#ffffff' BorderBrush='#ccc'/>

        <StackPanel Grid.Row='5' Grid.Column='0' Grid.ColumnSpan='3' Orientation='Horizontal' HorizontalAlignment='Right'>
            <ProgressBar Name='ProgressBar' Width='200' Height='20' Margin='0,10,10,0'/>
            <Button Content='Run IntuneWinAppUtil' Background='#0078D4' Foreground='White' Padding='10,5' Margin='0,10,0,0' Name='RunButton'/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$setupFolderTextbox = $window.FindName('SetupFolderTextbox')
$setupFileTextbox = $window.FindName('SetupFileTextbox')
$outputFolderTextbox = $window.FindName('OutputFolderTextbox')
$catalogFolderTextbox = $window.FindName('CatalogFolderTextbox')
$logTextbox = $window.FindName('LogTextbox')
$progressBar = $window.FindName('ProgressBar')
$runButton = $window.FindName('RunButton')
$setupFolderButton = $window.FindName('SetupFolderButton')
$setupFileButton = $window.FindName('SetupFileButton')
$outputFolderButton = $window.FindName('OutputFolderButton')
$catalogFolderButton = $window.FindName('CatalogFolderButton')


# Set default values
$setupFileTextbox.Text = "Invoke-AppDeployToolkit.exe"
$outputFolderTextbox.Text = Join-Path $PWD "Intune Apps"
$catalogFolderTextbox.Text =

# Drag-and-drop support
$setupFolderTextbox.Add_PreviewDragOver({
    param($sender, $e)
    $e.Effects = [System.Windows.DragDropEffects]::Copy
    $e.Handled = $true
})
$setupFolderTextbox.Add_Drop({
    param($sender, $e)
    $data = $e.Data.GetData('FileDrop')
    if ($data.Count -eq 1 -and (Test-Path $data[0] -PathType Container)) {
        $setupFolderTextbox.Text = $data[0]
    } else {
        [System.Windows.MessageBox]::Show('Please drop a single folder.')
    }
})

# Folder pickers
$setupFolderButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $setupFolderTextbox.Text = $dialog.SelectedPath
    }
})
$outputFolderButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputFolderTextbox.Text = $dialog.SelectedPath
    }
})
$catalogFolderButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $catalogFolderTextbox.Text = $dialog.SelectedPath
    }
})

# File picker
$setupFileButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = 'Executable Files (*.exe)|*.exe|All Files (*.*)|*.*'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $setupFileTextbox.Text = $dialog.FileName
    }
})

# Run logic
$runButton.Add_Click({
    $setupFolder = $setupFolderTextbox.Text
    $setupFile = $setupFileTextbox.Text
    $outputFolder = $outputFolderTextbox.Text
    $catalogFolder = $catalogFolderTextbox.Text

    if (-not (Test-Path $outputFolder)) {
        New-Item -Path $outputFolder -ItemType Directory | Out-Null
    }

    $intuneWinAppUtilPath = Join-Path -Path $PWD -ChildPath 'IntuneWinAppUtil.exe'
    $args = "-c `"$setupFolder`" -s `"$setupFile`" -o `"$outputFolder`""
    if ($catalogFolder -ne '') {
        $args += " -catalog `"$catalogFolder`""
    }

    $progressBar.Value = 0
    $progressBar.Maximum = 100

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $intuneWinAppUtilPath
    $process.StartInfo.Arguments = $args
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.CreateNoWindow = $true
    $process.Start() | Out-Null

    while (-not $process.HasExited) {
        Start-Sleep -Milliseconds 100
        $progressBar.Value = ($progressBar.Value + 5) % 100
    }

    $output = $process.StandardOutput.ReadToEnd()
    $error = $process.StandardError.ReadToEnd()
    $logTextbox.AppendText("$output`n$error")

    $outputFile = Get-ChildItem -Path $outputFolder -Filter '*.intunewin' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($outputFile) {
        $newName = "$([System.IO.Path]::GetFileName($setupFolder)).intunewin"
        Rename-Item -Path $outputFile.FullName -NewName $newName -Force
        [System.Windows.MessageBox]::Show("Packaging complete! Output renamed to $newName.")
    } else {
        [System.Windows.MessageBox]::Show("Packaging complete, but no output file was found.")
    }

    $progressBar.Value = $progressBar.Maximum
})

$window.ShowDialog() | Out-Null
