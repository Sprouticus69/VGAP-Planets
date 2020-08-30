###
# Verify PSv3 or higher
###
$version = ((Get-Host | Select-Object Version).Version.major)
If ($Version -lt 3)
{
    'Powershell must be version 3 or higher'
    exit 
}

###
# Examples
###
<#
The below examples are basic powershell commands you can run to gather data from Planets.nu VGAP games. The data is readily available via the web client (or some other addons, but some of it is difficult to gather and summaries are not available. Additionally I have added some commands to let you do stuff that is not available via the web interface. Generally speaking all you need to get the data is the GameID, your username and password, or the playerID you wish to examine. Many of the commands are intended to review past games and will not ork well against running games. Others will work with running games but will only return data on your own games (which may or may not be userful). For those of you with powershell skills of your own, these funcitons/cmdlets may open up other data gathering options. If you want to dig into the properties of the various objects, I have outlined them in the remarks for each function. Some of these are available in the API documentaiton as well. 

 



Funciton Examples:


# Get Game Information Example - Want to access all the info on a game setup quickly? This is your cmdlet. This returns an object with all the game info. It is also used by several other funcitons to perform other tasks.
Syntax: Get-PlanetsGameinfo -GameID '338810'




# List the Scores of a specific game- Note, this lists ALL of the scores, by date. If you just want to see the current score, it will be at the end of the list. The charting funciton of the website uses this. A simple excel sheet could be setup to do the same. 
Get-PlanetsGameScore -GameID '338810'


NOTE: This is a prime example of where data analysis might be fun for some folks. Using the gameameinfo command to gather the player races and then combine with score data from lots of games might provide some insight on which races do better where in games. We all have our own experiences on this, but using this data against a larger data set could provide real insight into balance. Even better would be to somehow take the player experience into account to add that dimension to the data set.


# Enumerate Game Settings Example: Similar to the webpage, this will list the settings. This is primarily used in other Functions, but the settings data is available as needed. 
(Get-PlanetsGameInfo -GameID '338810).settings


# Pull Player Info Example
(Get-PlanetsGameInfo -GameID '338810').players


#find the player ID for a specific User in a specific game. Again, this is used primarily for other functions.
$GamePlayerInfo = (Get-PlanetsGameInfo -GameID '338810').players
($GamePlayerInfo| ? {$_.username -eq 'sprouticus'}).id




Other examples:

# The APIKey is used when connecting as a user. Think of it as a combo of your username and password.
$APIKey = Get-PlanetsAPIKey -UserName 'sprouticus' -Password 'notmypassword' 


# Userprofile is pretty self explanatory. 
Get-PlanetsUserProfile UserName 'sprouticus'


# User ID is an important value when digging into game data.
$UserID = $UserProfile.id




# Enumerate Game List - Here is a q1uick little script to list all the games a specific user is playing in currently.

   Get-PlanetsUserGameList $UserName
   Foreach ($Game in $gamelist)
   {
      $GameName = $Game.Name
      $GameID = $Game.ID
      "Game: $GameName"
      "ID: $GameID"
   }

# Pull Game Settings Example - This example converts the settings into a nice hash table and diaplays the hash. Useful for various steps when cloning games. 

$GameSettings = (Get-PlanetsGameInfo $GameID).settings.PsObject.Properties |Select Name,Value







# LoadTurn Example - Loafturn is the Big Kahuna This is how you get specific game data for a user turn (current or historical. When you open a turn this is what gets pulled. When you use the time machine it does the same, but with the 'turn' option. 

Syntax Options:
GameID, UserName, and Password are required.
TurnNumber is optional and can be any valid turnnumber from the game. 
GamePlayerID is optional, and is used for completed games. If you do not specific the GamePlayerID, the function will search for your turn. If a game is live you obviously cannot access the turn data from another player. 


$Loadturn = Get-PlanetsUserTurn -GameID '338810'  -UserName 'sprouticus' -Password 'notmypassword' -TurnNumber 1


# Loadturn RST: The RST property is where are the important data is stored. (lists of planets, ships, starbases, etc) 
$Loadturn = Get-PlanetsUserTurn -GameID '338810'  -UserName 'sprouticus' -Password 'notmypassword')
$LoadTurnRST= $loadturn.rst
###

###
# Pull Messages Example: There is an excel sheet that will export all messages from games. This 
###
$Loadturn = Get-PlanetsUserTurn -GameID '338810'  -UserName 'sprouticus' -Password 'notmypassword')
$LoadTurnRST= $loadturn.rst
$MyMessages= $loadTurnRST.myMessages


