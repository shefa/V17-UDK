//  ================================================================================================
//   * File Name:    Dragon
//   * Created By:   User
//   * Time Stamp:     13.4.2014 г. 00:02:34 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class Dragon extends V17Pawn
placeable;

var bool bAllowStopFire, bStopFireCalled, bStartedAttack, bStartedStopFire;
var name Release_Seq,Charge_Seq,Idle_Seq;
var name Alt_Seq;

var bool jumping;
var Rotator DesiredAim;              
var Rotator CurrentAim;              
var float  AimSpeed;
var AnimNodePlayCustomAnim CustAnim;

var bool bShouldTrace;

var ParticleSystemComponent myPS;
var name ParticleSocket;
var repnotify bool PSActive;
var int lal;

//replicating anim
struct RepAnim
{
    var bool Toggle;
    var name AnimName;
    var float Rate;
    var float BlendInTime;
    var float BlendOutTime;
    var bool bLoop;
    var Dragon Pawn;
    var int lawl;
};

var repnotify RepAnim FullBodyRep;

replication
{
    if(bNetDirty) FullBodyRep,PSActive;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName=='FullBodyRep')
    {
        ClientePlayAnim('CustAnim', FullBodyRep.AnimName, FullBodyRep.Rate, FullBodyRep.BlendInTime, FullBodyRep.BlendOutTime, FullBodyRep.bLoop, FullBodyRep.Pawn);
    }
    if(VarName=='PSActive')
    {
        ClientChangePS(PSActive);
    }
    super.ReplicatedEvent(VarName);
}

//replicating anim
reliable client function ClientePlayAnim(Name NewAnimSlot, Name NewAnimName, float NewRate, float NewBlendInTime, float NewBlendOutTime, bool NewbLoop, optional Dragon PlayerPawn)
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
    NewRepAnim.lawl=lal+1;
    lal=lal+1;

    time_ret=CustAnim.PlayCustomAnim(NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
    // changing this var will make it get caught and replicated by ReplicatedEvent. remember repnotify on the declaration?
    FullBodyRep = NewRepAnim;

    if(Role < ROLE_Authority)

    ServerePlayAnim(NewAnimSlot, NewAnimName, NewRate, NewBlendInTime, NewBlendOutTime, NewbLoop);
    return time_ret;
}

reliable client function ClientChangePS(bool a)
{
    if(a==true) myPS.ActivateSystem();
    else myPS.DeactivateSystem();
    PSActive=a;
}

reliable server function ServerChangePS(bool a)
{
    ChangePS(a);
}

function ChangePS(bool a)
{
    if(a==true) myPS.ActivateSystem();
    else myPS.DeactivateSystem();
    PSActive=a;
    if(Role<ROLE_Authority) ServerChangePS(a);
}


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        CustAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('DragCustomAnim'));
    }
}

simulated event Destroyed()
{
    Super.Destroyed();
    CustAnim = None;
}

function FireballZ()
{
    
    local Fireball fireball;
    local float time1;
    //CustAnim.PlayCustomAnimation();
    time1=ePlayAnim('CustAnim',Alt_Seq, 1.0f, 0.5f, 0.2f,false);
    SetTimer(time1,false,'finish_attack');
    fireball = Spawn( class'Fireball', Self,,GetSwordSocketLocation(ParticleSocket));
    fireball.init( Vector(GetSwordSocketRotation(ParticleSocket)));
}

function Vector GetSwordSocketLocation(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SwordRotation;
    local SkeletalMeshComponent SMC;

    SMC = Mesh;
    
    if (SMC != none && SMC.GetSocketByName(SocketName) != none)
    {
        SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
    }

    return SocketLocation;
}

function Rotator GetSwordSocketRotation(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SwordRotation;
    local SkeletalMeshComponent SMC;

    SMC = Mesh;
    
    if (SMC != none && SMC.GetSocketByName(SocketName) != none)
    {
        SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
    }

    return SwordRotation;
}

