class CustomPawn extends UTPawn;
var SkeletalMeshComponent PlayerMeshComponent;
var AnimNodeSlot AnimSlot;
var bool SwordState;


function AddDefaultInventory()
{
    //Add the sword as default
    InvManager.DiscardInventory();
    InvManager.CreateInventory(class'Custom_Sword'); //InvManager is the pawn's InventoryManager
}


exec function SetSwordState(bool inHand)
{
    //setting our sword state.
    SwordState = inHand; 
}


function bool GetSwordState()
{
    //getting our sword state.
    return SwordState;   
}


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    //Setting up a reference to our animtree to play custom stuff.
    super.PostInitAnimTree(SkelComp);
    if ( SkelComp == Mesh)
    {
        AnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));
    }
}


exec function PlayAttack(name AnimationName, float AnimationSpeed)
{
    //The function we use to play our anims
    //Below goes, (anim name, anim speed, blend in time, blend out time, loop, override all anims)
    AnimSlot.PlayCustomAnim( AnimationName, AnimationSpeed, 0.00, 0.00, false, true);
}


defaultproperties
{
    SwordState = false
}