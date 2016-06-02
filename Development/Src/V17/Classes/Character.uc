//  ================================================================================================
//   * File Name:    V17Pawn
//   * Created By:   User
//   * Time Stamp:     30.1.2014 г. 01:14:54 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class Character extends V17Pawn;
 
var name RidingIdleAnimation;

var bool DebugLines;

var bool shouldattach;
var Pawn OtherP;

var NearFoliageManager myFoliageManager;

var AnimNodePlayCustomAnim CustAnim;

// REPLICATION STUFF

//WEAPON
/** This holds the local copy of the current attachment.  This "attachment" actor will exist independantly on all clients */
var V17WeaponAttachment CurrentWeaponAttachment;

/** Holds the class type of the current weapon attachment.  Replicated to all clients. */
var repnotify   class<V17WeaponAttachment>   CurrentWeaponAttachmentClass;

var repnotify bool WeaponSheathed;
var repnotify name WeaponSocket;

//Blocking
var repnotify bool isBlocking;
var repnotify int BlockingDir;

struct RepAnim
{
    var bool Toggle;
    var name AnimName;
    var float Rate;
    var float BlendInTime;
    var float BlendOutTime;
    var bool bLoop;
    var Character Pawn;
};

var repnotify RepAnim FullBodyRep;

replication
{
    if ( bNetDirty ) FullBodyRep,CurrentWeaponAttachmentClass,WeaponSheathed, isBlocking, BlockingDir,WeaponSocket;
}

simulated event ReplicatedEvent(name VarName)
{

    if ( VarName == 'FullBodyRep'){
    ClientePlayAnim('CustAnim', FullBodyRep.AnimName, FullBodyRep.Rate, FullBodyRep.BlendInTime, FullBodyRep.BlendOutTime, FullBodyRep.bLoop, FullBodyRep.Pawn);
    }
    if ( VarName == 'CurrentWeaponAttachmentClass' )
    {
        //`log( "current weapon class changed  "@CurrentWeaponAttachmentClass);
        WeaponAttachmentChanged();
    }
    if(VarName=='WeaponSheathed')
    {
        //`log( "Weapon SHEATHED REPLICATED CHARACTER "@WeaponSheathed);
        UpdateAttach();
    }
    super.ReplicatedEvent(VarName);
}

//WEPON

simulated simulated function UpdateAttach()
{
     if (CurrentWeaponAttachment!=None)
        {
            CurrentWeaponAttachment.DetachFrom(Mesh);
            CurrentWeaponAttachment.Destroy();
        }
        // Create the new Attachment.
        if (CurrentWeaponAttachmentClass!=None)
        {
            CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
            CurrentWeaponAttachment.Instigator = self;
        }
        else
            CurrentWeaponAttachment = none;

        // If all is good, attach it to the Pawn's Mesh.
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.AttachTo(self);
        }
}
  
simulated function WeaponAttachmentChanged()
{
        // 1. None when we changed to empty hands, 2. compare classes so we dont change to the same weapon and 3. just make sure we have a skeletal mesh
    if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
    {
        // Detach/Destroy the current attachment if we have one
        if (CurrentWeaponAttachment!=None)
        {
            CurrentWeaponAttachment.DetachFrom(Mesh);
            CurrentWeaponAttachment.Destroy();
        }
        // Create the new Attachment.
        if (CurrentWeaponAttachmentClass!=None)
        {
            CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
            CurrentWeaponAttachment.Instigator = self;
        }
        else
            CurrentWeaponAttachment = none;

        // If all is good, attach it to the Pawn's Mesh.
        if (CurrentWeaponAttachment != None)
        {
            CurrentWeaponAttachment.AttachTo(self);
        }
    }
    
    
}


