class V17Inventory extends Inventory
    ClassGroup(V17Game)
    placeable;

/** The slot inside the inventory, aka. where in the grid it's located */
var repnotify string ItemSlot;

/** The quantity of objects stacked here */
var int Quantity;

/** The name of the Item */
var() string ObjectName;

/** The current durability of this item */
var() float Durability;
/** The max durability of this item */
var() float MaxDurability;

/** The money value of this item */
var() float Value;

/** the actual object's mesh */
var() SkeletalMeshComponent Mesh;

/** the armor part attachment (if needed) */
var V17ArmorAttachment ArmorAttachment;

/** Texture to display as icon in the inventory */
var() Texture2D InventoryTexture;

enum ItemTypes
{
    Item_Object<DisplayName=Object Item>,
    Armor_Head<DisplayName=Head Armor>,
    Armor_Body<DisplayName=Body Armor>,
    Armor_Back<DisplayName=Back Armor>,
    Armor_Hands<DisplayName=Hands Armor>,
    Armor_Arms<DisplayName=Arms Armor>,
    Armor_Feet<DisplayName=Shoes>
};
var() ItemTypes ItemType;

replication
{
    if(bNetDirty) ItemSlot;
}

/*
simulated event ReplicatedEvent(name VarName)
{
    if(VarName== 'ItemSlot')
    {
        `log( "==============================");
        `log( "==============================");
        `log( " item slot replicated on ITEM");
        `log( "==============================");
        `log( "==============================");
    }
    else super.ReplicatedEvent(VarName);
}
*/

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
        Pickup.SetPickupMesh(Mesh);
    Pickup.SetPhysics(PHYS_Falling);

    // save the cloth properties into the drop (add more if needed)
    V17ItemPickup(Pickup).Mesh.SetEnableClothSimulation(Mesh.bEnableClothSimulation);
    V17ItemPickup(Pickup).Mesh.ClothWind = Mesh.ClothWind;

    Instigator = None;
    GotoState('');
}

function UpdateAttachment()
{
    // destroy the attachment and spawn a new one
    if (ArmorAttachment != None)
    {
        ArmorAttachment.Destroy();
        ArmorAttachment = None;
    }

    if (Owner == None)
    {
        return;
    }

    if (ItemSlot == "slotHelm" || ItemSlot == "slotArmor" || ItemSlot == "slotCloak" ||
        ItemSlot == "slotGloves" || ItemSlot == "slotBracers" || ItemSlot == "slotShoes")
    {
        ArmorAttachment = Spawn(class'V17ArmorAttachment', Owner);
        
        //mystuff
        ArmorAttachment.AttachmentSocket=ItemSlot;
        
        
        
        // apply all of the archetype's properties (add more if needed)
        ArmorAttachment.SkeletalMeshComponent.SetSkeletalMesh(Mesh.SkeletalMesh);
        ArmorAttachment.SkeletalMeshComponent.SetEnableClothSimulation(Mesh.bEnableClothSimulation);
        ArmorAttachment.SkeletalMeshComponent.ClothWind = Mesh.ClothWind;
        //ArmorAttachment.SkeletalMeshComponent=Mesh;
        //ArmorAttachment.SkeletalMeshComponent.bHasPhysicsAssetInstance = bHasMesh.PhysicsAssetInstance;
        
       
        ArmorAttachment.AttachTo(V17Pawn(Owner));
        ArmorAttachment.SetHidden(false);
    }
}

function Destroyed()
{
    if (ArmorAttachment != None)
    {
        ArmorAttachment.Destroy();
        ArmorAttachment = None;
    }
}

DefaultProperties
{
    DroppedPickupClass=class'V17ItemPickup'
}
