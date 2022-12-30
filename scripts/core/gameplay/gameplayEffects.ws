importonly abstract class EffectNode extends IScriptable
{
}

importonly abstract class EffectExecutor extends EffectNode
{
}

import class EffectExecutor_Scripted extends EffectExecutor
{
}

importonly abstract class EffectDurationModifier extends IScriptable
{
}

import class EffectDurationModifier_Scripted extends EffectDurationModifier
{
}

abstract class EffectDataHelper
{

	public static function FillMeleeEffectData( effectData : EffectData, colliderBoxSize : Vector4, duration : Float, position : Vector4, rotation : Quaternion, direction : Vector4, range : Float )
	{
		EffectData.SetVector( effectData, GetAllBlackboardDefs().EffectSharedData.box, colliderBoxSize );
		EffectData.SetFloat( effectData, GetAllBlackboardDefs().EffectSharedData.duration, duration );
		EffectData.SetVector( effectData, GetAllBlackboardDefs().EffectSharedData.position, position );
		EffectData.SetQuat( effectData, GetAllBlackboardDefs().EffectSharedData.rotation, rotation );
		EffectData.SetVector( effectData, GetAllBlackboardDefs().EffectSharedData.forward, direction );
		EffectData.SetFloat( effectData, GetAllBlackboardDefs().EffectSharedData.range, range );
		EffectData.SetFloat( effectData, GetAllBlackboardDefs().EffectSharedData.radius, range );
	}

}

importonly struct EffectRef
{
}

importonly abstract class IEffect extends IScriptable
{
}

importonly final class EffectInstance extends IEffect
{
	public import final function Run() : Bool;
	public import final function AttachToEntity( entity : weak< Entity >, positionParameter : BlackboardID_Vector4, optional offset : Vector4 );
	public import final function AttachToSlot( entity : weak< Entity >, slotName : CName, positionParameter : BlackboardID_Vector4, directionParameter : BlackboardID_Vector4 );
	public import final function Terminate();
	public import final function IsFinished() : Bool;
	public import final function GetSharedData() : EffectData;
	public import static function GetBlackboard() : IBlackboard;
	public import final function GetLastError() : String;
	public import final function GetExecutionInfo();
	public import final function RegisterCallbackEntity( entity : weak< Entity >, tag : String );
}

importonly abstract class IEffectSystem extends IGameSystem
{
}

importonly final class EffectSystem extends IEffectSystem
{
	public import final function CreateEffect( definition : EffectRef, instigator : Entity, optional weapon : Entity ) : EffectInstance;
	public import final function HasEffect( effectName : CName, effectTag : CName ) : Bool;
	public import final function CreateEffectStatic( effectName : CName, effectTag : CName, instigator : Entity, optional weapon : Entity ) : EffectInstance;
	public import final function PreloadStaticEffectResources( effectName : CName, effectTag : CName );
	public import final function ReleaseStaticEffectResources( effectName : CName, effectTag : CName );
}

importonly struct EffectData
{
	public import static function SetBool( ctx : EffectData, id : BlackboardID_Bool, value : Bool ) : Bool;
	public import static function SetInt( ctx : EffectData, id : BlackboardID_Int, value : Int32 ) : Bool;
	public import static function SetFloat( ctx : EffectData, id : BlackboardID_Float, value : Float ) : Bool;
	public import static function SetName( ctx : EffectData, id : BlackboardID_Name, value : CName ) : Bool;
	public import static function SetString( ctx : EffectData, id : BlackboardID_String, value : String ) : Bool;
	public import static function SetVector( ctx : EffectData, id : BlackboardID_Vector4, value : Vector4 ) : Bool;
	public import static function SetEulerAngles( ctx : EffectData, id : BlackboardID_EulerAngles, value : EulerAngles ) : Bool;
	public import static function SetQuat( ctx : EffectData, id : BlackboardID_Quat, value : Quaternion ) : Bool;
	public import static function SetEntity( ctx : EffectData, id : BlackboardID_Entity, value : weak< Entity > ) : Bool;
	public import static function SetVariant( ctx : EffectData, id : BlackboardID_Variant, value : Variant ) : Bool;
	public import static function GetBool( ctx : EffectData, id : BlackboardID_Bool, out value : Bool ) : Bool;
	public import static function GetInt( ctx : EffectData, id : BlackboardID_Int, out value : Int32 ) : Bool;
	public import static function GetFloat( ctx : EffectData, id : BlackboardID_Float, out value : Float ) : Bool;
	public import static function GetName( ctx : EffectData, id : BlackboardID_Name, out value : CName ) : Bool;
	public import static function GetString( ctx : EffectData, id : BlackboardID_String, out value : String ) : Bool;
	public import static function GetVector( ctx : EffectData, id : BlackboardID_Vector4, out value : Vector4 ) : Bool;
	public import static function GetEulerAngles( ctx : EffectData, id : BlackboardID_EulerAngles, out value : EulerAngles ) : Bool;
	public import static function GetQuat( ctx : EffectData, id : BlackboardID_Quat, out value : Quaternion ) : Bool;
	public import static function GetEntity( ctx : EffectData, id : BlackboardID_Entity, out value : weak< Entity > ) : Bool;
	public import static function GetVariant( ctx : EffectData, id : BlackboardID_Variant, out value : Variant ) : Bool;
}

