abstract class LocomotionTransition extends DefaultTransition
{
	var m_ownerRecordId : TweakDBID;
	var m_statModifierGroupId : Uint64;
	var m_statModifierTDBNameDefault : String;

	protected export virtual function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_statModifierTDBNameDefault = NameToString( GetStateName() );
		UppercaseFirstChar( m_statModifierTDBNameDefault );
		m_statModifierTDBNameDefault = "player_locomotion_data_" + m_statModifierTDBNameDefault;
		m_statModifierTDBNameDefault = ( ( "Player" + NameToString( GetStateMachineName() ) ) + "." ) + m_statModifierTDBNameDefault;
	}

	public export virtual function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
	}

	protected export const function InternalEnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var capsuleHeight : Float;
		var capsuleRadius : Float;
		capsuleHeight = GetStaticFloatParameterDefault( "capsuleHeight", 1.0 );
		capsuleRadius = GetStaticFloatParameterDefault( "capsuleRadius", 1.0 );
		return scriptInterface.CanCapsuleFit( capsuleHeight, capsuleRadius );
	}

	protected function SetModifierGroupForState( scriptInterface : StateGameScriptInterface, optional statModifierTDBName : String )
	{
		var statSystem : StatsSystem;
		var ownerRecordId : TweakDBID;
		statSystem = scriptInterface.GetStatsSystem();
		ownerRecordId = ( ( gamePuppetBase )( scriptInterface.owner ) ).GetRecordID();
		if( m_ownerRecordId != ownerRecordId )
		{
			m_ownerRecordId = ownerRecordId;
			TDBID.Append( ownerRecordId, T"PlayerLocomotion" );
			m_statModifierGroupId = TDBID.ToNumber( ownerRecordId );
		}
		statSystem.RemoveModifierGroup( scriptInterface.ownerEntityID, m_statModifierGroupId );
		statSystem.UndefineModifierGroup( m_statModifierGroupId );
		if( statModifierTDBName == "" )
		{
			statModifierTDBName = m_statModifierTDBNameDefault;
		}
		statSystem.DefineModifierGroupFromRecord( m_statModifierGroupId, TDBID.Create( statModifierTDBName ) );
		statSystem.ApplyModifierGroup( scriptInterface.ownerEntityID, m_statModifierGroupId );
	}

	protected function ShowDebugText( text : String, scriptInterface : StateGameScriptInterface, out layerId : Uint32 )
	{
		layerId = GameInstance.GetDebugVisualizerSystem( scriptInterface.owner.GetGame() ).DrawText( Vector4( 650.0, 100.0, 0.0, 0.0 ), text, gameDebugViewETextAlignment.Center, Color( 0, 240, 148, 100 ) );
		GameInstance.GetDebugVisualizerSystem( scriptInterface.owner.GetGame() ).SetScale( layerId, Vector4( 1.5, 1.5, 0.0, 0.0 ) );
	}

	protected function ClearDebugText( layerId : Uint32, scriptInterface : StateGameScriptInterface )
	{
		GameInstance.GetDebugVisualizerSystem( scriptInterface.owner.GetGame() ).ClearLayer( layerId );
	}

	protected function ResetFallingParameters( stateContext : StateContext )
	{
		stateContext.SetPermanentIntParameter( 'LandingType', ( ( Int32 )( LandingType.Off ) ), true );
		stateContext.SetPermanentFloatParameter( 'ImpactSpeed', 0.0, true );
		stateContext.SetPermanentFloatParameter( 'InAirDuration', 0.0, true );
	}

	protected function PlayHardLandingEffects( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		StartEffect( scriptInterface, 'landing_hard' );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.HardLanding" ) );
		SpawnLandingFxGameEffect( T"Attacks.HardLanding", scriptInterface );
		GameObject.PlayVoiceOver( scriptInterface.owner, 'hardLanding', 'Scripts:HardLandEvents' );
		PlayRumble( scriptInterface, "medium_pulse" );
	}

	protected function PlayVeryHardLandingEffects( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		StartEffect( scriptInterface, 'landing_very_hard' );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.VeryHardLanding" ) );
		SpawnLandingFxGameEffect( T"Attacks.VeryHardLanding", scriptInterface );
		GameObject.PlayVoiceOver( scriptInterface.owner, 'veryhardLanding', 'Scripts:VeryHardLandEvents' );
		PlayRumble( scriptInterface, "heavy_fast" );
	}

	protected function PlayDeathLandingEffects( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		StartEffect( scriptInterface, 'landing_death' );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.DeathLanding" ) );
		SpawnLandingFxGameEffect( T"Attacks.DeathLanding", scriptInterface );
		GameObject.PlayVoiceOver( scriptInterface.owner, 'veryhardLanding', 'Scripts:DeathLandEvents' );
	}

	protected function AddImpulseInMovingDirection( stateContext : StateContext, scriptInterface : StateGameScriptInterface, impulse : Float )
	{
		var direction : Vector4;
		if( impulse == 0.0 )
		{
			return;
		}
		direction = scriptInterface.GetOwnerMovingDirection();
		AddImpulse( stateContext, direction * impulse );
	}

	protected function AddImpulse( stateContext : StateContext, impulse : Vector4 )
	{
		stateContext.SetTemporaryVectorParameter( 'impulse', impulse, true );
	}

	protected function AddVerticalImpulse( stateContext : StateContext, force : Float )
	{
		var impulse : Vector4;
		impulse.Z = force;
		AddImpulse( stateContext, impulse );
	}

	public function SetCollisionFilter( scriptInterface : StateGameScriptInterface )
	{
		var simulationFilter : SimulationFilter;
		var zero : Bool;
		zero = GetStaticBoolParameterDefault( "collisionFilterPresetIsZero", false );
		if( zero )
		{
			simulationFilter = SimulationFilter.ZERO();
		}
		else
		{
			SimulationFilter.SimulationFilter_BuildFromPreset( simulationFilter, 'Player Collision' );
		}
		scriptInterface.SetStateVectorParameter( physicsStateValue.SimulationFilter, simulationFilter );
	}

	public virtual function SetLocomotionParameters( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : LocomotionParameters
	{
		var locomotionParameters : LocomotionParameters;
		SetModifierGroupForState( scriptInterface );
		locomotionParameters = new LocomotionParameters;
		GetStateDefaultLocomotionParameters( locomotionParameters );
		stateContext.SetTemporaryScriptableParameter( 'locomotionParameters', locomotionParameters, true );
		return locomotionParameters;
	}

	protected final function SetLocomotionCameraParameters( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var param : StateResultCName;
		param = GetStaticCNameParameter( "onEnterCameraParamsName" );
		if( param.valid )
		{
			stateContext.SetPermanentCNameParameter( 'LocomotionCameraParams', param.value, true );
			UpdateCameraParams( stateContext, scriptInterface );
		}
	}

	protected const function GetStateDefaultLocomotionParameters( out locomotionParameters : LocomotionParameters )
	{
		locomotionParameters.SetUpwardsGravity( GetStaticFloatParameterDefault( "upwardsGravity", -16.0 ) );
		locomotionParameters.SetDownwardsGravity( GetStaticFloatParameterDefault( "downwardsGravity", -16.0 ) );
		locomotionParameters.SetImperfectTurn( GetStaticBoolParameterDefault( "imperfectTurn", false ) );
		locomotionParameters.SetSpeedBoostInputRequired( GetStaticBoolParameterDefault( "speedBoostInputRequired", false ) );
		locomotionParameters.SetSpeedBoostMultiplyByDot( GetStaticBoolParameterDefault( "speedBoostMultiplyByDot", false ) );
		locomotionParameters.SetUseCameraHeadingForMovement( GetStaticBoolParameterDefault( "useCameraHeadingForMovement", false ) );
		locomotionParameters.SetCapsuleHeight( GetStaticFloatParameterDefault( "capsuleHeight", 1.79999995 ) );
		locomotionParameters.SetCapsuleRadius( GetStaticFloatParameterDefault( "capsuleRadius", 0.40000001 ) );
		locomotionParameters.SetIgnoreSlope( GetStaticBoolParameterDefault( "ignoreSlope", false ) );
	}

	protected function BroadcastStimuliFootstepSprint( context : StateGameScriptInterface )
	{
		var broadcastFootstepStim : Bool;
		var broadcaster : StimBroadcasterComponent;
		broadcastFootstepStim = GameInstance.GetStatsSystem( context.owner.GetGame() ).GetStatValue( context.owner.GetEntityID(), gamedataStatType.CanRunSilently ) < 1.0;
		if( broadcastFootstepStim )
		{
			broadcaster = context.executionOwner.GetStimBroadcasterComponent();
			if( broadcaster )
			{
				broadcaster.TriggerSingleBroadcast( context.executionOwner, gamedataStimType.FootStepSprint );
			}
		}
	}

	protected function BroadcastStimuliFootstepRegular( context : StateGameScriptInterface )
	{
		var broadcastFootstepStim : Bool;
		var broadcaster : StimBroadcasterComponent;
		broadcastFootstepStim = GameInstance.GetStatsSystem( context.owner.GetGame() ).GetStatValue( context.owner.GetEntityID(), gamedataStatType.CanWalkSilently ) < 1.0;
		if( broadcastFootstepStim )
		{
			broadcaster = context.executionOwner.GetStimBroadcasterComponent();
			if( broadcaster )
			{
				broadcaster.TriggerSingleBroadcast( context.executionOwner, gamedataStimType.FootStepRegular );
			}
		}
	}

	protected final function SetDetailedState( scriptInterface : StateGameScriptInterface, state : gamePSMDetailedLocomotionStates )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed, ( ( Int32 )( state ) ) );
	}

	public const function IsTouchingGround( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var onGround : Bool;
		onGround = scriptInterface.IsOnGround();
		return onGround;
	}

	public const function HasSecureFooting( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return CheckSecureFootingFailure( HasSecureFootingDetailedResult( scriptInterface ) );
	}

	public const function CheckSecureFootingFailure( const result : SecureFootingResult ) : Bool
	{
		return result.type == moveSecureFootingFailureType.Invalid;
	}

	public const function HasSecureFootingDetailedResult( const scriptInterface : StateGameScriptInterface ) : SecureFootingResult
	{
		return scriptInterface.HasSecureFooting();
	}

	protected const function GetFallingSpeedBasedOnHeight( const scriptInterface : StateGameScriptInterface, height : Float ) : Float
	{
		var speed : Float;
		var acc : Float;
		if( height <= 0.0 )
		{
			return 0.0;
		}
		acc = AbsF( GetStaticFloatParameterDefault( "upwardsGravity", GetStaticFloatParameterDefault( "defaultGravity", -16.0 ) ) );
		speed = 0.0;
		if( acc != 0.0 )
		{
			speed = acc * SqrtF( ( 2.0 * height ) / acc );
		}
		return speed * -1.0;
	}

	protected function GetSpeedBasedOnDistance( scriptInterface : StateGameScriptInterface, desiredDistance : Float ) : Float
	{
		var deceleration : Float;
		var statSystem : StatsSystem;
		statSystem = scriptInterface.GetStatsSystem();
		deceleration = GetStatFloatValue( scriptInterface, gamedataStatType.Deceleration, statSystem );
		return deceleration * SqrtF( ( 2.0 * desiredDistance ) / deceleration );
	}

	protected const function IsCurrentFallSpeedTooFastToEnter( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var playerFallingTooFast : Float;
		var verticalSpeed : Float;
		if( !( scriptInterface.IsOnGround() ) )
		{
			verticalSpeed = GetVerticalSpeed( scriptInterface );
			playerFallingTooFast = stateContext.GetFloatParameter( 'VeryHardLandingFallingSpeed', true );
			if( verticalSpeed <= playerFallingTooFast )
			{
				return true;
			}
		}
		return false;
	}

	protected const function IsAiming( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetActionValue( 'CameraAim' ) > 0.0;
	}

	protected const function WantsToDodge( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isInCooldown : Bool;
		isInCooldown = StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeCooldown" ) || StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeAirCooldown" );
		if( isInCooldown )
		{
			return false;
		}
		if( scriptInterface.IsActionJustPressed( 'Dodge' ) )
		{
			if( scriptInterface.IsMoveInputConsiderable() )
			{
				stateContext.SetConditionFloatParameter( 'DodgeDirection', scriptInterface.GetInputHeading(), true );
				return true;
			}
			else if( GetStaticBoolParameterDefault( "dodgeWithNoMovementInput", false ) )
			{
				stateContext.SetConditionFloatParameter( 'DodgeDirection', -180.0, true );
				return true;
			}
		}
		if( WantsToDodgeFromMovementInput( stateContext, scriptInterface ) && GameplaySettingsSystem.GetMovementDodgeEnabled( scriptInterface.executionOwner ) )
		{
			return true;
		}
		return false;
	}

	protected const function WantsToDodgeFromMovementInput( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustPressed( 'DodgeForward' ) )
		{
			stateContext.SetConditionFloatParameter( 'DodgeDirection', 0.0, true );
			return true;
		}
		if( scriptInterface.IsActionJustPressed( 'DodgeRight' ) )
		{
			stateContext.SetConditionFloatParameter( 'DodgeDirection', -90.0, true );
			return true;
		}
		if( scriptInterface.IsActionJustPressed( 'DodgeLeft' ) )
		{
			stateContext.SetConditionFloatParameter( 'DodgeDirection', 90.0, true );
			return true;
		}
		if( scriptInterface.IsActionJustPressed( 'DodgeBack' ) )
		{
			stateContext.SetConditionFloatParameter( 'DodgeDirection', -180.0, true );
			return true;
		}
		return false;
	}

	protected const function IsIdleForced( const stateContext : StateContext ) : Bool
	{
		return stateContext.GetBoolParameter( 'ForceIdle', true );
	}

	protected const function IsWalkForced( const stateContext : StateContext ) : Bool
	{
		return stateContext.GetBoolParameter( 'ForceWalk', true );
	}

	protected const function IsFreezeForced( const stateContext : StateContext ) : Bool
	{
		return stateContext.GetBoolParameter( 'ForceFreeze', true );
	}

	protected const function GetLandingType( const stateContext : StateContext ) : Int32
	{
		return stateContext.GetIntParameter( 'LandingType', true );
	}

	protected function PlayRumbleBasedOnDodgeDirection( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var movementDirection : EPlayerMovementDirection;
		var presetName : String;
		movementDirection = GetMovementDirection( stateContext, scriptInterface );
		if( movementDirection == EPlayerMovementDirection.Right )
		{
			presetName = "medium_pulse_right";
		}
		else if( movementDirection == EPlayerMovementDirection.Left )
		{
			presetName = "medium_pulse_left";
		}
		else
		{
			presetName = "medium_pulse";
		}
		PlayRumble( scriptInterface, presetName );
	}

	protected const function IsStatusEffectType( statusEffectRecord : StatusEffect_Record, type : gamedataStatusEffectType ) : Bool
	{
		var effectType : gamedataStatusEffectType;
		effectType = statusEffectRecord.StatusEffectType().Type();
		return effectType == type;
	}

	protected function SpawnLandingFxGameEffect( attackId : TweakDBID, scriptInterface : StateGameScriptInterface )
	{
		var effect : EffectInstance;
		var position : Vector4;
		effect = scriptInterface.GetGameEffectSystem().CreateEffectStatic( 'landing', 'fx', scriptInterface.executionOwner );
		position = scriptInterface.executionOwner.GetWorldPosition();
		position.Z += 0.5;
		EffectData.SetFloat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 2.0 );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4( 0.0, 0.0, -1.0, 0.0 ) );
		EffectData.SetVariant( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackId, attackId );
		effect.Run();
	}

	protected const function ProcessSprintInputLock( stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		if( ( stateContext.GetBoolParameter( 'sprintInputLock', true ) && ( scriptInterface.GetActionValue( 'Sprint' ) == 0.0 ) ) && ( scriptInterface.GetActionValue( 'ToggleSprint' ) == 0.0 ) )
		{
			stateContext.RemovePermanentBoolParameter( 'sprintInputLock' );
		}
	}

	protected const function SetupSprintInputLock( stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		if( ( scriptInterface.GetActionValue( 'Sprint' ) != 0.0 ) || ( scriptInterface.GetActionValue( 'ToggleSprint' ) != 0.0 ) )
		{
			stateContext.SetPermanentBoolParameter( 'sprintInputLock', true, true );
		}
	}

	protected const function LogSpecialMovementToTelemetry( const scriptInterface : StateGameScriptInterface, mvtType : telemetryMovementType )
	{
		GameInstance.GetTelemetrySystem( scriptInterface.executionOwner.GetGame() ).LogSpecialMovementPerformed( mvtType );
	}

}

abstract class LocomotionEventsTransition extends LocomotionTransition
{
	var m_causeContactDestruction : Bool;
	var m_activatedDestructionComponent : Bool;
	var m_ignoreBarbedWire : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		m_causeContactDestruction = GetStaticBoolParameterDefault( "causeContactDestruction", false );
		m_ignoreBarbedWire = GetStaticBoolParameterDefault( "ignoreBarbedWire", false );
		m_activatedDestructionComponent = false;
	}

	public virtual function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var blockAimingFor : Float;
		var activateEvent : ActivateTriggerDestructionComponentEvent;
		var prevStateIgnoredBarbedWire : Bool;
		blockAimingFor = GetStaticFloatParameterDefault( "softBlockAimingOnEnterFor", -1.0 );
		if( blockAimingFor > 0.0 )
		{
			SoftBlockAimingForTime( stateContext, scriptInterface, blockAimingFor );
		}
		SetLocomotionParameters( stateContext, scriptInterface );
		SetCollisionFilter( scriptInterface );
		SetLocomotionCameraParameters( stateContext, scriptInterface );
		if( m_causeContactDestruction )
		{
			LogAssert( GetStaticBoolParameterDefault( "hasOnExit", false ), ( "Locomotion State " + NameToString( GetStateName() ) ) + " has 'hasOnExit' set to false, this will cause the window destruction logic to stay on" );
			activateEvent = new ActivateTriggerDestructionComponentEvent;
			scriptInterface.executionOwner.QueueEvent( activateEvent );
			m_activatedDestructionComponent = true;
		}
		prevStateIgnoredBarbedWire = scriptInterface.localBlackboard.GetFloat( GetAllBlackboardDefs().PlayerStateMachine.IgnoreBarbedWireStateEnterTime ) > 0.0;
		if( prevStateIgnoredBarbedWire != m_ignoreBarbedWire )
		{
			if( m_ignoreBarbedWire )
			{
				SetBlackboardFloatVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IgnoreBarbedWireStateEnterTime, EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) );
			}
			else
			{
				SetBlackboardFloatVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IgnoreBarbedWireStateEnterTime, -1.0 );
			}
		}
	}

	protected function CleanupTriggerDestructionComponent( scriptInterface : StateGameScriptInterface )
	{
		var deactivateEvent : DeactivateTriggerDestructionComponentEvent;
		if( m_activatedDestructionComponent )
		{
			deactivateEvent = new DeactivateTriggerDestructionComponentEvent;
			scriptInterface.executionOwner.QueueEvent( deactivateEvent );
			m_activatedDestructionComponent = false;
		}
	}

	public virtual function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		CleanupTriggerDestructionComponent( scriptInterface );
	}

	public export override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		CleanupTriggerDestructionComponent( scriptInterface );
	}

	public export virtual function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ProcessSprintInputLock( stateContext, scriptInterface );
	}

	protected final function ConsumeStaminaBasedOnLocomotionState( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var stateName : CName;
		var staminaReduction : Float;
		staminaReduction = 0.0;
		stateName = GetStateName();
		switch( stateName )
		{
			case 'sprint':
				if( !( RPGManager.HasStatFlag( scriptInterface.executionOwner, gamedataStatType.IsSprintStaminaFree ) ) )
				{
					staminaReduction = PlayerStaminaHelpers.GetSprintStaminaCost();
				}
			break;
			case 'swimmingSurfaceFast':
			case 'swimmingFastDiving':
				staminaReduction = PlayerStaminaHelpers.GetSprintStaminaCost();
			break;
			case 'slide':
				staminaReduction = PlayerStaminaHelpers.GetSlideStaminaCost();
			break;
			case 'jump':
			case 'doubleJump':
			case 'chargeJump':
			case 'hoverJump':
				staminaReduction = PlayerStaminaHelpers.GetJumpStaminaCost();
			break;
			case 'dodge':
				if( !( RPGManager.HasStatFlag( scriptInterface.executionOwner, gamedataStatType.IsDodgeStaminaFree ) ) )
				{
					staminaReduction = PlayerStaminaHelpers.GetDodgeStaminaCost();
				}
			break;
			case 'dodgeAir':
				if( !( RPGManager.HasStatFlag( scriptInterface.executionOwner, gamedataStatType.IsDodgeStaminaFree ) ) )
				{
					staminaReduction = PlayerStaminaHelpers.GetAirDodgeStaminaCost();
				}
			break;
			default:
				staminaReduction = 0.1;
			break;
		}
		if( staminaReduction > 0.0 )
		{
			PlayerStaminaHelpers.ModifyStamina( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ), -( staminaReduction ) );
		}
	}

	protected final function UpdateInputToggles( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( scriptInterface.IsActionJustPressed( 'ToggleSprint' ) || scriptInterface.IsActionJustPressed( 'Sprint' ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', true, true );
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
			return;
		}
		if( scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', true, true );
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return;
		}
	}

}

abstract class LocomotionGroundEvents extends LocomotionEventsTransition
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var animFeature : AnimFeature_PlayerLocomotionStateMachine;
		super.OnEnter( stateContext, scriptInterface );
		stateContext.RemovePermanentBoolParameter( 'enteredFallFromAirDodge' );
		stateContext.SetPermanentIntParameter( 'currentNumberOfJumps', 0, true );
		stateContext.SetPermanentIntParameter( 'currentNumberOfAirDodges', 0, true );
		SetAudioParameter( 'RTPC_Vertical_Velocity', 0.0, scriptInterface );
		animFeature = new AnimFeature_PlayerLocomotionStateMachine;
		animFeature.inAirState = false;
		scriptInterface.SetAnimationParameterFeature( 'LocomotionStateMachine', animFeature );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.Default ) ) );
		scriptInterface.GetAudioSystem().NotifyGameTone( 'EnterOnGround' );
		StopEffect( scriptInterface, 'falling' );
		stateContext.SetConditionBoolParameter( 'JumpPressed', false, true );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		scriptInterface.GetAudioSystem().NotifyGameTone( 'LeaveOnGround' );
	}

}

abstract class LocomotionGroundDecisions extends LocomotionTransition
{

	public const virtual function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	public static function CheckCrouchEnterCondition( const stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) || stateContext.GetConditionBool( 'CrouchToggled' ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', true, true );
			return true;
		}
		return scriptInterface.GetActionValue( 'Crouch' ) > 0.0;
	}

	protected const function CrouchEnterCondition( const stateContext : StateContext, scriptInterface : StateGameScriptInterface, isFFByLine : Bool ) : Bool
	{
		var paramName : CName;
		var puppet : ScriptedPuppet;
		var puppetPS : ScriptedPuppetPS;
		paramName = ( ( isFFByLine ) ? ( 'FFhintActive' ) : ( 'FFHoldLock' ) );
		puppet = ( ( ScriptedPuppet )( scriptInterface.owner ) );
		if( puppet )
		{
			puppetPS = puppet.GetPuppetPS();
		}
		if( ( ( scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) || stateContext.GetConditionBool( 'CrouchToggled' ) ) && !( stateContext.GetBoolParameter( paramName, true ) ) ) || ( puppetPS && puppetPS.IsCrouch() ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', true, true );
			return true;
		}
		return scriptInterface.GetActionValue( 'Crouch' ) > 0.0;
	}

	protected const function CrouchExitCondition( const stateContext : StateContext, scriptInterface : StateGameScriptInterface, isFFByLine : Bool ) : Bool
	{
		var paramName : CName;
		paramName = ( ( isFFByLine ) ? ( 'FFhintActive' ) : ( 'FFHoldLock' ) );
		if( ( scriptInterface.IsActionJustReleased( 'Crouch' ) || scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) ) && !( stateContext.GetBoolParameter( paramName, true ) ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
			return true;
		}
		if( !( stateContext.GetConditionBool( 'CrouchToggled' ) ) && ( scriptInterface.GetActionValue( 'Crouch' ) == 0.0 ) )
		{
			return true;
		}
		return false;
	}

}

