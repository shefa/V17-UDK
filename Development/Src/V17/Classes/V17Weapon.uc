//  ================================================================================================
//   * File Name:    V17Weapon
//   * Created By:   User
//   * Time Stamp:     4.2.2014 г. 19:57:05 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17Weapon extends UDKWeapon
    ClassGroup(V17Game)
    placeable;
    
/*2015 woo, trying static mesh shit*/ 
var() bool IHaveStaticMesh;
    
    
/** The slot inside the inventory, aka. where in the grid/character it's located */
var repnotify string ItemSlot;

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
    Weapon_Sword<DisplayName=Sword>,
    Weapon_Axe<DisplayName=Axe>,
    Weapon_Polesword<DisplayName=PoleSword>,
    Weapon_Hammer<DisplayName=Hammer>,
    Weapon_Other<DisplayName=Other>
};

var PawnWeaponType WeaponType;
var() WeaponTypes WeaponType1;
var() V17WeaponTypes V17WeaponType;

var() name WeaponSocket1;
var() name SheathSocket1;
var() name EquipAnimation;
var() name UnEquipAnimation;

var repnotify bool IsEquipped;
var repnotify bool Sheathed;

var V17Pawn ownerPawn;

var byte InventoryGroup;        // Grupo de inventario. Se usa para cambiar de arma
 
// ****************************************************************
// Instant HIT
// ****************************************************************
var ParticleSystem BeamTemplate;    // Sistema de partículas del rayo mostrado en Instant Hit
 
var MaterialInterface ExplosionDecal;       // Decal (calcomanía) que deja en las superficies el Instant Hit
var float DecalWidth, DecalHeight;          // Ancho y altura del decal
var float DurationOfDecal;                  // Duración del decal antes de desaparecer
var name DecalDissolveParamName;            // Nombre del parámetro del MaterialInstance para disolver el material
var SoundCue ShotSound; // Sonido de disparo
var ParticleSystem Muzzle; // Sistema de particulas de Muzzle


var() AnimSet PawnAnimSet;

//Attachment class
var() class<V17WeaponAttachment> AttachmentClass;



replication
{
    if(bNetDirty||bNetInitial) ItemSlot,Sheathed,IsEquipped;
}

simulated event ReplicatedEvent(name VarName)
{
    super.ReplicatedEvent(VarName);
}

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


// Determina la posición real del arma
simulated event SetPosition(UDKPawn Holder)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;
 
    compo = Holder.Mesh;
 
    if (compo != none)
    {
        socket = compo.GetSocketByName(WeaponSocket1);
        if (socket != none)
        {
            FinalLocation = compo.GetBoneLocation(socket.BoneName);
        }
    }
    SetLocation(FinalLocation);
}
 
// Calcula la posición real desde donde se disparan los proyectiles
simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
 
    compo = Instigator.Mesh;
 
    if (compo != none)
    {
        socket = compo.GetSocketByName(WeaponSocket1);
        if (socket != none)
        {
             return compo.GetBoneLocation(socket.BoneName);
        }
    }
}
 
// Sobreescribe la funcion de Weapon. Procesa los impactos instantaneos.
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
    local MaterialInstanceTimeVarying MITV_Decal;
 
    // Calcula el daño total y lo aplica al actor
    Super.ProcessInstantHit(FiringMode, Impact, NumHits);
 
    // Creación del Decal
    MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
    MITV_Decal.SetParent(ExplosionDecal);
    WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, Impact.HitLocation, rotator(-Impact.HitNormal), DecalWidth, DecalHeight, 10.0, FALSE );
    MITV_Decal.SetScalarStartTime( DecalDissolveParamName, DurationOfDecal );
 
    // Generación del rayo de Instant Hit
    SpawnBeam(GetPhysicalFireStartLoc() + (FireOffset >> Instigator.GetViewRotation()), Impact.HitLocation, false);
}
 
// Se llama al equipar el arma
simulated function TimeWeaponEquipping()
{
    `log(  "========== time weapon equiping  "@Role);
    if(IHaveStaticMesh) `log("------------------------------------------------------jeah");
    
    AttachWeaponTo( Instigator.Mesh,WeaponSocket1 );
    ownerPawn=V17Pawn(Instigator);
    FockDat(V17Pawn(Instigator));
    V17Pawn(Instigator).SetWeaponType(WeaponType);
    //WorldInfo.Game.Broadcast(self,   'blabla its equipped ');
    V17Pawn(Instigator).HasEquippedWeapon=true;
    V17Pawn(Instigator).CurrentWeapon=self;
    Chivalry_Char(Instigator).UpdateAnim();
    IsEquipped=true;
    
    Sheathed=false;
    WriteSheathed(false,WeaponSocket1);
    //Character(Instigator).WeaponSheathed=false;
    super.TimeWeaponEquipping();
}

reliable server function FockDat(V17Pawn aa)
{
    ownerPawn=aa;
    ownerPawn.WeaponType2=V17WeaponType;
}

reliable server function serverattach( SkeletalMeshComponent MeshComp, optional Name SocketName )
{
    //`log( "================================================bullshit ");
    AttachWeaponTo(MeshComp,SocketName);
}
reliable server function serverdetach()
{
    DetachWeapon();
}

