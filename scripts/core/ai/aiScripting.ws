import class AIBehaviorScriptBase extends IScriptable
{
	public import function ToString() : String;

	public virtual function GetDescription( context : ScriptExecutionContext ) : String
	{
		return ToString();
	}

	public static function GetPuppet( context : ScriptExecutionContext ) : ScriptedPuppet
	{
		return ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) );
	}

	public static function GetNPCPuppet( context : ScriptExecutionContext ) : NPCPuppet
	{
		return ( ( NPCPuppet )( ScriptExecutionContext.GetOwner( context ) ) );
	}

	public static function GetGame( context : ScriptExecutionContext ) : GameInstance
	{
		return ScriptExecutionContext.GetOwner( context ).GetGame();
	}

	public static function GetHitReactionComponent( context : ScriptExecutionContext ) : HitReactionComponent
	{
		return GetPuppet( context ).GetHitReactionComponent();
	}

	public static function GetAIComponent( context : ScriptExecutionContext ) : AIHumanComponent
	{
		return GetPuppet( context ).GetAIControllerComponent();
	}

	public static function GetStatPoolValue( context : ScriptExecutionContext, statPoolType : gamedataStatPoolType ) : Float
	{
		var ownerID : StatsObjectID;
		ownerID = ScriptExecutionContext.GetOwner( context ).GetEntityID();
		return GameInstance.GetStatPoolsSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).GetStatPoolValue( ownerID, statPoolType, false );
	}

	public static function GetStatPoolPercentage( context : ScriptExecutionContext, statPoolType : gamedataStatPoolType ) : Float
	{
		var ownerID : StatsObjectID;
		ownerID = ScriptExecutionContext.GetOwner( context ).GetEntityID();
		return GameInstance.GetStatPoolsSystem( ScriptExecutionContext.GetOwner( context ).GetGame() ).GetStatPoolValue( ownerID, statPoolType, true );
	}

	public static function GetCombatTarget( context : ScriptExecutionContext ) : GameObject
	{
		return ScriptExecutionContext.GetArgumentObject( context, 'CombatTarget' );
	}

	public static function GetCompanion( context : ScriptExecutionContext ) : GameObject
	{
		return ScriptExecutionContext.GetArgumentObject( context, 'Companion' );
	}

	public static function GetUpperBodyState( context : ScriptExecutionContext ) : gamedataNPCUpperBodyState
	{
		return ( ( gamedataNPCUpperBodyState )( GetPuppet( context ).GetPuppetStateBlackboard().GetInt( GetAllBlackboardDefs().PuppetState.UpperBody ) ) );
	}

	public static function RandomizeOffsetForUpdateInterval( interval : Float ) : Float
	{
		var randomCheckIntervalMods : array< Float >;
		randomCheckIntervalMods.Resize( 3 );
		randomCheckIntervalMods[ 0 ] = 0.0;
		randomCheckIntervalMods[ 1 ] = 0.0334;
		randomCheckIntervalMods[ 2 ] = 0.0667;
		return interval += randomCheckIntervalMods[ RandRange( 0, 3 ) ];
	}

}

import class AIbehaviorconditionScript extends AIBehaviorScriptBase
{

	protected export virtual function Activate( context : ScriptExecutionContext ) {}

	protected export virtual function Deactivate( context : ScriptExecutionContext ) {}

	protected virtual function Check( context : ScriptExecutionContext ) : AIbehaviorConditionOutcomes
	{
		SetUpdateInterval( context, 999999.0 );
		return false;
	}

	protected virtual function CheckOnEvent( context : ScriptExecutionContext, behaviorEvent : AIEvent ) : AIbehaviorConditionOutcomes
	{
		return Check( context );
	}

	public import function ListenToSignal( context : ScriptExecutionContext, signalName : CName ) : Uint16;
	public import function StopListeningToSignal( context : ScriptExecutionContext, signalName : CName, callbackId : Uint16 );
	public import static function SetUpdateInterval( context : ScriptExecutionContext, interval : Float ) : Bool;
}

import class AIbehaviorexpressionScript extends AIBehaviorScriptBase
{
	public import function MarkDirty( context : ref< ScriptExecutionContext > );

	protected export virtual function OnBehaviorCallback( cbName : CName, context : ScriptExecutionContext ) : Bool
	{
		MarkDirty( context );
		return true;
	}

}

import class AIbehaviortaskScript extends AIBehaviorScriptBase
{

	protected export virtual function Activate( context : ScriptExecutionContext ) {}

	protected export virtual function Deactivate( context : ScriptExecutionContext ) {}

	protected export virtual function Update( context : ScriptExecutionContext ) : AIbehaviorUpdateOutcome
	{
		SetUpdateInterval( context, 999999.0 );
		return AIbehaviorUpdateOutcome.IN_PROGRESS;
	}

	protected export virtual function ChildCompleted( context : ScriptExecutionContext, status : AIbehaviorCompletionStatus ) {}
	public import static function CutSelector( context : ScriptExecutionContext );
	public import static function SetUpdateInterval( context : ScriptExecutionContext, interval : Float ) : Bool;
}

