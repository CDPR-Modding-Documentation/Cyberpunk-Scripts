import struct animAnimFeatureEntry
{
}

importonly struct StateMachineInstanceData
{
	import var referenceName : CName;
	import var priority : Uint32;
	import var initData : IScriptable;
}

importonly struct StateMachineIdentifier
{
	import var definitionName : CName;
	import var referenceName : CName;
}

importonly struct StateSnapshot
{
	import var instanceData : StateMachineInstanceData;
	import var stateMachineName : CName;
	import var stateName : CName;
	import var running : Bool;
	import var transitionJustHappened : Bool;
}

importonly struct SnapshotResult
{
	import var snapshot : StateSnapshot;
	import var valid : Bool;
}

importonly struct StateSnapshotsContainer
{
	public import static function GetSnapshot( self : StateSnapshotsContainer, stateMachineIdentifier : StateMachineIdentifier ) : SnapshotResult;
}

importonly class StateContext extends IScriptable
{
	public import const function GetTemporaryBoolParameter( parameterName : CName ) : StateResultBool;
	public import const function GetTemporaryIntParameter( parameterName : CName ) : StateResultInt;
	public import const function GetTemporaryFloatParameter( parameterName : CName ) : StateResultFloat;
	public import const function GetTemporaryVectorParameter( parameterName : CName ) : StateResultVector;
	public import const function GetTemporaryCNameParameter( parameterName : CName ) : StateResultCName;
	public import const function GetTemporaryScriptableParameter( parameterName : CName ) : IScriptable;
	public import const function GetTemporaryTweakDBIDParameter( parameterName : CName ) : TweakDBID;
	public import const function GetPermanentBoolParameter( parameterName : CName ) : StateResultBool;
	public import const function GetPermanentIntParameter( parameterName : CName ) : StateResultInt;
	public import const function GetPermanentFloatParameter( parameterName : CName ) : StateResultFloat;
	public import const function GetPermanentVectorParameter( parameterName : CName ) : StateResultVector;
	public import const function GetPermanentCNameParameter( parameterName : CName ) : StateResultCName;
	public import const function GetPermanentScriptableParameter( parameterName : CName ) : IScriptable;
	public import const function GetPermanentTweakDBIDParameter( parameterName : CName ) : TweakDBID;
	public import const function GetBoolParameter( parameterName : CName, optional isPermanent : Bool ) : Bool;
	public import const function GetFloatParameter( parameterName : CName, optional isPermanent : Bool ) : Float;
	public import const function GetIntParameter( parameterName : CName, optional isPermanent : Bool ) : Int32;
	public import const function GetVectorParameter( parameterName : CName, optional isPermanent : Bool ) : Vector4;
	public import const function GetConditionBoolParameter( parameterName : CName ) : StateResultBool;
	public import const function GetConditionBool( parameterName : CName ) : Bool;
	public import const function GetConditionIntParameter( parameterName : CName ) : StateResultInt;
	public import const function GetConditionInt( parameterName : CName ) : Int32;
	public import const function GetConditionFloatParameter( parameterName : CName ) : StateResultFloat;
	public import const function GetConditionFloat( parameterName : CName ) : Float;
	public import const function GetConditionVectorParameter( parameterName : CName ) : StateResultVector;
	public import const function GetConditionCNameParameter( parameterName : CName ) : StateResultCName;
	public import const function GetConditionScriptableParameter( parameterName : CName ) : IScriptable;
	public import const function GetConditionWeakScriptableParameter( parameterName : CName ) : weak< IScriptable >;
	public import const function GetConditionTweakDBIDParameter( parameterName : CName ) : TweakDBID;
	public import const function GetCurrentStates( stateMachineIdentifier : StateMachineIdentifier ) : array< CName >;
	public import const function IsStateActive( stateMachineName : CName, stateName : CName ) : Bool;
	public import const function IsStateActiveWithIdentifier( stateMachineIdentifier : StateMachineIdentifier, stateName : CName ) : Bool;
	public import const function GetStateMachineCurrentState( stateMachineName : CName ) : CName;
	public import const function GetStateMachineCurrentStateWithIdentifier( stateMachineIdentifier : StateMachineIdentifier ) : CName;
	public import const function IsStateMachineActive( stateMachineName : CName ) : Bool;
	public import const function IsStateMachineActiveWithIdentifier( stateMachineIdentifier : StateMachineIdentifier ) : Bool;
	public import const function IsStateJustBecomeActive( stateMachineName : CName, stateName : CName ) : Bool;
	public import const function IsStateJustBecomeActiveWithIdentifier( stateMachineIdentifier : StateMachineIdentifier, stateName : CName ) : Bool;
	public import function SetTemporaryBoolParameter( parameterName : CName, value : Bool, optional force : Bool );
	public import function SetTemporaryIntParameter( parameterName : CName, value : Int32, optional force : Bool );
	public import function SetTemporaryFloatParameter( parameterName : CName, value : Float, optional force : Bool );
	public import function SetTemporaryVectorParameter( parameterName : CName, value : Vector4, optional force : Bool );
	public import function SetTemporaryCNameParameter( parameterName : CName, value : CName, optional force : Bool );
	public import function SetTemporaryScriptableParameter( parameterName : CName, value : IScriptable, optional force : Bool );
	public import function SetTemporaryTweakDBIDParameter( parameterName : CName, value : TweakDBID, optional force : Bool );
	public import function SetPermanentBoolParameter( parameterName : CName, value : Bool, optional force : Bool );
	public import function SetPermanentIntParameter( parameterName : CName, value : Int32, optional force : Bool );
	public import function SetPermanentFloatParameter( parameterName : CName, value : Float, optional force : Bool );
	public import function SetPermanentVectorParameter( parameterName : CName, value : Vector4, optional force : Bool );
	public import function SetPermanentCNameParameter( parameterName : CName, value : CName, optional force : Bool );
	public import function SetPermanentScriptableParameter( parameterName : CName, value : IScriptable, optional force : Bool );
	public import function SetPermanentTweakDBIDParameter( parameterName : CName, value : TweakDBID, optional force : Bool );
	public import const function SetConditionBoolParameter( parameterName : CName, value : Bool, optional force : Bool );
	public import const function SetConditionIntParameter( parameterName : CName, value : Int32, optional force : Bool );
	public import const function SetConditionFloatParameter( parameterName : CName, value : Float, optional force : Bool );
	public import const function SetConditionVectorParameter( parameterName : CName, value : Vector4, optional force : Bool );
	public import const function SetConditionCNameParameter( parameterName : CName, value : CName, optional force : Bool );
	public import const function SetConditionScriptableParameter( parameterName : CName, value : IScriptable, optional force : Bool );
	public import const function SetConditionWeakScriptableParameter( parameterName : CName, value : weak< IScriptable >, optional force : Bool );
	public import const function SetConditionTweakDBIDParameter( parameterName : CName, value : TweakDBID, optional force : Bool );
	public import function RemovePermanentBoolParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentIntParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentFloatParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentVectorParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentCNameParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentScriptableParameter( parameterName : CName ) : Bool;
	public import function RemovePermanentTweakDBIDParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionBoolParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionIntParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionFloatParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionVectorParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionCNameParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionScriptableParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionWeakScriptableParameter( parameterName : CName ) : Bool;
	public import const function RemoveConditionTweakDBIDParameter( parameterName : CName ) : Bool;
}

