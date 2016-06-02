/**
 *  DominantDirectionalLightDayNight
 *
 *  Creation date: 24.08.2012 19:25
 *  Copyright 2012, Boris Novikov
 *  Modified 2014, Georgi Marinov - Venom1724
 */
class DominantDirectionalLightDayNight extends DominantDirectionalLightMovable
ClassGroup(Lights,DirectionalLights)
placeable;

var (DayNight) float DayNightFreq;
var (DayNight) int DayNightStep;
var (DayNight) float Correction;
var (DayNight) int TurnOffHour;
var (DayNight) int TurnOnHour;

var (DayNight) array <float> SunBrightness;
var (DayNight) float BrightnessInterpolationSpeed;
var (DayNight) bool ConstBrightnessInterpolationSpeed;

var (DayNight) array <Color> SunColor;
var (DayNight) float ColorInterpolationSpeed;
var (DayNight) bool ConstColorInterpolationSpeed;

var (DayNight) InterpActor SkyActor;
var (DayNight) array <MaterialInterface> SkyMaterials;

var (DayNight) array <Name> ScalarParamNames;
var (DayNight) float ScalarInterpolationSpeed;
var (DayNight) bool ConstScalarInterpolationSpeed;

var (DayNight) array <Name> ColorParamNames;
var (DayNight) float VectorInterpolationSpeed;
var (DayNight) bool ConstVectorInterpolationSpeed;


var float TimeStamp;
var bool MatInstanced;

var repnotify rotator SunRotation;

var int Days, Hours, Minutes, i;