abstract class LocomotionAirDecisions extends LocomotionTransition
{

	protected const virtual function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	protected const function ShouldFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var regularLandingFallingSpeed : Float;
		var verticalSpeed : Float;
		if( IsTouchingGround( scriptInterface ) )
		{
			return false;
		}
		IsTouchingGround( scriptInterface );
		if( scriptInterface.IsOnMovingPlatform() )
		{
			return false;
		}
		if( stateContext.GetBoolParameter( 'isAttacking', true ) )
		{
			return true;
		}
		regularLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "regularLandingHeight", 0.1 ) );
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		return verticalSpeed < regularLandingFallingSpeed;
	}

	protected export const virtual function ToRegularLand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var landingType : Int32;
		landingType = GetLandingType( stateContext );
		if( !( IsTouchingGround( scriptInterface ) ) || ( GetVerticalSpeed( scriptInterface ) > 0.0 ) )
		{
			return false;
		}
		if( landingType <= ( ( Int32 )( LandingType.Regular ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToHardLand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var landingType : Int32;
		if( !( IsTouchingGround( scriptInterface ) ) || ( GetVerticalSpeed( scriptInterface ) > 0.0 ) )
		{
			return false;
		}
		landingType = GetLandingType( stateContext );
		if( landingType == ( ( Int32 )( LandingType.Hard ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToVeryHardLand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var landingType : Int32;
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		landingType = GetLandingType( stateContext );
		if( landingType == ( ( Int32 )( LandingType.VeryHard ) ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToSuperheroLand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var landingType : Int32;
		landingType = GetLandingType( stateContext );
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		if( landingType == ( ( Int32 )( LandingType.Superhero ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToDeathLand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var landingType : Int32;
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		landingType = GetLandingType( stateContext );
		if( landingType == ( ( Int32 )( LandingType.Death ) ) )
		{
			return true;
		}
		return false;
	}

}

abstract class LocomotionAirEvents extends LocomotionEventsTransition
{
	var m_maxSuperheroFallHeight : Bool;
	default m_maxSuperheroFallHeight = false;
	var m_updateInputToggles : Bool;
	default m_updateInputToggles = true;
	var m_resetFallingParametersOnExit : Bool;
	default m_resetFallingParametersOnExit = false;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var regularLandingFallingSpeed : Float;
		var safeLandingFallingSpeed : Float;
		var hardLandingFallingSpeed : Float;
		var veryHardLandingFallingSpeed : Float;
		var deathLandingFallingSpeed : Float;
		var animFeature : AnimFeature_PlayerLocomotionStateMachine;
		super.OnEnter( stateContext, scriptInterface );
		regularLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "regularLandingHeight", 0.1 ) );
		safeLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "safeLandingHeight", 0.1 ) );
		hardLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "hardLandingHeight", 1.0 ) );
		veryHardLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "veryHardLandingHeight", 1.0 ) );
		deathLandingFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "deathLanding", 1.0 ) );
		stateContext.SetPermanentFloatParameter( 'RegularLandingFallingSpeed', regularLandingFallingSpeed, true );
		stateContext.SetPermanentFloatParameter( 'SafeLandingFallingSpeed', safeLandingFallingSpeed, true );
		stateContext.SetPermanentFloatParameter( 'HardLandingFallingSpeed', hardLandingFallingSpeed, true );
		stateContext.SetPermanentFloatParameter( 'VeryHardLandingFallingSpeed', veryHardLandingFallingSpeed, true );
		stateContext.SetPermanentFloatParameter( 'DeathLandingFallingSpeed', deathLandingFallingSpeed, true );
		animFeature = new AnimFeature_PlayerLocomotionStateMachine;
		animFeature.inAirState = true;
		scriptInterface.SetAnimationParameterFeature( 'LocomotionStateMachine', animFeature );
		scriptInterface.PushAnimationEvent( 'InAir' );
		scriptInterface.GetTargetingSystem().SetIsMovingFast( scriptInterface.owner, true );
		m_maxSuperheroFallHeight = false;
		m_resetFallingParametersOnExit = false;
	}

	protected export override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var verticalSpeed : Float;
		var horizontalSpeed : Float;
		var playerVelocity : Vector4;
		var regularLandingFallingSpeed : Float;
		var safeLandingFallingSpeed : Float;
		var hardLandingFallingSpeed : Float;
		var veryHardLandingFallingSpeed : Float;
		var deathLandingFallingSpeed : Float;
		var isInSuperheroFall : Bool;
		var maxAllowedDistanceToGround : Float;
		var landingType : LandingType;
		var landingAnimFeature : AnimFeature_Landing;
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		if( IsTouchingGround( scriptInterface ) )
		{
			m_resetFallingParametersOnExit = true;
			return;
		}
		m_resetFallingParametersOnExit = false;
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		if( m_updateInputToggles && ( verticalSpeed < GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "minFallHeightToConsiderInputToggles", 0.0 ) ) ) )
		{
			UpdateInputToggles( stateContext, scriptInterface );
		}
		if( scriptInterface.IsActionJustPressed( 'Jump' ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
			return;
		}
		if( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.BerserkPlayerBuff" ) && ( verticalSpeed < GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "minFallHeightToEnterSuperheroFall", 0.0 ) ) ) )
		{
			stateContext.SetTemporaryBoolParameter( 'requestSuperheroLandActivation', true, true );
		}
		regularLandingFallingSpeed = stateContext.GetFloatParameter( 'RegularLandingFallingSpeed', true );
		safeLandingFallingSpeed = stateContext.GetFloatParameter( 'SafeLandingFallingSpeed', true );
		hardLandingFallingSpeed = stateContext.GetFloatParameter( 'HardLandingFallingSpeed', true );
		veryHardLandingFallingSpeed = stateContext.GetFloatParameter( 'VeryHardLandingFallingSpeed', true );
		deathLandingFallingSpeed = stateContext.GetFloatParameter( 'DeathLandingFallingSpeed', true );
		isInSuperheroFall = stateContext.IsStateActive( 'Locomotion', 'superheroFall' );
		maxAllowedDistanceToGround = GetStaticFloatParameterDefault( "maxDistToGroundFromSuperheroFall", 20.0 );
		if( isInSuperheroFall && !( m_maxSuperheroFallHeight ) )
		{
			StartEffect( scriptInterface, 'falling' );
			PlaySound( 'lcm_falling_wind_loop', scriptInterface );
			if( GetDistanceToGround( scriptInterface ) >= maxAllowedDistanceToGround )
			{
				m_maxSuperheroFallHeight = true;
				return;
			}
			else
			{
				landingType = LandingType.Superhero;
			}
		}
		else if( ( verticalSpeed <= deathLandingFallingSpeed ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap ) ) )
		{
			landingType = LandingType.Death;
			SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.DeathFall ) ) );
		}
		else if( ( verticalSpeed <= veryHardLandingFallingSpeed ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap ) ) )
		{
			landingType = LandingType.VeryHard;
			SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.VeryFastFall ) ) );
		}
		else if( verticalSpeed <= hardLandingFallingSpeed )
		{
			landingType = LandingType.Hard;
			if( GetLandingType( stateContext ) != ( ( Int32 )( LandingType.Hard ) ) )
			{
				StartEffect( scriptInterface, 'falling' );
			}
			SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.FastFall ) ) );
		}
		else if( verticalSpeed <= safeLandingFallingSpeed )
		{
			landingType = LandingType.Regular;
			SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.RegularFall ) ) );
			playerVelocity = GetLinearVelocity( scriptInterface );
			horizontalSpeed = Vector4.Length2D( playerVelocity );
			if( horizontalSpeed <= GetStaticFloatParameterDefault( "maxHorizontalSpeedToAerialTakedown", 0.0 ) )
			{
				SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, ( ( Int32 )( gamePSMFallStates.SafeFall ) ) );
			}
		}
		else if( verticalSpeed <= regularLandingFallingSpeed )
		{
			if( GetLandingType( stateContext ) != ( ( Int32 )( LandingType.Regular ) ) )
			{
				PlaySound( 'lcm_falling_wind_loop', scriptInterface );
			}
			landingType = LandingType.Regular;
		}
		else
		{
			landingType = LandingType.Off;
		}
		stateContext.SetPermanentIntParameter( 'LandingType', ( ( Int32 )( landingType ) ), true );
		stateContext.SetPermanentFloatParameter( 'ImpactSpeed', verticalSpeed, true );
		stateContext.SetPermanentFloatParameter( 'InAirDuration', GetInStateTime(), true );
		landingAnimFeature = new AnimFeature_Landing;
		landingAnimFeature.impactSpeed = verticalSpeed;
		landingAnimFeature.type = ( ( Int32 )( landingType ) );
		scriptInterface.SetAnimationParameterFeature( 'Landing', landingAnimFeature );
		SetAudioParameter( 'RTPC_Vertical_Velocity', verticalSpeed, scriptInterface );
		SetAudioParameter( 'RTPC_Landing_Type', ( ( Float )( ( ( Int32 )( landingType ) ) ) ), scriptInterface );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( m_resetFallingParametersOnExit )
		{
			ResetFallingParameters( stateContext );
		}
		super.OnExit( stateContext, scriptInterface );
		StopEffect( scriptInterface, 'falling' );
		PlaySound( 'lcm_falling_wind_loop_end', scriptInterface );
		scriptInterface.GetTargetingSystem().SetIsMovingFast( scriptInterface.owner, false );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( m_resetFallingParametersOnExit )
		{
			ResetFallingParameters( stateContext );
		}
		super.OnForcedExit( stateContext, scriptInterface );
	}

	protected function OnExitToRegularLand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_resetFallingParametersOnExit = false;
		OnExit( stateContext, scriptInterface );
	}

	protected function OnExitToHardLand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_resetFallingParametersOnExit = false;
		OnExit( stateContext, scriptInterface );
	}

	protected function OnExitToVeryHardLand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_resetFallingParametersOnExit = false;
		OnExit( stateContext, scriptInterface );
	}

	protected function OnExitToSuperheroLand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_resetFallingParametersOnExit = false;
		OnExit( stateContext, scriptInterface );
	}

	protected function OnExitToDeathLand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_resetFallingParametersOnExit = false;
		OnExit( stateContext, scriptInterface );
	}

	protected function OnExitToUnsecureFootingFall( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		switch( ( ( LandingType )( GetLandingType( stateContext ) ) ) )
		{
			case LandingType.Hard:
				PlayHardLandingEffects( stateContext, scriptInterface );
			break;
			case LandingType.VeryHard:
				PlayVeryHardLandingEffects( stateContext, scriptInterface );
			break;
			case LandingType.Death:
				PlayDeathLandingEffects( stateContext, scriptInterface );
			break;
		}
		OnExit( stateContext, scriptInterface );
	}

}

abstract class AbstractLandDecisions extends LocomotionGroundDecisions
{
}

abstract class AbstractLandEvents extends LocomotionGroundEvents
{
	var m_blockLandingStimBroadcasting : Bool;
	default m_blockLandingStimBroadcasting = false;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var collisionReport : array< ControllerHit >;
		var hit : ControllerHit;
		var playerPositionCentreOfSphere : Vector4;
		var up : Vector4;
		var bottomCollisionFound : Bool;
		var bottomCollisionNormal : Vector4;
		var playerPosition : Vector4;
		var touchNormal : Vector4;
		var collisionIndex : Int32;
		var capsuleRadius : Float;
		up = GetUpVector();
		super.OnEnter( stateContext, scriptInterface );
		SetAudioParameter( 'RTPC_Landing_Type', 0.0, scriptInterface );
		scriptInterface.PushAnimationEvent( 'Land' );
		capsuleRadius = ( ( Float )( scriptInterface.GetStateVectorParameter( physicsStateValue.Radius ) ) );
		playerPosition = GetPlayerPosition( scriptInterface );
		collisionReport = scriptInterface.GetCollisionReport();
		playerPositionCentreOfSphere = playerPosition + ( up * capsuleRadius );
		bottomCollisionFound = false;
		for( collisionIndex = 0; ( collisionIndex < collisionReport.Size() ) && !( bottomCollisionFound ); collisionIndex += 1 )
		{
			hit = collisionReport[ collisionIndex ];
			touchNormal = Vector4.Normalize( playerPositionCentreOfSphere - hit.worldPos );
			if( ( touchNormal.Z > 0.0 ) && ( bottomCollisionNormal.Z < touchNormal.Z ) )
			{
				bottomCollisionNormal = touchNormal;
				if( bottomCollisionNormal.Z < 1.0 )
				{
					bottomCollisionFound = true;
				}
			}
		}
		ResetFallingParameters( stateContext );
	}

	protected function BroadcastLandingStim( stateContext : StateContext, scriptInterface : StateGameScriptInterface, stimType : gamedataStimType )
	{
		var broadcastLandingStim : Bool;
		var impactSpeed : StateResultFloat;
		var speedThresholdToSendStim : Float;
		var broadcaster : StimBroadcasterComponent;
		broadcastLandingStim = scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.CanLandSilently ) < 1.0;
		if( !( broadcastLandingStim ) || m_blockLandingStimBroadcasting )
		{
			m_blockLandingStimBroadcasting = false;
			return;
		}
		if( LocomotionGroundDecisions.CheckCrouchEnterCondition( stateContext, scriptInterface ) && stimType == gamedataStimType.LandingRegular )
		{
			return;
		}
		else
		{
			impactSpeed = stateContext.GetPermanentFloatParameter( 'ImpactSpeed' );
			speedThresholdToSendStim = GetFallingSpeedBasedOnHeight( scriptInterface, 1.20000005 );
			if( impactSpeed.value < speedThresholdToSendStim )
			{
				broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
				if( broadcaster )
				{
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, stimType );
				}
			}
		}
	}

	protected function EvaluatePlayingLandingVFX( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impactSpeed : StateResultFloat;
		var minFallSpeed : Float;
		impactSpeed = stateContext.GetPermanentFloatParameter( 'ImpactSpeed' );
		minFallSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, 2.0 );
		if( impactSpeed.value < minFallSpeed )
		{
			StartEffect( scriptInterface, 'landing_regular' );
		}
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.Default ) ) );
	}

}

class ClimbEvents extends LocomotionGroundEvents
{
	var m_ikHandEvents : array< IKTargetAddEvent >;
	var m_shouldIkHands : Bool;
	var m_framesDelayingAnimStart : Int32;
	var m_climbedEntity : weak< Entity >;
	var m_playerCapsuleDimensions : Vector4;

	private function GetClimbParameter( scriptInterface : StateGameScriptInterface ) : ClimbParameters
	{
		var directionOffset : Vector4;
		var climbInfo : PlayerClimbInfo;
		var climbParameters : ClimbParameters;
		var playerPosition : Vector4;
		var direction : Vector4;
		var statSystem : StatsSystem;
		var obstacleHeight : Float;
		var climbTypeKey : String;
		var climbSpeed : Float;
		climbParameters = new ClimbParameters;
		statSystem = scriptInterface.GetStatsSystem();
		direction = scriptInterface.GetOwnerForward();
		directionOffset = direction * GetStaticFloatParameterDefault( "capsuleRadius", 0.0 );
		climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo( scriptInterface.owner );
		playerPosition = GetPlayerPosition( scriptInterface );
		climbParameters.SetObstacleFrontEdgePosition( climbInfo.descResult.topPoint );
		climbParameters.SetObstacleFrontEdgeNormal( climbInfo.descResult.collisionNormal );
		climbParameters.SetObstacleVerticalDestination( climbInfo.descResult.topPoint - directionOffset );
		climbParameters.SetObstacleSurfaceNormal( climbInfo.descResult.topNormal );
		climbParameters.SetObstacleHorizontalDestination( climbInfo.descResult.topPoint + ( direction * GetStaticFloatParameterDefault( "forwardStep", 0.5 ) ) );
		m_climbedEntity = climbInfo.descResult.climbedEntity;
		climbParameters.SetClimbedEntity( m_climbedEntity );
		obstacleHeight = climbInfo.descResult.topPoint.Z - playerPosition.Z;
		if( obstacleHeight > GetStaticFloatParameterDefault( "highThreshold", 1.0 ) )
		{
			climbParameters.SetClimbType( 0 );
			climbTypeKey = "High";
			m_shouldIkHands = true;
		}
		else if( obstacleHeight > GetStaticFloatParameterDefault( "midThreshold", 1.0 ) )
		{
			climbParameters.SetClimbType( 1 );
			climbTypeKey = "Mid";
			m_shouldIkHands = true;
		}
		else
		{
			climbParameters.SetClimbType( 2 );
			climbTypeKey = "Low";
			m_shouldIkHands = false;
		}
		climbSpeed = GetStatFloatValue( scriptInterface, gamedataStatType.ClimbSpeedModifier, statSystem );
		if( climbSpeed <= 0.0 )
		{
			climbSpeed = 1.0;
		}
		climbParameters.SetHorizontalDuration( climbSpeed * GetStaticFloatParameterDefault( "horizontalDuration" + climbTypeKey, 10.0 ) );
		climbParameters.SetVerticalDuration( climbSpeed * GetStaticFloatParameterDefault( "verticalDuration" + climbTypeKey, 10.0 ) );
		climbParameters.SetAnimationNameApproach( GetStaticCNameParameterDefault( "animationNameApproach", '' ) );
		return climbParameters;
	}

	private function CreateIKConstraint( scriptInterface : StateGameScriptInterface, const handData : HandIKDescriptionResult, const refUpVector : Vector4, const ikChainName : CName, climbedEntity : Entity )
	{
		var ikEvent : IKTargetAddEvent;
		var edgeSlop : Vector4;
		var handOrientation : Matrix;
		var handNormal : Vector4;
		var climbedEntityTransform : Transform;
		ikEvent = new IKTargetAddEvent;
		edgeSlop = handData.grabPointStart - handData.grabPointEnd;
		handNormal = Vector4.Cross( edgeSlop, refUpVector );
		handNormal = Vector4.Normalize( handNormal );
		handNormal.Z = 0.30000001;
		handNormal = Vector4.Normalize( handNormal );
		handOrientation = Matrix.BuildFromDirectionVector( handNormal, edgeSlop );
		if( climbedEntity )
		{
			climbedEntityTransform = WorldTransform._ToXForm( climbedEntity.GetWorldTransform() );
			ikEvent.targetPositionProvider = IPositionProvider.CreateEntityPositionProvider( climbedEntity, ( ( Vector3 )( Transform.TransformPoint( Transform.GetInverse( climbedEntityTransform ), handData.grabPointEnd + ( edgeSlop * 0.5 ) ) ) ) );
			ikEvent.orientationProvider = IOrientationProvider.CreateEntityOrientationProvider( NULL, '', climbedEntity, Quaternion.Conjugate( Transform.GetOrientation( climbedEntityTransform ) ) * Matrix.ToQuat( handOrientation ) );
		}
		else
		{
			ikEvent.SetStaticTarget( handData.grabPointEnd + ( edgeSlop * 0.5 ) );
			ikEvent.SetStaticOrientationTarget( Matrix.ToQuat( handOrientation ) );
		}
		ikEvent.request.transitionIn = 0.0;
		ikEvent.request.priority = -100;
		ikEvent.bodyPart = ikChainName;
		scriptInterface.owner.QueueEvent( ikEvent );
		m_ikHandEvents.PushBack( ikEvent );
	}

	private function AddHandIK( scriptInterface : StateGameScriptInterface )
	{
		var climbInfo : PlayerClimbInfo;
		climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo( scriptInterface.owner );
		CreateIKConstraint( scriptInterface, climbInfo.descResult.leftHandData, Vector4( 0.0, 0.0, 1.0, 0.0 ), 'ikLeftArm', m_climbedEntity );
		CreateIKConstraint( scriptInterface, climbInfo.descResult.rightHandData, Vector4( 0.0, 0.0, -1.0, 0.0 ), 'ikRightArm', m_climbedEntity );
	}

	private function RemoveHandIK( scriptInterface : StateGameScriptInterface )
	{
		var ikEvent : IKTargetAddEvent;
		var i : Int32;
		for( i = 0; i < m_ikHandEvents.Size(); i += 1 )
		{
			ikEvent = m_ikHandEvents[ i ];
			if( !( ikEvent ) )
			{
				continue;
			}
			IKTargetRemoveEvent.QueueRemoveIkTargetRemoveEvent( scriptInterface.owner, ikEvent );
		}
		m_ikHandEvents.Clear();
	}

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		GameObject.PlayVoiceOver( scriptInterface.owner, 'climbStart', 'Scripts:ClimbEvents' );
		stateContext.SetTemporaryScriptableParameter( 'climbInfo', GetClimbParameter( scriptInterface ), true );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Climb );
		PlayRumble( scriptInterface, "light_fast" );
		m_framesDelayingAnimStart = 0;
		m_playerCapsuleDimensions.X = GetStaticFloatParameterDefault( "capsuleRadius", 0.40000001 );
		m_playerCapsuleDimensions.Y = ( GetStaticFloatParameterDefault( "capsuleHeight", 1.0 ) * 0.5 ) - m_playerCapsuleDimensions.X;
		m_playerCapsuleDimensions.Z = -1.0;
	}

	public override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var playerPosition : Vector4;
		var tolerance : Float;
		var capsuleOrientation : EulerAngles;
		var fitTestOverlap : TraceResult;
		var hitDetected : Bool;
		var knockdownStatusEffect : weak< StatusEffect_Record >;
		tolerance = 0.15000001;
		if( m_climbedEntity )
		{
			playerPosition = scriptInterface.owner.GetWorldPosition();
			playerPosition.Z += ( ( m_playerCapsuleDimensions.X + m_playerCapsuleDimensions.Y ) + tolerance );
			capsuleOrientation.Roll = 90.0;
			hitDetected = scriptInterface.LocomotionOverlapTestExcludeEntity( m_playerCapsuleDimensions, playerPosition, capsuleOrientation, m_climbedEntity, fitTestOverlap );
			if( hitDetected && TraceResult.IsValid( fitTestOverlap ) )
			{
				knockdownStatusEffect = TweakDBInterface.GetStatusEffectRecord( T"BaseStatusEffect.ClimbingKnockdown" );
				scriptInterface.GetStatusEffectSystem().ApplyStatusEffect( scriptInterface.owner.GetEntityID(), T"BaseStatusEffect.ClimbingKnockdown", , ,  );
				stateContext.SetPermanentScriptableParameter( StatusEffectHelper.GetForceKnockdownKey(), knockdownStatusEffect, true );
			}
		}
		m_framesDelayingAnimStart = m_framesDelayingAnimStart + 1;
		if( m_framesDelayingAnimStart == 3 )
		{
			scriptInterface.SetAnimationParameterFeature( 'PreClimb', ( ( AnimFeature_PreClimbing )( stateContext.GetConditionScriptableParameter( 'PreClimbAnimFeature' ) ) ) );
			stateContext.RemoveConditionScriptableParameter( 'PreClimbAnimFeature' );
			if( m_shouldIkHands )
			{
				AddHandIK( scriptInterface );
			}
		}
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		RemoveHandIK( scriptInterface );
		m_climbedEntity = NULL;
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		RemoveHandIK( scriptInterface );
		m_climbedEntity = NULL;
	}

}

