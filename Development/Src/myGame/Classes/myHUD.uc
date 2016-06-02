class myHUD extends UTHUD;

var myGFxInventory InventoryMovie;

function InitInventory()
{
	if (InventoryMovie == None)
	{
		InventoryMovie = new class'myGFxInventory';
	}

	InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
	InventoryMovie.SetTimingMode(TM_Real);
	InventoryMovie.Start();

	// add a few ignore keys so we can still move, toggle the inventory or open a menu
	InventoryMovie.AddFocusIgnoreKey('Escape');
	InventoryMovie.AddFocusIgnoreKey('F10');
	InventoryMovie.AddFocusIgnoreKey('I');
	InventoryMovie.AddFocusIgnoreKey('W');
	InventoryMovie.AddFocusIgnoreKey('A');
	InventoryMovie.AddFocusIgnoreKey('S');
	InventoryMovie.AddFocusIgnoreKey('D');

	InventoryMovie.Advance(0.1f);
	ToggleInventory(false);
}

function ToggleInventory(optional bool bOpen)
{
	if ( InventoryMovie != None && !bOpen)
	{
		InventoryMovie.LootScreen(false, true);
		InventoryMovie.LootScreen(false, false);

		InventoryMovie.Close(false);
	}
	else
	{
		InventoryMovie.Start();
		InventoryMovie.SetUpInventory();

		// check if we're looting
		if (myPawn(PawnOwner) != None && myPawn(PawnOwner).LootedPawn != None && VSize2D(PawnOwner.Location - myPawn(PawnOwner).LootedPawn.Location) <= myPawn(PawnOwner).LootDistance)
		{
			InventoryMovie.SetUpLoot();
		}
	}
}

DefaultProperties
{
}
