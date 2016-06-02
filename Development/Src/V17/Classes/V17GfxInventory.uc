class V17GfxInventory extends GFxMoviePlayer;

var GFxObject Gold_MC;

var Texture2D DefaultIcon;

var PlayerController PC;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);
    
    return true;
}

function setPC(PlayerController C)
{
    PC=C;
}

simulated function SetUpInventory()
{
    local V17PlayerController V17PC;
    local V17Pawn V17P;
    local V17InventoryManager V17InvM;

    local V17Weapon V17Weap;
    local V17Inventory V17Inv;

    local Texture2D ItemIcon;

    V17PC = V17PlayerController(PC);
    V17P = V17Pawn(V17PC.Pawn);
    V17InvM = V17InventoryManager(V17P.InvManager);
    //`log( "LOOOOOOK !!!! setup INVENOTRY CALLED ");
    //`log( "PC "@V17PC@"Pawn "@V17P@"Inv manager"@V17InvM);
    // send each of the weapons to the inventory screen
    ForEach V17InvM.InventoryActors(class'V17Weapon', V17Weap)
    {
        `log("SendItem "$string(V17Weap.Name)$" slot "$V17Weap.ItemSlot);
        SendItem("backpack", string(V17Weap.Name), V17Weap.ItemSlot, string(V17Weap.WeaponType1), V17Weap.ObjectName, "1", string(V17Weap.Durability), string(V17Weap.MaxDurability), string(V17Weap.Value));
        
        // replace the slot's icon with the one from the item
        ItemIcon=V17Weap.InventoryTexture;
        if (ItemIcon != None)
        {
            // we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Backpack_0
            SetExternalTexture("Icon_Backpack_"$Repl(V17Weap.ItemSlot, "slot", ""), ItemIcon);
        }
    }

    // send each of the non-weapons to the inventory screen
    ForEach V17InvM.InventoryActors(class'V17Inventory', V17Inv)
    {
        //`log("SendItem "$string(V17Inv.Name)$" slot "$V17Inv.ItemSlot);
        SendItem("backpack", string(V17Inv.Name), V17Inv.ItemSlot, string(V17Inv.ItemType), V17Inv.ObjectName, string(V17Inv.Quantity), string(V17Inv.Durability), string(V17Inv.MaxDurability), string(V17Inv.Value));
        
        // replace the slot's icon with the one from the item
        ItemIcon=V17Inv.InventoryTexture;
        if (ItemIcon != None)
        {
            // we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Backpack_0
            SetExternalTexture("Icon_Backpack_"$Repl(V17Inv.ItemSlot, "slot", ""), ItemIcon);
        }
    }

    // send the gold amount to the inventory screen
    SendGold("backpack", V17InvM.Gold);

    // hide all loot screens
    LootScreen(false, true);
    LootScreen(false, false);
}


simulated function SetUpLootContainer()
{
    local V17PlayerController V17PC;
    
    local V17InventoryContainer V17IC;
    local V17InventoryManager V17InvM;
    
    local String LootType;
    

    V17PC = V17PlayerController(PC);
    
        V17IC = V17InventoryContainer(V17Pawn(V17PC.Pawn).LootedPawn);
        V17InvM = V17IC.V17InvM;
        //`log("looting "$V17IC);
        LootType = "Container";
        LootScreen(true, true);
    
    if (V17InvM == None)
        return;

    serverSomething(V17InvM);

    // send the gold amount to the inventory screen
    SendGold(LootType, V17InvM.Gold);
}

