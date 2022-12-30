importonly struct gameRicochetData
{
	import var count : Int32;
	import var range : Float;
	import var targetSearchAngle : Float;
	import var minAngle : Float;
	import var maxAngle : Float;
	import var chance : Float;
}

importonly struct gameprojectileWeaponParams
{
	import var targetPosition : Vector4;
	import var smartGunSpreadOnHitPlane : Vector3;
	import var charge : Float;
	import var trackedTargetComponent : weak< IPlacedComponent >;
	import var smartGunAccuracy : Float;
	import var smartGunIsProjectileGuided : Bool;
	import var hitPlaneOffset : Vector4;
	import var shootingOffset : Float;
	import var ignoreWeaponOwnerCollision : Bool;
	import var ricochetData : gameRicochetData;
	import var range : Float;

	public import static function AddObjectToIgnoreCollisionWith( self : gameprojectileWeaponParams, entityID : EntityID );
}

importonly struct gameprojectileLaunchParams
{
	import var launchMode : gameprojectileELaunchMode;
	import var logicalPositionProvider : IPositionProvider;
	import var logicalOrientationProvider : IOrientationProvider;
	import var visualPositionProvider : IPositionProvider;
	import var visualOrientationProvider : IOrientationProvider;
	import var ownerVelocityProvider : IVelocityProvider;
}

importonly class gameprojectileSpawnerPreviewEvent extends Event
{
	import var previewActive : Bool;
}

importonly class gameprojectileProjectilePreviewEvent extends gameprojectileSpawnerPreviewEvent
{
	import var visualOffset : Transform;
}

importonly class gameprojectileLaunchEvent extends Event
{
	import var launchParams : gameprojectileLaunchParams;
	import var owner : weak< GameObject >;
	import var projectileParams : gameprojectileWeaponParams;
}

importonly class gameprojectileSetUpEvent extends Event
{
	import var weapon : weak< GameObject >;
	import var owner : weak< GameObject >;
	import var trajectoryParams : gameprojectileTrajectoryParams;
	import var lerpMultiplier : Float;
}

importonly class gameprojectileSetUpAndLaunchEvent extends gameprojectileLaunchEvent
{
	import var trajectoryParams : gameprojectileTrajectoryParams;
	import var lerpMultiplier : Float;
}

importonly class gameprojectileShootEvent extends gameprojectileSetUpEvent
{
	import var localToWorld : Matrix;
	import var startPoint : Vector4;
	import var startVelocity : Vector4;
	import var weaponVelocity : Vector4;
	import var params : gameprojectileWeaponParams;
}

importonly final class gameprojectileShootTargetEvent extends gameprojectileShootEvent
{
}

importonly final class gameprojectileTickEvent extends Event
{
	import var deltaTime : Float;
	import var position : Vector4;
}

importonly struct gameprojectileHitInstance
{
	import var traceResult : TraceResult;
	import var position : Vector4;
	import var projectilePosition : Vector4;
	import var projectileSourcePosition : Vector4;
	import var forward : Vector4;
	import var velocity : Vector4;
	import var hitObject : weak< Entity >;
	import var hitWeakspot : weak< WeakspotObject >;
	import var hitRepresentationResult : HitRepresentationQueryResult;
	import var numRicochetBounces : Int32;
	import var isWaterSurfaceImpact : Bool;
	import var hitThroughWaterSurface : Bool;
}

importonly final class gameprojectileHitEvent extends Event
{
	import var hitInstances : array< gameprojectileHitInstance >;
}

importonly final class gameprojectileBroadPhaseHitEvent extends Event
{
	import var traceResult : TraceResult;
	import var position : Vector4;
	import var hitObject : weak< Entity >;
	import var hitComponent : weak< IComponent >;
}

importonly final class gameprojectileFollowEvent extends Event
{
	import var followObject : weak< GameObject >;
}

importonly class gameprojectileLinearMovementEvent extends Event
{
	import var targetPosition : Vector4;
}

importonly final class gameprojectileAcceleratedMovementEvent extends gameprojectileLinearMovementEvent
{
}

importonly final class gameprojectileSpawnerLaunchEvent extends Event
{
	import var launchParams : gameprojectileLaunchParams;
	import var templateName : CName;
	import var appearance : CName;
	import var owner : weak< GameObject >;
	import var projectileParams : gameprojectileWeaponParams;
}

importonly final class gameprojectileForceActivationEvent extends Event
{
}

class ThrowingKnifePickupEvent extends Event
{
	var throwCooldownSE : TweakDBID;
}

import enum gameprojectileELaunchMode
{
	Default,
	FromLogic,
	FromVisuals,
}

