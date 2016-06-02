// this class extends Pawn because of the InventoryManager, which requires a Pawn instigator
class V17InventoryContainer extends Pawn
    ClassGroup(V17Game)
    Placeable;

/** The in-game mesh for the container if we want a skeletal mesh */
//var() SkeletalMeshComponent   SkeletalMesh;
/** The in-game mesh for the container if we want a static mesh */
var() StaticMeshComponent StaticMesh;

/** The list of items stored in this container */
var() array<archetype Object> InventoryItems;

/** The amount of gold stored in this container */
var() int Gold;

/** Make this container invulnerable to damage */
var() bool bIndestructible;

var V17InventoryManager V17InvM;

replication
{
    if(bNetDirty) V17InvM;
}




simulated event ReplicatedEvent(name VarName)
{
    if(VarName== 'V17InvM')
    {
        `log( "=========!!!!+==========!!!=====Inv repl");
        `log( "Gold="@V17InvM.Gold);
    }
    if(VarName== 'Gold')
    {
        //later
    }
    super.ReplicatedEvent(VarName);
}

event PostBeginPlay()
{
    super.PostBeginPlay();
    //V17InvM=spawn( class'InventoryBag',self);
    AddInventoryItems();
}

reliable client function blabla()
{
    local Inventory faggot;    
    `log(  "oka now ima tell you all my items and gold  ");
    
    for(faggot=V17InvM.InventoryChain;faggot!=none; faggot=faggot.Inventory)
    {
        if(V17Weapon(faggot)!=none) `log( "weap "$string(V17Weapon(faggot).Name)$" slot "$V17Weapon(faggot).ItemSlot);
        if(V17Inventory(faggot)!=none) `log("Inv "$string(V17Inventory(faggot).Name)$" slot "$V17Inventory(faggot).ItemSlot);
    }
    
    `log( "end ");
}


function AddInventoryItems()
{
    local Actor ArchetypeTemplate, NewItem;
    local int i, saveSlot;
    
    local string checkSlot;
    local bool bFreeSlot;
    //local V17Weapon V17Weap;
    //local V17Inventory V17Inv;
    
    local Inventory Item;
    
    // make sure we have an InvManager, or wait for one
    if (InvManager == None)
    {
        SetTimer(0.25f, false, 'AddInventoryItems');
        return;
    }

    // load inventory
    V17InvM = V17InventoryManager(InvManager);
    for (i=0; i<InventoryItems.Length; i++)
    {
        if (InventoryItems[i] == none)
            continue;

        ArchetypeTemplate = Actor(DynamicLoadObject(PathName(InventoryItems[i]), class'Actor', true));
        NewItem = Spawn(ArchetypeTemplate.Class, self, , , , ArchetypeTemplate);
        
        V17InvM.AddInventory(Inventory(NewItem), true);

        // find out the first free inventory slot to store this in
        for (saveSlot = 0; saveSlot < V17InvM.MaxSpaces; saveSlot++)
        {
            bFreeSlot = true;
            checkSlot = "slot"$saveSlot;
            
            For(Item=V17InvM.InventoryChain;Item!=None; Item=Item.Inventory)
            {
                if(V17Weapon(Item)!=none&&V17Weapon(Item).ItemSlot==checkSlot) bFreeSlot=false;
                if(V17Inventory(Item)!=none&&V17Inventory(Item).ItemSlot==checkSlot) bFreeSlot=false;
            }
            
            if (bFreeSlot)
            {
                break;
            }
        }

        if (V17Weapon(NewItem) != None)
        {
            V17Weapon(NewItem).ItemSlot = checkSlot;
        }
        else if (V17Inventory(NewItem) != None)
        {
            V17Inventory(NewItem).ItemSlot = checkSlot;
            V17Inventory(NewItem).Quantity = 1;
        }
    }

    V17InvM.Gold = Gold;
    //InvM2=V17InvM;
    //`log( "o!!!!!!KKKKKKK_+++++++++++++++++++++++++++++================kay u not fck with me  "@InvM2.Gold);
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    if (!bIndestructible)
    {
        Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
    }
}

DefaultProperties
{
    /*Begin Object Class=SkeletalMeshComponent Name=ICSkeletalMeshComponent
    End Object
    SkeletalMesh=ICSkeletalMeshComponent
    Components.Add(ICSkeletalMeshComponent)*/

    Begin Object Class=StaticMeshComponent Name=ICStaticMeshComponent
        StaticMesh=StaticMesh'PhysTest_Resources.RemadePhysBarrel'
        BlockRigidBody=true
        BlockActors=true
    End Object
    CollisionComponent=ICStaticMeshComponent
    StaticMesh=ICStaticMeshComponent
    Components.Add(ICStaticMeshComponent)

    bAlwaysRelevant=true
    bCollideActors=false
    bBlockActors=true
    bPathColliding=true

    bDontPossess=true

    InventoryManagerClass=class'V17InventoryManager'
}