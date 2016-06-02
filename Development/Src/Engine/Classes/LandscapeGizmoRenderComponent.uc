/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class LandscapeGizmoRenderComponent extends PrimitiveComponent
	native(Terrain)
	hidecategories(Object);

cpptext
{
	/**
	 * Creates a new scene proxy for the path rendering component.
	 * @return	Pointer to the FLandscapeGizmoSceneProxy
	 */
	virtual FPrimitiveSceneProxy* CreateSceneProxy();
};

defaultproperties
{
	HiddenGame=true
	AlwaysLoadOnClient=false
	AlwaysLoadOnServer=false
	bSelectable=false
}
