import class AnimFeature extends IScriptable
{
}

import class AnimFeatureMarkUnstable extends AnimFeature
{
}

import class AnimFeature_WeaponData extends AnimFeature
{
	public import function SetCycleTime( cycleTime : Float );
	public import function SetChargePercentage( chargePercentage : Float );
	public import function SetTimeInMaxCharge( timeInMaxCharge : Float );
	public import function SetAmmoRemaining( ammoRemaining : Int32 );
	public import function SetTriggerMode( triggerMode : gamedataTriggerMode );
	public import function SetMagazineFull( magazineFull : Bool );
	public import function SetTriggerDown( triggerDown : Bool );
}

import class AnimFeature_NPCState extends AnimFeature
{
	import editable var state : Int32;
}

import class AnimFeature_NPCCoverStanceState extends AnimFeature_NPCState
{
}

import class AnimFeature_AIAction extends AnimFeature
{
	import editable var state : Int32;
	import editable var stateDuration : Float;
	import editable var animVariation : Int32;
	editable var direction : Float;
}

import class AnimFeature_CoverAction extends AnimFeature_AIAction
{
	import editable var coverStance : Int32;
	import editable var coverActionType : Int32;
	import editable var coverShootType : Int32;
	import editable var movementType : Int32;
}

import class AnimFeature_ExitCover extends AnimFeature_AIAction
{
	import editable var coverStance : Int32;
	import editable var coverExitDirection : Int32;
}

class AnimFeature_EquipType extends AnimFeature
{
	editable var firstEquip : Bool;
	editable var equipDuration : Float;
	editable var unequipDuration : Float;
}

import class AnimFeature_LoopableAction extends AnimFeature
{
	public import function SetLoopDuration( loopDuration : Float );
	public import function SetNumLoops( numLoops : Int32 );
	public import function SetActive( isActive : Bool );
}

import class AnimFeature_BasicAim extends AnimFeature
{
	public import function SetAimState( aimState : animAimState );
	public import function SetZoomState( zoomState : animAimState );
}

import class AnimFeature_Aim extends AnimFeature_BasicAim
{
	public import function Aim( aimPoint : Vector4 );
}

import class AnimFeature_AimPlayer extends AnimFeature_BasicAim
{
	public import function SetZoomLevel( zoomLevel : Float );
	public import function SetAimInTime( aimInTime : Float );
	public import function SetAimOutTime( aimOutTime : Float );
}

import class AnimFeature_Zoom extends AnimFeature
{
	import var finalZoomLevel : Float;
	import var weaponZoomLevel : Float;
	import var weaponAimFOV : Float;
	import var worldFOV : Float;
	editable var weaponScopeFov : Float;
	import var zoomLevelNum : Int32;
	import var noWeaponAimInTime : Float;
	import var noWeaponAimOutTime : Float;
	import var shouldUseWeaponZoomStats : Bool;
	import var focusModeActive : Bool;
}

import class AnimFeature_Stance extends AnimFeature
{
	public import function SetStanceState( stanceState : animStanceState );
}

import class AnimFeature_HitReactionsData extends AnimFeature
{
	import var hitDirection : Int32;
	import var hitIntensity : Int32;
	import var hitType : Int32;
	import var hitBodyPart : Int32;
	import var npcMovementSpeed : Int32;
	import var npcMovementDirection : Int32;
	import var stance : Int32;
	import var animVariation : Int32;
	import var hitSource : Int32;
	import var useInitialRotation : Bool;
	import var hitDirectionWs : Vector4;
	import var angleToAttack : Float;
	import var initialRotationDuration : Float;
}

import class AnimFeature_MoveTo extends AnimFeature
{
	public import function MoveTo( targetPosition : Vector4, targetYawRotation : Float, timeToMove : Float );
	public import function MoveToWithDir( targetPosition : Vector4, targetYawRotation : Vector4, timeToMove : Float );
}

import class AnimFeature_Movement extends AnimFeature
{
	public import function SetSpeed( speed : Float );
}

import class AnimFeature_PlayerMovement extends AnimFeature_Movement
{
	public import function SetVerticalSpeed( verticalSpeed : Float );
	public import function SetFacingDirection( facingDirection : Vector4 );
	public import function SetMovementDirection( movementDirection : Vector4, forwardVector : Vector4 );
}