###
# Pull Build History from a completed game
###
Get-PlanetsBuildHistory -GameID $GameID -Username $UserName -password $Password -GamePlayerID $GamePlayerID


#>

Function Get-Distance([int]$X1,[int]$Y1,[int]$X2,[int]$Y2)
{
  $Deltax = [Math]::Pow(($x2 - $x1),2)
  $Deltay = [Math]::Pow(($Y2 - $Y1),2)
  $Distance= [Math]::SQRT($DeltaX + $DeltaY)
  $Distance = [Math]::Round($Distance,2)
  Return $Distance
}

Function Invoke-PlanetsAPI($URI)
{
$BaseURI ="http://api.planets.nu"
$FullURI = "$BAseURI$URI"
Invoke-RestMethod -uri $FullURI
}

Function Get-PlanetsAPIKey($UserName,$Password)
{
   ###
   # Login and get APIKey
   ###
   $Login = Invoke-PlanetsAPI "/account/login?username=$Username&password=$Password"
   $APIKey =$null
   If ($login.success -eq $True)
      {
       $APIKey = $login.apikey
      }Else
      { 
         $LoginError = $login.error
         "Unable to Login:"
         $LoginError
         #Exit
      }
      Return $APIKey
}

Function Get-PlanetsUserProfile($UserName)
{
   ###
   # Get User Profile info
   ###
   $UserProfile = (Invoke-PlanetsAPI "/account/loadprofile?username=$UserName").account
   
   Return $UserProfile
   ###
   # Profile Properties
   ###
   <#
   countryid          
   dateadded          
   description        
   finishtenacity     
   id                 
   imageurl           
   lastactivity       
   registereduntil    
   replacementtenacity
   tenacity           
   turns              
   turnsmissed        
   turntenacity       
   username
   #>
}

Function Get-PlanetsUserGameList($UserName)
{
   $Gamelist= Invoke-PlanetsAPI "/games/list?username=$UserName"
   Return $GameList
   ###
   # Game List Properties
   ###
   <#
   allturnsin      
   createdby       
   datecreated     
   dateended       
   deletedate      
   description     
   difficulty      
   faststart       
   gametype        
   haspassword     
   hostdays        
   hosttime        
   id              
   iscustom        
   ishosting       
   isprivate       
   justended       
   lastbackuppath  
   lasthostdate    
   lastloadeddate  
   lastnotified    
   maptype         
   masterplanetid  
   maxlevelid      
   mintenacity     
   name            
   nexthost        
   password        
   quadrant        
   requiredlevelid 
   scenarioid      
   shortdescription
   slots           
   slowhostdays    
   status          
   statusname      
   timetohost      
   turn            
   turnsperweek    
   turnstatus      
   tutorialid      
   wincondition    
   yearstarted     #>
}

Function Get-PlanetsGameInfo($GameID)
{
   $Gameinfo = Invoke-PlanetsAPI "/game/loadinfo?gameid=$GameID"
   Return $GameInfo
   ###
   # Game info Properties
   ###
   <#
   Events
   game        
   haspassword 
   interest    
   players     
   relations   
   schedule    
   settings    
   timetohost  
   wincondition
   yearfrom    
   yearto     
   #>
}


Function Get-PlanetsGameScores($GameID)
{
   $GameScores = (Invoke-PlanetsAPI "/game/loadscores?gameid=$gameID").scores|Format-Table
   Return $GameScores
   ###
   # Loadscores properties
   ###
   <#
   Scores
   #>
   
   ###
   # LoadScores.Scores Properties
   ###
   <#
   accountid     
   capitalships  
   dateadded     
   freighters    
   id            
   inventoryscore
   militaryscore 
   name          
   ownerid       
   percent       
   planets       
   prioritypoints
   starbases     
   turn          
   #>
}

Function Get-PlanetsGameStatus($GameID)
{
   $status = (Get-PlanetsGameInfo $GameID).game.statusname
   Return $Status
}

