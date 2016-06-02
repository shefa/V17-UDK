/*******************************************************************************
	TheHuntGame

	Creation date: 19/01/2010 22:24
	Copyright (c) 2010, Michael Allar

*******************************************************************************/

class TheHuntGame extends UDKGame;

var array< class<Inventory> > DefaultInventory;

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;
	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "New Player", true);
    return PC;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local int i;

	for (i=0; i<DefaultInventory.Length; i++)
	{
		// Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			// Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}
	}

	PlayerPawn.AddDefaultInventory();
}

defaultproperties
{
	DefaultPawnClass=class'UDKGame.HTPawn'
	PlayerControllerClass=class'UDKGame.HTPlayerController'

	PlayerReplicationInfoClass=class'UTGame.UTPlayerReplicationInfo'
	GameReplicationInfoClass=class'UTGame.UTGameReplicationInfo'

	//DefaultInventory(0)=class'UDKGame.HTWP_LittleBang'

	bRestartLevel=False
	bDelayedStart=False
	bUseSeamlessTravel=true

}