importonly class StateFunctor extends IScriptable
{
	public import const function GetStaticBoolParameter( parameterName : String ) : StateResultBool;
	public import const function GetStaticIntParameter( parameterName : String ) : StateResultInt;
	public import const function GetStaticFloatParameter( parameterName : String ) : StateResultFloat;
	public import const function GetStaticCNameParameter( parameterName : String ) : StateResultCName;
	public import const function GetStaticStringParameter( parameterName : String ) : StateResultString;
	public import const function GetStaticBoolParameterDefault( parameterName : String, defaultVal : Bool ) : Bool;
	public import const function GetStaticIntParameterDefault( parameterName : String, defaultVal : Int32 ) : Int32;
	public import const function GetStaticFloatParameterDefault( parameterName : String, defaultVal : Float ) : Float;
	public import const function GetStaticCNameParameterDefault( parameterName : String, defaultVal : CName ) : CName;
	public import const function GetStaticStringParameterDefault( parameterName : String, defaultVal : String ) : String;
	public import const function GetStaticBoolArrayParameter( parameterName : String ) : array< Bool >;
	public import const function GetStaticIntArrayParameter( parameterName : String ) : array< Int32 >;
	public import const function GetStaticFloatArrayParameter( parameterName : String ) : array< Float >;
	public import const function GetStaticStringArrayParameter( parameterName : String ) : array< String >;
	public import const function GetStaticCNameArrayParameter( parameterName : String ) : array< CName >;
	public import const function GetStateMachineName() : CName;
	public import const function GetStateName() : CName;
	public import const function GetInStateTime() : Float;
	public import function SetFlavour( flavourName : CName );
	public import const function EnableOnEnterCondition( enable : Bool );
	public import const function IsOnEnterConditionEnabled() : Bool;
}