class AnimFeature_PlayerLocomotionStateMachine extends AnimFeature
{
	editable var inAirState : Bool;
}

class AnimFeature_LadderEnterStyleData extends AnimFeature
{
	editable var enterStyle : Int32;
}

import class AnimFeature_PlayerVitals extends AnimFeature
{
	import editable var state : Int32;
	import editable var stateDuration : Float;
}

import class AnimFeature_Cover extends AnimFeature
{
	public import function SetCoverState( coverState : animCoverState );
	public import function SetCoverAction( coverAction : animCoverAction );
	public import function SetCoverAngleToAction( angleToAction : Float );
	public import function SetCoverPosition( position : Vector4 );
	public import function SetCoverDirection( direction : Vector4 );
}

class MeshParam_Weakspot extends AnimFeature
{
	editable var hidden : Int32;
}

class AnimFeature_Inspection extends AnimFeature
{
	editable var activeInspectionStage : Int32;
	editable var rotationX : Float;
	editable var rotationY : Float;
	editable var offsetX : Float;
	editable var offsetY : Float;
}

class AnimFeature_RotatingObject extends AnimFeature
{
	editable var rotateClockwise : Bool;
	editable var randomizeBladesRotation : Bool;
	editable var maxRotationSpeed : Float;
	editable var timeToMaxRotation : Float;
}

import class AnimFeature_FPPCamera extends AnimFeature
{
	public import function SetDeltaYaw( deltaYaw : Float );
	public import function SetDeltaPitch( deltaPitch : Float );
	public import function SetYawSpeed( yawSpeed : Float );
	public import function SetPitchSpeed( pitchSpeed : Float );
}

import class AnimFeature_PlayerStateMachineState extends AnimFeature
{
	public import function SetActive( active : Float );
}

class AnimFeature_IconicItem extends AnimFeature
{
	editable var isScanning : Bool;
	editable var isFreeDrilling : Bool;
	editable var isActiveDrilling : Bool;
	editable var isScanToInteraction : Bool;
	editable var isItemEquipped : Bool;
}

import class AnimFeature_Landing extends AnimFeature
{
	import var type : Int32;
	import var impactSpeed : Float;
}

class AnimFeature_Throwable extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_LeftHandCyberware extends AnimFeature
{
	editable var actionDuration : Float;
	editable var state : Int32;
	editable var isQuickAction : Bool;
	editable var isChargeAction : Bool;
	editable var isLoopAction : Bool;
	editable var isCatchAction : Bool;
	editable var isSafeAction : Bool;
}

class AnimFeature_CoverState extends AnimFeature
{
	editable var inCover : Bool;
	editable var debugVar : Bool;
}

class AnimFeature_DelayEntry extends AnimFeature
{
	editable var thresholdPassed : Bool;
}

import class AnimFeature_PlayerCoverActionState extends AnimFeature
{
	import var state : Int32;
}

class AnimFeature_PlayerCoverActionWeaponHolster extends AnimFeature
{
	editable var isWeaponHolstered : Bool;
}

class AnimFeature_PlayerPeekScale extends AnimFeature
{
	editable var peekScale : Float;
}

class AnimFeature_FocusMode extends AnimFeature
{
	editable var isFocusModeActive : Bool;
}

class AnimFeature_AnimatedDevice extends AnimFeature
{
	editable var isOn : Bool;
	editable var isOff : Bool;
}

class AnimFeature_SimpleDevice extends AnimFeatureMarkUnstable
{
	editable var isOpen : Bool;
	editable var isOpenLeft : Bool;
	editable var isOpenRight : Bool;
}

class AnimFeature_IndustrialArm extends AnimFeature
{
	editable var idleAnimNumber : Int32;
	editable var isRotate : Bool;
	editable var isDistraction : Bool;
	editable var isPoke : Bool;
}

class AnimFeature_DoorDevice extends AnimFeature
{
	editable var isOpen : Bool;
	editable var isLocked : Bool;
	editable var isSealed : Bool;
}

class AnimFeature_Container extends AnimFeature
{
	editable var opened : Bool;
	editable var transitionDuration : Float;
}

class AnimFeature_ForkliftDevice extends AnimFeature
{
	editable var isUp : Bool;
	editable var isDown : Bool;
	editable var distract : Bool;
}

class AnimFeature_SceneSystem extends AnimFeature
{
	editable var tier : Int32;
}

