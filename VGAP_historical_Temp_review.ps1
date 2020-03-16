
###
# Set variables
###
$PlanetsScanned = $null
$AverageTemp = $null
$PLanetsabove84 = $null
$PlanetsBelow15 = $null
$PercentHot = $null
$PercentCold = $null
$GamesScanned = 0

###
# Load Games
###
$PlanetTempListFull = @()
$GameIDs = (Invoke-PlanetsAPI '/games/list?Status=3&type=1,2,3,4,5,6').id
$TotalPlanetCount = 0

Foreach ($GameID in $GameIDs)
{
   $GameID
   ###
   # Get basic Game Info
   ###
   $GameInfo = Invoke-PlanetsAPI "/game/loadinfo?gameid=$GameID"
   ###
   # If the REST call pulled something back (it is a valid game), then proceed
   ###
   If ($Gameinfo.Success -ne $False)
   {
      $GamesScanned = $GamesScanned +1
      $PlanetTempList = @()
      $planetIDList = @()
      $playerCount = $gameinfo.Players.count
      $TotalPlayers = 1..$playerCount
      $totalPlanets = $gameinfo.Settings.numplanets
      $TotalPlanetCount = $TotalplanetCount + $TotalPlanets
      ###
      # Start scanning planets for each player
      ###
      Foreach ($PlayerID in $TotalPlayers)
      {
         "Checking player $PlayerID"
         ###
         # Load the last turn for the player.
         # If a player account no long exists, data will not be returned.
         # I have no idea what gets returned for a computer player.
         ###
         $loadturn = Invoke-PlanetsAPI "/game/loadturn?GameID=$GameID&PlayerID=$PlayerID"
         If ($Loadturn.success -ne $False)
         {
            ###
            # Load the info for all of the player planets (Scanned I believe)
            ###
            $LoadturnPlanets = $Loadturn.rst.planets
            Foreach ($Planet in $LoadturnPlanets)
            {
               ###
               # Grab Planet ID and Temprature
               ###
               $PlanetID = $planet.id
               $Temp = $planet.temp

               ###
               # Temp = -1 is the default for unscanned planets
               ###
               If ($Temp -ne -1)
               {
                  ###
                  # Check to see if this planet was already on the list and add if it was not
                  ###
                  $IsPlanetAlreadyOnList = $null
                  $IsPlanetAlreadyOnList = $PlanetIDList |? {$_ -like $planetID}
                  If (!($IsPlanetAlreadyOnList -ne $null))
                  {
                     $PlanetTempList += $Temp
                     $planetIDList +=$planetID
                  }
               }
            }
         }
      }
      ###
      # Add the list from this game to all the other games
      ###

      $PLanetTempListFull += $PlanetTemplist

      
   }
}

###
# Math the sdhit out of the data
###
$PlanetsScanned = $PlanetTempListFull.count
$AverageTemp = ($planettemplistfull |Measure-Object -Average).Average
$PLanetsabove84 = ($PlanetTempListFull |? {$_ -gt 84}).count
$PlanetsBelow15 = ($PlanetTempListFull |? {$_ -lt 15}).count
$PercentHot = $PLanetsabove84/$PlanetsScanned * 100
$PercentCold = $PlanetsBelow15/$PlanetsScanned * 100

###
# Results
###
"Total Games Scanned:`t`t`t$GamesScanned"
"Total Planets Scanned in all games:`t$PlanetsScanned"
"Avg Temp for all planets scanned:`t$AverageTemp"
"Percent of Planets above 84 degrees:`t$PercentHot"
"Percent of Planets below 15 degrees:`t$PercentCold"