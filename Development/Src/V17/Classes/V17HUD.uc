//  ================================================================================================
//   * File Name:    V17Weapon2
//   * Created By:   User
//   * Time Stamp:     5.2.2014 г. 00:54:17 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17HUD extends UDKHUD;
 

var float CrosshairSize;
var float holeSize;

var V17GFxInventory InventoryMovie;

function InitInventory()
{
    
    if (InventoryMovie == None)
    {
        InventoryMovie = new class'V17GFxInventory';
    }

    InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
    
    InventoryMovie.SetTimingMode(TM_Real);
    InventoryMovie.Start();
      
    InventoryMovie.SetPC(PlayerOwner);
    
    // add a few ignore keys so we can still move, toggle the inventory or open a menu
    InventoryMovie.AddFocusIgnoreKey('Escape');
    InventoryMovie.AddFocusIgnoreKey('F10');
    InventoryMovie.AddFocusIgnoreKey('I');
    InventoryMovie.AddFocusIgnoreKey('W');
    InventoryMovie.AddFocusIgnoreKey('A');
    InventoryMovie.AddFocusIgnoreKey('S');
    InventoryMovie.AddFocusIgnoreKey('D');

    InventoryMovie.Advance(0.1f);
    ToggleInventory(false);
    
   
}

function ToggleInventory(optional bool bOpen)
{
    local pawn PawnOwner;
    if ( InventoryMovie != None && !bOpen)
    {
        InventoryMovie.LootScreen(false, true);
        InventoryMovie.LootScreen(false, false);

        InventoryMovie.Close(false);
    }
    else
    {
        InventoryMovie.Start();
        InventoryMovie.SetUpInventory();
        
        PawnOwner = Pawn(PlayerOwner.ViewTarget);
        // check if we're looting
        if (V17Pawn(PawnOwner) != None && V17Pawn(PawnOwner).LootedPawn != None && VSize2D(PawnOwner.Location - V17Pawn(PawnOwner).LootedPawn.Location) <= V17Pawn(PawnOwner).LootDistance)
        {
            InventoryMovie.SetUpLoot();
        }
    }
}

//function DrawPressEToDoSmth()

event DrawHUD()
{
    local color cs;
    super.DrawHUD();
    
    
    if(PlayerOwner != none && PlayerOwner.Pawn != none)
    {
        
        Canvas.DrawColor = WhiteColor;
        Canvas.Font = class'Engine'.Static.GetLargeFont();
        Canvas.SetPos(Canvas.ClipX * 0.01, Canvas.ClipY * 0.85);
        Canvas.DrawText("HEALTH:"@PlayerOwner.Pawn.Health);
 
        
        Canvas.SetDrawColor(0,255,0,255);

        CrosshairSize = 6;
        holeSize=2;
        cs=MakeColor(0,255,0,255);
        //Canvas.Draw2DLine(1,2,3,4,cs);
        Canvas.Draw2DLine(Canvas.ClipX * 0.5 - CrosshairSize, Canvas.ClipY*0.5 -CrosshairSize, Canvas.ClipX*0.5 -holeSize, Canvas.ClipY*0.5 - holeSize, cs);
        Canvas.Draw2DLine(Canvas.ClipX * 0.5 + CrosshairSize, Canvas.ClipY*0.5 +CrosshairSize, Canvas.ClipX*0.5 +holeSize, Canvas.ClipY*0.5 + holeSize, cs);
        Canvas.Draw2DLine(Canvas.ClipX * 0.5 + CrosshairSize, Canvas.ClipY*0.5 -CrosshairSize, Canvas.ClipX*0.5 +holeSize, Canvas.ClipY*0.5 - holeSize, cs);
        Canvas.Draw2DLine(Canvas.ClipX * 0.5 - CrosshairSize, Canvas.ClipY*0.5 +CrosshairSize, Canvas.ClipX*0.5 -holeSize, Canvas.ClipY*0.5 + holeSize, cs);
        
        //Canvas.SetPos(CenterX - CrosshairSize, CenterY);
        //Canvas.DrawRect(2*CrosshairSize + 1, 1);

        //Canvas.SetPos(CenterX, CenterY - CrosshairSize);
        //Canvas.DrawRect(1, 2*CrosshairSize + 1);    
    }
}
 
defaultproperties
{
}