class LadderEvents extends LocomotionGroundEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var locomotionState : CName;
		locomotionState = stateContext.GetStateMachineCurrentState( 'Locomotion' );
		if( locomotionState != 'ladderSprint' && locomotionState != 'ladderSlide' )
		{
			super.OnEnter( stateContext, scriptInterface );
			SetLadderEntryDuration( stateContext, scriptInterface );
			UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.Enter );
		}
		SetLocomotionParameters( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Ladder );
	}

	public function OnEnterFromJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 1 );
		OnEnter( stateContext, scriptInterface );
	}

	public function OnEnterFromDoubleJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 2 );
		OnEnter( stateContext, scriptInterface );
	}

	public function OnEnterFromChargeJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 3 );
		OnEnter( stateContext, scriptInterface );
	}

	public function OnEnterFromDodgeAir( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 4 );
		OnEnter( stateContext, scriptInterface );
	}

	public function OnEnterFromFall( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 5 );
		OnEnter( stateContext, scriptInterface );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var detailedLocomotionState : Int32;
		var ladderEntryDuration : StateResultFloat;
		var ladderCameraParams : LadderCameraParams;
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		detailedLocomotionState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed );
		if( detailedLocomotionState == ( ( Int32 )( gamePSMDetailedLocomotionStates.LadderJump ) ) )
		{
			return;
		}
		ladderEntryDuration = stateContext.GetPermanentFloatParameter( 'ladderEntryDuration' );
		if( ladderEntryDuration.valid )
		{
			if( GetInStateTime() > ladderEntryDuration.value )
			{
				stateContext.RemovePermanentFloatParameter( 'ladderEntryDuration' );
				UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.Default );
			}
		}
		else
		{
			ladderCameraParams = ( ( LadderCameraParams )( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LadderCameraParams ) ) );
			if( IsPlayerAboveLadderTop( stateContext, scriptInterface ) )
			{
				UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.Exit );
			}
			else if( ladderCameraParams == LadderCameraParams.CameraReset )
			{
				if( IsPlayerLookingDirectlyAtLadder( stateContext, scriptInterface ) )
				{
					UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.Default );
				}
			}
			else if( ladderCameraParams == LadderCameraParams.Default )
			{
				if( ShouldResetCamera( stateContext, scriptInterface ) )
				{
					UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.CameraReset );
				}
			}
		}
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel ) == ( ( Int32 )( gamePSMHighLevel.Swimming ) ) )
		{
			return;
		}
		CleanUpLadderState( stateContext, scriptInterface );
		super.OnForcedExit( stateContext, scriptInterface );
	}

	protected export function OnExitToStand( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var direction : Vector4;
		var impulse : Vector4;
		impulse = direction * GetStaticFloatParameterDefault( "exitToStandPushMagnitude", 3.0 );
		super.OnExit( stateContext, scriptInterface );
		AddImpulse( stateContext, impulse );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	protected function OnExitToLadderSprint( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}

	protected function OnExitToLadderSlide( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}

	protected function OnExitToLadderJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	protected function OnExitToLadderCrouch( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	protected function OnExitToKnockdown( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	protected function OnExitToStunned( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpLadderState( stateContext, scriptInterface );
	}

	private const function SendLadderEnterStyleToGraph( scriptInterface : StateGameScriptInterface, enterStyle : Int32 )
	{
		var animFeature : AnimFeature_LadderEnterStyleData;
		animFeature = new AnimFeature_LadderEnterStyleData;
		animFeature.enterStyle = enterStyle;
		scriptInterface.SetAnimationParameterFeature( 'LadderEnterStyleData', animFeature );
	}

	private const function SetLadderEntryDuration( stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var isActionEnterLadder : StateResultBool;
		var ladderEntryDuration : Float;
		isActionEnterLadder = stateContext.GetTemporaryBoolParameter( 'actionEnterLadder' );
		if( ( isActionEnterLadder.valid && isActionEnterLadder.value ) || IsPlayerAboveLadderTop( stateContext, scriptInterface ) )
		{
			ladderEntryDuration = GetStaticFloatParameterDefault( "ladderEntryDurationFromTop", 0.0 );
		}
		else
		{
			ladderEntryDuration = GetStaticFloatParameterDefault( "ladderEntryDuration", 0.0 );
		}
		stateContext.SetPermanentFloatParameter( 'ladderEntryDuration', ladderEntryDuration, true );
	}

	private function CleanUpLadderState( stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		SendLadderEnterStyleToGraph( scriptInterface, 0 );
		UseLadderCameraParams( stateContext, scriptInterface, LadderCameraParams.None );
		stateContext.RemovePermanentFloatParameter( 'ladderEntryDuration' );
		stateContext.RemoveConditionScriptableParameter( 'usingLadder' );
	}

	private const function IsPlayerAboveLadderTop( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ladderParameter : LadderDescription;
		var playerPosition : Vector4;
		var ladderTopPosition : Vector4;
		ladderParameter = ( ( LadderDescription )( stateContext.GetConditionScriptableParameter( 'usingLadder' ) ) );
		playerPosition = GetPlayerPosition( scriptInterface );
		ladderTopPosition = ladderParameter.position + ( ladderParameter.up * ladderParameter.topHeightFromPosition );
		if( playerPosition.Z < ladderTopPosition.Z )
		{
			return false;
		}
		return true;
	}

	private const function IsPlayerLookingDirectlyAtLadder( stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ladderNormalXY : Vector4;
		var cameraForwardXY : Vector4;
		var cameraToLadderAngle : Float;
		ladderNormalXY = ( ( LadderDescription )( stateContext.GetConditionScriptableParameter( 'usingLadder' ) ) ).normal;
		ladderNormalXY.Z = 0.0;
		Vector4.Normalize( ladderNormalXY );
		cameraForwardXY = Transform.GetForward( scriptInterface.GetCameraWorldTransform() );
		cameraForwardXY.Z = 0.0;
		Vector4.Normalize( cameraForwardXY );
		cameraToLadderAngle = Rad2Deg( AcosF( Vector4.Dot( cameraForwardXY, ladderNormalXY ) ) );
		if( ( 180.0 - cameraToLadderAngle ) > 2.0 )
		{
			return false;
		}
		return true;
	}

	private function UseLadderCameraParams( stateContext : StateContext, const scriptInterface : StateGameScriptInterface, const params : LadderCameraParams )
	{
		var paramsName : CName;
		var ladderCameraParams : LadderCameraParams;
		paramsName = '';
		ladderCameraParams = ( ( LadderCameraParams )( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LadderCameraParams ) ) );
		if( ladderCameraParams == params )
		{
			return;
		}
		switch( params )
		{
			case LadderCameraParams.Enter:
				paramsName = 'LadderEnter';
			break;
			case LadderCameraParams.Default:
				paramsName = 'LadderDefault';
			break;
			case LadderCameraParams.CameraReset:
				paramsName = 'LadderCameraReset';
			break;
			case LadderCameraParams.Exit:
				paramsName = 'LadderExit';
			break;
		}
		stateContext.SetPermanentCNameParameter( 'LadderCameraParams', paramsName, true );
		scriptInterface.localBlackboard.SetInt( GetAllBlackboardDefs().PlayerStateMachine.LadderCameraParams, ( ( Int32 )( params ) ) );
		UpdateCameraParams( stateContext, scriptInterface );
	}

	private const function ShouldResetCamera( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var geometryDescription : GeometryDescriptionQuery;
		var staticQueryFilter : QueryFilter;
		var geometryDescriptionResult : GeometryDescriptionResult;
		var cameraWorldTransform : Transform;
		if( !( scriptInterface.IsMoveInputConsiderable() ) )
		{
			return false;
		}
		if( GetMovementInputActionValue( stateContext, scriptInterface ) < GetStaticFloatParameterDefault( "minStickInputToSwapToClimbCamera", 0.0 ) )
		{
			return false;
		}
		if( AbsF( GetVerticalSpeed( scriptInterface ) ) <= 0.01 )
		{
			return false;
		}
		cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
		QueryFilter.AddGroup( staticQueryFilter, 'Interaction' );
		geometryDescription = new GeometryDescriptionQuery;
		geometryDescription.refPosition = Transform.GetPosition( cameraWorldTransform );
		geometryDescription.refDirection = Transform.GetForward( cameraWorldTransform );
		geometryDescription.filter = staticQueryFilter;
		geometryDescription.primitiveDimension = Vector4( 0.1, 0.1, 0.1, 0.0 );
		geometryDescription.maxDistance = 2.0;
		geometryDescription.maxExtent = 0.5;
		geometryDescription.probingPrecision = 0.05;
		geometryDescription.probingMaxDistanceDiff = 2.0;
		geometryDescription.AddFlag( worldgeometryDescriptionQueryFlags.DistanceVector );
		geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents( geometryDescription );
		if( geometryDescriptionResult.queryStatus != worldgeometryDescriptionQueryStatus.NoGeometry )
		{
			return false;
		}
		return true;
	}

}

class FallDecisions extends LocomotionAirDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var shouldFall : Bool;
		shouldFall = ShouldFall( stateContext, scriptInterface );
		if( shouldFall )
		{
			scriptInterface.GetAudioSystem().NotifyGameTone( 'StartFalling' );
		}
		return shouldFall;
	}

}

class FallEvents extends LocomotionAirEvents
{

	public function OnEnterFromDodgeAir( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetPermanentBoolParameter( 'enteredFallFromAirDodge', true, true );
		OnEnter( stateContext, scriptInterface );
	}

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		PlaySound( 'lcm_falling_wind_loop', scriptInterface );
		scriptInterface.PushAnimationEvent( 'Fall' );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Fall );
	}

}

class ForceIdleDecisions extends LocomotionGroundDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsIdleForced( stateContext ) || scriptInterface.IsSceneAnimationActive();
	}

	protected export const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var mountingInfo : MountingInfo;
		mountingInfo = scriptInterface.GetMountingInfo( scriptInterface.executionOwner );
		return ( ( !( IsIdleForced( stateContext ) ) && !( scriptInterface.IsSceneAnimationActive() ) ) && !( IMountingFacility.InfoIsComplete( mountingInfo ) ) ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice ) );
	}

}

class ForceIdleEvents extends LocomotionGroundEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.AverageNormal );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal );
	}

}

class WorkspotDecisions extends LocomotionGroundDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsInWorkspot( scriptInterface );
	}

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsInWorkspot( scriptInterface ) ) || IsInMinigame( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected constexpr const function ToCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	protected constexpr export const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

}

class WorkspotEvents extends LocomotionGroundEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( GetPlayerPuppet( scriptInterface ).HasWorkspotTag( 'DisableCameraControl' ) )
		{
			SetWorkspotAnimFeature( scriptInterface );
		}
		if( GetPlayerPuppet( scriptInterface ).HasWorkspotTag( 'Grab' ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		}
		stateContext.SetTemporaryBoolParameter( 'requestSandevistanDeactivation', true, true );
		super.OnEnter( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, ( ( Int32 )( gamePSMWorkspotState.Workspot ) ) );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Workspot ) ) );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, ( ( Int32 )( gamePSMWorkspotState.Default ) ) );
		ResetWorkspotAnimFeature( scriptInterface );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal );
	}

	public export override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, ( ( Int32 )( gamePSMWorkspotState.Default ) ) );
		ResetWorkspotAnimFeature( scriptInterface );
	}

	protected function SetWorkspotAnimFeature( scriptInterface : StateGameScriptInterface )
	{
		var animFeature : AnimFeature_AerialTakedown;
		animFeature = new AnimFeature_AerialTakedown;
		animFeature.state = 1;
		scriptInterface.SetAnimationParameterFeature( 'AerialTakedown', animFeature );
	}

	protected function ResetWorkspotAnimFeature( scriptInterface : StateGameScriptInterface )
	{
		var animFeature : AnimFeature_AerialTakedown;
		animFeature = new AnimFeature_AerialTakedown;
		animFeature.state = 0;
		scriptInterface.SetAnimationParameterFeature( 'AerialTakedown', animFeature );
	}

}

class ForceWalkDecisions extends LocomotionGroundDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsWalkForced( stateContext );
	}

	protected const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( IsWalkForced( stateContext ) );
	}

}

class ForceWalkEvents extends LocomotionGroundEvents
{
	var m_storedSpeedValue : Float;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
		ProcessPermanentBoolParameterToggle( 'WalkToggled', false, stateContext );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
	}

}

class ForceFreezeDecisions extends LocomotionGroundDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsFreezeForced( stateContext );
	}

	protected const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( IsFreezeForced( stateContext ) );
	}

	protected const function ToWorkspot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( IsInMinigame( scriptInterface ) ) && IsInWorkspot( scriptInterface );
	}

}

class ForceFreezeEvents extends LocomotionGroundEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner( scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal );
	}

}

class InitialDecisions extends LocomotionGroundDecisions
{

	protected constexpr const function ToCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

}

class StandDecisions extends LocomotionGroundDecisions
{

	public const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsTouchingGround( scriptInterface ) && ( GetVerticalSpeed( scriptInterface ) <= 0.5 );
	}

}

class StandEvents extends LocomotionGroundEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.PushAnimationEvent( 'StandEnter' );
		stateContext.SetConditionBoolParameter( 'blockEnteringSlide', false, true );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
		PlaySound( 'lcm_falling_wind_loop_end', scriptInterface );
		super.OnEnter( stateContext, scriptInterface );
		if( stateContext.GetBoolParameter( 'WalkToggled', true ) && !( stateContext.GetBoolParameter( 'ForceDisableToggleWalk', true ) ) )
		{
			SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Crouch );
			SetModifierGroupForState( scriptInterface, "PlayerLocomotion.player_locomotion_data_Crouch" );
		}
		else
		{
			SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
		}
	}

	[ profile = "" ]
	protected export function OnTick( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var playerSpeed : Float;
		var footstepStimuliSpeedThreshold : Float;
		if( IsTouchingGround( scriptInterface ) )
		{
			playerSpeed = scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed );
			footstepStimuliSpeedThreshold = GetStaticFloatParameterDefault( "footstepStimuliSpeedThreshold", 2.5 );
			if( playerSpeed > footstepStimuliSpeedThreshold )
			{
				BroadcastStimuliFootstepRegular( scriptInterface );
			}
		}
		if( stateContext.GetBoolParameter( 'ForceDisableToggleWalk', true ) )
		{
			SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
			SetModifierGroupForState( scriptInterface, "PlayerLocomotion.player_locomotion_data_Stand" );
			ProcessPermanentBoolParameterToggle( 'WalkToggled', false, stateContext );
			stateContext.RemovePermanentBoolParameter( 'ForceDisableToggleWalk' );
			stateContext.RemovePermanentBoolParameter( 'ToggleWalkInputRegistered' );
		}
		else if( stateContext.GetBoolParameter( 'ToggleWalkInputRegistered', true ) )
		{
			if( stateContext.GetBoolParameter( 'WalkToggled', true ) )
			{
				SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Stand );
				SetModifierGroupForState( scriptInterface, "PlayerLocomotion.player_locomotion_data_Stand" );
				ProcessPermanentBoolParameterToggle( 'WalkToggled', false, stateContext );
			}
			else
			{
				SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Crouch );
				SetModifierGroupForState( scriptInterface, "PlayerLocomotion.player_locomotion_data_Crouch" );
				ProcessPermanentBoolParameterToggle( 'WalkToggled', true, stateContext );
			}
			stateContext.RemovePermanentBoolParameter( 'ToggleWalkInputRegistered' );
		}
	}

}

class AimWalkDecisions extends LocomotionGroundDecisions
{
	var m_callbackIDs : array< CallbackHandle >;
	private var m_isBlocking : Bool;
	private var m_isAiming : Bool;
	private var m_inFocusMode : Bool;
	private var m_isLeftHandChanging : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		super.OnAttach( stateContext, scriptInterface );
		if( scriptInterface.localBlackboard )
		{
			allBlackboardDef = GetAllBlackboardDefs();
			m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Melee, this, 'OnMeleeChanged', true ) );
			m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.UpperBody, this, 'OnUpperBodyChanged', true ) );
			m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vision, this, 'OnVisionChanged', true ) );
			m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.LeftHandCyberware, this, 'OnLeftHandCyberwareChanged', true ) );
		}
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callbackIDs.Clear();
	}

	protected function UpdateEnterConditionEnabled()
	{
		EnableOnEnterCondition( ( ( m_isBlocking || m_isAiming ) || m_inFocusMode ) || m_isLeftHandChanging );
	}

	protected event OnMeleeChanged( value : Int32 )
	{
		m_isBlocking = value == ( ( Int32 )( gamePSMMelee.Block ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnUpperBodyChanged( value : Int32 )
	{
		m_isAiming = value == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnVisionChanged( value : Int32 )
	{
		m_inFocusMode = value == ( ( Int32 )( gamePSMVision.Focus ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnLeftHandCyberwareChanged( value : Int32 )
	{
		m_isLeftHandChanging = value == ( ( Int32 )( gamePSMLeftHandCyberware.Charge ) );
		UpdateEnterConditionEnabled();
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( m_isBlocking && HasMeleeWeaponEquipped( scriptInterface ) ) && ( scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.IsNotSlowedDuringBlock ) > 0.0 ) )
		{
			return false;
		}
		return true;
	}

	protected export const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( IsOnEnterConditionEnabled() ) || !( EnterCondition( stateContext, scriptInterface ) );
	}

}

class AimWalkEvents extends LocomotionGroundEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.AimWalk );
	}

}

class CrouchDecisions extends LocomotionGroundDecisions
{
	var m_gameplaySettings : weak< GameplaySettingsSystem >;
	var m_executionOwner : weak< GameObject >;
	var m_callbackID : CallbackHandle;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_crouchPressed : Bool;
	private var m_toggleCrouchPressed : Bool;
	private var m_forcedCrouch : Bool;
	private var m_controllingDevice : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		m_gameplaySettings = GameplaySettingsSystem.GetGameplaySettingsSystemInstance( scriptInterface.executionOwner );
		if( scriptInterface.localBlackboard )
		{
			allBlackboardDef = GetAllBlackboardDefs();
			m_callbackID = scriptInterface.localBlackboard.RegisterListenerBool( allBlackboardDef.PlayerStateMachine.IsControllingDevice, this, 'OnControllingDeviceChange' );
			OnControllingDeviceChange( scriptInterface.localBlackboard.GetBool( allBlackboardDef.PlayerStateMachine.IsControllingDevice ) );
		}
		scriptInterface.executionOwner.RegisterInputListener( this, 'Crouch' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'ToggleCrouch' );
		m_crouchPressed = scriptInterface.GetActionValue( 'Crouch' ) > 0.0;
		m_toggleCrouchPressed = scriptInterface.GetActionValue( 'ToggleCrouch' ) > 0.0;
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( scriptInterface.owner.GetEntityID(), m_statusEffectListener );
		m_executionOwner = scriptInterface.executionOwner;
		m_forcedCrouch = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'ForceCrouch' );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callbackID = NULL;
		m_statusEffectListener = NULL;
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( !( m_forcedCrouch ) )
		{
			if( statusEffect.GameplayTagsContains( 'ForceCrouch' ) )
			{
				m_forcedCrouch = true;
				EnableOnEnterCondition( true );
			}
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_forcedCrouch )
		{
			if( statusEffect.GameplayTagsContains( 'ForceCrouch' ) )
			{
				m_forcedCrouch = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'ForceCrouch' );
			}
		}
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.GetName( action ) == 'Crouch' )
		{
			m_crouchPressed = ListenerAction.GetValue( action ) > 0.0;
			if( m_crouchPressed )
			{
				EnableOnEnterCondition( true );
			}
		}
		else if( ListenerAction.GetName( action ) == 'ToggleCrouch' )
		{
			m_toggleCrouchPressed = ListenerAction.GetValue( action ) > 0.0;
			if( m_toggleCrouchPressed )
			{
				EnableOnEnterCondition( true );
			}
		}
	}

	protected event OnControllingDeviceChange( value : Bool )
	{
		m_controllingDevice = value;
	}

	protected export const override function EnterCondition( stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var superResult : Bool;
		var shouldCrouch : Bool;
		var isFFByLine : Bool;
		if( m_controllingDevice )
		{
			return true;
		}
		isFFByLine = m_gameplaySettings.GetIsFastForwardByLine();
		if( isFFByLine && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ForceStand' ) ) )
		{
			if( ( !( scriptInterface.HasStatFlag( gamedataStatType.CanCrouch ) ) || stateContext.GetBoolParameter( 'FFhintActive', true ) ) || !( scriptInterface.HasStatFlag( gamedataStatType.FFInputLock ) ) )
			{
				if( scriptInterface.IsActionJustHeld( 'ToggleCrouch' ) )
				{
					stateContext.SetConditionBoolParameter( 'CrouchToggled', true, true );
					stateContext.SetPermanentBoolParameter( 'HoldInputFastForwardLock', true, true );
					return true;
				}
				return false;
			}
		}
		superResult = super.EnterCondition( stateContext, scriptInterface ) && scriptInterface.HasStatFlag( gamedataStatType.CanCrouch );
		shouldCrouch = CrouchEnterCondition( stateContext, scriptInterface, isFFByLine ) || m_forcedCrouch;
		if( ( ( !( m_crouchPressed ) && !( m_toggleCrouchPressed ) ) && !( m_forcedCrouch ) ) && !( stateContext.GetConditionBool( 'CrouchToggled' ) ) )
		{
			EnableOnEnterCondition( false );
		}
		return ( shouldCrouch && superResult ) && IsTouchingGround( scriptInterface );
	}

	protected const virtual function ToCrouch( stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
		return true;
	}

	protected export const virtual function ToStand( stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isFFByLine : Bool;
		if( m_controllingDevice )
		{
			return false;
		}
		isFFByLine = m_gameplaySettings.GetIsFastForwardByLine();
		if( isFFByLine )
		{
			if( ( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FastForwardCrouchLock' ) || stateContext.GetBoolParameter( 'FFhintActive', true ) ) || !( scriptInterface.HasStatFlag( gamedataStatType.FFInputLock ) ) )
			{
				if( scriptInterface.IsActionJustHeld( 'ToggleCrouch' ) )
				{
					stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
					stateContext.SetPermanentBoolParameter( 'HoldInputFastForwardLock', true, true );
					return true;
				}
				return false;
			}
			if( !( scriptInterface.HasStatFlag( gamedataStatType.CanCrouch ) ) && !( stateContext.GetBoolParameter( 'FFhintActive', true ) ) )
			{
				return true;
			}
		}
		else
		{
			if( ( ( !( scriptInterface.HasStatFlag( gamedataStatType.CanCrouch ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FastForward' ) ) ) && !( stateContext.GetBoolParameter( 'FFRestriction', true ) ) ) && !( stateContext.GetBoolParameter( 'TriggerFF', true ) ) )
			{
				return true;
			}
		}
		if( CrouchExitCondition( stateContext, scriptInterface, isFFByLine ) && !( m_forcedCrouch ) )
		{
			return true;
		}
		if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ForceStand' ) )
		{
			return true;
		}
		return false;
	}

	protected export const virtual function ToSprint( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var visionToggled : StateResultBool;
		visionToggled = stateContext.GetPermanentBoolParameter( 'VisionToggled' );
		if( m_controllingDevice )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanSprint ) ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().CoverAction.coverActionStateId ) == 3 )
		{
			return false;
		}
		if( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vision ) == ( ( Int32 )( gamePSMVision.Focus ) ) ) || ( visionToggled.valid && visionToggled.value ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware ) == ( ( Int32 )( gamePSMLeftHandCyberware.Charge ) ) )
		{
			return false;
		}
		if( scriptInterface.GetActionValue( 'AttackA' ) > 0.0 )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) ) )
		{
			return false;
		}
		if( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Melee ) == ( ( Int32 )( gamePSMMelee.Block ) ) ) || IsInMeleeState( stateContext, 'meleeChargedHold' ) )
		{
			return false;
		}
		if( IsChargingWeapon( scriptInterface ) )
		{
			return false;
		}
		if( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon ) == ( ( Int32 )( gamePSMMeleeWeapon.ChargedHold ) ) ) && !( stateContext.GetBoolParameter( 'canSprintWhileCharging', true ) ) )
		{
			return false;
		}
		if( ( !( stateContext.GetConditionBool( 'SprintToggled' ) ) && scriptInterface.IsActionJustReleased( 'ToggleSprint' ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoSlide' ) ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', true, true );
		}
		if( ( ( ( scriptInterface.GetActionValue( 'Crouch' ) == 0.0 ) && ( ( ( scriptInterface.GetActionValue( 'Sprint' ) > 0.0 ) || ( scriptInterface.GetActionValue( 'ToggleSprint' ) > 0.0 ) ) || stateContext.GetConditionBool( 'SprintToggled' ) ) ) && ( scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed ) >= 1.0 ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoSlide' ) ) )
		{
			return true;
		}
		return false;
	}

}

class CrouchEvents extends LocomotionGroundEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var puppet : ScriptedPuppet;
		puppet = ( ( ScriptedPuppet )( scriptInterface.owner ) );
		if( puppet )
		{
			puppet.GetPuppetPS().SetCrouch( true );
		}
		super.OnEnter( stateContext, scriptInterface );
		if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoSlide' ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
		}
		scriptInterface.GetAudioSystem().NotifyGameTone( 'EnterCrouch' );
		scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().OnEnterCrouch( scriptInterface.owner );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Crouch ) ) );
		scriptInterface.SetAnimationParameterFloat( 'crouch', 1.0 );
		if( HasMeleeWeaponEquipped( scriptInterface ) )
		{
			scriptInterface.GetTargetingSystem().AimSnap( scriptInterface.owner );
		}
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Crouch );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var puppet : ScriptedPuppet;
		puppet = ( ( ScriptedPuppet )( scriptInterface.owner ) );
		if( puppet )
		{
			puppet.GetPuppetPS().SetCrouch( false );
		}
		super.OnExit( stateContext, scriptInterface );
		scriptInterface.GetAudioSystem().NotifyGameTone( 'LeaveCrouch' );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
		scriptInterface.SetAnimationParameterFloat( 'crouch', 0.0 );
		if( HasMeleeWeaponEquipped( scriptInterface ) )
		{
			scriptInterface.GetTargetingSystem().AimSnap( scriptInterface.owner );
		}
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		OnExit( stateContext, scriptInterface );
	}

}