importonly abstract class StateScriptInterface extends IScriptable
{
	import var owner : weak< GameObject >;
	import var executionOwner : weak< GameObject >;
	import var localBlackboard : weak< IBlackboard >;
	import var ownerEntityID : EntityID;
	import var executionOwnerEntityID : EntityID;

	public import const function GetNow() : Float;
}

import class StateGameScriptInterface extends StateScriptInterface
{
	public import const function GetStateVectorParameter( stateVectorParameter : physicsStateValue ) : Variant;
	public import function SetStateVectorParameter( stateVectorParameter : physicsStateValue, value : Variant ) : Bool;
	public import const function Overlap( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, queryPreset : CName, out result : TraceResult ) : Bool;
	public import const function OverlapWithASingleGroup( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, queryGroup : CName, out result : TraceResult ) : Bool;
	public import const function OverlapMultipleHits( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, queryPreset : CName ) : array< TraceResult >;
	public import const function LocomotionOverlapTest( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, out result : TraceResult ) : Bool;
	public import const function LocomotionOverlapTestExcludeEntity( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, excludedEntity : Entity, out result : TraceResult ) : Bool;
	public import const function Raycast( start : Vector4, end : Vector4, queryPreset : CName ) : TraceResult;
	public import const function RaycastWithASingleGroup( start : Vector4, end : Vector4, queryGroup : CName ) : TraceResult;
	public import const function RaycastMultipleHits( start : Vector4, end : Vector4, queryPreset : CName ) : array< TraceResult >;
	public import const function LocomotionRaycastTest( start : Vector4, end : Vector4 ) : TraceResult;
	public import const function Sweep( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, direction : Vector4, distance : Float, queryPreset : CName, optional assumeInitialPositionClear : Bool, out result : TraceResult ) : Bool;
	public import const function SweepWithASingleGroup( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, direction : Vector4, distance : Float, queryGroup : CName, optional assumeInitialPositionClear : Bool, out result : TraceResult ) : Bool;
	public import const function SweepMultipleHits( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, direction : Vector4, distance : Float, queryPreset : CName ) : array< TraceResult >;
	public import const function LocomotionSweepTest( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, direction : Vector4, distance : Float, optional assumeInitialPositionClear : Bool, out result : TraceResult ) : Bool;
	public import const function GetCollisionReport() : array< ControllerHit >;
	public import const function IsOnGround() : Bool;
	public import const function IsOnMovingPlatform() : Bool;
	public import const function CanCapsuleFit( capsuleHeight : Float, capsuleRadius : Float ) : Bool;
	public import const function HasSecureFooting() : SecureFootingResult;
	public import const function GetActionPrevStateTime( actionName : CName ) : Float;
	public import const function GetActionStateTime( actionName : CName ) : Float;
	public import const function GetActionValue( actionName : CName ) : Float;
	public import const function IsActionJustPressed( actionName : CName ) : Bool;
	public import const function IsActionJustReleased( actionName : CName ) : Bool;
	public import const function IsActionJustHeld( actionName : CName ) : Bool;
	public import const function IsAxisChangeAction( actionName : CName ) : Bool;
	public import const function IsRelativeChangeAction( actionName : CName ) : Bool;
	public import const function GetActionPressCount( actionName : CName ) : Uint32;

	public const function IsActionJustTapped( actionName : CName ) : Bool
	{
		if( !( IsActionJustReleased( actionName ) ) )
		{
			return false;
		}
		if( GetActionPrevStateTime( actionName ) > 0.2 )
		{
			return false;
		}
		return true;
	}

	public import function SetComponentVisibility( actionName : CName, visibility : Bool ) : Bool;
	public import function GetObjectFromComponent( targetingComponent : IPlacedComponent ) : GameObject;
	public import const function TransformInvPointFromObject( point : Vector4, optional object : GameObject ) : Vector4;
	public import function ActivateCameraSetting( settingId : CName ) : Bool;
	public import function SetCameraTimeDilationCurve( curveName : CName ) : Bool;
	public import const function GetCameraWorldTransform() : Transform;
	public import function TEMP_WeaponStopFiring() : Bool;
	public import const function IsTriggerModeActive( const triggerMode : gamedataTriggerMode ) : Bool;
	public import const function GetMeleeAttackData( attackRecord : weak< Attack_Melee_Record >, staminaCost : Float, attackSpeed : Float ) : MeleeAttackData;
	public import function SetAnimationParameterInt( key : CName, value : Int32 ) : Bool;
	public import function SetAnimationParameterFloat( key : CName, value : Float ) : Bool;
	public import function SetAnimationParameterBool( key : CName, value : Bool ) : Bool;
	public import function SetAnimationParameterVector( key : CName, value : Vector4 ) : Bool;
	public import function SetAnimationParameterQuaternion( key : CName, value : Quaternion ) : Bool;
	public import function SetAnimationParameterFeature( key : CName, value : AnimFeature, optional owner : GameObject ) : Bool;
	public import function PushAnimationEvent( eventName : CName ) : Bool;
	public import const function IsSceneAnimationActive() : Bool;
	public import const function IsMoveInputConsiderable() : Bool;
	public import const function GetInputHeading() : Float;
	public import const function GetOwnerStateVectorParameterFloat( parameterType : physicsStateValue ) : Float;
	public import const function GetOwnerStateVectorParameterVector( parameterType : physicsStateValue ) : Vector4;
	public import const function GetOwnerMovingDirection() : Vector4;
	public import const function GetOwnerForward() : Vector4;
	public import const function GetOwnerTransform() : Transform;
	public import const function MeetsPrerequisites( prereqName : TweakDBID ) : Bool;
	public import const function GetItemIdInSlot( slotName : TweakDBID ) : ItemID;
	public import const function CanEquipItem( const stateContext : StateContext ) : Bool;
	public import const function IsMountedToObject( optional object : GameObject ) : Bool;
	public import const function IsDriverInVehicle( optional child : GameObject, optional parent : GameObject ) : Bool;
	public import const function IsPassengerInVehicle( optional child : GameObject, optional parent : GameObject ) : Bool;
	public import const function GetMountingInfo( child : GameObject ) : MountingInfo;
	public import const function GetRoleForSlot( slot : MountingSlotId, parent : GameObject, optional occupantSlotComponentName : CName ) : gameMountingSlotRole;
	public import const function GetWaterLevel( puppetPosition : Vector4, referencePosition : Vector4, out waterLevel : Float ) : Bool;
	public import const function IsEntityInCombat( optional objectId : EntityID ) : Bool;
	public import const function CanEnterInteraction( const stateContext : StateContext ) : Bool;
	public import static function CreateWaterImpulse( position : Vector4, radius : Float, strength : Float, numFrames : Uint32 );
	public import const function RequestWeaponEquipOnServer( slotName : TweakDBID, itemId : ItemID );
	public import const function HasStatFlag( flag : gamedataStatType ) : Bool;
	public import const function HasStatFlagOwner( flag : gamedataStatType, owner : GameObject ) : Bool;
	public import const function IsPlayerInBraindance() : Bool;
	public import const function GetScriptableSystem( name : CName ) : ScriptableSystem;
	public import const function GetGame() : GameInstance;
	public import const function GetActivityLogSystem() : ActivityLogSystem;
	public import const function GetAttitudeSystem() : AttitudeSystem;
	public import const function GetAudioSystem() : AudioSystem;
	public import const function GetBlackboardSystem() : BlackboardSystem;
	public import const function GetCameraSystem() : CameraSystem;
	public import const function GetCommunitySystem() : CommunitySystem;
	public import const function GetCompanionSystem() : CompanionSystem;
	public import const function GetCoverManager() : CoverManager;
	public import const function GetDebugVisualizerSystem() : DebugVisualizerSystem;
	public import const function GetDebugDrawHistorySystem() : IDebugDrawHistorySystem;
	public import const function GetDelaySystem() : DelaySystem;
	public import const function GetDeviceSystem() : DeviceSystem;
	public import const function GetEntitySpawnerEventsBroadcaster() : EntitySpawnerEventsBroadcaster;
	public import const function GetGameEffectSystem() : EffectSystem;
	public import const function GetSpatialQueriesSystem() : SpatialQueriesSystem;
	public import const function GetLootManager() : LootManager;
	public import const function GetLocationManager() : LocationManager;
	public import const function GetMappinSystem() : MappinSystem;
	public import const function GetObjectPoolSystem() : ObjectPoolSystem;
	public import const function GetPersistencySystem() : GamePersistencySystem;
	public import const function GetPlayerSystem() : PlayerSystem;
	public import const function GetPrereqManager() : PrereqManager;
	public import const function GetPreventionSpawnSystem() : PreventionSpawnSystem;
	public import const function GetQuestsSystem() : QuestsSystem;
	public import const function GetSceneSystem() : SceneSystem;
	public import const function GetScriptableSystemsContainer() : ScriptableSystemsContainer;
	public import const function GetStatPoolsSystem() : StatPoolsSystem;
	public import const function GetStatsSystem() : StatsSystem;
	public import const function GetStatsDataSystem() : StatsDataSystem;
	public import const function GetStatusEffectSystem() : StatusEffectSystem;
	public import const function GetGodModeSystem() : GodModeSystem;
	public import const function GetEffectorSystem() : EffectorSystem;
	public import const function GetDamageSystem() : DamageSystem;
	public import const function GetTargetingSystem() : TargetingSystem;
	public import const function GetTimeSystem() : TimeSystem;
	public import const function GetTransactionSystem() : TransactionSystem;
	public import const function GetVisionModeSystem() : VisionModeSystem;
	public import const function GetVehicleSystem() : VehicleSystem;
	public import const function GetWorkspotSystem() : WorkspotGameSystem;
	public import const function GetInventoryManager() : InventoryManager;
	public import const function GetTeleportationFacility() : TeleportationFacility;
	public import const function GetInfluenceMapSystem() : InfluenceMapSystem;
	public import const function GetFxSystem() : FxSystem;
	public import const function GetMountingFacility() : IMountingFacility;
	public import const function GetRestrictMovementAreaManager() : RestrictMovementAreaManager;
	public import const function GetSafeAreaManager() : SafeAreaManager;
	public import const function GetGameplayLogicPackageSystem() : GameplayLogicPackageSystem;
	public import const function GetJournalManager() : JournalManager;
	public import const function GetDebugCheatsSystem() : DebugCheatsSystem;
	public import const function GetCombatQueriesSystem() : gameICombatQueriesSystem;
	public import const function GetTelemetrySystem() : TelemetrySystem;
	public import const function GetGameRulesSystem() : gameIGameRulesSystem;
	public import const function GetGameTagSystem() : GameTagSystem;
	public import const function GetPingSystem() : PingSystem;
	public import const function GetPlayerManagerSystem() : gameIPlayerManager;
	public import const function GetScriptsDebugOverlaySystem() : ScriptsDebugOverlaySystem;
	public import const function GetCooldownSystem() : ICooldownSystem;
	public import const function GetDebugPlayerBreadcrumbs() : DebugPlayerBreadcrumbs;
	public import const function GetInteractionManager() : InteractionManager;
	public import const function GetSubtitleHandlerSystem() : SubtitleHandlerSystem;
	public import const function GetAINavigationSystem() : AINavigationSystem;
	public import const function GetSenseManager() : SenseManager;
	public import const function GetUISystem() : UISystem;
	public import const function GetAchievementSystem() : AchievementSystem;
	public import const function GetWatchdogSystem() : IWatchdogSystem;
	public import const function GetLevelAssignmentSystem() : LevelAssignmentSystem;
	public import const function GetPhotoModeSystem() : PhotoModeSystem;
	public import const function GetCharacterCustomizationSystem() : gameuiICharacterCustomizationSystem;
	public import const function GetOnlineSystem() : IOnlineSystem;
}