importonly struct EffectScriptContext
{
	public import static function GetGameInstance( ctx : EffectScriptContext ) : GameInstance;
	public import static function ReportError( ctx : EffectScriptContext, error : String );
	public import static function GetSharedData( ctx : EffectScriptContext ) : EffectData;
	public import static function GetBlackboard( ctx : EffectScriptContext ) : IBlackboard;
	public import static function GetInstigator( ctx : EffectScriptContext ) : Entity;
	public import static function GetSource( ctx : EffectScriptContext ) : Entity;
	public import static function GetWeapon( ctx : EffectScriptContext ) : Entity;
	public import static function SpawnEffect( ctx : EffectScriptContext, resource : FxResource, transform : WorldTransform, optional ignoreTimeDilation : Bool );
}

importonly struct EffectProviderScriptContext
{
	public import static function GetTimeDelta( providerCtx : EffectProviderScriptContext ) : Float;
	public import static function AddTarget( ctx : EffectScriptContext, providerCtx : EffectProviderScriptContext, optional target : Entity );
}

importonly struct EffectSingleFilterScriptContext
{
	public import static function GetTimeDelta( filterCtx : EffectSingleFilterScriptContext ) : Float;
	public import static function GetEntity( filterCtx : EffectSingleFilterScriptContext ) : Entity;
	public import static function GetHitPosition( filterCtx : EffectSingleFilterScriptContext ) : Vector4;
	public import static function GetHitNormal( filterCtx : EffectSingleFilterScriptContext ) : Vector4;
}

importonly struct EffectGroupFilterScriptContext
{
	import var resultIndices : array< Int32 >;

	public import static function GetTimeDelta( filterCtx : EffectGroupFilterScriptContext ) : Float;
	public import static function GetNumAgents( filterCtx : EffectGroupFilterScriptContext ) : Int32;
	public import static function GetEntity( filterCtx : EffectGroupFilterScriptContext, index : Int32 ) : Entity;
	public import static function GetHitPosition( filterCtx : EffectGroupFilterScriptContext, index : Int32 ) : Vector4;
	public import static function GetHitNormal( filterCtx : EffectGroupFilterScriptContext, index : Int32 ) : Vector4;
}

importonly struct EffectExecutionScriptContext
{
	public import static function GetTimeDelta( applierCtx : EffectExecutionScriptContext ) : Float;
	public import static function GetTarget( applierCtx : EffectExecutionScriptContext ) : Entity;
	public import static function GetTargetNode( applierCtx : EffectExecutionScriptContext ) : GlobalNodeID;
	public import static function GetHitPosition( applierCtx : EffectExecutionScriptContext ) : Vector4;
	public import static function GetHitNormal( applierCtx : EffectExecutionScriptContext ) : Vector4;
	public import static function GetHitThroughTechSurface( applierCtx : EffectExecutionScriptContext ) : Bool;
	public import static function GetHitThroughWaterSurface( applierCtx : EffectExecutionScriptContext ) : Bool;
	public import static function IsTargetWater( applierCtx : EffectExecutionScriptContext ) : Bool;
}

importonly struct EffectDurationModifierScriptContext
{
	public import static function GetTimeDelta( modifierCtx : EffectDurationModifierScriptContext ) : Float;
	public import static function GetRemainingTime( modifierCtx : EffectDurationModifierScriptContext ) : Float;
	public import static function SetRemainingTime( modifierCtx : EffectDurationModifierScriptContext, time : Float );
}

importonly struct EffectPreloadScriptContext
{
	public import static function PreloadFxResource( ctx : EffectPreloadScriptContext, resource : FxResource );
}

importonly abstract class EffectObjectProvider extends EffectNode
{
}

importonly abstract class EffectObjectFilter extends EffectNode
{
}

