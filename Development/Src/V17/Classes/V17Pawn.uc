//  ================================================================================================
//   * File Name:    YourClassName
//   * Created By:   User
//   * Time Stamp:     20.4.2014 ??. 22:38:13 ??.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * ?? Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

//  ================================================================================================
//   * File Name:    V17Pawn
//   * Created By:   User
//   * Time Stamp:     30.1.2014 ??. 01:14:54 ??.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * ?? Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17Pawn extends UDKPawn
   ClassGroup(V17Game)
    placeable;

/** The list of items stored in this Pawn's InventoryManager */
var() array<archetype Object> InventoryItems;

/** The amount of gold stored in this container */
var() int Gold;

var Actor LootedPawn;
var float LootDistance;
 

// * Lighting environment * /
var DynamicLightEnvironmentComponent LightEnvironment;
 
/* ************************************************ *****************************
Camera Properties
************************************************** *************************** */
var vector DesiredCamStartLocation; 
var vector DesiredCamOffset;        
var float DesiredCamScale;          
var float DesiredCamZOffset;        
 
var vector CurrentCamStartLocation; 
var vector CurrentCamOffset;        
var float CurrentCamScale;          
var float CurrentCamZOffset;        
 
var vector CamOffsetDefault;    
var vector CamOffsetAimRight;   
 
var float CameraInterpolationSpeed;     

var float speed2,speed3;

//var bool WeaponSheathed;
var bool HasEquippedWeapon;
var V17Weapon CurrentWeapon;

enum V17WeaponTypes
{
    OneHanded,
    TwoHanded,
    Bow,
    Shield
};

enum PawnWeaponType { PWT_Default, PWT_AimRight };
var PawnWeaponType WeaponType;

var V17WeaponTypes WeaponType2;

var V17PlayerController Controller2;


replication
{
    if(bNetDirty) WeaponType2,HasEquippedWeapon,Controller2;
}

// CAMERA STUFF // 3RD PERSON

simulated event BecomeViewTarget (PlayerController PC)
{
    Local V17PlayerController UTPC;
    Super.BecomeViewTarget(PC);
    if(LocalPlayer(PC.Player)!=None)
    {
        UTPC= V17PlayerController(PC);
        if(UTPC != None)
        {
            //UTPC.SetBehindView(true);
            Controller=PC;
            Controller2=V17PlayerController(PC);
            V17PlayerController(Controller).Pawn=self;
            //SetMeshVisibility(UTPC.bBehindView);
        }
    }
}


simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc,
out rotator out_CamRot, out float out_FOV )
{
    local vector HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ;
 
    // Valores deseados:
    DesiredCamStartLocation = Location;  // El punto inicial de la c??mara es la posici??n del Pawn
    if(WeaponType == PWT_AimRight)       // Offset var??a seg??n postura (tipo de arma)
    {
        DesiredCamOffset = CamOffsetAimRight;
    }
    else
    {
        DesiredCamOffset = CamOffsetDefault;
    }
    DesiredCamZOffset = (Health > 0) ? 1.0 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
 
    // Valores interpolados:
    CurrentCamStartLocation = VLerp(CurrentCamStartLocation, DesiredCamStartLocation, CameraInterpolationSpeed*fDeltaTime);
    CurrentCamOffset = VLerp(CurrentCamOffset, DesiredCamOffset, CameraInterpolationSpeed*fDeltaTime);
    CurrentCamScale = Lerp(CurrentCamScale, DesiredCamScale, CameraInterpolationSpeed*fDeltaTime);
    CurrentCamZOffset = Lerp(CurrentCamZOffset, DesiredCamZOffset, CameraInterpolationSpeed*fDeltaTime);
 
    if ( Health <= 0 )
    {
        CurrentCamOffset = vect(0,0,0);
        CurrentCamOffset.X = GetCollisionRadius();
    }
 
    // Se extraen los ejes de la rotaci??n de la c??mara
    GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
    // Escala de la camara (zoom)
    CamDirX *= CurrentCamScale;
 
    if ( (Health <= 0) || bFeigningDeath )
    {
        // adjust camera position to make sure it's not clipping into world
        // @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
        FindSpot(GetCollisionExtent(),CurrentCamStartLocation);
    }
 
    // C??lculo de la posici??n final de la c??mara
    out_CamLoc = (CurrentCamStartLocation + vect(0.0,0.0,1.0) * CurrentCamZOffset) - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;
 
    // Se traza un rayo para calcular posibles colisiones con la geometr??a
    if (Trace(HitLocation, HitNormal, out_CamLoc, CurrentCamStartLocation, false, vect(12,12,12)) != None)
    {
        out_CamLoc = HitLocation;
    }
 
    return true;
}


//END CAMERA PART

//Weapon Types, Sheath 

function SetWeaponType(PawnWeaponType NewWeaponType)
{
    WeaponType = NewWeaponType;
}
 

function SetDefaultWeaponType()
{
    SetWeaponType(PWT_Default);
}