class SprintDecisions extends LocomotionGroundDecisions
{
	private var m_sprintPressed : Bool;
	private var m_toggleSprintPressed : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Sprint' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'ToggleSprint' );
		m_sprintPressed = scriptInterface.GetActionValue( 'Sprint' ) > 0.0;
		m_toggleSprintPressed = scriptInterface.GetActionValue( 'ToggleSprint' ) > 0.0;
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.GetName( action ) == 'Sprint' )
		{
			m_sprintPressed = ListenerAction.GetValue( action ) > 0.0;
			if( m_sprintPressed )
			{
				EnableOnEnterCondition( true );
			}
		}
		else if( ListenerAction.GetName( action ) == 'ToggleSprint' )
		{
			m_toggleSprintPressed = ListenerAction.GetValue( action ) > 0.0;
			if( m_toggleSprintPressed )
			{
				EnableOnEnterCondition( true );
			}
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var minLinearVelocityThreshold : Float;
		var minStickInputThreshold : Float;
		var enterAngleThreshold : Float;
		var superResult : Bool;
		var isAiming : Bool;
		var lastShotTime : StateResultFloat;
		var isChargingCyberware : Bool;
		if( ( !( m_sprintPressed ) && !( m_toggleSprintPressed ) ) && !( stateContext.GetConditionBool( 'SprintToggled' ) ) )
		{
			EnableOnEnterCondition( false );
			return false;
		}
		superResult = super.EnterCondition( stateContext, scriptInterface ) && IsTouchingGround( scriptInterface );
		minLinearVelocityThreshold = GetStaticFloatParameterDefault( "minLinearVelocityThreshold", 0.5 );
		minStickInputThreshold = GetStaticFloatParameterDefault( "minStickInputThreshold", 0.89999998 );
		enterAngleThreshold = GetStaticFloatParameterDefault( "enterAngleThreshold", -180.0 );
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanSprint ) ) )
		{
			return false;
		}
		if( ( ( !( scriptInterface.IsMoveInputConsiderable() ) || ( AbsF( scriptInterface.GetInputHeading() ) > enterAngleThreshold ) ) || ( GetMovementInputActionValue( stateContext, scriptInterface ) <= minStickInputThreshold ) ) || ( scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed ) < minLinearVelocityThreshold ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return false;
		}
		isAiming = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) );
		if( isAiming )
		{
			return false;
		}
		isChargingCyberware = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware ) == ( ( Int32 )( gamePSMLeftHandCyberware.Charge ) );
		if( isChargingCyberware )
		{
			return false;
		}
		if( IsChargingWeapon( scriptInterface ) )
		{
			return false;
		}
		if( !( MeleeTransition.MeleeSprintStateCondition( stateContext, scriptInterface ) ) )
		{
			return false;
		}
		lastShotTime = stateContext.GetPermanentFloatParameter( 'LastShotTime' );
		if( lastShotTime.valid )
		{
			if( ( EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) - lastShotTime.value ) < GetStaticFloatParameterDefault( "sprintDisableTimeAfterShoot", -2.0 ) )
			{
				return false;
			}
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponShootWhileSprinting ) ) && ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().CoverAction.coverActionStateId ) == 3 )
		{
			return false;
		}
		if( m_toggleSprintPressed && !( stateContext.GetBoolParameter( 'sprintInputLock', true ) ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', true, true );
		}
		if( !( superResult ) )
		{
			return false;
		}
		if( stateContext.GetConditionBool( 'SprintToggled' ) && !( stateContext.GetBoolParameter( 'sprintInputLock', true ) ) )
		{
			return true;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSprinting ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) ) ) )
		{
			if( scriptInterface.IsActionJustPressed( 'Sprint' ) && !( stateContext.GetBoolParameter( 'sprintInputLock', true ) ) )
			{
				return true;
			}
		}
		else if( m_sprintPressed && !( stateContext.GetBoolParameter( 'sprintInputLock', true ) ) )
		{
			return true;
		}
		return false;
	}

	protected const virtual function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var minLinearVelocityThreshold : Float;
		var enterAngleThreshold : Float;
		var minStickInputThreshold : Float;
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanSprint ) ) )
		{
			return true;
		}
		if( stateContext.GetBoolParameter( 'InterruptSprint' ) || stateContext.GetBoolParameter( 'WalkToggled', true ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		if( GetInStateTime() >= 0.30000001 )
		{
			minLinearVelocityThreshold = GetStaticFloatParameterDefault( "minLinearVelocityThreshold", 0.5 );
			if( scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed ) < minLinearVelocityThreshold )
			{
				stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
				return true;
			}
		}
		enterAngleThreshold = GetStaticFloatParameterDefault( "enterAngleThreshold", 45.0 );
		if( !( scriptInterface.IsMoveInputConsiderable() ) || !( ( AbsF( scriptInterface.GetInputHeading() ) <= enterAngleThreshold ) ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		minStickInputThreshold = GetStaticFloatParameterDefault( "minStickInputThreshold", 0.89999998 );
		if( stateContext.GetConditionBool( 'SprintToggled' ) && ( GetMovementInputActionValue( stateContext, scriptInterface ) <= minStickInputThreshold ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		if( scriptInterface.IsActionJustReleased( 'Sprint' ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		return false;
	}

}

class SprintEvents extends LocomotionGroundEvents
{
	var m_previousStimTimeStamp : Float;
	var m_reloadModifier : gameStatModifierData;
	var m_isInSecondSprint : Bool;
	var m_sprintModifier : gameStatModifierData;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_previousStimTimeStamp = -1.0;
		m_isInSecondSprint = false;
		super.OnEnter( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Sprint ) ) );
		ProcessPermanentBoolParameterToggle( 'WalkToggled', false, stateContext );
		SetupSprintInputLock( stateContext, scriptInterface );
		stateContext.SetConditionBoolParameter( 'blockEnteringSlide', false, true );
		stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		stateContext.SetTemporaryBoolParameter( 'CancelGrenadeAction', true, true );
		ForceDisableVisionMode( stateContext );
		StartEffect( scriptInterface, 'locomotion_sprint' );
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSprinting ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) ) ) )
		{
			stateContext.SetTemporaryBoolParameter( 'TryInterruptReload', true, true );
		}
		if( !( GetStaticBoolParameterDefault( "enableTwoStepSprint_EXPERIMENTAL", false ) ) )
		{
			AddMaxSpeedModifier( stateContext, scriptInterface );
		}
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Sprint );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var isReloading : Bool;
		var isShooting : Bool;
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		UpdateFootstepSprintStim( stateContext, scriptInterface );
		isReloading = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) );
		isShooting = scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0;
		EvaluateTwoStepSprint( stateContext, scriptInterface );
		if( ( ( isReloading && !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSprinting ) ) ) || ( isShooting && !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponShootWhileSprinting ) ) ) ) && !( m_reloadModifier ) )
		{
			AnimationControllerComponent.SetInputFloat( scriptInterface.executionOwner, 'sprint', 0.0 );
			EnableReloadStatModifier( true, stateContext, scriptInterface );
		}
		else if( !( ( isReloading || isShooting ) ) && m_reloadModifier )
		{
			AnimationControllerComponent.SetInputFloat( scriptInterface.executionOwner, 'sprint', 1.0 );
			EnableReloadStatModifier( false, stateContext, scriptInterface );
		}
	}

	private function EvaluateTwoStepSprint( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( GetStaticBoolParameterDefault( "enableTwoStepSprint_EXPERIMENTAL", false ) )
		{
			if( ShouldEnterSecondSprint( stateContext, scriptInterface ) )
			{
				m_isInSecondSprint = true;
				AddMaxSpeedModifier( stateContext, scriptInterface );
			}
			else if( ( m_isInSecondSprint && ( GetInStateTime() >= 0.5 ) ) && scriptInterface.IsActionJustPressed( 'ToggleSprint' ) )
			{
				m_isInSecondSprint = false;
				RemoveMaxSpeedModifier( stateContext, scriptInterface );
			}
		}
	}

	private function AddMaxSpeedModifier( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var statSystem : StatsSystem;
		statSystem = scriptInterface.GetStatsSystem();
		m_sprintModifier = RPGManager.CreateStatModifierUsingCurve( gamedataStatType.MaxSpeed, gameStatModifierType.Additive, gamedataStatType.Reflexes, 'locomotion_stats', 'max_speed_in_sprint' );
		statSystem.AddModifier( scriptInterface.ownerEntityID, m_sprintModifier );
	}

	private function RemoveMaxSpeedModifier( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var statSystem : StatsSystem;
		statSystem = scriptInterface.GetStatsSystem();
		if( m_sprintModifier )
		{
			statSystem.RemoveModifier( scriptInterface.ownerEntityID, m_sprintModifier );
			m_sprintModifier = NULL;
		}
	}

	private function ShouldEnterSecondSprint( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( !( m_isInSecondSprint ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "minTimeToEnterTwoStepSprint", 0.0 ) ) ) && scriptInterface.IsActionJustPressed( 'ToggleSprint' );
	}

	private function CleanupTwoStepSprint( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_isInSecondSprint = false;
		RemoveMaxSpeedModifier( stateContext, scriptInterface );
	}

	protected const function GetReloadModifier( const scriptInterface : StateGameScriptInterface ) : Float
	{
		var result : Float;
		var statValue : Float;
		var lerp : Float;
		var modifierStart : Float;
		var modifierEnd : Float;
		var modifierRange : Float;
		modifierStart = GetStaticFloatParameterDefault( "reloadModifierStart", -2.0 );
		modifierEnd = GetStaticFloatParameterDefault( "reloadModifierEnd", -2.0 );
		modifierRange = modifierEnd - modifierStart;
		statValue = scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.Reflexes );
		lerp = ( statValue - 1.0 ) / 19.0;
		result = modifierStart + ( lerp * modifierRange );
		return result;
	}

	protected virtual function EnableReloadStatModifier( enable : Bool, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var ownerID : StatsObjectID;
		var reloadModifierAmount : Float;
		ownerID = scriptInterface.executionOwnerEntityID;
		if( enable && !( m_reloadModifier ) )
		{
			reloadModifierAmount = GetReloadModifier( scriptInterface );
			m_reloadModifier = RPGManager.CreateStatModifier( gamedataStatType.MaxSpeed, gameStatModifierType.Additive, reloadModifierAmount );
			scriptInterface.GetStatsSystem().AddModifier( ownerID, m_reloadModifier );
		}
		else if( !( enable ) && m_reloadModifier )
		{
			scriptInterface.GetStatsSystem().RemoveModifier( ownerID, m_reloadModifier );
			m_reloadModifier = NULL;
		}
	}

	protected function UpdateFootstepSprintStim( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( GetInStateTime() >= ( m_previousStimTimeStamp + 0.2 ) )
		{
			m_previousStimTimeStamp = GetInStateTime();
			BroadcastStimuliFootstepSprint( scriptInterface );
		}
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		CleanupTwoStepSprint( stateContext, scriptInterface );
		EnableReloadStatModifier( false, stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
		stateContext.SetPermanentFloatParameter( 'SprintingStoppedTimeStamp', scriptInterface.GetNow(), true );
		StopEffect( scriptInterface, 'locomotion_sprint' );
		super.OnExit( stateContext, scriptInterface );
	}

	protected virtual function OnExitToJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		CleanupTwoStepSprint( stateContext, scriptInterface );
		EnableReloadStatModifier( false, stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
		stateContext.SetPermanentFloatParameter( 'SprintingStoppedTimeStamp', scriptInterface.GetNow(), true );
		StopEffect( scriptInterface, 'locomotion_sprint' );
		super.OnExit( stateContext, scriptInterface );
	}

	protected virtual function OnExitToChargeJump( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		CleanupTwoStepSprint( stateContext, scriptInterface );
		EnableReloadStatModifier( false, stateContext, scriptInterface );
		StopEffect( scriptInterface, 'locomotion_sprint' );
		super.OnExit( stateContext, scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		CleanupTwoStepSprint( stateContext, scriptInterface );
		EnableReloadStatModifier( false, stateContext, scriptInterface );
		StopEffect( scriptInterface, 'locomotion_sprint' );
	}

}

class SlideFallDecisions extends LocomotionAirDecisions
{

	protected const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ShouldFall( stateContext, scriptInterface );
	}

	protected const function ToSlide( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		return true;
	}

	protected const function ToFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var fallingSpeedThreshold : Float;
		var verticalSpeed : Float;
		var height : Float;
		if( AbsF( GetCameraYaw( stateContext, scriptInterface ) ) >= GetStaticFloatParameterDefault( "maxCameraYawToExit", 95.0 ) )
		{
			return true;
		}
		if( GetStaticBoolParameterDefault( "backInputExitsSlide", false ) && ( scriptInterface.GetActionValue( 'MoveY' ) < -0.5 ) )
		{
			return true;
		}
		if( ( scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed ) <= GetStaticFloatParameterDefault( "minSpeedToExit", 2.0 ) ) && stateContext.GetStateMachineCurrentState( 'TimeDilation' ) != 'kerenzikov' )
		{
			return true;
		}
		height = GetStaticFloatParameterDefault( "heightToEnterFall", 0.0 );
		if( height > 0.0 )
		{
			fallingSpeedThreshold = GetFallingSpeedBasedOnHeight( scriptInterface, height );
			verticalSpeed = GetVerticalSpeed( scriptInterface );
			if( verticalSpeed <= fallingSpeedThreshold )
			{
				return true;
			}
		}
		return false;
	}

}

class SlideFallEvents extends LocomotionAirEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.SlideFall );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.SlideFall ) ) );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
	}

}

class SlideDecisions extends CrouchDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var superResult : Bool;
		var currentSpeed : Float;
		var velocity : Vector4;
		var angle : Float;
		var secureFootingResult : SecureFootingResult;
		superResult = super.EnterCondition( stateContext, scriptInterface );
		if( !( superResult ) )
		{
			return false;
		}
		if( stateContext.GetConditionBool( 'blockEnteringSlide' ) )
		{
			return false;
		}
		if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoSlide' ) )
		{
			return false;
		}
		velocity = GetLinearVelocity( scriptInterface );
		angle = Vector4.GetAngleBetween( scriptInterface.executionOwner.GetWorldForward(), velocity );
		if( AbsF( angle ) > 45.0 )
		{
			return false;
		}
		currentSpeed = Vector4.Length2D( velocity );
		secureFootingResult = scriptInterface.HasSecureFooting();
		if( secureFootingResult.type == moveSecureFootingFailureType.Slope )
		{
			return true;
		}
		if( currentSpeed < GetStaticFloatParameterDefault( "minSpeedToEnter", 4.5 ) )
		{
			return false;
		}
		if( !( scriptInterface.IsMoveInputConsiderable() ) )
		{
			return false;
		}
		return true;
	}

	protected const override function ToCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var secureFootingResult : SecureFootingResult;
		var angle : Float;
		var horizontalDirection : Vector4;
		var slidingUphill : Bool;
		var velocity : Vector4;
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		secureFootingResult = scriptInterface.HasSecureFooting();
		if( secureFootingResult.type == moveSecureFootingFailureType.Invalid )
		{
			horizontalDirection = secureFootingResult.slidingDirection;
			horizontalDirection.Z = 0.0;
			velocity = GetLinearVelocity( scriptInterface );
			angle = Vector4.GetAngleBetween( secureFootingResult.slidingDirection, horizontalDirection );
			slidingUphill = Vector4.Dot( secureFootingResult.slidingDirection, velocity ) < 0.0;
			if( ( slidingUphill && ( angle >= GetStaticFloatParameterDefault( "minAngleToStopUphillSlide", 10.0 ) ) ) && ( angle < 89.5 ) )
			{
				return true;
			}
		}
		if( ShouldExit( stateContext, scriptInterface ) )
		{
			return ( scriptInterface.GetActionValue( 'Crouch' ) > 0.0 ) || stateContext.GetConditionBool( 'CrouchToggled' );
		}
		return false;
	}

	protected const override function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsTouchingGround( scriptInterface ) ) )
		{
			return false;
		}
		if( GetInStateTime() < GetStaticFloatParameterDefault( "minTimeToExit", 1.0 ) )
		{
			return false;
		}
		if( !( stateContext.GetConditionBool( 'CrouchToggled' ) ) && ( scriptInterface.GetActionValue( 'Crouch' ) <= 0.0 ) )
		{
			return true;
		}
		if( ( ( ( scriptInterface.IsActionJustReleased( 'Crouch' ) || scriptInterface.IsActionJustPressed( 'Sprint' ) ) || scriptInterface.IsActionJustPressed( 'ToggleSprint' ) ) || scriptInterface.IsActionJustPressed( 'Jump' ) ) || scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
			return true;
		}
		return ShouldExit( stateContext, scriptInterface );
	}

	protected const virtual function ShouldExit( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isKerenzikovEnd : Bool;
		var isKerenzikovStateActive : Bool;
		if( AbsF( GetCameraYaw( stateContext, scriptInterface ) ) >= GetStaticFloatParameterDefault( "maxCameraYawToExit", 95.0 ) )
		{
			return true;
		}
		isKerenzikovStateActive = stateContext.GetStateMachineCurrentState( 'TimeDilation' ) == 'kerenzikov';
		if( GetStaticBoolParameterDefault( "backInputExitsSlide", false ) && ( ( GetInStateTime() >= GetStaticFloatParameterDefault( "minTimeToExit", 0.69999999 ) ) && ( scriptInterface.GetActionValue( 'MoveY' ) < -0.5 ) ) )
		{
			return true;
		}
		if( scriptInterface.GetOwnerStateVectorParameterFloat( physicsStateValue.LinearSpeed ) <= GetStaticFloatParameterDefault( "minSpeedToExit", 3.0 ) )
		{
			return !( isKerenzikovStateActive );
		}
		isKerenzikovEnd = isKerenzikovStateActive && !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.KerenzikovPlayerBuff" ) );
		if( isKerenzikovEnd )
		{
			return true;
		}
		return false;
	}

}

class SlideEvents extends CrouchEvents
{
	var m_rumblePlayed : Bool;
	var m_addDecelerationModifier : gameStatModifierData;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
		m_rumblePlayed = false;
		if( GetStaticBoolParameterDefault( "pushAnimEventOnEnter", false ) )
		{
			scriptInterface.PushAnimationEvent( 'Slide' );
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSliding ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) ) ) )
		{
			stateContext.SetTemporaryBoolParameter( 'TryInterruptReload', true, true );
		}
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Slide ) ) );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Slide );
	}

	public function OnEnterFromSprint( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		BroadcastStimuliFootstepSprint( scriptInterface );
		OnEnter( stateContext, scriptInterface );
	}

	protected virtual function AddDecelerationStatModifier( stateContext : StateContext, scriptInterface : StateGameScriptInterface, enable : Bool )
	{
		var ownerID : StatsObjectID;
		ownerID = scriptInterface.executionOwnerEntityID;
		if( enable && !( m_addDecelerationModifier ) )
		{
			m_addDecelerationModifier = RPGManager.CreateStatModifier( gamedataStatType.Deceleration, gameStatModifierType.Additive, GetStaticFloatParameterDefault( "backInputDecelerationModifier", 8.0 ) );
			scriptInterface.GetStatsSystem().AddModifier( ownerID, m_addDecelerationModifier );
		}
		else if( !( enable ) && m_addDecelerationModifier )
		{
			scriptInterface.GetStatsSystem().RemoveModifier( ownerID, m_addDecelerationModifier );
			m_addDecelerationModifier = NULL;
		}
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		if( !( m_rumblePlayed ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "rumbleDelay", 0.5 ) ) )
		{
			m_rumblePlayed = true;
			PlayRumble( scriptInterface, GetStaticStringParameterDefault( "rumbleName", "medium_slow" ) );
		}
		if( GetInStateTime() >= GetStaticFloatParameterDefault( "minTimeToExit", 1.0 ) )
		{
			UpdateInputToggles( stateContext, scriptInterface );
		}
		if( GetStaticBoolParameterDefault( "backInputDeceleratesSlide", false ) )
		{
			EvaluateSlideDeceleration( stateContext, scriptInterface );
		}
	}

	private function EvaluateSlideDeceleration( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( ( ( GetInStateTime() >= GetStaticFloatParameterDefault( "minTimeToAllowDeceleration", 0.1 ) ) && ( scriptInterface.GetActionValue( 'MoveY' ) < -0.5 ) ) && !( stateContext.GetBoolParameter( 'isDecelerating', true ) ) )
		{
			stateContext.SetPermanentBoolParameter( 'isDecelerating', true, true );
			AddDecelerationStatModifier( stateContext, scriptInterface, true );
		}
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpOnExit( stateContext, scriptInterface );
		StopSlideSoundEffect( scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		CleanUpOnExit( stateContext, scriptInterface );
		StopSlideSoundEffect( scriptInterface );
	}

	public function OnExitToCrouch( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Crouch ) ) );
		scriptInterface.SetAnimationParameterFloat( 'crouch', 1.0 );
		CleanUpOnExit( stateContext, scriptInterface );
		StopSlideSoundEffect( scriptInterface );
	}

	private function CleanUpOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		AddDecelerationStatModifier( stateContext, scriptInterface, false );
		stateContext.RemovePermanentBoolParameter( 'isDecelerating' );
	}

	private function StopSlideSoundEffect( scriptInterface : StateGameScriptInterface )
	{
		GameObject.PlaySoundEvent( scriptInterface.owner, 'lcm_fs_additional_slide_stop' );
	}

}

