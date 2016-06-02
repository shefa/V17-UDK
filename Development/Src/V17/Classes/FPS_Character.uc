//  ================================================================================================
//   * File Name:    FPS_Character
//   * Created By:   User
//   * Time Stamp:     16.7.2014 г. 20:52:38 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class FPS_Character extends Chivalry_Char;

var name EyeSocket, EyeSocket2;

var AnimNodeAimOffset PFMAimNode;   // Referencia al nodo de animación de AimOffset
var Rotator DesiredAim;             // Aim deseado
var Rotator CurrentAim;             // Aim actual
var float AimSpeed;                 // Velocidad de apuntado
var float HeadBob;

var rotator CurrentAim1,DesiredAim1;
var float DeltaSMTH;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
}

static function Rotator RLerpQuat( Rotator A, Rotator B, float Alpha, bool bShortestPath )
{
    return QuatToRotator( QuatSlerp( QuatFromRotator( A ), QuatFromRotator( B ), Alpha, bShortestPath ) );
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    // Se busca la referencia del nodo de Aiming
    PFMAimNode = AnimNodeAimOffset(SkelComp.FindAnimNode('PFMAimNode'));
    super.PostInitAnimTree(SkelComp);
}
 
simulated event Destroyed()
{
    Super.Destroyed();
    //`log( "+============+ PAWN DESTROYED WAT THA FUCK ");
    PFMAimNode = None;  //Es necesario desreferenciar el nodo para que el Pawn se destruya correctamente
}
 




/*
CalcCamera

Called from UTPlayerController::GetPlayerViewPoint(), 
which is called by the current camera.
*/
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    if(V173rdPersonController(Controller)!=none&&V173rdPersonController(Controller).b3rdPerson) return super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
    
    DeltaSMTH=fDeltaTime;
     GetActorEyesViewPoint( out_CamLoc, out_CamRot );

   return true;
}

/*
GetPawnViewLocation

Someone wants the position of our eyes - lets give it to them.
Its probably CalcCamera() anyway (see above).
*/
simulated event Vector GetPawnViewLocation()
{
    local vector viewLoc;
    if(V173rdPersonController(Controller)!=none&&V173rdPersonController(Controller).b3rdPerson) return super.GetPawnViewLocation();
   
    // no eye socket? No way I can tell you a location based on this socket then...
    if (EyeSocket == '')
        return Location + BaseEyeHeight * vect(0,0,1);

    // HACK - force the first person weapon and arm models to hide
    // NOTE: You should remove all first person only weapon/arm meshes instead.
    //SetWeaponVisibility(false);
    
    // HACK - force the world model and attachments to be visible
    // NOTE: You should make sure the mesh/attachments are always rendered.
    //SetMeshVisibility(true);

    Mesh.GetSocketWorldLocationAndRotation(EyeSocket, viewLoc);

    return viewLoc;
}

//GetViewRotation

simulated event rotator GetViewRotation()
{
    local vector out_Loc,out_Loc1;
    local rotator out_Rot,out_Rot1;
    
    local rotator aim1, aim2;
    
    if(V173rdPersonController(Controller)!=none&&V173rdPersonController(Controller).b3rdPerson) return super.GetViewRotation();
   
    // no eye socket? No way I can tell you a rotation based on this socket then...
    if (EyeSocket == '')
        return Super.GetViewRotation();
        
    Mesh.GetSocketWorldLocationAndRotation(EyeSocket, out_Loc, out_Rot);
    //DesiredAim1=out_Rot;
    aim1=out_Rot;
    Mesh.GetSocketWorldLocationAndRotation(EyeSocket2, out_Loc1, out_Rot1);
    aim2=out_Rot1;
    
    aim1.Roll=0;
    aim2.Roll=0;
    //if(CurrentAim1==None) CurrentAim1=DesiredAim1;
     //if (DesiredAim1 != CurrentAim1) CurrentAim1 = RLerpQuat(CurrentAim1, DesiredAim1, AimSpeed * DeltaSMTH, false);
     //WorldInfo.Game.Broadcast(self,  aim1.Pitch@aim1.Yaw);
     //WorldInfo.Game.Broadcast(self, aim2.Pitch@aim2.Yaw);
    
     if(aim1!=aim2) aim1=RLerp(aim1,aim2,HeadBob,true);

    return aim1;
}
exec function bobchange(float a)
{
    if(Role<ROLE_Authority) bobbchange(a);
    HeadBob=a;
}
reliable server function bobbchange(float a)
{
    bobchange(a);
}


simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
    
    DesiredAim=NewRotation;
    
    if(DesiredAim.Pitch>16383)
    {
        DesiredAim.Pitch=DesiredAim.Pitch-65535;
    }
    
    
    DesiredAim.Pitch = Clamp(DesiredAim.Pitch, ViewPitchMin, ViewPitchMax);
    //`log( "pitch "@DesiredAim.Pitch);
    

    // Interpolación de la rotación
    if (DesiredAim != CurrentAim)
    {
        CurrentAim = RLerp(CurrentAim, DesiredAim, AimSpeed * DeltaTime, false);
    }
    //WorldInfo.Game.Broadcast(self, V17PlayerController(Controller).PlayerInput.aLookUp@DesiredAim.Pitch);
    // Se cambia el nodo de animación
    if(PFMAimNode==none) PFMAimNode = AnimNodeAimOffset(Mesh.FindAnimNode('PFMAimNode'));

    if (CurrentAim.Pitch < 0)
    {
        PFMAimNode.Aim.Y = -float(CurrentAim.Pitch) / ViewPitchMin;
    }
    else if (CurrentAim.Pitch > 0)
    {
        PFMAimNode.Aim.Y = float(CurrentAim.Pitch) / ViewPitchMax;
    }
    else
    {
        PFMAimNode.Aim.Y = 0.f;
    }
    super.FaceRotation(NewRotation,DeltaTime);
    
}
/*
Dying

Instead of switching to a third person view, 
match the camera to the location and rotation of the eye socket.
*/
simulated State Dying
{
    // skip UTPawn's fancy damage/third person views
    simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
    {
        return Global.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
    }

    simulated event rotator GetViewRotation()
    {
       
        local vector out_Loc;
        local rotator out_Rot;
        if(V173rdPersonController(Controller)!=none&&V173rdPersonController(Controller).b3rdPerson) return super.GetViewRotation();
   
        // no eye socket? No way I can tell you a rotation based on this socket then...
        if (EyeSocket == '')
            return Global.GetViewRotation(); // non-state version please
        
        Mesh.GetSocketWorldLocationAndRotation(EyeSocket, out_Loc, out_Rot);

        return out_Rot;
    }
}

defaultproperties
{
    AimSpeed=8;
    EyeSocket="RightEye"
    EyeSocket2="LeftEye"
    HeadBob=0.5f
}