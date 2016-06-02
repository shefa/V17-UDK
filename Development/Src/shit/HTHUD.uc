/*******************************************************************************
	HTHUD

	Creation date: 09/03/2010 05:04
	Copyright (c) 2010, Allar

*******************************************************************************/

class HTHUD extends UDKHUD
      config(UI);

/** The Pawn that is currently owning this hud */
var Pawn PawnOwner;

/** Points to the UT Pawn.  Will be resolved if in a vehicle */
var HTPawn HTPawnOwner;

/** Cached reference to the another hud texture */
var const Texture2D HudTexture;

var linearcolor HudTint;

/******************************************************************************
*   Common Colors - These are defined in DefaultUI.ini
******************************************************************************/
//var config color WhiteColor, RedColor, GreenColor; //Declared in HUD as const
var config color BlueColor, GrayColor, BlackColor;

var config color CrosshairColor, CrosshairShadowColor;

var bool bDrawColorPalette;

/******************************************************************************
*   HUD Stuff
******************************************************************************/

var bool bShowAmmo, bShowCrosshair;
var vector2d AmmoPosition;
var TextureCoordinates AmmoBGCoords;

/** Resolution dependent HUD scaling factor */
var float HUDScaleX, HUDScaleY;
/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** The percentage of the view that should be considered safe */
var float SafeRegionPct;
/** Holds the full width and height of the viewport */
var float FullWidth, FullHeight;


/**
 * Perform any value precaching, and set up various safe regions
 *
 * NOTE: NO DRAWING should ever occur in PostRender.  Put all drawing code in DrawHud().
 */
event PostRender()
{
	PawnOwner = Pawn(PlayerOwner.ViewTarget);
	if ( PawnOwner == None )
	{
		PawnOwner = PlayerOwner.Pawn;
	}

	HTPawnOwner = HTPawn(PawnOwner);

	// draw any debug text in real-time
	PlayerOwner.DrawDebugTextList(Canvas,RenderDelta);

	HUDScaleX = Canvas.ClipX/1280;
	HUDScaleY = Canvas.ClipX/1280;

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;

	FullWidth = Canvas.ClipX;
	FullHeight = Canvas.ClipY;

	if ( bShowHud )
	{
		DrawHud();

	}

	// let iphone draw any always present overlays
	DrawInputOverlays();
}

/**
 * This is the main drawing pump.  It will determine which hud we need to draw (Game or PostGame).  Any drawing that should occur
 * regardless of the game state should go here.
 */
function DrawHUD()
{
	local float x,y,w,h;

	// Create the safe region
	w = FullWidth * SafeRegionPct;
	X = Canvas.OrgX + (Canvas.ClipX - w) * 0.5;

	// We have some extra logic for figuring out how things should be displayed
	// in split screen.

	h = FullHeight * SafeRegionPct;

	Y = Canvas.OrgY + (Canvas.ClipY - h) * 0.5;

	Canvas.OrgX = X;
	Canvas.OrgY = Y;
	Canvas.ClipX = w;
	Canvas.ClipY = h;
	Canvas.Reset(true);

	// Set up delta time
	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;

    PlayerOwner.DrawHud( Self );
	if (bShowGameHUD)
	{
		DrawGameHud();
	}
	if (bDrawColorPalette)
	   DrawColorPalette();
}