replication
{
    if (bNetInitial)
        SunRotation;
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'SunRotation')
    {
        SetRotation(SunRotation);
    }
    else    if (VarName == 'bEnabled')
    {
        LightComponent.SetEnabled(bEnabled);
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated event PostBeginPlay()
{
    V17Game(WorldInfo.Game).lightvar=self;
    super.PostBeginPlay();
    TimeStamp = WorldInfo.TimeSeconds;
    SetTimer(DayNightFreq, true, 'DayNightTimer');
}

function DisplayWorldTime()
{
    //Days = (Rotation.Pitch + Correction*(65536/24)) / 65536;
    //Hours = ( ( (Rotation.Pitch - (Days*65536) ) / 65536.) * 24.)+Correction;
    //Minutes = ( ( (Rotation.Pitch+(Correction*(65536/24)) - (Days*65536) ) ) - (Hours*(65536/24) ) ) / 45.51;
    
    WorldInfo.Game.Broadcast(self, "Day"@Days@"Hours ="@Hours@"Minutes= "@Minutes );
}

function SetWorldTime( int day, int hour, int minute)
{
    local rotator R;
    R=Rotation;
    
     R.Pitch=(minute*45.51)+(hour*(65536/24))+(day*65536)-Correction*(65536/24);
     SetRotation(R);
     DisplayWorldTime();
    
}

simulated function DayNightTimer()
{
    local Rotator R;

    local MaterialInterface NewMaterial, OldMaterial;
    local MaterialInstance CurrentMaterial;
    local float fOldScalarParam, fScalarParam, fCurrentParam;
    local LinearColor vOldParam, vParam;
    local color cColor, cNextColor; 
    local int index, NextIndex, Progress, TotalProgress;
    local float DeltaTime;
    
    DeltaTime=WorldInfo.TimeSeconds-TimeStamp;
    TimeStamp = WorldInfo.TimeSeconds;
    
    R=self.Rotation;
    R.Pitch += DayNightStep;
    //SunRotation=R;
    
    Days = (Rotation.Pitch + Correction*(65536/24)) / 65536;
    Hours = ( ( (Rotation.Pitch - (Days*65536) ) / 65536.) * 24.)+Correction;
    Minutes = ( ( (Rotation.Pitch+(Correction*(65536/24)) - (Days*65536) ) ) - (Hours*(65536/24) ) ) / 45.51;
    
    if (Role == Role_Authority){
        SunRotation=R;
        V17Game(WorldInfo.Game).Day = Days;
        V17Game(WorldInfo.Game).Hour = Hours;
        V17Game(WorldInfo.Game).Minute = Minutes;
    }

    self.SetRotation(R);
    
    //`Log(self@Role@SunRotation);
    
    
    
    //HERE YOU CAN SET CALCULATED TIME SOMEWHERE TO WorldInfo
    
    
    
    //WorldInfo.Game.Broadcast(self, "Day"@Days@"Hours ="@Hours@"Minutes= "@Minutes );
    
    if (Hours == TurnOffHour && LightComponent.bEnabled)
    {
        bEnabled=FALSE;
        LightComponent.SetEnabled(FALSE);
        //WorldInfo.Game.Broadcast(self, "Day"@Days@"Hours ="@Hours@"Minutes= "@Minutes );
        //WorldInfo.Game.Broadcast(self, "TURN OFF" );
    }
    if (Hours == TurnOnHour && !LightComponent.bEnabled)
    {
        bEnabled=TRUE;
        LightComponent.SetEnabled(TRUE);
        LightComponent.BloomScale=LightComponent.Default.BloomScale;
        LightComponent.BloomThreshold=LightComponent.Default.BloomThreshold;
        LightComponent.BloomScreenBlendThreshold=LightComponent.Default.BloomScreenBlendThreshold;
        
        LightComponent.SetLightProperties(LightComponent.Default.Brightness, LightComponent.Default.LightColor, );
        LightComponent.UpdateLightShaftParameters();
        LightComponent.UpdateColorAndBrightness();

        //WorldInfo.Game.Broadcast(self, "Day"@Days@"Hours ="@Hours@"Minutes= "@Minutes );
        //WorldInfo.Game.Broadcast(self, "TURN ON" );
    }

    TotalProgress=( (self.Rotation.Pitch+Correction*(65536/24)) % 65536);
    
    i = SunBrightness.Length;
    if (i !=0 )
    {
        index = TotalProgress*i / 65536;
        Progress = TotalProgress - ( index * (65536 / i) );
        fOldScalarParam = SunBrightness[ index ];
        
        NextIndex=( index+1 )%i;

        if (NextIndex > -1 && NextIndex < SunBrightness.Length)
        {
            fScalarParam = SunBrightness[ NextIndex ];
            
            if (fOldScalarParam != fScalarParam)
            {
                //`Log(fOldScalarParam@"["$index$"]"@"->"@fScalarParam@"["$NextIndex$"]"@" = "@LightComponent.Brightness );
                //`Log( Progress@"/"@(ABS(fScalarParam - fOldScalarParam) / (65536 / SunBrightness.Length)) );
                if (ConstBrightnessInterpolationSpeed)
                    fCurrentParam= FInterpConstantTo(fOldScalarParam, fScalarParam, Progress, ABS(fScalarParam - fOldScalarParam) / (65536 / SunBrightness.Length) );
                else
                    fCurrentParam= FInterpTo(LightComponent.Brightness, SunBrightness[ Hours/( 24 / i ) ], DeltaTime, BrightnessInterpolationSpeed);
                
                LightComponent.SetLightProperties(fCurrentParam);               
                //WorldInfo.Game.Broadcast(self, fOldScalarParam@" => "@fScalarParam@"="@fCurrentParam@"progress="$Progress@"speed="$ABS(fScalarParam-fOldScalarParam)/(65536 / SunBrightness.Length)@" step="$(ABS(fScalarParam-fOldScalarParam)/(65536 / SunBrightness.Length))*Progress  );
            }
        }
    }
    i=0;
    
    i = SunColor.Length;
    if (i !=0 )
    {

        index = TotalProgress*i / 65536;
        cColor = SunColor[index];

        NextIndex=( index+1 )%i;
        cNextColor = SunColor[NextIndex];
        
        //WorldInfo.Game.Broadcast(self, "R="$cColor.R@"G="$cColor.G@"B="$cColor.B@" => "@"R="$cNextColor.R@"G="$cNextColor.G@"B="$cNextColor.B);
        
        Progress = TotalProgress - ( index * (65536 / i) );
        
        if (ConstColorInterpolationSpeed)
        {       
            cColor.R += (cNextColor.R - cColor.R) * Progress / (65536 / i);
            cColor.G += (cNextColor.G - cColor.G) * Progress / (65536 / i);
            cColor.B += (cNextColor.B - cColor.B) * Progress / (65536 / i);

        }
        else
        {
            cColor.R=FInterpTo( cColor.R, cNextColor.R, DeltaTime, ABS(cNextColor.R - cColor.R) /  (65536 / i) );
            cColor.G=FInterpTo( cColor.G, cNextColor.G, DeltaTime, ABS(cNextColor.G - cColor.G) /  (65536 / i) );
            cColor.B=FInterpTo( cColor.B, cNextColor.B, DeltaTime, ABS(cNextColor.B - cColor.B) /  (65536 / i) );
        }
        //WorldInfo.Game.Broadcast(self, "R="$cColor.R@"G="$cColor.G@"B="$cColor.B);
        LightComponent.BloomTint = cColor;
        LightComponent.SetLightProperties( ,cColor );

    }
    i=0;
    index=0;
    
    if (SkyActor != none && SkyMaterials.Length > 0)
    {

        i = SkyMaterials.Length;
        if (i !=0 )
        {
            index = TotalProgress*i / 65536;
            Progress = TotalProgress - ( index * (65536 / i) );
            OldMaterial = SkyMaterials[index];
            
            NextIndex=( index+1 )%i;
            NewMaterial = SkyMaterials[NextIndex];
            
            //WorldInfo.Game.Broadcast(self, "SkyMat"@index@SkyMaterials[index] );
            
            if (!MatInstanced){
                CurrentMaterial=SkyActor.StaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
                MatInstanced=TRUE;
            }
            else
                CurrentMaterial=MaterialInstance(SkyActor.StaticMeshComponent.GetMaterial(0));
                
            i=0;    
            
            while ( i < ScalarParamNames.Length )
            {
                NewMaterial.GetScalarParameterValue(ScalarParamNames[i], fScalarParam);
                OldMaterial.GetScalarParameterValue(ScalarParamNames[i], fOldScalarParam);
                    
                if (fOldScalarParam != fScalarParam)
                {
                    if (ConstScalarInterpolationSpeed){
                        fCurrentParam=FInterpConstantTo(fOldScalarParam, fScalarParam, Progress, ABS(fScalarParam-fOldScalarParam)/(65536 / SkyMaterials.Length)  );
                    }
                    else
                        fCurrentParam=FInterpTo(fOldScalarParam, fScalarParam, DeltaTime, ScalarInterpolationSpeed);
                    
                    CurrentMaterial.SetScalarParameterValue(ScalarParamNames[i], fCurrentParam);
                }
                
                //WorldInfo.Game.Broadcast(self, ScalarParamNames[i]@fOldScalarParam@" => "@fScalarParam@"="@fCurrentParam@"progress="$Progress@"speed="$ABS(fScalarParam-fOldScalarParam)/(65536 / SkyMaterials.Length)@" step="$(ABS(fScalarParam-fOldScalarParam)/(65536 / SkyMaterials.Length))*Progress  );
                //`log(ScalarParamNames[i]@fOldScalarParam@" => "@fScalarParam@"="@fCurrentParam@"progress="$Progress@"speed="$ABS(fScalarParam-fOldScalarParam)/(65536 / SkyMaterials.Length)@" step="$(ABS(fScalarParam-fOldScalarParam)/(65536 / SkyMaterials.Length))*Progress  );
                i++;
            }
            
            i=0;

            //WorldInfo.Game.Broadcast(self, "ColorParamNames.Length="@ColorParamNames.Length );
            while ( i < ColorParamNames.Length )
            {
                NewMaterial.GetVectorParameterValue(ColorParamNames[i],vParam);
                OldMaterial.GetVectorParameterValue(ColorParamNames[i], vOldParam);
                if (ConstVectorInterpolationSpeed)
                {
                    //WorldInfo.Game.Broadcast(self, ColorParamNames[i]@"R="$vOldParam.R@" => "@"R="$vParam.R@"progress="$Progress@"speed="$ABS(vParam.R-vOldParam.R)/(65536 / SkyMaterials.Length)@" diff="$(ABS(vParam.R-vOldParam.R)/(65536 / SkyMaterials.Length))*Progress);  
                    //`log(ColorParamNames[i]@"R="$vOldParam.R@" => "@"R="$vParam.R@"progress="$Progress@"speed="$ABS(vParam.R-vOldParam.R)/(65536 / SkyMaterials.Length)@" diff="$(ABS(vParam.R-vOldParam.R)/(65536 / SkyMaterials.Length))*Progress);
                    //`log(ColorParamNames[i]@"G="$vOldParam.R@" => "@"G="$vParam.R@"progress="$Progress@"speed="$ABS(vParam.G-vOldParam.G)/(65536 / SkyMaterials.Length)@" diff="$(ABS(vParam.G-vOldParam.G)/(65536 / SkyMaterials.Length))*Progress);
                    //`log(ColorParamNames[i]@"B="$vOldParam.R@" => "@"B="$vParam.R@"progress="$Progress@"speed="$ABS(vParam.B-vOldParam.B)/(65536 / SkyMaterials.Length)@" diff="$(ABS(vParam.B-vOldParam.B)/(65536 / SkyMaterials.Length))*Progress);
                    //`log(ColorParamNames[i]@"A="$vOldParam.R@" => "@"A="$vParam.R@"progress="$Progress@"speed="$ABS(vParam.A-vOldParam.A)/(65536 / SkyMaterials.Length)@" diff="$(ABS(vParam.A-vOldParam.A)/(65536 / SkyMaterials.Length))*Progress);
                    vParam.R = FInterpConstantTo(vOldParam.R, vParam.R, Progress, ABS(vParam.R-vOldParam.R)/(65536 / SkyMaterials.Length)  );
                    vParam.G = FInterpConstantTo(vOldParam.G, vParam.G, Progress, ABS(vParam.G-vOldParam.G)/(65536 / SkyMaterials.Length)  );
                    vParam.B = FInterpConstantTo(vOldParam.B, vParam.B, Progress, ABS(vParam.B-vOldParam.B)/(65536 / SkyMaterials.Length)  );
                    vParam.A = vOldParam.A;
                    //WorldInfo.Game.Broadcast(self, ColorParamNames[i]@"STEP="$ (Progress*ABS(vParam.B-vOldParam.B)/(65536 / SkyMaterials.Length) ) );
                    
                }
                else
                {
                    vParam.R=FInterpTo(vOldParam.R, vParam.R, DeltaTime, VectorInterpolationSpeed);
                    vParam.G=FInterpTo(vOldParam.G, vParam.G, DeltaTime, VectorInterpolationSpeed);
                    vParam.B=FInterpTo(vOldParam.B, vParam.B, DeltaTime, VectorInterpolationSpeed);
                    vParam.A=FInterpTo(vOldParam.A, vParam.A, DeltaTime, VectorInterpolationSpeed);
                }
                //WorldInfo.Game.Broadcast(self,ColorParamNames[i]@"R="$vParam.R@"G="$vParam.G@"B="$vParam.B);
                //CurrentMaterial.SetVectorParameterValue(ColorParamNames[i], vParam);
                //`log(ColorParamNames[i]@"R="$vParam.R@"G="$vParam.G@"B="$vParam.B@"A="$vParam.A);
                CurrentMaterial.SetVectorParameterValue(ColorParamNames[i], vParam);
                i++;
            }
            i=0;
    
        }   
    
    }   
}

defaultproperties
{
    bHidden=FALSE //REPLICATION NEEDS THIS
    bNoDelete=TRUE

    bRouteBeginPlayEvenIfStatic=FALSE
    bEdShouldSnap=FALSE
    

    Begin Object Name=DominantDirectionalLightComponent0

        
        ModShadowFadeoutExponent=3.0
    
        bRenderLightShafts=True

        LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

        CastShadows=TRUE
        CastStaticShadows=TRUE
        CastDynamicShadows=TRUE
        bForceDynamicLight=FALSE
        UseDirectLightMap=FALSE
        bAllowPreShadow=TRUE

        LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
        LightmassSettings=(LightSourceAngle=.2)

    End Object

    bStatic=FALSE
    bHardAttach=TRUE
    bMovable=TRUE
    Physics=PHYS_Interpolating
    
    RemoteRole=ROLE_SimulatedProxy
    Role=ROLE_Authority
    bNetInitialRotation=TRUE
    bUpdateSimulatedPosition=TRUE
    bReplicateMovement=TRUE
    
    Correction=22;
    DayNightStep = 1;
    DayNightFreq = 0.001;
    TurnOffHour=-1;
    TurnOnHour=-1;
    
    SkyMaterials[0]=MaterialInstanceConstant'MapTemplates.Sky.M_Procedural_Sky_Night'
    SkyMaterials[1]=MaterialInstanceConstant'MapTemplates.Sky.M_Procedural_Sky_Morning'
    SkyMaterials[2]=MaterialInstanceConstant'MapTemplates.Sky.M_Procedural_Sky_Daytime'
    SkyMaterials[3]=MaterialInstanceConstant'MapTemplates.Sky.M_Procedural_Sky_Afternoon'
    
    
    ScalarParamNames[0]=CloudBrightness
    ScalarParamNames[1]=CloudDarkness
    ScalarParamNames[2]=CloudOpacity
    ScalarParamNames[3]=Desaturation
    ScalarParamNames[4]=RimBrightness
    ScalarParamNames[5]=SkyBrightness
    ScalarParamNames[6]=Speed
    
    
    ColorParamNames[0]=HorizonColor
    ColorParamNames[1]=RimColor
    ColorParamNames[2]=Sun
    ColorParamNames[3]=ZenithColor

    
    BrightnessInterpolationSpeed=1.;
    ColorInterpolationSpeed=100.;
    ScalarInterpolationSpeed=1.;
    VectorInterpolationSpeed=1.;

}