/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryFogVolumeLinearHalfspaceDensityInfo extends ActorFactoryFogVolumeConstantDensityInfo
	config(Editor)
	native(FogVolume);

defaultproperties
{
	MenuName="Add FogVolumeLinearHalfspaceDensityInfo"
	NewActorClass=class'Engine.FogVolumeLinearHalfspaceDensityInfo'
}