simulated function PostBeginPlay() {
    super.PostBeginPlay();
    AddInventoryItems();
}
/*
function PossessedBy(Controller C, bool bVehicleTransition)
{
    super.PossessedBy(C, bVehicleTransition);

    if (V17PlayerController(C) != None)
    {
        // initialize (and hide) the inventory - this prevents errors later
        // make sure we have hud
         WaitForV17HUD();
        
        
    }
}


function WaitForV17HUD()
{
     `log( "waiting ");
    if (V17PlayerController(Controller).myHUD  == None)
    {
        SetTimer(0.25f, false, 'WaitForV17HUD');
        return;
    }
    V17HUD(V17PlayerController(Controller).myHUD).InitInventory();
}
*/
function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (LootedPawn != None)
    {
        // if we're far enough from the looted pawn, remove the loot screen
        if (VSize2D(Location - LootedPawn.Location) > LootDistance)
        {
            LootedPawn = None;
            V17HUD(PlayerController(Controller).myHUD).InventoryMovie.LootScreen(false, true);
            V17HUD(PlayerController(Controller).myHUD).InventoryMovie.LootScreen(false, false);
        }
    }
}

function AddInventoryItems()
{
    local Actor ArchetypeTemplate, NewItem;
    local int i, saveSlot;
    local V17InventoryManager V17InvM;
    local string checkSlot;
    local bool bEquipped, bFreeSlot;
    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    
    if(WorldInfo.NetMode== NM_DedicatedServer) `log( "fuck off ");
    // make sure we have an InvManager, or wait for one
    if (InvManager == None)
    {
        SetTimer(0.25f, false, 'AddInventoryItems');
        return;
    }
    `log(  "!!!!!! add called, role "@Role@RemoteRole@WorldInfo.NetMode);
    // load inventory if we're an NPC
    V17InvM = V17InventoryManager(InvManager);
    for (i=0; i<InventoryItems.Length; i++)
    {
        if (InventoryItems[i] == none)
            continue;

        ArchetypeTemplate = Actor(DynamicLoadObject(PathName(InventoryItems[i]), class'Actor', true));
        NewItem = Spawn(ArchetypeTemplate.Class, self, , , , ArchetypeTemplate);
        V17InvM.AddInventory(Inventory(NewItem), true);

        // try to equip it first
        bEquipped = false;
        if (V17Weapon(NewItem) != None)
        {
            bFreeSlot = true;
            ForEach V17InvM.InventoryActors(class'V17Weapon', V17Weap)
            {
                if (V17Weap.ItemSlot == "slotWeapon")
                {
                    bFreeSlot = false;
                    break;
                }
            }

            if (bFreeSlot)
            {
                V17Weapon(NewItem).ItemSlot = "slotWeapon";
                
                V17InvM.ClientWeaponSet(V17Weapon(NewItem), true);
                bEquipped = true;
            }
        }

        // if it wasn't successfully equipped, find out the first free inventory slot to store this in
        if (!bEquipped)
        {
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
            
    }

    V17InvM.Gold = Gold;
    //V17ReplicationInfo(Controller.PlayerReplicationInfo).V17InvManager=V17InvM;
}

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
    
    // if we bump into a container start looting (but only if we're not already looting it)
    if (LootedPawn != Other && V17InventoryContainer(Other) != None && Controller != None && V17PlayerController(Controller) != None)
    {
        
        if (VSize2D(Location - Other.Location) <= LootDistance)
        {
            `log( "herro");
            LootedPawn = V17InventoryContainer(Other);
            V17HUD(V17PlayerController(Controller).myHUD).ToggleInventory(true);
            V17InventoryContainer(Other).blabla();
            //V17HUD(V17PlayerController(Controller).myHUD).InventoryMovie.SetUpLootContainer();
        }
    }
    // if we bump into another character start looting (but only if we're not already looting him)
    // commented out: handled through RigidBodyCollision. re-enable if you want to loot living Pawns
    /*else if (LootedPawn != Other && V17Pawn(Other) != None && Controller != None && PlayerController(Controller) != None)
    {
        if (VSize2D(Location - Other.Location) <= LootDistance)
        {
            LootedPawn = V17Pawn(Other);
            V17HUD(PlayerController(Controller).V17HUD).ToggleInventory(true);
            V17HUD(PlayerController(Controller).V17HUD).InventoryMovie.SetUpLoot();
        }
    }*/
    super.Bump(Other, OtherComp, HitNormal);
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
                    const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
    if (HitComponent.Owner != OtherComponent.Owner)
        super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);

    if (LootedPawn != OtherComponent.Owner && V17Pawn(OtherComponent.Owner) != None && Health > 0)
    {
        LootedPawn = V17Pawn(OtherComponent.Owner);
        V17HUD(PlayerController(Controller).myHUD).ToggleInventory(true);
        V17HUD(PlayerController(Controller).myHUD).InventoryMovie.SetUpLoot();
    }
}
simulated function SetPawnRBChannels(bool bRagdollMode)
{
    if(bRagdollMode)
    {
        // enable pawn-to-ragdoll collisions so we can loot him
        Mesh.SetRBChannel(RBCC_Pawn);
        Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
        Mesh.SetActorCollision(false, false);
    }
    else
    {
        Mesh.SetRBChannel(RBCC_Untitled3);
        Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
        Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
        Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
        Mesh.SetActorCollision(true, true);
    }
}




defaultproperties
{
   
     Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=TRUE
        bIsCharacterLightEnvironment=TRUE
        bUseBooleanEnvironmentShadowing=FALSE
        InvisibleUpdateTime=1
        MinTimeBetweenFullUpdates=.2
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment
    bCanPickupInventory=True
    LootDistance = 80.0f
    InventoryManagerClass=class'V17.V17InventoryManager'

}