//  ================================================================================================
//   * File Name:    Dragon
//   * Created By:   User
//   * Time Stamp:     13.4.2014 г. 00:02:34 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class Horse extends V17Pawn
placeable;



simulated event PostBeginPlay()
{
     
    super.PostBeginPlay();
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
}


defaultproperties
{
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
        SkeletalMesh=SkeletalMesh'horse.SkeletalMesh.horse'
        AnimSets(0)=AnimSet'horse.SkeletalMesh.HorseAnim'
        //AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
        AnimTreeTemplate=AnimTree'horse.SkeletalMesh.HorseTree'
        LightEnvironment=MyLightEnvironment
        PhysicsAsset=PhysicsAsset'horse.SkeletalMesh.horse_Physics'
        bHasPhysicsAssetInstance=True
        //bEnableFullAnimWeightBodies=True
        //bEnableSoftBodySimulation=True
        //bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    Mesh=SkeletalMeshComponentRobot
    Components.Add(SkeletalMeshComponentRobot)
    
    //collision
    Begin Object Name=CollisionCylinder
    CollisionRadius=+00050.000000
    CollisionHeight=+00050.000000
    End Object
    CylinderComponent=CollisionCylinder
 
    
    DrawScale = 1.5
 
    // Camera Properties
    DesiredCamScale=90.0
    CurrentCamScale=0.0
 
    CameraInterpolationSpeed=5.0              //Velocidad de interpolación de la cámara
 
    CamOffsetDefault=(X=4.0,Y=0.0,Z=100.0)     // Offset postura default
    CamOffsetAimRight=(X=4.0,Y=40.0,Z=100.0)
 
    // Locomotion
    JumpZ=+0700.000000
    MaxFallSpeed=+1200.0         // Maximum speed to fall without getting hurt
    AirControl=+0.1             // Air Traffic Control
    //CustomGravityScaling=0.4     // Multiplier personal gravity
    GroundSpeed=400
    speed2=1200
    //AirSpeed=1100
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
}