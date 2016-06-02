class NearFoliageManager extends Actor;

var const CylinderComponent CylinderComponent;

// aditional meshes types
var archetype array<RuntimeGrass> Foliage;
var archetype array<RuntimeGrass> Rocks;

// Grass Counts
var array<RuntimeGrass> currentGrass;
var array<RuntimeGrass> sleepGrass;
var array<RuntimeGrass> currentGrass2;
var array<RuntimeGrass> sleepGrass2;
var array<RuntimeGrass> currentGrass3;
var array<RuntimeGrass> sleepGrass3;

var int GrassToSpawnInRing;
var int GrassWidth;
var int offsetammount;

// Phys Material
var PhysicalMaterial physMatMask; //for grass
var PhysicalMaterial physMatMask2; //for sand

// Optimization
var Vector lastSpawnPosition;
var int ReCheckDistance;
var int MaxGrassCount;

//Initial filling
var float IniCil;


simulated function PostBeginPlay() {
super.PostBeginPlay();
Owner.AttachComponent(CylinderComponent);
}

event Destroyed() {
Owner.DetachComponent(CylinderComponent);
DestroyAllGrass();
super.Destroyed();
}

event Tick( float DeltaTime ) 
{
local RuntimeGrass localGrass;
local vector CylinderPosition;
local float Radius;

// Only do both of these either on the client or in singleplayer (NO SPAWNED GRASS ON SERVER)
if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone) 
{
// Optimization :: If player hasnt moved more than 100 UUs since last check, don't spawn grass.
CylinderPosition = CylinderComponent.GetPosition();
if (VSize(lastSpawnPosition - CylinderPosition) >= ReCheckDistance)
{
Radius = CylinderComponent.CollisionRadius + 50;
foreach currentGrass(localGrass) { if (VSize2D(Localgrass.Location - CylinderPosition) > Radius) { currentGrass.RemoveItem(localgrass); sleepGrass.AddItem(LocalGrass); LocalGrass.sethidden(true); } }
foreach currentGrass2(localGrass) { if (VSize2D(Localgrass.Location - CylinderPosition) > Radius) { currentGrass2.RemoveItem(localgrass); sleepGrass2.AddItem(LocalGrass); LocalGrass.sethidden(true); } }
foreach currentGrass3(localGrass) { if (VSize2D(Localgrass.Location - CylinderPosition) > Radius) { currentGrass3.RemoveItem(localgrass); sleepGrass3.AddItem(LocalGrass); LocalGrass.sethidden(true); } }
if (currentGrass.Length < MaxGrassCount) { createGrassMesh(); }
lastSpawnPosition = CylinderComponent.GetPosition();
}
}
}

function DestroyAllGrass() {
local RuntimeGrass localGrass;
foreach Worldinfo.AllActors(class'RuntimeGrass', localgrass)
{
localGrass.Destroy();
}
}