class AnimFeature_SceneSystemCarrying extends AnimFeature
{
	editable var carrying : Bool;
}

class AnimFeature_SceneGameplayOverrides extends AnimFeature
{
	editable var aimForced : Bool;
	editable var safeForced : Bool;
	editable var isAimOutTimeOverridden : Bool;
	editable var aimOutTimeOverride : Float;
}

class AnimFeature_DOFControl extends AnimFeature
{
	editable var dofIntensity : Float;
	editable var dofNearBlur : Float;
	editable var dofNearFocus : Float;
	editable var dofFarBlur : Float;
	editable var dofFarFocus : Float;
	editable var dofBlendInTime : Float;
	editable var dofBlendOutTime : Float;
}

class AnimFeature_SelectRandomAnimSync extends AnimFeature
{
	editable var value : Int32;
}

class AnimFeature_TriggerModeChange extends AnimFeature
{
	editable var cycleTime : Float;
}

import class AnimFeature_MeleeData extends AnimFeature
{
	import var isMeleeWeaponEquipped : Bool;
	import var attackSpeed : Float;
	import var isEquippingThrowable : Bool;
	import var isTargeting : Bool;
	import var isBlocking : Bool;
	import var isHolding : Bool;
	editable var isParried : Bool;
	editable var isThrowReloading : Bool;
	editable var throwReloadTime : Float;
	import var isAttacking : Bool;
	import var attackNumber : Int32;
	import var shouldHandsDisappear : Bool;
	import var isSliding : Bool;
	import var deflectDuration : Float;
	import var isSafe : Bool;
	import var keepRenderPlane : Bool;
	import var hasDeflectAnim : Bool;
	import var hasHitAnim : Bool;
	import var attackType : Int32;
}

import class AnimFeature_MeleeSlotData extends AnimFeature
{
	import var attackType : Int32;
	import var comboNumber : Int32;
	import var startupDuration : Float;
	import var activeDuration : Float;
	import var recoverDuration : Float;
	editable var activeHitDuration : Float;
	editable var recoverHitDuration : Float;
}

import class AnimFeature_MeleeIKData extends AnimFeature
{
	import var isValid : Bool;
	import var headPosition : Vector4;
	import var chestPosition : Vector4;
	import var ikOffset : Vector4;
}

class AnimFeature_MeleeAttack extends AnimFeature
{
	editable var hit : Bool;
}

import class AnimFeature_QuickMelee extends AnimFeature
{
	import var state : Int32;
}

class AnimFeature_StatusEffect extends AnimFeature
{
	editable var state : Int32;
	editable var duration : Float;
	default duration = -1.f;
	editable var variation : Int32;
	default variation = 1;
	editable var direction : Int32;
	editable var impactDirection : Int32;
	default impactDirection = -1;
	editable var knockdown : Bool;
	editable var stunned : Bool;
	editable var playImpact : Bool;
	default playImpact = false;

	public function Clear()
	{
		state = 0;
		impactDirection = -1;
		knockdown = false;
		stunned = false;
		playImpact = false;
	}

}

class AnimFeature_Whip extends AnimFeature
{
	editable var state : Int32;
	editable var pullState : Int32;
	editable var targetPoint : Vector4;
}

class AnimFeature_AerialTakedown extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_AirHover extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_SuperheroLand extends AnimFeature
{
	editable var state : Int32;
	editable var type : Int32;
}

class AnimFeature_VehicleData extends AnimFeature
{
	editable var isInVehicle : Bool;
	editable var isDriver : Bool;
	editable var vehType : Int32;
	editable var vehSlot : Int32;
	editable var isInCombat : Bool;
	editable var isInWindowCombat : Bool;
	editable var isInDriverCombat : Bool;
	editable var vehClass : Int32;
	editable var isEnteringCombat : Bool;
	editable var enteringCombatDuration : Float;
	editable var isExitingCombat : Bool;
	editable var exitingCombatDuration : Float;
	editable var isEnteringVehicle : Bool;
	editable var isExitingVehicle : Bool;
	editable var isWorldRenderPlane : Bool;
}

class AnimFeature_PartData extends AnimFeatureMarkUnstable
{
	editable var state : Int32;
	editable var duration : Float;
}

class AnimFeature_VehicleSteeringLimit extends AnimFeatureMarkUnstable
{
	editable var state : Int32;
}