importonly struct ScriptExecutionContext
{
	public import static function GetOwner( context : ScriptExecutionContext ) : gamePuppet;
	public import static function GetAITime( context : ScriptExecutionContext ) : EngineTime;
	public import static function GetArgumentBool( context : ScriptExecutionContext, entry : CName ) : Bool;
	public import static function SetArgumentBool( context : ScriptExecutionContext, entry : CName, value : Bool );
	public import static function GetArgumentInt( context : ScriptExecutionContext, entry : CName ) : Int32;
	public import static function SetArgumentInt( context : ScriptExecutionContext, entry : CName, value : Int32 );
	public import static function GetArgumentUint64( context : ScriptExecutionContext, entry : CName ) : Uint64;
	public import static function SetArgumentUint64( context : ScriptExecutionContext, entry : CName, value : Uint64 );
	public import static function GetArgumentFloat( context : ScriptExecutionContext, entry : CName ) : Float;
	public import static function SetArgumentFloat( context : ScriptExecutionContext, entry : CName, value : Float );
	public import static function GetArgumentName( context : ScriptExecutionContext, entry : CName ) : CName;
	public import static function SetArgumentName( context : ScriptExecutionContext, entry : CName, value : CName );
	public import static function GetArgumentVector( context : ScriptExecutionContext, entry : CName ) : Vector4;
	public import static function SetArgumentVector( context : ScriptExecutionContext, entry : CName, value : Vector4 );
	public import static function GetArgumentObject( context : ScriptExecutionContext, entry : CName ) : weak< GameObject >;
	public import static function SetArgumentObject( context : ScriptExecutionContext, entry : CName, value : weak< GameObject > );
	public import static function GetArgumentScriptable( context : ScriptExecutionContext, entry : CName ) : weak< IScriptable >;
	public import static function SetArgumentScriptable( context : ScriptExecutionContext, entry : CName, value : weak< IScriptable > );
	public import static function GetArgumentNodeRef( context : ScriptExecutionContext, entry : CName ) : NodeRef;
	public import static function SetArgumentNodeRef( context : ScriptExecutionContext, entry : CName, value : NodeRef );
	public import static function GetArgumentGlobalNodeId( context : ScriptExecutionContext, entry : CName ) : GlobalNodeID;
	public import static function SetArgumentGlobalNodeId( context : ScriptExecutionContext, entry : CName, value : GlobalNodeID );
	public import static function GetMappingValue( context : ScriptExecutionContext, mapping : AIArgumentMapping ) : Variant;
	public import static function GetScriptableMappingValue( context : ScriptExecutionContext, mapping : AIArgumentMapping ) : IScriptable;
	public import static function GetTweakDBIDMappingValue( context : ref< ScriptExecutionContext >, mapping : AIArgumentMapping ) : TweakDBID;
	public import static function SetMappingValue( context : ScriptExecutionContext, mapping : AIArgumentMapping, value : Variant ) : Bool;
	public import static function SetEnumMappingValue( context : ScriptExecutionContext, mapping : AIArgumentMapping, value : Int64 ) : Bool;
	public import static function GetDelegate( context : ScriptExecutionContext ) : BehaviorDelegate;
	public import static function GetClosestDelegate( context : ScriptExecutionContext ) : BehaviorDelegate;
	public import static function CreateActionID( context : ScriptExecutionContext, actionStringName : String, actionPackageType : AIactionParamsPackageTypes ) : TweakDBID;
	public import static function CreateActionParamID( context : ScriptExecutionContext, actionStringName : String, paramName : String ) : TweakDBID;
	public import static function GetOverriddenNode( context : ref< ScriptExecutionContext >, nodeId : TweakDBID, out result : AIRecord_Record, lookupDefault : Bool ) : Bool;
	public import static function PuppetRefToObject( context : ScriptExecutionContext, puppetRef : EntityReference ) : GameObject;
	public import static function AddBehaviorCallback( context : ScriptExecutionContext, cbName : CName, callback : IScriptable ) : Uint32;
	public import static function RemoveBehaviorCallback( context : ScriptExecutionContext, id : Uint32 ) : Bool;
	public import static function InvokeBehaviorCallback( context : ref< ScriptExecutionContext >, cbName : CName );
	public import static function GetLOD( context : ref< ScriptExecutionContext > ) : Int32;
	public import static function GetTweakActionSystem( context : ref< ScriptExecutionContext > ) : AITweakActionSystem;
	public import static function DebugLog( context : ScriptExecutionContext, category : CName, message : String );
}

abstract class AIBehaviorScript extends IScriptable
{

	protected function GetPuppet( context : ScriptExecutionContext ) : ScriptedPuppet
	{
		return ( ( ScriptedPuppet )( ScriptExecutionContext.GetOwner( context ) ) );
	}

	protected function GetGame( context : ScriptExecutionContext ) : GameInstance
	{
		return ScriptExecutionContext.GetOwner( context ).GetGame();
	}

}

importonly struct CachedBoolValue
{
	public import static function SetDirty( cachedValue : ref< CachedBoolValue > );
	public import static function GetIfNotDirty( cachedValue : ref< CachedBoolValue >, out value : Bool ) : Bool;
	public import static function Set( cachedValue : ref< CachedBoolValue >, value : Bool );
}

import enum AIbehaviorConditionOutcomes
{
	True,
	False,
	Failure,
}

import enum AIbehaviorUpdateOutcome
{
	IN_PROGRESS,
	SUCCESS,
	FAILURE,
}

import enum AIbehaviorCompletionStatus
{
	FAILURE,
	SUCCESS,
}

implicit cast ( value : Bool ) : AIbehaviorConditionOutcomes
{
	if( value )
	{
		return AIbehaviorConditionOutcomes.True;
	}
	return AIbehaviorConditionOutcomes.False;
}

implicit cast ( value : AIbehaviorConditionOutcomes ) : Bool
{
	return value == AIbehaviorConditionOutcomes.True;
}

