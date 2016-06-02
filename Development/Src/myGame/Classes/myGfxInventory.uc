class myGfxInventory extends GFxMoviePlayer;

var GFxObject Gold_MC;

var Texture2D DefaultIcon;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

    return true;
}

simulated function SetUpInventory()
{
	local myPlayerController myPC;
	local myPawn myP;
	local myInventoryManager myInvM;

	local myWeapon myWeap;
	local myInventory myInv;

	local Texture2D ItemIcon;

	myPC = myPlayerController(GetPC());
	myP = myPawn(myPC.Pawn);
	myInvM = myInventoryManager(myP.InvManager);

	// send each of the weapons to the inventory screen
	ForEach myInvM.InventoryActors(class'myWeapon', myWeap)
	{
		//`log("SendItem "$string(myWeap.Name)$" slot "$myWeap.ItemSlot);
		SendItem("backpack", string(myWeap.Name), myWeap.ItemSlot, string(myWeap.WeaponType), myWeap.ObjectName, "1", string(myWeap.Durability), string(myWeap.MaxDurability), string(myWeap.Value));
		
		// replace the slot's icon with the one from the item
		ItemIcon=myWeap.InventoryTexture;
		if (ItemIcon != None)
		{
			// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Backpack_0
			SetExternalTexture("Icon_Backpack_"$Repl(myWeap.ItemSlot, "slot", ""), ItemIcon);
		}
	}

	// send each of the non-weapons to the inventory screen
	ForEach myInvM.InventoryActors(class'myInventory', myInv)
	{
		//`log("SendItem "$string(myInv.Name)$" slot "$myInv.ItemSlot);
		SendItem("backpack", string(myInv.Name), myInv.ItemSlot, string(myInv.ItemType), myInv.ObjectName, string(myInv.Quantity), string(myInv.Durability), string(myInv.MaxDurability), string(myInv.Value));
		
		// replace the slot's icon with the one from the item
		ItemIcon=myInv.InventoryTexture;
		if (ItemIcon != None)
		{
			// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Backpack_0
			SetExternalTexture("Icon_Backpack_"$Repl(myInv.ItemSlot, "slot", ""), ItemIcon);
		}
	}

	// send the gold amount to the inventory screen
	SendGold("backpack", myInvM.Gold);

	// hide all loot screens
	LootScreen(false, true);
	LootScreen(false, false);
}

simulated function SetUpLoot()
{
	local myPlayerController myPC;
	local myPawn myP;
	local myInventoryContainer myIC;
	local myInventoryManager myInvM;
	local String LootType;

	local myWeapon myWeap;
	local myInventory myInv;

	local Texture2D ItemIcon;

	myPC = myPlayerController(GetPC());
	if (myInventoryContainer(myPawn(myPC.Pawn).LootedPawn) != None)
	{
		myIC = myInventoryContainer(myPawn(myPC.Pawn).LootedPawn);
		myInvM = myInventoryManager(myIC.InvManager);
		//`log("looting "$myIC);
		LootType = "Container";
		LootScreen(true, true);
	}
	else if (myPawn(myPawn(myPC.Pawn).LootedPawn) != None)
	{
		myP = myPawn(myPawn(myPC.Pawn).LootedPawn);
		myInvM = myInventoryManager(myP.InvManager);
		//`log("looting "$myP);
		LootType = "Loot";
		LootScreen(true, false);
	}

	if (myInvM == None)
		return;

	// send each of the weapons to the inventory screen
	ForEach myInvM.InventoryActors(class'myWeapon', myWeap)
	{
		//`log("SendItem loot "$string(myWeap.Name)$" slot "$myWeap.ItemSlot);
		SendItem(LootType, string(myWeap.Name), myWeap.ItemSlot, string(myWeap.WeaponType), myWeap.ObjectName, "1", string(myWeap.Durability), string(myWeap.MaxDurability), string(myWeap.Value));

		// replace the slot's icon with the one from the item
		ItemIcon=myWeap.InventoryTexture;
		if (ItemIcon != None)
		{
			// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
			SetExternalTexture("Icon_"$LootType$"_"$Repl(myWeap.ItemSlot, "slot", ""), ItemIcon);
		}
	}

	// send each of the non-weapons to the inventory screen
	ForEach myInvM.InventoryActors(class'myInventory', myInv)
	{
		//`log("SendItem loot "$string(myInv.Name)$" slot "$myInv.ItemSlot);
		SendItem(LootType, string(myInv.Name), myInv.ItemSlot, string(myInv.ItemType), myInv.ObjectName, string(myInv.Quantity), string(myInv.Durability), string(myInv.MaxDurability), string(myInv.Value));

		// replace the slot's icon with the one from the item
		ItemIcon=myInv.InventoryTexture;
		if (ItemIcon != None)
		{
			// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
			SetExternalTexture("Icon_"$LootType$"_"$Repl(myInv.ItemSlot, "slot", ""), ItemIcon);
		}
	}

	// send the gold amount to the inventory screen
	SendGold(LootType, myInvM.Gold);
}

