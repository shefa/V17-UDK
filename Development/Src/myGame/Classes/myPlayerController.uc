class myPlayerController extends UTPlayerController;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// 3rd person view so we can see the armor :)
	SetBehindView(true);
}

exec function PrevWeapon()
{
	// disabled changing of weapons
}

exec function NextWeapon()
{
	// disabled changing of weapons
}

exec function ToggleInventory()
{
	myHUD(myHUD).ToggleInventory(!myHUD(myHUD).InventoryMovie.bMovieIsOpen);
}

defaultproperties
{
}