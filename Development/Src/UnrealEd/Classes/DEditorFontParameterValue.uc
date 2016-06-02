/**
 * MaterialEditorInstanceConstant.uc: This is derived class for material instance editor parameter represenation.
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class DEditorFontParameterValue extends DEditorParameterValue
	native
	hidecategories(Object)
	dependson(UnrealEdTypes)
	collapsecategories;


var() Font		FontValue;
var() int		FontPage;