class DodgeDecisions extends LocomotionGroundDecisions
{

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Dodge' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeDirection' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeForward' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeRight' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeLeft' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeBack' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.IsButtonJustPressed( action ) )
		{
			EnableOnEnterCondition( true );
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		EnableOnEnterCondition( false );
		if( WantsToDodge( stateContext, scriptInterface ) )
		{
			if( !( scriptInterface.HasStatFlag( gamedataStatType.HasDodge ) ) )
			{
				return false;
			}
			if( IsTimeDilationActive( stateContext, scriptInterface, TimeDilationHelper.GetKerenzikovKey() ) )
			{
				return false;
			}
			if( ( !( scriptInterface.HasStatFlag( gamedataStatType.CanAimWhileDodging ) ) && stateContext.IsStateActive( 'UpperBody', 'aimingState' ) ) && IsRangedWeaponEquipped( scriptInterface ) )
			{
				return false;
			}
			return true;
		}
		return false;
	}

	protected export const virtual function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isKerenzikovActive : Bool;
		var isKerenzikovEnd : Bool;
		isKerenzikovActive = IsTimeDilationActive( stateContext, scriptInterface, TimeDilationHelper.GetKerenzikovKey() );
		if( !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeBuff" ) ) )
		{
			return !( isKerenzikovActive );
		}
		isKerenzikovEnd = isKerenzikovActive && !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.KerenzikovPlayerBuff" ) );
		if( isKerenzikovEnd )
		{
			return true;
		}
		return false;
	}

}

class DodgeEvents extends LocomotionGroundEvents
{
	var m_blockStatFlag : gameStatModifierData;
	var m_decelerationModifier : gameStatModifierData;
	var m_pressureWaveCreated : Bool;
	default m_pressureWaveCreated = false;

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var ownerID : StatsObjectID;
		var questSystem : QuestsSystem;
		var dodgeHeading : Float;
		ownerID = scriptInterface.executionOwnerEntityID;
		questSystem = scriptInterface.GetQuestsSystem();
		dodgeHeading = stateContext.GetConditionFloat( 'DodgeDirection' );
		super.OnEnter( stateContext, scriptInterface );
		Dodge( stateContext, scriptInterface );
		PlayRumbleBasedOnDodgeDirection( stateContext, scriptInterface );
		questSystem.SetFact( 'gmpl_player_dodged', questSystem.GetFact( 'gmpl_player_dodged' ) + 1 );
		scriptInterface.PushAnimationEvent( 'Dodge' );
		stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		StatusEffectHelper.ApplyStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeBuff" );
		if( ( dodgeHeading < -45.0 ) || ( dodgeHeading > 45.0 ) )
		{
			StatusEffectHelper.ApplyStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeInvulnerability" );
		}
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		m_blockStatFlag = RPGManager.CreateStatModifier( gamedataStatType.IsDodging, gameStatModifierType.Additive, 1.0 );
		scriptInterface.GetStatsSystem().AddModifier( ownerID, m_blockStatFlag );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Dodge );
		LogSpecialMovementToTelemetry( scriptInterface, telemetryMovementType.Dodge );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Dodge ) ) );
	}

	protected export override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		if( !( m_pressureWaveCreated ) && ( GetInStateTime() >= 0.15000001 ) )
		{
			m_pressureWaveCreated = true;
			PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.Dodge" ) );
		}
		if( scriptInterface.IsActionJustPressed( 'Jump' ) )
		{
			stateContext.SetConditionBoolParameter( 'JumpPressed', true, true );
		}
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		CleanUpOnExit( stateContext, scriptInterface );
		super.OnExit( stateContext, scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		CleanUpOnExit( stateContext, scriptInterface );
	}

	private function CleanUpOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var ownerID : StatsObjectID;
		ownerID = scriptInterface.executionOwnerEntityID;
		m_pressureWaveCreated = false;
		scriptInterface.GetStatsSystem().RemoveModifier( ownerID, m_blockStatFlag );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeBuff" );
		EnableMovementDecelerationStatModifier( stateContext, scriptInterface, false );
	}

	protected function Dodge( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impulseValue : Float;
		var impulse : Vector4;
		var dodgeHeading : Float;
		if( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, PlayerStaminaHelpers.GetExhaustedStatusEffectID() ) )
		{
			EnableMovementDecelerationStatModifier( stateContext, scriptInterface, true );
			impulseValue = GetStaticFloatParameterDefault( "impulseNoStamina", 4.80000019 );
		}
		else
		{
			EnableMovementDecelerationStatModifier( stateContext, scriptInterface, false );
			impulseValue = GetStaticFloatParameterDefault( "impulse", 13.0 );
		}
		dodgeHeading = stateContext.GetConditionFloat( 'DodgeDirection' );
		impulse = Vector4.FromHeading( AngleNormalize180( scriptInterface.executionOwner.GetWorldYaw() + dodgeHeading ) ) * impulseValue;
		AddImpulse( stateContext, impulse );
	}

	protected virtual function EnableMovementDecelerationStatModifier( stateContext : StateContext, scriptInterface : StateGameScriptInterface, enable : Bool )
	{
		var ownerID : StatsObjectID;
		ownerID = scriptInterface.executionOwnerEntityID;
		if( enable && !( m_decelerationModifier ) )
		{
			m_decelerationModifier = RPGManager.CreateStatModifier( gamedataStatType.Deceleration, gameStatModifierType.Additive, GetStaticFloatParameterDefault( "movementDecelerationNoStamina", -90.0 ) );
			scriptInterface.GetStatsSystem().AddModifier( ownerID, m_decelerationModifier );
		}
		else if( !( enable ) && m_decelerationModifier )
		{
			scriptInterface.GetStatsSystem().RemoveModifier( ownerID, m_decelerationModifier );
			m_decelerationModifier = NULL;
		}
	}

}

class ClimbDecisions extends LocomotionGroundDecisions
{
	const var stateBodyDone : Bool;

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var climbInfo : PlayerClimbInfo;
		var enterAngleThreshold : Float;
		var isObstacleSuitable : Bool;
		var isPathClear : Bool;
		var preClimbAnimFeature : AnimFeature_PreClimbing;
		var isInAcceptableAerialState : Bool;
		isPathClear = false;
		isInAcceptableAerialState = ( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Locomotion ) == ( ( Int32 )( gamePSMLocomotionStates.Jump ) ) ) || IsInLocomotionState( stateContext, 'dodgeAir' ) ) || stateContext.GetBoolParameter( 'enteredFallFromAirDodge', true );
		if( !( isInAcceptableAerialState ) && !( ( stateContext.GetConditionBool( 'JumpPressed' ) || scriptInterface.IsActionJustPressed( 'Jump' ) ) ) )
		{
			return false;
		}
		climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo( scriptInterface.owner );
		isObstacleSuitable = climbInfo.climbValid && OverlapFitTest( scriptInterface, climbInfo );
		if( isObstacleSuitable )
		{
			isPathClear = TestClimbingPath( scriptInterface, climbInfo, GetPlayerPosition( scriptInterface ) );
			isObstacleSuitable = isObstacleSuitable && isPathClear;
		}
		preClimbAnimFeature = new AnimFeature_PreClimbing;
		preClimbAnimFeature.valid = 0.0;
		if( isObstacleSuitable )
		{
			preClimbAnimFeature.edgePositionLS = scriptInterface.TransformInvPointFromObject( climbInfo.descResult.topPoint );
			preClimbAnimFeature.valid = 1.0;
		}
		stateContext.SetConditionScriptableParameter( 'PreClimbAnimFeature', preClimbAnimFeature, true );
		if( isObstacleSuitable )
		{
			if( IsVaultingClimbingRestricted( scriptInterface ) )
			{
				return false;
			}
			if( !( ForwardAngleTest( stateContext, scriptInterface, climbInfo ) ) )
			{
				return false;
			}
			if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
			{
				return false;
			}
			if( ( AbsF( scriptInterface.GetInputHeading() ) > 45.0 ) || IsPlayerMovingBackwards( stateContext, scriptInterface ) )
			{
				return false;
			}
			if( IsCameraPitchAcceptable( stateContext, scriptInterface, GetStaticFloatParameterDefault( "cameraPitchThreshold", -30.0 ) ) )
			{
				return false;
			}
			if( stateContext.IsStateActive( 'Locomotion', 'chargeJump' ) && ( GetVerticalSpeed( scriptInterface ) > 0.0 ) )
			{
				return false;
			}
			enterAngleThreshold = GetStaticFloatParameterDefault( "inputAngleThreshold", -180.0 );
			if( !( AbsF( scriptInterface.GetInputHeading() ) <= enterAngleThreshold ) )
			{
				return false;
			}
			if( !( MeleeTransition.MeleeUseExplorationCondition( stateContext, scriptInterface ) ) )
			{
				return false;
			}
			return isObstacleSuitable;
		}
		return false;
	}

	public const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

	public const function ToCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

	private const function ForwardAngleTest( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, climbInfo : PlayerClimbInfo ) : Bool
	{
		var obstaclePosition : Vector4;
		var playerForward : Vector4;
		var enterAngleThreshold : Float;
		var forwardAngleDifference : Float;
		playerForward = scriptInterface.GetOwnerForward();
		obstaclePosition = climbInfo.descResult.collisionNormal;
		forwardAngleDifference = Vector4.GetAngleBetween( -( obstaclePosition ), playerForward );
		enterAngleThreshold = GetStaticFloatParameterDefault( "obstacleEnterAngleThreshold", -180.0 );
		if( ( forwardAngleDifference < enterAngleThreshold ) && ( ( forwardAngleDifference - 180.0 ) < enterAngleThreshold ) )
		{
			return true;
		}
		return false;
	}

	private const function TestClimbingPath( const scriptInterface : StateGameScriptInterface, climbInfo : PlayerClimbInfo, playerPosition : Vector4 ) : Bool
	{
		var playerCapsuleDimensions : Vector4;
		var tolerance : Float;
		var climbDestination : Vector4;
		var rotation1 : EulerAngles;
		var fitTestOvelap1 : TraceResult;
		var overlapPosition1 : Vector4;
		var rayCastSourcePosition1 : Vector4;
		var rayCastDestinationPosition1 : Vector4;
		var rayCastTraceResult1 : TraceResult;
		var rayCastResult1 : Bool;
		var overlapResult1 : Bool;
		var rotation2 : EulerAngles;
		var fitTestOvelap2 : TraceResult;
		var overlapPosition2 : Vector4;
		var rayCastSourcePosition2 : Vector4;
		var rayCastDestinationPosition2 : Vector4;
		var rayCastTraceResult2 : TraceResult;
		var rayCastResult2 : Bool;
		var overlapResult2 : Bool;
		var groundTolerance : Float;
		groundTolerance = 0.05;
		tolerance = 0.15000001;
		playerCapsuleDimensions.X = GetStaticFloatParameterDefault( "capsuleRadius", 0.40000001 );
		playerCapsuleDimensions.Y = -1.0;
		playerCapsuleDimensions.Z = -1.0;
		climbDestination = climbInfo.descResult.topPoint + ( GetUpVector() * ( playerCapsuleDimensions.X + tolerance ) );
		overlapPosition1 = playerPosition;
		overlapPosition1.Z = climbDestination.Z;
		rayCastSourcePosition1 = playerPosition;
		rayCastSourcePosition1.Z += groundTolerance;
		rayCastDestinationPosition1 = overlapPosition1;
		rayCastTraceResult1 = scriptInterface.LocomotionRaycastTest( rayCastSourcePosition1, rayCastDestinationPosition1 );
		rayCastResult1 = TraceResult.IsValid( rayCastTraceResult1 );
		if( !( rayCastResult1 ) )
		{
			overlapResult1 = scriptInterface.LocomotionOverlapTest( playerCapsuleDimensions, overlapPosition1, rotation1, fitTestOvelap1 );
		}
		if( !( rayCastResult1 ) && !( overlapResult1 ) )
		{
			overlapPosition2 = climbDestination;
			rayCastSourcePosition2 = overlapPosition1;
			rayCastDestinationPosition2 = overlapPosition2;
			rayCastTraceResult2 = scriptInterface.LocomotionRaycastTest( rayCastSourcePosition2, rayCastDestinationPosition2 );
			rayCastResult2 = TraceResult.IsValid( rayCastTraceResult2 );
			if( !( rayCastResult2 ) )
			{
				overlapResult2 = scriptInterface.LocomotionOverlapTest( playerCapsuleDimensions, overlapPosition2, rotation2, fitTestOvelap2 );
			}
		}
		return ( ( !( rayCastResult1 ) && !( overlapResult1 ) ) && !( rayCastResult2 ) ) && !( overlapResult2 );
	}

	private const function OverlapFitTest( const scriptInterface : StateGameScriptInterface, climbInfo : PlayerClimbInfo ) : Bool
	{
		var rotation : EulerAngles;
		var crouchOverlap : Bool;
		var fitTestOvelap : TraceResult;
		var playerCapsuleDimensions : Vector4;
		var queryPosition : Vector4;
		var tolerance : Float;
		tolerance = 0.15000001;
		playerCapsuleDimensions.X = GetStaticFloatParameterDefault( "capsuleRadius", 0.40000001 );
		playerCapsuleDimensions.Y = -1.0;
		playerCapsuleDimensions.Z = -1.0;
		queryPosition = climbInfo.descResult.topPoint + ( GetUpVector() * ( playerCapsuleDimensions.X + tolerance ) );
		crouchOverlap = scriptInterface.LocomotionOverlapTest( playerCapsuleDimensions, queryPosition, rotation, fitTestOvelap );
		return !( crouchOverlap );
	}

}

class VaultDecisions extends LocomotionGroundDecisions
{
	const var stateBodyDone : Bool;

	private const function ObstacleLengthCheck( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, vaultInfo : PlayerClimbInfo ) : Bool
	{
		var maxSpeedNormalizer : Float;
		var normalizedSpeed : Float;
		var detectionRange : Float;
		var maxExtent : Float;
		var obstacleExtent : Float;
		var offsetFromObstacleInVelocityVectorMag : Float;
		var maxClimbableDistanceFromCurve : Float;
		var minDetectionRange : Float;
		var linearVelocity : Vector4;
		var playerForward : Vector4;
		var offsetFromObstacle : Vector4;
		var playerPosition : Vector4;
		var offsetFromObstacleInVelocityVector : Vector4;
		var resVelocity : Bool;
		var resDepth : Bool;
		minDetectionRange = GetStaticFloatParameterDefault( "minDetectionRange", 0.40000001 );
		maxSpeedNormalizer = GetStaticFloatParameterDefault( "maxSpeedNormalizer", 8.5 );
		detectionRange = GetStaticFloatParameterDefault( "detectionRange", 2.0 );
		linearVelocity = GetLinearVelocity( scriptInterface );
		normalizedSpeed = MinF( 1.0, Vector4.Length( linearVelocity ) / maxSpeedNormalizer );
		playerPosition = GetPlayerPosition( scriptInterface );
		offsetFromObstacle = vaultInfo.descResult.topPoint - playerPosition;
		playerForward = scriptInterface.GetOwnerForward();
		offsetFromObstacleInVelocityVector = playerForward * Vector4.Dot( playerForward, offsetFromObstacle );
		offsetFromObstacleInVelocityVectorMag = Vector4.Length( offsetFromObstacleInVelocityVector );
		maxExtent = GetStaticFloatParameterDefault( "maxExtent", 2.0999999 );
		obstacleExtent = vaultInfo.descResult.topExtent;
		maxClimbableDistanceFromCurve = ( minDetectionRange + ( ( detectionRange - minDetectionRange ) * normalizedSpeed ) ) + 0.05;
		resVelocity = offsetFromObstacleInVelocityVectorMag < maxClimbableDistanceFromCurve;
		resDepth = obstacleExtent < maxExtent;
		return resVelocity && resDepth;
	}

	protected const function FitTest( const scriptInterface : StateGameScriptInterface, playerCapsuleDimensions : Vector4, vaultInfo : PlayerClimbInfo ) : Bool
	{
		var fitTest : TraceResult;
		var queryPosition : Vector4;
		var direction : Vector4;
		var playerForward : Vector4;
		var playerPosition : Vector4;
		var distance : Float;
		var rotation : EulerAngles;
		var freeSpace : Bool;
		var deltaZ : Bool;
		playerForward = scriptInterface.GetOwnerForward();
		playerPosition = GetPlayerPosition( scriptInterface );
		distance = vaultInfo.descResult.topExtent;
		direction = playerForward * distance;
		direction = Vector4.Normalize( direction );
		queryPosition = ( vaultInfo.descResult.topPoint + ( GetUpVector() * playerCapsuleDimensions.X ) ) + 0.01;
		freeSpace = !( scriptInterface.LocomotionSweepTest( playerCapsuleDimensions, queryPosition, rotation, direction, distance, false, fitTest ) );
		deltaZ = ( vaultInfo.descResult.behindPoint.Z - playerPosition.Z ) <= 0.40000001;
		return freeSpace && deltaZ;
	}

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Jump' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.IsButtonJustPressed( action ) )
		{
			EnableOnEnterCondition( true );
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var vaultInfo : PlayerClimbInfo;
		var enterAngleThreshold : Float;
		var playerCapsuleDimensions : Vector4;
		EnableOnEnterCondition( false );
		if( !( scriptInterface.IsActionJustPressed( 'Jump' ) ) )
		{
			return false;
		}
		if( IsVaultingClimbingRestricted( scriptInterface ) )
		{
			return false;
		}
		if( GetStaticBoolParameterDefault( "requireDirectionalInputToVault", false ) && !( scriptInterface.IsMoveInputConsiderable() ) )
		{
			return false;
		}
		enterAngleThreshold = GetStaticFloatParameterDefault( "enterAngleThreshold", -180.0 );
		if( AbsF( scriptInterface.GetInputHeading() ) > enterAngleThreshold )
		{
			return false;
		}
		if( !( MeleeTransition.MeleeUseExplorationCondition( stateContext, scriptInterface ) ) )
		{
			return false;
		}
		vaultInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo( scriptInterface.owner );
		playerCapsuleDimensions.X = GetStaticFloatParameterDefault( "capsuleRadius", 0.40000001 );
		playerCapsuleDimensions.Y = -1.0;
		playerCapsuleDimensions.Z = -1.0;
		return ( vaultInfo.vaultValid && FitTest( scriptInterface, playerCapsuleDimensions, vaultInfo ) ) && ObstacleLengthCheck( stateContext, scriptInterface, vaultInfo );
	}

	public const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

	public const function ToCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

}

class VaultEvents extends LocomotionGroundEvents
{

	protected function GetVaultParameter( scriptInterface : StateGameScriptInterface ) : VaultParameters
	{
		var playerPosition : Vector4;
		var climbInfo : PlayerClimbInfo;
		var vaultParameters : VaultParameters;
		var direction : Vector4;
		var landingPoint : Vector4;
		var obstacleEnd : Vector4;
		var behindZ : Float;
		playerPosition = GetPlayerPosition( scriptInterface );
		vaultParameters = new VaultParameters;
		climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo( scriptInterface.owner );
		direction = scriptInterface.GetOwnerForward();
		vaultParameters.SetObstacleFrontEdgePosition( climbInfo.descResult.topPoint );
		vaultParameters.SetObstacleFrontEdgeNormal( climbInfo.descResult.collisionNormal );
		vaultParameters.SetObstacleVerticalDestination( climbInfo.descResult.topPoint );
		vaultParameters.SetObstacleSurfaceNormal( climbInfo.descResult.topNormal );
		obstacleEnd = climbInfo.obstacleEnd;
		behindZ = MaxF( climbInfo.descResult.behindPoint.Z, playerPosition.Z );
		landingPoint.X = obstacleEnd.X;
		landingPoint.Y = obstacleEnd.Y;
		landingPoint.Z = behindZ;
		vaultParameters.SetObstacleDestination( landingPoint + ( direction * GetStaticFloatParameterDefault( "forwardStep", 0.5 ) ) );
		vaultParameters.SetObstacleDepth( climbInfo.descResult.topExtent );
		vaultParameters.SetMinSpeed( GetStaticFloatParameterDefault( "minSpeed", 3.5 ) );
		return vaultParameters;
	}

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		stateContext.SetTemporaryScriptableParameter( 'vaultInfo', GetVaultParameter( scriptInterface ), true );
		scriptInterface.PushAnimationEvent( 'Vault' );
		GameObject.PlayVoiceOver( scriptInterface.owner, 'Vault', 'Scripts:VaultEvents' );
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileVaulting ) ) )
		{
			stateContext.SetTemporaryBoolParameter( 'TryInterruptReload', true, true );
		}
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Vault );
		PlayRumble( scriptInterface, "medium_pulse" );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Vault ) ) );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		stateContext.SetPermanentBoolParameter( 'ForceSafeState', false, true );
	}

}

class LadderDecisions extends LocomotionGroundDecisions
{

	private const function TestParameters( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, out ladderParameter : LadderDescription ) : Bool
	{
		var ladderFinishedParameter : StateResultBool;
		ladderParameter = ( ( LadderDescription )( stateContext.GetTemporaryScriptableParameter( 'usingLadder' ) ) );
		if( !( ladderParameter ) )
		{
			ladderParameter = ( ( LadderDescription )( stateContext.GetConditionScriptableParameter( 'usingLadder' ) ) );
			ladderFinishedParameter = stateContext.GetTemporaryBoolParameter( 'exitLadder' );
			if( ladderFinishedParameter.valid && ladderFinishedParameter.value )
			{
				stateContext.RemoveConditionScriptableParameter( 'usingLadder' );
				return false;
			}
			if( !( ladderParameter ) )
			{
				return false;
			}
		}
		else
		{
			stateContext.SetConditionScriptableParameter( 'usingLadder', ladderParameter, true );
		}
		return true;
	}

