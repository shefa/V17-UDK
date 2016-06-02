//  ================================================================================================
//   * File Name:    TestEmitter
//   * Created By:   User
//   * Time Stamp:     26.7.2014 г. 21:17:38 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class TestEmitter extends Emitter
    placeable;
   


event Touch( actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    //GetALocalPlayerController().ClientMessage("******Touch:"@Other);
    `log( "touched "@Other);
}

DefaultProperties
{
    bBlockActors=False
    bCollideActors=True

    Begin Object Class=CylinderComponent Name=CollisionCylinder0
        CollisionRadius=32.0
        CollisionHeight=64.0
        //BlockNonZeroExtent=True
        //BlockZeroExtent=False
        //BlockActors=False
        CollideActors=True
    End Object
    CollisionComponent=CollisionCylinder0
    Components.Add(CollisionCylinder0)

    bNoDelete=False
}