simulated function TraceShot()
{
    local Actor HitActor;
    local Vector HitLoc, HitNorm, Momentum;
    local int DamageAmount;
    
    local Vector ArrowTip, ArrowBase;
    local Rotator ArrowTipRot;
    
    //`log(Role@ "allllllllllllllllllll trace");

    ArrowTip = GetSwordSocketLocation(ParticleSocket);
    ArrowTipRot=GetSwordSocketRotation(ParticleSocket);
    
    DamageAmount = 20;
    
    ArrowBase=ArrowTip+ (Vector(ArrowTipRot)*800);
    //DrawDebugLine(ArrowTip,ArrowBase,0,255,0,true);
    
    HitActor=Trace(HitLoc,HitNorm,ArrowBase,ArrowTip,true);
    
    if (HitActor!=none && HitActor != self)
        {
            `log( "hit "@HitActor);
            Momentum = Normal(ArrowBase-ArrowTip) * 5000;
            HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
            //PlaySound(SwordClank);
        }
    
}

reliable server function ServerStartFire(Byte FireModeNum)
{
    StartFire(FireModeNum);
}

simulated function StartFire(Byte FireModeNum)
{
    local float time1;
    
    if(Role<ROLE_Authority){  ServerStartFire(FireModeNum); return; }
   
    if(FireModeNum==1)
    {
        FireballZ();
    return;
    }
    
    if(bStartedAttack==false)
    {

     
    bAllowStopFire=false; 
    bStopFireCalled=false;
    bStartedAttack=true;
        

    WorldInfo.Game.Broadcast(self,  "Dragon breath ");
    time1=ePlayAnim('CustAnim',Charge_Seq, 1.0f, 0.5f, 0.2f,false);
    SetTimer(time1,false, 'AllowStopFire');
    
    }

}
function AllowStopFire()
{
    //`log(Role@ "allllllllllllllllllll AllowStop");
    ePlayAnim('CustAnim',Idle_Seq, 1.0f, 0.5f, 0.2f,true);
    //FireBreath=Spawn(class'TestEmitter',Self,,GetSwordSocketLocation(ParticleSocket));
    //FireBreath.SetBase(self, , Mesh, ParticleSocket);
    //FireBreath.SetTemplate(PS2);
    //FireBreath.ParticleSytemComponent.ActivateSystem();
    ChangePS(true);
    //myPS.ActivateSystem();
    bShouldTrace=true;
    bAllowStopFire=true;
    if(bStopFireCalled==true) StopFire(0);
}

simulated function StopFire(Byte FireModeNum)
{
    local float time1;

    if(Role<ROLE_Authority){  ServerStopFire(FireModeNum); return; }
        
    if(FireModeNum==1) return;
    
    //`log(Role@ "allllllllllllllllllll StopFire");
    bStopFireCalled=true;
    

    if(bAllowStopFire&&bStartedAttack&&bStartedStopFire==false){
    
    WorldInfo.Game.Broadcast(self,   "End Dragon ");
    
    bStartedStopFire=true;
    bShouldTrace=false;
    time1=ePlayAnim('CustAnim',Release_Seq, 1.0f, 0.5f, 0.2f,false);
    SetTimer(time1,false,'finish_attack');
    
    
    }
}

reliable server function ServerStopFire(Byte FireModeNum)
{
    StopFire(FireModeNum);
}

function finish_attack()
{
    //FireBreath.Destroy();
    //FireBreath.ParticleSytemComponent.DeactivateSystem();
    ChangePS(false);
    //myPS.DeactivateSystem();
    
    bStartedAttack=false;
    bStartedStopFire=false;
}

function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    if(bShouldTrace) TraceShot();
}


