importonly struct Tier3CameraSettings
{
	import var yawLeftLimit : Float;
	import var yawRightLimit : Float;
	import var pitchTopLimit : Float;
	import var pitchBottomLimit : Float;
	import var yawSpeedMultiplier : Float;
	import var pitchSpeedMultiplier : Float;
}

importonly abstract class SceneTierData extends IScriptable
{
	import const var tier : GameplayTier;
	import var emptyHands : Bool;
}

importonly class SceneTier1Data extends SceneTierData
{
}

importonly class SceneTier2Data extends SceneTierData
{
	import var walkType : Tier2WalkType;
}

importonly struct MotionConstrainedTierDataParams
{
	import var splineRef : NodeRef;
	import var adjustingSpeed : Float;
	import var adjustingDuration : Float;
	import var travellingSpeed : Float;
	import var travellingDuration : Float;
	import var notificationBackwardIndex : Int32;
}

importonly abstract class SceneTierDataMotionConstrained extends SceneTierData
{
	import var params : MotionConstrainedTierDataParams;
}

importonly class SceneTier3Data extends SceneTierDataMotionConstrained
{
	import var cameraSettings : Tier3CameraSettings;
}

importonly class SceneTier4Data extends SceneTierDataMotionConstrained
{
}

importonly class SceneTier5Data extends SceneTierDataMotionConstrained
{
}

import enum GameplayTier
{
	Undefined,
	Tier1_FullGameplay,
	Tier2_StagedGameplay,
	Tier3_LimitedGameplay,
	Tier4_FPPCinematic,
	Tier5_Cinematic,
}

import enum Tier2WalkType
{
	Undefined,
	Slow,
	Normal,
	Fast,
}

