//  ================================================================================================
//   * File Name:    InventoryBag
//   * Created By:   User
//   * Time Stamp:     21.7.2014 г. 00:00:05 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class InventoryBag extends Actor;

var int MaxSpaces;

var repnotify int Gold;
var repnotify Inventory InventoryChain;

replication
{
    if(bNetDirty) Gold, InventoryChain;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName=='Gold')
    {
    }
    if(VarName=='InventoryChain')
    {
    }
    //super.ReplicatedEvent(VarName);
}

simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
    local Inventory Item, LastItem;

    if( (NewItem != None) && !NewItem.bDeleteMe )
    {
        // if we don't have an inventory list, start here
        if( InventoryChain == None )
        {
            InventoryChain = newItem;
        }
        else
        {
            // Skip if already in the inventory.
            for (Item = InventoryChain; Item != None; Item = Item.Inventory)
            {
                if( Item == NewItem )
                {
                    return FALSE;
                }
                LastItem = Item;
            }
            LastItem.Inventory = NewItem;
        }


        NewItem.SetOwner( Instigator );
        NewItem.Instigator = Instigator;
        //NewItem.InvManager = Self;
        NewItem.GivenTo( Instigator, bDoNotActivate);

        // Trigger inventory event
        Instigator.TriggerEventClass(class'SeqEvent_GetInventory', NewItem);
        return TRUE;
    }

    return FALSE;
}


/**
 * Attempts to remove an item from the inventory list if it exists.
 *
 * @param   Item    Item to remove from inventory
 */
 simulated function RemoveFromInventory(Inventory ItemToRemove)
{
    local Inventory Item;
    local bool      bFound;

    if( ItemToRemove != None )
    {
        if( InventoryChain == ItemToRemove )
        {
            bFound = TRUE;
            InventoryChain = ItemToRemove.Inventory;
        }
        else
        {
            // If this item is in our inventory chain, unlink it.
            for(Item = InventoryChain; Item != None; Item = Item.Inventory)
            {
                if( Item.Inventory == ItemToRemove )
                {
                    bFound = TRUE;
                    Item.Inventory = ItemToRemove.Inventory;
                    break;
                }
            }
        }

        if( bFound )
        {
            `Log("removed" @ ItemToRemove);
            ItemToRemove.ItemRemovedFromInvManager();
            ItemToRemove.SetOwner(None);
            ItemToRemove.Inventory = None;
        }

        // make sure we don't have other references to the item
        if( ItemToRemove == Instigator.Weapon )
        {
            Instigator.Weapon = None;
        }

    }
}

defaultproperties
{
    bHidden=false
    bAlwaysRelevant=true
    Gold=0
    MaxSpaces = 20
}