class AnimFeature_NPCVehicleAdditionalFeatures extends AnimFeatureMarkUnstable
{
	editable var state : Bool;
}

class AnimFeature_HoverJumpData extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_CamberData extends AnimFeatureMarkUnstable
{
	editable var rightFrontCamber : Float;
	editable var leftFrontCamber : Float;
	editable var rightBackCamber : Float;
	editable var leftBackCamber : Float;
	editable var rightFrontCamberOffset : Vector4;
	editable var leftFrontCamberOffset : Vector4;
	editable var rightBackCamberOffset : Vector4;
	editable var leftBackCamberOffset : Vector4;
}

class AnimFeature_VehicleState extends AnimFeatureMarkUnstable
{
	editable var tppEnabled : Bool;
}

class AnimFeature_SwimmingData extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_AirThrusterData extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_PlayerDeathAnimation extends AnimFeature
{
	editable var animation : Int32;
}

class AnimFeature_VehicleNPCData extends AnimFeature
{
	editable var isDriver : Bool;
	editable var side : Int32;
}

class AnimFeature_VehicleNPCDeathData extends AnimFeature
{
	editable var deathType : Int32;
	editable var side : Int32;
}

import class AnimFeature_VehiclePassenger extends AnimFeature
{
	import var isCar : Bool;
}

class AnimFeature_SecurityTurretData extends AnimFeature
{
	editable var Shoot : Bool;
	editable var isRippedOff : Bool;
	editable var ripOffSide : Bool;
	editable var isOverriden : Bool;
}

class AnimFeature_LeftHandAnimation extends AnimFeature
{
	editable var lockLeftHandAnimation : Bool;
}

import class AnimFeature_LeftHandItem extends AnimFeature
{
	import var itemInLeftHand : Bool;
}

class AnimFeature_CombatGadget extends AnimFeature
{
	editable var isQuickthrow : Bool;
	editable var isChargedThrow : Bool;
	editable var isDetonated : Bool;
}

class AnimFeature_LookAt extends AnimFeature
{
	editable var enableLookAt : Int32;
	editable var enableLookAtChest : Int32;
	editable var enableLookAtHead : Int32;
	editable var enableLookAtLeftHanded : Int32;
	editable var enableLookAtRightHanded : Int32;
	editable var enableLookAtTwoHanded : Int32;
	editable var gpLookAtTargetBlend : Float;
	editable var gpLookAtUpBlend : Float;
	editable var gpLookAtTarget : Vector4;
	editable var gpLookAtUp : Vector4;
	editable var lookAtChestMode : Int32;
	editable var lookAtChestOverride : Float;
	editable var lookAtHeadMode : Int32;
	editable var lookAtHeadOverride : Float;
	editable var lookAtLeftHandedMode : Int32;
	editable var lookAtLeftHandedOverride : Float;
	editable var lookAtRightHandedMode : Int32;
	editable var lookAtRightHandedOverride : Float;
	editable var lookAtTwoHandedMode : Int32;
	editable var lookAtTwoHandedOverride : Float;
}

class AnimFeature_SimpleIkSystem extends AnimFeature
{
	editable var isEnable : Bool;
	editable var weight : Float;
	default weight = 1.0f;
	editable var setPosition : Bool;
	editable var position : Vector4;
	editable var positionOffset : Vector4;
	editable var setRotation : Bool;
	editable var rotation : Quaternion;
	editable var rotationOffset : Quaternion;
}

class AnimFeature_ProceduralIronsightData extends AnimFeature
{
	editable var hasScope : Bool;
	editable var isEnabled : Bool;
	editable var offset : Float;
	editable var scopeOffset : Float;
	editable var position : Vector4;
	editable var rotation : Quaternion;
}

import class AnimFeature_DodgeData extends AnimFeature
{
	import var dodgeType : Int32;
	import var dodgeDirection : Int32;
}

import class AnimFeature_EquipUnequipItem extends AnimFeature
{
	import var stateTransitionDuration : Float;
	import var itemState : Int32;
	import var itemType : Int32;
	import var firstEquip : Bool;
}

class AnimFeature_Mounting extends AnimFeature
{
	editable var mountingState : Int32;
	editable var parentSpeed : Float;
}

class AnimFeature_Carry extends AnimFeature
{
	editable var state : Int32;
	editable var pickupAnimation : Int32;
	editable var useBothHands : Bool;
	editable var instant : Bool;
}

