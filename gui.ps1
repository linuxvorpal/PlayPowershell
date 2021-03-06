New-Window -Title "Create User" {
StackPanel -ControlName 'Create User' {
    StackPanel -Margin 5 -Orientation Horizontal {
        RadioButton "_Faculty" -Name UserType
        RadioButton "_Staff" -Name UserType
        RadioButton "St_udent" -Name UserType -IsChecked:$true
        RadioButton "_Other" -Name UserType
    }
    UniformGrid -Name UserInfo -Margin 5 -Columns 2 -Rows 5 {
        "First Name"
        TextBox -Name FirstName -Margin 2
        "Last Name"
        TextBox -Name Surname -Margin 2
        "User Name"
        TextBox -Name sAMAccountName -Margin 2
        "D.O.B."
        TextBox -Name DOB -Margin 2
        "Employee ID"
        TextBox -Name EmployeeID -Margin 2
    }
        
    New-ListView -Name People -ItemsSource {
        ## This one way to create initial data, but you'd want to query SQL, a CSV or ... whatever
        ## Please excuse the ridiculous PowerShell syntax for constructing generic collections:
        New-Object System.Collections.ObjectModel.ObservableCollection[PSObject](,([PSObject[]](&{
            ## These are the actual data:
            New-Object PSObject -Property @{ UserType = "Staff"; FirstName = "Joel"; Surname  = "Bennett";  sAMAccountName  = "Jaykul"; DOB = [DateTime]'1/2/34'; EmployeeID= 123456 }
            New-Object PSObject -Property @{ UserType = "Staff"; FirstName = "Laerte"; Surname  = "Junior";  sAMAccountName  = "LaerteSqlDBA"; DOB = [DateTime]'1/23/45'; EmployeeID= 123457 }
            New-Object PSObject -Property @{ UserType = "Staff"; FirstName = "Doug"; Surname  = "Finke";  sAMAccountName  = "dfinke"; DOB = [DateTime]'12/3/45'; EmployeeID= 123458 }
        })))
    } -View {
        # WPF ListViews have a "View" -- this one has a GridView:
        New-GridView -Columns {
            # With Five columns that are data bound:
            New-GridViewColumn -Header "First Name" -DisplayMember { Binding FirstName }
            New-GridViewColumn -Header "Last Name" -DisplayMember { Binding Surname }
            New-GridViewColumn -Header "User Name" -DisplayMember { Binding sAMAccountName }
            New-GridViewColumn -Header "Birth Date" -DisplayMember { Binding DOB }
            New-GridViewColumn -Header "Employee ID" -DisplayMember { Binding EmployeeID }
        }
    } -On_Load {
        # Add-EventHandler -Input $People -SourceType GridViewColumnHeader -EventName Click { 
        ## ShowUI apologizes for the mess: this is not necessary in our next release ##
        [System.Windows.RoutedEventHandler]$EventHandler = {                         ##
            Initialize-EventHandler                                                  ##
            $ErrorActionPreference = 'stop'                                          ##
        ## ShowUI apologizes for the mess: this is not necessary in our next release ##
    
        ## We'd like to be able to sort by clicking the ColumnHeaders: 
        if($_.OriginalSource -and $_.OriginalSource.Role -ne "Padding") {
            ## We need to sort by a PROPERTY of the objects in the gridview
            ## in our example, we can just use the path that we used for binding ...
            $Sort = $_.OriginalSource.Column.DisplayMemberBinding.Path.Path
            $direction = if($Sort -eq $lastSort) { "Descending" } else { "Ascending" }
            $lastSort = $Sort
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $People.ItemsSource )
            $view.SortDescriptions.Clear()
            try {
                $view.SortDescriptions.Add(( New-Object System.ComponentModel.SortDescription $Sort, $direction ))
            } catch { Write-Warning "Failed to sort.`n`n$($_|Out-String)" }
            $view.Refresh()
        }
       
        ## ShowUI apologizes for the mess: this is not necessary in our next release ##
            trap {                                                                   ##
                . Write-WPFError $_                                                  ##
                continue                                                             ##
            }                                                                        ##
        }                                                                            ##
        ## Hook the RoutedEvent from the grid headers by handling it on the ListView ##
        $People.AddHandler(                                                          ##
            [Windows.Controls.GridViewColumnHeader]::ClickEvent, $EventHandler)      ##
        ## ShowUI apologizes for the mess: this is not necessary in our next release ##
    }
    
    CheckBox -Margin 5 #If checked, enable the TextBox below -Margin 5
    TextBox -Name Description -Text "Enter an optional description here" -Margin 5
    Button "Add To List" -Margin 2 -On_Click {
        #$People.ItemsSource.Add(
        $NewUser = Get-UIValue $UserInfo
        $NewUser.UserType = $UserType.Content.Replace("_","")
        ## Add it to the ItemsSource (the data binding for the grid)
        $People.ItemsSource.Add((
            New-Object PSObject -Property $NewUser
        ))
    }  
} } -On_Closing {
    ## Output the ItemsSource (the whole collection)
    Set-UIValue $Window $People.ItemsSource
} -Show  # | New-QADUser ... or whatever