	private const function TestLadderMath( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, ladderParameter : LadderDescription ) : Bool
	{
		var isPlayerMovingForward : Bool;
		var playerMoveDirection : Float;
		var playerInputDirection : Vector4;
		var playerForward : Vector4;
		var directionToLadder : Vector4;
		var ladderPosition : Vector4;
		var ladderEntityAngle : Float;
		var fromBottomFactor : Float;
		var enterAngleThreshold : Float;
		playerForward = scriptInterface.GetOwnerForward();
		if( SgnF( Vector4.Dot( ladderParameter.normal, playerForward ) ) > 0.0 )
		{
			return false;
		}
		ladderPosition = ladderParameter.position + ( ( ladderParameter.up * ( ladderParameter.verticalStepBottom + ladderParameter.topHeightFromPosition ) ) / 2.0 );
		directionToLadder = ladderPosition - GetPlayerPosition( scriptInterface );
		directionToLadder = Vector4.Normalize2D( directionToLadder );
		ladderEntityAngle = Rad2Deg( AcosF( ClampF( Vector4.Dot( playerForward, directionToLadder ), -1.0, 1.0 ) ) );
		enterAngleThreshold = GetStaticFloatParameterDefault( "enterAngleThreshold", 35.0 );
		isPlayerMovingForward = !( IsPlayerMovingBackwards( stateContext, scriptInterface ) );
		if( !( IsTouchingGround( scriptInterface ) ) && isPlayerMovingForward )
		{
			if( AbsF( ladderEntityAngle ) < enterAngleThreshold )
			{
				if( GetLandingType( stateContext ) < ( ( Int32 )( LandingType.VeryHard ) ) )
				{
					return true;
				}
			}
		}
		else
		{
			playerInputDirection = Vector4.Normalize2D( ( ( Vector4 )( Vector4.RotByAngleXY( playerForward, scriptInterface.GetInputHeading() ) ) ) );
			playerMoveDirection = Rad2Deg( AcosF( ClampF( Vector4.Dot( playerInputDirection, -( ladderParameter.normal ) ), -1.0, 1.0 ) ) );
			fromBottomFactor = SgnF( Vector4.Dot( ladderParameter.up, directionToLadder ) );
			if( ( scriptInterface.IsMoveInputConsiderable() && isPlayerMovingForward ) && ( ( ( fromBottomFactor > 0.0 ) && ( AbsF( ladderEntityAngle ) < enterAngleThreshold ) ) && ( AbsF( playerMoveDirection ) < enterAngleThreshold ) ) )
			{
				return true;
			}
		}
		return false;
	}

	protected export const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var finishedLadder : StateResultBool;
		finishedLadder = stateContext.GetTemporaryBoolParameter( 'finishedLadderAction' );
		return finishedLadder.valid && finishedLadder.value;
	}

	protected export const function ToLadderCrouch( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustPressed( 'Crouch' ) || scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ladderParameter : LadderDescription;
		var testParameters : Bool;
		var isActionEnterLadderParam : StateResultBool;
		var isActionEnterLadder : Bool;
		testParameters = TestParameters( stateContext, scriptInterface, ladderParameter );
		if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoLadder' ) )
		{
			return false;
		}
		isActionEnterLadderParam = stateContext.GetTemporaryBoolParameter( 'actionEnterLadder' );
		isActionEnterLadder = isActionEnterLadderParam.valid && isActionEnterLadderParam.value;
		if( ( ladderParameter == NULL ) && !( isActionEnterLadder ) )
		{
			return false;
		}
		if( !( MeleeTransition.MeleeUseExplorationCondition( stateContext, scriptInterface ) ) )
		{
			return false;
		}
		if( isActionEnterLadder )
		{
			return true;
		}
		return testParameters && TestLadderMath( stateContext, scriptInterface, ladderParameter );
	}

	protected const function CommonEnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ladderEntryDuration : StateResultFloat;
		ladderEntryDuration = stateContext.GetPermanentFloatParameter( 'ladderEntryDuration' );
		if( ladderEntryDuration.valid )
		{
			return false;
		}
		if( !( scriptInterface.IsMoveInputConsiderable() ) )
		{
			return false;
		}
		if( scriptInterface.IsActionJustPressed( 'ToggleSprint' ) || stateContext.GetConditionBool( 'SprintToggled' ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', true, true );
			return true;
		}
		if( ( scriptInterface.GetActionValue( 'Sprint' ) > 0.0 ) || ( scriptInterface.GetActionValue( 'ToggleSprint' ) > 0.0 ) )
		{
			return true;
		}
		return false;
	}

	protected const function CommonToLadder( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, const isVerticalSpeedValid : Bool ) : Bool
	{
		if( stateContext.GetBoolParameter( 'InterruptSprint' ) )
		{
			return true;
		}
		if( !( scriptInterface.IsMoveInputConsiderable() ) || !( isVerticalSpeedValid ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		if( !( stateContext.GetConditionBool( 'SprintToggled' ) ) && ( scriptInterface.GetActionValue( 'Sprint' ) == 0.0 ) )
		{
			return true;
		}
		if( scriptInterface.IsActionJustReleased( 'Sprint' ) || scriptInterface.IsActionJustPressed( 'AttackA' ) )
		{
			stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
			return true;
		}
		return false;
	}

}

class LadderSprintDecisions extends LadderDecisions
{

	protected const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetVerticalSpeed( scriptInterface ) <= 0.0 )
		{
			return false;
		}
		return CommonEnterCondition( stateContext, scriptInterface );
	}

	protected const function ToLadder( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return CommonToLadder( stateContext, scriptInterface, GetVerticalSpeed( scriptInterface ) > 0.0 );
	}

}

class LadderSprintEvents extends LadderEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		LogAssert( stateContext.GetStateMachineCurrentState( 'Locomotion' ) == 'ladder', "[LadderSprintEvents::OnEnter] 'LadderSprint' state entered from state other than 'Ladder'" );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.LadderSprint );
		SetLocomotionParameters( stateContext, scriptInterface );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
	}

	protected function OnExitToLadder( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}
}

class LadderSlideDecisions extends LadderDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetVerticalSpeed( scriptInterface ) >= 0.0 )
		{
			return false;
		}
		return CommonEnterCondition( stateContext, scriptInterface );
	}

	protected const function ToLadder( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return CommonToLadder( stateContext, scriptInterface, GetVerticalSpeed( scriptInterface ) < 0.0 );
	}

}

class LadderSlideEvents extends LadderEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		LogAssert( stateContext.GetStateMachineCurrentState( 'Locomotion' ) == 'ladder', "[LadderSlideEvents::OnEnter] 'LadderSlide' state entered from state other than 'Ladder'" );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.LadderSlide );
		SetLocomotionParameters( stateContext, scriptInterface );
	}

	protected function OnExitToLadder( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}
}

class LadderJumpEvents extends LocomotionAirEvents
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var ownerTransform : Transform;
		var ownerForwardXY : Vector4;
		var ownerRightXY : Vector4;
		var camerForwardXY : Vector4;
		var cameraAngle : Float;
		var jumpDirection : Vector4;
		ownerTransform = scriptInterface.GetOwnerTransform();
		super.OnEnter( stateContext, scriptInterface );
		camerForwardXY = Transform.GetForward( scriptInterface.GetCameraWorldTransform() );
		camerForwardXY.Z = 0.0;
		camerForwardXY = Vector4.Normalize( camerForwardXY );
		ownerForwardXY = Transform.GetForward( ownerTransform );
		ownerForwardXY.Z = 0.0;
		ownerForwardXY = Vector4.Normalize( ownerForwardXY );
		cameraAngle = Rad2Deg( AcosF( Vector4.Dot( camerForwardXY, ownerForwardXY ) ) );
		if( cameraAngle < GetStaticFloatParameterDefault( "angleToleranceForLateralJump", 30.0 ) )
		{
			jumpDirection = -( ownerForwardXY );
		}
		else if( cameraAngle < 90.0 )
		{
			ownerRightXY = Transform.GetRight( ownerTransform );
			ownerRightXY.Z = 0.0;
			ownerRightXY = Vector4.Normalize( ownerRightXY );
			if( Vector4.Dot( camerForwardXY, ownerRightXY ) > 0.0 )
			{
				jumpDirection = ownerRightXY;
			}
			else
			{
				jumpDirection = -( ownerRightXY );
			}
		}
		else
		{
			jumpDirection = camerForwardXY;
		}
		jumpDirection.Z = SinF( Deg2Rad( GetStaticFloatParameterDefault( "pitchAngle", 45.0 ) ) );
		jumpDirection = Vector4.Normalize( jumpDirection );
		AddImpulse( stateContext, jumpDirection * GetStaticFloatParameterDefault( "impulseStrength", 4.0 ) );
		stateContext.SetTemporaryBoolParameter( 'finishedLadderAction', true, true );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.LadderJump );
	}

}

class UnsecureFootingFallDecisions extends FallDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var secureFootingResult : SecureFootingResult;
		var linearVelocity : Vector4;
		if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
		{
			return false;
		}
		secureFootingResult = scriptInterface.HasSecureFooting();
		linearVelocity = GetLinearVelocity( scriptInterface );
		return secureFootingResult.type == moveSecureFootingFailureType.Edge && ( linearVelocity.Z < GetStaticFloatParameterDefault( "minVerticalVelocityToEnter", -0.30000001 ) );
	}

}

class UnsecureFootingFallEvents extends FallEvents
{

	protected export override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
	}

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
	}

}

class AirThrustersDecisions extends LocomotionAirDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var shouldFall : Bool;
		var minInputHoldTime : Float;
		var autoActivationNearGround : Bool;
		shouldFall = ShouldFall( stateContext, scriptInterface );
		if( shouldFall )
		{
			scriptInterface.GetAudioSystem().NotifyGameTone( 'StartFalling' );
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.HasAirThrusters ) ) && !( GetStaticBoolParameterDefault( "debug_Enable_Air_Thrusters", false ) ) )
		{
			return false;
		}
		minInputHoldTime = GetStaticFloatParameterDefault( "minInputHoldTime", 0.15000001 );
		if( ( scriptInterface.GetActionValue( 'Jump' ) > 0.0 ) && ( scriptInterface.GetActionStateTime( 'Jump' ) > minInputHoldTime ) )
		{
			return GetDistanceToGround( scriptInterface ) >= GetStaticFloatParameterDefault( "minDistanceToGround", 0.0 );
		}
		autoActivationNearGround = GetStaticBoolParameterDefault( "autoActivationAboutToHitGround", true );
		if( autoActivationNearGround && IsFallHeightAcceptable( stateContext, scriptInterface ) )
		{
			return GetDistanceToGround( scriptInterface ) <= GetStaticFloatParameterDefault( "autoActivationDistanceToGround", 0.0 );
		}
		return false;
	}

	protected const function IsFallHeightAcceptable( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var acceptableFallingSpeed : Float;
		var verticalSpeed : Float;
		acceptableFallingSpeed = GetFallingSpeedBasedOnHeight( scriptInterface, GetStaticFloatParameterDefault( "minFallHeight", 3.0 ) );
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		if( verticalSpeed <= acceptableFallingSpeed )
		{
			return true;
		}
		return false;
	}

	protected const function ToFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( scriptInterface.HasStatFlag( gamedataStatType.HasAirThrusters ) ) )
		{
			return true;
		}
		if( GetStaticBoolParameterDefault( "autoTransitionToFall", true ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "stateDuration", 0.0 ) ) )
		{
			return true;
		}
		if( ( !( GetStaticBoolParameterDefault( "autoTransitionToFall", true ) ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "stateDuration", 0.0 ) ) ) && ( scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) || scriptInterface.IsActionJustPressed( 'Crouch' ) ) )
		{
			return true;
		}
		if( ( GetStaticBoolParameterDefault( "allowCancelingWithCrouchAction", true ) && scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) ) || scriptInterface.IsActionJustPressed( 'Crouch' ) )
		{
			return true;
		}
		if( GetDistanceToGround( scriptInterface ) <= GetStaticFloatParameterDefault( "minDistanceToGround", 0.0 ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( IsTouchingGround( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToDoubleJump( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( scriptInterface.HasStatFlag( gamedataStatType.HasDoubleJump ) ) )
		{
			return false;
		}
		if( stateContext.GetIntParameter( 'currentNumberOfJumps', true ) >= 2 )
		{
			return false;
		}
		if( stateContext.GetConditionBool( 'JumpPressed' ) || scriptInterface.IsActionJustPressed( 'Jump' ) )
		{
			return true;
		}
		return false;
	}

}

class AirThrustersEvents extends LocomotionAirEvents
{
	default m_updateInputToggles = false;

	protected virtual function SendAnimFeatureDataToGraph( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : Int32 )
	{
		var animFeature : AnimFeature_AirThrusterData;
		animFeature = new AnimFeature_AirThrusterData;
		animFeature.state = state;
		scriptInterface.SetAnimationParameterFeature( 'AirThrusterData', animFeature );
	}

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SendAnimFeatureDataToGraph( stateContext, scriptInterface, 1 );
		scriptInterface.SetAnimationParameterFloat( 'crouch', 0.0 );
		stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		StopEffect( scriptInterface, 'falling' );
		PlaySound( 'q115_thruster_start', scriptInterface );
		PlayEffectOnItem( scriptInterface, 'thrusters' );
		SetUpwardsThrustStats( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.AirThrusters );
		PlayRumbleLoop( scriptInterface, "light" );
	}

	private function GetActiveFeetAreaItem( scriptInterface : StateGameScriptInterface ) : ItemObject
	{
		var es : EquipmentSystem;
		var feetItem : ItemObject;
		es = ( ( EquipmentSystem )( scriptInterface.GetScriptableSystem( 'EquipmentSystem' ) ) );
		feetItem = es.GetActiveWeaponObject( scriptInterface.executionOwner, gamedataEquipmentArea.Feet );
		return feetItem;
	}

	private function PlayEffectOnItem( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var spawnEffectEvent : entSpawnEffectEvent;
		if( GetActiveFeetAreaItem( scriptInterface ) )
		{
			spawnEffectEvent = new entSpawnEffectEvent;
			spawnEffectEvent.effectName = effectName;
			GetActiveFeetAreaItem( scriptInterface ).GetOwner().QueueEvent( spawnEffectEvent );
		}
	}

	protected function StopEffectOnItem( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var killEffectEvent : entKillEffectEvent;
		if( GetActiveFeetAreaItem( scriptInterface ) )
		{
			killEffectEvent = new entKillEffectEvent;
			killEffectEvent.effectName = effectName;
			GetActiveFeetAreaItem( scriptInterface ).GetOwner().QueueEvent( killEffectEvent );
		}
	}

	private function SetUpwardsThrustStats( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var locomotionParameters : LocomotionParameters;
		locomotionParameters = new LocomotionParameters;
		SetModifierGroupForState( scriptInterface );
		GetStateDefaultLocomotionParameters( locomotionParameters );
		locomotionParameters.SetUpwardsGravity( GetStaticFloatParameterDefault( "upwardsGravity", -16.0 ) );
		locomotionParameters.SetDownwardsGravity( GetStaticFloatParameterDefault( "downwardsGravity", -4.0 ) );
		locomotionParameters.SetDoJump( true );
		stateContext.SetTemporaryScriptableParameter( 'locomotionParameters', locomotionParameters, true );
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SendAnimFeatureDataToGraph( stateContext, scriptInterface, 0 );
		PlaySound( 'q115_thruster_stop', scriptInterface );
		StopEffectOnItem( scriptInterface, 'thrusters' );
		StopRumbleLoop( scriptInterface, "light" );
	}

}

class AirHoverDecisions extends LocomotionAirDecisions
{
	private var m_executionOwner : weak< GameObject >;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_hasStatusEffect : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( scriptInterface.owner.GetEntityID(), m_statusEffectListener );
		m_executionOwner = scriptInterface.executionOwner;
		UpdateHasStatusEffect();
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_statusEffectListener = NULL;
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( !( m_hasStatusEffect ) )
		{
			m_hasStatusEffect = statusEffect.GetID() == T"BaseStatusEffect.BerserkPlayerBuff";
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_hasStatusEffect )
		{
			if( statusEffect.GetID() == T"BaseStatusEffect.BerserkPlayerBuff" )
			{
				UpdateHasStatusEffect();
			}
		}
	}

	protected function UpdateHasStatusEffect()
	{
		m_hasStatusEffect = StatusEffectSystem.ObjectHasStatusEffect( m_executionOwner, T"BaseStatusEffect.BerserkPlayerBuff" );
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isInAcceptableAerialState : Bool;
		var shouldFall : Bool;
		shouldFall = ShouldFall( stateContext, scriptInterface );
		if( shouldFall )
		{
			scriptInterface.GetAudioSystem().NotifyGameTone( 'StartFalling' );
		}
		if( !( m_hasStatusEffect ) )
		{
			return false;
		}
		if( IsHeavyWeaponEquipped( scriptInterface ) )
		{
			return false;
		}
		isInAcceptableAerialState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Locomotion ) == ( ( Int32 )( gamePSMLocomotionStates.Jump ) );
		if( stateContext.GetBoolParameter( 'requestSuperheroLandActivation' ) && isInAcceptableAerialState )
		{
			if( IsDistanceToGroundAcceptable( stateContext, scriptInterface ) && IsFallSpeedAcceptable( stateContext, scriptInterface ) )
			{
				return true;
			}
		}
		return false;
	}

	protected const function IsDistanceToGroundAcceptable( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetDistanceToGround( scriptInterface ) <= GetStaticFloatParameterDefault( "minDistanceToGround", 2.0 ) )
		{
			return false;
		}
		return true;
	}

	protected const function IsFallSpeedAcceptable( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var playerFallingTooFast : Float;
		var verticalSpeed : Float;
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		playerFallingTooFast = stateContext.GetFloatParameter( 'VeryHardLandingFallingSpeed', true );
		if( verticalSpeed <= playerFallingTooFast )
		{
			return false;
		}
		return true;
	}

	protected const function ToSuperheroFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetStaticBoolParameterDefault( "autoTransitionToSuperheroFall", true ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "maxAirHoverTime", 0.0 ) ) )
		{
			return true;
		}
		if( ( !( GetStaticBoolParameterDefault( "autoTransitionToSuperheroFall", true ) ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "maxAirHoverTime", 0.0 ) ) ) && ( scriptInterface.IsActionJustTapped( 'ToggleCrouch' ) || scriptInterface.IsActionJustPressed( 'Crouch' ) ) )
		{
			return true;
		}
		return false;
	}

}

class AirHoverEvents extends LocomotionAirEvents
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var verticalSpeed : Float;
		super.OnEnter( stateContext, scriptInterface );
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		scriptInterface.PushAnimationEvent( 'AirHover' );
		PlaySound( 'lcm_wallrun_out', scriptInterface );
		AddUpwardsImpulse( stateContext, scriptInterface, verticalSpeed );
		stateContext.SetPermanentBoolParameter( 'forcedTemporaryUnequip', true, true );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.AirHover );
	}

	private function AddUpwardsImpulse( stateContext : StateContext, scriptInterface : StateGameScriptInterface, verticalSpeed : Float )
	{
		var verticalImpulse : Float;
		if( verticalSpeed <= -0.5 )
		{
			verticalImpulse = GetStaticFloatParameterDefault( "verticalUpwardsImpulse", 4.0 );
			AddVerticalImpulse( stateContext, verticalImpulse );
		}
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
	}

}

class SuperheroFallDecisions extends LocomotionAirDecisions
{
}

class SuperheroFallEvents extends LocomotionAirEvents
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		PlaySound( 'Player_double_jump', scriptInterface );
		scriptInterface.PushAnimationEvent( 'SuperHeroFall' );
		AddVerticalImpulse( stateContext, GetStaticFloatParameterDefault( "downwardsImpulseStrength", 0.0 ) );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.SuperheroFall );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
	}

}

class JumpDecisions extends LocomotionAirDecisions
{
	protected var m_jumpPressed : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Jump' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		m_jumpPressed = ListenerAction.GetValue( action ) > 0.0;
		EnableOnEnterCondition( true );
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var jumpPressedFlag : Bool;
		jumpPressedFlag = stateContext.GetConditionBool( 'JumpPressed' );
		if( !( jumpPressedFlag ) && !( m_jumpPressed ) )
		{
			EnableOnEnterCondition( false );
		}
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideElevator ) )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanJump ) ) )
		{
			return false;
		}
		if( scriptInterface.HasStatFlag( gamedataStatType.HasChargeJump ) || scriptInterface.HasStatFlag( gamedataStatType.HasAirHover ) )
		{
			if( ( ( GetActionHoldTime( stateContext, scriptInterface, 'Jump' ) < 0.15000001 ) && ( stateContext.GetConditionFloat( 'InputHoldTime' ) < 0.2 ) ) && scriptInterface.IsActionJustReleased( 'Jump' ) )
			{
				return true;
			}
		}
		else
		{
			if( jumpPressedFlag || scriptInterface.IsActionJustPressed( 'Jump' ) )
			{
				return true;
			}
		}
		return false;
	}

}

class JumpEvents extends LocomotionAirEvents
{

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		if( !( IsInRpgContext( scriptInterface ) ) )
		{
			stateContext.SetPermanentBoolParameter( 'VisionToggled', false, true );
		}
		scriptInterface.PushAnimationEvent( 'Jump' );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Jump ) ) );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Jump );
		LogSpecialMovementToTelemetry( scriptInterface, telemetryMovementType.Jump );
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
	}

}

class DoubleJumpDecisions extends JumpDecisions
{

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var currentNumberOfJumps : Int32;
		var jumpPressedFlag : Bool;
		jumpPressedFlag = stateContext.GetConditionBool( 'JumpPressed' );
		if( !( jumpPressedFlag ) && !( m_jumpPressed ) )
		{
			EnableOnEnterCondition( false );
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.HasDoubleJump ) ) )
		{
			return false;
		}
		if( scriptInterface.HasStatFlag( gamedataStatType.HasChargeJump ) || scriptInterface.HasStatFlag( gamedataStatType.HasAirHover ) )
		{
			return false;
		}
		if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator ) )
		{
			return false;
		}
		currentNumberOfJumps = stateContext.GetIntParameter( 'currentNumberOfJumps', true );
		if( currentNumberOfJumps >= GetStaticIntParameterDefault( "numberOfMultiJumps", 1 ) )
		{
			return false;
		}
		if( jumpPressedFlag || scriptInterface.IsActionJustPressed( 'Jump' ) )
		{
			return true;
		}
		return false;
	}

}

class DoubleJumpEvents extends LocomotionAirEvents
{

	public function OnEnterFromAirThrusters( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetPermanentIntParameter( 'currentNumberOfJumps', 1, true );
		OnEnter( stateContext, scriptInterface );
	}

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var currentNumberOfJumps : Int32;
		super.OnEnter( stateContext, scriptInterface );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		currentNumberOfJumps = stateContext.GetIntParameter( 'currentNumberOfJumps', true );
		currentNumberOfJumps += 1;
		stateContext.SetPermanentIntParameter( 'currentNumberOfJumps', currentNumberOfJumps, true );
		PlaySound( 'lcm_player_double_jump', scriptInterface );
		PlayRumble( scriptInterface, GetStaticStringParameterDefault( "rumbleOnEnter", "medium_fast" ) );
		scriptInterface.PushAnimationEvent( 'DoubleJump' );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Jump ) ) );
		stateContext.SetConditionBoolParameter( 'JumpPressed', false, true );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.DoubleJump );
		LogSpecialMovementToTelemetry( scriptInterface, telemetryMovementType.DoubleJump );
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
	}

}

