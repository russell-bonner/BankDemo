properties([pipelineTriggers([githubPush()])])

// V101

node {
    environment {
     myJson = ''
	 responseCN = ''
	 responsemfError = ''
	 responsemfServerStatus = ''
    }

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */
	cleanWs()
	dir('GitHub\\BankDemo') {
		git branch: "v8.0",
		url: 'https://github.com/russell-bonner/BankDemo.git'
	}
    }

    stage('Create release folder structure') {  
    	dir('Release') {
		powershell '''
		New-Item -Path CSP_MVP_Pipeline_Release\\system -ItemType directory
		New-Item -Path CSP_MVP_Pipeline_Release\\system\\catalog -ItemType directory
		New-Item -Path CSP_MVP_Pipeline_Release\\system\\catalog\\data -ItemType directory
		New-Item -Path CSP_MVP_Pipeline_Release\\system\\loadlib -ItemType directory
		New-Item -Path CSP_MVP_Pipeline_Release\\system\\logs -ItemType directory
		New-Item -Path CSP_MVP_Pipeline_Release\\system\\rdef -ItemType directory
		'''
	}
    }

    stage('Pre-build Checks') {  
	//Logoff
	bat '''curl -X "DELETE" "http://127.0.0.1:10086/logoff" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With"'''

	//Logon
	bat '''curl -X POST "http://127.0.0.1:10086/logon" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With" -H "Content-Type: application/json" -d "@GitHub\\BankDemo\\config\\logon.json"'''

	powershell '''
	New-Item -Path Test -ItemType directory
	New-Item -Path Test\\logs -ItemType directory
	Try
	{

	 Invoke-WebRequest -Headers @{"X-Requested-With"="X-Requested-With";"Origin"="http://localhost:86";"Host"="localhost:86";"accept"="application/json";} http://127.0.0.1:10086/native/v1/regions/127.0.0.1/86/BANKVSAM/status -OutFile "Test\\logs\\status.json" | ConvertFrom-Json 
	 write-host "***************"
	 write-host "*--- ERROR ---*"
	 write-host "*"
	 write-host "* BANKVSAM region exists. Please DELETE."
	 write-host "*"
	 write-host "*-------------*"
	 write-host "***************"
	 exit 1
	}
	Catch
	{
	 write-host "**************"
	 write-host "*--- INFO ---*"
	 write-host "*"
	 write-host "* BANKVSAM region does NOT exist. Processing continues"
	 write-host "*"
	 write-host "*------------*"
	 write-host "**************"
	}
	'''
    }

    stage('Build') {
        dir('GitHub\\BankDemo\\scripts\\build') {
		powershell '''
		python MFBuild.py
		'''
		//archiveArtifacts artifacts: 'build.txt', fingerprint: true
	}
    }

    stage('Release') {
	//Create System Release folder structure
	powershell '''
	Copy-Item -Path "GitHub\\BankDemo\\datafiles\\*" -Destination "Release\\CSP_MVP_Pipeline_Release\\system\\catalog\\data"
	Copy-Item -Path "GitHub\\BankDemo\\cicsrdef\\dfhdrdat" -Destination "Release\\CSP_MVP_Pipeline_Release\\system\\rdef\\dfhdrdat"
	Compress-Archive -Path "Release\\CSP_MVP_Pipeline_Release\\system" -DestinationPath "Release\\CSP_MVP_Pipeline_Release_$env:BUILD_ID.zip"
	'''
	dir ('Release'){
		archiveArtifacts artifacts: '*.zip', fingerprint: true
	}
    }
     
    stage('Deploy') {
        dir('GitHub\\BankDemo\\config') {
		//Logoff
		bat '''curl -X "DELETE" "http://127.0.0.1:10086/logoff" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With"'''

		//Logon
		bat '''curl -X POST "http://127.0.0.1:10086/logon" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With" -H "Content-Type: application/json" -d "@logon.json"'''

		//IMPORT JSON
		bat '''curl -X POST "http://127.0.0.1:10086/native/v1/import/127.0.0.1/86" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With" -H "Content-Type: application/json" -d "@BANKVSAM.json"'''

		//Start BANKVSAM
		sleep 5
		bat '''curl -X POST "http://localhost:10086/native/v1/regions/127.0.0.1/86/BANKVSAM/start" -H "Cache-Control: no-cache" -H "Origin:http://localhost:86" -H "Host:localhost:86" -H "accept: application/json" -H "X-Requested-With: X-Requested-With" -H "Content-Type: application/json" -d "@start.json"'''
	}
    }
    
    stage('Test') {  
	sleep 5
	powershell '''
	Invoke-WebRequest -Headers @{"X-Requested-With"="X-Requested-With";"Origin"="http://localhost:86";"Host"="localhost:86";"accept"="application/json";} http://127.0.0.1:10086/native/v1/regions/127.0.0.1/86/BANKVSAM/status -OutFile "Test\\logs\\test_region_status.json" | ConvertFrom-Json  
	$env:myJson = Get-Content 'test\\logs\\test_region_status.json' | ConvertFrom-Json
	$env:responseCN = (Get-Content 'test\\logs\\test_region_status.json' | ConvertFrom-Json).CN
	$env:responsemfError = (Get-Content 'test\\logs\\test_region_status.json' | ConvertFrom-Json).mfError
	$env:responsemfServerStatus = (Get-Content 'test\\logs\\test_region_status.json' | ConvertFrom-Json).mfServerStatus

	if ($env:responsemfError = 'OKAY')
	{
	  write-host "**************"
	  write-host "*--- INFO ---*"
	  write-host "*"
	  write-host "* TEST PASSED"
	  write-host "* Region $env:responseCN is $env:responsemfError with status $env:responsemfServerStatus"
	  write-host "* $env:myJson"
	  write-host "*"
	  write-host "*------------*"
	  exit 0
	}else{
	  write-host "***************"
	  write-host "*--- ERROR ---*"
	  write-host "*"
	  write-host "* TEST FAILED"
	  write-host "* $env:myJson"
	  write-host "*"
	  write-host "*--------------*"
	  write-host "***************"
	  exit 1
	}
	'''
	archiveArtifacts artifacts: 'Test/logs/*.*', fingerprint: true	
    }
}
