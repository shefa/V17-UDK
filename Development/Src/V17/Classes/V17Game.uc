class  V17Game extends  UDKGame;

var DominantDirectionalLightMovable lightvar;
var int Day, Hour, Minute;
var int SomeInt;

event PlayerController Login(string Portal, string Options, const UniqueNetId UniqueId, out string ErrorMessage)
{
    local string InOpt;
   
    InOpt = ParseOption(Options, "PlayerType");
    if(InOpt != "")
    {
        SomeInt = int(InOpt);
         
    }
    return Super.Login(Portal, Options, UniqueId, ErrorMessage);
}
/*
event InitGame( string Options, out string ErrorMessage )
{
    local string InOpt;
   

     `log( "============================!!!!!!!!!!!!!!!!!!!!!!================== ");
     `log( "DO I GET THISSSSSS  "@SomeInt);
    
    InOpt = ParseOption(Options, "PlayerType");
    if(InOpt != "")
    {
        SomeInt = int(InOpt);
         `log( "============================!!!!!!!!!!!!!!!!!!!!!!================== ");
        `log( "YAHOUUU SOME INT PASSED MOFO  "@SomeInt);
    }
         super.InitGame(Options, ErrorMessage);
}
     */
function GenericPlayerInitialization(Controller C)
{
    // set the HUD as our custom HUD
    HUDType = class'V17.V17HUD';
    V17PlayerController(C).MyTypeOfPlayer=SomeInt;
    Super.GenericPlayerInitialization(C);
    V17PlayerController(C).CreateHud();
   
}


static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return Default.Class;
}

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
    if( KilledPlayer != None && KilledPlayer.bIsPlayer )
    {
        KilledPlayer.PlayerReplicationInfo.IncrementDeaths();
        KilledPlayer.PlayerReplicationInfo.SetNetUpdateTime(FMin(KilledPlayer.PlayerReplicationInfo.NetUpdateTime, WorldInfo.TimeSeconds + 0.3 * FRand()));
        BroadcastDeathMessage(Killer, KilledPlayer, damageType);
    }

    if( KilledPlayer != None )
    {
        ScoreKill(Killer, KilledPlayer);
    }

    //DiscardInventory(KilledPawn, Killer);
    NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);
}

exec function displaytime()
{
    lightvar.DisplayWorldTime();
}

exec function settime(int days, int hours, int minutes)
{
    lightvar.SetWorldTime(days,hours,minutes);
}
defaultProperties
 {
     //PawnArchetype=V17Pawn'v17.Archetypes.V17Pawn'
     //DefaultPawnClass = class 'V17.Chivalry_Char'
    DefaultPawnClass=class 'V17.FPS_Character'
    //PlayerControllerClass = class 'V17.V17PlayerController'
    PlayerControllerClass = class 'V17.V173rdPersonController'
     PlayerReplicationInfoClass=class'V17ReplicationInfo'
     HUDType=class'V17.V17HUD'
    
     SomeInt=0
 }