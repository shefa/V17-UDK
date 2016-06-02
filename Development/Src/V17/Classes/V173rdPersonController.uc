//  ================================================================================================
//   * File Name:    V17PlayerController
//   * Created By:   User
//   * Time Stamp:     30.1.2014 ??. 01:12:17 ??.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.4.0
//   * ?? Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V173rdPersonController extends V17PlayerController;


var bool NewRotationStyle;
var bool b3rdPerson;


//var PawnWeaponType WeaponType;

//var float RotationSpeed;        // Velocidad de rotaci??n del Pawn
var bool bTurningToFire;        // Flag que indica si el Pawn est?? girando sobre s?? mismo para disparar
var bool bPendingStopFire;      // Flag que indica que durante el giro se dej?? de pulsar el disparo.
var byte lastFireModeNum;       // Almacena el modo de disparo para aplicarlo tras el giro.
 
//Extiende el estado PlayerWalking, sobreescribiendo PlayerMove


state PlayerWalking
{
    ignores SeePlayer, HearNoise, Bump;
 
    function PlayerMove( float DeltaTime )
    {
        local vector            X,Y,Z, NewAccel;
        local eDoubleClickDir   DoubleClickMove;
        local rotator           OldRotation;
        local bool              bSaveJump;
        
        if(NewRotationStyle==false) {
            super.PlayerMove(DeltaTime);
            return;
        }
        
        if( Pawn == None )
        {
            GotoState('Dead');
        }
        else
        {
            GetAxes(Pawn.Rotation,X,Y,Z);
 
            // La aceleraci??n (y en consecuencia el movimiento) es diferente seg??n el tipo de arma que lleve el Pawn
            
            if(!Pawn.isA('Character') || Character(Pawn).WeaponType == PWT_Default)
            {
                NewAccel = Abs(PlayerInput.aForward)*X + Abs(PlayerInput.aStrafe)*X;
            }
            else
            {
                NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
            }
           
            NewAccel.Z  = 0;
            NewAccel = Pawn.AccelRate * Normal(NewAccel);
 
            if (IsLocalPlayerController())
            {
                AdjustPlayerWalkingMoveAccel(NewAccel);
            }
 
            DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
 
            // Update rotation.
            OldRotation = Rotation;
            UpdateRotation( DeltaTime );
            bDoubleJump = false;
 
            if( bPressedJump && Pawn.CannotJumpNow() )
            {
                bSaveJump = true;
                bPressedJump = false;
            }
            else
            {
                bSaveJump = false;
            }
 
            if( Role < ROLE_Authority ) // then save this move and replicate it
            {
                ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
            }
            else
            {
                ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
            }
            bPressedJump = bSaveJump;
        }
    }
}
 
function UpdateRotation( float DeltaTime )
{
    local Rotator DeltaRot, newRotation, ViewRotation;
    local Rotator CurrentRot;
    local vector X, Y, Z, newRotationVector;
 
    if(NewRotationStyle==false) {
        super.UpdateRotation(DeltaTime);
            return;
        }
        
    ViewRotation = Rotation;
    if (Pawn!=none)
    {
        Pawn.SetDesiredRotation(ViewRotation);
    }
 
    // Calculate Delta to be applied on ViewRotation
    DeltaRot.Yaw = PlayerInput.aTurn;
    DeltaRot.Pitch = PlayerInput.aLookUp;
 
    ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
    SetRotation(ViewRotation);
 
    //Rotaci??n del Pawn
    if ( Pawn != None )
    {
        // Se aplica el giro
        if (bTurningToFire || Pawn.IsFiring())  // si est?? disparando (o girando para disparar)
        {
            // Pawn mira a donde mira la c??mara
            NewRotation = ViewRotation;
            NewRotation.Roll = Rotation.Roll;
            CurrentRot = RLerp(Pawn.Rotation, newRotation, RotationSpeed * DeltaTime, true);
            Pawn.FaceRotation(CurrentRot, deltatime);
 
            if(bTurningToFire)
            {
                CheckIfCanFire(lastFireModeNum);
            }
        }
        else if(PlayerInput.aForward != 0.0 || PlayerInput.aStrafe != 0.0)  // o en movimiento sin disparar
        {
            // Giro solidario con la c??mara. Pawn mira a donde mira la c??mara
            if( Character(Pawn)!=None && Character(Pawn).WeaponType != PWT_Default )
            {
                NewRotation = ViewRotation;
                NewRotation.Roll = Rotation.Roll;
                CurrentRot = RLerp(Pawn.Rotation, newRotation, RotationSpeed * DeltaTime, true);
            }
            else    // Giro relativo a la c??mara. Pawn se gira hacia su direcci??n de movimiento
            {
                GetAxes(ViewRotation, X, Y, Z);
                newRotationVector = PlayerInput.aForward * X + PlayerInput.aStrafe * Y;
                newRotationVector.Z = 0;
                NewRotation = rotator(Normal(newRotationVector));
                CurrentRot = RLerp(Pawn.Rotation, NewRotation, RotationSpeed * DeltaTime, true);
            }
            Pawn.FaceRotation(CurrentRot, deltatime);
        }
    }
}

