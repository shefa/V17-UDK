/*******************************************************************************
	HTWeapon

	Creation date: 08/03/2010 06:21
	Copyright (c) 2010, Allar

*******************************************************************************/

class HTWeapon extends UDKWeapon;

/** Max ammo count */
var int MaxAmmoCount;

/** Holds the amount of ammo used for a given shot */
var array<int> ShotCost;

/** Offset from view center */
var(FirstPerson) vector	PlayerViewOffset;

/** HUD Stuff */
var Texture CrosshairImage;
var UIRoot.TextureCoordinates CrosshairCoordinates;

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'AmmoCount' )
	{
		if ( !HasAnyAmmo() )
		{
			WeaponEmpty();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/*********************************************************************************************
 * Ammunition / Inventory
 *********************************************************************************************/

simulated function int GetAmmoCount()
{
	return AmmoCount;
}
 /*
 * Consumes some of the ammo
 */
function ConsumeAmmo( byte FireModeNum )
{
	// Subtract the Ammo
	AddAmmo(-ShotCost[FireModeNum]);
}

/**
 * This function is used to add ammo back to a weapon.  It's called from the Inventory Manager
 */
function int AddAmmo( int Amount )
{
	AmmoCount = Clamp(AmmoCount + Amount,0,MaxAmmoCount);
	return AmmoCount;
}


/**
 * Returns true if the ammo is maxed out
 */
simulated function bool AmmoMaxed(int mode)
{
	return (AmmoCount >= MaxAmmoCount);
}

/**
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param	FireModeNum		- The Fire Mode to Test For
 * @param	Amount			- [Optional] Check to see if this amount is available.  If 0 it will default to checking
 *							  for the ShotCost
 */
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if (Amount==0)
		return (AmmoCount >= ShotCost[FireModeNum]);
	else
		return ( AmmoCount >= Amount );
}

/**
 * returns true if this weapon has any ammo
 */
simulated function bool HasAnyAmmo()
{
	return ( ( AmmoCount > 0 ) || (ShotCost[0]==0 && ShotCost[1]==0) );
}

/**
 * This function retuns how much of the clip is empty.
 */
simulated function float DesireAmmo(bool bDetour)
{
	return (1.f - float(AmmoCount)/MaxAmmoCount);
}

/**
 * Returns true if the current ammo count is less than the default ammo count
 */
simulated function bool NeedAmmo()
{
	return ( AmmoCount < Default.AmmoCount );
}

/**
 * Cheat Help function the loads out the weapon
 *
 * @param 	bUseWeaponMax 	- [Optional] If true, this function will load out the weapon
 *							  with the actual maximum, not 999
 */
simulated function Loaded(optional bool bUseWeaponMax)
{
	if (bUseWeaponMax)
		AmmoCount = MaxAmmoCount;
	else
		AmmoCount = 999;
}

/**
 * Called when the weapon runs out of ammo during firing
 */
simulated function WeaponEmpty()
{
	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
	}

	if ( Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}
/*********************************************************
*  HUD Stuff
*********************************************************/

/**
 * Draw the Crosshairs
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y, ScreenX, ScreenY;
	local HTHUD	H;

	H = HTHUD(HUD);
	if ( H == None )
		return;

 	CrosshairSize.Y = CrosshairCoordinates.VL * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( CrosshairCoordinates.UL / CrosshairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = H.CrosshairShadowColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1 );
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);

		H.Canvas.DrawColor = H.CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);
	}
}



function PrintScreenDebug(string debugText)
{
    local PlayerController PC;
    PC = PlayerController(Pawn(Owner).Controller);
    if (PC != None)
       PC.ClientMessage("HTWeapon: " $ debugText);
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local HTPawn HTP;

	HTP = HTPawn(Instigator);
	PrintScreenDebug("Attaching Weapon");
	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(False);
		Mesh.SetLightEnvironment(HTP.LightEnvironment);
		PrintScreenDebug("First Person Weapon Attached");
	}
	else
	{
		SetHidden(True);
		if (HTP != None)
		{
			Mesh.SetLightEnvironment(HTP.LightEnvironment);
		}
	}
	//SetSkin(HTPawn(Instigator).ReplicatedBodyMaterial);
}


simulated event SetPosition(UDKPawn Holder)
{
	local vector DrawOffset, ViewOffset, FinalLocation;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local PlayerController PC;
	local vector2D ViewportSize;
	local bool bIsWideScreen;
	local vector SpecViewLoc;

	if ( !Holder.IsFirstPerson() )
		return;

	Mesh.SetHidden(False);

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}
	bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

	Mesh.SetScale3D(default.Mesh.Scale3D);
	Mesh.SetRotation(default.Mesh.Rotation);

	ViewOffset = PlayerViewOffset;

	// Calculate the draw offset
	if ( Holder.Controller == None )
	{

		if ( DemoRecSpectator(PC) != None )
		{
			PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
			DrawOffset = ViewOffset >> SpecRotation;
			//DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);
			FinalLocation = SpecViewLoc + DrawOffset;
			SetLocation(FinalLocation);
			SetBase(Holder);

			// Add some rotation leading
			//SpecRotation.Yaw = LagRot(SpecRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
			//SpecRotation.Pitch = LagRot(SpecRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
			//LastRotUpdate = WorldInfo.TimeSeconds;
			//LastRotation = SpecRotation;

			if ( bIsWideScreen )
			{
				//SpecRotation += WidescreenRotationOffset;
			}
			SetRotation(SpecRotation);
			return;
		}
		else
		{
		 DrawOffset = (ViewOffset >> Holder.GetBaseAimRotation()) + HTPawn(Holder).GetEyeHeight() * vect(0,0,1);
		 PrintScreenDebug("Setting DrawOffset to Holder Info");
	    }
	}
	else
	{

		DrawOffset.Z = HTPawn(Holder).GetEyeHeight();
		//DrawOffset += HTPawn(Holder).WeaponBob(BobDamping, JumpDamping);

		if ( HTPlayerController(Holder.Controller) != None )
		{
			DrawOffset += HTPlayerController(Holder.Controller).ShakeOffset >> Holder.Controller.Rotation;
		}

		DrawOffset = DrawOffset + ( ViewOffset >> Holder.Controller.Rotation );
	}

	// Adjust it in the world
	FinalLocation = Holder.Location + DrawOffset;
	SetLocation(FinalLocation);
	SetBase(Holder);

	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;

	// Add some rotation leading
	//if (Holder.Controller != None)
	//{
	//	FinalRotation.Yaw = LagRot(NewRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
	//	FinalRotation.Pitch = LagRot(NewRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
	//	FinalRotation.Roll = NewRotation.Roll;
	//}
	//else
	//{
		FinalRotation = NewRotation;
	//}
	//LastRotUpdate = WorldInfo.TimeSeconds;
	//LastRotation = NewRotation;

	if ( bIsWideScreen )
	{
		//FinalRotation += WidescreenRotationOffset;
	}
	SetRotation(FinalRotation);
}

simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
        PrintScreenDebug("Weapon Equipping");
        AttachWeaponTo(Instigator.Mesh);
		Super.BeginState(PreviousStateName);
	}
}

simulated state Active
{
	simulated event BeginState(Name PreviousStateName)
	{
		PrintScreenDebug("Active");
		Super.BeginState(PreviousStateName);
	}
}

simulated state WeaponFiring
{
	simulated event BeginState(Name PreviousStateName)
	{
		PrintScreenDebug("Firing");
		Super.BeginState(PreviousStateName);
	}

	/**
	 * We override BeginFire() so that we can check for zooming and/or empty weapons
	 */

	simulated function BeginFire( Byte FireModeNum )
	{
		// No Ammo, then do a quick exit.
		if( !HasAmmo(FireModeNum) )
		{
			WeaponEmpty();
			return;
		}
		Global.BeginFire(FireModeNum);
	}
}

