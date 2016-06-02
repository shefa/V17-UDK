//  ================================================================================================
//   * File Name:    V17MeleeWeapon
//   * Created By:   User
//   * Time Stamp:     6.5.2014 г. 14:40:45 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17MeleeWeapon extends V17Weapon;

var() const name SwordHiltSocketName;
var() const name SwordTipSocketName;
var() const name SwordAnimationName;
var() const SoundCue SwordClank;
//var() const SoundCue SwingSound;
//var() ParticleSystem HitEffect;

//tracing points
var array<Vector> PreviousPoints;
var array<Vector> CurrentPoints;
var int numPoints;


var array<Actor> SwingHitActors;
var array<int> Swings;
var const int MaxSwings;

var bool bA, bD ,bW, bAlt, ShouldTrace;
var int attack_dir;
var bool bAllowStopFire, bStopFireCalled, bStartedAttack, bStartedStopFire;

var bool bAllowStopBlock, bStopBlockCalled, bStartedBlock, bStartedStopBlock;
var bool isBlocking,bPerfectBlock;

var() array<name> Charge_Seq;
var() array<name> Release_Seq;
var() array<name> Block_Charge_Seq;
var() name parry_seq;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
}


function Vector GetSwordSocketLocation(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SwordRotation;
    local SkeletalMeshComponent SMC;

    SMC = SkeletalMeshComponent(Mesh);

    if (SMC != none && SMC.GetSocketByName(SocketName) != none)
    {
        SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);

    }

    return SocketLocation;
}

function bool AddToSwingHitActors(Actor HitActor)
{
    local int i;

    for (i = 0; i < SwingHitActors.Length; i++)
    {
        if (SwingHitActors[i] == HitActor)
        {
            return false;
        }
    }

    SwingHitActors.AddItem(HitActor);
    return true;
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
   local Pawn pawnLocal;

   pawnLocal = Pawn( Other );
   `log(" touched nanananananaaaaaaaaaaaaaaan");

   if(pawnLocal != None)
   {
         //HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');

         PlaySound(SwordClank);
   }
}
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
    `log("bumpeddddddddddddddddddddd asdasdasdasdhasdabskndjasndkasdhasjdnaksjdasd yesa");
}
simulated function TraceSwing1()
{

    local Actor HitActor;
    local StaticMeshComponent SMC;

    local vector pos;
    local rotator rotz;
    local vector endpos;

    //`log("herro");
    SMC = StaticMeshComponent(Mesh);
    
    pos=SMC.GetPosition();
    rotz=SMC.GetRotation();
    endpos=pos+vector(rotz)*50;
    DrawDebugLine(SMC.Bounds.Origin,SMC.Bounds.Origin-SMC.Bounds.BoxExtent,0,255,0,true);
    `log("collision "@SMC.CollideActors@SMC.BlockActors );
    SMC.SetActorCollision(true,false,true);
    

    foreach TouchingActors(class'Actor',HitActor)
    {
        `log("plus plus actorz");
    }
    //if(V17StaticMeshComponent(Mesh)!=None) V17StaticMeshComponent(Mesh).Tracing=false;
}