function DrawColorPalette()
{
    Canvas.SetPos(0,0);
    Canvas.DrawColorizedTile(HudTexture, 40 * ResolutionScale, 40 *ResolutionScale,0,130,40,40, ColorToLinearColor(WhiteColor));

    Canvas.SetPos(40,0);
    Canvas.DrawColorizedTile(HudTexture, 40 * ResolutionScale, 40 *ResolutionScale,0,130,40,40, ColorToLinearColor(RedColor));

    Canvas.SetPos(80,0);
    Canvas.DrawColorizedTile(HudTexture, 40 * ResolutionScale, 40 *ResolutionScale,0,130,40,40, ColorToLinearColor(GreenColor));

    // We don't need a texture if we use Canvas' DrawRect function.
    Canvas.SetPos(120,0);
    Canvas.DrawColor = BlueColor; //Sets color for Canvas' primitive drawing functions
    Canvas.DrawRect(40,40); //Width and Height of Rect
                            //Note that DrawRect can take a 3rd argument, a Texture to draw with.

    Canvas.SetPos(160,0);
    Canvas.DrawColorizedTile(HudTexture, 40 * ResolutionScale, 40 *ResolutionScale,0,130,40,40, ColorToLinearColor(GrayColor));

    Canvas.SetPos(200,0);
    Canvas.DrawColorizedTile(HudTexture, 40 * ResolutionScale, 40 *ResolutionScale,0,130,40,40, ColorToLinearColor(BlackColor));
}

function DrawGameHud()
{
    DrawLivingHud();
}

/**
 * Anything drawn in this function will be displayed ONLY when the player is living.
 */
function DrawLivingHud()
{
    local HTWeapon Weapon;

	// Manage the weapon.  NOTE: Vehicle weapons are managed by the vehicle
	// since they are integrated in to the vehicle health bar
	if( PawnOwner != none )
	{
	    Weapon = HTWeapon(PawnOwner.Weapon);
	    if ( Weapon != none )
	    {
   		     if ( bShowAmmo )
		     {
	              DisplayAmmo(Weapon);
             }
             if (bShowCrosshair)
             {
                  Weapon.DrawWeaponCrosshair(self);
             }
		}
	}
}

function DisplayAmmo(HTWeapon Weapon)
{
	local vector2d POS;
	local string Amount;
	local int AmmoCount;

	// Resolve the position
	POS = ResolveHudPosition(AmmoPosition,AmmoBGCoords.UL,AmmoBGCoords.VL);


    // Figure out if we should be pulsing
	AmmoCount = Weapon.GetAmmoCount();

    // Draw the background
	Canvas.SetPos(POS.X,POS.Y);// - (AmmoBarOffsetY * ResolutionScale));
	Canvas.DrawColorizedTile(HudTexture, AmmoBGCoords.UL * ResolutionScale, AmmoBGCoords.VL * ResolutionScale, AmmoBGCoords.U, AmmoBGCoords.V, AmmoBGCoords.UL, AmmoBGCoords.VL, HudTint);

	// Draw the amount
	Amount = ""$AmmoCount;
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawText(Amount,,3.0f,3.0f);
}

/**
 * Given a default screen position (at 1024x768) this will return the hud position at the current resolution.
 * NOTE: If the default position value is < 0.0f then it will attempt to place the right/bottom face of
 * the "widget" at that offset from the ClipX/Y.
 *
 * @Param Position		The default position (in 1024x768 space)
 * @Param Width			How wide is this "widget" at 1024x768
 * @Param Height		How tall is this "widget" at 1024x768
 *
 * @returns the hud position
 */
function Vector2D ResolveHUDPosition(vector2D Position, float Width, float Height)
{
	local vector2D FinalPos;
	FinalPos.X = (Position.X < 0) ? Canvas.ClipX - (Position.X * ResolutionScale) - (Width * ResolutionScale)  : Position.X * ResolutionScale;
	FinalPos.Y = (Position.Y < 0) ? Canvas.ClipY - (Position.Y * ResolutionScale) - (Height * ResolutionScale) : Position.Y * ResolutionScale;

	return FinalPos;
}

defaultproperties
{
    HudTexture=Texture2D'HTUI.Textures.T_UI_HUD_BaseA'

    HudTint=(R=1.0f,G=1.0f,B=1.0f,A=1.0f)

    AmmoPosition=(X=0,Y=-1)
    AmmoBGCoords=(U=0,UL=76,V=0,VL=126)

    SafeRegionPct = 1.0f

    bShowAmmo=true
    bShowCrosshair=true

    bDrawColorPalette=false

}
