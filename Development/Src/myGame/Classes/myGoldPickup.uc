class myGoldPickup extends myItemPickup
	ClassGroup(myGame)
	Placeable;

/** The amount of Gold coins contained in this stack */
var() int GoldAmount;

function GiveTo(Pawn P)
{
	local myPawn myP;

	myP = myPawn(P);
	if (myP != none && myInventoryManager(myP.InvManager) != none)
	{
		myInventoryManager(myP.InvManager).Gold += GoldAmount;
	}

	if (PickupSound != None)
	{
		PlaySound(PickupSound);
	}

	PickedUpBy(P);

	// update the inventory screen in case it's open
	if (myPlayerController(P.Controller) != None)
	{
		myHUD(PlayerController(P.Controller).myHUD).InventoryMovie.SetUpInventory();
	}
}

auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		// make sure its a live player
		if (Other == None || !Other.bCanPickupInventory || (Other.DrivenVehicle == None && Other.Controller == None))
		{
			return false;
		}

		// make sure thrower doesn't run over own weapon
		if ( (Physics == PHYS_Falling) && (Other == Instigator) && (Velocity.Z > 0) )
		{
			return false;
		}

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
		{
			SetTimer( 0.5, false, nameof(RecheckValidTouch) );
			return false;
		}

		return true;
	}
}

DefaultProperties
{
	Begin Object Name=Sprite
		Scale=0.25f
	End Object

	Begin Object Name=EditorMeshComp
		SkeletalMesh=SkeletalMesh'KismetGame_Assets.Pickups.SK_Carrot'
		Scale=0.35f
	End Object
	Mesh = EditorMeshComp;
	Components.Add(EditorMeshComp);

	PickupSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagPickedUp01Cue'

	LifeSpan=0.0
}
