class myGameInfo extends UTDeathmatch;

function GenericPlayerInitialization(Controller C)
{
	// set the HUD as our custom HUD
	HUDType = class'myGame.myHUD';
	Super(UDKGame).GenericPlayerInitialization(C);
}

// same as GameInfo's but without discarding the inventory
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

defaultproperties
{
	PlayerControllerClass=class'myGame.myPlayerController'
	DefaultPawnClass=class'myGame.myPawn'
	HUDType=class'myGame.myHUD'

	DefaultInventory(0)=None
}