reliable client function ClientePlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, optional Character PlayerPawn)
{
    PlayerPawn.CustAnim.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
}
reliable server function ServerePlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop)
{
    ePlayAnim(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
}
function float ePlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop)
{
    local float time_ret;
    local RepAnim NewRepAnim;

    NewRepAnim.Toggle = !FullBodyRep.Toggle;
    NewRepAnim.AnimName = NewAnimName;
    NewRepAnim.Rate = NewRate;
    NewRepAnim.BlendInTime = NewBlendInTime;
    NewRepAnim.BlendOutTime = NewBlendOutTime;
    NewRepAnim.bLoop = NewbLoop;
    NewRepAnim.Pawn = self;

    time_ret=CustAnim.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
    // changing this var will make it get caught and replicated by ReplicatedEvent. remember repnotify on the declaration?
    FullBodyRep = NewRepAnim;

    if(Role < ROLE_Authority)

    ServerePlayAnim(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
    return time_ret;
}

/*
simulated function eJump()
{
    ePlayAnim( 'FullBodyAnimSlot',  'Jump' , 1.0, 0.15, 0.15, false);
    if(Role < ROLE_Authority)  ServereJump(); 
}
reliable server function ServereJump()
{
    eJump();
}
*/

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        CustAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('SwingCustomAnim'));
    }
}


function AddDefaultInventory()
{
    
    //InvManager.CreateInventory(class'V17.V17Weapon1');
    //InvManager.CreateInventory(class'V17.V17Weapon2');
}
 

simulated function SwitchWeapon(byte NewGroup)
{
    //disabling
    /*
    if (V17InventoryManager(InvManager) != None)
    {
         
        V17InventoryManager(InvManager).SwitchWeapon(NewGroup);
    }
    */
}

exec function Foliage(int Max)
{
    
if (myFoliageManager == none && Max > 0) { 
myFoliageManager = Spawn(class'NearFoliageManager', self,,,,,true); 
myFoliageManager.MaxGrassCount = Max;
}
else { myFoliageManager.DestroyAllGrass(); myFoliageManager.destroy(); myFoliageManager = none; }
}

simulated function PostBeginPlay() {
    super.PostBeginPlay();
    if (myFoliageManager == none) myFoliageManager = Spawn(class'NearFoliageManager', self,,,,,true);
}

simulated function Destroyed() {
    myFoliageManager.Destroy();
    super.Destroyed();
}

function UnPossessed() {
    // myFoliageManager.Destroy();
    local V17PlayerController pc;
    local Vector SocketLocation;
    local Rotator SocketRotation;
    
    SetCollision( false, false);
    bCollideWorld = false;
    SetPhysics(PHYS_None);
    
    pc=V17PlayerController(GetALocalPlayerController());
        
    if (pc!= none && pc.Pawn.Mesh != None)
    {
        if (pc.Pawn.Mesh.GetSocketByName('Seat') != None)
      {
          pc.Pawn.Mesh.GetSocketWorldLocationAndRotation('Seat', SocketLocation, SocketRotation);
          //WorldInfo.Game.Broadcast(self,"unposess "); 
          SetBase(pc.Pawn, , pc.Pawn.Mesh, 'Seat');
          CustAnim.PlayCustomAnim('MountedCombat_Idle1', 1.0f, 0.5f, 0.30f, true, true);
          //CustAnim.PlayCustomAnim('viper_idle_sitting', 1.0);
      }
        
     
    }
    
    shouldattach=false;
    super.UnPossessed();
}


exec function float playanim1(name name1)
{
    
    return CustAnim.PlayCustomAnim(name1, 1.0f, 0.5f, 0.30f, true, true);
       
}

exec function float playanim2(name name1)
{
    return ePlayAnim('CustAnim',name1, 1.0f, 0.0f, 0.0f, false);
    //return CustAnim.PlayCustomAnim(name1, 1.0);
       
}

exec function float playanim3(name name1, float rate, float fadein, float fadeout, bool looping)
{
    return ePlayAnim( 'CustAnim',name1,rate,fadein,fadeout,looping);
}



function PossessedBy(Controller C, bool bVehicleTransition)
{
    
    //local Vector SocketLocation;
    //local Rotator SocketRotation;
    shouldattach=true;
    //WorldInfo.Game.Broadcast(self,"should implement jump "); 
    if(OtherP!=None){
    Detach(OtherP);
    OtherP.Detach(C.Pawn);
    SetBase(None);
    SetCollision( true, true);
    bCollideWorld = true;
    CustAnim.StopCustomAnim(0.25);
    }
    super.PossessedBy(C, bVehicleTransition);
}

