class myInventoryManager extends UTInventoryManager;

var int Gold;
var int MaxSpaces;
var array<string> EquipSlots;

function bool HandlePickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if( InventoryChain == None )
	{
		return TRUE;
	}

	// prevent from picking up if there's no room in the backpack
	if (!HasInvSpace())
	{
		return FALSE;
	}
	return TRUE;
}

simulated function SwitchToBestWeapon( optional bool bForceADifferentWeapon )
{
	// with this we disable autoswitch
}

function OwnerDied()
{
	// disable destroying ourself when the owner died
}

// Get the amount of spaces used up in the backpack
function int GetUsedSpaces()
{
	local Inventory Inv;
	local int spaces;

	for( Inv=InventoryChain; Inv!=None; Inv=Inv.Inventory )
	{
		if (myInventory(Inv) != None)
		{
			// if the item isn't equipped, it's taking a backpack space
			if (EquipSlots.Find(myInventory(Inv).ItemSlot) == INDEX_NONE)
			{
				spaces += 1;
			}
		}
		else if (myWeapon(Inv) != None)
		{
			// if the weapon isn't equipped, it's taking a backpack space
			if (EquipSlots.Find(myWeapon(Inv).ItemSlot) == INDEX_NONE)
			{
				spaces += 1;
			}
		}
	}

	return spaces;
}

function bool HasInvSpace()
{
	// TO DO: in the future this should also check if we can store a pickup into an existing stack even if the inventory is full

	if (GetUsedSpaces() == MaxSpaces)
	{
		return false;
	}

	return true;
}

DefaultProperties
{
	Gold = 0

	MaxSpaces = 20

	EquipSlots[0]="slotWeapon"
	EquipSlots[1]="slotHelm"
	EquipSlots[2]="slotArmor"
	EquipSlots[3]="slotCloak"
	EquipSlots[4]="slotGloves"
	EquipSlots[5]="slotBracers"
	EquipSlots[6]="slotShoes"
}