class AnimFeature_Grapple extends AnimFeature
{
	editable var inGrapple : Bool;
}

class AnimFeature_PreClimbing extends AnimFeature
{
	editable var edgePositionLS : Vector4;
	editable var valid : Float;
}

class AnimFeature_SafeAction extends AnimFeature
{
	editable var triggerHeld : Bool;
	editable var inCover : Bool;
	editable var safeActionDuration : Float;
}

abstract class AnimFeatureCustom extends AnimFeature
{
}

class AnimFeatureShieldState extends AnimFeatureCustom
{
	editable var state : Int32;
}

class AnimFeature_WeaponOverride extends AnimFeature
{
	editable var state : Int32;
}

class AnimFeature_StimReactions extends AnimFeature
{
	editable var reactionType : Int32;
}

import class AnimFeature_ConsumableAnimation extends AnimFeature
{
	import var consumableType : Int32;
	import var useConsumable : Bool;
}

class AnimFeature_OwnerType extends AnimFeature
{
	editable var ownerEnum : Int32;
}

class AnimFeature_BulletBend extends AnimFeature
{
	editable var animProgression : Float;
	editable var randomAdditive : Float;
	editable var isResetting : Bool;
}

class AnimFeature_WorkspotIK extends AnimFeature
{
	editable var rightHandPosition : Vector4;
	editable var leftHandPosition : Vector4;
	editable var cameraPosition : Vector4;
	editable var rightHandRotation : Quaternion;
	editable var leftHandRotation : Quaternion;
	editable var cameraRotation : Quaternion;
	editable var shouldCrouch : Bool;
	editable var isInteractingWithDevice : Bool;
}

class AnimFeature_RoadBlock extends AnimFeature
{
	editable var isOpening : Bool;
	editable var duration : Float;
	editable var initOpen : Bool;
}

class AnimFeature_Stamina extends AnimFeature
{
	editable var staminaValue : Float;
	default staminaValue = 1.f;
	editable var tiredness : Float;
	default tiredness = 0.f;
}

class AnimFeature_CombatState extends AnimFeature
{
	editable var isInCombat : Bool;
}

class AnimFeature_AdHocAnimation extends AnimFeature
{
	editable var isActive : Bool;
	editable var useBothHands : Bool;
	editable var animationIndex : Int32;
}

import class AnimFeature_WeaponReload extends AnimFeature
{
	import var emptyReload : Bool;
	import var amountToReload : Int32;
	import var continueLoop : Bool;
	import var loopDuration : Float;
	import var emptyDuration : Float;
}

class AnimFeature_WeaponStats extends AnimFeature
{
	editable var magazineCapacity : Int32;
	editable var cycleTime : Float;
}

class AnimFeature_ProceduralLean extends AnimFeature
{
	editable var angle_threshold : Float;
	default angle_threshold = 5.0f;
	editable var max_turn_angle : Float;
	default max_turn_angle = 50.0f;
	editable var hips_shift_side : Float;
	default hips_shift_side = 0.1f;
	editable var hips_shift_down : Float;
	default hips_shift_down = -0.01f;
	editable var hips_tilt : Float;
	default hips_tilt = -8.0f;
	editable var hips_turn : Float;
	default hips_turn = -5.0f;
	editable var spine_tilt : Float;
	default spine_tilt = -5.0f;
	editable var spine_turn : Float;
	default spine_turn = -12.0f;
	editable var arms_counter_turn : Float;
	default arms_counter_turn = 10.0f;
	editable var transform_multiplyer : Float;
	default transform_multiplyer = 1.0f;
	editable var damp_value_walk : Float;
	default damp_value_walk = 100.0f;
	editable var damp_value_sprint : Float;
	default damp_value_sprint = 100.0f;
}

class AnimFeature_CameraGameplay extends AnimFeature
{
	editable var is_forward_offset : Float;
	default is_forward_offset = 1.0f;
	editable var forward_offset_value : Float;
	default forward_offset_value = 0.2f;
	editable var upperbody_pitch_weight : Float;
	default upperbody_pitch_weight = 0.0f;
	editable var upperbody_yaw_weight : Float;
	default upperbody_yaw_weight = 0.0f;
	editable var is_pitch_off : Float;
	default is_pitch_off = 0.0f;
	editable var is_yaw_off : Float;
	default is_yaw_off = 0.0f;
}