simulated event PostBeginPlay()
{
    if (Mesh != None &&
      //SkeletalMeshComponent.bEnableFullAnimWeightBodies &&
      Mesh.PhysicsAssetInstance != None)
      {
      
      Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);
      Mesh.PhysicsAssetInstance.SetLinearDriveScale(0.2,0.2,0.2);
      Mesh.PhysicsAssetInstance.SetAngularDriveScale(0.2,0.2,0.2);
       
      Mesh.SetActorCollision(true, false);
      Mesh.SetTraceBlocking(true, true);
      Mesh.PhysicsWeight=0.1;
  }
  
  //FireBreath=Spawn(class'TestEmitter',Self,,GetSwordSocketLocation(ParticleSocket));
  //FireBreath.SetTemplate(myPS);
  //FireBreath.ParticleSystemComponent.DeactivateSytem();
    Mesh.AttachComponentToSocket(myPS, ParticleSocket);    //Attach to a given socket on your pawn.
    super.PostBeginPlay();
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
}
exec function Offset ( int  scale, int x, int y, int z )
{
    DesiredCamScale=scale;
    DesiredCamOffset.X=x;
    DesiredCamOffset.Y=y;
    DesiredCamOffset.Z=z;
}



/*
exec function MyJump()
{
    jumping=true;
    
}

exec function EndJump()
{
    jumping=false;
}

event zTick( float DeltaTime ) {
    if(jumping)
    {
           Velocity.Z += JumpZ;
           if(Physics!=PHYS_Falling) SetPhysics(PHYS_Falling);
    }
}
 */
   

defaultproperties
{
    lal=0;
    
    bShouldTrace=false
    
    Release_Seq="begin_firebreath_end"
    Charge_Seq="begin_firebreath"
    Idle_Seq="begin_firebreath_idle"
    Alt_Seq="begin_fireball"
    
    ParticleSocket="A"
    
    
    Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
        Template=ParticleSystem'Dragon.Particles.PS_Fire_Small'    //Adds the system you wish to use
         bAutoActivate = false                                    //Stops it from activating on object/actor/pawn spawn
    End Object
    Components.Add(ParticleSystemComponent0)
    myPS= ParticleSystemComponent0                       //Instantiates the reference for you to use later
    
    
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
        SkeletalMesh=SkeletalMesh'Dragon.SkeletalMesh.A'
        AnimSets(0)=AnimSet'Dragon.SkeletalMesh.A-nim'
        //AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
        AnimTreeTemplate=AnimTree'Dragon.SkeletalMesh.A-nim-tree'
        LightEnvironment=MyLightEnvironment
        PhysicsAsset=PhysicsAsset'Dragon.SkeletalMesh.A_Physics'
        bHasPhysicsAssetInstance=True
        bEnableFullAnimWeightBodies=True
        //bEnableSoftBodySimulation=True
        //bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    Mesh=SkeletalMeshComponentRobot
    Components.Add(SkeletalMeshComponentRobot)
    
    //collision
    Begin Object Name=CollisionCylinder
    CollisionRadius=+00300.000000
    CollisionHeight=+00200.000000
    End Object
    CylinderComponent=CollisionCylinder
 
    // The robot is a little big
    DrawScale = 1
 
    // Camera Properties
    DesiredCamScale=220.0
    CurrentCamScale=0.0
 
    CameraInterpolationSpeed=5.0              //Velocidad de interpolación de la cámara
 
    CamOffsetDefault=(X=6.0,Y=0.0,Z=100.0)     // Offset postura default
    CamOffsetAimRight=(X=4.0,Y=40.0,Z=100.0)
 
    // Locomotion
    jumping=false
    //JumpZ=+0700.000000
    MaxFallSpeed=+2200.0         // Maximum speed to fall without getting hurt
    AirControl=+0.1             // Air Traffic Control
    //CustomGravityScaling=0.4     // Multiplier personal gravity
    GroundSpeed=450
    AirSpeed=1200
    speed2=1200
    speed3=2400
    //Speed=1000
    //Physics=PHYS_Flying
    //bCanWalk = false
    //bCanSwim = false
    //bCanFly = true
    //bCanFly=true
    //bStatic=False
    //bMovable=True
    //WalkingPhysics=PHYS_Flying
   // bSimulateGravity=true
   //bShouldBaseAtStartup=true
   //LandMovementState=PlayerFlying
   AimSpeed=8
}