import struct StateResultBool
{
	import var valid : Bool;
	import var value : Bool;
}

import struct StateResultInt
{
	import var valid : Bool;
	import var value : Int32;
}

import struct StateResultFloat
{
	import var valid : Bool;
	import var value : Float;
}

import struct StateResultVector
{
	import var valid : Bool;
	import var value : Vector4;
}

import struct StateResultCName
{
	import var valid : Bool;
	import var value : CName;
}

import struct StateResultString
{
	import var valid : Bool;
	import var value : String;
}

importonly class LadderDescription extends IScriptable
{
	import var position : Vector4;
	import var normal : Vector4;
	import var up : Vector4;
	import var topHeightFromPosition : Float;
	import var exitStepTop : Float;
	import var verticalStepTop : Float;
	import var exitStepBottom : Float;
	import var verticalStepBottom : Float;
	import var exitStepJump : Float;
	import var verticalStepJump : Float;
	import var enterOffset : Float;
}

importonly class ItemEquipRequest extends IScriptable
{
	import var slotId : TweakDBID;
	import var itemId : ItemID;
	import var startingRenderingPlane : ERenderingPlane;
}

importonly class ItemUnequipRequest extends IScriptable
{
	import var slotId : TweakDBID;
	import var itemId : ItemID;
	import var instant : Bool;
}

