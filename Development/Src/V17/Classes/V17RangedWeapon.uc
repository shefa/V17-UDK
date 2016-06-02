//  ================================================================================================
//   * File Name:    V17RangedWeapon
//   * Created By:   User
//   * Time Stamp:     20.7.2014 г. 18:41:37 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17RangedWeapon extends V17Weapon;

var bool bAllowStopFire, bStopFireCalled, bStartedAttack, bStartedStopFire;

var() name WEP_Charge_Seq, WEP_Release_Seq,WEP_Idle_Seq;
var() name Release_Seq,Charge_Seq;

var() SkeletalMeshComponent ArrowMesh;
var() name Arrow_Socket;

var() name arrow_tip,arrow_base;
var() float BowRange;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
}

function Vector GetBowSocketLocation(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SwordRotation;
    local SkeletalMeshComponent SMC;

    SMC = ArrowMesh;
    
    if (SMC != none && SMC.GetSocketByName(SocketName) != none)
    {
        SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
    }

    return SocketLocation;
}

function Rotator GetBowSocketRotation(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SwordRotation;
    local SkeletalMeshComponent SMC;

    SMC = ArrowMesh;
    
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
    

    ArrowTip = GetBowSocketLocation(arrow_tip);
    ArrowTipRot=GetBowSocketRotation(arrow_tip);
    
    DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);
    
    ArrowBase=ArrowTip+ (Vector(ownerPawn.GetViewRotation())*BowRange);
    if(Character(ownerPawn).DebugLines) DrawDebugLine(ArrowTip,ArrowBase,0,255,0,true);
    
    HitActor=Trace(HitLoc,HitNorm,ArrowBase,ArrowTip,true);
    
    if (HitActor!=none && HitActor != self)
        {
            `log( "hit "@HitActor);
            Momentum = Normal(ArrowBase-ArrowTip) * InstantHitMomentum[CurrentFireMode];
            HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
            //PlaySound(SwordClank);
        }
    
}



simulated function BeginFire(Byte FireModeNum)
{
    local float time1;
    //if(Role==ROLE_Authority) return;
    
    //sheath
    if(Sheathed==true) return;
    
    if(FireModeNum==1)  return;
 
    
    if(bStartedAttack==false)
    {
        
    
    //SwingHitActors.Remove(0, SwingHitActors.Length);
    
    
    bAllowStopFire=false; 
    bStopFireCalled=false;
    bStartedAttack=true;
    
    ownerPawn.Mesh.AttachComponentToSocket(ArrowMesh,Arrow_Socket);
    WorldInfo.Game.Broadcast(self,  "Start Firing Ranged ");
    
    PlayWeaponAnimation(WEP_Charge_Seq,0);
    time1=Character(ownerPawn).playanim3(Charge_Seq,1.0f,0.5f,-1.0f,false);
    SetTimer(time1,false, 'AllowStopFire');
    
    }

}
function AllowStopFire()
{
    WorldInfo.Game.Broadcast(self,  "AllowStop also play idle"@bStopFireCalled);
    PlayWeaponAnimation(WEP_Idle_Seq,0,true);
    bAllowStopFire=true;
    if(bStopFireCalled==true) StopFire(0);
}

simulated function StopFire(Byte FireModeNum)
{
    local float time1;
    
    //sheath
    if(Sheathed==true) return;
    
    if(FireModeNum==1) return;
    
    
    bStopFireCalled=true;
    
    if(Role<ROLE_Authority) ServerStopFire(FireModeNum);
    else{
    if(bAllowStopFire&&bStartedAttack&&bStartedStopFire==false){
    
    WorldInfo.Game.Broadcast(self,   "End Firing Range");
    
    bStartedStopFire=true;
    
    
    TraceShot();
    ownerPawn.Mesh.DetachComponent(ArrowMesh);
    PlayWeaponAnimation(WEP_Release_Seq,0);
    time1=Character(ownerPawn).playanim2(Release_Seq);
    SetTimer(time1,false,'finish_attack');
    
    }
    }
}

reliable server function ServerStopFire(Byte FireModeNum)
{
    StopFire(FireModeNum);
}

function finish_attack()
{
    ownerPawn.Mesh.DetachComponent(ArrowMesh);
    bStartedAttack=false;
    bStartedStopFire=false;
}

defaultproperties
{
    BowRange=2048
    WeaponSocket1= "DualWeaponPoint"
}