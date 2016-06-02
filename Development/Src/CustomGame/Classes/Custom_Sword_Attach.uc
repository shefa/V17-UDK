class Custom_Sword_Attach extends UTWeaponAttachment;


var SkeletalMeshComponent weapMesh;
var name StartSocket, EndSocket;
var bool LastSwordState;
var bool NewSwordState;
var Vector Start, End;


simulated function PostBeginPlay()
{
    //Initialise our reference to our sword.
    weapMesh = Mesh;
    Super.PostBeginPlay();
}


simulated event SetPosition(UDKPawn Holder)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;
 
    compo = Holder.Mesh;
 
    if (compo != none)
    {
        //Find out socket called weaponpoint.
        socket = compo.GetSocketByName('WeaponPoint');
        if (socket != none)
        {
            FinalLocation = compo.GetBoneLocation(socket.BoneName);
        }
    } 
    //Update the location of the sword. 
    SetLocation(FinalLocation);
}


simulated function Tick(float DeltaTime)
{
    //Get the locations of the two sockets on the sword, and save them for later referencing
    Mesh.GetSocketWorldLocationAndRotation(StartSocket, Start);
    Mesh.GetSocketWorldLocationAndRotation(EndSocket, End);  
    //Check if the sword needs to be changed.  
    ChangeSwordState();
}


function ChangeSwordState()
{
    //Get the sword state of our custom pawn.
    NewSwordState = CustomPawn(Owner).GetSwordState();
    if(NewSwordState != LastSwordState)
    {
        //If its not the same as last time it was checked, detach it.
        CustomPawn(Owner).Mesh.DetachComponent(weapMesh);
        //Then we check which point it has to go to, and attach it there.
        if(!NewSwordState)
        {
            CustomPawn(Owner).Mesh.AttachComponentToSocket(weapMesh, 'Sheathe');
        }   
        else
        {
            CustomPawn(Owner).Mesh.AttachComponentToSocket(weapMesh, 'WeaponPoint');
        }
        LastSwordState = NewSwordState;
    }
}


DefaultProperties
{
    //Socket names
    StartSocket = StartSocket
    EndSocket = EndSocket
    
    //Sword Mesh
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'GDC_Materials.Meshes.SK_ExportSword2'
    CullDistance=5000.000000
    Scale=1.5
    End Object
    weapMesh = SkeletalMeshComponent0
    
    //More default stuff...
    bMakeSplash=False
    MuzzleFlashSocket=none
    MuzzleFlashLightClass=none
    MuzzleFlashDuration=0


    //Our sword state default setting
    LastSwordState = true
    
    //Don't touch!
    Mesh=SkeletalMeshComponent0
    WeaponClass=Class'Custom_Sword'
}