simulated function TraceSwing()
{
    local Actor HitActor;
    local Vector HitLoc, HitNorm, Momentum;
    local int DamageAmount;

    local Vector SwordTip, SwordHilt;
    local int i;

    //`log( "tracing Role "@Role);

    SwordTip = GetSwordSocketLocation(SwordTipSocketName);
    SwordHilt = GetSwordSocketLocation(SwordHiltSocketName);
    //To do: Damage ammount related to player stats
    DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);


    //Change current points
    for(i=0;i<numPoints; i++)
    {
        CurrentPoints[i]=VLerp(SwordHilt,SwordTip,i/float(numPoints-1));
    }

    for(i=0;i<numPoints; i++)
    {


    foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, PreviousPoints[i], CurrentPoints[i])
    {
        if (HitActor != self && AddToSwingHitActors(HitActor))
        {
            if(Character(HitActor)!=none&&Character(HitActor).isBlocking&&Blocked(Character(HitActor).BlockingDir,attack_dir))
            {

                WorldInfo.Game.Broadcast(self,  "BLOCKED ");
                `log( "==============blocked"@Role);
                finish_attack();
                Character(ownerPawn).playanim2(parry_seq);
                return;

            }
            Momentum = Normal(SwordTip - SwordHilt) * InstantHitMomentum[CurrentFireMode];
            HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
            PlaySound(SwordClank);
        }
    }
    }

    // Debug lines
    if(Character(ownerPawn).DebugLines) for(i = 0; i < numPoints; i++) DrawDebugLine(PreviousPoints[i],CurrentPoints[i],0,255,0,true);


    //Swap old points for new
    for(i = 0; i < numPoints; i++)
    {
        PreviousPoints[i] = CurrentPoints[i];
    }
}

function bool Blocked(int blockdir, int attackdir)
{
    //to do: perfect block and so on
    if(blockdir==0&&attackdir==1) return true;
    if(blockdir==1&&attackdir==0) return true;
    if(blockdir==2)
    {
        if(attackdir==3||attackdir==2) return true;
    }
    return false;
}

function reset_swing()
{

    local Vector BaseSocketLocation, TipSocketLocation;
    local int i;


    TipSocketLocation = GetSwordSocketLocation(SwordTipSocketName);
    BaseSocketLocation = GetSwordSocketLocation(SwordHiltSocketName);


    // Reset arrays
    PreviousPoints.Remove(0,PreviousPoints.length);
    CurrentPoints.Remove(0,PreviousPoints.length);
    SwingHitActors.Remove(0, SwingHitActors.Length);

    // init values
    for(i = 0; i < numPoints; i++)
    {
        PreviousPoints.AddItem(VLerp(BaseSocketLocation,TipSocketLocation,i/float(numPoints-1)));
        CurrentPoints.AddItem(VLerp(BaseSocketLocation,TipSocketLocation,i/float(numPoints-1)));
    }


}

simulated function BeginFire(Byte FireModeNum)
{
    local float time1;
    //if(Role==ROLE_Authority) return;

    //sheath
    if(Sheathed==true) return;

    if(FireModeNum==1)
    {
        BeginBlock();
        return;
    }
    if(bStartedAttack==false&&bStartedBlock==false)
    {


    //SwingHitActors.Remove(0, SwingHitActors.Length);


    bAllowStopFire=false;
    bStopFireCalled=false;
    bStartedAttack=true;

    if(V17PlayerController(ownerPawn.Controller).bAlt==true) attack_dir=3;
    else if(V17PlayerController(ownerPawn.Controller).bW==true) attack_dir=2;
    else if(V17PlayerController(ownerPawn.Controller).bA==true) attack_dir=1;
    else attack_dir=0;
    WorldInfo.Game.Broadcast(self,  "Start Firing "@attack_dir@FireModeNum);
    //`log( "Start fire role "@Role);
    SetDir(attack_dir);
    time1=Character(ownerPawn).playanim3(Charge_Seq[attack_dir],1.0f,0.5f,-1.0f,false);
    SetTimer(time1,false, 'AllowStopFire');
    //Super.BeginFire( FireModeNum);
    }

}

reliable server function SetDir(int dir)
{
    attack_dir=dir;
}

function AllowStopFire()
{
    WorldInfo.Game.Broadcast(self,  "AllowStop"@bStopFireCalled);
    bAllowStopFire=true;
    if(bStopFireCalled==true) StopFire(0);
}

simulated function StopFire(Byte FireModeNum)
{
    local float time1;

    //sheath
    if(Sheathed==true) return;

    if(FireModeNum==1)
    {
        StopBlock();
        return;
    }

    bStopFireCalled=true;

    if(Role<ROLE_Authority) ServerStopFire(FireModeNum);
    else{
    if(bAllowStopFire&&bStartedAttack&&bStartedStopFire==false){

    WorldInfo.Game.Broadcast(self,   "End Firing "@attack_dir);
    reset_swing();
    ShouldTrace=true;
    bStartedStopFire=true;
    time1=Character(ownerPawn).playanim2(Release_Seq[attack_dir]);
    SetTimer(time1,false,'finish_attack');
    //super.StopFire(FireModeNum);
    }
    }
}

reliable server function ServerStopFire(Byte FireModeNum)
{
    StopFire(FireModeNum);
}

function finish_attack()
{
    ShouldTrace=false;
    bStartedAttack=false;
    bStartedStopFire=false;
}

event Tick(float DeltaTime)
{
    if(ShouldTrace) TraceSwing();
}

// BLOCKING functions

simulated function BeginBlock()
{
    //local float time1;

    if(bStartedBlock==false&&bStartedAttack==false)
    {


    bAllowStopBlock=false;
    bStopBlockCalled=false;
    bStartedBlock=true;

    isBlocking=true;


    //Direction apply
    if(V17PlayerController(ownerPawn.Controller).bD==true) attack_dir=0;
    else if(V17PlayerController(ownerPawn.Controller).bA==true) attack_dir=1;
    else attack_dir=2;
    WorldInfo.Game.Broadcast(self,  "Start Blocking "@attack_dir);

    SetDir(attack_dir);
    WritePawnBlocking(true,attack_dir);

    Character(ownerPawn).playanim3(Block_Charge_Seq[attack_dir],1.0f,0.2f,0.0f,false);
    //`log(time1);
    SetTimer(0.3333f,false, 'AllowStopBlock');
    }

}
function AllowStopBlock()
{
    WorldInfo.Game.Broadcast(self,  "AllowStopBlock"@bStopFireCalled);
    bAllowStopBlock=true;
    if(bStopBlockCalled==true) StopBlock();
}

simulated function StopBlock()
{
    local float time1;

    bStopBlockCalled=true;

    if(Role<ROLE_Authority) ServerStopBlock();
    else{
        if(bAllowStopBlock&&bStartedBlock&&bStartedStopBlock==false){

            WorldInfo.Game.Broadcast(self,   "End Blocking "@attack_dir);

            //ShouldTrace=true;
            bStartedStopBlock=true;

            time1=Character(ownerPawn).playanim3(Block_Charge_Seq[attack_dir],1.0f,0.0f,0.34f,false);
            SetTimer(time1,false,'finish_block');

        }
    }

}

function finish_block()
{
    WorldInfo.Game.Broadcast(self,  "finish block ");
    bStartedBlock=false;
    bStartedStopBlock=false;
    isBlocking=False;
    WritePawnBlocking(false,attack_dir);
}

reliable server function ServerStopBlock()
{
    StopBlock();
}

reliable server function WritePawnBlocking(bool blocking, int direction)
{
    Character(ownerPawn).isBlocking=blocking;
    Character(ownerPawn).BlockingDir=direction;
}

defaultproperties
{

    
    numPoints=5;

    Charge_Seq(0)= "3p_1hsharp_slash01downtoup";
    Release_Seq(0)="3p_1hsharp_slash01release";

    Charge_Seq(1)="3p_1hsharp_slash011altdowntoup";
    Release_Seq(1)="3p_1hsharp_slash011release";

    Charge_Seq(2)="3p_1hsharp_slash021altdowntoup";
    Release_Seq(2)="3p_1hsharp_slash021release";

    Charge_Seq(3)="3p_1hsharp_stabdowntoup";
    Release_Seq(3)="3p_1hsharp_stabrelease";


    Block_Charge_Seq(2)="3p_1hsharp_parryhitH";
    Block_Charge_Seq(0)="3p_1hsharp_parryhitR";
    Block_Charge_Seq(1)="3p_1hsharp_parryhitL";

    parry_seq="3p_1hsharp_parried";

    bPerfectBlock=false;
    isBlocking=false;
    bStartedAttack=false;
    bStartedBlock=false;

    ShouldTrace=false;
    bA=false;
    bAlt=false;
    bW=false;
    bD=false;


    MaxSwings=2
    Swings(0)=2

    bMeleeWeapon=true;
    bInstantHit=true;
    bCanThrow=false;


     

    //bCollideActors=true;
    //bBlockActors=false;
    //CollisionType=COLLIDE_TouchAll

    // Configuración del arma
    FiringStatesArray(0)=WeaponFiring       // Estado de disparo para el modo de disparo 0
    WeaponFireTypes(0)=EWFT_Custom      // Tipo de disparo para el modo de disparo 0
    FireInterval(0)=0.1                     // Intervalo entre disparos
    Spread(0)=0.05                          // Dispersion de los disparos
    InstantHitDamage(0)=20                  // Daño de Instant Hit
    InstantHitMomentum(0)=50000             // Inercia de Instant Hit


    //shot=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireCue'
    //WeaponFireSnd(1)=SoundCue'A_Weapon_Link.Cue.A_Weap on_Link_AltFireCue'


}