reliable server function serverSomething(V17InventoryManager V17InvM)
{
    local Inventory faggot;  
    
    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    local String LootType;
    local Texture2D ItemIcon;
    LootType = "Container";
    `log( "looting container from server");
    
      
    
    
    for(faggot=V17InvM.InventoryChain;faggot!=none; faggot=faggot.Inventory)
    {
        if(V17Weapon(faggot)!=none) {
            V17Weap=V17Weapon(faggot);
            
            `log("SendItem loot "$string(V17Weap.Name)$" slot "$V17Weap.ItemSlot);
            SendItem(LootType, string(V17Weap.Name), V17Weap.ItemSlot, string(V17Weap.WeaponType1), V17Weap.ObjectName, "1", string(V17Weap.Durability), string(V17Weap.MaxDurability), string(V17Weap.Value));

            // replace the slot's icon with the one from the item
             ItemIcon=V17Weap.InventoryTexture;
            if (ItemIcon != None) SetExternalTexture("Icon_"$LootType$"_"$Repl(V17Weap.ItemSlot, "slot", ""), ItemIcon);
            
        }
        if(V17Inventory(faggot)!=none){
            V17Inv=V17Inventory(faggot);
            `log("SendItem loot "$string(V17Inv.Name)$" slot "$V17Inv.ItemSlot);
            SendItem(LootType, string(V17Inv.Name), V17Inv.ItemSlot, string(V17Inv.ItemType), V17Inv.ObjectName, string(V17Inv.Quantity), string(V17Inv.Durability), string(V17Inv.MaxDurability), string(V17Inv.Value));

            // replace the slot's icon with the one from the item
            ItemIcon=V17Inv.InventoryTexture;
            if (ItemIcon != None) SetExternalTexture("Icon_"$LootType$"_"$Repl(V17Inv.ItemSlot, "slot", ""), ItemIcon);
        }
    }
    
 }

simulated function SetUpLoot()
{
    local V17PlayerController V17PC;
    local V17Pawn V17P;
    local V17InventoryContainer V17IC;
    local V17InventoryManager V17InvM;
    local String LootType;

    local V17Weapon V17Weap;
    local V17Inventory V17Inv;

    local Texture2D ItemIcon;

    V17PC = V17PlayerController(PC);
    if (V17InventoryContainer(V17Pawn(V17PC.Pawn).LootedPawn) != None)
    {
        //return;
        V17IC = V17InventoryContainer(V17Pawn(V17PC.Pawn).LootedPawn);
        V17InvM = V17IC.V17InvM;
        `log("looting "$V17IC);
        LootType = "Container";
        LootScreen(true, true);
        serverSomething(V17InvM);
        
    }
    else if (V17Pawn(V17Pawn(V17PC.Pawn).LootedPawn) != None)
    {
        V17P = V17Pawn(V17Pawn(V17PC.Pawn).LootedPawn);
        V17InvM = V17InventoryManager(V17P.InvManager);
        //`log("looting "$V17P);
        LootType = "Loot";
        LootScreen(true, false);
    }

    if (V17InvM == None)
        return;

    // send each of the weapons to the inventory screen
    ForEach V17InvM.InventoryActors(class'V17Weapon', V17Weap)
    {
        //`log("SendItem loot "$string(V17Weap.Name)$" slot "$V17Weap.ItemSlot);
        SendItem(LootType, string(V17Weap.Name), V17Weap.ItemSlot, string(V17Weap.WeaponType1), V17Weap.ObjectName, "1", string(V17Weap.Durability), string(V17Weap.MaxDurability), string(V17Weap.Value));

        // replace the slot's icon with the one from the item
        ItemIcon=V17Weap.InventoryTexture;
        if (ItemIcon != None)
        {
            // we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
            SetExternalTexture("Icon_"$LootType$"_"$Repl(V17Weap.ItemSlot, "slot", ""), ItemIcon);
        }
    }

    // send each of the non-weapons to the inventory screen
    ForEach V17InvM.InventoryActors(class'V17Inventory', V17Inv)
    {
        //`log("SendItem loot "$string(V17Inv.Name)$" slot "$V17Inv.ItemSlot);
        SendItem(LootType, string(V17Inv.Name), V17Inv.ItemSlot, string(V17Inv.ItemType), V17Inv.ObjectName, string(V17Inv.Quantity), string(V17Inv.Durability), string(V17Inv.MaxDurability), string(V17Inv.Value));

        // replace the slot's icon with the one from the item
        ItemIcon=V17Inv.InventoryTexture;
        if (ItemIcon != None)
        {
            // we need to extract the number from them ItemSlot string (ie. 0 from slot0), so in the end we get Icon_Loot_0
            SetExternalTexture("Icon_"$LootType$"_"$Repl(V17Inv.ItemSlot, "slot", ""), ItemIcon);
        }
    }

    // send the gold amount to the inventory screen
    SendGold(LootType, V17InvM.Gold);
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
    local V17PlayerController V17PC;
    local V17Pawn V17P, lootP;
    local V17InventoryContainer lootIC;
    local V17InventoryManager sourceInvM, destInvM, V17InvM, lootInvM;

    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    local bool bFound;
    local Vector DropLoc, HitNorm;

    local V17GoldPickup GoldDrop;

    local Texture2D ItemIcon;

    //`log("DraggedItem "$itemID$" from "$FromContainer$" "$FromSlot$" to "$ToContainer$" "$ToSlot);

    V17PC = V17PlayerController(PC);
    V17P = V17Pawn(V17PC.Pawn);
    V17InvM = V17InventoryManager(V17P.InvManager);

    if (V17InventoryContainer(V17P.LootedPawn) != None)
    {
        //return;
        lootIC = V17InventoryContainer(V17P.LootedPawn);
        lootInvM = lootIC.V17InvM;
    }
    else if (V17Pawn(V17P.LootedPawn) != None)
    {
        lootP = V17Pawn(V17P.LootedPawn);
        lootInvM = V17InventoryManager(lootP.InvManager);
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
        sourceInvM = V17InvM;
    }
    // get the destination inventory manager
    if (ToContainer == "panelLoot" || ToContainer == "panelContainer")
    {
        destInvM = lootInvM;
    }
    else if (ToContainer == "panelBackpack" || ToContainer == "panelChar")
    {
        destInvM = V17InvM;
    }

    // handle it if it's gold
    if (FromSlot == "gold")
    {
        // check if we're dropping it
        if (ToSlot == "slotdrop")
        {
            //`log("drop gold "$GoldAmt);
            DropLoc = V17P.Location + Vector(V17P.Rotation) * 150.0f;
            DropLoc.X += RandRange(-10.0f, 10.0f);
            DropLoc.Y += RandRange(-10.0f, 10.0f);
            GoldDrop = V17P.Spawn(class'V17GoldPickup',,, DropLoc);
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
    ForEach sourceInvM.InventoryActors(class'V17Weapon', V17Weap)
    {
        if (V17Weap.Name == name(itemID))
        {
            bFound = true;
            V17Weap.ItemSlot = ToSlot;

            // handle unequipping
            if (FromSlot == "slotWeapon")
            {
                V17Weap.GotoState('Inactive');
                V17Weap.ForceEndFire();
                V17Weap.DetachWeapon();
                V17Pawn(sourceInvM.Owner).Weapon = None;
                //destInvM.ClientWeaponSet(None, true);
            }

            sourceInvM.RemoveFromInventory(V17Weap);
            if (destInvM != None)
            {
                destInvM.AddInventory(V17Weap, true);
            }

            // handle equipping
            if (ToSlot == "slotWeapon")
            {
                destInvM.ClientWeaponSet(V17Weap, true);
            }
            // handle dropping
            else if (ToSlot == "slotdrop")
            {
                V17P.Trace(DropLoc, HitNorm, V17P.Location + Vector(V17P.Rotation) * 150.0f, V17P.Location, true);
                if (DropLoc == vect(0,0,0))
                {
                    DropLoc = V17P.Location + Vector(V17P.Rotation) * 150.0f;
                    DropLoc.X += RandRange(-10.0f, 10.0f);
                    DropLoc.Y += RandRange(-10.0f, 10.0f);
                }
                V17Weap.DropFrom(DropLoc + Vect(0,0,20), Vector(V17P.Rotation));
            }

            // replace the slot's icon with the one from the item
            ItemIcon=V17Weap.InventoryTexture;
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
        ForEach sourceInvM.InventoryActors(class'V17Inventory', V17Inv)
        {
            if (V17Inv.Name == name(itemID))
            {
                bFound = true;
                V17Inv.ItemSlot = ToSlot;

                // handle unequpping
                if (FromSlot == "slotHelm" || FromSlot == "slotArmor" || FromSlot == "slotCloak" 
                    || FromSlot == "slotGloves" || FromSlot == "slotBracers" || FromSlot == "slotShoes")
                {
                    V17Inv.SetOwner(None);
                    V17Inv.UpdateAttachment();
                    V17Pawn(sourceInvM.Owner).ForceUpdateComponents(false, false);
                }

                sourceInvM.RemoveFromInventory(V17Inv);
                if (destInvM != None)
                {
                    destInvM.AddInventory(V17Inv, true);
                }

                // handle dropping
                if (ToSlot == "slotdrop")
                {
                    V17P.Trace(DropLoc, HitNorm, V17P.Location + Vector(V17P.Rotation) * 150.0f, V17P.Location, true);
                    if (DropLoc == vect(0,0,0))
                    {
                        DropLoc = V17P.Location + Vector(V17P.Rotation) * 150.0f;
                        DropLoc.X += RandRange(-10.0f, 10.0f);
                        DropLoc.Y += RandRange(-10.0f, 10.0f);
                    }
                    V17Inv.DropFrom(DropLoc + Vect(0,0,20), Vector(V17P.Rotation));
                }
                // handle equipping
                else if (ToSlot == "slotHelm" || ToSlot == "slotArmor" || ToSlot == "slotCloak" 
                    || ToSlot == "slotGloves" || ToSlot == "slotBracers" || ToSlot == "slotShoes")
                {
                    V17Inv.UpdateAttachment();
                    V17Pawn(destInvM.Owner).ForceUpdateComponents(false, false);
                }

                // replace the slot's icon with the one from the item
                ItemIcon=V17Inv.InventoryTexture;
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


/*

simulated event DraggedContainer(string FromContainer, string FromSlot, string ToContainer, string ToSlot, string itemID)
{
    local V17PlayerController V17PC;
    local V17Pawn V17P;
    local V17InventoryContainer lootIC;
    local V17InventoryManager sourceInvM, destInvM, V17InvM, lootInvM;

    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    local bool bFound;
    local Vector DropLoc, HitNorm;

    local V17GoldPickup GoldDrop;

    local Texture2D ItemIcon;

    `log("DraggedItem "$itemID$" from "$FromContainer$" "$FromSlot$" to "$ToContainer$" "$ToSlot);

    V17PC = V17PlayerController(PC);
    V17P = V17Pawn(V17PC.Pawn);
    V17InvM = V17InventoryManager(V17P.InvManager);

    lootIC = V17InventoryContainer(V17P.LootedPawn);
    lootInvM = lootIC.V17InvM;
    
    
    // if the dragged item is empty replace its icon back to default
    if (itemID == "" && DefaultIcon != None)
    {
        SetExternalTexture("Icon_"$Repl(ToContainer, "panel", "")$"_"$Repl(ToSlot, "slot", ""), DefaultIcon);
        return;
    }

    // get the source inventory manager
    if (FromContainer == "panelContainer")  sourceInvM = lootInvM;
    else if (FromContainer == "panelBackpack" || FromContainer == "panelChar")  sourceInvM = V17InvM;
    
    // get the destination inventory manager
    if (ToContainer == "panelContainer") destInvM = lootInvM;
    else if (ToContainer == "panelBackpack" || ToContainer == "panelChar")destInvM = V17InvM;
    
    // handle it if it's gold
    if (FromSlot == "gold")
    {
        // check if we're dropping it
        if (ToSlot == "slotdrop") sourceInvM.Gold = 0;
        else
        {
            // take it off the source invmanager and into the destination invmanager
            destInvM.Gold += sourceInvM.Gold;
            sourceInvM.Gold = 0;
        }
    }
    
    // find the dragged item (weapon?) in the inventory manager
    ForEach sourceInvM.InventoryActors(class'V17Weapon', V17Weap)
    {
        if (V17Weap.Name == name(itemID))
        {
            bFound = true;
            V17Weap.ItemSlot = ToSlot;

            // handle unequipping
            if (FromSlot == "slotWeapon")
            {
                V17Weap.GotoState('Inactive');
                V17Weap.ForceEndFire();
                V17Weap.DetachWeapon();
                V17Pawn(sourceInvM.Owner).Weapon = None;
                //destInvM.ClientWeaponSet(None, true);
            }

            sourceInvM.RemoveFromInventory(V17Weap);
            if (destInvM != None)
            {
                destInvM.AddInventory(V17Weap, true);
            }

            // handle equipping
            if (ToSlot == "slotWeapon")
            {
                destInvM.ClientWeaponSet(V17Weap, true);
            }
            // handle dropping
            else if (ToSlot == "slotdrop")
            {
                V17P.Trace(DropLoc, HitNorm, V17P.Location + Vector(V17P.Rotation) * 150.0f, V17P.Location, true);
                if (DropLoc == vect(0,0,0))
                {
                    DropLoc = V17P.Location + Vector(V17P.Rotation) * 150.0f;
                    DropLoc.X += RandRange(-10.0f, 10.0f);
                    DropLoc.Y += RandRange(-10.0f, 10.0f);
                }
                V17Weap.DropFrom(DropLoc + Vect(0,0,20), Vector(V17P.Rotation));
            }

            // replace the slot's icon with the one from the item
            ItemIcon=V17Weap.InventoryTexture;
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
        ForEach sourceInvM.InventoryActors(class'V17Inventory', V17Inv)
        {
            if (V17Inv.Name == name(itemID))
            {
                bFound = true;
                V17Inv.ItemSlot = ToSlot;

                // handle unequpping
                if (FromSlot == "slotHelm" || FromSlot == "slotArmor" || FromSlot == "slotCloak" 
                    || FromSlot == "slotGloves" || FromSlot == "slotBracers" || FromSlot == "slotShoes")
                {
                    V17Inv.SetOwner(None);
                    V17Inv.UpdateAttachment();
                    V17Pawn(sourceInvM.Owner).ForceUpdateComponents(false, false);
                }

                sourceInvM.RemoveFromInventory(V17Inv);
                if (destInvM != None)
                {
                    destInvM.AddInventory(V17Inv, true);
                }

                // handle dropping
                if (ToSlot == "slotdrop")
                {
                    V17P.Trace(DropLoc, HitNorm, V17P.Location + Vector(V17P.Rotation) * 150.0f, V17P.Location, true);
                    if (DropLoc == vect(0,0,0))
                    {
                        DropLoc = V17P.Location + Vector(V17P.Rotation) * 150.0f;
                        DropLoc.X += RandRange(-10.0f, 10.0f);
                        DropLoc.Y += RandRange(-10.0f, 10.0f);
                    }
                    V17Inv.DropFrom(DropLoc + Vect(0,0,20), Vector(V17P.Rotation));
                }
                // handle equipping
                else if (ToSlot == "slotHelm" || ToSlot == "slotArmor" || ToSlot == "slotCloak" 
                    || ToSlot == "slotGloves" || ToSlot == "slotBracers" || ToSlot == "slotShoes")
                {
                    V17Inv.UpdateAttachment();
                    V17Pawn(destInvM.Owner).ForceUpdateComponents(false, false);
                }

                // replace the slot's icon with the one from the item
                ItemIcon=V17Inv.InventoryTexture;
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

*/
DefaultProperties
{
    MovieInfo=SwfMovie'myUI.myInventory'

    DefaultIcon=Texture2D'myUI.Icon_Bag'
    bCaptureInput=true
}