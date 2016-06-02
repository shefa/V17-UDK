//  ================================================================================================
//   * File Name:    YourClassName
//   * Created By:   User
//   * Time Stamp:     20.4.2014 г. 22:12:11 ч.
//   * UDK Path:   C:\UDK\UDK-2013-07
//   * Unreal X-Editor v3.1.5.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class V17AnimBlendByUpDown extends UDKAnimBlendBase;

var V17Pawn Owner;

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
    
    Owner = V17Pawn(SkelComponent.Owner);
}

simulated event TickAnim(float DeltaSeconds)
{
    local int NewChildIndex;

    // no owner,  do nothing.
    if ((Owner == None))
        return;

    // If ladder is LT_Pipe, use first child
    if (Owner.Acceleration.Z > 0.0f)
    NewChildIndex = 0;
   
    // down 
    else if (Owner.Acceleration.Z < 0.0f)
    NewChildIndex = 1;
    // only switch over if we haven't already switched
    if (ActiveChildIndex != NewChildIndex)
        SetActiveChild(NewChildIndex, BlendTime);
}

defaultproperties
{
    CategoryDesc="V17"
    Children(0)=(Name="Up",Weight=1.0)
    Children(1)=(Name="Down")
    Children(2)=(Name="Left")
    Children(3)=(Name="Right")
    bFixNumChildren=true
    bTickAnimInScript=true
    bPlayActiveChild=true
    bCallScriptEventOnInit=true
    NodeName="UpDown"
}