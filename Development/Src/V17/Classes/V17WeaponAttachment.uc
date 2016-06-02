//  ================================================================================================
//   * File Name:    V17WeaponAttachment
//   * Created By:   User
//   * Time Stamp:     14.7.2014 г. 01:59:40 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17WeaponAttachment extends Actor
abstract;

/** Weapon SkelMesh */
var MeshComponent Mesh;



/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 */
 simulated function AttachTo(V17Pawn OwnerPawn )
{
    local name SocketName;
    //`log( "attaching from wep attachment");
    if (OwnerPawn.Mesh != None)
    {
        // Attach Weapon mesh to player skelmesh
        if ( Mesh != None )
        {
            // Weapon Mesh Shadow
            Mesh.SetShadowParent(OwnerPawn.Mesh);
            Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
            
            //`log(Character(OwnerPawn).WeaponSocket);
            OwnerPawn.Mesh.AttachComponentToSocket(Mesh, Character(OwnerPawn).WeaponSocket);
            //if(Character(OwnerPawn).WeaponSheathed==true) SocketName= 'Sheath';
            //else SocketName= 'WeaponPoint';
            //OwnerPawn.Mesh.AttachComponentToSocket(Mesh, SocketName);
        }
    }
}


/**
 * Detach weapon from skeletal mesh
 */
simulated function DetachFrom( SkeletalMeshComponent MeshCpnt )
{
    //`log( "detaching from wep attachment");
    // Weapon Mesh Shadow
    if ( Mesh != None )
    {
        Mesh.SetShadowParent(None);
        Mesh.SetLightEnvironment(None);
    }
    if ( MeshCpnt != None )
    {
        // detach weapon mesh from player skelmesh
        if ( Mesh != None )
        {
            MeshCpnt.DetachComponent( mesh );
        }
    }
}

defaultproperties
{
    // Weapon SkeletalMesh
    Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
        bOwnerNoSee=true
        bOnlyOwnerSee=false
        CollideActors=false
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        MaxDrawDistance=4000
        bForceRefPose=1
        bUpdateSkelWhenNotRendered=false
        bIgnoreControllersWhenNotRendered=true
        bOverrideAttachmentOwnerVisibility=true
        bAcceptsDynamicDecals=FALSE
        CastShadow=true
        bCastDynamicShadow=true
        bPerBoneMotionBlur=true
    End Object
    Mesh=SkeletalMeshComponent0
}