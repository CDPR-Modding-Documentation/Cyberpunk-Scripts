importonly final struct TS_TargetPartInfo
{
	public import static function GetComponent( self : TS_TargetPartInfo ) : weak< TargetingComponent >;
	public import static function GetPlayerAngleDistance( self : TS_TargetPartInfo ) : EulerAngles;
}

importonly final class ObjectLookedAtEvent extends Event
{
	import var ownerID : EntityID;
	import var state : Bool;
}

importonly final class LookAtObjectChangedEvent extends Event
{
	import var lookatObject : weak< GameObject >;
}

importonly abstract class ITargetingSystem extends IGameSystem
{
}

importonly struct TargetFilterTicket
{
}

importonly struct TargetHitInfo
{
	import const var queryMask : Uint64;
	import const var entityId : EntityID;
	import const var entity : weak< Entity >;
	import const var component : weak< IComponent >;
	import var aimStartPosition : Vector4;
	import var closestHitPosition : Vector4;
	import var isTransparent : Bool;

	public import static function IsValid( self : TargetHitInfo ) : Bool;
}

import class TargetFilterResult extends IScriptable
{
	import var hitEntId : EntityID;
	import var hitComponent : weak< IComponent >;

	public export virtual function OnReset() {}

	public virtual function OnClone( out cloneDestination : TargetFilterResult ) {}
}

importonly abstract class TargetFilter extends IScriptable
{
	public import function GetHitEntityID() : EntityID;
	public import function GetHitComponent() : weak< IComponent >;
}

import class TargetFilter_Script extends TargetFilter
{
	public import function GetFilterMask() : Uint64;
	public import function GetFilter() : QueryFilter;
	public import function SetFilter( queryFilter : QueryFilter );
	public import function TestFilterMask( mask : Uint64 ) : Bool;
	public import function GetResult( destination : TargetFilterResult );

	public virtual function PreFilter() {}

	public virtual function Filter( hitInfo : TargetHitInfo, workingState : TargetFilterResult ) {}

	public virtual function PostFilter() {}

	public virtual function CreateFilterResult() : TargetFilterResult
	{
		return NULL;
	}

}

importonly final abstract class TargetingSystem extends ITargetingSystem
{
	public import function GetTargetParts( instigator : weak< GameObject >, query : TargetSearchQuery, out parts : array< TS_TargetPartInfo > ) : Bool;
	public import function GetObjectClosestToCrosshair( instigator : weak< GameObject >, out angleDistance : EulerAngles, query : TargetSearchQuery ) : GameObject;
	public import function GetComponentClosestToCrosshair( instigator : weak< GameObject >, out angleDistance : EulerAngles, query : TargetSearchQuery ) : IPlacedComponent;
	public import function GetCrosshairData( instigator : weak< GameObject >, out crosshairPosition : Vector4, out crosshairForward : Vector4 );
	public import function GetDefaultCrosshairData( instigator : weak< GameObject >, out crosshairPosition : Vector4, out crosshairForward : Vector4 );
	public import function GetDefaultCrosshairPositionProvider( instigator : weak< GameObject >, optional offsetEntitySpace : Vector3 ) : IPositionProvider;
	public import function GetDefaultCrosshairOrientationProvider( instigator : weak< GameObject >, optional orientationEntitySpace : Quaternion ) : IOrientationProvider;
	public import function GetOrientationFromCrosshairToTargetOrientationProvider( instigator : weak< GameObject >, targetComponent : weak< IPlacedComponent >, optional orientationEntitySpace : Quaternion ) : IOrientationProvider;
	public import function GetLookAtObject( instigator : weak< GameObject >, optional withLOS : Bool, optional ignoreTranparent : Bool ) : GameObject;
	public import function GetLookAtComponent( instigator : weak< GameObject >, optional withLOS : Bool, optional ignoreTranparent : Bool ) : weak< IComponent >;
	public import function GetCurrentSpread( instigator : weak< GameObject > ) : Vector4;
	public import function GetPuppetBlackboardUpdater() : PuppetBlackboardUpdater;
	public import function AimSnap( instigator : weak< GameObject > );
	public import function LookAt( instigator : weak< GameObject >, out params : AimRequest );
	public import function BreakAimSnap( instigator : weak< GameObject > );
	public import function BreakLookAt( instigator : weak< GameObject > );
	public import function OnAimStartBegin( instigator : weak< GameObject > );
	public import function OnAimStartEnd( instigator : weak< GameObject > );
	public import function OnAimStop( instigator : weak< GameObject > );
	public import function SetAimAssistConfig( owner : weak< GameObject >, presetId : TweakDBID );
	public import function GetAimAssistConfig( owner : weak< GameObject > ) : TweakDBID;
	public import function ProcessLookAtFilter( instigator : weak< GameObject >, filter : TargetFilter );
	public import function RegisterLookAtFilter( instigator : weak< GameObject >, filter : TargetFilter ) : TargetFilterTicket;
	public import function UnregisterLookAtFilter( instigator : weak< GameObject >, filterTicket : TargetFilterTicket );
	public import function AddIgnoredLookAtEntity( instigator : weak< GameObject >, ignoredEntityId : EntityID );
	public import function RemoveIgnoredLookAtEntity( instigator : weak< GameObject >, ignoredEntityId : EntityID );
	public import function AddIgnoredCollisionEntities( entity : weak< GameObject > );
	public import function RemoveIgnoredCollisionEntities( entity : weak< GameObject > );
	public import function SetIsMovingFast( instigator : weak< GameObject >, isFast : Bool );
	public import function IsVisibleTarget( instigator : weak< GameObject >, target : weak< GameObject > ) : Bool;
	public import function GetTargetingSet( instigator, object : weak< GameObject > ) : TargetingSet;
	public import function GetBestComponentOnTargetObject( shootStartPosition : Vector4, shootStartForward : Vector4, target : weak< GameObject >, componentFilter : TargetComponentFilterType ) : weak< TargetingComponent >;
	public import function IsAnyEnemyVisible( instigator : weak< GameObject >, optional distance : Float ) : Bool;
	public import function IsAnyEnemyOrSensorVisible( instigator : weak< GameObject >, optional distance : Float ) : Bool;
}

importonly final class TargetingComponent extends IPlacedComponent
{
	public import function IsAimAssistEnabled() : Bool;
}

importonly final class DisableAimAssist extends Event
{
}

importonly final class EnableAimAssist extends Event
{
}

importonly final class AndroidTurnOn extends Event
{
}

importonly final class AndroidTurnOff extends Event
{
}

importonly final class SetQuickHackableMask extends Event
{
	import var isQuickHackable : Bool;
}

importonly final class SetAggressiveMask extends Event
{
}

import enum gametargetingSystemETargetFilterStatus
{
	Stop,
	Continue,
}

