class NearFoliageManager extends Actor;

// Visible/ Collision Components
var const CylinderComponent CylinderComponent;
var const DrawSphereComponent   SphereComponent;

// Grass Counts
var array<RuntimeGrass> currentGrass;
var int GrassToSpawnInRing;
var int offsetammount;

// Phys Material
var PhysicalMaterial physMatMask;

// Optimization
var Vector lastSpawnPosition;
var int ReCheckDistance;
var int MaxGrassCount;

simulated function PostBeginPlay() {
    super.PostBeginPlay();
    Owner.AttachComponent(SphereComponent);
    Owner.AttachComponent(CylinderComponent);
}

event Destroyed() {
    DestroyAllGrass();
    Owner.DetachComponent(SphereComponent);
    Owner.DetachComponent(CylinderComponent);
    super.Destroyed();
}

event Tick( float DeltaTime ) {
    local RuntimeGrass localGrass;

    super.Tick(DeltaTime);

    // Hacky replication check to ensure destroyed is called.
    // Also ensure this only exists on client that owns the pawn.
    

    // Only do both of these either on the client or in singleplayer (NO SPAWNED GRASS ON SERVER)
    if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone) {
        createGrassMesh(GrassToSpawnInRing);
    }

    if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone) {
        foreach currentGrass(localGrass) {
            localGrass.checkDistanceFromOwner();
        }
    }
}

function DestroyAllGrass() {
    local RuntimeGrass localGrass;

    foreach currentGrass(localGrass) {
        localGrass.Destroy();
    }
}

function RemoveGrassInstance(RuntimeGrass grassToRemove) {
    currentGrass.RemoveItem(grassToRemove);
}

// Creates a RunTimeGrass, if it succeeds the grass is placed into an array, otherwise it returns false.
unreliable client function createGrassMesh(int grassToSpawn) {
    local Vector spawnLocation;
    local Rotator spawnRotation;
    local RuntimeGrass spawnedGrass;
    local int i, rad;
    local float radian;

    // Trace Info
    local TraceHitInfo spawnedGrassTraceInfo;
    local Vector traceHitPos, traceHitNormal, traceEndPos;

    // Optimization :: Stops Spawning Grass if Max Reach
    if (currentGrass.Length > MaxGrassCount) return;

    // Optimization :: If player hasnt moved more than 100 UUs since last check, don't spawn grass.
    if (VSize(lastSpawnPosition - CylinderComponent.GetPosition()) < ReCheckDistance) return;

    rad = CylinderComponent.CollisionRadius-(offsetammount*2);
    lastSpawnPosition = CylinderComponent.GetPosition();

    for (i=0; i < grassToSpawn; i++) {

        // Creates the grass in a circle.
        radian = i * Pi/(grassToSpawn/ 2);
        spawnLocation = CylinderComponent.GetPosition();
        spawnLocation.X += rad * Cos(radian);
        spawnLocation.Y += rad * Sin(radian);

        // Offsets position to make it feel more random

        spawnLocation.X += (offsetammount * ((FRand()*2)-1));
        spawnLocation.Y += (offsetammount * ((FRand()*2)-1));

        spawnLocation.Z += 500; // Allows grass to spawn on ledges/ hills above player

        // Trace downwards to get surface/ hit location/ hitnormal
        traceEndPos = spawnLocation;
        traceEndPos.Z -= 1000;
        //DrawDebugLine(spawnLocation, traceEndPos, 128,128,255, true);
        Trace(traceHitPos, traceHitNormal, traceEndPos, spawnLocation, false,, spawnedGrassTraceInfo);

        // If the physical material is not grass, back out.
        if(spawnedGrassTraceInfo.PhysMaterial != physMatMask) goto'end';

        // Align grass to surface normal.
        spawnLocation = traceHitPos;
        spawnRotation = Rotator(normal(traceHitNormal));
        spawnRotation.Pitch-= 16384;

        // Spawn da grass. If it fails for whatever reason, back out.
        spawnedGrass = Spawn(class'RuntimeGrass', self,, spawnLocation,spawnRotation,,true);
        if (spawnedGrass != none) currentGrass.AddItem(spawnedGrass);
end:
    }   
}

DefaultProperties
{
    physMatMask = PhysicalMaterial'PhysicalMaterials.Default.Stone.PM_Stone'
    MaxGrassCount = 1200
    ReCheckDistance = 100
    GrassToSpawnInRing = 250
    offsetammount = 64

    Begin Object Class=CylinderComponent NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_C  lass
        CollideActors=true
        CollisionRadius=+3000
        CollisionHeight=+512.000000
        HiddenGame=true
    End Object
    CollisionComponent=CollisionCylinder
    CylinderComponent = CollisionCylinder
    Components.Add(CollisionCylinder)

/**
    Begin Object Class=DrawSphereComponent Name=Sphere
        bDrawOnlyIfSelected=false
        bDrawWireSphere=true
        SphereRadius=1024
        SphereSides=32
        SphereColor=(R=255,G=32,B=32)
        HiddenEditor=false
        HiddenGame=false
    End Object
    SphereComponent = Sphere
    Components.Add(Sphere)
**/

    CollisionType = COLLIDE_NoCollision 

    bBlockActors = false
    bCollideActors = true
    bStatic = false;
    bMovable = true;
    bNoDelete = false;
    bHidden = false;
}