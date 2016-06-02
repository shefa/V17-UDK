//  ================================================================================================
//   * File Name:    V17ReplicationInfo
//   * Created By:   User
//   * Time Stamp:     21.5.2014 г. 17:38:14 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17ReplicationInfo extends PlayerReplicationInfo;

var RepNotify V17InventoryManager V17InvManager;

replication
{
    if(bNetDirty && Role==Role_Authority)
    V17InvManager;
}

simulated event ReplicatedEvent(name VarName)
{
    local Playercontroller PC;
    if(varname== 'V17InvManager')
    {
         ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            if ( PC.PlayerReplicationInfo == self )
            {
                `log( "changed InvManager ");
                PC.Pawn.InvManager=V17InvManager;
            }
        }
    }
    super.ReplicatedEvent(VarName);
}

/*
var RepNotify int playerID;

// Replication block
replication
{

    if (bNetDirty && Role == Role_Authority)
    playerID;
}

simulated event ReplicatedEvent(name VarName)
{
    local Playercontroller PC;
    
    if (varname == 'playerID') {
        ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            if ( PC.PlayerReplicationInfo == self )
            {
                `log( "changed id ");
            }
        }
    }
    
    super.ReplicatedEvent(VarName);
}
*/

defaultproperties
{
    bOnlyDirtyReplication   = true
    bAlwaysRelevant         = true
    //NetUpdateFrequency        = 3
}