Function Get-PlanetsUserTurn($GameID,$UserName,$Password,$TurnNumber,$GamePlayerID)
{
   $Loadturn = $null
   ###
   # Create URI based upon available variables
   ###
   $URI = "/game/loadturn?GameID=$GameID"
   If ($userName -and $Password)
   {
           $APIKey = Get-PlanetsAPIKey -UserName $UserName -Password $Password
           $URI = "$URI&APIKey=$APIKey" 
   }
   $GamePlayerInfo = (Get-PlanetsGameInfo $GameID).players
   If ($GamePlayerID -eq $null)
   {
      $GamePlayerID = ($GamePlayerInfo| Where-Object {$_.username -eq $Username}).id
      If ($GameplayerID -eq $null)
      {
         Return
         'This player is not part of this game. Please use the GamePlayerID value'
      }

   }
   $URI = "$URI&PlayerID=$GamePlayerID"
   if ($TurnNumber)
   {
      $URI ="$URI&Turn=$TurnNumber"
   }
   $URI
   $LoadTurn = Invoke-PlanetsAPI $URI
   Return $LoadTurn
   ###
   # Loadturn properties
   ###
   <#
   accountsettings
   ispremium      
   rst            
   savekey        
   success
   #>
}


Function Get-PlanetsPlayerMessages($GameID,$UserName,$Password,$Filepath)
{
   $GameStatus = Get-PlanetsGameStatus -GameID $GameID
   If ($GameStatus -ne 'Finished')
   {
      "Status: $Gamestatus"
      'Game not complete, Message History cannot be conmplied'
      Return
   }
   $Players = (Get-PlanetsUserTurn -GameID $GameID -GamePlayerID 1 -turnnumber 1).rst.players
   $PlayerIDs = $Players.id
   $Messages = @()
   $output = @()
   Foreach ($PlayerID in $playerIDs) 
   {
      
      "Processing Player: $PlayerID"
      $Loadturn = Get-PlanetsUserTurn -GameID $GameID  -GamePlayerID $PlayerID #-UserName $UserName -Password $Password
      $MyMessages= $loadturn.rst.mymessages
      $Messages += $Mymessages
   }
   # Add Names
   # NOTE The Name list is bsed upon the beginning players and does not reflect replacements. I have not figured out a quick way to do that
   Foreach ($Message in $Messages)
   {
      $SendingPlayerName = ($Players| Where-Object {$_.id -eq $Message.ownerID}).Username
      $TargetPlayerName = ($Players| Where-Object {$_.id -eq $Message.Target}).Username
      $Message |Add-member -MemberType NoteProperty -Name 'Sender' -Value $SendingPlayerName
      $Message |Add-member -MemberType NoteProperty -Name 'Recipient' -Value $TargetPlayerName
      $Output += $Message
   }
   If ($FilePath)
   {
      $SaveFileName = $loadturn.rst.game.name
      $Output |Export-csv "$FilePath\$SaveFileName.csv" -NoTypeInformation
   }
   Return $Output
}

Function Get-PlanetsPlanetInfo($GameID,$UserName,$Password)
{
   $APIKey = Get-PlanetsAPIKey -UserName $UserName -Password $Password
   $LoadTurn = Invoke-PlanetsAPI "/game/loadturn?GameID=$GameID&APIKey=$APIKey"
   Return $LoadTurn.rst.planets
   ###
   # Loadturn properties
   ###
   <#
   accountsettings
   ispremium      
   rst            
   savekey        
   success
   #>

   ###
   # loadturn.RST Properties
   ###
   <#
activebadges
advantages  
artifacts   
badgechange 
beams       
cutscenes   
engines     
game        
hulls       
ionstorms   
maps        
messages    
minefields  
mymessages  
nebulas     
notes       
planets     
player      
players     
racehulls   
races       
relations   
scores      
settings    
ships       
starbases   
stars       
stock       
torpedos    
vcrs        
wormholes  
#>

   ###
   # Loadturn.rst.planets properties
   ###
   <#buildingstarbase    
builtdefense        
builtfactories      
builtmines          
burrowsize          
checkduranium       
checkmegacredits    
checkmolybdenum     
checkneutronium     
checksupplies       
checktritanium      
clans               
colchange           
colhappychange      
colonisthappypoints 
colonisttaxrate     
debrisdisk          
defense             
densityduranium     
densitymolybdenum   
densityneutronium   
densitytritanium    
duranium            
factories           
flag                
friendlycode        
groundduranium      
groundmolybdenum    
groundneutronium    
groundtritanium     
id                  
img                 
infoturn            
larva               
larvaturns          
megacredits         
mines               
molybdenum          
name                
nativechange        
nativeclans         
nativegovernment    
nativegovernmentname
nativehappychange   
nativehappypoints   
nativeracename      
nativetaxrate       
nativetaxvalue      
nativetype          
neutronium          
ownerid             
podcargo            
podhullid           
podspeed            
readystatus         
supplies            
suppliessold        
targetdefense       
targetfactories     
targetmines         
targetx             
targety             
temp                
totalduranium       
totalmolybdenum     
totalneutronium     
totaltritanium      
tritanium           
x                   
y                   
#>
}


