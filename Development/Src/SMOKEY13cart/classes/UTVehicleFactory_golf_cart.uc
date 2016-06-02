/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
 class UTVehicleFactory_golf_cart extends UTVehicleFactory;

defaultproperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'VH_SMOKEY13_golf_cart.Mesh.golf_cart'
        Translation=(X=0.0,Y=0.0,Z=-70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
    End Object

    Components.Remove(Sprite)

    Begin Object Name=CollisionCylinder
        CollisionHeight=+80.0
        CollisionRadius=+120.0
        Translation=(X=-45.0,Y=0.0,Z=-10.0)
    End Object

    VehicleClassPath="SMOKEY13cart.UTVehicle_golf_cart_Content"
    DrawScale=1.0
}
