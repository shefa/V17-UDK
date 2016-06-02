/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_GiveInventory extends SequenceAction;

var() array<class<Inventory> >			InventoryList;
var() bool bClearExisting;
var() bool bForceReplace;

defaultproperties
{
	ObjName="Give Inventory"
	ObjCategory="Pawn"
}