Function Get-PLanetsHomeworlds ($GameID,$UserName,$Password)
{
   ###
   # Gather HW Planet Serttings
   ###
   $GameSettings = (Get-PlanetsGameInfo -GameID $GameID).Settings
   $minPlanetsWithin81LY = $GameSettings.verycloseplanets
   $minplanetsWithin162LY = $GameSettings.closeplanets
   $OtherPlanetMinimumDistance = $GameSettings.otherplanetsminhomeworlddist

   ###
   # Get planet name, ID, X and Y coordinates
   ### 
   $planets = (Get-PlanetsPlanetInfo -GameID $GameID -UseRName $UserName -Password $Password) | Select-Object ID,X,Y
     
   ###
   # Determine distance from plant X to plant Y
   ###
   $null = $planets.count
   $PlanetstoReview = @()
   Foreach ($Sourceplanet in $Planets)
   {
      $SourcePlanetID= $SourcePlanet.id
      $SourcePlanetX = $SourcePlanet.x
      $SourcePlanetY = $SourcePlanet.y
   
   
      ###
      # Get distance from all planets
      ###
   
      Foreach ($DestinationPlanet in $Planets)
      {
         $DestinationPlanetID = $DestinationPlanet.ID
         $DestinationPlanetX = $DestinationPlanet.X
         $DestinationplanetY = $DestinationPlanet.Y
         $SourceToDestinationDistance = Get-Distance $SourcePlanetX $SourcePlanetY $DestinationPlanetX $DestinationplanetY
         ###
         # If two planets are within 162 LY of one another, add to the array
         ###
         If (($SourceToDestinationDistance -le 162) -and ($SourceToDestinationDistance -ne 0))
         {
            "$SourcePlanetID to $DestinationPlanetID : $SourceToDestinationDistance"
            $Planetinfo = [PSCustomObject]@{ SourcePlanetID = $SourcePlanetID; DestinationPlanetID = $DestinationPlanetID; Distance = $SourceToDestinationDistance}
            #"The distance from $SourcePlanetID ID to $DestinationPlanetID is $SourcetoDestinationDistance"
            $PlanetstoReview += $PlanetInfo
         }   
      }
   }
   

   ###
   # Determine which planets qualify
   ###
   Foreach ($Sourceplanet in $Planets)
   {
      $OneTurnPlanets =  0
      $TwoTurnPlanets = 0
      $EdgePlanets = 0
      $SourcePlanetID= $SourcePlanet.id
      
      $Planets0to81 = $PlanetstoReview | Where-Object {($_.SourceplanetID -eq $SourcePlanetID) -and ($_.Distance -gt 0) -and ($_.Distance -le 81)} |Sort-Object Distance
      $Planets81to162 = $PlanetstoReview | Where-Object {($_.SourceplanetID -eq $SourcePlanetID) -and ($_.Distance -gt 81) -and ($_.Distance -lt 162)} |Sort-Object Distance
      $planets155to162 = $PlanetstoReview | Where-Object {($_.SourceplanetID -eq $SourcePlanetID) -and ($_.Distance -gt $OtherPlanetMinimumDistance) -and ($_.Distance -le 162)} |Sort-Object Distance
      $OneTurnPlanets = $planets0to81.count
      $TwoTurnPlanets = $Planets81to162.count
      $EdgePlanets = $planets155to162.count
      If ($EdgePlanets -eq $null) {$EdgePlanets = 0}
   
      If ( ($OneTurnPlanets -eq $minPlanetsWithin81LY) -and (($TwoturnPlanets-ge $minplanetsWithin162LY) -and (($TwoTurnPlanets - $EdgePlanets) -le $TwoTurnPlanets) ))
      {
         "-------------"
         "Planet: $SourcePlanetID"
         "Planets within 81 LY: $OneTurnPlanets"
         "Planets 81 to 162: $TwoTurnPlanets"
         "Planets 155 to 162: $EdgePlanets"
      }
   }


}


