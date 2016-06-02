/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryInteractiveFoliage extends ActorFactoryStaticMesh
	config(Editor)
	native(Foliage);

defaultproperties
{
	MenuName="Add InteractiveFoliageActor"
	NewActorClass=class'Engine.InteractiveFoliageActor'
}
