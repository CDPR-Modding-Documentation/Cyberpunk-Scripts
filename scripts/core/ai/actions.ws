import abstract class CActionScriptProxy extends IScriptable
{
	public import function Bind( go : GameObject );
	public import function Launch();
	public import function Stop();
	public import function GetStatus() : gameEActionStatus;
}

import class ActionSlideToScriptProxy extends CActionScriptProxy
{
	public import function SetupWorldPosition( worldPosition : Vector4, optional duration : Float, optional ignoreNavigation : Bool, optional rotateTowardsMovementDirection : Bool ) : Bool;
	public import function SetupPosition( localPosition : Vector4, optional duration : Float, optional ignoreNavigation : Bool, optional rotateTowardsMovementDirection : Bool ) : Bool;
	public import function SetupObject( gameObject : GameObject, optional duration : Float, optional ignoreNavigation : Bool, optional rotateTowardsMovementDirection : Bool ) : Bool;
}

import class ActionHitReactionScriptProxy extends CActionScriptProxy
{
	public import function Setup( hitReactionsData : AnimFeature_HitReactionsData, optional fastForward : Bool ) : Bool;
}

import class ActionDodgeScriptProxy extends CActionScriptProxy
{
	public import function Setup( DodgeData : AnimFeature_DodgeData ) : Bool;
}

import class ActionTeleportScriptProxy extends CActionScriptProxy
{
	public import function Setup( targetPosition : Vector4, rotation : Float, doNavTest : Bool ) : Bool;
}

import struct ActionAnimationSlideParams
{
	import var distance : Float;
	import var duration : Float;
	import var positionSpeed : Float;
	import var rotationSpeed : Float;
	import var maxSlidePositionDistance : Float;
	import var maxSlideRotationAngle : Float;
	import var slideStartDelay : Float;
	import var usePositionSlide : Bool;
	import var useRotationSlide : Bool;
	import var slideToTarget : Bool;
	import var zAlignmentThreshold : Float;
	import var offsetToTarget : Float;
	import var offsetAroundTarget : Float;
	import var maxTargetVelocity : Float;
	import var directionAngle : Float;
	import var finalRotationAngle : Float;
}

import class ActionAnimationScriptProxy extends CActionScriptProxy
{
	public import function Setup( animFeatureName : CName, animFeature : AnimFeature_AIAction, useRootMotion : Bool, usePoseMatching : Bool, resetRagdollOnStart : Bool, motionDynamicObjectsCheck : Bool, updadeMovePolicy : Bool, slideParams : ActionAnimationSlideParams, targetObject : weak< GameObject >, marginToPlayer : Float, optional tagetPositionProvider : IPositionProvider ) : Bool;
	public import function ForceLaunch( animFeatureName : CName, animFeature : AnimFeature_AIAction, useRootMotion : Bool, usePoseMatching : Bool, resetRagdollOnStart : Bool, motionDynamicObjectsCheck : Bool, slideParams : ActionAnimationSlideParams, targetObject : weak< GameObject >, marginToPlayer : Float, optional tagetPositionProvider : IPositionProvider );
	public import function Terminate();
	public import function GetPhaseDuration( animFeatureName : CName, animFeature : AnimFeature_AIAction ) : Float;
}

import enum moveMovementType
{
	Walk,
	Run,
	Sprint,
}

import enum gameEActionStatus
{
	STATUS_INVALID,
	STATUS_BOUND,
	STATUS_READY,
	STATUS_PROGRESS,
	STATUS_COMPLETE,
	STATUS_FAILURE,
}

import enum AIEExecutionOutcome
{
	OUTCOME_FAILURE,
	OUTCOME_SUCCESS,
	OUTCOME_IN_PROGRESS,
}

import enum AIEInterruptionOutcome
{
	INTERRUPTION_SUCCESS,
	INTERRUPTION_DELAYED,
	INTERRUPTION_FAILED,
}

function GetActionAnimationSlideParams( slideRecord : AIActionSlideData_Record ) : ActionAnimationSlideParams
{
	var resultParams : ActionAnimationSlideParams;
	resultParams.distance = slideRecord.Distance();
	resultParams.directionAngle = slideRecord.DirectionAngle();
	resultParams.finalRotationAngle = slideRecord.FinalRotationAngle();
	resultParams.offsetToTarget = slideRecord.OffsetToTarget();
	resultParams.offsetAroundTarget = slideRecord.OffsetAroundTarget();
	resultParams.slideToTarget = slideRecord.Target();
	resultParams.duration = slideRecord.Duration();
	resultParams.positionSpeed = slideRecord.PositionSpeed();
	resultParams.rotationSpeed = slideRecord.RotationSpeed();
	resultParams.slideStartDelay = slideRecord.SlideStartDelay();
	resultParams.usePositionSlide = slideRecord.UsePositionSlide();
	resultParams.useRotationSlide = slideRecord.UseRotationSlide();
	resultParams.maxSlidePositionDistance = slideRecord.Distance();
	resultParams.zAlignmentThreshold = slideRecord.ZAlignmentCollisionThreshold();
	resultParams.maxTargetVelocity = 0.0;
	resultParams.maxSlideRotationAngle = 135.0;
	return resultParams;
}

