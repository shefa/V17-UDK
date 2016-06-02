//  ================================================================================================
//   * File Name:    V17Weapon1
//   * Created By:   User
//   * Time Stamp:     4.2.2014 г. 20:07:09 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17Weapon1 extends V17Weapon;
var SoundCue shot;
var AudioComponent Shooting;
var byte started_sound;

simulated function BeginFire(Byte FireModeNum)
{
    Super.BeginFire( FireModeNum);
    //PlayFiringSound();
    //WorldInfo.Game.Broadcast(self,"start fire "); 
    if(started_sound==0){
    Shooting= new(self) class'AudioComponent';
    AttachComponent(Shooting);
    Shooting.SoundCue = shot;
    Shooting.Play();
    started_sound=1;
}
}
simulated function StopFire(Byte FireModeNum)
{
    super.StopFire(FireModeNum);
    //WorldInfo.Game.Broadcast(self,"supposedly stopping fire "); 
    Shooting.Stop();
    started_sound=0;
}
 
defaultproperties
{
    // Mesh
    Begin Object Class=SkeletalMeshComponent Name=GunMesh
        SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3P'
        HiddenGame=FALSE
        HiddenEditor=FALSE
        Scale=2.0
    End Object
    Mesh=GunMesh
    Components.Add(GunMesh)
 
    // Configuración del arma
    FiringStatesArray(0)=WeaponFiring       // Estado de disparo para el modo de disparo 0
    WeaponFireTypes(0)=EWFT_InstantHit      // Tipo de disparo para el modo de disparo 0
    FireInterval(0)=0.1                     // Intervalo entre disparos
    Spread(0)=0.05                          // Dispersion de los disparos
    InstantHitDamage(0)=20                  // Daño de Instant Hit
    InstantHitMomentum(0)=50000             // Inercia de Instant Hit
 
    // Beam
    BeamTemplate=particlesystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam'
 
    // Decal
    ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
    DecalWidth=128.0
    DecalHeight=128.0
    DurationOfDecal=24.0
    DecalDissolveParamName="DissolveAmount"
    
    //Muzzle=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
    shot=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireCue'
    //WeaponFireSnd(1)=SoundCue'A_Weapon_Link.Cue.A_Weap on_Link_AltFireCue'
 
    // Grupo de inventario
    InventoryGroup=1
}