//=============================================================================
// Pickup items.
//
// This class handles both dropped and placeable items.
// It holds a reference to the item archetype and uses it as the actual item.
// The mesh is only a visual representation and is actually independent from the item's mesh
//   once it's picked up
//=============================================================================
class V17ItemPickup extends DroppedPickup
    ClassGroup(V17Game)
    Placeable;

/** The visual mesh for this item in the world */
var() SkeletalMeshComponent Mesh;
var() StaticMeshComponent OrdinaryMesh;

/** The sound to play when this item is picked up */
var() const SoundCue PickupSound;

/** The item archetype */
var() archetype Object InventoryItem;

var Inventory ArchetypeTemplate;

event PostBeginPlay()
{
    if( Inventory == None )
    {
        ArchetypeTemplate = Inventory(DynamicLoadObject(PathName(InventoryItem), class'Inventory'));
    }
}

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
    Mesh.SetSkeletalMesh(SkeletalMeshComponent(NewPickupMesh).SkeletalMesh);
    OrdinaryMesh.SetStaticMesh(StaticMeshComponent(NewPickupMesh).StaticMesh);
}

/** give pickup to player */

function GiveTo( Pawn P )
{
    ClientGiveTo(P);
}
function ClientGiveTo( Pawn P )
{
    local V17InventoryManager V17InvM;
    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    local int saveSlot;
    local string checkSlot;
    local bool bFreeSlot;
    
    
     
    if( Inventory == None )
    {
        Inventory = Spawn(ArchetypeTemplate.Class, self, , , , ArchetypeTemplate);
    }

    // find out the first free inventory slot to store this in
    V17InvM = V17InventoryManager(P.InvManager);
    
    
    for (saveSlot = 0; saveSlot < V17InvM.MaxSpaces; saveSlot++)
    {
        bFreeSlot = true;
        checkSlot = "slot"$saveSlot;
        ForEach V17InvM.InventoryActors(class'V17Weapon', V17Weap)
        {
            if (V17Weap.ItemSlot == checkSlot)
            {
                bFreeSlot = false;
            }
        }
        ForEach V17InvM.InventoryActors(class'V17Inventory', V17Inv)
        {
            if (V17Inv.ItemSlot == checkSlot)
            {
                bFreeSlot = false;
            }
        }

        if (bFreeSlot)
        {
            break;
        }
    }

    `log("Picked up item "$Inventory$", saving at slot "$saveSlot);

    if (V17Weapon(Inventory) != None)
    {
        V17Weapon(Inventory).ItemSlot = checkSlot;
    }
    else if (V17Inventory(Inventory) != None)
    {
        V17Inventory(Inventory).ItemSlot = checkSlot;
        V17Inventory(Inventory).Quantity = 1;
    }
    
    //super.GiveTo(P);
    if( Inventory != None )
    {
        Inventory.AnnouncePickup(P);
        //Inventory.GiveTo(P);
        if ( P != None && P.InvManager != None )
        {
            P.InvManager.AddInventory( Inventory, true );
        }
        Inventory = None;

        if (PickupSound != None)
        {
            PlaySound(PickupSound);     
        }
    }
    PickedUpBy(P);

    // update the inventory screen in case it's open
    if (V17PlayerController(P.Controller) != None && V17HUD(PlayerController(P.Controller).myHUD) != None && V17HUD(PlayerController(P.Controller).myHUD).InventoryMovie != None)
    {
        V17HUD(PlayerController(P.Controller).myHUD).InventoryMovie.SetUpInventory();
    }
}

function Destroyed()
{
    Mesh = None;
    super.Destroyed();
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

        // make sure game will let player pick me up
        if (Inventory != None)
        {
            if (WorldInfo.Game.PickupQuery(Other, Inventory.class, self))
            {
                return true;
            }
        }
        else
        {
            if (WorldInfo.Game.PickupQuery(Other, ArchetypeTemplate.class, self))
            {
                return true;
            }
        }
        return false;
    }
}

DefaultProperties
{
    Begin Object Name=Sprite
        Scale=0.25f
    End Object

    Begin Object Class=SkeletalMeshComponent Name=EditorMeshComp
    End Object
    Mesh = EditorMeshComp;
    Components.Add(EditorMeshComp);

    LifeSpan=0.0
}