class ChargeJumpDecisions extends LocomotionAirDecisions
{

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Jump' );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.IsButtonJustReleased( action ) )
		{
			EnableOnEnterCondition( true );
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		EnableOnEnterCondition( false );
		if( ( ( stateContext.GetConditionFloat( 'InputHoldTime' ) > 0.15000001 ) && scriptInterface.IsActionJustReleased( 'Jump' ) ) && scriptInterface.HasStatFlag( gamedataStatType.HasChargeJump ) )
		{
			if( scriptInterface.HasStatFlag( gamedataStatType.HasAirHover ) )
			{
				return false;
			}
			if( IsPlayerInAnyMenu( scriptInterface ) || IsRadialWheelOpen( scriptInterface ) )
			{
				return false;
			}
			if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
			{
				return false;
			}
			if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator ) )
			{
				return false;
			}
			return true;
		}
		return false;
	}

}

class ChargeJumpEvents extends LocomotionAirEvents
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var inputHoldTime : Float;
		super.OnEnter( stateContext, scriptInterface );
		inputHoldTime = stateContext.GetConditionFloat( 'InputHoldTime' );
		scriptInterface.PushAnimationEvent( 'ChargeJump' );
		PlaySound( 'lcm_player_double_jump', scriptInterface );
		PlayRumble( scriptInterface, GetStaticStringParameterDefault( "rumbleOnEnter", "medium_fast" ) );
		StartEffect( scriptInterface, 'charged_jump' );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.PressureWave" ) );
		SpawnLandingFxGameEffect( T"Attacks.PressureWave", scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Jump ) ) );
		SetChargeJumpParameters( stateContext, scriptInterface, inputHoldTime );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.ChargeJump );
		LogSpecialMovementToTelemetry( scriptInterface, telemetryMovementType.ChargedJump );
	}

	private function SetChargeJumpParameters( stateContext : StateContext, scriptInterface : StateGameScriptInterface, inputHoldTime : Float )
	{
		var upwardsGravity : Float;
		var downwardsGravity : Float;
		var nameSuffix : String;
		if( ( inputHoldTime >= GetStaticFloatParameterDefault( "minHoldTime", 0.1 ) ) && ( inputHoldTime <= GetStaticFloatParameterDefault( "medChargeHoldTime", 0.2 ) ) )
		{
			upwardsGravity = GetStaticFloatParameterDefault( "upwardsGravityMinCharge", -16.0 );
			downwardsGravity = GetStaticFloatParameterDefault( "downwardsGravityMinCharge", -16.0 );
			nameSuffix = "Low";
		}
		else if( ( inputHoldTime > GetStaticFloatParameterDefault( "medChargeHoldTime", 0.2 ) ) && ( inputHoldTime <= GetStaticFloatParameterDefault( "maxChargeHoldTime", 0.30000001 ) ) )
		{
			upwardsGravity = GetStaticFloatParameterDefault( "upwardsGravityMedCharge", -16.0 );
			downwardsGravity = GetStaticFloatParameterDefault( "downwardsGravityMedCharge", -16.0 );
			nameSuffix = "Medium";
		}
		else if( inputHoldTime >= GetStaticFloatParameterDefault( "maxChargeHoldTime", 0.30000001 ) )
		{
			upwardsGravity = GetStaticFloatParameterDefault( "upwardsGravityMaxCharge", -16.0 );
			downwardsGravity = GetStaticFloatParameterDefault( "downwardsGravityMaxCharge", -20.0 );
			nameSuffix = "High";
			AddVerticalImpulse( stateContext, GetStaticFloatParameterDefault( "verticalImpulse", 2.0 ) );
		}
		UpdateChargeJumpStats( stateContext, scriptInterface, upwardsGravity, downwardsGravity, nameSuffix );
	}

	private function UpdateChargeJumpStats( stateContext : StateContext, scriptInterface : StateGameScriptInterface, upwardsGravity : Float, downwardsGravity : Float, nameSuffix : String )
	{
		var statModifierTDBName : String;
		var locomotionParameters : LocomotionParameters;
		locomotionParameters = new LocomotionParameters;
		statModifierTDBName = m_statModifierTDBNameDefault + nameSuffix;
		SetModifierGroupForState( scriptInterface, statModifierTDBName );
		GetStateDefaultLocomotionParameters( locomotionParameters );
		locomotionParameters.SetUpwardsGravity( upwardsGravity );
		locomotionParameters.SetDownwardsGravity( downwardsGravity );
		locomotionParameters.SetDoJump( true );
		stateContext.SetTemporaryScriptableParameter( 'locomotionParameters', locomotionParameters, true );
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
	}

}

class HoverJumpDecisions extends LocomotionAirDecisions
{

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Jump' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		EnableOnEnterCondition( ListenerAction.GetValue( action ) > 0.0 );
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustHeld( 'Jump' ) )
		{
			if( !( scriptInterface.HasStatFlag( gamedataStatType.HasAirHover ) ) )
			{
				return false;
			}
			if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
			{
				return false;
			}
			if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator ) )
			{
				return false;
			}
			return true;
		}
		return false;
	}

}

class HoverJumpEvents extends LocomotionAirEvents
{

	protected virtual function SendHoverJumpStateToGraph( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : Int32 )
	{
		var animFeature : AnimFeature_HoverJumpData;
		animFeature = new AnimFeature_HoverJumpData;
		animFeature.state = state;
		scriptInterface.SetAnimationParameterFeature( 'HoverJumpData', animFeature );
	}

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SendHoverJumpStateToGraph( stateContext, scriptInterface, 1 );
		PlaySound( 'lcm_player_double_jump', scriptInterface );
		PlayRumble( scriptInterface, GetStaticStringParameterDefault( "rumbleOnEnter", "medium_fast" ) );
		StartEffect( scriptInterface, 'charged_jump' );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.PressureWave" ) );
		SpawnLandingFxGameEffect( T"Attacks.PressureWave", scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Jump ) ) );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.HoverJump );
		StatusEffectHelper.ApplyStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.HoverJumpPlayerBuff" );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var verticalSpeed : Float;
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		if( ( !( stateContext.GetBoolParameter( 'isAboutToLand', true ) ) && ( verticalSpeed <= -1.0 ) ) && ( GetDistanceToGround( scriptInterface ) <= 1.0 ) )
		{
			SendHoverJumpStateToGraph( stateContext, scriptInterface, 2 );
			stateContext.SetPermanentBoolParameter( 'isAboutToLand', true, true );
		}
		if( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.HoverJumpPlayerBuff" ) )
		{
			if( ( scriptInterface.GetActionValue( 'CameraAim' ) == 0.0 ) && ( scriptInterface.GetActionValue( 'Jump' ) > 0.0 ) )
			{
				AddUpwardsThrust( stateContext, scriptInterface, GetStaticFloatParameterDefault( "verticalImpulse", 4.0 ) * ( ( TimeDilatable )( scriptInterface.owner ) ).GetTimeDilationValue() );
				if( !( stateContext.GetBoolParameter( 'isHovering', true ) ) )
				{
					stateContext.RemovePermanentBoolParameter( 'isStabilising' );
					stateContext.SetPermanentBoolParameter( 'isHovering', true, true );
					UpdateHoverJumpStats( stateContext, scriptInterface, GetStaticFloatParameterDefault( "upwardsGravityOnThrust", -10.0 ), GetStaticFloatParameterDefault( "downwardsGravityOnThrust", -5.0 ), "" );
				}
			}
			else if( GetStaticBoolParameterDefault( "stabilizeOnAim", false ) && ( scriptInterface.GetActionValue( 'CameraAim' ) > 0.0 ) )
			{
				if( !( stateContext.GetBoolParameter( 'isStabilising', true ) ) )
				{
					if( verticalSpeed <= -0.5 )
					{
						AddUpwardsThrust( stateContext, scriptInterface, GetStaticFloatParameterDefault( "verticalImpulseStabilize", 4.0 ) * ( ( TimeDilatable )( scriptInterface.owner ) ).GetTimeDilationValue() );
					}
					stateContext.RemovePermanentBoolParameter( 'isHovering' );
					stateContext.SetPermanentBoolParameter( 'isStabilising', true, true );
					UpdateHoverJumpStats( stateContext, scriptInterface, GetStaticFloatParameterDefault( "upwardsGravityOnStabilize", -10.0 ), GetStaticFloatParameterDefault( "downwardsGravityOnStabilize", -3.0 ), "Thrust" );
					PlaySound( 'lcm_wallrun_in', scriptInterface );
				}
			}
		}
		else
		{
			UpdateHoverJumpStats( stateContext, scriptInterface, GetStaticFloatParameterDefault( "upwardsGravity", -16.0 ), GetStaticFloatParameterDefault( "downwardsGravity", -16.0 ), "" );
		}
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
	}

	private function UpdateHoverJumpStats( stateContext : StateContext, scriptInterface : StateGameScriptInterface, upwardsGravity : Float, downwardsGravity : Float, nameSuffix : String )
	{
		var statModifierTDBName : String;
		var locomotionParameters : LocomotionParameters;
		locomotionParameters = new LocomotionParameters;
		statModifierTDBName = m_statModifierTDBNameDefault + nameSuffix;
		SetModifierGroupForState( scriptInterface, statModifierTDBName );
		GetStateDefaultLocomotionParameters( locomotionParameters );
		locomotionParameters.SetUpwardsGravity( upwardsGravity );
		locomotionParameters.SetDownwardsGravity( downwardsGravity );
		locomotionParameters.SetDoJump( true );
		stateContext.SetTemporaryScriptableParameter( 'locomotionParameters', locomotionParameters, true );
	}

	private function AddUpwardsThrust( stateContext : StateContext, scriptInterface : StateGameScriptInterface, verticalImpulse : Float )
	{
		if( verticalImpulse > 0.0 )
		{
			AddVerticalImpulse( stateContext, verticalImpulse );
		}
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		CleanUpOnExit( stateContext, scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		CleanUpOnExit( stateContext, scriptInterface );
	}

	private function CleanUpOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendHoverJumpStateToGraph( stateContext, scriptInterface, 0 );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.Default ) ) );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.HoverJumpPlayerBuff" );
		UpdateHoverJumpStats( stateContext, scriptInterface, -16.0, -16.0, "" );
		stateContext.RemovePermanentBoolParameter( 'isStabilising' );
		stateContext.RemovePermanentBoolParameter( 'isHovering' );
		stateContext.RemovePermanentBoolParameter( 'isAboutToLand' );
	}

}

class DodgeAirDecisions extends LocomotionAirDecisions
{

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		scriptInterface.executionOwner.RegisterInputListener( this, 'Dodge' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeDirection' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeForward' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeRight' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeLeft' );
		scriptInterface.executionOwner.RegisterInputListener( this, 'DodgeBack' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		if( ListenerAction.IsButtonJustPressed( action ) )
		{
			EnableOnEnterCondition( true );
		}
	}

	protected export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var currentNumberOfAirDodges : Int32;
		EnableOnEnterCondition( false );
		if( !( scriptInterface.HasStatFlag( gamedataStatType.HasDodgeAir ) ) )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanAimWhileDodging ) ) && IsInUpperBodyState( stateContext, 'aimingState' ) )
		{
			return false;
		}
		if( IsCurrentFallSpeedTooFastToEnter( stateContext, scriptInterface ) )
		{
			return false;
		}
		currentNumberOfAirDodges = stateContext.GetIntParameter( 'currentNumberOfAirDodges', true );
		if( currentNumberOfAirDodges >= GetStaticIntParameterDefault( "numberOfAirDodges", 1 ) )
		{
			return false;
		}
		if( WantsToDodge( stateContext, scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected const virtual function ToFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isKerenzikovStateActive : Bool;
		var isKerenzikovEnd : Bool;
		isKerenzikovStateActive = stateContext.GetStateMachineCurrentState( 'TimeDilation' ) == 'kerenzikov';
		if( !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeAirBuff" ) ) )
		{
			return !( isKerenzikovStateActive );
		}
		isKerenzikovEnd = isKerenzikovStateActive && !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.KerenzikovPlayerBuff" ) );
		if( isKerenzikovEnd )
		{
			return true;
		}
		return false;
	}

}

class DodgeAirEvents extends LocomotionAirEvents
{
	default m_updateInputToggles = false;

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var currentNumberOfAirDodges : Int32;
		super.OnEnter( stateContext, scriptInterface );
		currentNumberOfAirDodges = stateContext.GetIntParameter( 'currentNumberOfAirDodges', true );
		currentNumberOfAirDodges += 1;
		stateContext.SetPermanentIntParameter( 'currentNumberOfAirDodges', currentNumberOfAirDodges, true );
		Dodge( stateContext, scriptInterface );
		PlayRumbleBasedOnDodgeDirection( stateContext, scriptInterface );
		scriptInterface.PushAnimationEvent( 'Dodge' );
		stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
		stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		StatusEffectHelper.ApplyStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeAirBuff" );
		ConsumeStaminaBasedOnLocomotionState( stateContext, scriptInterface );
		LogSpecialMovementToTelemetry( scriptInterface, telemetryMovementType.AirDodge );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, ( ( Int32 )( gamePSMLocomotionStates.DodgeAir ) ) );
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( scriptInterface.IsActionJustPressed( 'Jump' ) )
		{
			stateContext.SetConditionBoolParameter( 'JumpPressed', true, true );
		}
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.DodgeAirBuff" );
	}

	protected function Dodge( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impulseValue : Float;
		var impulse : Vector4;
		var dodgeHeading : Float;
		impulseValue = GetStaticFloatParameterDefault( "impulse", 10.0 );
		dodgeHeading = stateContext.GetConditionFloat( 'DodgeDirection' );
		impulse = Vector4.FromHeading( AngleNormalize180( scriptInterface.executionOwner.GetWorldYaw() + dodgeHeading ) ) * impulseValue;
		AddImpulse( stateContext, impulse );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.DodgeAir );
	}

}

abstract class FailedLandingAbstractDecisions extends AbstractLandDecisions
{

	public export const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() >= GetStaticFloatParameterDefault( "duration", 2.5 );
	}

}

abstract class FailedLandingAbstractEvents extends AbstractLandEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
	}

}

class RegularLandDecisions extends AbstractLandDecisions
{
}

class RegularLandEvents extends AbstractLandEvents
{

	public function OnEnterFromLadderCrouch( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		m_blockLandingStimBroadcasting = true;
		OnEnter( stateContext, scriptInterface );
	}

	public export function OnEnterFromUnsecureFootingFall( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetConditionBoolParameter( 'blockEnteringSlide', true, true );
		OnEnter( stateContext, scriptInterface );
	}

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		GameObject.PlayVoiceOver( scriptInterface.owner, 'regularLanding', 'Scripts:RegularLandEvents' );
		EvaluateTransitioningToSlideAfterLanding( stateContext, scriptInterface );
		ShouldTriggerDestruction( stateContext, scriptInterface );
		EvaluatePlayingLandingVFX( stateContext, scriptInterface );
		BroadcastLandingStim( stateContext, scriptInterface, gamedataStimType.LandingRegular );
		super.OnEnter( stateContext, scriptInterface );
		TryPlayRumble( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.RegularLand );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.RegularLand ) ) );
	}

	protected function EvaluateTransitioningToSlideAfterLanding( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var inAirTime : StateResultFloat;
		var velocity : Vector4;
		var currentSpeed : Float;
		if( !( stateContext.GetConditionBool( 'CrouchToggled' ) ) )
		{
			return;
		}
		inAirTime = stateContext.GetPermanentFloatParameter( 'InAirDuration' );
		velocity = GetLinearVelocity( scriptInterface );
		currentSpeed = Vector4.Length2D( velocity );
		if( ( ( inAirTime.valid && ( inAirTime.value > 0.69999999 ) ) && ( currentSpeed < 5.0 ) ) || ( inAirTime.valid && ( inAirTime.value < 0.5 ) ) )
		{
			stateContext.SetConditionBoolParameter( 'blockEnteringSlide', true, true );
		}
	}

	protected function TryPlayRumble( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impactSpeed : StateResultFloat;
		var inAirTime : StateResultFloat;
		impactSpeed = stateContext.GetPermanentFloatParameter( 'ImpactSpeed' );
		inAirTime = stateContext.GetPermanentFloatParameter( 'InAirDuration' );
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice ) )
		{
			return;
		}
		if( stateContext.GetConditionBool( 'CrouchToggled' ) && ( impactSpeed.valid && ( impactSpeed.value > GetFallingSpeedBasedOnHeight( scriptInterface, 1.20000005 ) ) ) )
		{
			return;
		}
		if( impactSpeed.valid && ( impactSpeed.value < GetFallingSpeedBasedOnHeight( scriptInterface, 0.66000003 ) ) )
		{
			PlayRumble( scriptInterface, "light_pulse" );
		}
		else if( inAirTime.valid && ( inAirTime.value > 0.333 ) )
		{
			PlayRumble( scriptInterface, "light_pulse" );
		}
	}

	protected function ShouldTriggerDestruction( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impactSpeed : StateResultFloat;
		impactSpeed = stateContext.GetPermanentFloatParameter( 'ImpactSpeed' );
		if( impactSpeed.value < GetFallingSpeedBasedOnHeight( scriptInterface, 2.5 ) )
		{
			PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.PressureWave" ) );
			SpawnLandingFxGameEffect( T"Attacks.PressureWave", scriptInterface );
		}
	}

}

class HardLandDecisions extends FailedLandingAbstractDecisions
{
}

class HardLandEvents extends FailedLandingAbstractEvents
{

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		PlayHardLandingEffects( stateContext, scriptInterface );
		BroadcastLandingStim( stateContext, scriptInterface, gamedataStimType.LandingHard );
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.HardLand );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.HardLand ) ) );
	}

}

class VeryHardLandDecisions extends FailedLandingAbstractDecisions
{
}

class VeryHardLandEvents extends FailedLandingAbstractEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		PlayVeryHardLandingEffects( stateContext, scriptInterface );
		BroadcastLandingStim( stateContext, scriptInterface, gamedataStimType.LandingVeryHard );
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.VeryHardLand );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.VeryHardLand ) ) );
	}

}

class DeathLandDecisions extends FailedLandingAbstractDecisions
{
}

class DeathLandEvents extends FailedLandingAbstractEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		PlayDeathLandingEffects( stateContext, scriptInterface );
		BroadcastLandingStim( stateContext, scriptInterface, gamedataStimType.LandingVeryHard );
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.DeathLand );
		ProcessPermanentBoolParameterToggle( 'WalkToggled', false, stateContext );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.DeathLand ) ) );
	}

}

class SuperheroLandDecisions extends AbstractLandDecisions
{

	public const function ToSuperheroLandRecovery( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() >= GetStaticFloatParameterDefault( "stateDuration", 0.76999998 );
	}

}

class SuperheroLandEvents extends AbstractLandEvents
{

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var broadcaster : StimBroadcasterComponent;
		super.OnEnter( stateContext, scriptInterface );
		scriptInterface.PushAnimationEvent( 'SuperheroLand' );
		PlaySound( 'lcm_wallrun_in', scriptInterface );
		StartEffect( scriptInterface, 'stagger_effect' );
		stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		PlayRumble( scriptInterface, "heavy_fast" );
		PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.SuperheroLanding" ) );
		SpawnLandingFxGameEffect( T"Attacks.SuperheroLanding", scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.SuperheroLand );
		broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.LandingVeryHard );
		}
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.SuperheroLand ) ) );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.Default ) ) );
	}

}

class SuperheroLandRecoveryDecisions extends AbstractLandDecisions
{

	public const function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() >= GetStaticFloatParameterDefault( "stateDuration", 0.40000001 );
	}

}

class SuperheroLandRecoveryEvents extends AbstractLandEvents
{

	protected virtual function SendAnimFeature( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : Int32 )
	{
		var animFeature : AnimFeature_SuperheroLand;
		animFeature = new AnimFeature_SuperheroLand;
		animFeature.state = state;
		scriptInterface.SetAnimationParameterFeature( 'SuperheroLand', animFeature );
	}

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.SuperheroLandRecovery );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.SuperheroLandRecovery ) ) );
	}

	public override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendAnimFeature( stateContext, scriptInterface, 0 );
		stateContext.SetPermanentBoolParameter( 'forcedTemporaryUnequip', false, true );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, ( ( Int32 )( gamePSMLandingState.Default ) ) );
	}

}

abstract class WallCollisionHelpers
{

	public static function GetWallCollision( const scriptInterface : StateGameScriptInterface, playerPosition : Vector4, up : Vector4, capsuleRadius : Float, out wallCollision : ControllerHit ) : Bool
	{
		var collisionReport : array< ControllerHit >;
		var hit : ControllerHit;
		var playerPositionCentreOfSphere : Vector4;
		var sideCollisionFound : Bool;
		var collisionIndex : Int32;
		var touchDirection : Vector4;
		collisionReport = scriptInterface.GetCollisionReport();
		playerPositionCentreOfSphere = playerPosition + ( up * capsuleRadius );
		sideCollisionFound = false;
		for( collisionIndex = 0; ( collisionIndex < collisionReport.Size() ) && !( sideCollisionFound ); collisionIndex += 1 )
		{
			hit = collisionReport[ collisionIndex ];
			touchDirection = Vector4.Normalize( hit.worldPos - playerPositionCentreOfSphere );
			if( touchDirection.Z >= 0.0 )
			{
				wallCollision = hit;
				return true;
			}
		}
		return false;
	}

}

class StatusEffectDecisions extends LocomotionGroundDecisions
{
	private var m_executionOwner : weak< GameObject >;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_statusEffectEnumName : String;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		m_statusEffectEnumName = GetStaticStringParameterDefault( "statusEffectEnumName", "" );
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( scriptInterface.owner.GetEntityID(), m_statusEffectListener );
		m_executionOwner = scriptInterface.executionOwner;
		EnableOnEnterCondition( StatusEffectSystem.ObjectHasStatusEffectOfTypeName( m_executionOwner, m_statusEffectEnumName ) );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_statusEffectListener = NULL;
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_statusEffectEnumName == statusEffect.StatusEffectType().EnumName() )
		{
			EnableOnEnterCondition( true );
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_statusEffectEnumName == statusEffect.StatusEffectType().EnumName() )
		{
			EnableOnEnterCondition( StatusEffectSystem.ObjectHasStatusEffectOfTypeName( m_executionOwner, m_statusEffectEnumName ) );
		}
	}

	public export const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	protected export const virtual function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( HasMovementAffiliatedStatusEffect( stateContext, scriptInterface ) );
	}

	protected const virtual function ToRegularFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( HasMovementAffiliatedStatusEffect( stateContext, scriptInterface ) ) && !( IsTouchingGround( scriptInterface ) );
	}

	private const function HasMovementAffiliatedStatusEffect( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var statusEffectRecord : weak< StatusEffect_Record >;
		statusEffectRecord = ( ( StatusEffect_Record )( stateContext.GetConditionScriptableParameter( 'AffectMovementStatusEffectRecord' ) ) );
		return StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.owner, statusEffectRecord.GetID() );
	}

}

