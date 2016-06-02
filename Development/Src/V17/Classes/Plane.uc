class Plane extends UTVehicle
placeable;

var int ForwardForce, PitchForce, SteerForce;

var vector CamOffset;   
var float CameraZOffset;

var() int ThrustMultiplier, SteerMultiplier;
var() float PitchMultiplier, RollMultiplier, GravityForce;

var() float CamLag;
var() name CameraTag;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    if (Mesh != None)
    {
            Mesh.WakeRigidBody();
    }

    CustomGravityScaling = GravityForce;
}

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
   Throttle = InForward;
    Steering = InStrafe;
    Rise = InUp;

    ForwardForce += (Throttle * ThrustMultiplier);
    SteerForce = (-Steering * SteerMultiplier);
    PitchForce = (-Rise * PitchMultiplier);

    ApplyForce(ForwardForce, SteerForce, PitchForce);
}

function ApplyForce(float FForce, float SForce, float PForce)
{
    local vector X, Y, Z, ForceApplication, RotationForce;
    //work out force direction
    WorldInfo.GetAxes(Rotation, X, Y, Z);
    //pitch
    RotationForce = PForce  * Y;
    //yaw
    RotationForce += SForce  * Z;
    //roll
    RotationForce += (-SForce * RollMultiplier)  * X;
    //thrust
    ForceApplication = FForce  * X;

     //apply force
    Mesh.AddTorque(RotationForce);
    Mesh.AddForce(ForceApplication);
}

/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    local vector SocketLoc;
    local rotator SocketRot;

        //get the location and rotation of the socket
        Mesh.GetSocketWorldLocationAndRotation(CameraTag, SocketLoc, SocketRot);
         //set the cam location and rotation
      out_CamLoc = VLerp(out_CamLoc, SocketLoc, CamLag*fDeltaTime); //VLerp to give us lag
      out_CamRot = Rotator(Location - out_CamLoc);   //look at the vehicle 
      WorldInfo.Game.Broadcast( self, "Rotation: "@out_CamRot.Pitch@out_CamRot.Roll@out_CamRot.Yaw);
      out_CamRot=SocketRot;
      WorldInfo.Game.Broadcast( self, "Rotation: "@out_CamRot.Pitch@out_CamRot.Roll@out_CamRot.Yaw);
   
      //WorldInfo.Game.Broadcast( self, "SocketLocation: "@SocketLoc.X@SocketLoc.Y@SocketLoc.Z);
      //WorldInfo.Game.Broadcast( self, "Rotation: "@out_CamRot.Pitch@out_CamRot.Roll@out_CamRot.Yaw);
   return true;
}
*/
defaultproperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'Nighthawk.Nighthawk'
        PhysicsAsset=PhysicsAsset'Nighthawk.Nighthawk_Physics'
    End Object

    DrawScale=20

    Seats.Empty
    Seats(0)={( GunClass=class'UTVWeap_CicadaTurret',
                GunSocket=(Gun_Socket_02,Gun_Socket_01),
                CameraTag=ViewSocket,
                TurretControls=(LauncherA,LauncherB),
                CameraOffset=-400,
                CameraBaseOffset=(Z=25.0),
                SeatIconPos=(X=0.48,Y=0.25),
                GunPivotPoints=(Main),
                WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X  =-80),Scale3D=(X=12.0,Y=15.0,Z=15.0)),(SocketName=Gu  n_Socket_02,Offset=(X=-80),Scale3D=(X=12.0,Y=15.0,Z=15.0)))
                )}

    AirSpeed=2100.0
    GroundSpeed=2100.0

    UprightLiftStrength=100.0
    UprightTorqueStrength=100.0

    bStayUpright=true
    StayUprightRollResistAngle=5.0
    StayUprightPitchResistAngle=5.0
    StayUprightStiffness=100
    StayUprightDamping=10

    bMustBeUpright=false
    UpsideDownDamagePerSec=0.0
    OccupiedUpsideDownDamagePerSec=0.0
    bEjectPassengersWhenFlipped=false

    PitchMultiplier=0.5
    SteerMultiplier=200
    ThrustMultiplier=10
    RollMultiplier=0.5

    GravityForce=1

    CamLag=9.0
    CameraTag="ViewSocket"
    
    CamOffset=(X=4.0,Y=0.0,Z=-13.0) 
    CameraZOffset=10;
}