function SetRotationAmmount(int a)
{
    RotationSpeed=a;
} 
exec function displayrotation()
{
    WorldInfo.Game.Broadcast(self,"rotation: "@RotationSpeed); 
}

exec function StartFire( optional byte FireModeNum )
{
    local Dragon drag;
    drag=Dragon(Pawn);
    if( drag != none )
    {
        drag.StartFire(FireModeNum);
        //to be implemented
    }
     if(NewRotationStyle==false) {
         super.StartFire(FireModeNum);
            return;
     }
    if ( Pawn != None && !bCinematicMode && !WorldInfo.bPlayersOnly && !IsPaused())
    {
        lastFireModeNum = FireModeNum;      // Se guarda el modo de disparo para los disparos retardados.
        if(CheckIfCanFire(FireModeNum))     // Si se puede disparar directamente:
        {
            Pawn.StartFire( FireModeNum );  // se hace.
        }
    }
}
 
exec function StopFire(optional byte FireModeNum)
{
    local Dragon drag;
    drag=Dragon(Pawn);
    if( drag != none )
    {
        drag.StopFire(FireModeNum);
        //to be implemented
    }
    if(NewRotationStyle==false) {
        super.StopFire(FireModeNum);
            return;
     }
    Super.StopFire(FireModeNum);
    if(bTurningToFire)              // Si se ha dejado de pulsar el bot??n de disparo mientras se gira,
    {
        bPendingStopFire = true;    // se activa el flag para tenerlo en cuenta.
    }
}
 
// Comprueba si el ??ngulo del Pawn es el adecuado para disparar. En caso contrario, activa el giro y recuerda el disparo pendiente.
function bool CheckIfCanFire(optional byte FireModeNum)
{
    local float cosAng;     //Coseno de ??ngulo
 
    
    // Podr?? disparar si Postura es Default
    if(V17Pawn(Pawn).WeaponType == PWT_Default)
    {
        return true;
    }
    // Si la diferencia entre la rotaci??n actual del Pawn y del Controller es inferior a cierto l??mite, puede disparar
    cosAng = Normal(vector(Rotation) * vect(1.0,1.0,0.0)) dot Normal(vector(Pawn.Rotation));
    if((1 - cosAng) < 0.01)
    {
        if(bTurningToFire)  // Si est??bamos girando...
        {
            bTurningToFire=false;           
            Pawn.StartFire(FireModeNum);    
            if(bPendingStopFire)            
            {
                Pawn.StopFire(FireModeNum); 
                bPendingStopFire = false;   
            }
        }
        return true;
    }
    else   
    {
        bTurningToFire=true;
        return false;
    }
}

exec function ChangeCamera(bool b3rdP, bool RotationStyle)
{
    if(Role<ROLE_Authority) ChangeCameraServ(b3rdP, RotationStyle);
    b3rdPerson=b3rdP;
    NewRotationStyle=RotationStyle;
}

reliable server function ChangeCameraServ(bool b3rdP, bool RotationStyle)
{
    ChangeCamera(b3rdP, RotationStyle);
}
defaultproperties
{
    NewRotationStyle=true
    b3rdPerson=true
}