importonly class LocomotionParameters extends IScriptable
{
	public import function SetUpwardsGravity( value : Float );
	public import function SetDownwardsGravity( value : Float );
	public import function SetImperfectTurn( value : Bool );
	public import function SetSpeedBoostInputRequired( value : Bool );
	public import function SetSpeedBoostMultiplyByDot( value : Bool );
	public import function SetUseCameraHeadingForMovement( value : Bool );
	public import function SetCapsuleHeight( value : Float );
	public import function SetCapsuleRadius( value : Float );
	public import function SetDoJump( value : Bool );
	public import function SetIgnoreSlope( value : Bool );
	public import function GetUpwardsGravity( defaultValue : Float ) : Float;
	public import function GetDownwardsGravity( defaultValue : Float ) : Float;
	public import function GetImperfectTurn( defaultValue : Bool ) : Bool;
	public import function GetSpeedBoostInputRequired( defaultValue : Bool ) : Bool;
	public import function GetSpeedBoostMultiplyByDot( defaultValue : Bool ) : Bool;
	public import function GetUseCameraHeadingForMovement( defaultValue : Bool ) : Bool;
	public import function GetCapsuleHeight( defaultValue : Float ) : Float;
	public import function GetCapsuleRadius( defaultValue : Float ) : Float;
	public import function GetDoJump( defaultValue : Bool ) : Bool;
	public import function GetIgnoreSlope( defaultValue : Bool ) : Bool;
}

