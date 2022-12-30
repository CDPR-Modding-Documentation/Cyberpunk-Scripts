import abstract class gameprojectileTrajectoryParams extends IScriptable
{
}

importonly class ParabolicTrajectoryParams extends gameprojectileTrajectoryParams
{
	public import static function GetAccelTargetAngleParabolicParams( accel : Vector4, target : Vector4, angle : Float, optional zVelocityClamp : Float ) : ParabolicTrajectoryParams;
	public import static function GetAccelVelParabolicParams( accel : Vector4, vel : Float, optional zVelocityClamp : Float ) : ParabolicTrajectoryParams;
	public import static function GetVelTargetParabolicParams( target : Vector4, vel : Float, optional zVelocityClamp : Float ) : ParabolicTrajectoryParams;
}

importonly class FollowTrajectoryParams extends gameprojectileTrajectoryParams
{
	import editable var startVel : Float;
	import editable var target : weak< GameObject >;
	import editable var targetComponent : weak< IPlacedComponent >;
	import editable var accuracy : Float;
	import editable var targetOffset : Vector4;
}

importonly class SpiralControllerParams extends IScriptable
{
	import editable var enabled : Bool;
	import editable var radius : Float;
	import editable var cycleTimeMin : Float;
	import editable var cycleTimeMax : Float;
	import editable var rampUpDistanceStart : Float;
	import editable var rampUpDistanceEnd : Float;
	import editable var rampDownDistanceStart : Float;
	import editable var rampDownDistanceEnd : Float;
	import editable var rampDownFactor : Float;
	import editable var randomizePhase : Bool;
	import editable var randomizeDirection : Bool;
}

importonly class FollowCurveTrajectoryParams extends gameprojectileTrajectoryParams
{
	import editable var target : weak< GameObject >;
	import editable var componentName : CName;
	import editable var targetComponent : weak< IPlacedComponent >;
	import editable var targetPosition : Vector4;
	import editable var startVelocity : Float;
	import editable var linearTimeRatio : Float;
	import editable var interpolationTimeRatio : Float;
	import editable var returnTimeMargin : Float;
	import editable var bendTimeRatio : Float;
	import editable var bendFactor : Float;
	import editable var angleInHitPlane : Float;
	import editable var angleInVerticalPlane : Float;
	import editable var shouldRotate : Bool;
	import editable var halfLeanAngle : Float;
	import editable var endLeanAngle : Float;
	import editable var angleInterpolationDuration : Float;
	import editable var snapRadius : Float;
	import editable var accuracy : Float;
	import editable var offset : Vector4;
	import editable var offsetInPlane : Vector3;
	import editable var sendFollowEvent : Bool;
}

importonly class AccelerateTowardsTrajectoryParams extends gameprojectileTrajectoryParams
{
	import editable var accelerationSpeed : Float;
	import editable var maxSpeed : Float;
	import editable var decelerateTowardsTargetPositionDistance : Float;
	import editable var maxRotationSpeed : Float;
	import editable var minRotationSpeed : Float;
	import editable var diffForMaxRotation : Float;
	import editable var target : weak< GameObject >;
	import editable var targetComponent : weak< IPlacedComponent >;
	import editable var targetPosition : Vector4;
	import editable var targetOffset : Vector4;
	import editable var accuracy : Float;
}

importonly class LinearTrajectoryParams extends gameprojectileTrajectoryParams
{
	import editable var startVel : Float;
	import editable var acceleration : Float;
}

importonly class SlideTrajectoryParams extends gameprojectileTrajectoryParams
{
	import editable var stickiness : Float;
	import editable var constAccel : Vector4;
}

importonly class CollisionEvaluatorParams extends IScriptable
{
	import var target : weak< GameObject >;
	import var isPiercableSurface : Bool;
	import var isWaterSurface : Bool;
	import var angle : Float;
	import var numBounces : Uint32;
	import var position : Vector4;
	import var projectilePenetration : CName;
	import var isTechPiercing : Bool;
}

importonly class gameprojectileCollisionEvaluator extends IScriptable
{
}

import class gameprojectileScriptCollisionEvaluator extends gameprojectileCollisionEvaluator
{

	protected virtual function EvaluateCollision( defaultOnCollisionAction : gameprojectileOnCollisionAction, params : CollisionEvaluatorParams ) : gameprojectileOnCollisionAction
	{
		return defaultOnCollisionAction;
	}

}

importonly class ProjectileSpawnComponent extends IPlacedComponent
{
	public import function Spawn( templateID : Uint32 );
}

importonly class ProjectileComponent extends IPlacedComponent
{
	public import function AddParabolic( params : ParabolicTrajectoryParams );
	public import function AddFollow( params : FollowTrajectoryParams );
	public import function AddFollowCurve( params : FollowCurveTrajectoryParams );
	public import function AddAccelerateTowards( params : AccelerateTowardsTrajectoryParams );
	public import function AddLinear( params : LinearTrajectoryParams );
	public import function Slide( params : SlideTrajectoryParams );
	public import function SetEnergyLossFactor( energyLossFactor : Float, puppetEnergyLossFactor : Float );
	public import function GetPrintVelocity() : Vector4;
	public import function SetWasTrajectoryStopped( wasStopped : Bool );
	public import function AddIgnoredEntity( entityID : EntityID );
	public import function RemoveIgnoredEntity( entityID : EntityID );
	public import function ClearIgnoredEntities();
	public import function SetExplosionVisualRadius( explosionRadius : Float );
	public import function ClearTrajectories();
	public import function IsTrajectoryEmpty() : Bool;
	public import function SetDesiredTransform( transform : Transform );
	public import function SetOnCollisionAction( action : gameprojectileOnCollisionAction );
	public import function GetGameEffectInstance() : EffectInstance;
	public import function SpawnTrailVFX();
	public import function GetTrailVFXName() : CName;
	public import function ToggleAxisRotation( enabled : Bool );
	public import function AddAxisRotation( axis : Vector4, value : Float );
	public import function SetCollisionEvaluator( collisionEvaluator : gameprojectileScriptCollisionEvaluator );
	public import function LogDebugVariable( key : CName, value : String );
	public import function LockOrientation( enable : Bool );
	public import function SetSpiral( params : SpiralControllerParams );
	public import function SetDeactivationDepth( depth : Float );
	public import function SetCollisionCooldown( cooldown : Float );
}

import enum gameprojectileOnCollisionAction
{
	None,
	Stop,
	Bounce,
	StopAndStick,
	StopAndStickPerpendicular,
	Pierce,
}