event Tick( float DeltaTime ) {
    // If FoliageManager is destroyed whilst this is created some grass can be left over.
    // Hacky fix.
    local Vector SocketLocation;
    local Rotator SocketRotation;
    //local Actor SpawnedActor;
    //local V17Pawn mypawn;
    //local V17Pawn fuckingdragon;
    local V17PlayerController pc;
 
    if (Owner == none)
    {
        pc=Controller2;
        //pc=V17PlayerController(GetALocalPlayerController());
        //WorldInfo.Game.Broadcast(self,"NO OWNER "); 
        //if(pc == none) WorldInfo.Game.Broadcast(self,"FUCK SHIT"); 
       
        if (pc!=None && pc.Pawn.Mesh != None)
    {
        if (pc.Pawn.Mesh.GetSocketByName('Seat') != None)
      {
          pc.Pawn.Mesh.GetSocketWorldLocationAndRotation('Seat', SocketLocation, SocketRotation);
          //SetCollision(false, false);
         //SetPhysics(PHYS_NONE);
          //SC_TestShip(Pawn).Turret = Pawn(SpawnedActor);
          // WorldInfo.Game.Broadcast(self,  "attaching ");
          SetBase(pc.Pawn, , pc.Pawn.Mesh, 'Seat');
          CustAnim.PlayCustomAnim('MountedCombat_Idle1', 1.0);
          //SetPhysics(PHYS_None);
        //shouldattach=true;
          //viper_idle_sitting
          OtherP=pc.Pawn;
        
      }
        
     
    }
    }
}

exec function DebugLinesSwitch()
{
    if(Role<ROLE_Authority) SDebugLines();
    else DebugLines=!DebugLines;
}

reliable server function SDebugLines()
{
    DebugLinesSwitch();
}

defaultproperties
{
    RidingIdleAnimation='MountedCombat_Idle1'
    
    DebugLines=false
    
    WeaponSheathed=false
    isBlocking=false
    BlockingDir=0
    //CameraScale = 40.0
    // CamOffset = ( X = 4.0, Y = 0.0 , Z = -13.0 )
    InventoryManagerClass=class'V17.V17InventoryManager'
   // Pawn lighting environment
   /*
     Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=TRUE
        bIsCharacterLightEnvironment=TRUE
        bUseBooleanEnvironmentShadowing=FALSE
        InvisibleUpdateTime=1
        MinTimeBetweenFullUpdates=.2
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment
    */
    // Component SkeletalMesh for robot
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentRobot
        SkeletalMesh=SkeletalMesh'jill.SkeletalMesh.jill'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
        AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
        AnimTreeTemplate=AnimTree'MeleeWeaponContent.animation.Human'
        //AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
        LightEnvironment=MyLightEnvironment
        bEnableSoftBodySimulation=True
        bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    Mesh=SkeletalMeshComponentRobot
    Components.Add(SkeletalMeshComponentRobot)
 
    // Is made smaller cylinder collision
    Begin Object Name=CollisionCylinder
    CollisionRadius=+0025.000000
    CollisionHeight=+0044.000000
    End Object
    CylinderComponent=CollisionCylinder
 
    // The robot is a little big
    DrawScale = 1
 
    // Camera Properties
    DesiredCamScale=40.0
    CurrentCamScale=0.0
 
    CameraInterpolationSpeed=8.0              //Velocidad de interpolación de la cámara
 
    CamOffsetDefault=(X=4.0,Y=0.0,Z=-13.0)     // Offset postura default
    CamOffsetAimRight=(X=4.0,Y=40.0,Z=-13.0)   
 
    // Locomotion
    JumpZ=+0700.000000
    MaxFallSpeed=+1200.0         // Maximum speed to fall without getting hurt
    AirControl=+0.1              // Air Traffic Control
    CustomGravityScaling=1.3     // Multiplier personal gravity
    //GroundSpeed=450
    speed2=900
}