importonly class AdjustTransform extends IScriptable
{
}

importonly class AdjustTransformWithDurations extends AdjustTransform
{
	public import function SetPosition( value : Vector4 );
	public import function SetRotation( value : Quaternion );
	public import function SetSlideDuration( value : Float );
	public import function SetRotationDuration( value : Float );
	public import function SetGravity( value : Float );
	public import function SetCurve( value : CName );
	public import function SetTarget( value : weak< GameObject > );
	public import function SetDistanceRadius( value : Float );
	public import function SetUseParabolicMotion( value : Bool );
}

importonly class ClimbParametersBase extends IScriptable
{
	public import function SetObstacleFrontEdgePosition( val : Vector4 );
	public import function SetObstacleFrontEdgeNormal( val : Vector4 );
	public import function SetObstacleVerticalDestination( val : Vector4 );
	public import function SetObstacleHorizontalDestination( val : Vector4 );
	public import function SetObstacleSurfaceNormal( val : Vector4 );
	public import function SetAnimationNameApproach( val : CName );
}

importonly class ClimbParameters extends ClimbParametersBase
{
	public import function SetHorizontalDuration( val : Float );
	public import function SetVerticalDuration( val : Float );
	public import function SetClimbedEntity( val : weak< Entity > );
	public import function SetClimbType( val : Int32 );
}

importonly class VaultParameters extends ClimbParametersBase
{
	public import function SetObstacleDestination( val : Vector4 );
	public import function SetObstacleDepth( val : Float );
	public import function SetMinSpeed( val : Float );
}

importonly class LocomotionSwimmingParameters extends LocomotionParameters
{
	public import function SetBuoyancyLineFraction( val : Float );
	public import function SetDragCoefficient( val : Float );
}

importonly class LocomotionBraindanceParameters extends LocomotionParameters
{
	public import function SetUpperMovementLimit( val : Float );
	public import function SetLowerMovementLimit( val : Float );
}

importonly class SceneTier extends StimuliData
{
	public import function SetTierData( tierData : SceneTierData );
	public import function GetTierData() : SceneTierData;
	public import function GetTier() : GameplayTier;
	public import function GetForceEmptyHands() : Bool;
}

