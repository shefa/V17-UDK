class myPawn extends UTPawn
	ClassGroup(myGame)
	placeable;

/** The list of items stored in this Pawn's InventoryManager */
var() array<archetype Object> InventoryItems;

/** The amount of gold stored in this container */
var() int Gold;

var Actor LootedPawn;
var float LootDistance;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	AddInventoryItems();
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);

	if (myPlayerController(C) != None)
	{
		// initialize (and hide) the inventory - this prevents errors later
		myHUD(PlayerController(Controller).myHUD).InitInventory();
	}
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (LootedPawn != None)
	{
		// if we're far enough from the looted pawn, remove the loot screen
		if (VSize2D(Location - LootedPawn.Location) > LootDistance)
		{
			LootedPawn = None;
			myHUD(PlayerController(Controller).myHUD).InventoryMovie.LootScreen(false, true);
			myHUD(PlayerController(Controller).myHUD).InventoryMovie.LootScreen(false, false);
		}
	}
}

function AddInventoryItems()
{
	local Actor ArchetypeTemplate, NewItem;
	local int i, saveSlot;
	local myInventoryManager myInvM;
	local string checkSlot;
	local bool bEquipped, bFreeSlot;
	local myWeapon myWeap;
	local myInventory myInv;

	// make sure we have an InvManager, or wait for one
	if (InvManager == None)
	{
		SetTimer(0.25f, false, 'AddInventoryItems');
		return;
	}

	// load inventory if we're an NPC
	myInvM = myInventoryManager(InvManager);
	for (i=0; i<InventoryItems.Length; i++)
	{
		if (InventoryItems[i] == none)
			continue;

		ArchetypeTemplate = Actor(DynamicLoadObject(PathName(InventoryItems[i]), class'Actor', true));
		NewItem = Spawn(ArchetypeTemplate.Class, self, , , , ArchetypeTemplate);
		myInvM.AddInventory(Inventory(NewItem), true);

		// try to equip it first
		bEquipped = false;
		if (myWeapon(NewItem) != None)
		{
			bFreeSlot = true;
			ForEach myInvM.InventoryActors(class'myWeapon', myWeap)
			{
				if (myWeap.ItemSlot == "slotWeapon")
				{
					bFreeSlot = false;
					break;
				}
			}

			if (bFreeSlot)
			{
				myWeapon(NewItem).ItemSlot = "slotWeapon";
				myInvM.ClientWeaponSet(myWeapon(NewItem), true);
				bEquipped = true;
			}
		}

		// if it wasn't successfully equipped, find out the first free inventory slot to store this in
		if (!bEquipped)
		{
			for (saveSlot = 0; saveSlot < myInvM.MaxSpaces; saveSlot++)
			{
				bFreeSlot = true;
				checkSlot = "slot"$saveSlot;
				ForEach myInvM.InventoryActors(class'myWeapon', myWeap)
				{
					if (myWeap.ItemSlot == checkSlot)
					{
						bFreeSlot = false;
					}
				}
				ForEach myInvM.InventoryActors(class'myInventory', myInv)
				{
					if (myInv.ItemSlot == checkSlot)
					{
						bFreeSlot = false;
					}
				}

				if (bFreeSlot)
				{
					break;
				}
			}

			if (myWeapon(NewItem) != None)
			{
				myWeapon(NewItem).ItemSlot = checkSlot;
			}
			else if (myInventory(NewItem) != None)
			{
				myInventory(NewItem).ItemSlot = checkSlot;
				myInventory(NewItem).Quantity = 1;
			}
		}
	}

	myInvM.Gold = Gold;
}

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	// if we bump into a container start looting (but only if we're not already looting it)
	if (LootedPawn != Other && myInventoryContainer(Other) != None && Controller != None && PlayerController(Controller) != None)
	{
		if (VSize2D(Location - Other.Location) <= LootDistance)
		{
			LootedPawn = myInventoryContainer(Other);
			myHUD(PlayerController(Controller).myHUD).ToggleInventory(true);
			myHUD(PlayerController(Controller).myHUD).InventoryMovie.SetUpLoot();
		}
	}
	// if we bump into another character start looting (but only if we're not already looting him)
	// commented out: handled through RigidBodyCollision. re-enable if you want to loot living Pawns
	/*else if (LootedPawn != Other && myPawn(Other) != None && Controller != None && PlayerController(Controller) != None)
	{
		if (VSize2D(Location - Other.Location) <= LootDistance)
		{
			LootedPawn = myPawn(Other);
			myHUD(PlayerController(Controller).myHUD).ToggleInventory(true);
			myHUD(PlayerController(Controller).myHUD).InventoryMovie.SetUpLoot();
		}
	}*/

	super.Bump(Other, OtherComp, HitNormal);
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	if (HitComponent.Owner != OtherComponent.Owner)
		super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);

	if (LootedPawn != OtherComponent.Owner && myPawn(OtherComponent.Owner) != None && Health > 0)
	{
		LootedPawn = myPawn(OtherComponent.Owner);
		myHUD(PlayerController(Controller).myHUD).ToggleInventory(true);
		myHUD(PlayerController(Controller).myHUD).InventoryMovie.SetUpLoot();
	}
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	// leave this empty so we can use a custom character mesh without worrying about the family info stuffs
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		// enable pawn-to-ragdoll collisions so we can loot him
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
		Mesh.SetActorCollision(false, false);
	}
	else
	{
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
		Mesh.SetActorCollision(true, true);
	}
}

simulated function bool ShouldGib(class<UTDamageType> UTDamageType)
{
	// with this we disable gibbing corpses
	return false;
}

simulated State Dying
{
ignores OnAnimEnd, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, StartFeignDeathRecoveryAnim, ForceRagdoll, FellOutOfWorld;
	event Timer()
	{
		// with this we leave the corpses permanently
	}

	simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		// with this we disable gibbing corpses
	}
}

DefaultProperties
{
	InventoryManagerClass=class'myInventoryManager'
	ControllerClass=class'AIController'

	// set the ironguard as the mesh
	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'InvDemo.Meshes.SK_CH_IronGuard_MaleA_Physics'
		RBCollideWithChannels=(Cloth=true)
		bHasPhysicsAssetInstance=true
		ScriptRigidBodyCollisionThreshold=0.001
		bNotifyRigidBodyCollision=true
	End Object
	Mesh=WPawnSkeletalMeshComponent

	Begin Object Name=CollisionCylinder
		ScriptRigidBodyCollisionThreshold=0.001
		bNotifyRigidBodyCollision=true
	End Object
	CylinderComponent=CollisionCylinder

	LootDistance = 80.0f

	RagdollLifespan=0.0
}
