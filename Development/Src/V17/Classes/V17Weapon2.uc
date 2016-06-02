//  ================================================================================================
//   * File Name:    V17Weapon2
//   * Created By:   User
//   * Time Stamp:     4.2.2014 г. 20:30:00 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17Weapon2 extends V17Weapon;
 
defaultproperties
{
    // Mesh
    Begin Object Class=SkeletalMeshComponent Name=GunMesh
        SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
        HiddenGame=FALSE
        HiddenEditor=FALSE
        Scale=2.0
    End Object
    Mesh=GunMesh
    Components.Add(GunMesh)
 
    // Configuración del arma
    FiringStatesArray(0)=WeaponFiring           // Estado de disparo para el modo de disparo 0
    WeaponFireTypes(0)=EWFT_Projectile          // Tipo de disparo para el modo de disparo 0
    WeaponProjectiles(0)=class'UTProj_Rocket'   // Clase del proyectil
    FireInterval(0)=0.5                         // Intervalo entre disparos
    Spread(0)=0.01                              // Dispersion de los disparos
 
    // Grupo de inventario
    WeaponType=PWT_AimRight;
    InventoryGroup=2
    Muzzle=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RockerLauncher_Muzzle_Flash'
    ShotSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
}