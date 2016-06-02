class myWeapon extends UTWeap_RocketLauncher_Content
	ClassGroup(myGame)
	placeable;

/** The slot inside the inventory, aka. where in the grid/character it's located */
var string ItemSlot;

/** The name of the Item */
var() string ObjectName;

/** The current durability of this item */
var() float Durability;
/** The max durability of this item */
var() float MaxDurability;

/** The money value of this item */
var() float Value;

/** Texture to display as icon in the inventory */
var() Texture2D InventoryTexture;

enum WeaponTypes
{
	Weapon_Gun<DisplayName=Gun>,
	Weapon_Sword<DisplayName=Sword>
};
var() WeaponTypes WeaponType;

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	// here we disable autoswitch for this weapon
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	local DroppedPickup Pickup;

	if( Instigator != None && Instigator.InvManager != None )
	{
		Instigator.InvManager.RemoveFromInventory(Self);
	}

	// if cannot spawn a pickup, then destroy and quit
	if( DroppedPickupClass == None || (DroppedPickupMesh == None && Mesh == None))
	{
		Destroy();
		return;
	}

	Pickup = Spawn(DroppedPickupClass,,, StartLocation);
	if( Pickup == None )
	{
		Destroy();
		return;
	}

	// here we set ourself to be the drop's Inventory var
	Pickup.Inventory = self;
	Pickup.InventoryClass = class;
	Pickup.Velocity = StartVelocity;
	if (Mesh != None)
		Pickup.SetPickupMesh(DroppedPickupMesh);
	Pickup.SetPhysics(PHYS_Falling);

	Instigator = None;
	GotoState('');
}

DefaultProperties
{
	DroppedPickupClass=class'myItemPickup'
}