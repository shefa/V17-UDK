class V17InventoryManager extends InventoryManager;

var int Gold;
var int MaxSpaces;
var array<string> EquipSlots;



replication
{
    if(bNetDirty||bNetInitial) Gold;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName== 'Gold')
    {
        `log("0000000000000000000000000 meeeit geld"@Gold);
    }
    super.ReplicatedEvent(VarName);
}


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
        if (V17Inventory(Inv) != None)
        {
            // if the item isn't equipped, it's taking a backpack space
            if (EquipSlots.Find(V17Inventory(Inv).ItemSlot) == INDEX_NONE)
            {
                spaces += 1;
            }
        }
        else if (V17Weapon(Inv) != None)
        {
            // if the weapon isn't equipped, it's taking a backpack space
            if (EquipSlots.Find(V17Weapon(Inv).ItemSlot) == INDEX_NONE)
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
    PendingFire(0)=0
    PendingFire(1)=0
    
    Gold = 0

    MaxSpaces = 20
    
    bAlwaysRelevant=true

    EquipSlots[0]="slotWeapon"
    EquipSlots[1]="slotHelm"
    EquipSlots[2]="slotArmor"
    EquipSlots[3]="slotCloak"
    EquipSlots[4]="slotGloves"
    EquipSlots[5]="slotBracers"
    EquipSlots[6]="slotShoes"
}
