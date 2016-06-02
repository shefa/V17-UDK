/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleLocationWorldOffset extends ParticleModuleLocation
	native(Particle)
	editinlinenew;

cpptext
{
protected:
	virtual void SpawnEx(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime, class FRandomStream* InRandomStream);
}