class StatusEffectEvents extends LocomotionGroundEvents
{
	var m_statusEffectRecord : weak< StatusEffect_Record >;
	var m_playerStatusEffectRecordData : weak< StatusEffectPlayerData_Record >;
	var m_animFeatureStatusEffect : AnimFeature_StatusEffect;
	private var m_statusEffectEnumName : String;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnAttach( stateContext, scriptInterface );
		m_statusEffectEnumName = GetStaticStringParameterDefault( "statusEffectEnumName", "" );
	}

	public export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var appliedStatusEffects : array< StatusEffect >;
		super.OnEnter( stateContext, scriptInterface );
		scriptInterface.GetStatusEffectSystem().GetAppliedEffectsOfTypeName( scriptInterface.executionOwnerEntityID, m_statusEffectEnumName, appliedStatusEffects );
		if( appliedStatusEffects.Size() > 0 )
		{
			m_statusEffectRecord = appliedStatusEffects[ 0 ].GetRecord();
			m_playerStatusEffectRecordData = TweakDBInterface.GetStatusEffectRecord( m_statusEffectRecord.GetID() ).PlayerData();
		}
		stateContext.SetConditionScriptableParameter( 'AffectMovementStatusEffectRecord', m_statusEffectRecord, true );
		stateContext.SetConditionScriptableParameter( 'PlayerStatusEffectRecordData', m_playerStatusEffectRecordData, true );
		if( ShouldForceUnequipWeapon() )
		{
			stateContext.SetPermanentBoolParameter( 'forcedTemporaryUnequip', true, true );
		}
		ProcessStatusEffectBasedOnType( scriptInterface, stateContext, GetStatusEffectType( scriptInterface, stateContext ) );
		if( ShouldRotateToSource() )
		{
			RotateToKnockdownSource( stateContext, scriptInterface );
		}
	}

	protected function RotateToKnockdownSource( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var adjustRequest : AdjustTransformWithDurations;
		var direction : Vector4;
		direction = GetStatusEffectHitDirection( scriptInterface );
		if( Vector4.IsZero( direction ) )
		{
			return;
		}
		adjustRequest = new AdjustTransformWithDurations;
		adjustRequest.SetPosition( Vector4( 0.0, 0.0, 0.0, 0.0 ) );
		adjustRequest.SetSlideDuration( -1.0 );
		adjustRequest.SetRotation( Quaternion.BuildFromDirectionVector( -( direction ), Vector4( 0.0, 0.0, 1.0, 0.0 ) ) );
		adjustRequest.SetRotationDuration( 0.5 );
		stateContext.SetTemporaryScriptableParameter( 'adjustTransform', adjustRequest, true );
	}

	private function ProcessStatusEffectBasedOnType( scriptInterface : StateGameScriptInterface, stateContext : StateContext, type : gamedataStatusEffectType )
	{
		if( !( m_statusEffectRecord ) )
		{
			return;
		}
		if( !( ShouldUseCustomAdditives( scriptInterface, type ) ) )
		{
			if( type == gamedataStatusEffectType.Stunned )
			{
				scriptInterface.PushAnimationEvent( 'StaggerHit' );
				if( !( StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.Parry" ) ) )
				{
					stateContext.SetPermanentBoolParameter( 'InterruptMelee', m_playerStatusEffectRecordData.ForceSafeWeapon(), true );
				}
			}
			SendCameraShakeDataToGraph( scriptInterface, stateContext, GetCameraShakeStrength() );
			SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.Start );
		}
		ApplyCounterForce( scriptInterface, stateContext, GetImpulseDistance(), GetScaleImpulseDistance() );
	}

	private function SendCameraShakeDataToGraph( scriptInterface : StateGameScriptInterface, stateContext : StateContext, camShakeStrength : Float )
	{
		var animFeatureHitReaction : AnimFeature_PlayerHitReactionData;
		animFeatureHitReaction = new AnimFeature_PlayerHitReactionData;
		animFeatureHitReaction.hitStrength = camShakeStrength;
		scriptInterface.SetAnimationParameterFeature( 'HitReactionData', animFeatureHitReaction );
	}

	protected export override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
	}

	protected const function GetTimeInStatusEffect( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Float
	{
		var startTime : StateResultFloat;
		var timeInState : Float;
		startTime = stateContext.GetPermanentFloatParameter( StatusEffectHelper.GetStateStartTimeKey() );
		if( !( startTime.valid ) )
		{
			return 0.0;
		}
		timeInState = EngineTime.ToFloat( GameInstance.GetTimeSystem( scriptInterface.owner.GetGame() ).GetSimTime() ) - startTime.value;
		return timeInState;
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnForcedExit( stateContext, scriptInterface );
		DefaultOnExit( stateContext, scriptInterface );
	}

	public export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		DefaultOnExit( stateContext, scriptInterface );
	}

	protected function OnExitToFall( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		DefaultOnExit( stateContext, scriptInterface );
		scriptInterface.PushAnimationEvent( 'StraightToFall' );
	}

	protected virtual function CommonOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		RemoveStatusEffect( scriptInterface, stateContext );
		if( ShouldForceUnequipWeapon() )
		{
			stateContext.SetPermanentBoolParameter( 'forcedTemporaryUnequip', false, true );
		}
		stateContext.RemovePermanentFloatParameter( StatusEffectHelper.GetStateStartTimeKey() );
	}

	protected function DefaultOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( m_animFeatureStatusEffect )
		{
			m_animFeatureStatusEffect.Clear();
		}
		scriptInterface.SetAnimationParameterFeature( 'StatusEffect', m_animFeatureStatusEffect );
		if( GetStaticBoolParameterDefault( "forceExitToStand", false ) )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		}
		CommonOnExit( stateContext, scriptInterface );
	}

	protected virtual function SendStatusEffectAnimDataToGraph( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : EKnockdownStates )
	{
		if( !( m_animFeatureStatusEffect ) )
		{
			m_animFeatureStatusEffect = new AnimFeature_StatusEffect;
		}
		stateContext.SetPermanentFloatParameter( StatusEffectHelper.GetStateStartTimeKey(), EngineTime.ToFloat( GameInstance.GetTimeSystem( scriptInterface.owner.GetGame() ).GetSimTime() ), true );
		StatusEffectHelper.PopulateStatusEffectAnimData( scriptInterface.owner, m_statusEffectRecord, state, GetStatusEffectHitDirection( scriptInterface ), m_animFeatureStatusEffect );
		scriptInterface.SetAnimationParameterFeature( 'StatusEffect', m_animFeatureStatusEffect );
	}

	protected function ApplyCounterForce( scriptInterface : StateGameScriptInterface, stateContext : StateContext, desiredDistance : Float, scaleDistance : Bool )
	{
		var direction : Vector4;
		var ev : PSMImpulse;
		var impulseDir : Vector4;
		var speed : Float;
		if( desiredDistance <= 0.0 )
		{
			return;
		}
		direction = GetStatusEffectHitDirection( scriptInterface );
		direction.Z = 0.0;
		if( scaleDistance )
		{
			desiredDistance *= Vector4.Length2D( direction );
		}
		if( Vector4.IsZero( direction ) )
		{
			direction = scriptInterface.owner.GetWorldForward() * -1.0;
		}
		else
		{
			Vector4.Normalize2D( direction );
		}
		speed = GetSpeedBasedOnDistance( scriptInterface, desiredDistance );
		impulseDir = direction * speed;
		ev = new PSMImpulse;
		ev.id = 'impulse';
		ev.impulse = impulseDir;
		scriptInterface.owner.QueueEvent( ev );
	}

	private const function RemoveStatusEffect( const scriptInterface : StateGameScriptInterface, const stateContext : StateContext )
	{
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.owner, m_statusEffectRecord.GetID() );
		stateContext.RemoveConditionScriptableParameter( 'PlayerStatusEffectRecordData' );
	}

	private const function GetStatusEffectType( const scriptInterface : StateGameScriptInterface, const stateContext : StateContext ) : gamedataStatusEffectType
	{
		return m_statusEffectRecord.StatusEffectType().Type();
	}

	protected const function GetStatusEffectRemainingDuration( const scriptInterface : StateGameScriptInterface, const stateContext : StateContext ) : Float
	{
		return StatusEffectHelper.GetStatusEffectByID( scriptInterface.owner, m_statusEffectRecord.GetID() ).GetRemainingDuration();
	}

	protected const function GetStatusEffectHitDirection( const scriptInterface : StateGameScriptInterface ) : Vector4
	{
		return StatusEffectHelper.GetStatusEffectByID( scriptInterface.owner, m_statusEffectRecord.GetID() ).GetDirection();
	}

	protected const function GetStartupAnimDuration() : Float
	{
		return m_playerStatusEffectRecordData.StartupAnimDuration();
	}

	protected const function ShouldRotateToSource() : Bool
	{
		return m_playerStatusEffectRecordData.RotateToSource();
	}

	protected const function GetAirRecoveryAnimDuration() : Float
	{
		return m_playerStatusEffectRecordData.AirRecoveryAnimDuration();
	}

	protected const function GetRecoveryAnimDuration() : Float
	{
		return m_playerStatusEffectRecordData.RecoveryAnimDuration();
	}

	protected const function GetLandAnimDuration() : Float
	{
		return m_playerStatusEffectRecordData.LandAnimDuration();
	}

	private const function GetImpulseDistance() : Float
	{
		return m_playerStatusEffectRecordData.ImpulseDistance();
	}

	private const function GetScaleImpulseDistance() : Bool
	{
		return m_playerStatusEffectRecordData.ScaleImpulseDistance();
	}

	private const function GetCameraShakeStrength() : Float
	{
		return m_playerStatusEffectRecordData.CameraShakeStrength();
	}

	private const function ShouldForceUnequipWeapon() : Bool
	{
		return m_playerStatusEffectRecordData.ForceUnequipWeapon();
	}

	protected const function ShouldUseCustomAdditives( const scriptInterface : StateGameScriptInterface, type : gamedataStatusEffectType ) : Bool
	{
		return type == gamedataStatusEffectType.Stunned && StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'UseCustomAdditives' );
	}

}

class KnockdownDecisions extends StatusEffectDecisions
{

	protected const override function ToStand( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var canExit : StateResultBool;
		canExit = stateContext.GetTemporaryBoolParameter( StatusEffectHelper.GetCanExitKnockdownKey() );
		if( canExit.valid )
		{
			return super.ToStand( stateContext, scriptInterface );
		}
		return false;
	}

	protected const override function ToRegularFall( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var canExit : StateResultBool;
		canExit = stateContext.GetTemporaryBoolParameter( StatusEffectHelper.GetCanExitKnockdownKey() );
		if( canExit.valid )
		{
			return super.ToRegularFall( stateContext, scriptInterface );
		}
		return false;
	}

	protected const virtual function ToSecondaryKnockdown( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var canTriggerSecondaryKnockdown : StateResultBool;
		canTriggerSecondaryKnockdown = stateContext.GetPermanentBoolParameter( StatusEffectHelper.TriggerSecondaryKnockdownKey() );
		if( canTriggerSecondaryKnockdown.valid )
		{
			return super.EnterCondition( stateContext, scriptInterface );
		}
		return false;
	}

}

class KnockdownEvents extends StatusEffectEvents
{
	var m_cachedPlayerVelocity : Vector4;
	var m_secondaryKnockdownDir : Vector4;
	var m_secondaryKnockdownTimer : Float;
	var m_playedImpactAnim : Bool;
	var m_frictionForceApplied : Bool;
	var m_frictionForceAppliedLastFrame : Bool;
	var m_delayDamageFrame : Bool;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetDetailedState( scriptInterface, gamePSMDetailedLocomotionStates.Knockdown );
		super.OnEnter( stateContext, scriptInterface );
		m_playedImpactAnim = false;
		m_frictionForceApplied = false;
		m_frictionForceAppliedLastFrame = false;
		m_delayDamageFrame = false;
		m_secondaryKnockdownTimer = -1.0;
		m_cachedPlayerVelocity = GetLinearVelocity( scriptInterface );
	}

	protected override function CommonOnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.CommonOnExit( stateContext, scriptInterface );
		stateContext.RemovePermanentBoolParameter( StatusEffectHelper.TriggerSecondaryKnockdownKey() );
	}

	protected override function SendStatusEffectAnimDataToGraph( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : EKnockdownStates )
	{
		if( state == EKnockdownStates.Land && ( m_animFeatureStatusEffect.state != ( ( Int32 )( state ) ) ) )
		{
			SetModifierGroupForState( scriptInterface, "PlayerLocomotion.player_locomotion_data_KnockdownLand" );
		}
		super.SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, state );
	}

	private function UpdateStatusEffectAnimStates( timeDelta : Float, scriptInterface : StateGameScriptInterface, stateContext : StateContext )
	{
		switch( ( ( EKnockdownStates )( m_animFeatureStatusEffect.state ) ) )
		{
			case EKnockdownStates.Start:
				if( GetTimeInStatusEffect( stateContext, scriptInterface ) >= GetStartupAnimDuration() )
				{
					if( IsTouchingGround( scriptInterface ) )
					{
						SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.Land );
					}
					else
					{
						SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.FallLoop );
					}
				}
			break;
			case EKnockdownStates.FallLoop:
				if( IsTouchingGround( scriptInterface ) )
				{
					SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.Land );
				}
				else if( GetStatusEffectRemainingDuration( scriptInterface, stateContext ) <= GetAirRecoveryAnimDuration() )
				{
					SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.AirRecovery );
				}
			break;
			case EKnockdownStates.Land:
				if( ( GetTimeInStatusEffect( stateContext, scriptInterface ) >= GetLandAnimDuration() ) && ( GetStatusEffectRemainingDuration( scriptInterface, stateContext ) <= GetRecoveryAnimDuration() ) )
				{
					SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.Recovery );
				}
			break;
			case EKnockdownStates.Recovery:
				if( GetTimeInStatusEffect( stateContext, scriptInterface ) >= GetRecoveryAnimDuration() )
				{
					stateContext.SetTemporaryBoolParameter( StatusEffectHelper.GetCanExitKnockdownKey(), true, true );
				}
			break;
			case EKnockdownStates.AirRecovery:
				if( IsTouchingGround( scriptInterface ) )
				{
					SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.Land );
				}
				else if( GetTimeInStatusEffect( stateContext, scriptInterface ) >= GetAirRecoveryAnimDuration() )
				{
					stateContext.SetTemporaryBoolParameter( StatusEffectHelper.GetCanExitKnockdownKey(), true, true );
				}
			break;
			default:
				break;
		}
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var impulseEvent : PSMImpulse;
		var collisionFrictionForce : Vector4;
		var frictionForceScale : Float;
		var startupInterruptPoint : Float;
		var impactDirection : Int32;
		var playImpact : Bool;
		var triggerSecondaryKnockdown : Bool;
		var currentVelocity : Vector4;
		var velocityChangeDir : Vector4;
		var velocityChangeMag : Float;
		impactDirection = -1;
		playImpact = false;
		triggerSecondaryKnockdown = false;
		UpdateStatusEffectAnimStates( timeDelta, scriptInterface, stateContext );
		UpdateQueuedSecondaryKnockdown( stateContext, scriptInterface, timeDelta );
		super.OnUpdate( timeDelta, stateContext, scriptInterface );
		if( m_frictionForceAppliedLastFrame )
		{
			m_frictionForceAppliedLastFrame = false;
			return;
		}
		currentVelocity = GetLinearVelocity( scriptInterface );
		velocityChangeDir = currentVelocity - m_cachedPlayerVelocity;
		velocityChangeMag = Vector4.Length( velocityChangeDir );
		if( velocityChangeMag > 0.001 )
		{
			velocityChangeDir *= ( 1.0 / velocityChangeMag );
		}
		if( ( velocityChangeMag > 7.0 ) && ( Vector4.Dot( velocityChangeDir, m_cachedPlayerVelocity ) < 0.0 ) )
		{
			if( !( m_delayDamageFrame ) )
			{
				m_delayDamageFrame = true;
				playImpact = true;
				impactDirection = GameObject.GetLocalAngleForDirectionInInt( velocityChangeDir, scriptInterface.owner );
				currentVelocity = m_cachedPlayerVelocity;
			}
			else
			{
				m_delayDamageFrame = false;
				frictionForceScale = 0.0;
				if( velocityChangeMag > 25.0 )
				{
					frictionForceScale = 0.89999998;
					PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.HardWallImpact" ) );
					triggerSecondaryKnockdown = true;
				}
				else if( velocityChangeMag > 15.0 )
				{
					frictionForceScale = 0.60000002;
					PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.MediumWallImpact" ) );
					triggerSecondaryKnockdown = true;
				}
				else
				{
					frictionForceScale = 0.30000001;
					PrepareGameEffectAoEAttack( stateContext, scriptInterface, TweakDBInterface.GetAttackRecord( T"Attacks.LightWallImpact" ) );
					triggerSecondaryKnockdown = Vector4.Length2D( collisionFrictionForce ) < 1.0;
				}
				if( frictionForceScale > 0.0 )
				{
					if( !( m_frictionForceApplied ) )
					{
						m_frictionForceApplied = true;
						m_frictionForceAppliedLastFrame = true;
						impulseEvent = new PSMImpulse;
						impulseEvent.id = 'impulse';
						impulseEvent.impulse = currentVelocity * -( frictionForceScale );
						currentVelocity += impulseEvent.impulse;
						scriptInterface.owner.QueueEvent( impulseEvent );
					}
				}
			}
		}
		else
		{
			m_delayDamageFrame = false;
		}
		if( playImpact != m_animFeatureStatusEffect.playImpact )
		{
			if( !( m_playedImpactAnim ) )
			{
				m_playedImpactAnim = playImpact;
			}
			if( playImpact )
			{
				m_animFeatureStatusEffect.playImpact = true;
				m_animFeatureStatusEffect.impactDirection = impactDirection;
			}
			else
			{
				m_animFeatureStatusEffect.playImpact = false;
			}
			scriptInterface.SetAnimationParameterFeature( 'StatusEffect', m_animFeatureStatusEffect );
		}
		if( m_playedImpactAnim && ( m_animFeatureStatusEffect.state == ( ( Int32 )( EKnockdownStates.Start ) ) ) )
		{
			startupInterruptPoint = m_playerStatusEffectRecordData.StartupAnimInterruptPoint();
			if( startupInterruptPoint >= 0.0 )
			{
				if( GetTimeInStatusEffect( stateContext, scriptInterface ) >= startupInterruptPoint )
				{
					SendStatusEffectAnimDataToGraph( stateContext, scriptInterface, EKnockdownStates.FallLoop );
				}
			}
		}
		if( triggerSecondaryKnockdown )
		{
			QueueSecondaryKnockdown( stateContext, scriptInterface, velocityChangeDir );
		}
		m_cachedPlayerVelocity = currentVelocity;
	}

	protected function QueueSecondaryKnockdown( stateContext : StateContext, scriptInterface : StateGameScriptInterface, knockdownDir : Vector4 )
	{
		var startupInterruptPoint : Float;
		if( m_secondaryKnockdownTimer <= 0.0 )
		{
			m_secondaryKnockdownTimer = 0.1;
			m_secondaryKnockdownDir = knockdownDir;
			if( m_animFeatureStatusEffect.state == ( ( Int32 )( EKnockdownStates.Start ) ) )
			{
				startupInterruptPoint = m_playerStatusEffectRecordData.StartupAnimInterruptPoint();
				if( startupInterruptPoint < 0.0 )
				{
					startupInterruptPoint = m_playerStatusEffectRecordData.StartupAnimDuration();
				}
				m_secondaryKnockdownTimer += ( startupInterruptPoint - GetTimeInStatusEffect( stateContext, scriptInterface ) );
			}
		}
	}

	protected function UpdateQueuedSecondaryKnockdown( stateContext : StateContext, scriptInterface : StateGameScriptInterface, deltaTime : Float )
	{
		var statusEffectRecord : weak< StatusEffect_Record >;
		var stackcount : Uint32;
		stackcount = 1;
		if( ( m_secondaryKnockdownTimer > 0.0 ) && ( m_animFeatureStatusEffect.state < ( ( Int32 )( EKnockdownStates.Land ) ) ) )
		{
			m_secondaryKnockdownTimer -= deltaTime;
			if( m_secondaryKnockdownTimer <= 0.0 )
			{
				stateContext.SetPermanentBoolParameter( StatusEffectHelper.TriggerSecondaryKnockdownKey(), true, true );
				statusEffectRecord = TweakDBInterface.GetStatusEffectRecord( T"BaseStatusEffect.SecondaryKnockdown" );
				GameInstance.GetStatusEffectSystem( scriptInterface.owner.GetGame() ).ApplyStatusEffect( scriptInterface.executionOwnerEntityID, statusEffectRecord.GetID(), GameObject.GetTDBID( scriptInterface.owner ), scriptInterface.ownerEntityID, stackcount, m_secondaryKnockdownDir );
			}
		}
	}

	protected function DidPlayerCollideWithWall( scriptInterface : StateGameScriptInterface, out wallCollision : ControllerHit ) : Bool
	{
		var playerPosition : Vector4;
		var capsuleRadius : Float;
		playerPosition = GetPlayerPosition( scriptInterface );
		capsuleRadius = ( ( Float )( scriptInterface.GetStateVectorParameter( physicsStateValue.Radius ) ) );
		return WallCollisionHelpers.GetWallCollision( scriptInterface, playerPosition, GetUpVector(), capsuleRadius, wallCollision );
	}

}

class ForcedKnockdownDecisions extends KnockdownDecisions
{

	protected const override function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return HasForcedStatusEffect( stateContext, scriptInterface );
	}

	private const function HasForcedStatusEffect( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetStaticStringParameterDefault( "statusEffectEnumName", "" ) == GetForcedStatusEffectName( stateContext, scriptInterface );
	}

	private const function GetForcedStatusEffectName( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : String
	{
		var statusEffectRecord : weak< StatusEffect_Record >;
		var statusEffectName : String;
		statusEffectRecord = ( ( StatusEffect_Record )( stateContext.GetPermanentScriptableParameter( StatusEffectHelper.GetForceKnockdownKey() ) ) );
		if( statusEffectRecord )
		{
			statusEffectName = statusEffectRecord.StatusEffectType().EnumName();
		}
		return statusEffectName;
	}

}

class ForcedKnockdownEvents extends KnockdownEvents
{
	var m_firstUpdate : Bool;

	public override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var statusEffectRecord : weak< StatusEffect_Record >;
		var initialVelocity : StateResultVector;
		var originalStartTime : StateResultFloat;
		statusEffectRecord = ( ( StatusEffect_Record )( stateContext.GetPermanentScriptableParameter( StatusEffectHelper.GetForceKnockdownKey() ) ) );
		stateContext.RemovePermanentScriptableParameter( StatusEffectHelper.GetForceKnockdownKey() );
		initialVelocity = stateContext.GetPermanentVectorParameter( StatusEffectHelper.GetForcedKnockdownImpulseKey() );
		stateContext.RemovePermanentVectorParameter( StatusEffectHelper.GetForcedKnockdownImpulseKey() );
		stateContext.SetTemporaryScriptableParameter( StatusEffectHelper.GetAppliedStatusEffectKey(), statusEffectRecord, true );
		originalStartTime = stateContext.GetPermanentFloatParameter( StatusEffectHelper.GetStateStartTimeKey() );
		super.OnEnter( stateContext, scriptInterface );
		if( initialVelocity.valid )
		{
			m_cachedPlayerVelocity = initialVelocity.value;
		}
		if( originalStartTime.valid )
		{
			stateContext.SetPermanentFloatParameter( StatusEffectHelper.GetStateStartTimeKey(), originalStartTime.value, true );
		}
		m_firstUpdate = true;
	}

	protected override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( m_firstUpdate )
		{
			m_firstUpdate = false;
		}
		else
		{
			super.OnUpdate( timeDelta, stateContext, scriptInterface );
		}
	}

}

enum LadderCameraParams
{
	None = 0,
	Enter = 1,
	Default = 2,
	CameraReset = 3,
	Exit = 4,
}

enum LandingType
{
	Off = 0,
	Regular = 1,
	Hard = 2,
	VeryHard = 3,
	Superhero = 4,
	Death = 5,
}