// Attaching the wep
simulated function AttachWeaponTo( SkeletalMeshComponent MeshComp, optional Name SocketName )
{
    local Character P;

    P = Character(Instigator);
    // Spawn the 3rd Person Attachment
    if (P != None)
    {
        P.CurrentWeaponAttachmentClass = AttachmentClass;
        if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
        {
                        // call the function directly if we are the server, we're running standalone or we are the client that is changing our weapon
            P.WeaponAttachmentChanged();
            
        }
    }
    
    if(MeshComp==None) MeshComp=Instigator.Mesh;
    MeshComp.AttachComponentToSocket(Mesh,SocketName);
    // light environment
    Mesh.SetLightEnvironment(V17Pawn(Instigator).LightEnvironment);
    
    if(Role<ROLE_Authority) 
    {
        //ownerPawn=V17Pawn(Instigator);
        
        serverattach(MeshComp,SocketName);
    }
    //old code
    /*
   
    
    */
}
 
// Llamado al dejar de usar el arma
simulated function DetachWeapon()
{
    //Instigator.Mesh.DetachComponent(Mesh);
    //Worldinfo.Game.Broadcast(self,  'bla unequipped ');
    local Character P;

    P = Character(ownerPawn);
    if(P!=none)
    {
    P.CurrentWeaponAttachmentClass = None;
    if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
        {
                        // call the function directly if we are the server, we're running standalone or we are the client that is changing our weapon
                   
                        P.WeaponAttachmentChanged();
                        //`log( "!!!!!!!!!!! removing wep ");
        }
        
    }
    
    
    //if(V17Pawn(Instigator)!=none) V17Pawn(Instigator).HasEquippedWeapon=false;
    
    Instigator.Mesh.DetachComponent(Mesh);
    IsEquipped=false;
    //SetBase(None);
    //SetHidden(True);
    if(Role<ROLE_Authority)
    {
        
        serverdetach();
    }
}
 
function SetMode(bool InHand)
{
    
    if(Sheathed&& InHand)
    {
        Character(Instigator).playanim2(EquipAnimation);
        EquipUp();
        //V17Pawn(Instigator).SetWeaponType(WeaponType);
    
        //V17Pawn(Instigator).HasEquippedWeapon=true;
        //V17Pawn(Instigator).CurrentWeapon=self;
    
        //IsEquipped=true;
        Sheathed=false;
        Character(ownerPawn).WeaponSheathed=false;
        Character(ownerPawn).WeaponSocket=WeaponSocket1;

        
    }
    else if ( Sheathed==false && InHand==false)
    {
        
        EquipDown();
        //V17Pawn(Instigator).SetWeaponType(WeaponType);
        Worldinfo.Game.Broadcast(self,  'sheathing');
        //V17Pawn(Instigator).HasEquippedWeapon=true;
        //V17Pawn(Instigator).CurrentWeapon=self;
    
        //IsEquipped=true;
        Sheathed=true;
    }
}

reliable client function EquipUp()
{

    //`log( "EquipUp called role "@Role);
    
    DetachWeapon();
    AttachWeaponTo( ownerPawn.Mesh,WeaponSocket1 );
    
    
    //if(Role<ROLE_Authority) sEquipUp();
        
}


function EquipDown()
{
    local float time1;
    //`log( "EquipDown called role "@Role);
    time1=Character(Instigator).playanim2(UnEquipAnimation);
    SetTimer(time1,false,'finishDOWN');
    
}

reliable client function finishDOWN()
{
    //`log( "finishdown called role "@Role);
    DetachWeapon();
    AttachWeaponTo( ownerPawn.Mesh,SheathSocket1);
    WriteSheathed(true,SheathSocket1);
    //if(Role<ROLE_Authority) sFinishDOWN();
}
reliable server function WriteSheathed(bool sh, name wepsocketname)
{
    `log("============="@wepsocketname@WeaponSocket1@SheathSocket1);
    Character(ownerPawn).WeaponSheathed=sh;
    Character(ownerPawn).WeaponSocket=wepsocketname;
}



// Genera el rayo del arma. Extraído de UTAttachment_ShockRifle
simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
    local ParticleSystemComponent E;
    local actor HitActor;
    local vector HitNormal, HitLocation;
 
    if (End == Vect(0,0,0))
    {
        if (!bFirstPerson || (Instigator.Controller == None))
        {
            return;
        }
        End = Start + vector(Instigator.Controller.Rotation) * class'UTWeap_ShockRifle'.default.WeaponRange;
        HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
        if ( HitActor != None )
        {
            End = HitLocation;
        }
    }
    E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
    E.SetVectorParameter('ShockBeamEnd', End);
    if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
    {
        E.SetDepthPriorityGroup(SDPG_Foreground);
    }
    else
    {
        E.SetDepthPriorityGroup(SDPG_World);
    }
}



simulated function FireAmmunition()
{
Super.FireAmmunition();

PlayFiringSound();
}

simulated function PlayFiringSound()
{
if(ShotSound != none)
{
    MakeNoise(1.0);
    //WeaponPlaySound( ShotSound );
    Instigator.PlaySound(ShotSound, false, true);
}
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
if(Muzzle != None)
{
WorldInfo.MyEmitterPool.SpawnEmitter(Muzzle, GetPhysicalFireStartLoc() + (FireOffset >> Instigator.GetViewRotation()), Instigator.GetViewRotation());
}
}
 
defaultproperties
{
    EquipAnimation="EquipWeapon"
    UnEquipAnimation="UnequipWeapon"
    WeaponSocket1= "WeaponPoint"
    SheathSocket1= "Sheath"
    Sheathed=false
    AttachmentClass=class'RocketLauncherAttachment'
    DroppedPickupClass=class'V17ItemPickup'
    WeaponType=PWT_Default;
    FireOffset=(X=50,Y=0,Z=0)
    //DepthPriorityGroup=SDPG_Foreground
}