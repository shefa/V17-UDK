class Custom_Sword extends UTWeapon;

var array<Actor> HitArray;


var name StartSocket, EndSocket;
var int ComboTimer;
var int ComboMove;
var SoundCue Swipe1, Swipe2, Swipe3, Swipe4, Sheath;


//Starting our custom firing state
simulated state WeaponFiring{
    
    simulated event BeginState( Name PreviousStateName)
    {
        //Check if there is any ammo for the current firemode.
        if(!HasAmmo(CurrentFireMode))
        {
            //Return if it's empty.
            WeaponEmpty();
            return;
        }
        
        //The firemode for left click
        if(CurrentFireMode == 0)
        {
            //Set the state of the sword to be true, i.e. in the pawn's hand
            CustomPawn(Owner).SetSwordState(true);
            CustomPawn(Owner).Mesh.AttachComponentToSocket(Mesh,'WeaponPoint');
            
            //If the timer has got above 2, reset the combo.
            if(ComboTimer >= 2 && ComboMove >= 0)
            {
                ComboMove = 0;
                ClearTimer('ComboTimerIncrease');
                ComboTimer = 0;
            }
            
            //Run the first combo move
            if(Combotimer < 2 && ComboMove == 1)
            {
                //Clear the timer
                ClearTimer('ComboTimerIncrease');
                ComboTimer = 0;
                //Change damage amount
                InstantHitDamage[1] = 20;
                //Play our relevant sound
                PlaySound(Swipe2);
                //Play the pawn's animation
                CustomPawn(Instigator).PlayAttack('Swipe1', 1);
                //Set the timer again
                SetTimer(0.25, true, 'ComboTimerIncrease');
                //Update how far along the combo we are.
                ComboMove = 2;
            }
            
            //Run the second combo move
            else if(Combotimer < 2 && ComboMove == 2)
            {
                //Same as above IF block
                ClearTimer('ComboTimerIncrease');
                ComboTimer = 0;
                InstantHitDamage[1] = 30;
                PlaySound(Swipe3);
                CustomPawn(Instigator).PlayAttack('Swipe2', 1);
                SetTimer(0.25, true, 'ComboTimerIncrease');
                ComboMove = 3;  
            }
            
            //Run the third combo move
            else if(Combotimer < 2 && ComboMove == 3)
            {
                //Same as above IF block
                ClearTimer('ComboTimerIncrease');
                ComboTimer = 0;
                InstantHitDamage[1] = 50;
                PlaySound(Swipe4);
                CustomPawn(Instigator).PlayAttack('Swipe3', 1);
                SetTimer(0.25, true, 'ComboTimerIncrease');
                ComboMove = 0; 
            }
            
            //Or if it was reset above, run the basic move.
            else
            {
                //Same as above IF block
                ClearTimer('ComboTimerIncrease');
                ComboTimer = 0;
                InstantHitDamage[1] = 10;
                PlaySound(Swipe1);
                CustomPawn(Instigator).PlayAttack('Swipe0', 1);
                SetTimer(0.25, true, 'ComboTimerIncrease');
                ComboMove = 1;  
            }
            
        }
        
        //Run any effects, such as muzzle flares and what not.
        //Although we defaulted them to nothing
        PlayFireEffects(CurrentFireMode);
        //Check for next fire interval
        SetTimer(GetFireInterval(CurrentFireMode), false, 'RefireCheckTimer');
        
    }
    
    simulated event EndState( Name NextStateName ){
        //Reset the array of hit pawns/actors
        HitArray.Length = 0;
        ClearTimer('RefireCheckTimer');
        NotifyWeaponFinishedFiring(CurrentFireMode);
        super.EndState(NextStateName);
        return;
    }
    simulated function RefireCheckTimer()
    {
        //Check if the pawn wants to put down the weapon.
        if(bWeaponPutDown)
        {
            PutDownWeapon();
            return;
        }
        if(ShouldRefire())
        {
            //Check if the controller wants to fire again.
            HitArray.Length = 0;
            PlayFireEffects(CurrentFireMode);
            SetTimer(GetFireInterval(CurrentFireMode), false, 'RefireCheckTimer');
            return;
        }
        
        //Ends the firing sequence.
        HandleFinishedFiring();
    }
    
    
    function Tick(float DeltaTime)
    {
        local Vector Start, End;
        //Get the trace locations from your third person weapon mesh
        End = Custom_Sword_Attach(CustomPawn(Owner).CurrentWeaponAttachment).End;
        Start = Custom_Sword_Attach(CustomPawn(Owner).CurrentWeaponAttachment).Start; 
        if(CurrentFireMode == 0)
        { 
            //Trace if in firemode 0, i.e. left click
            WeaponTrace(End, Start);
        }
    }
    
    simulated event WeaponTrace(vector End, vector Start){
        local vector HitLocation, HitNormal;
        local Actor HitActor;
        
        //Begin the trace from the recieved locations.
        HitActor = Trace(HitLocation, HitNormal, End, Start, true);
        
        //Check if the trace collides with an actor.
        if(HitActor != none)
        {
            //Check to make sure the actor that is hit hasn't already been counted for during this attack.
            if(HitArray.Find(HitActor) == INDEX_NONE && HitActor.bCanBeDamaged)
            {
                //Do the specified damage to the hit actor, using our custom damage type.
                HitActor.TakeDamage(InstantHitDamage[CurrentFireMode],
                Pawn(Owner).Controller, HitLocation, Velocity * 100.f, class'Custom_Sword_Damage');
                AmmoCount -= ShotCost[CurrentFireMode];
                //Add them to the hit array, so we don't hit them twice in one motion.
                HitArray.AddItem(HitActor);
            }
        }
    }
    
    //Finish the entire sequence.
    begin:
    FinishAnim(AnimNodeSequence(SkeletalMeshComponent(Mesh).FindAnimNode(WeaponFireAnim[CurrentFireMode])));
}