defaultproperties
{
    //Our properties we made.

    CrosshairImage=Texture2D'HTUI.Textures.T_UI_HUD_BaseA'
    CrosshairCoordinates=(U=80,V=0,UL=50,VL=50)

    //Epic's default properties and stuff
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		CastShadow=false
		bAllowAmbientOcclusion=false
	End Object
	Mesh=FirstPersonMesh

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		bUseAsOccluder=false
		MaxDrawDistance=6000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsStaticDecals=FALSE
		bAcceptsDynamicDecals=FALSE
		bAllowAmbientOcclusion=false
	End Object
	DroppedPickupMesh=PickupMesh
	PickupFactoryMesh=PickupMesh


	MessageClass=class'UTPickupMessage'
	DroppedPickupClass=class'UTDroppedPickup'

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	WeaponProjectiles(0)=none
	WeaponProjectiles(1)=none

	FireInterval(0)=+0.3
	FireInterval(1)=+0.3

	Spread(0)=0.0
	Spread(1)=0.0

	ShotCost(0)=1
	ShotCost(1)=1

	AmmoCount=5
	MaxAmmoCount=5

	InstantHitDamage(0)=0.0
	InstantHitDamage(1)=0.0
	InstantHitMomentum(0)=0.0
	InstantHitMomentum(1)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	WeaponRange=22000

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	DefaultAnimSpeed=0.9

	EquipTime=+0.45
	PutDownTime=+0.33
}