simulated function LootScreen(bool bOpen, bool bContainer)
{
	ActionScriptVoid("LootScreen");
}

simulated function SendItem(string ContainerType, string idemID, string itemSlot, string itemType, string itemName, string itemQuantity, string itemDurability, string itemMaxDurability, string itemValue)
{
	//`log("SendItem "$bEnabled$" "$itemID$" "$itemSlot$" "$itemType$" "$itemName$" "$itemQuantity$" "$itemWeight$" "$itemQuality$" "$itemDurability$" "$itemMaxDurability);
	ActionScriptVoid("SetItemByString");
}

simulated function SendGold(string ContainerType, float Amount)
{
	ActionScriptVoid("SetGoldByString");
}

simulated function DraggedItem(string FromContainer, string FromSlot, string ToContainer, string ToSlot, string itemID)
{
	local myPlayerController myPC;
	local myPawn myP, lootP;
	local myInventoryContainer lootIC;
	local myInventoryManager sourceInvM, destInvM, myInvM, lootInvM;

	local myWeapon myWeap;
	local myInventory myInv;
	local bool bFound;
	local Vector DropLoc, HitNorm;

	local myGoldPickup GoldDrop;

	local Texture2D ItemIcon;

	//`log("DraggedItem "$itemID$" from "$FromContainer$" "$FromSlot$" to "$ToContainer$" "$ToSlot);

	myPC = myPlayerController(GetPC());
	myP = myPawn(myPC.Pawn);
	myInvM = myInventoryManager(myP.InvManager);

	if (myInventoryContainer(myP.LootedPawn) != None)
	{
		lootIC = myInventoryContainer(myP.LootedPawn);
		lootInvM = myInventoryManager(lootIC.InvManager);
	}
	else if (myPawn(myP.LootedPawn) != None)
	{
		lootP = myPawn(myP.LootedPawn);
		lootInvM = myInventoryManager(lootP.InvManager);
	}

	// if the dragged item is empty replace its icon back to default
	if (itemID == "" && DefaultIcon != None)
	{
		// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
		SetExternalTexture("Icon_"$Repl(ToContainer, "panel", "")$"_"$Repl(ToSlot, "slot", ""), DefaultIcon);
		return;
	}

	// get the source inventory manager
	if (FromContainer == "panelLoot" || FromContainer == "panelContainer")
	{
		sourceInvM = lootInvM;
	}
	else if (FromContainer == "panelBackpack" || FromContainer == "panelChar")
	{
		sourceInvM = myInvM;
	}
	// get the destination inventory manager
	if (ToContainer == "panelLoot" || ToContainer == "panelContainer")
	{
		destInvM = lootInvM;
	}
	else if (ToContainer == "panelBackpack" || ToContainer == "panelChar")
	{
		destInvM = myInvM;
	}

	// handle it if it's gold
	if (FromSlot == "gold")
	{
		// check if we're dropping it
		if (ToSlot == "slotdrop")
		{
			//`log("drop gold "$GoldAmt);
			DropLoc = myP.Location + Vector(myP.Rotation) * 150.0f;
			DropLoc.X += RandRange(-10.0f, 10.0f);
			DropLoc.Y += RandRange(-10.0f, 10.0f);
			GoldDrop = myP.Spawn(class'myGoldPickup',,, DropLoc);
			// take it off the source invmanager
			GoldDrop.GoldAmount = sourceInvM.Gold;
			sourceInvM.Gold = 0;
		}
		else
		{
			// take it off the source invmanager and into the destination invmanager
			destInvM.Gold += sourceInvM.Gold;
			sourceInvM.Gold = 0;
		}
	}

	// find the dragged item (weapon?) in the inventory manager
	ForEach sourceInvM.InventoryActors(class'myWeapon', myWeap)
	{
		if (myWeap.Name == name(itemID))
		{
			bFound = true;
			myWeap.ItemSlot = ToSlot;

			// handle unequipping
			if (FromSlot == "slotWeapon")
			{
				myWeap.GotoState('Inactive');
				myWeap.ForceEndFire();
				myWeap.DetachWeapon();
				myPawn(sourceInvM.Owner).Weapon = None;
				//destInvM.ClientWeaponSet(None, true);
			}

			sourceInvM.RemoveFromInventory(myWeap);
			if (destInvM != None)
			{
				destInvM.AddInventory(myWeap, true);
			}

			// handle equipping
			if (ToSlot == "slotWeapon")
			{
				destInvM.ClientWeaponSet(myWeap, true);
			}
			// handle dropping
			else if (ToSlot == "slotdrop")
			{
				myP.Trace(DropLoc, HitNorm, myP.Location + Vector(myP.Rotation) * 150.0f, myP.Location, true);
				if (DropLoc == vect(0,0,0))
				{
					DropLoc = myP.Location + Vector(myP.Rotation) * 150.0f;
					DropLoc.X += RandRange(-10.0f, 10.0f);
					DropLoc.Y += RandRange(-10.0f, 10.0f);
				}
				myWeap.DropFrom(DropLoc + Vect(0,0,20), Vector(myP.Rotation));
			}

			// replace the slot's icon with the one from the item
			ItemIcon=myWeap.InventoryTexture;
			if (ItemIcon != None)
			{
				// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
				SetExternalTexture("Icon_"$Repl(ToContainer, "panel", "")$"_"$Repl(ToSlot, "slot", ""), ItemIcon);
			}

			break;
		}
	}

	if (!bFound)
	{
		// find the dragged item (non-weapon?) in the inventory manager
		ForEach sourceInvM.InventoryActors(class'myInventory', myInv)
		{
			if (myInv.Name == name(itemID))
			{
				bFound = true;
				myInv.ItemSlot = ToSlot;

				// handle unequpping
				if (FromSlot == "slotHelm" || FromSlot == "slotArmor" || FromSlot == "slotCloak" 
					|| FromSlot == "slotGloves" || FromSlot == "slotBracers" || FromSlot == "slotShoes")
				{
					myInv.SetOwner(None);
					myInv.UpdateAttachment();
					myPawn(sourceInvM.Owner).ForceUpdateComponents(false, false);
				}

				sourceInvM.RemoveFromInventory(myInv);
				if (destInvM != None)
				{
					destInvM.AddInventory(myInv, true);
				}

				// handle dropping
				if (ToSlot == "slotdrop")
				{
					myP.Trace(DropLoc, HitNorm, myP.Location + Vector(myP.Rotation) * 150.0f, myP.Location, true);
					if (DropLoc == vect(0,0,0))
					{
						DropLoc = myP.Location + Vector(myP.Rotation) * 150.0f;
						DropLoc.X += RandRange(-10.0f, 10.0f);
						DropLoc.Y += RandRange(-10.0f, 10.0f);
					}
					myInv.DropFrom(DropLoc + Vect(0,0,20), Vector(myP.Rotation));
				}
				// handle equipping
				else if (ToSlot == "slotHelm" || ToSlot == "slotArmor" || ToSlot == "slotCloak" 
					|| ToSlot == "slotGloves" || ToSlot == "slotBracers" || ToSlot == "slotShoes")
				{
					myInv.UpdateAttachment();
					myPawn(destInvM.Owner).ForceUpdateComponents(false, false);
				}

				// replace the slot's icon with the one from the item
				ItemIcon=myInv.InventoryTexture;
				if (ItemIcon != None)
				{
					// we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
					SetExternalTexture("Icon_"$Repl(ToContainer, "panel", "")$"_"$Repl(ToSlot, "slot", ""), ItemIcon);
				}

				break;
			}
		}
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'myUI.myInventory'

	DefaultIcon=Texture2D'MyUI.Icon_Bag'
	bCaptureInput=true
}