function ComboTimerIncrease()
{
    //Increase the combo timer.
    ComboTimer+=1;  
    //Check the sword state of the custom pawn.
    if(CustomPawn(Owner).GetSwordState())
    {
        if(ComboTimer == 4)  
        {
            //If the combo timer is above 4 ticks, play the sheath sound and animation
            PlaySound(Sheath);
            CustomPawn(Instigator).PlayAttack('sheath', 1.8);
        }
        if(ComboTimer >= 6)
        {
            //Once the anim is done, swap the sword to the sheath socket.
            CustomPawn(Owner).SetSwordState(false);  
            ComboTimer = 0;
        }
    }
}       


DefaultProperties
{
    //This is all of the default stuff that would be set up for first person.
    PlayerViewOffset=(X=0.000000,Y=0.00000,Z=0.000000)
    FiringStatesArray(1) = WeaponFiring
    
    //Sets up how much ammo to use per shot.
    ShotCost(1)=0
    bMeleeWeapon = true
    
    //Lets us create our own firing method.
    WeaponFireTypes(1)=EWFT_Custom
    
    //The two sockets we want to track and trace during attacking
    StartSocket = StartSocket
    EndSocket = EndSocket
    
    //More Default stuff
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    bCauseActorAnimEnd=true
    End Object
    
    //And even moreee
    Begin Object Name=FirstPersonMesh
    SkeletalMesh=SkeletalMesh'GDC_Materials.Meshes.SK_ExportSword2'
    FOV=60
    Animations=MeshSequenceA
    AnimSets(1)=AnimSet'GDC_Materials.Meshes.SwordAnimset'
    bForceUpdateAttachmentsInTick=True
    Scale=1
    
    End Object
    
    //Don't need this... defaulting it to nothing!
    Begin Object Name=PickupMesh
    SkeletalMesh=none
    Scale=1
    End Object
    
    //No more pesky noises
    WeaponEquipSnd=none
    WeaponPutDownSnd=none
    WeaponFireSnd(0)=none
    WeaponFireSnd(1)=none
    PickupSound=none
    
    //Defaulting as usual
    PivotTranslation=(Y=0.0)
    MuzzleFlashPSCTemplate=none
    MuzzleFlashLightClass=none
    
    //Set these to an arbitrary number above zero, so it doesn't get ejected from inventory
    MaxAmmoCount=100
    AmmoCount=100
    
    InventoryGroup=2
    
    //Good setup for combo intervals
    FireInterval(1)=0.25
    FireInterval(0)=0.1
    
    //Don't touch this bit!
    ArmsAnimSet=none
    Mesh=FirstPersonMesh
    DroppedPickupMesh=PickupMesh
    PickupFactoryMesh=PickupMesh
    AttachmentClass=Class'Custom_Sword_Attach'
    
    //Defaulting the combo timer
    ComboTimer = 0
    
    //Cool sounds! Change these to the 'full link' from your content browser
    Swipe1 = none //SoundCue'YourCustomPackage.Cue.Swipe1'
    Swipe2 = none //SoundCue'YourCustomPackage.Cue.Swipe2'
    Swipe3 = none //SoundCue'YourCustomPackage.Cue.Swipe3'
    Swipe4 = none //SoundCue'YourCustomPackage.Cue.Swipe4'
    Sheath = none //SoundCue'YourCustomPackage.Cue.sheath'
    
}