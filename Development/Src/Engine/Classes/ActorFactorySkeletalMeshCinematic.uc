/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactorySkeletalMeshCinematic extends ActorFactorySkeletalMesh
	config(Editor)
	hidecategories(Object);

defaultproperties
{
	MenuName="Add SkeletalMeshCinematic"
	NewActorClass=class'Engine.SkeletalMeshCinematicActor'
}