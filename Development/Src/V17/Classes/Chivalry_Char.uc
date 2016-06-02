//================================================================================================
//   * File Name:    Chivalry_Char
//   * Created By:   User
//   * Time Stamp:     17.5.2014 �. 18:10:58 �.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * � Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================


class Chivalry_Char extends Character;

var SkeletalMeshComponent me[5];
var repnotify int currentIndex;
var int oldindex;

replication
{
    if(bNetDirty||bNetInitial) currentIndex;
}

simulated event ReplicatedEvent(Name VarName)
{
    if(VarName== 'currentIndex')
    {
        //`log( "=========!!!!!!!!!!!!!! so fucking happey currentIndex repplicated ");
        ClientChange(currentIndex);
        
    }
    super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay() {
    local int fak;
    if(Role==ROLE_Authority)
    {
       `log( "PLaer typ "@V17Game(WorldInfo.Game).SomeInt);
       fak=V17Game(Worldinfo.Game).SomeInt;
       ChangeChar(fak);
       
    }
    super.PostBeginPlay();
}


reliable client function ClientChange(int index)
{
    Mesh=me[index];
    DetachComponent(me[oldIndex]);
    AttachComponent(me[index]);
    CurrentIndex=index;
    oldIndex=index;
}

reliable server function ServerChange(int index)
{
    ChangeChar(index);
}


exec function ChangeChar(int index)
{
    
    Mesh=me[index];
    DetachComponent(me[currentIndex]);
    AttachComponent(me[index]);
    CurrentIndex=index;
    OldIndex=index;
    if(Role<ROLE_Authority) ServerChange(index);
}


function UpdateAnim()
{
    Mesh.AnimSets[1]=CurrentWeapon.PawnAnimSet;
    Mesh.UpdateAnimations();
}

defaultproperties
{
    //InventoryItems(0)=V17MeleeWeapon'InvDemo.archetypes1.GreatSword'
    //InventoryItems(1)=V17MeleeWeapon'InvDemo.archetypes1.BroadSword'
    //InventoryItems(2)=V17RangedWeapon'InvDemo.archetypes1.LongBow'
    //InventoryItems(0)=V17MeleeWeapon'InvDemo.archetypes1.meleeweapon'
    
    // SkeletalMesh'Chivalry.SkeletalMesh.3P_A_Vanguard_SKELMESH'
    // SkeletalMesh'Chivalry.SkeletalMesh.SK_CH_3P_AgathaArcher'
    
    // red
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentRobot2
        SkeletalMesh=SkeletalMesh'MoDebugMale.SkeletalMesh.Debug_Male'
        AnimSets(0)=AnimSet'MoDebugMale.AnimSets.Base_AnimSet'
        AnimSets(1)=AnimSet'MoDebugMale.AnimSets.One_Handed_Sword'
        AnimTreeTemplate=AnimTree'MoDebugMale.animtrees.Debug_Male_AT'
        PhysicsAsset=PhysicsAsset'MoDebugMale.SkeletalMesh.Debug_Male_Physics'
        bHasPhysicsAssetInstance=True
        bEnableFullAnimWeightBodies=True
        //DepthPriorityGroup=SDPG_Foreground
        LightEnvironment=MyLightEnvironment
        bAcceptsLights=True
    End Object
    me[0]=SkeletalMeshComponentRobot2
    //blue
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentRobot3
        SkeletalMesh=SkeletalMesh'MoNakedGuys.SkeletalMesh.HumanMale'
        AnimSets(0)=AnimSet'MoDebugMale.AnimSets.Base_AnimSet'
        AnimSets(1)=AnimSet'MoDebugMale.AnimSets.One_Handed_Sword'
        AnimTreeTemplate=AnimTree'MoDebugMale.animtrees.Debug_Male_AT'
        //DepthPriorityGroup=SDPG_Foreground
        LightEnvironment=MyLightEnvironment
        bEnableSoftBodySimulation=True
        bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    me[1]=SkeletalMeshComponentRobot3
    //yellow
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentRobot4
        SkeletalMesh=SkeletalMesh'MoNakedGuys.SkeletalMesh.HumanFemale'
        AnimSets(0)=AnimSet'MoDebugFemale.AnimSets.Base_Female_AnimSet'
        AnimTreeTemplate=AnimTree'MoDebugMale.animtrees.Debug_Male_AT'
        //DepthPriorityGroup=SDPG_Foreground
        LightEnvironment=MyLightEnvironment
        bEnableSoftBodySimulation=True
        bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    me[2]=SkeletalMeshComponentRobot4
    
    //girl
    me[3]=SkeletalMeshComponentRobot
    
    //dude
     Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponentRobot5
        SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
        AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
        AnimTreeTemplate=AnimTree'MeleeWeaponContent.animation.Human'
        //AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
        LightEnvironment=MyLightEnvironment
        bHasPhysicsAssetInstance=True
        BlockRigidBody=True
        RBCollideWithChannels=(Cloth=true)
        ScriptRigidBodyCollisionThreshold=0.1
        bNotifyRigidBodyCollision=true
        bEnableFullAnimWeightBodies=True
        bEnableSoftBodySimulation=True
        bSoftBodyAwakeOnStartup=True
        bAcceptsLights=True
    End Object
    me[4]=SkeletalMeshComponentRobot5
    
    
    Mesh=SkeletalMeshComponentRobot2
    
   
    Components.Remove(SkeletalMeshComponentRobot);
    Components.Add(SkeletalMeshComponentRobot2)
    currentIndex=0;
    oldIndex=0;
 
    GroundSpeed=350
    speed2=650
}