// Creates a RunTimeGrass, if it succeeds the grass is placed into an array, otherwise it returns false.
unreliable client function createGrassMesh() 
{
local Vector spawnLocation, Cil, traceHitPos, traceHitNormal, traceEndPos;
local Rotator spawnRotation;
local RuntimeGrass spawnedGrass, Arq;
local int i, rad, rad2, rndfol, GrassToSpawn;
local float radian;
local TraceHitInfo spawnedGrassTraceInfo;

Cil = CylinderComponent.GetPosition();
Fill:
rad2 = CylinderComponent.CollisionRadius-(offsetammount*2);
rad = inicil;
if (rad < rad2) { inicil += ReCheckDistance*1.0+rand(5); if (inicil > rad2) { inicil = rad2; }}

GrassToSpawn = (2*pi*rad) / GrassWidth;
for (i=0; i < grassToSpawn; i++) 
{
// Creates the grass in a circle.
radian = i * Pi/(grassToSpawn/2);
spawnLocation = Cil;
spawnLocation.X += rad * Cos(radian);
spawnLocation.Y += rad * Sin(radian);

// Offsets position to make it feel more random
spawnLocation.X += (offsetammount * ((FRand()*2)-1));
spawnLocation.Y += (offsetammount * ((FRand()*2)-1));
spawnLocation.Z += 1500; // Allows grass to spawn on ledges/ hills above player

// Trace downwards to get surface/ hit location/ hitnormal
traceEndPos = spawnLocation;
traceEndPos.Z -= 3500;
//DrawDebugLine(spawnLocation, traceEndPos, 128,128,255, true);
Trace(traceHitPos, traceHitNormal, traceEndPos, spawnLocation, false,, spawnedGrassTraceInfo);

// If the physical material is not grass, back out.
if(spawnedGrassTraceInfo.PhysMaterial == physMatMask)
{
// Align grass to surface normal.
spawnLocation = traceHitPos;
spawnRotation = Rotator(normal(traceHitNormal));
spawnRotation.Pitch-= 16384;
// Spawn da grass. If it fails for whatever reason, back out.
spawnedGrass = none; if (sleepGrass.length > 0) { spawnedGrass = SleepGrass[sleepGrass.length-1]; }
if (spawnedGrass != none) { SleepGrass.length = SleepGrass.length-1; spawnedGrass.setlocation(spawnLocation); spawnedGrass.setrotation(spawnRotation); spawnedGrass.sethidden(false); }
else if (SleepGrass.length + CurrentGrass.length < MaxGrassCount) { spawnedGrass = Spawn(class'RuntimeGrass', self,, spawnLocation,spawnRotation,,true); if (spawnedGrass != none) { spawnedGrass.setdrawscale(spawnedGrass.drawscale + randrange(-0.25,0.25)); spawnedGrass.SetTickIsDisabled(True); } }
if (spawnedGrass != none) currentGrass.AddItem(spawnedGrass);

rndfol = rand(100);
if (rndfol < 10) { arq = foliage[0]; }
else if (rndfol < 11) { arq = foliage[1]; }
else if (rndfol < 12) { arq = foliage[2]; }
else if (rndfol < 13) { arq = foliage[3]; }
else if (rndfol < 14) { arq = foliage[4]; }
else if (rndfol < 15) { arq = foliage[5]; }
else if (rndfol < 16) { arq = foliage[6]; }
else if (rndfol < 17) { arq = foliage[7]; }
else if (rndfol < 18) { arq = foliage[8]; }
else if (rndfol < 19) { arq = foliage[9]; }
else if (rndfol < 20) { arq = foliage[10]; }
else { arq = none; }
if (arq != none)
{ 
spawnedGrass = none; if (sleepGrass2.length > 0) { spawnedGrass = SleepGrass2[sleepGrass2.length-1]; sleepGrass2.length = sleepGrass2.length-1; spawnedGrass.setlocation(spawnLocation); spawnedGrass.setrotation(spawnRotation); spawnedGrass.sethidden(false); }
else if (SleepGrass2.length + CurrentGrass2.length < MaxGrassCount/6) { spawnRotation.yaw = -32768 + Rand(65535); spawnedGrass = Spawn(arq.class, self,, spawnLocation,spawnRotation,arq,true); if (spawnedGrass != none) { spawnedGrass.setdrawscale(spawnedGrass.drawscale + randrange(-0.25,0.25)); spawnedGrass.SetTickIsDisabled(True); } }
if (spawnedGrass != none) currentGrass2.AddItem(spawnedGrass);
}
}
else if(spawnedGrassTraceInfo.PhysMaterial == physMatMask2)
{
// Align grass to surface normal.
spawnLocation = traceHitPos;
spawnRotation = Rotator(normal(traceHitNormal));
spawnRotation.Pitch-= 16384;
rndfol = rand(100);
if (rndfol < 3) { arq = rocks[0]; }
else if (rndfol < 6) { arq = rocks[1]; }
else if (rndfol < 9) { arq = rocks[2]; }
else { arq = none; }
if (arq != none)
{ 
spawnedGrass = none; if (sleepGrass3.length > 0) { spawnedGrass = SleepGrass3[sleepGrass3.length-1]; sleepGrass3.length = sleepGrass3.length-1; spawnedGrass.setlocation(spawnLocation); spawnedGrass.setrotation(spawnRotation); spawnedGrass.sethidden(false); }
else if (SleepGrass3.length + CurrentGrass3.length < MaxGrassCount/8) { spawnRotation.yaw = -32768 + Rand(65535); spawnedGrass = Spawn(arq.class, self,, spawnLocation,spawnRotation,arq,true); if (spawnedGrass != none) { spawnedGrass.setdrawscale(spawnedGrass.drawscale + randrange(-0.25,0.25)); spawnedGrass.SetTickIsDisabled(True); } }
if (spawnedGrass != none) currentGrass3.AddItem(spawnedGrass);
}
}
} 
if (rad2 - rad > 10) { goto'Fill'; }
}



DefaultProperties
{
physMatMask = PhysicalMaterial'TEST-xPruebas.Material.FootStep_hierba'
physMatMask2 = PhysicalMaterial'TEST-xPruebas.Material.FootStep_tierra'
MaxGrassCount = 250

ReCheckDistance = 190
GrassWidth = 190
offsetammount = 32

Begin Object Class=CylinderComponent NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_C lass
CollideActors=false
CollisionRadius=+3000
CollisionHeight=+1024
HiddenGame=True
End Object
CollisionComponent=CollisionCylinder
CylinderComponent = CollisionCylinder
Components.Add(CollisionCylinder)

CollisionType = COLLIDE_NoCollision 

bBlockActors = false
bCollideActors = false
bStatic = false;
bMovable = true;
bNoDelete = false;
bHidden = TRUE;

IniCil=1
foliage[0]=RuntimeGrass'TEST-archetypes.Foliage.Flores'
foliage[1]=RuntimeGrass'TEST-archetypes.Foliage.Palmerillas'
foliage[2]=RuntimeGrass'TEST-archetypes.Foliage.Musgo'
foliage[3]=RuntimeGrass'TEST-archetypes.Foliage.Arbolito'
foliage[4]=RuntimeGrass'TEST-archetypes.Foliage.Palmerillas2'
foliage[5]=RuntimeGrass'TEST-archetypes.Foliage.Piedra1'
foliage[6]=RuntimeGrass'TEST-archetypes.Foliage.Palmerillas3'
foliage[7]=RuntimeGrass'TEST-archetypes.Foliage.Arbolito2'
foliage[8]=RuntimeGrass'TEST-archetypes.Foliage.Arbolito3'
foliage[9]=RuntimeGrass'TEST-archetypes.Foliage.Palmerillas4'
foliage[10]=RuntimeGrass'TEST-archetypes.Foliage.Palmerillas5'
Rocks[0]=RuntimeGrass'TEST-archetypes.Foliage.roca1'
Rocks[1]=RuntimeGrass'TEST-archetypes.Foliage.roca2'
Rocks[2]=RuntimeGrass'TEST-archetypes.Foliage.roca3'
}