import class MountEventData extends IScriptable
{
	import var slotName : CName;
	import var mountParentEntityId : EntityID;
	import var isInstant : Bool;
	import var entryAnimName : CName;
	import var initialTransformLS : Transform;
	import var mountEventOptions : MountEventOptions;
	import var ignoreHLS : Bool;

	public function IsTransitionForced() : Bool
	{
		if( slotName == 'trunk_body' )
		{
			return true;
		}
		return false;
	}

}

import class MountEventOptions extends IScriptable
{
	var entityID : EntityID;
	var alive : Bool;
	var occupiedByNeutral : Bool;
	import var silentUnmount : Bool;
}

importonly final class MountAIEvent extends AIEvent
{
	import var data : MountEventData;
}

importonly final class ActivateTriggerDestructionComponentEvent extends Event
{
}

importonly final class DeactivateTriggerDestructionComponentEvent extends Event
{
}

import struct SecureFootingParameters
{
	import var unsecureCollisionFilterName : CName;
	import var slopeCurveName : CName;
	import var maxVerticalDistanceForCentreRaycast : Float;
	import var maxAngularDistanceForOtherRaycasts : Float;
	import var standingMinNumberOfRaycasts : Uint32;
	import var standingMinCollisionHorizontalDistance : Float;
	import var fallingMinNumberOfRaycasts : Uint32;
	import var fallingMinCollisionHorizontalDistance : Float;
	import var maxStaticGroundFactor : Float;
	import var minVelocityForFalling : Float;
	import var needsCentreRaycast : Bool;
}

import struct SecureFootingResult
{
	import var slidingDirection : Vector4;
	import var normalDirection : Vector4;
	import var lowestLocalPosition : Vector4;
	import var staticGroundFactor : Float;
	import var reason : moveSecureFootingFailureReason;
	import var type : moveSecureFootingFailureType;
}

import enum physicsStateValue
{
	Position,
	Rotation,
	LinearVelocity,
	AngularVelocity,
	LinearSpeed,
	TouchesWalls,
	ImpulseAccumulator,
	Mass,
	Volume,
	IsSimulated,
	IsKinematic,
	SimulationFilter,
	Radius,
}

enum EDodgeMovementInput
{
	Invalid = 0,
	Forward = 1,
	Right = 2,
	Left = 3,
	Back = 4,
}

import enum gameStoryTier : Uint8
{
	Gameplay,
	Cinematic,
}

import enum gamePlayerStateMachine
{
	Locomotion,
	UpperBody,
	Weapon,
	HighLevel,
	Projectile,
	Vision,
	TimeDilation,
	CoverAction,
	IconicItem,
	Combat,
	Takedown,
}

import enum gamePSMLocomotionStates
{
	Default,
	Crouch,
	Sprint,
	Kereznikov,
	Jump,
	Vault,
	Dodge,
	DodgeAir,
	Workspot,
	Slide,
	SlideFall,
}

import enum gamePSMUpperBodyStates
{
	Default,
	SwitchItems,
	SwitchCyberware,
	Reload,
	TemporaryUnequip,
	ForceEmptyHands,
	Aim,
}

import enum gamePSMWeaponStates
{
	Default,
	NoAmmo,
	Ready,
	Safe,
}

import enum gamePSMTimeDilation
{
	Default,
	Sandevistan,
}

import enum gamePSMHighLevel
{
	Default,
	SceneTier1,
	SceneTier2,
	SceneTier3,
	SceneTier4,
	SceneTier5,
	Swimming,
}

import enum gamePSMZones
{
	Default,
	Public,
	Safe,
	Restricted,
	Dangerous,
}

import enum gamePSMBodyCarryingStyle
{
	Any,
	Default,
	Friendly,
	Strong,
}

import enum gamePSMBodyCarrying
{
	Default,
	PickUp,
	Carry,
	Dispose,
	Drop,
}

import enum gamePSMMelee
{
	Default,
	Attack,
	Block,
}

enum gamePSMUIState
{
	None = 0,
	WeaponSelect = 1,
}

enum gamePSMCrosshairStates
{
	Default = 0,
	Safe = 1,
	Scanning = 2,
	GrenadeCharging = 3,
	Aim = 4,
	Reload = 5,
	Sprint = 6,
	HipFire = 7,
	LeftHandCyberware = 8,
	QuickHack = 9,
}

enum gamePSMReaction
{
	Default = 0,
	Stagger = 1,
}

enum gamePSMVisionDebug
{
	Default = 0,
	VisionToggle = 1,
}

import enum gamePSMVision
{
	Default,
	Focus,
}