class AnimFeature_CameraSceneMode extends AnimFeature
{
	editable var pitch_yaw_order : Float;
	editable var is_scene_mode : Float;
	editable var scene_settings_mode : Float;
}

class AnimFeature_CameraBodyOffset extends AnimFeature
{
	editable var lookat_pitch_forward_offset : Float;
	default lookat_pitch_forward_offset = 0.05f;
	editable var lookat_pitch_forward_down_ratio : Float;
	default lookat_pitch_forward_down_ratio = 0.4f;
	editable var lookat_yaw_left_offset : Float;
	default lookat_yaw_left_offset = 0.0f;
	editable var lookat_yaw_left_up_offset : Float;
	default lookat_yaw_left_up_offset = 0.0f;
	editable var lookat_yaw_right_offset : Float;
	default lookat_yaw_right_offset = 0.0f;
	editable var lookat_yaw_right_up_offset : Float;
	default lookat_yaw_right_up_offset = 0.0f;
	editable var lookat_yaw_offset_active_angle : Float;
	default lookat_yaw_offset_active_angle = 45.0f;
	editable var is_paralax : Float;
	default is_paralax = 0.0f;
	editable var paralax_radius : Float;
	default paralax_radius = 0.1f;
	editable var paralax_forward_offset : Float;
	default paralax_forward_offset = 0.1f;
	editable var lookat_offset_vertical : Float;
	default lookat_offset_vertical = 0.0f;
}

class AnimFeature_CameraBreathing extends AnimFeature
{
	editable var amplitudeWeight : Float;
	editable var dampIncreaseSpeed : Float;
	editable var dampDecreaseSpeed : Float;
}

class AnimFeature_CameraRecoil extends AnimFeature
{
	editable var backward_offset : Float;
	editable var side_offset : Float;
	editable var tilt_angle : Float;
	editable var yaw_angle : Float;
	editable var pitch_angle : Float;
	editable var translate_transform_speed : Float;
	editable var rotate_transform_speed : Float;
	editable var is_offset : Bool;
}

import class animAnimFeature_IK extends AnimFeature
{
	import editable var point : Vector4;
	import editable var normal : Vector4;
	import editable var weight : Float;
}

class AnimFeature_DeviceWorkspot extends AnimFeature
{
	editable var e3_lockInReferencePose : Bool;
}

class AnimFeature_WeaponBlur extends AnimFeature
{
	editable var weaponNearPlane : Float;
	editable var weaponFarPlane : Float;
	editable var weaponEdgesSharpness : Float;
	editable var weaponVignetteIntensity : Float;
	editable var weaponVignetteRadius : Float;
	editable var weaponVignetteCircular : Float;
	editable var weaponBlurIntensity : Float;
	editable var weaponNearPlane_aim : Float;
	editable var weaponFarPlane_aim : Float;
	editable var weaponEdgesSharpness_aim : Float;
	editable var weaponVignetteIntensity_aim : Float;
	editable var weaponVignetteRadius_aim : Float;
	editable var weaponVignetteCircular_aim : Float;
	editable var weaponBlurIntensity_aim : Float;
}

class AnimFeature_Paperdoll extends AnimFeature
{
	editable var genderSelection : Bool;
	editable var characterCreation : Bool;
	editable var characterCreation_Head : Bool;
	editable var characterCreation_Teeth : Bool;
	editable var characterCreation_Nails : Bool;
	editable var characterCreation_Eyes : Bool;
	editable var characterCreation_Nose : Bool;
	editable var characterCreation_Lips : Bool;
	editable var characterCreation_Hair : Bool;
	editable var characterCreation_Jaw : Bool;
	editable var characterCreation_Summary : Bool;
	editable var inventoryScreen : Bool;
	editable var inventoryScreen_Weapon : Bool;
	editable var inventoryScreen_Legs : Bool;
	editable var inventoryScreen_Feet : Bool;
	editable var inventoryScreen_Cyberware : Bool;
	editable var inventoryScreen_QuickSlot : Bool;
	editable var inventoryScreen_Consumable : Bool;
	editable var inventoryScreen_Outfit : Bool;
	editable var inventoryScreen_Head : Bool;
	editable var inventoryScreen_Face : Bool;
	editable var inventoryScreen_InnerChest : Bool;
	editable var inventoryScreen_OuterChest : Bool;
}

