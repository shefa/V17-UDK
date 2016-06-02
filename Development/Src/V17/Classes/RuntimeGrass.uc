class RuntimeGrass extends StaticMeshActor
placeable;

var DynamicLightEnvironmentComponent LightEnvironment;


DefaultProperties
{
    
    
            
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=TRUE
        bIsCharacterLightEnvironment=FALSE
        bUseBooleanEnvironmentShadowing=FALSE
        InvisibleUpdateTime=5
        MinTimeBetweenFullUpdates=1
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment
    
Begin Object Name=StaticMeshComponent0
StaticMesh=StaticMesh'Some_Plants.Grass.S_GrassClump_02'
Materials(0)=MaterialInstanceConstant'Some_Plants.Grass.ads'
LightEnvironment=MyLightEnvironment
CastShadow=false
bAcceptsLights=True
bAcceptsDynamicLights=true
bAcceptsDynamicDominantLightShadows=true
BlockRigidBody=False
BlockActors=False
BlockZeroExtent=False
BlockNonZeroExtent=False
CollideActors=False
bUsePrecomputedShadows=False
            ReplacementPrimitive=None
            bAllowApproximateOcclusion=True
            bForceDirectLightMap=True
            LightingChannels=(bInitialized=True,Static=True)
End Object
StaticMeshComponent=StaticMeshComponent0
DrawScale = 2.5
bNoDelete = false
bStatic = false
bMovable = true
}