/*******************************************************************************
	HTWP_M16

	Creation date: 08/03/2010 06:48
	Copyright (c) 2010, Allar
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class HTWP_M16 extends HTWeapon;

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'ALWP_M16.Mesh.SK_WP_M16_1P'
		AnimSets(0)=AnimSet'ALWP_M16.Anims.K_WP_M16_1P'
		Scale=1.0
		FOV=60.0
	End Object

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'ALWP_M16.Mesh.SK_WP_M16_3P'
	End Object

	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)
}