enum gamePSMCombatGadget
{
	Default = 0,
	EquipRequest = 1,
	Equipped = 2,
	Charging = 3,
	Throwing = 4,
	WaitForUnequip = 5,
	QuickThrow = 6,
}

import enum gamePSMVehicle
{
	Default,
	Driving,
	Combat,
	Passenger,
	Transition,
	Turret,
	DriverCombat,
	Scene,
}

enum gamePSMWhip
{
	Default = 0,
	Charging = 1,
	Pulling = 2,
}

enum coverLeanDirection
{
	Top = 0,
	Left = 1,
	Right = 2,
}

enum gamePSMLeftHandCyberware
{
	Default = 0,
	Safe = 1,
	EquipRequest = 2,
	Idle = 3,
	Equipped = 4,
	Charge = 5,
	Loop = 6,
	Catch = 7,
	QuickAction = 8,
	ChargeAction = 9,
	CatchAction = 10,
	StartUnequip = 11,
	Unequip = 12,
}

enum gamePSMMeleeWeapon
{
	NotReady = 0,
	Idle = 1,
	Safe = 2,
	PublicSafe = 3,
	Parried = 4,
	Hold = 5,
	ChargedHold = 6,
	Block = 7,
	Targeting = 8,
	Deflect = 9,
	ComboAttack = 10,
	FinalAttack = 11,
	StrongAttack = 12,
	SafeAttack = 13,
	BlockAttack = 14,
	SprintAttack = 15,
	CrouchAttack = 16,
	JumpAttack = 17,
	ThrowAttack = 18,
	DeflectAttack = 19,
	EquipAttack = 20,
	Default = 21,
}

import enum gamePSMDetailedLocomotionStates
{
	NotInBaseLocomotion,
	Stand,
	AimWalk,
	Crouch,
	Sprint,
	Slide,
	SlideFall,
	Dodge,
	Climb,
	Vault,
	Ladder,
	LadderSprint,
	LadderSlide,
	LadderJump,
	Fall,
	AirThrusters,
	AirHover,
	SuperheroFall,
	Jump,
	DoubleJump,
	ChargeJump,
	HoverJump,
	DodgeAir,
	RegularLand,
	HardLand,
	VeryHardLand,
	DeathLand,
	SuperheroLand,
	SuperheroLandRecovery,
	Knockdown,
}

import enum gamePSMCombat
{
	Default,
	InCombat,
	OutOfCombat,
	Stealth,
}

enum gamePSMStamina
{
	Rested = 0,
	Exhausted = 1,
}

import enum gamePSMVitals
{
	Alive,
	Dead,
	Resurrecting,
}

import enum gamePSMTakedown
{
	Default,
	EnteringGrapple,
	Grapple,
	Leap,
	Takedown,
}

enum gamePSMRangedWeaponStates
{
	Default = 0,
	Charging = 1,
	Reload = 2,
	QuickMelee = 3,
	NoAmmo = 4,
	Ready = 5,
	Safe = 6,
	Overheat = 7,
	Shoot = 8,
}

import enum gamePSMFallStates
{
	Default,
	RegularFall,
	SafeFall,
	FastFall,
	VeryFastFall,
	DeathFall,
}

import enum gamePSMLandingState
{
	Default,
	RegularLand,
	HardLand,
	VeryHardLand,
	DeathLand,
	SuperheroLand,
	SuperheroLandRecovery,
}

enum braindanceVisionMode
{
	Default = 0,
	Audio = 1,
	Thermal = 2,
}

enum gamePSMWorkspotState
{
	Default = 0,
	Workspot = 1,
}

import enum gamePSMSwimming
{
	Default,
	Surface,
	Diving,
}

enum gamePSMBodyCarryingLocomotion
{
	Default = 0,
	Jump = 1,
	Crouch = 2,
	Sprint = 3,
	Fall = 4,
	Land = 5,
	DropBody = 6,
}

enum gamePSMDetailedBodyDisposal
{
	Default = 0,
	Dispose = 1,
	Lethal = 2,
	NonLethal = 3,
}

enum gamePSMNanoWireLaunchMode
{
	Default = 0,
	Primary = 1,
	Secondary = 2,
}

import enum moveSecureFootingFailureReason
{
	Invalid,
	Filter,
	SimulationType,
	Ground,
}

import enum moveSecureFootingFailureType
{
	Invalid,
	Edge,
	Slope,
}

