//  ================================================================================================
//   * File Name:    YourClassName
//   * Created By:   User
//   * Time Stamp:     20.4.2014 г. 22:12:11 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17AnimBlendByUpWeaponType extends UDKAnimBlendBase;

var Character Owner;

/*
OnInit

Overriding function from AnimNode, called from InitAnim.
*/
simulated event OnInit()
{
    Super.OnInit();

    // Call me paranoid, but I must insist on checking for both of these on init
    if ((SkelComponent == None) || (V17Pawn(SkelComponent.Owner) == None))
        return;
    
        Owner = Character(SkelComponent.Owner);
}

simulated event TickAnim(float DeltaSeconds)
{
    local int NewChildIndex;

    // no owner,  do nothing.
    if ((Owner == None))
        return;

    // If ladder is LT_Pipe, use first child
     //`log( "hello from AT"@Owner.HasEquippedWeapon@Owner.WeaponType1@Owner.CurrentWeapon.WeaponType1);
    
     if (Owner.HasEquippedWeapon==false|| Owner.WeaponSheathed==true)
     NewChildIndex=4;
    else if(Owner.WeaponType2==OneHanded) NewChildIndex = 0;
    else if(Owner.WeaponType2==TwoHanded) NewChildIndex=1;
    else if(Owner.WeaponType2==Bow) NewChildIndex=2;
    else if(Owner.WeaponType2==Shield) NewChildIndex=3;
    
    // only switch over if we haven't already switched
    if (ActiveChildIndex != NewChildIndex)
        SetActiveChild(NewChildIndex, BlendTime);
}

defaultproperties
{
    CategoryDesc="V17"
    Children(0)=(Name="OneHanded",Weight=1.0)
    Children(1)=(Name="TwoHanded")
    Children(2)=(Name="Bow")
    Children(3)=(Name="Shield")
    Children(4)=(Name="Unarmed/Sheathed")
    bFixNumChildren=true
    bTickAnimInScript=true
    bPlayActiveChild=true
    bCallScriptEventOnInit=true
    NodeName="WeaponType"
}