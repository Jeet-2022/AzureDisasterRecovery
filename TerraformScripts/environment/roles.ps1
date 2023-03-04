configuration InstallIIS {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node localhost {
        WindowsFeature IIS {
            Name = "Web-Server"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }
    }
}