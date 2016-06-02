//  ================================================================================================
//   * File Name:    V17PlayerController
//   * Created By:   User
//   * Time Stamp:     30.1.2014 ??. 01:12:17 ??.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * ?? Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17PlayerController extends UTPlayerController;


var Pawn Hero;
var Pawn OtherP;
var V17Pawn myPawn;

var int MyTypeOfPlayer;

//min distance to switch pawns EBI GO TUI PO KUSNO
var int CrashingDistance;
var bool bA, bW, bD, bAlt;
var float RotationSpeed; 


exec Function WhatItemsDoIHave()
{
    local V17Weapon V17Weap;
    local V17Inventory V17Inv;
    local V17InventoryManager V17InvM;
    
    V17InvM=V17InventoryManager(Pawn.InvManager);
    
    ForEach V17InvM.InventoryActors(class'V17Weapon', V17Weap) `log("Weapon "$string(V17Weap.Name)$" at slot "$V17Weap.ItemSlot);
    ForEach V17InvM.InventoryActors(class'V17Inventory', V17Inv) `log("Item "$string(V17Inv.Name)$" at slot "$V17Inv.ItemSlot);
}

exec Function WhoAmI(){
    
    local GameReplicationInfo           GRI;
    local PlayerReplicationInfo         PRI;
    local int theID;
    
    //calling player info
    
    
    //Get GRI
    GRI = WorldInfo.GRI;
    
    //loop thru all player infos
    foreach GRI.PRIArray(PRI) {
        
        if (playerreplicationinfo == PRI)
        {
            clientmessage("this is my info!");

            theID = V17ReplicationInfo(PRI).playerID;

        clientmessage("YourUniqueID"@theID);
        }
    }
}

reliable client function CreateHud()
{
    if ( myHUD != None )
    {
        myHUD.Destroy();
    }
    `log("CREATING THE HUD ON THE PLAYER");
    myHUD  = spawn(class'V17HUD', self);
    V17HUD(myHUD).InitInventory();
}


//KEY EVENTS STUFF

exec function SheathWeapon()
{
    if(Role<ROLE_Authority) ServerSheath();
    else{
        //`log("============");
        //`log( "sheath weapon called, equippedwep? "@V17Pawn(Pawn).HasEquippedWeapon@" currwep "@V17Pawn(Pawn).CurrentWeapon);
    if(V17Pawn(Pawn).HasEquippedWeapon)
    {
        //Character(Pawn).WeaponSheathed=!Character(Pawn).WeaponSheathed;
        V17Pawn(Pawn).CurrentWeapon.SetMode(V17Pawn(Pawn).CurrentWeapon.Sheathed);
    }
    }
}

reliable server function ServerSheath()
{
    SheathWeapon();
}

exec function bbA(bool aa)
{
    //`log( "bba called ");
    if(Role<ROLE_Authority) ServerBB(aa,1);
    bA=aa;
}
exec function bbD(bool aa)
{ 
    //`log( "bbd called ");
    if(Role<ROLE_Authority) ServerBB(aa,2);
    bD=aa;
}
exec function bbW(bool aa)
{
    //`log( "bbw called ");
    if(Role<ROLE_Authority) ServerBB(aa,3);
    bW=aa;
}
exec function bbAlt(bool aa)
{
    //`log( "bbalt called ");
    if(Role<ROLE_Authority) ServerBB(aa,4);
    bAlt=aa;
}

reliable server function ServerBB(bool aa, int mode)
{
    if(mode==1) bbA(aa);
    if(mode==2) bbD(aa);
    if(mode==3) bbW(aa);
    if(mode==4) bbAlt(aa);
}

exec function Walk()
{
    if(Role<ROLE_Authority) WalkServ();
    //`log("fagot walkin ");
     V17Pawn(Pawn).GroundSpeed = V17Pawn(Pawn).Default.Groundspeed;
     V17Pawn(Pawn).AirSpeed = V17Pawn(Pawn).Default.AirSpeed;
}

exec function Run()
{
    if(Role<ROLE_Authority) RunServ();
    // `log( "fagot runnin");
    V17Pawn(Pawn).GroundSpeed = V17Pawn(Pawn).speed2;
    if(Dragon(Pawn)!=none) V17Pawn(Pawn).AirSpeed = V17Pawn(Pawn).speed3;
}

reliable server function WalkServ()
{
    Walk();
}
reliable server function RunServ()
{
    Run();
}


reliable server function PawnServer()
{
    PawnSwap();
}

//this function is called by a button press
exec function PawnSwap()
{
    `log( "PAWN SWAP CALLED @ROLE "@Role@Pawn);
    if(Role<ROLE_Authority)
    {
        PawnServer();
        return;
    }
    
    if( Pawn.isA('Character') )
    {
          
     //check if theres a pawn near by
    ForEach Pawn.OverlappingActors(class'Pawn', OtherP, CrashingDistance)
    {
        if (OtherP != None && OtherP != Pawn) //if there is one close enough
        {
          //possess the pawn
          
          Hero=Pawn;
          UnPossess(); 
          Possess(OtherP, false);
          RotationSpeed=5;
          break;
        }
    }
    }
    else
    {
        UnPossess();
        //Hero.Detach(OtherP);
        //OtherP.Detach(Hero);
        Possess(Hero, false);
        RotationSpeed=8;
    }
}

exec function SwitchWeapon(byte T)
{
    if (Character(Pawn) != None)
    {
         //WorldInfo.Game.Broadcast(self,"switchin weap "); 
         Character(Pawn).SwitchWeapon(t);
    }
}

 reliable server function ServerJump()
 {
     MyJump();
 }

exec function MyJump()
{
    local Dragon drag;
    drag=Dragon(Pawn);
    if(Role<Role_Authority) { ServerJump(); return;}
    if( !IsInState( 'PlayerFlying' ) && drag!=none )
    {
        GotoState( 'PlayerFlying' );
        //bCheatFlying = true;
        SetTimer( 2.0f, true,  nameof(Land1) );
    }
}


function Land1()
{
    local Dragon drag;
    drag=Dragon(Pawn);
    if(IsInState( 'PlayerFlying'))
    {
    if( drag != none )
    {
        //WorldInfo.Game.Broadcast(self,  "Not none:  "@drag );

        if( !FastTrace( drag.Location + vect( 0, 0, -320 ), drag.Location, vect( 5, 5, 5 ), false ) )
        {
            if( drag.Physics != Phys_Walking )
            {
                drag.SetPhysics( Phys_Walking );

                if( !IsInState( 'PlayerWalking' ) )
                {
                    GotoState( 'PlayerWalking' );
                    ClearTimer( nameof( Land1 ) );
                    //ClearTimer( nameof( Land ) );
                }
            }
        }
    }
    }
}

exec function PrevWeapon()
{
    // disabled changing of weapons
}

exec function NextWeapon()
{
    // disabled changing of weapons
}

exec function ToggleInventory()
{
    V17HUD(myHUD).ToggleInventory(!V17HUD(myHUD).InventoryMovie.bMovieIsOpen);
}


defaultproperties
{
    Hero=None
    RotationSpeed=8
    CrashingDistance=80
    MyTypeOfPlayer=0
}