importonly abstract class EffectObjectSingleFilter extends EffectObjectFilter
{
}

importonly abstract class EffectObjectGroupFilter extends EffectObjectFilter
{
}

importonly abstract class EffectAction extends IScriptable
{
}

importonly abstract class EffectPreAction extends EffectAction
{
}

importonly abstract class EffectPostAction extends EffectAction
{
}

importonly abstract class gameEffectObjectFilter extends EffectNode
{
}

importonly abstract class gameEffectObjectGroupFilter extends gameEffectObjectFilter
{
}

importonly class gameEffectObjectFilter_OnlyNearest extends gameEffectObjectGroupFilter
{
}

import class EffectObjectProvider_Scripted extends EffectObjectProvider
{
}

import class EffectObjectSingleFilter_Scripted extends EffectObjectSingleFilter
{
}

import class EffectObjectGroupFilter_Scripted extends EffectObjectGroupFilter
{
}

import class EffectPreAction_Scripted extends EffectPreAction
{
}

import class EffectPostAction_Scripted extends EffectPostAction
{
}

importonly struct EffectInputParameter_Bool
{
	public import static function Get( ctx : EffectInputParameter_Bool, bb : IBlackboard ) : Bool;
}

importonly struct EffectInputParameter_Int
{
	public import static function Get( ctx : EffectInputParameter_Int, bb : IBlackboard ) : Int32;
}

importonly struct EffectInputParameter_Float
{
	public import static function Get( ctx : EffectInputParameter_Float, bb : IBlackboard ) : Float;
}

importonly struct EffectInputParameter_CName
{
	public import static function Get( ctx : EffectInputParameter_CName, bb : IBlackboard ) : CName;
}

importonly struct EffectInputParameter_String
{
	public import static function Get( ctx : EffectInputParameter_String, bb : IBlackboard ) : String;
}

importonly struct EffectInputParameter_Vector
{
	public import static function Get( ctx : EffectInputParameter_Vector, bb : IBlackboard ) : Vector4;
}

importonly struct EffectInputParameter_Quat
{
	public import static function Get( ctx : EffectInputParameter_Quat, bb : IBlackboard ) : Quaternion;
}

importonly struct EffectInputParameter_Variant
{
	public import static function Get( ctx : EffectInputParameter_Variant, bb : IBlackboard ) : Variant;
}

importonly struct EffectOutputParameter_Bool
{
	public import static function Set( ctx : EffectOutputParameter_Bool, bb : IBlackboard, value : Bool );
}

importonly struct EffectOutputParameter_Int
{
	public import static function Set( ctx : EffectOutputParameter_Int, bb : IBlackboard, value : Int32 );
}

importonly struct EffectOutputParameter_Float
{
	public import static function Set( ctx : EffectOutputParameter_Float, bb : IBlackboard, value : Float );
}

importonly struct EffectOutputParameter_CName
{
	public import static function Set( ctx : EffectOutputParameter_CName, bb : IBlackboard, value : CName );
}

importonly struct EffectOutputParameter_String
{
	public import static function Set( ctx : EffectOutputParameter_String, bb : IBlackboard, value : String );
}

importonly struct EffectOutputParameter_Vector
{
	public import static function Set( ctx : EffectOutputParameter_Vector, bb : IBlackboard, value : Vector4 );
}

importonly struct EffectOutputParameter_Quat
{
	public import static function Set( ctx : EffectOutputParameter_Quat, bb : IBlackboard, value : Quaternion );
}

importonly struct EffectOutputParameter_Variant
{
	public import static function Set( ctx : EffectOutputParameter_Variant, bb : IBlackboard, value : Variant );
}

importonly struct EffectInfo
{
	public import static function GetGatheredCount( info : EffectInfo ) : Int32;
	public import static function GetFilteredCount( info : EffectInfo ) : Int32;
	public import static function GetProcessedCount( info : EffectInfo ) : Int32;
}

importonly final class EffectInfoEvent extends Event
{
	import var tag : String;
	import var entitiesGathered : Uint32;
	import var entitiesFiltered : Uint32;
	import var entitiesProcessed : Uint32;
}

exec function SpawnTestEffect( gameInstance : GameInstance )
{
	var effect : EffectInstance;
	var pos : Vector4;
	pos.X = 0.0;
	pos.Y = 0.0;
	pos.Z = 0.0;
	effect = GameInstance.GetGameEffectSystem( gameInstance ).CreateEffectStatic( 'test_effect', 'explosion', GetPlayer( gameInstance ) );
	EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, pos );
	effect.Run();
}