class AnimFeature_DroneProcedural extends AnimFeature
{
	editable var mass : Float;
	default mass = 100f;
	editable var size_front : Float;
	default size_front = 1.5f;
	editable var size_back : Float;
	default size_back = -1.5f;
	editable var size_left : Float;
	default size_left = 1.2f;
	editable var size_right : Float;
	default size_right = -1.2f;
	editable var walk_tilt_coef : Float;
	default walk_tilt_coef = 1.33f;
	editable var mass_normalized_coef : Float;
	default mass_normalized_coef = 2.0f;
	editable var tilt_angle_on_speed : Float;
	default tilt_angle_on_speed = 40.0f;
	editable var speed_idle_threshold : Float;
	default speed_idle_threshold = 0.2f;
	editable var starting_recovery_ballance : Float;
	default starting_recovery_ballance = 0.01f;
	editable var pseudo_acceleration : Float;
	default pseudo_acceleration = 30f;
	editable var turn_inertia_damping : Float;
	default turn_inertia_damping = 0.75f;
	editable var combat_default_z_offset : Float;
	default combat_default_z_offset = 0.f;
}

class AnimFeature_DroneActionAltitudeOffset extends AnimFeature
{
	editable var desiredOffset : Float;
	default desiredOffset = 0.f;
}

class AnimFeature_DroneStateAnimationData extends AnimFeature
{
	editable var statePose : Int32;
	default statePose = 0;
}

class AnimFeature_PlayerHitReactionData extends AnimFeature
{
	editable var hitDirection : Float;
	editable var hitStrength : Float;
	editable var isMeleeHit : Bool;
	editable var isLightMeleeHit : Bool;
	editable var isStrongMeleeHit : Bool;
	editable var isQuickMeleeHit : Bool;
	editable var isExplosion : Bool;
	editable var isPressureWave : Bool;
	editable var meleeAttackDirection : Int32;
}

class AnimFeature_WeaponScopeData extends AnimFeature
{
	editable var ironsightAngleWithScope : Float;
	editable var hasScope : Bool;
}

class AnimFeature_MuzzleData extends AnimFeature
{
	editable var muzzleOffset : Vector4;
}

class AnimFeature_WeaponHandlingStats extends AnimFeature
{
	editable var weaponRecoil : Float;
	editable var weaponSpread : Float;
}

import class AnimFeature_WeaponReloadSpeedData extends AnimFeature
{
	import var reloadSpeed : Float;
	import var emptyReloadSpeed : Float;
}

import class AnimFeature_PhotomodeFacial extends AnimFeature
{
	import editable var facialPoseIndex : Int32;
}

class AnimFeature_Reprimand extends AnimFeature
{
	editable var state : Int32;
	editable var isActive : Bool;
	editable var isLocomotion : Bool;
	editable var weaponType : Int32;
}

class AnimFeature_CrowdRunningAway extends AnimFeature
{
	editable var isRunningAwayFromPlayersCar : Bool;
}

class AnimFeature_RagdollState extends AnimFeature
{
	editable var isActive : Bool;
	editable var hipsPolePitch : Float;
	editable var speed : Float;
}

import enum animAimState
{
	Unaimed,
	Aimed,
}

import enum animStanceState
{
	Stand,
	Crouch,
	Kneel,
	Cover,
	Swim,
	Crawl,
}

import enum animHitReactionType
{
	None,
	Twitch,
	Impact,
	Stagger,
	Pain,
	Knockdown,
	Ragdoll,
	Death,
	Block,
	GuardBreak,
	Parry,
	Bump,
}

import enum animCoverState
{
	LowCover,
	HighCover,
}

import enum animCoverAction
{
	NoAction,
	LeanLeft,
	LeanRight,
	StepOutLeft,
	StepOutRight,
	LeanOver,
	StepUp,
	EnterCover,
	SlideTo,
	Vault,
	LeaveCover,
	BlindfireLeft,
	BlindfireRight,
	BlindfireOver,
	OverheadStepOutLeft,
	OverheadStepOutRight,
	OverheadStepUp,
}

enum animNPCVehicleDeathType
{
	Default = 0,
	Relaxed = 1,
	Combat = 2,
	Ragdoll = 3,
}

enum animWeaponOwnerType
{
	Player = 0,
	NPC = 1,
	None = 2,
}