Function Compare-PlanetsSettings ($GameID,$GameType,$BaselineGameID)
{
   $GameSettings = (Get-PlanetsGameInfo -GameID $GameID).Settings
   ###
   # Select Baseline
   ###
   If ($baselineGameID)
   {
      $BaselineGameSettings = (Get-PlanetsGameInfo -GameID $BaselineGameID).Settings
   }
   Else
   {
      If ($Gametype -notmatch 'Standard|Calssic|Championship|Campaign|Training|Beginner')
      {
        $Options = [Management.Automation.Host.ChoiceDescription[]] @("&Standard","&Calssic","C&hamionship","C&ampaign","&Training","B&eginner")
        $Title = 'GameType'
        $Message = 'Select Baseline GameType'
        $Gametype = $host.ui.PromptForChoice($title, $message, $options, 0)
      }
      [pscustomobject]$BaselineGameSettings = Switch ($GameType){
      0   #Standard
      {
        [pscustomobject]@{  name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 3:51:29 PM"
            hostcompleted                  = "3/10/2020 3:51:31 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "1.88"
            duraniumlevel                  = "1.16"
            tritaniumlevel                 = "1.78"
            molybdenumlevel                = "1.17"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "0"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "True"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "False"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "False"
            nowarpwells                    = "False"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            } 
      }
      1   #Classic
      {
        [pscustomobject]@{  name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 4:20:32 PM"
            hostcompleted                  = "3/10/2020 4:20:34 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "2.13"
            duraniumlevel                  = "1.3"
            tritaniumlevel                 = "1.7"
            molybdenumlevel                = "1.51"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "False"
            starbasefightertransfer        = "False"
            superspyadvanced               = "False"
            cloakandintercept              = "False"
            quantumtorpedos                = "False"
            galacticpower                  = "False"
            shiplimittype                  = "0"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "False"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "False"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "False"
            nowarpwells                    = "False"
            directtransfermc               = "False"
            directtransferammo             = "False"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            }
      }
      2   #Championship
      {
        [pscustomobject]@{  name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "0"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 4:35:29 PM"
            hostcompleted                  = "3/10/2020 4:35:31 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "1.75"
            duraniumlevel                  = "1.53"
            tritaniumlevel                 = "1.66"
            molybdenumlevel                = "1.34"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "0"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "True"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "False"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "False"
            nowarpwells                    = "False"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            }
      }
      3   #Campaign
      {
        [pscustomobject]@{  name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 4:13:01 PM"
            hostcompleted                  = "3/10/2020 4:13:03 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "2.22"
            duraniumlevel                  = "1.46"
            tritaniumlevel                 = "1.77"
            molybdenumlevel                = "1.33"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "True"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "0"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "True"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "False"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "False"
            nowarpwells                    = "False"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            }
      }
      4   #Training
      {
         [pscustomobject]@{ name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 4:03:12 PM"
            hostcompleted                  = "3/10/2020 4:03:14 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "2.07"
            duraniumlevel                  = "1.35"
            tritaniumlevel                 = "1.58"
            molybdenumlevel                = "1.19"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "1"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "False"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "True"
            unlimitedammo                  = "True"
            nominefields                   = "True"
            nosupplies                     = "True"
            nowarpwells                    = "True"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "5,6,7,12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            }
      }
      5   #Beginner
      {
         [pscustomobject]@{ name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/9/2020 4:13:30 PM"
            hostcompleted                  = "3/9/2020 4:13:32 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "1.99"
            duraniumlevel                  = "1.28"
            tritaniumlevel                 = "1.56"
            molybdenumlevel                = "1.29"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "1"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "False"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "True"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "True"
            nowarpwells                    = "False"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "5,7,12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            }
      }
      
      default  # No selection Made, standard is default.
      {
        @{  name                           = "default"
            turn                           = "1"
            buildqueueplanetid             = "0"
            victorycountdown               = "0"
            maxallies                      = "1"
            maxshareintel                  = "35"
            maxsafepassage                 = "35"
            alliessharefullinfo            = "False"
            mapwidth                       = "1412"
            mapheight                      = "1412"
            numplanets                     = "300"
            shiplimit                      = "500"
            hoststart                      = "3/10/2020 3:51:29 PM"
            hostcompleted                  = "3/10/2020 3:51:31 PM"
            nexthost                       = "1/1/0001 12:00:00 AM"
            lastinvite                     = "1/1/0001 12:00:00 AM"
            teamsize                       = "0"
            planetscanrange                = "10000"
            shipscanrange                  = "300"
            allvisible                     = "False"
            minefieldsvisible              = "False"
            nebulas                        = "0"
            stars                          = "0"
            maxwormholes                   = "0"
            wormholemix                    = "80"
            wormholescanrange              = "100"
            discussionid                   = ""
            nuionstorms                    = "False"
            maxions                        = "4"
            maxioncloudsperstorm           = "10"
            debrisdiskpercent              = "50"
            debrisdiskversion              = "2"
            cloakfail                      = "0"
            structuredecayrate             = "3"
            mapshape                       = "1"
            verycloseplanets               = "3"
            closeplanets                   = "10"
            nextplanets                    = "0"
            otherplanetsminhomeworlddist   = "155"
            ncircles                       = "5"
            hwdistribution                 = "2"
            ndebrisdiscs                   = "0"
            levelid                        = "0"
            nextlevelid                    = "0"
            storyid                        = "0"
            killrace                       = "False"
            runningstart                   = "0"
            deadradius                     = "81"
            playerselectrace               = "True"
            militaryscorepercent           = "65"
            hideraceselection              = "False"
            fixedstartpositions            = "False"
            shuffleteampositions           = "False"
            minnativeclans                 = "1000"
            maxnativeclans                 = "75000"
            nohomeworld                    = "False"
            homeworldhasstarbase           = "True"
            homeworldclans                 = "25000"
            homeworldresources             = "3"
            gamepassword                   = ""
            extraplanets                   = "0"
            extraships                     = "0"
            centerextraplanets             = "0"
            centerextraships               = "0"
            extraplanetsrandomloc          = "False"
            extrashipsrandomloc            = "False"
            wanderingtribescount           = "0"
            wanderingtribesdist            = "0"
            neutroniumlevel                = "1.88"
            duraniumlevel                  = "1.16"
            tritaniumlevel                 = "1.78"
            molybdenumlevel                = "1.17"
            averagedensitypercent          = "55"
            developmentfactor              = "1"
            nativeprobability              = "55"
            nativegovernmentlevel          = "2"
            neusurfacemax                  = "250"
            dursurfacemax                  = "40"
            trisurfacemax                  = "50"
            molsurfacemax                  = "25"
            neugroundmax                   = "700"
            durgroundmax                   = "500"
            trigroundmax                   = "500"
            molgroundmax                   = "200"
            computerbuildships             = "True"
            computerbuilddelay             = "0"
            computerreplacedrops           = "False"
            fightorfail                    = "0"
            fofincrement                   = "5"
            fofbyteam                      = "False"
            stealthmode                    = "False"
            sphere                         = "False"
            showallexplosions              = "True"
            highidfixchunnelusepodhullid   = "False"
            highidfixfightertransferoffset = "0"
            campaignmode                   = "False"
            maxadvantage                   = "500"
            fascistdoublebeams             = "True"
            starbasefightertransfer        = "True"
            superspyadvanced               = "True"
            cloakandintercept              = "True"
            quantumtorpedos                = "True"
            galacticpower                  = "True"
            shiplimittype                  = "0"
            plsminships                    = "20"
            plsextraships                  = "0"
            plsshipsperplanet              = "1"
            productionqueue                = "True"
            productionbasecost             = "1"
            productionstarbaseoutput       = "2"
            productionstarbasereward       = "2"
            planetaryproductionqueue       = "False"
            fcodesrbx                      = "False"
            ppqminbuilds                   = "10"
            endturn                        = "100"
            maxplayersperrace              = "10"
            crystalwebimmunity             = "0"
            fcodesmustmatchgsx             = "False"
            fcodesextraalchemy             = "False"
            fcodesbdx                      = "False"
            cloningenabled                 = "True"
            unlimitedfuel                  = "False"
            unlimitedammo                  = "False"
            nominefields                   = "False"
            nosupplies                     = "False"
            nowarpwells                    = "False"
            directtransfermc               = "True"
            directtransferammo             = "True"
            topadvancecount                = "1"
            snapgridsize                   = "0"
            dumppartsdumpstorps            = "False"
            burrowsimprovemining           = "False"
            isacademy                      = "False"
            acceleratedturns               = "3"
            disallowedraces                = "12"
            emorkslegacy                   = "False"
            combatrng                      = "0"
            chainedintercept               = "False"
            randomplayerslots              = "False"
            id                             = "0"
            } 
      }
  
   }

   }
   ###
   # Determine Differences
   ###
   $Summary = new-Object PSObject
   $Summary = @()
   Foreach ($Setting in $GameSettings.psobject.properties)
   {
      $SettingName = $Setting.Name
      $SettingValue = $Setting.Value
      $BaselineValue = $BaselineGamesettings.$SettingName
      If ($settingValue.tostring() -ne  $BaselineValue)
      {
         If (($SettingName -ne 'name') -and ($SettingName -ne 'turn') -and ($SettingName -ne 'hoststart') -and ($SettingName -ne 'hostcompleted') -and ($SettingName -ne 'lastinvite') -and ($SettingName -ne 'hostcompleted'))
         {
            $Item = New-Object PSObject |
            Add-Member -Type NoteProperty -Name 'SettingName' -Value $SettingName -Passthru |
            Add-Member -Type NoteProperty -Name 'BaselineValue' -Value $BaselineValue -Passthru |
            Add-Member -Type NoteProperty -Name 'NewGameValue' -Value $SettingValue -Passthru
            $Summary += $Item
         }
      }
   }
Return $Summary
}


Function Get-PlanetsBuildHistory ($GameID,$UserName,$Password,$GamePlayerID,$FilePath)
{
   $Filepath
   ###
   # Check if the game has ended
   ###
   $status = Get-PlanetsGameStatus -GameID $GameID
   If ($status -ne 'Finished')
   {
      'Game not complete, Build History cannot be conmplied'
      Return
   }
   ###
   # Get game ship info
   ###
   $GameData = Get-PlanetsUserTurn -GameID $GameID -UserName $UserName -Password $Password -Turn 1 -GamePlayerID $GamePlayerID
   $Hulls = $GameData.rst.hulls
   $Engines = $GameData.rst.engines
   $Beams = $GameData.rst.beams
   $Torpedos = $GameData.rst.Torpedos
   $Planets = $GameData.rst.planets |Select-Object Name,ID
   $LastTurn = (Get-PlanetsGameInfo $GameID).Settings.turn

   ###
   # Gather SB Build info for each turn for this player
   ###
   $TurnNumber = $null
   $buildinfo = $null
   $BuildInfo = @()
   For ($TurnNumber=1;$TurnNumber -le $Lastturn;$TurnNumber++) 
   {
      " Processing Turn: $TurnNumber"
      $Turn = $null
      $Starbases = $null
      $Turn = Get-PlanetsUserTurn -GameID $GameID -UserName $UserName -Password $Password -Turn $TurnNumber -GamePlayerID $GamePlayerID
      $Starbases = $Turn.rst.starbases |Where-Object {$_.isbuilding -eq $True}
      If ($Starbases)
      {
         $Starbase = $null
         Foreach ($Starbase in $Starbases)
         {
            $SBBuild = New-Object PSObject -Property `
            @{
               Turn = $TurnNumber
               Planet = ($Planets |Where-Object {$starbase.PlanetID -eq $_.id}).Name
               PLanetID = $Starbase.PlanetID
               StarbaseHull = ($Hulls |Where-Object { $Starbase.BuildhullID -eq  $_.id}).Name
               Engines = ($Engines |Where-Object { $Starbase.BuildEngineID -eq  $_.id}).Name
               Beams = ($Beams | Where-Object { $Starbase.BuildBeamID -eq  $_.id}).Name
               BeamCount = $Starbase.BuildBeamCount
               TorpedoLauncher = ($Torpedos | ? { $Starbase.BuildTorpID -eq  $_.id}).Name
                TorppedoLauncherCount = $Starbase.BuildTorpCount
            }
            $Output += $SBBuild
         }
      }
   }
   ###
   # Export to CSV if desired
   ###
   If ($FilePath)
   {
      $SaveFileName = "$GameID-$GameplayerID"
      $Output | Export-csv "$Filepath\$SaveFileName.csv" -NoTypeInformation
      "Exported $SaveFileName.csv to $Filepath"
   }
   Return $Buildinfo 
}
##################################################################################################################
###
# Set variables
###
$Username= read-host 'Enter your planets Nu username'
$Password = read-host 'Enter your planets Nu password here'
$GameID = read-host 'Enter GameID'





