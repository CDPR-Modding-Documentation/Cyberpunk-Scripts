importonly class AnimExternalEvent extends Event
{
	import var name : CName;
}

importonly class AnimInputSetter extends Event
{
	import var key : CName;
}

importonly class AnimInputSetterInt extends AnimInputSetter
{
	import var value : Int32;
}

importonly class AnimInputSetterFloat extends AnimInputSetter
{
	import var value : Float;
}

importonly class AnimInputSetterBool extends AnimInputSetter
{
	import var value : Bool;
}

importonly class AnimInputSetterVector extends AnimInputSetter
{
	import var value : Vector4;
}

importonly class AnimInputSetterAnimFeature extends AnimInputSetter
{
	import var value : AnimFeature;
	import var delay : Float;
}

importonly final class AnimFastForwardEvent extends Event
{
}

importonly class AnimInputSetterUsesSleepMode extends Event
{
	import var value : Bool;
}

importonly class AnimWrapperWeightSetter extends AnimInputSetter
{
	import var value : Float;
}

importonly final class RagdollRequestCollectAnimPoseEvent extends Event
{
}

importonly final class RagdollDisableEvent extends Event
{
	public import function DebugSetSourceName( debugSourceName : CName );
}

importonly final class RagdollNotifyEnabledEvent extends Event
{
	import var instigator : EntityID;
}

importonly final class RagdollNotifyDisabledEvent extends Event
{
}

importonly final class AnimatedRagdollNotifyEnabledEvent extends Event
{
	import var instigator : EntityID;
}

importonly final class AnimatedRagdollNotifyDisabledEvent extends Event
{
}

importonly final class RagdollNotifyVelocityTresholdEvent extends Event
{
	import var velocity : Vector4;
}

importonly final class RagdollPutToSleepEvent extends Event
{
}

importonly final class RagdollApplyImpulseEvent extends Event
{
	import var worldImpulsePos : Vector4;
	import var worldImpulseValue : Vector4;
	import var influenceRadius : Float;
}

import struct RagdollImpactPointData
{
	import var worldPosition : WorldPosition;
	import var worldNormal : Vector4;
	import var forceMagnitude : Float;
	import var impulseMagnitude : Float;
	import var ragdollProxyActorIndex : Uint32;
	import var maxForceMagnitude : Float;
	import var maxImpulseMagnitude : Float;
	import var velocityChange : Float;
}

importonly final class RagdollImpactEvent extends Event
{
	import var otherEntity : weak< Entity >;
	import var triggeredSimulation : Bool;
	import var impactPoints : array< RagdollImpactPointData >;
}

struct RagdollDamagePollData
{
	var worldPosition : WorldPosition;
	var worldNormal : Vector4;
	var maxForceMagnitude : Float;
	var maxImpulseMagnitude : Float;
	var maxVelocityChange : Float;
	var maxZDiff : Float;
}

importonly final struct RagdollActivationRequestData
{
	import var filterDataOverride : CName;
	import var type : entragdollActivationRequestType;
	import var applyPowerPose : Bool;
	import var applyMomentum : Bool;
}

importonly final class RagdollActivationRequestEvent extends Event
{
	import var data : RagdollActivationRequestData;

	public import function DebugSetSourceName( debugSourceName : CName );
}

importonly final class UncontrolledMovementStartEvent extends Event
{
	import var ragdollNoGroundThreshold : Float;
	import var ragdollOnCollision : Bool;
	import var calculateEarlyPositionGroundHeight : Bool;

	public import function DebugSetSourceName( debugSourceName : CName );
}

importonly final class UncontrolledMovementEndEvent extends Event
{
}

final class DisableRagdollComponentEvent extends Event
{
}

importonly final class RagdollBodyPartWaterImpactEvent extends Event
{
	import var worldPosition : Vector4;
	import var linearVelocity : Vector4;
	import var depthBelowSurface : Float;
	import var isTorso : Bool;
}

import enum entragdollActivationRequestType
{
	Default,
	Animated,
	Forced,
}

function CreateRagdollActivationRequestEvent( activationType : entragdollActivationRequestType, filterDataOverride : CName, applyPowerPose : Bool, applyMomentum : Bool, debugSourceName : CName ) : RagdollActivationRequestEvent
{
	var evt : RagdollActivationRequestEvent;
	evt = new RagdollActivationRequestEvent;
	evt.data.type = activationType;
	evt.data.applyPowerPose = applyPowerPose;
	evt.data.applyMomentum = applyMomentum;
	evt.data.filterDataOverride = filterDataOverride;
	evt.DebugSetSourceName( debugSourceName );
	return evt;
}

function CreateForceRagdollEvent( debugSourceName : CName ) : RagdollActivationRequestEvent
{
	return CreateRagdollActivationRequestEvent( entragdollActivationRequestType.Forced, '', true, true, debugSourceName );
}

function CreateForceRagdollWithCustomFilterDataEvent( customFilterData : CName, debugSourceName : CName ) : RagdollActivationRequestEvent
{
	return CreateRagdollActivationRequestEvent( entragdollActivationRequestType.Forced, customFilterData, true, true, debugSourceName );
}

function CreateForceRagdollNoPowerPoseEvent( debugSourceName : CName ) : RagdollActivationRequestEvent
{
	return CreateRagdollActivationRequestEvent( entragdollActivationRequestType.Forced, '', false, true, debugSourceName );
}

function CreateDisableRagdollEvent( debugSourceName : CName ) : RagdollDisableEvent
{
	var evt : RagdollDisableEvent;
	evt = new RagdollDisableEvent;
	evt.DebugSetSourceName( debugSourceName );
	return evt;
}

function CreateRagdollApplyImpulseEvent( worldPos : Vector4, imuplseVal : Vector4, influenceRadius : Float ) : RagdollApplyImpulseEvent
{
	var evt : RagdollApplyImpulseEvent;
	evt = new RagdollApplyImpulseEvent;
	evt.worldImpulsePos = worldPos;
	evt.worldImpulseValue = imuplseVal;
	evt.influenceRadius = influenceRadius;
	return evt;
}

