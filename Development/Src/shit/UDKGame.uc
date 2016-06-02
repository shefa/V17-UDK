/*******************************************************************************
	UDKGame

	Creation date: 14/01/2010 13:55
	Copyright (c) 2010, Michael Allar

*******************************************************************************/

class UDKGame extends GameInfo
	config(UDKGame);

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	local string ThisMapPrefix;
	local int i,pos;
	local class<GameInfo> NewGameType;

    `log("We are setting our game type.");
	if (Left(MapName, 10) ~= "HTFrontEnd")
	{
		return class'UDKGame';
	}
    `log("We are not HTFrontEnd");

	// strip the UEDPIE_ from the filename, if it exists (meaning this is a Play in Editor game)
	if (Left(MapName, 6) ~= "UEDPIE")
	{
		MapName = Right(MapName, Len(MapName) - 6);
	}
	else if ( Left(MapName, 5) ~= "UEDPC" )
	{
		MapName = Right(MapName, Len(MapName) - 5);
	}
	else if (Left(MapName, 6) ~= "UEDPS3")
	{
		MapName = Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UED360")
	{
		MapName = Right(MapName, Len(MapName) - 6);
	}

	// replace self with appropriate gametype if no game specified
	pos = InStr(MapName,"-");
	ThisMapPrefix = left(MapName,pos);

	// change game type
	for ( i=0; i<Default.DefaultMapPrefixes.Length; i++ )
	{
	    `log("Going through a iteration of DefaultMapPrefixes");
		if ( Default.DefaultMapPrefixes[i].Prefix ~= ThisMapPrefix )
		{
			NewGameType = class<GameInfo>(DynamicLoadObject(Default.DefaultMapPrefixes[i].GameType,class'Class'));
			if ( NewGameType != None )
			{
				return NewGameType;
			}
		}
	}

	return class'UDKGame';
}

defaultproperties
{
	DefaultPawnClass=class'UDKGame.HTPawn'
	PlayerControllerClass=class'UDKGame.HTPlayerController'

	HUDType=class'UDKGame.HTHUD'
}
