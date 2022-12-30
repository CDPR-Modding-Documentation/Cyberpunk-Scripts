class DefaultTransition extends StateFunctor
{

	public function ForceFreeze( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'ForceIdle', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceWalk', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceFreeze', true, true );
		stateContext.SetPermanentBoolParameter( 'ForceIdleVehicle', false, true );
	}

	public function ForceIdle( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'ForceIdle', true, true );
		stateContext.SetPermanentBoolParameter( 'ForceWalk', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceFreeze', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceIdleVehicle', false, true );
	}

	public function ForceIdleVehicle( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'ForceIdleVehicle', true, true );
		stateContext.SetPermanentBoolParameter( 'ForceIdle', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceWalk', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceFreeze', false, true );
	}

	public function ResetForceFlags( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'ForceIdle', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceWalk', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceFreeze', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceEmptyHands', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceSafeState', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceReadyState', false, true );
		stateContext.SetPermanentBoolParameter( 'ForceIdleVehicle', false, true );
	}

	public function SetBlackboardFloatVariable( scriptInterface : StateGameScriptInterface, id : BlackboardID_Float, value : Float )
	{
		scriptInterface.localBlackboard.SetFloat( id, value );
		scriptInterface.localBlackboard.SignalFloat( id );
	}

	public function SetBlackboardIntVariable( scriptInterface : StateGameScriptInterface, id : BlackboardID_Int, value : Int32 )
	{
		scriptInterface.localBlackboard.SetInt( id, value );
	}

	public function SetBlackboardBoolVariable( scriptInterface : StateGameScriptInterface, id : BlackboardID_Bool, value : Bool )
	{
		scriptInterface.localBlackboard.SetBool( id, value );
	}

	public const function GetBoolFromQuestDB( const scriptInterface : StateGameScriptInterface, varName : CName ) : Bool
	{
		return scriptInterface.GetQuestsSystem().GetFact( varName ) != 0;
	}

	public const function HoldAimingForTime( stateContext : StateContext, scriptInterface : StateGameScriptInterface, const blockAimingFor : Float )
	{
		stateContext.SetPermanentFloatParameter( 'HoldAimingTillTimeStamp', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.owner.GetGame() ) ) + blockAimingFor, true );
	}

	public const function BlockAimingForTime( stateContext : StateContext, scriptInterface : StateGameScriptInterface, const blockAimingFor : Float )
	{
		stateContext.SetPermanentFloatParameter( 'BlockAimingTillTimeStamp', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.owner.GetGame() ) ) + blockAimingFor, true );
	}

	public const function SoftBlockAimingForTime( stateContext : StateContext, scriptInterface : StateGameScriptInterface, const blockAimingFor : Float )
	{
		stateContext.SetPermanentFloatParameter( 'SoftBlockAimingTillTimeStamp', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.owner.GetGame() ) ) + blockAimingFor, true );
		stateContext.SetTemporaryBoolParameter( 'InterruptAiming', true, true );
	}

	public const function ResetSoftBlockAiming( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetPermanentFloatParameter( 'SoftBlockAimingTillTimeStamp', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.owner.GetGame() ) ), true );
	}

	protected const function HasTimeStampElapsed( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, timeStampName : CName ) : Bool
	{
		var timeStampValue : Float;
		timeStampValue = stateContext.GetFloatParameter( timeStampName, true );
		if( timeStampValue <= 0.0 )
		{
			return false;
		}
		return EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.owner.GetGame() ) ) < timeStampValue;
	}

	protected const function IsAimingSoftBlocked( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return HasTimeStampElapsed( stateContext, scriptInterface, 'SoftBlockAimingTillTimeStamp' );
	}

	protected const function IsAimingHeldForTime( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return HasTimeStampElapsed( stateContext, scriptInterface, 'HoldAimingTillTimeStamp' );
	}

	protected const function IsAimingBlockedForTime( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return HasTimeStampElapsed( stateContext, scriptInterface, 'BlockAimingTillTimeStamp' );
	}

	public const function GetStatFloatValue( const scriptInterface : StateGameScriptInterface, statType : gamedataStatType, statSystem : StatsSystem, optional object : GameObject ) : Float
	{
		var result : Float;
		var objectToLookAt : GameObject;
		var objectToLookAtID : StatsObjectID;
		if( object )
		{
			objectToLookAt = object;
		}
		else
		{
			objectToLookAt = scriptInterface.owner;
		}
		objectToLookAtID = objectToLookAt.GetEntityID();
		result = statSystem.GetStatValue( objectToLookAtID, statType );
		return result;
	}

	protected const function ShouldEnterSafe( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var takedownState : Int32;
		if( ( !( IsPlayerInCombat( scriptInterface ) ) && ( ( PlayerPuppet )( scriptInterface.executionOwner ) ).IsAimingAtFriendly() ) && !( ShouldIgnoreWeaponSafe( scriptInterface ) ) )
		{
			return true;
		}
		if( IsInteractingWithTerminal( scriptInterface ) )
		{
			return true;
		}
		if( IsSafeStateForced( stateContext, scriptInterface ) )
		{
			return true;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vision ) == ( ( Int32 )( gamePSMVision.Focus ) ) )
		{
			return true;
		}
		takedownState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Takedown );
		if( ( ( takedownState == ( ( Int32 )( gamePSMTakedown.Takedown ) ) ) || ( takedownState == ( ( Int32 )( gamePSMTakedown.Leap ) ) ) ) || ( takedownState == ( ( Int32 )( gamePSMTakedown.Grapple ) ) ) )
		{
			return true;
		}
		if( ( stateContext.IsStateActive( 'Zoom', 'zoomLevelScan' ) || stateContext.IsStateActive( 'Zoom', 'zoomLevel3' ) ) || stateContext.IsStateActive( 'Zoom', 'zoomLevel4' ) )
		{
			return true;
		}
		return false;
	}

	protected const function ShouldIgnoreWeaponSafe( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ).IsAimingAtChild() && IsEnemyVisible( scriptInterface, 50.0 ) )
		{
			return true;
		}
		return false;
	}

	protected const function IsEnemyVisible( const scriptInterface : StateGameScriptInterface, optional distance : Float ) : Bool
	{
		var targetingSystem : TargetingSystem;
		var isEnemyVisible : Bool;
		isEnemyVisible = false;
		targetingSystem = scriptInterface.GetTargetingSystem();
		isEnemyVisible = targetingSystem.IsAnyEnemyVisible( scriptInterface.executionOwner, distance );
		return isEnemyVisible;
	}

	protected const function IsEnemyOrSensoryDeviceVisible( const scriptInterface : StateGameScriptInterface, optional distance : Float ) : Bool
	{
		var targetingSystem : TargetingSystem;
		var isEnemyVisible : Bool;
		isEnemyVisible = false;
		targetingSystem = scriptInterface.GetTargetingSystem();
		isEnemyVisible = targetingSystem.IsAnyEnemyOrSensorVisible( scriptInterface.executionOwner, distance );
		return isEnemyVisible;
	}

	public static function GetDistanceToTarget( const scriptInterface : StateGameScriptInterface ) : Float
	{
		var playerObject : GameObject;
		var targetObject : GameObject;
		playerObject = scriptInterface.executionOwner;
		targetObject = GetTargetObject( scriptInterface );
		return Vector4.Distance2D( playerObject.GetWorldPosition(), targetObject.GetWorldPosition() );
	}

	public static function GetTargetObject( const scriptInterface : StateGameScriptInterface, optional withinDistance : Float ) : GameObject
	{
		var targetingSystem : TargetingSystem;
		var targetObject : GameObject;
		var angleOut : EulerAngles;
		targetingSystem = scriptInterface.GetTargetingSystem();
		targetObject = targetingSystem.GetObjectClosestToCrosshair( scriptInterface.executionOwner, angleOut, TSQ_NPC() );
		if( !( targetingSystem ) || !( targetObject ) )
		{
			return NULL;
		}
		if( !( targetObject.IsPuppet() ) || !( ScriptedPuppet.IsActive( targetObject ) ) )
		{
			return NULL;
		}
		if( GameObject.GetAttitudeTowards( targetObject, scriptInterface.executionOwner ) == EAIAttitude.AIA_Friendly )
		{
			return NULL;
		}
		if( ( withinDistance <= 0.0 ) || ( Vector4.Distance( scriptInterface.executionOwner.GetWorldPosition(), targetObject.GetWorldPosition() ) <= withinDistance ) )
		{
			return targetObject;
		}
		return NULL;
	}

	protected function RequestPlayerPositionAdjustment( stateContext : StateContext, scriptInterface : StateGameScriptInterface, target : GameObject, slideTime : Float, distanceRadius : Float, rotationDuration : Float, adjustPosition : Vector4, optional useParabolicMotion : Bool ) : Bool
	{
		var adjustRequest : AdjustTransformWithDurations;
		adjustRequest = new AdjustTransformWithDurations;
		if( target )
		{
			adjustRequest.SetTarget( target );
			adjustRequest.SetDistanceRadius( distanceRadius );
		}
		adjustRequest.SetPosition( adjustPosition );
		adjustRequest.SetSlideDuration( slideTime );
		adjustRequest.SetRotation( scriptInterface.executionOwner.GetWorldOrientation() );
		adjustRequest.SetRotationDuration( rotationDuration );
		adjustRequest.SetGravity( GetStaticFloatParameterDefault( "downwardsGravity", -16.0 ) );
		adjustRequest.SetUseParabolicMotion( useParabolicMotion );
		stateContext.SetTemporaryScriptableParameter( 'adjustTransform', adjustRequest, true );
		return true;
	}

	protected function RequestPlayerPositionAdjustmentWithCurve( stateContext : StateContext, scriptInterface : StateGameScriptInterface, slideTime : Float, distanceRadius : Float, adjustPosition : Vector4, adjustCurveName : CName ) : Bool
	{
		var adjustRequest : AdjustTransformWithDurations;
		adjustRequest = new AdjustTransformWithDurations;
		adjustRequest.SetPosition( adjustPosition );
		adjustRequest.SetSlideDuration( slideTime );
		adjustRequest.SetRotationDuration( -1.0 );
		adjustRequest.SetGravity( GetStaticFloatParameterDefault( "downwardsGravity", -16.0 ) );
		adjustRequest.SetDistanceRadius( distanceRadius );
		adjustRequest.SetUseParabolicMotion( true );
		adjustRequest.SetCurve( adjustCurveName );
		stateContext.SetTemporaryScriptableParameter( 'adjustTransform', adjustRequest, true );
		return true;
	}

	public static function IsInteractingWithTerminal( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var uiBlackboard : IBlackboard;
		var interactionVariant : Variant;
		var interactionData : bbUIInteractionData;
		var isAiming : Bool;
		isAiming = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) );
		if( isAiming )
		{
			return false;
		}
		uiBlackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UIGameData );
		interactionVariant = uiBlackboard.GetVariant( GetAllBlackboardDefs().UIGameData.InteractionData );
		if( interactionVariant.IsValid() )
		{
			interactionData = ( ( bbUIInteractionData )interactionVariant );
			if( interactionData.terminalInteractionActive )
			{
				return true;
			}
		}
		return false;
	}

	public static function HasActiveInteraction( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var uiBlackboard : IBlackboard;
		var interactionVariant : Variant;
		var interactionData : bbUIInteractionData;
		uiBlackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UIGameData );
		interactionVariant = uiBlackboard.GetVariant( GetAllBlackboardDefs().UIGameData.InteractionData );
		if( interactionVariant.IsValid() )
		{
			interactionData = ( ( bbUIInteractionData )interactionVariant );
			if( bbUIInteractionData.HasAnyInteraction( interactionData ) )
			{
				return true;
			}
		}
		return false;
	}

	protected const function IsDoorInteractionActive( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsDoorInteractionActive );
	}

	public const virtual function GetStatusEffectRecordData( const stateContext : StateContext ) : weak< StatusEffectPlayerData_Record >
	{
		var recordData : weak< StatusEffectPlayerData_Record >;
		recordData = ( ( StatusEffectPlayerData_Record )( stateContext.GetConditionScriptableParameter( 'PlayerStatusEffectRecordData' ) ) );
		return recordData;
	}

	public const virtual function IsPlayerTired( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Stamina ) != ( ( Int32 )( gamePSMStamina.Rested ) );
	}

	public const virtual function IsPlayerExhausted( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Stamina ) == ( ( Int32 )( gamePSMStamina.Exhausted ) );
	}

	protected function ChangeStatPoolValue( scriptInterface : StateGameScriptInterface, entityID : EntityID, statPoolType : gamedataStatPoolType, changeByValue : Float, optional asPercentage : Bool )
	{
		scriptInterface.GetStatPoolsSystem().RequestChangingStatPoolValue( entityID, statPoolType, changeByValue, NULL, false, asPercentage );
	}

	protected const function GetStatPoolValue( const scriptInterface : StateGameScriptInterface, entityID : EntityID, statPool : gamedataStatPoolType, optional asPrecentage : Bool ) : Float
	{
		var statPoolsSystem : StatPoolsSystem;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		return statPoolsSystem.GetStatPoolValue( entityID, statPool, asPrecentage );
	}

	protected const function HasStatPoolValueReachedMax( const scriptInterface : StateGameScriptInterface, entityID : EntityID, statPool : gamedataStatPoolType ) : Bool
	{
		var statPoolsSystem : StatPoolsSystem;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		return statPoolsSystem.HasStatPoolValueReachedMax( entityID, statPool );
	}

	protected function StartStatPoolDecay( const scriptInterface : StateGameScriptInterface, statPoolType : gamedataStatPoolType )
	{
		var statPoolsSystem : StatPoolsSystem;
		var entityID : StatsObjectID;
		var mod : StatPoolModifier;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		entityID = scriptInterface.executionOwnerEntityID;
		statPoolsSystem.GetModifier( entityID, statPoolType, gameStatPoolModificationTypes.Decay, mod );
		mod.enabled = true;
		statPoolsSystem.RequestSettingModifier( entityID, statPoolType, gameStatPoolModificationTypes.Decay, mod );
		statPoolsSystem.RequestResetingModifier( entityID, statPoolType, gameStatPoolModificationTypes.Regeneration );
	}

	protected function StopStatPoolDecayAndRegenerate( const scriptInterface : StateGameScriptInterface, statPoolType : gamedataStatPoolType )
	{
		var statPoolsSystem : StatPoolsSystem;
		var entityID : StatsObjectID;
		var mod : StatPoolModifier;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		entityID = scriptInterface.executionOwnerEntityID;
		statPoolsSystem.GetModifier( entityID, statPoolType, gameStatPoolModificationTypes.Regeneration, mod );
		mod.enabled = true;
		statPoolsSystem.RequestSettingModifier( entityID, statPoolType, gameStatPoolModificationTypes.Regeneration, mod );
		statPoolsSystem.RequestResetingModifier( entityID, statPoolType, gameStatPoolModificationTypes.Decay );
	}

	public static function UppercaseFirstChar( out stringToChange : String )
	{
		var firstChar : String;
		var restOfTheString : String;
		var length : Int32;
		length = StrLen( stringToChange );
		firstChar = StrLeft( stringToChange, 1 );
		restOfTheString = StrRight( stringToChange, length - 1 );
		firstChar = StrUpper( firstChar );
		stringToChange = firstChar + restOfTheString;
	}

	public static function GetPlayerPuppet( const scriptInterface : StateGameScriptInterface ) : PlayerPuppet
	{
		return ( ( PlayerPuppet )( scriptInterface.executionOwner ) );
	}

	public static function PlayRumble( const scriptInterface : StateGameScriptInterface, presetName : String )
	{
		var rumbleName : CName;
		rumbleName = TDB.GetCName( TDBID.Create( "rumble.local." + presetName ) );
		GameObject.PlaySound( GetPlayerPuppet( scriptInterface ), rumbleName );
	}

	public static function PlayRumbleLoop( const scriptInterface : StateGameScriptInterface, intensity : String )
	{
		var rumbleName : CName;
		rumbleName = TDB.GetCName( TDBID.Create( ( "rumble.local." + "loop_" ) + intensity ) );
		GameObject.PlaySound( GetPlayerPuppet( scriptInterface ), rumbleName );
	}

	public static function StopRumbleLoop( const scriptInterface : StateGameScriptInterface, intensity : String )
	{
		var rumbleName : CName;
		rumbleName = TDB.GetCName( TDBID.Create( "rumble.loopstop." + intensity ) );
		GameObject.PlaySound( GetPlayerPuppet( scriptInterface ), rumbleName );
	}

	public static function RemoveAllBreathingEffects( const scriptInterface : StateGameScriptInterface )
	{
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.BreathingLow" );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.BreathingMedium" );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.BreathingHeavy" );
		StatusEffectHelper.RemoveStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.BreathingSick" );
	}

	public static function GetPlayerPosition( const scriptInterface : StateGameScriptInterface ) : Vector4
	{
		var playerPosition : Vector4;
		var positionParameter : Variant;
		positionParameter = scriptInterface.GetStateVectorParameter( physicsStateValue.Position );
		playerPosition = ( ( Vector4 )positionParameter );
		return playerPosition;
	}

	public static function GetPlayerDistanceToGround( const scriptInterface : StateGameScriptInterface, downwardRaycastLength : Float ) : Float
	{
		return Vector4.Distance2D( GetPlayerPosition( scriptInterface ), GetGroundPosition( scriptInterface, downwardRaycastLength ) );
	}

	public static function GetDistanceToGround( const scriptInterface : StateGameScriptInterface ) : Float
	{
		var geometryDescription : GeometryDescriptionQuery;
		var queryFilter : QueryFilter;
		var geometryDescriptionResult : GeometryDescriptionResult;
		var currentPosition : Vector4;
		var distanceToGround : Float;
		currentPosition = GetPlayerPosition( scriptInterface );
		QueryFilter.AddGroup( queryFilter, 'Static' );
		QueryFilter.AddGroup( queryFilter, 'Terrain' );
		QueryFilter.AddGroup( queryFilter, 'PlayerBlocker' );
		geometryDescription = new GeometryDescriptionQuery;
		geometryDescription.AddFlag( worldgeometryDescriptionQueryFlags.DistanceVector );
		geometryDescription.filter = queryFilter;
		geometryDescription.refPosition = currentPosition;
		geometryDescription.refDirection = Vector4( 0.0, 0.0, -1.0, 0.0 );
		geometryDescription.primitiveDimension = Vector4( 0.5, 0.1, 0.1, 0.0 );
		geometryDescription.maxDistance = 100.0;
		geometryDescription.maxExtent = 100.0;
		geometryDescription.probingPrecision = 10.0;
		geometryDescription.probingMaxDistanceDiff = 100.0;
		geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents( geometryDescription );
		if( geometryDescriptionResult.queryStatus == worldgeometryDescriptionQueryStatus.NoGeometry || geometryDescriptionResult.queryStatus != worldgeometryDescriptionQueryStatus.OK )
		{
			return -1.0;
		}
		distanceToGround = AbsF( geometryDescriptionResult.distanceVector.Z );
		return distanceToGround;
	}

	public static function GetGroundPosition( const scriptInterface : StateGameScriptInterface, inLenght : Float ) : Vector4
	{
		var playerFeetPosition : Vector4;
		var startPosition : Vector4;
		var raycastLenght : Vector4;
		var findGround : TraceResult;
		var findWater : TraceResult;
		var position : Vector4;
		playerFeetPosition = GetPlayerPosition( scriptInterface );
		startPosition = playerFeetPosition;
		startPosition.Z = startPosition.Z;
		raycastLenght = playerFeetPosition;
		raycastLenght.Z -= inLenght;
		findGround = scriptInterface.RaycastWithASingleGroup( startPosition, raycastLenght, 'PlayerBlocker' );
		findWater = scriptInterface.RaycastWithASingleGroup( startPosition, raycastLenght, 'Water' );
		if( TraceResult.IsValid( findGround ) )
		{
			position = ( ( Vector4 )( findGround.position ) );
		}
		else if( TraceResult.IsValid( findWater ) )
		{
			position = ( ( Vector4 )( findWater.position ) );
		}
		return position;
	}

	protected const function IsDeepEnoughToSwim( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var deepEnough : Bool;
		var waterLevel : Float;
		var playerFeetPosition : Vector4;
		var depthRaycastDestination : Vector4;
		playerFeetPosition = GetPlayerPosition( scriptInterface );
		depthRaycastDestination = playerFeetPosition;
		depthRaycastDestination.Z = depthRaycastDestination.Z - 2.0;
		deepEnough = false;
		if( scriptInterface.GetWaterLevel( playerFeetPosition, depthRaycastDestination, waterLevel ) )
		{
			deepEnough = ( playerFeetPosition.Z - waterLevel ) <= ( -0.89999998 + -0.1 );
		}
		return deepEnough;
	}

	public static function GetLinearVelocity( const scriptInterface : StateGameScriptInterface ) : Vector4
	{
		var parameter : Variant;
		var velocity : Vector4;
		parameter = scriptInterface.GetStateVectorParameter( physicsStateValue.LinearVelocity );
		velocity = ( ( Vector4 )parameter );
		return velocity;
	}

	public static function GetUpVector() : Vector4
	{
		var up : Vector4;
		up.Z = 1.0;
		return up;
	}

	public static function Get2DLinearSpeed( const scriptInterface : StateGameScriptInterface ) : Float
	{
		var parameter : Variant;
		var velocity : Vector4;
		parameter = scriptInterface.GetStateVectorParameter( physicsStateValue.LinearVelocity );
		velocity = ( ( Vector4 )parameter );
		return Vector4.Length2D( velocity );
	}

	protected const function GetVerticalSpeed( const scriptInterface : StateGameScriptInterface ) : Float
	{
		var parameter : Variant;
		var velocity : Vector4;
		parameter = scriptInterface.GetStateVectorParameter( physicsStateValue.LinearVelocity );
		velocity = ( ( Vector4 )parameter );
		return velocity.Z;
	}

	public static function GetMovementDirection( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : EPlayerMovementDirection
	{
		var direction : EPlayerMovementDirection;
		var currentYaw : Float;
		currentYaw = GetYawMovementDirection( stateContext, scriptInterface );
		if( ( currentYaw >= -45.0 ) && ( currentYaw <= 45.0 ) )
		{
			direction = EPlayerMovementDirection.Forward;
		}
		else if( ( currentYaw > 45.0 ) && ( currentYaw < 135.0 ) )
		{
			direction = EPlayerMovementDirection.Right;
		}
		else if( ( ( currentYaw >= 135.0 ) && ( currentYaw <= 180.0 ) ) || ( ( currentYaw <= -135.0 ) && ( currentYaw >= -180.0 ) ) )
		{
			direction = EPlayerMovementDirection.Back;
		}
		else if( ( currentYaw > -135.0 ) && ( currentYaw < -45.0 ) )
		{
			direction = EPlayerMovementDirection.Left;
		}
		return direction;
	}

	public static function GetYawMovementDirection( const stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Float
	{
		var linearVel : Vector4;
		var playerForward : Vector4;
		linearVel = GetLinearVelocity( scriptInterface );
		playerForward = scriptInterface.executionOwner.GetWorldForward();
		return Vector4.GetAngleDegAroundAxis( linearVel, playerForward, GetUpVector() );
	}

	public static function GetMovementInputActionValue( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Float
	{
		var x : Float;
		var y : Float;
		var res : Float;
		x = scriptInterface.GetActionValue( 'MoveX' );
		y = scriptInterface.GetActionValue( 'MoveY' );
		res = SqrtF( SqrF( x ) + SqrF( y ) );
		return res;
	}

	protected const function IsMovementInput( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.IsMoveInputConsiderable();
	}

	protected const function IsPlayerMoving( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsPlayerMovingHorizontally( stateContext, scriptInterface ) || IsPlayerMovingVertically( stateContext, scriptInterface );
	}

	protected const function IsPlayerMovingHorizontally( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var playerVelocity : Vector4;
		var horizontalSpeed : Float;
		playerVelocity = GetLinearVelocity( scriptInterface );
		horizontalSpeed = Vector4.Length2D( playerVelocity );
		return horizontalSpeed > 0.0;
	}

	protected const function IsPlayerMovingVertically( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var verticalSpeed : Float;
		verticalSpeed = GetVerticalSpeed( scriptInterface );
		return ( verticalSpeed > 0.0 ) || ( verticalSpeed < 0.0 );
	}

	protected const function IsPlayerMovingBackwards( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var movementDirection : Float;
		movementDirection = GetHorizontalMovementDirection( stateContext, scriptInterface );
		if( ( ( movementDirection >= 135.0 ) && ( movementDirection <= 180.0 ) ) || ( ( movementDirection <= -135.0 ) && ( movementDirection >= -180.0 ) ) )
		{
			return true;
		}
		return false;
	}

	protected const function GetHorizontalMovementDirection( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Float
	{
		var linearVel : Vector4;
		var playerForward : Vector4;
		linearVel = GetLinearVelocity( scriptInterface );
		playerForward = scriptInterface.executionOwner.GetWorldForward();
		return Vector4.GetAngleDegAroundAxis( linearVel, playerForward, GetUpVector() );
	}

	public static function GetActiveLeftHandItem( const scriptInterface : StateGameScriptInterface ) : ItemObject
	{
		return scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponLeft" );
	}

	public static function IsHeavyWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetActiveWeapon( scriptInterface ).IsHeavyWeapon();
	}

	public static function GetActiveWeapon( const scriptInterface : StateGameScriptInterface ) : WeaponObject
	{
		return ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
	}

	public static function IsXYActionInputGreaterEqual( const scriptInterface : StateGameScriptInterface, threshold : Float ) : Bool
	{
		return ( AbsF( scriptInterface.GetActionValue( 'MoveX' ) ) >= threshold ) || ( AbsF( scriptInterface.GetActionValue( 'MoveY' ) ) >= threshold );
	}

	public static function IsAxisButtonHeldGreaterEqual( const scriptInterface : StateGameScriptInterface, threshold : Float ) : Bool
	{
		return ( ( ( ( scriptInterface.GetActionValue( 'Forward' ) > 0.0 ) && ( scriptInterface.GetActionStateTime( 'Forward' ) > threshold ) ) || ( ( scriptInterface.GetActionValue( 'Right' ) > 0.0 ) && ( scriptInterface.GetActionStateTime( 'Right' ) > threshold ) ) ) || ( ( scriptInterface.GetActionValue( 'Back' ) > 0.0 ) && ( scriptInterface.GetActionStateTime( 'Back' ) > threshold ) ) ) || ( ( scriptInterface.GetActionValue( 'Left' ) > 0.0 ) && ( scriptInterface.GetActionStateTime( 'Left' ) > threshold ) );
	}

	public const function IsSafeStateForced( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( ( stateContext.GetBoolParameter( 'ForceSafeState', true ) || stateContext.GetBoolParameter( 'ForceSafeStateByZone', true ) ) || GetBoolFromQuestDB( scriptInterface, 'ForceSafeState' ) ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced ) ) ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced ) );
	}

	protected const function GetActionHoldTime( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, actionName : CName ) : Float
	{
		var holdTime : Float;
		if( scriptInterface.GetActionValue( actionName ) > 0.0 )
		{
			holdTime = scriptInterface.GetActionStateTime( actionName );
			stateContext.SetConditionFloatParameter( 'InputHoldTime', holdTime, true );
		}
		return holdTime;
	}

	protected function ToggleAudioAimDownSights( weapon : WeaponObject, toggleOn : Bool )
	{
		var ADSToggleEvent : ToggleAimDownSightsEvent;
		ADSToggleEvent = new ToggleAimDownSightsEvent;
		ADSToggleEvent.toggleOn = toggleOn;
		weapon.QueueEvent( ADSToggleEvent );
	}

	protected function DisableCameraBobbing( stateContext : StateContext, scriptInterface : StateGameScriptInterface, b : Bool )
	{
		AnimationControllerComponent.SetInputBool( GetPlayerPuppet( scriptInterface ), 'disable_camera_bobbing', b );
	}

	protected function StartEffect( scriptInterface : StateGameScriptInterface, effectName : CName, optional blackboard : worldEffectBlackboard )
	{
		GameObjectEffectHelper.StartEffectEvent( scriptInterface.executionOwner, effectName, false, blackboard );
	}

	protected function StopEffect( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		GameObjectEffectHelper.StopEffectEvent( scriptInterface.executionOwner, effectName );
	}

	protected function BreakEffectLoop( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		GameObjectEffectHelper.BreakEffectLoopEvent( scriptInterface.executionOwner, effectName );
	}

	protected function PlaySound( soundName : CName, scriptInterface : StateGameScriptInterface )
	{
		var audioEvent : SoundPlayEvent;
		audioEvent = new SoundPlayEvent;
		audioEvent.soundName = soundName;
		scriptInterface.owner.QueueEvent( audioEvent );
	}

	protected function SetAudioParameter( paramName : CName, paramValue : Float, scriptInterface : StateGameScriptInterface )
	{
		var audioParam : SoundParameterEvent;
		audioParam = new SoundParameterEvent;
		audioParam.parameterName = paramName;
		audioParam.parameterValue = paramValue;
		scriptInterface.owner.QueueEvent( audioParam );
	}

	protected function PlaySoundMetadataEvent( evtName : CName, scriptInterface : StateGameScriptInterface, evtParam : Float )
	{
		var metadataEvent : AudioEvent;
		metadataEvent = new AudioEvent;
		metadataEvent.eventName = evtName;
		metadataEvent.floatData = evtParam;
		metadataEvent.eventFlags = audioAudioEventFlags.Metadata;
		scriptInterface.owner.QueueEvent( metadataEvent );
	}

	protected function SetSurfaceMaterialProbingDirection( direction : gameaudioeventsSurfaceDirection, scriptInterface : StateGameScriptInterface )
	{
		var directionChangedEvent : NotifySurfaceDirectionChangedEvent;
		directionChangedEvent = new NotifySurfaceDirectionChangedEvent;
		directionChangedEvent.surfaceDirection = direction;
		scriptInterface.owner.QueueEvent( directionChangedEvent );
	}

	protected function AdjustPlayerPosition( stateContext : StateContext, scriptInterface : StateGameScriptInterface, target : GameObject, duration : Float, distanceRadius : Float, curveName : CName ) : Bool
	{
		var adjustRequest : AdjustTransformWithDurations;
		var vecToTarget : Vector4;
		var position : Vector4;
		if( !( target ) || ( duration <= 0.0 ) )
		{
			return false;
		}
		adjustRequest = new AdjustTransformWithDurations;
		vecToTarget = target.GetWorldPosition() - scriptInterface.executionOwner.GetWorldPosition();
		position = Vector4.Normalize( vecToTarget ) * -0.1;
		adjustRequest.SetDistanceRadius( distanceRadius );
		adjustRequest.SetTarget( target );
		adjustRequest.SetSlideDuration( duration );
		adjustRequest.SetPosition( position );
		adjustRequest.SetRotationDuration( -1.0 );
		if( IsNameValid( curveName ) )
		{
			adjustRequest.SetCurve( curveName );
		}
		stateContext.SetTemporaryScriptableParameter( 'adjustTransform', adjustRequest, true );
		return true;
	}

	public static function HasMeleeWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		weapon = GetActiveWeapon( scriptInterface );
		return ( ( weapon ) ? ( weapon.IsMelee() ) : ( false ) );
	}

	public static function IsRangedWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		weapon = GetActiveWeapon( scriptInterface );
		return ( ( weapon ) ? ( weapon.IsRanged() ) : ( false ) );
	}

	public static function IsChargeRangedWeapon( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var game : GameInstance;
		var weapon : WeaponObject;
		game = scriptInterface.owner.GetGame();
		weapon = ( ( WeaponObject )( GameInstance.GetTransactionSystem( game ).GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			if( weapon.IsRanged() )
			{
				return weapon.GetCurrentTriggerMode().Type() == gamedataTriggerMode.Charge;
			}
		}
		return false;
	}

	public static function IsChargingWeapon( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon && weapon.IsRanged() )
		{
			return WeaponObject.GetWeaponChargeNormalized( weapon ) > 0.0;
		}
		return false;
	}

	public static function HasRightWeaponEquipped( const scriptInterface : StateGameScriptInterface, optional checkForTag : Bool ) : Bool
	{
		var transactionSystem : TransactionSystem;
		var weapon : WeaponObject;
		transactionSystem = scriptInterface.GetTransactionSystem();
		weapon = ( ( WeaponObject )( transactionSystem.GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			if( checkForTag && !( transactionSystem.HasTag( scriptInterface.executionOwner, 'Weapon', weapon.GetItemID() ) ) )
			{
				return false;
			}
			return true;
		}
		return false;
	}

	protected function StartPool( statPoolsSystem : StatPoolsSystem, weaponEntityID : EntityID, poolType : gamedataStatPoolType, optional rangeEnd : Float, optional valuePerSec : Float )
	{
		var mod : StatPoolModifier;
		statPoolsSystem.GetModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Regeneration, mod );
		mod.enabled = true;
		if( rangeEnd > 0.0 )
		{
			mod.rangeEnd = rangeEnd;
		}
		if( valuePerSec > 0.0 )
		{
			mod.valuePerSec = valuePerSec;
		}
		statPoolsSystem.RequestSettingModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Regeneration, mod );
		statPoolsSystem.RequestResetingModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Decay );
	}

	protected function StopPool( statPoolsSystem : StatPoolsSystem, weaponEntityID : EntityID, poolType : gamedataStatPoolType, startDecay : Bool )
	{
		var mod : StatPoolModifier;
		statPoolsSystem.RequestResetingModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Regeneration );
		if( startDecay )
		{
			statPoolsSystem.GetModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Decay, mod );
			mod.enabled = true;
			statPoolsSystem.RequestSettingModifier( weaponEntityID, poolType, gameStatPoolModificationTypes.Decay, mod );
		}
	}

	protected const function GetWeaponItemTag( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, tag : CName, optional itemID : ItemID ) : Bool
	{
		var weapon : WeaponObject;
		weapon = GetActiveWeapon( scriptInterface );
		return weapon.WeaponHasTag( tag );
	}

	public static function GetWeaponItemType( const scriptInterface : StateGameScriptInterface, weapon : WeaponObject, out itemType : gamedataItemType ) : Bool
	{
		if( !( weapon ) )
		{
			return false;
		}
		itemType = weapon.GetWeaponRecord().ItemType().Type();
		return true;
	}

	public static function IsInWorkspot( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var workspotSystem : WorkspotGameSystem;
		var res : Bool;
		workspotSystem = scriptInterface.GetWorkspotSystem();
		res = workspotSystem.IsActorInWorkspot( scriptInterface.executionOwner );
		return res;
	}

	protected const function GetCurrentTier( const stateContext : StateContext ) : GameplayTier
	{
		var sceneTier : SceneTier;
		sceneTier = ( ( SceneTier )( stateContext.GetPermanentScriptableParameter( 'SceneTier' ) ) );
		if( sceneTier )
		{
			return sceneTier.GetTier();
		}
		return GameplayTier.Tier1_FullGameplay;
	}

	protected const function GetCurrentSceneTierData( const stateContext : StateContext ) : SceneTierData
	{
		var sceneTier : SceneTier;
		sceneTier = ( ( SceneTier )( stateContext.GetPermanentScriptableParameter( 'SceneTier' ) ) );
		if( sceneTier )
		{
			return sceneTier.GetTierData();
		}
		return NULL;
	}

	protected const function IsInMinigame( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsInMinigame );
	}

	protected const function IsUploadingQuickHack( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack ) > 0;
	}

	public static function IsInRpgContext( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ics : InputContextSystem;
		ics = ( ( InputContextSystem )( scriptInterface.GetScriptableSystem( 'InputContextSystem' ) ) );
		return ics.IsActiveContextRPG();
	}

	protected const function IsCameraPitchAcceptable( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, cameraPitchThreshold : Float ) : Bool
	{
		var cameraWorldTransform : Transform;
		var angles : EulerAngles;
		cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
		angles = Transform.ToEulerAngles( cameraWorldTransform );
		return angles.Pitch < cameraPitchThreshold;
	}

	protected const function GetCameraYaw( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Float
	{
		var cameraWorldTransform : Transform;
		var result : Float;
		cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
		result = Vector4.GetAngleDegAroundAxis( Transform.GetForward( cameraWorldTransform ), scriptInterface.owner.GetWorldForward(), GetUpVector() );
		return result;
	}

	protected const function IsPlayerInCombat( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Combat ) == ( ( Int32 )( gamePSMCombat.InCombat ) );
	}

	protected const function IsInSafeSceneTier( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var tier : Int32;
		tier = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel );
		return ( tier > ( ( Int32 )( gamePSMHighLevel.SceneTier1 ) ) ) && ( tier <= ( ( Int32 )( gamePSMHighLevel.SceneTier5 ) ) );
	}

	protected const function GetSceneTier( const scriptInterface : StateGameScriptInterface ) : Int32
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel );
	}

	protected const function ForceDisableVisionMode( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'forceDisableVision', true, true );
	}

	protected const function ForceDisableRadialWheel( const scriptInterface : StateGameScriptInterface )
	{
		var radialMenuCloseEvt : ForceRadialWheelShutdown;
		radialMenuCloseEvt = new ForceRadialWheelShutdown;
		scriptInterface.executionOwner.QueueEvent( radialMenuCloseEvt );
	}

	protected const function CheckItemCategoryInQuickWheel( const scriptInterface : StateGameScriptInterface, compareToType : gamedataItemCategory ) : Bool
	{
		var game : GameInstance;
		var quickSlotID : ItemID;
		var quickSlotRecord : Item_Record;
		var ts : TransactionSystem;
		var inInventory : Bool;
		var itemValid : Bool;
		var eqs : EquipmentSystem;
		game = scriptInterface.executionOwner.GetGame();
		ts = scriptInterface.GetTransactionSystem();
		eqs = ( ( EquipmentSystem )( GameInstance.GetScriptableSystemsContainer( game ).Get( 'EquipmentSystem' ) ) );
		if( !( eqs ) )
		{
			return false;
		}
		quickSlotID = eqs.GetItemIDFromHotkey( scriptInterface.executionOwner, EHotkey.RB );
		itemValid = ItemID.IsValid( quickSlotID );
		inInventory = ts.GetItemQuantity( scriptInterface.executionOwner, quickSlotID ) > 0;
		quickSlotRecord = TweakDBInterface.GetItemRecord( ItemID.GetTDBID( quickSlotID ) );
		return ( quickSlotRecord.ItemCategory().Type() == compareToType && itemValid ) && inInventory;
	}

	protected const function IsQuickWheelItemACyberdeck( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var quickSlotID : ItemID;
		var itemRecord : weak< Item_Record >;
		var itemTags : array< CName >;
		var eqs : EquipmentSystem;
		var checkSuccessful : Bool;
		eqs = ( ( EquipmentSystem )( scriptInterface.GetScriptableSystem( 'EquipmentSystem' ) ) );
		if( !( eqs ) )
		{
			return false;
		}
		quickSlotID = eqs.GetItemIDFromHotkey( scriptInterface.executionOwner, EHotkey.RB );
		itemRecord = RPGManager.GetItemRecord( quickSlotID );
		itemTags = itemRecord.Tags();
		checkSuccessful = ItemID.IsValid( quickSlotID ) && itemTags.Contains( 'Cyberdeck' );
		return checkSuccessful;
	}

	protected const function IsInFocusMode( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vision ) == ( ( Int32 )( gamePSMVision.Focus ) );
	}

	protected const function SetZoomStateAnimFeature( scriptInterface : StateGameScriptInterface, shouldAim : Bool )
	{
		var af : AnimFeature_AimPlayer;
		af = new AnimFeature_AimPlayer;
		if( shouldAim )
		{
			af.SetZoomState( animAimState.Aimed );
		}
		else
		{
			af.SetZoomState( animAimState.Unaimed );
		}
		af.SetAimInTime( 0.2 );
		af.SetAimOutTime( 0.2 );
		scriptInterface.SetAnimationParameterFeature( 'AnimFeature_AimPlayer', af );
	}

	protected const function GetSceneSystemInterface( const scriptInterface : StateGameScriptInterface ) : SceneSystemInterface
	{
		return scriptInterface.GetSceneSystem().GetScriptInterface();
	}

	protected function PrepareGameEffectAoEAttack( stateContext : StateContext, scriptInterface : StateGameScriptInterface, attackRecord : Attack_Record ) : Bool
	{
		var attackRadius : Float;
		var attack : Attack_GameEffect;
		var effect : EffectInstance;
		var attackContext : AttackInitContext;
		var statMods : array< gameStatModifierData >;
		attackRadius = attackRecord.Range();
		attackContext.record = attackRecord;
		attackContext.instigator = scriptInterface.executionOwner;
		attackContext.source = scriptInterface.executionOwner;
		attack = ( ( Attack_GameEffect )( IAttack.Create( attackContext ) ) );
		attack.GetStatModList( statMods );
		effect = attack.PrepareAttack( scriptInterface.executionOwner );
		if( !( attack ) )
		{
			return false;
		}
		EffectData.SetFloat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, attackRadius );
		EffectData.SetFloat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, attackRadius );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, scriptInterface.executionOwner.GetWorldPosition() );
		EffectData.SetVariant( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ( ( IAttack )( attack ) ) );
		EffectData.SetVariant( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, statMods );
		attack.StartAttack();
		return true;
	}

	protected const function IsPlayerInBraindance( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetSceneSystem().GetScriptInterface().IsRewindableSectionActive();
	}

	protected const function GetBraindanceSystem( const scriptInterface : StateGameScriptInterface ) : BraindanceSystem
	{
		var bdSys : BraindanceSystem;
		bdSys = ( ( BraindanceSystem )( scriptInterface.GetScriptableSystem( 'BraindanceSystem' ) ) );
		return bdSys;
	}

	protected const function IsInPhotoMode( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var photoModeSys : PhotoModeSystem;
		photoModeSys = GameInstance.GetPhotoModeSystem( scriptInterface.executionOwner.GetGame() );
		return photoModeSys.IsPhotoModeActive();
	}

	protected const function SendEquipmentSystemWeaponManipulationRequest( const scriptInterface : StateGameScriptInterface, requestType : EquipmentManipulationAction, optional equipAnimType : gameEquipAnimationType )
	{
		var request : EquipmentSystemWeaponManipulationRequest;
		var eqs : EquipmentSystem;
		eqs = ( ( EquipmentSystem )( scriptInterface.GetScriptableSystem( 'EquipmentSystem' ) ) );
		request = new EquipmentSystemWeaponManipulationRequest;
		request.owner = scriptInterface.executionOwner;
		request.requestType = requestType;
		if( equipAnimType != gameEquipAnimationType.Default )
		{
			request.equipAnimType = equipAnimType;
		}
		eqs.QueueRequest( request );
	}

	protected const function SendDrawItemRequest( const scriptInterface : StateGameScriptInterface, item : ItemID, optional equipAnimType : gameEquipAnimationType )
	{
		var drawItem : DrawItemRequest;
		var equipmentSystem : weak< EquipmentSystem >;
		drawItem = new DrawItemRequest;
		equipmentSystem = ( ( EquipmentSystem )( scriptInterface.GetScriptableSystem( 'EquipmentSystem' ) ) );
		drawItem.owner = scriptInterface.executionOwner;
		drawItem.itemID = item;
		if( equipAnimType != gameEquipAnimationType.Default )
		{
			drawItem.equipAnimationType = equipAnimType;
		}
		equipmentSystem.QueueRequest( drawItem );
	}

	protected const function IsItemMeleeWeapon( item : ItemID ) : Bool
	{
		var tags : array< CName >;
		tags = TweakDBInterface.GetWeaponItemRecord( ItemID.GetTDBID( item ) ).Tags();
		return tags.Contains( WeaponObject.GetMeleeWeaponTag() );
	}

	protected const function GetLeftHandItemFromParam( const stateContext : StateContext ) : ItemID
	{
		var wrapper : ItemIdWrapper;
		wrapper = ( ( ItemIdWrapper )( stateContext.GetPermanentScriptableParameter( 'leftHandItem' ) ) );
		if( wrapper )
		{
			return wrapper.itemID;
		}
		return ItemID.None();
	}

	protected const function GetRightHandItemFromParam( const stateContext : StateContext ) : ItemID
	{
		var wrapper : ItemIdWrapper;
		wrapper = ( ( ItemIdWrapper )( stateContext.GetPermanentScriptableParameter( 'rightHandItem' ) ) );
		if( wrapper )
		{
			return wrapper.itemID;
		}
		return ItemID.None();
	}

	protected const function IsLookingAtEnemyNPC( scriptInterface : StateGameScriptInterface ) : Bool
	{
		var game : GameInstance;
		var hudManager : HUDManager;
		var npc : ScriptedPuppet;
		game = scriptInterface.executionOwner.GetGame();
		hudManager = ( ( HUDManager )( GameInstance.GetScriptableSystemsContainer( game ).Get( 'HUDManager' ) ) );
		if( hudManager )
		{
			npc = ( ( ScriptedPuppet )( GameInstance.FindEntityByID( game, hudManager.GetCurrentTargetID() ) ) );
			return npc && npc.IsHostile();
		}
		return false;
	}

	protected const function GetHudManager( const scriptInterface : StateGameScriptInterface ) : HUDManager
	{
		var hudManager : HUDManager;
		hudManager = ( ( HUDManager )( scriptInterface.GetScriptableSystem( 'HUDManager' ) ) );
		return hudManager;
	}

	public function SetGameplayCameraParameters( scriptInterface : StateGameScriptInterface, tweakDBPath : String )
	{
		var cameraParameters : GameplayCameraData;
		var animFeature : AnimFeature_CameraGameplay;
		GetGameplayCameraParameters( cameraParameters, tweakDBPath );
		animFeature = new AnimFeature_CameraGameplay;
		animFeature.is_forward_offset = cameraParameters.is_forward_offset;
		animFeature.forward_offset_value = cameraParameters.forward_offset_value;
		animFeature.upperbody_pitch_weight = cameraParameters.upperbody_pitch_weight;
		animFeature.upperbody_yaw_weight = cameraParameters.upperbody_yaw_weight;
		animFeature.is_pitch_off = cameraParameters.is_pitch_off;
		animFeature.is_yaw_off = cameraParameters.is_yaw_off;
		scriptInterface.SetAnimationParameterFeature( 'CameraGameplay', animFeature );
	}

	public function GetGameplayCameraParameters( out cameraParameters : GameplayCameraData, tweakDBPath : String )
	{
		cameraParameters = new GameplayCameraData;
		cameraParameters.is_forward_offset = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "is_forward_offset" ), 0.0 );
		cameraParameters.forward_offset_value = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "forward_offset_value" ), 0.0 );
		cameraParameters.upperbody_pitch_weight = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "upperbody_pitch_weight" ), 0.0 );
		cameraParameters.upperbody_yaw_weight = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "upperbody_yaw_weight" ), 0.0 );
		cameraParameters.is_pitch_off = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "is_pitch_off" ), 0.0 );
		cameraParameters.is_yaw_off = TDB.GetFloat( TDBID.Create( ( ( "player." + tweakDBPath ) + "." ) + "is_yaw_off" ), 0.0 );
	}

	public static function DEBUG_IsSwimmingForced( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return DEBUG_IsSurfaceSwimmingForced( stateContext, scriptInterface ) || DEBUG_IsDivingForced( stateContext, scriptInterface );
	}

	public static function DEBUG_IsSurfaceSwimmingForced( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.ForceSwim" );
	}

	public static function DEBUG_IsDivingForced( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"BaseStatusEffect.ForceDive" );
	}

	protected const function IsInTier2Locomotion( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Tier2Locomotion' );
	}

	protected const function IsCrouchForced( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ForceCrouch' );
	}

	protected const function IsVaultingClimbingRestricted( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( IsInTier2Locomotion( scriptInterface ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoJump' ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'BodyCarryingGeneric' );
	}

	protected const function IsUsingMeleeForced( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Melee' );
	}

	protected const function IsUsingFistsForced( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' );
	}

	protected const function IsUsingFirearmsForced( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Firearms' ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequip' ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoSwitch' ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ShootingRangeCompetition' );
	}

	protected const function IsNoCombatActionsForced( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoCombat' ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FastForward' ) ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'VehicleScene' );
	}

	protected const function IsVehicleCameraChangeBlocked( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'VehicleFPP' ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'VehicleCombatNoInterruptions' );
	}

	protected const function IsVehicleExitCombatModeBlocked( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'VehicleCombatBlockExit' );
	}

	protected const function HasAnyValidWeaponAvailable( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return EquipmentSystem.GetFirstAvailableWeapon( scriptInterface.executionOwner ) != ItemID.None();
	}

	protected const function IsUsingLeftHandAllowed( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( LeftHandCyberwareHelper.IsProjectileLauncherInCooldown( scriptInterface ) )
		{
			return false;
		}
		if( StatusEffectSystem.ObjectHasStatusEffectOfType( scriptInterface.executionOwner, gamedataStatusEffectType.Stunned ) )
		{
			return false;
		}
		if( IsNoCombatActionsForced( scriptInterface ) )
		{
			return false;
		}
		if( IsUsingFirearmsForced( scriptInterface ) )
		{
			return false;
		}
		if( IsUsingFistsForced( scriptInterface ) )
		{
			return false;
		}
		if( IsUsingMeleeForced( scriptInterface ) )
		{
			return false;
		}
		if( IsCarryingBody( scriptInterface ) )
		{
			return false;
		}
		return true;
	}

	protected const function IsUsingConsumableRestricted( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var tier : Int32;
		if( PlayerGameplayRestrictions.IsHotkeyRestricted( scriptInterface.executionOwner.GetGame(), EHotkey.DPAD_UP ) )
		{
			return true;
		}
		tier = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel );
		if( ( tier >= ( ( Int32 )( gamePSMHighLevel.SceneTier3 ) ) ) && ( tier <= ( ( Int32 )( gamePSMHighLevel.SceneTier5 ) ) ) )
		{
			return true;
		}
		if( IsCarryingBody( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected const function GetTakedownAction( const stateContext : StateContext ) : ETakedownActionType
	{
		var enumName : CName;
		var param : StateResultCName;
		param = stateContext.GetPermanentCNameParameter( 'ETakedownActionType' );
		enumName = param.value;
		return ( ( ETakedownActionType )( ( ( Int32 )( EnumValueFromName( 'ETakedownActionType', enumName ) ) ) ) );
	}

	public const function IsVehicleBlockingCombat( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle ) ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vehicle ) == ( ( Int32 )( gamePSMVehicle.Combat ) ) )
		{
			return false;
		}
		return !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.MountedToCombatVehicle ) );
	}

	public const function IsEmptyHandsForced( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced ) ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced ) ) ) && ( ( ( ( stateContext.GetBoolParameter( 'ForceEmptyHands', true ) || stateContext.GetBoolParameter( 'ForceEmptyHandsByZone', true ) ) || scriptInterface.GetQuestsSystem().GetFact( 'ForceEmptyHands' ) ) || stateContext.GetBoolParameter( 'InVehicle', true ) ) || IsNoCombatActionsForced( scriptInterface ) );
	}

	protected const function CheckGenericEquipItemConditions( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( ( ( ( ( scriptInterface.CanEquipItem( stateContext ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel ) < ( ( Int32 )( gamePSMHighLevel.SceneTier5 ) ) ) ) && !( stateContext.IsStateActive( 'Locomotion', 'vault' ) ) ) && ( !( IsEmptyHandsForced( stateContext, scriptInterface ) ) || HasActiveConsumable( scriptInterface ) ) ) && !( IsInItemWheelState( stateContext ) ) ) && stateContext.GetStateMachineCurrentState( 'Vehicle' ) != 'entering' ) && stateContext.GetStateMachineCurrentState( 'Vehicle' ) != 'switchSeats' ) && !( IsVehicleBlockingCombat( scriptInterface ) );
	}

	protected const function IsCarryingBody( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.Carrying );
	}

	protected const function CompareLocalBlackboardInt( const scriptInterface : StateGameScriptInterface, blackboardID : BlackboardID_Int, CompareTo : Int32 ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( blackboardID ) == CompareTo;
	}

	protected const function IsExaminingDevice( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice );
	}

	protected const function HasActiveConsumable( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var consumable : ItemID;
		consumable = EquipmentSystem.GetData( scriptInterface.executionOwner ).GetActiveConsumable();
		return ItemID.IsValid( consumable );
	}

	public const function IsInItemWheelState( const stateContext : StateContext ) : Bool
	{
		var quickSlotsStateName : CName;
		quickSlotsStateName = stateContext.GetStateMachineCurrentState( 'QuickSlots' );
		return ( quickSlotsStateName == 'WeaponWheel' || quickSlotsStateName == 'VehicleWheel' ) || quickSlotsStateName == 'InteractionWheel';
	}

	public const function IsInEmptyHandsState( const stateContext : StateContext ) : Bool
	{
		var upperBodyStateName : CName;
		upperBodyStateName = stateContext.GetStateMachineCurrentState( 'UpperBody' );
		return ( upperBodyStateName == 'emptyHands' || upperBodyStateName == 'forceEmptyHands' ) || upperBodyStateName == 'forceSafe';
	}

	public const function IsInUpperBodyState( const stateContext : StateContext, upperBodyStateName : CName ) : Bool
	{
		var upperBodyState : CName;
		upperBodyState = stateContext.GetStateMachineCurrentState( 'UpperBody' );
		return upperBodyState == upperBodyStateName;
	}

	public const function IsInHighLevelState( const stateContext : StateContext, highLevelStateName : CName ) : Bool
	{
		var highLevelState : CName;
		highLevelState = stateContext.GetStateMachineCurrentState( 'HighLevel' );
		return highLevelState == highLevelStateName;
	}

	public const function IsInWeaponReloadState( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) );
	}

	public const function IsWeaponStateBlockingAiming( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) );
	}

	public static function GetBlackboardIntVariable( const executionOwner : GameObject, id : BlackboardID_Int ) : Int32
	{
		var blackboardSystem : BlackboardSystem;
		var blackboard : IBlackboard;
		blackboardSystem = GameInstance.GetBlackboardSystem( executionOwner.GetGame() );
		blackboard = blackboardSystem.GetLocalInstanced( executionOwner.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine );
		return blackboard.GetInt( id );
	}

	public const function IsInVisionModeActiveState( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vision ) == ( ( Int32 )( gamePSMVision.Focus ) );
	}

	public const function IsInTakedownState( const stateContext : StateContext ) : Bool
	{
		return stateContext.IsStateMachineActive( 'LocomotionTakedown' );
	}

	public const function IsInLocomotionState( const stateContext : StateContext, locomotionStateName : CName ) : Bool
	{
		var locomotionState : CName;
		locomotionState = stateContext.GetStateMachineCurrentState( 'Locomotion' );
		return locomotionState == locomotionStateName;
	}

	public const function GetLocomotionState( const stateContext : StateContext ) : CName
	{
		var locomotionState : CName;
		locomotionState = stateContext.GetStateMachineCurrentState( 'Locomotion' );
		return locomotionState;
	}

	public const function IsInVehicleState( const stateContext : StateContext, vehicleStateName : CName ) : Bool
	{
		var vehicleState : CName;
		vehicleState = stateContext.GetStateMachineCurrentState( 'Vehicle' );
		return vehicleState == vehicleStateName;
	}

	public const function IsInInputContextState( const stateContext : StateContext, inputContextStateName : CName ) : Bool
	{
		var inputContextState : CName;
		inputContextState = stateContext.GetStateMachineCurrentState( 'InputContext' );
		return inputContextState == inputContextStateName;
	}

	public const function IsInLadderState( const stateContext : StateContext ) : Bool
	{
		var ladderState : CName;
		ladderState = stateContext.GetStateMachineCurrentState( 'Locomotion' );
		return ( ( ( ladderState == 'ladder' || ladderState == 'ladderSprint' ) || ladderState == 'ladderSlide' ) || ladderState == 'ladderCrouch' ) || ladderState == 'ladderJump';
	}

	public const function IsInMeleeState( const stateContext : StateContext, meleeStateName : CName ) : Bool
	{
		var meleeState : CName;
		var identifier : StateMachineIdentifier;
		identifier.definitionName = 'Melee';
		identifier.referenceName = 'WeaponRight';
		meleeState = stateContext.GetStateMachineCurrentStateWithIdentifier( identifier );
		return meleeState == meleeStateName;
	}

	protected const function IsInSlidingState( const stateContext : StateContext ) : Bool
	{
		var slidingState : CName;
		slidingState = stateContext.GetStateMachineCurrentState( 'Locomotion' );
		return ( slidingState == 'slide' || slidingState == 'slideAfterFall' ) || slidingState == 'slideFall';
	}

	public const function CompareSMState( const smName : CName, const smState : CName, const stateContext : StateContext ) : Bool
	{
		var smCurrentState : CName;
		smCurrentState = stateContext.GetStateMachineCurrentState( smName );
		return smCurrentState == smState;
	}

	public const function CompareSMStateWithIden( const definitionName : CName, const referenceName : CName, const smState : CName, const stateContext : StateContext ) : Bool
	{
		var smCurrentState : CName;
		var identifier : StateMachineIdentifier;
		identifier.definitionName = definitionName;
		identifier.referenceName = referenceName;
		smCurrentState = stateContext.GetStateMachineCurrentStateWithIdentifier( identifier );
		return smCurrentState == smState;
	}

	public const function CompareSMState( const smName : CName, const smState : array< CName >, const stateContext : StateContext ) : Bool
	{
		var smCurrentState : CName;
		var i : Int32;
		smCurrentState = stateContext.GetStateMachineCurrentState( smName );
		for( i = 0; i < smState.Size(); i += 1 )
		{
			if( smCurrentState == smState[ i ] )
			{
				return true;
			}
		}
		return false;
	}

	protected const function CheckActiveConsumable( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var ts : TransactionSystem;
		var itemValid : Bool;
		var inInventory : Bool;
		ts = scriptInterface.GetTransactionSystem();
		itemValid = ItemID.IsValid( EquipmentSystem.GetData( scriptInterface.owner ).GetActiveConsumable() );
		inInventory = ts.GetItemQuantity( scriptInterface.owner, EquipmentSystem.GetData( scriptInterface.owner ).GetActiveConsumable() ) > 0;
		return itemValid && inInventory;
	}

	protected const function GetItemInRightHandSlot( const scriptInterface : StateGameScriptInterface ) : ItemObject
	{
		var transactionSystem : TransactionSystem;
		transactionSystem = scriptInterface.GetTransactionSystem();
		return transactionSystem.GetItemInSlot( scriptInterface.owner, T"AttachmentSlots.WeaponRight" );
	}

	protected const function GetItemInLeftHandSlot( const scriptInterface : StateGameScriptInterface ) : ItemObject
	{
		var transactionSystem : TransactionSystem;
		transactionSystem = scriptInterface.GetTransactionSystem();
		return transactionSystem.GetItemInSlot( scriptInterface.owner, T"AttachmentSlots.WeaponLeft" );
	}

	protected const function IsRightHandInEquippedState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'RightHand';
		return stateContext.IsStateActiveWithIdentifier( smIden, 'equipped' );
	}

	protected const function IsRightHandInUnequippedState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		var state : CName;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'RightHand';
		state = stateContext.GetStateMachineCurrentStateWithIdentifier( smIden );
		return state == 'None' || state == 'unequipped';
	}

	protected const function IsRightHandChangingEquipState( const stateContext : StateContext ) : Bool
	{
		return IsRightHandInUnequippingState( stateContext ) || IsRightHandInEquippingState( stateContext );
	}

	protected const function IsRightHandInUnequippingState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'RightHand';
		return stateContext.IsStateActiveWithIdentifier( smIden, 'unequipCycle' );
	}

	protected const function IsRightHandInEquippingState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'RightHand';
		return stateContext.IsStateActiveWithIdentifier( smIden, 'equipCycle' );
	}

	protected const function IsLeftHandInEquippedState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'LeftHand';
		return stateContext.IsStateActiveWithIdentifier( smIden, 'equipped' );
	}

	protected const function IsLeftHandInUnequippedState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		var state : CName;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'LeftHand';
		state = stateContext.GetStateMachineCurrentStateWithIdentifier( smIden );
		return state == 'None' || state == 'unequipped';
	}

	protected const function IsLeftHandInUnequippingState( const stateContext : StateContext ) : Bool
	{
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = 'LeftHand';
		return stateContext.IsStateActiveWithIdentifier( smIden, 'unequipCycle' );
	}

	protected const function GetReferenceNameFromEquipmentSide( side : EEquipmentSide ) : CName
	{
		switch( side )
		{
			case EEquipmentSide.Left:
				return 'LeftHand';
			case EEquipmentSide.Right:
				return 'RightHand';
		}
	}

	protected const function GetStateNameFromEquipmentState( equipmentState : EEquipmentState ) : CName
	{
		switch( equipmentState )
		{
			case EEquipmentState.Unequipped:
				return 'unequipped';
			case EEquipmentState.Equipped:
				return 'equipped';
			case EEquipmentState.Equipping:
				return 'equipCycle';
			case EEquipmentState.Unequipping:
				return 'unequipCycle';
			case EEquipmentState.FirstEquip:
				return 'firstEquip';
		}
	}

	protected const function CheckEquipmentStateMachineState( const stateContext : StateContext, SMSide : EEquipmentSide, compareToState : EEquipmentState ) : Bool
	{
		var smMissing : Bool;
		var smIden : StateMachineIdentifier;
		smIden.definitionName = 'Equipment';
		smIden.referenceName = GetReferenceNameFromEquipmentSide( SMSide );
		smMissing = stateContext.IsStateMachineActiveWithIdentifier( smIden );
		return stateContext.IsStateActiveWithIdentifier( smIden, GetStateNameFromEquipmentState( compareToState ) ) || ( compareToState == EEquipmentState.Unequipped && smMissing );
	}

	protected const function IsAnyEquipmentStateMachineActive( stateContext : StateContext ) : Bool
	{
		var leftSmIden : StateMachineIdentifier;
		var rightSmIden : StateMachineIdentifier;
		rightSmIden.definitionName = 'Equipment';
		rightSmIden.referenceName = GetReferenceNameFromEquipmentSide( EEquipmentSide.Right );
		if( stateContext.IsStateMachineActiveWithIdentifier( rightSmIden ) )
		{
			return true;
		}
		leftSmIden.definitionName = 'Equipment';
		leftSmIden.referenceName = GetReferenceNameFromEquipmentSide( EEquipmentSide.Left );
		return stateContext.IsStateMachineActiveWithIdentifier( leftSmIden );
	}

	protected const function IsInFirstEquip( const stateContext : StateContext ) : Bool
	{
		var result : StateResultBool;
		result = stateContext.GetConditionBoolParameter( 'firstEquip' );
		return result.valid && result.value;
	}

	protected const function AreChoiceHubsActive( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var interactonsBlackboard : IBlackboard;
		var interactionData : UIInteractionsDef;
		var data : DialogChoiceHubs;
		interactonsBlackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UIInteractions );
		interactionData = GetAllBlackboardDefs().UIInteractions;
		data = ( ( DialogChoiceHubs )( interactonsBlackboard.GetVariant( interactionData.DialogChoiceHubs ) ) );
		return data.choiceHubs.Size() > 0;
	}

	protected const function GetLootData( const scriptInterface : StateGameScriptInterface ) : LootData
	{
		var interactonsBlackboard : IBlackboard;
		var interactionData : UIInteractionsDef;
		var data : LootData;
		interactonsBlackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UIInteractions );
		interactionData = GetAllBlackboardDefs().UIInteractions;
		data = ( ( LootData )( interactonsBlackboard.GetVariant( interactionData.LootData ) ) );
		return data;
	}

	protected const function IsLootDataActive( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var data : LootData;
		data = GetLootData( scriptInterface );
		return data.isActive;
	}

	protected const function ItemsInLootData( const scriptInterface : StateGameScriptInterface ) : Int32
	{
		var data : LootData;
		var items : array< ItemID >;
		data = GetLootData( scriptInterface );
		items = data.itemIDs;
		return items.Size();
	}

	protected const function CheckConsumableLootDataCondition( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( IsLootDataActive( scriptInterface ) )
		{
			return ItemsInLootData( scriptInterface ) <= 1;
		}
		else
		{
			return true;
		}
	}

	protected const function SetItemIDWrapperPermanentParameter( stateContext : StateContext, parameterName : CName, item : ItemID )
	{
		var wrapper : ItemIdWrapper;
		wrapper = new ItemIdWrapper;
		wrapper.itemID = item;
		stateContext.SetPermanentScriptableParameter( parameterName, wrapper, true );
	}

	protected const function GetItemIDFromWrapperPermanentParameter( stateContext : StateContext, parameterName : CName ) : ItemID
	{
		var wrapper : ItemIdWrapper;
		wrapper = ( ( ItemIdWrapper )( stateContext.GetPermanentScriptableParameter( parameterName ) ) );
		if( wrapper )
		{
			return wrapper.itemID;
		}
		return ItemID.None();
	}

	protected const function ClearItemIDWrapperPermanentParameter( stateContext : StateContext, parameterName : CName )
	{
		stateContext.RemovePermanentScriptableParameter( parameterName );
	}

	protected const function IsPlayerInAnyMenu( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var blackboard : IBlackboard;
		var uiSystemBB : UI_SystemDef;
		blackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UI_System );
		uiSystemBB = GetAllBlackboardDefs().UI_System;
		return blackboard.GetBool( uiSystemBB.IsInMenu );
	}

	protected const function SendDataTrackingRequest( scriptInterface : StateGameScriptInterface, telemetryData : ETelemetryData, modifyValue : Int32 )
	{
		var request : ModifyTelemetryVariable;
		request = new ModifyTelemetryVariable;
		request.dataTrackingFact = telemetryData;
		request.value = modifyValue;
		scriptInterface.GetScriptableSystem( 'DataTrackingSystem' ).QueueRequest( request );
	}

	protected function RequestVehicleCameraPerspective( scriptInterface : StateGameScriptInterface, requestedCameraPerspective : vehicleCameraPerspective )
	{
		var camEvent : vehicleRequestCameraPerspectiveEvent;
		camEvent = new vehicleRequestCameraPerspectiveEvent;
		camEvent.cameraPerspective = requestedCameraPerspective;
		scriptInterface.executionOwner.QueueEvent( camEvent );
	}

	protected function SetVehicleCameraSceneMode( scriptInterface : StateGameScriptInterface, sceneMode : Bool )
	{
		var camEvent : vehicleCameraSceneEnableEvent;
		camEvent = new vehicleCameraSceneEnableEvent;
		camEvent.scene = sceneMode;
		scriptInterface.executionOwner.QueueEvent( camEvent );
	}

	protected const function IsInSafeZone( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( gamePSMZones )( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Zones ) ) ) == gamePSMZones.Safe;
	}

	protected function TutorialSetFact( scriptInterface : StateGameScriptInterface, factName : CName )
	{
		var questSystem : QuestsSystem;
		questSystem = scriptInterface.GetQuestsSystem();
		if( ( questSystem.GetFact( factName ) == 0 ) && ( questSystem.GetFact( 'disable_tutorials' ) == 0 ) )
		{
			questSystem.SetFact( factName, 1 );
		}
	}

	protected const function TutorialAddFact( scriptInterface : StateGameScriptInterface, factName : CName, add : Int32 )
	{
		var questSystem : QuestsSystem;
		var val : Int32;
		questSystem = scriptInterface.GetQuestsSystem();
		if( questSystem.GetFact( 'disable_tutorials' ) == 0 )
		{
			val = questSystem.GetFact( factName ) + add;
			questSystem.SetFact( factName, val );
		}
	}

	protected const function IsQuickHackPanelOpened( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var bb : IBlackboard;
		bb = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UI_QuickSlotsData );
		return bb.GetBool( GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen );
	}

	protected const function IsRadialWheelOpen( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var bb : IBlackboard;
		bb = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UI_QuickSlotsData );
		return bb.GetBool( GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest );
	}

	protected const function IsTimeDilationActive( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, timeDilationReason : CName ) : Bool
	{
		var timeSystem : TimeSystem;
		timeSystem = scriptInterface.GetTimeSystem();
		return timeSystem.IsTimeDilationActive( timeDilationReason );
	}

	protected const function ThreatsOnPlayerThreatList( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetPlayerPuppet( scriptInterface ).GetTargetTrackerComponent().HasHostileThreat( false );
	}

	protected const function IsPlayerInSecuritySystem( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var overlappedZones : array< PersistentID >;
		overlappedZones = GetPlayerPuppet( scriptInterface ).GetOverlappedSecurityZones();
		return overlappedZones.Size() > 0;
	}

	protected const function IsInStealthLocomotion( const stateContext : StateContext ) : Bool
	{
		return CompareSMState( 'Locomotion', 'crouch', stateContext );
	}

	protected const function ShowInputHint( const scriptInterface : StateGameScriptInterface, actionName : CName, source : CName, label : String, optional holdIndicationType : inkInputHintHoldIndicationType, optional enableHoldAnimation : Bool )
	{
		var evt : UpdateInputHintEvent;
		var data : InputHintData;
		if( IsDisplayingInputHintBlocked( scriptInterface, actionName ) )
		{
			return;
		}
		data.action = actionName;
		data.source = source;
		data.localizedLabel = label;
		data.holdIndicationType = holdIndicationType;
		data.enableHoldAnimation = enableHoldAnimation;
		evt = new UpdateInputHintEvent;
		evt.data = data;
		evt.show = true;
		evt.targetHintContainer = 'GameplayInputHelper';
		scriptInterface.GetUISystem().QueueEvent( evt );
	}

	protected const function RemoveInputHint( const scriptInterface : StateGameScriptInterface, actionName : CName, source : CName )
	{
		var evt : UpdateInputHintEvent;
		var data : InputHintData;
		data.action = actionName;
		data.source = source;
		evt = new UpdateInputHintEvent;
		evt.data = data;
		evt.show = false;
		evt.targetHintContainer = 'GameplayInputHelper';
		scriptInterface.GetUISystem().QueueEvent( evt );
	}

	protected const function RemoveInputHintsBySource( const scriptInterface : StateGameScriptInterface, source : CName )
	{
		var evt : DeleteInputHintBySourceEvent;
		evt = new DeleteInputHintBySourceEvent;
		evt.source = source;
		evt.targetHintContainer = 'GameplayInputHelper';
		scriptInterface.GetUISystem().QueueEvent( evt );
	}

	protected const function IsDisplayingInputHintBlocked( const scriptInterface : StateGameScriptInterface, actionName : CName ) : Bool
	{
		switch( actionName )
		{
			case 'RangedAttack':
				return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoCombat' ) || !( HasAnyValidWeaponAvailable( scriptInterface ) );
			case 'Jump':
				return StatusEffectSystem.ObjectHasStatusEffect( scriptInterface.executionOwner, T"GameplayRestriction.NoJump" );
			case 'Exit':
				return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'VehicleScene' );
			case 'ToggleVehCamera':
				return IsVehicleCameraChangeBlocked( scriptInterface );
			case 'WeaponWheel':
				return IsNoCombatActionsForced( scriptInterface ) || IsVehicleExitCombatModeBlocked( scriptInterface );
			case 'Dodge':
				return IsInTier2Locomotion( scriptInterface ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'PhoneCall' );
			case 'SwitchItem':
				return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoCombat' ) || !( EquipmentSystem.HasItemInArea( scriptInterface.executionOwner, gamedataEquipmentArea.Weapon ) );
			case 'DropCarriedObject':
				return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'BodyCarryingNoDrop' );
			case 'QuickMelee':
				return StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoQuickMelee' );
			default:
				return false;
		}
	}

	protected const function GetCancelChargeButtonInput( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.IsActionJustPressed( 'CancelChargingCG' );
	}

	protected const function ProcessCombatGadgetActionInputCaching( const scriptInterface : StateGameScriptInterface, stateContext : StateContext )
	{
		if( scriptInterface.IsActionJustHeld( 'UseCombatGadget' ) && !( stateContext.GetBoolParameter( 'cgCached', true ) ) )
		{
			stateContext.SetPermanentBoolParameter( 'cgCached', true, true );
		}
		else if( stateContext.GetBoolParameter( 'cgCached', true ) && ( scriptInterface.GetActionValue( 'UseCombatGadget' ) == 0.0 ) )
		{
			stateContext.RemovePermanentBoolParameter( 'cgCached' );
		}
	}

	protected const function ProcessPermanentBoolParameterToggle( parameterName : CName, state : Bool, stateContext : StateContext )
	{
		if( state )
		{
			stateContext.SetPermanentBoolParameter( parameterName, state, true );
		}
		else
		{
			stateContext.RemovePermanentBoolParameter( parameterName );
		}
	}

	protected const function ForceDisableToggleWalk( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'ForceDisableToggleWalk', true, true );
	}

	protected const function TriggerNoiseStim( owner : weak< GameObject >, takedownActionType : ETakedownActionType )
	{
		var broadcaster : StimBroadcasterComponent;
		broadcaster = owner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			broadcaster.TriggerNoiseStim( owner, takedownActionType );
		}
	}

	protected function ActivateDamageProjection( newState : Bool, weapon : WeaponObject, scriptInterface : StateGameScriptInterface, stateContext : StateContext )
	{
		var game : GameInstance;
		var damageSystem : DamageSystem;
		var blackboard : IBlackboard;
		game = scriptInterface.executionOwner.GetGame();
		damageSystem = GameInstance.GetDamageSystem( game );
		damageSystem.ClearPreviewTargetStruct();
		if( weapon )
		{
			damageSystem.SetPreviewLock( !( newState ) );
			weapon.GetCurrentAttack().SetDamageProjectionActive( newState );
			stateContext.SetPermanentBoolParameter( 'DamagePreviewActive', true, true );
		}
		if( !( newState ) )
		{
			GameInstance.GetBlackboardSystem( game ).Get( GetAllBlackboardDefs().UI_NameplateData );
			if( blackboard )
			{
				blackboard.SetInt( GetAllBlackboardDefs().UI_NameplateData.DamageProjection, 0, true );
			}
			damageSystem.ClearPreviewTargetStruct();
			stateContext.RemovePermanentBoolParameter( 'DamagePreviewActive' );
		}
	}

	protected function IsNameplateVisible( scriptInterface : StateGameScriptInterface ) : Bool
	{
		var blackboard : IBlackboard;
		blackboard = scriptInterface.GetBlackboardSystem().Get( GetAllBlackboardDefs().UI_NameplateData );
		return blackboard.GetBool( GetAllBlackboardDefs().UI_NameplateData.IsVisible );
	}

	protected function HandleDamagePreview( weapon : WeaponObject, scriptInterface : StateGameScriptInterface, stateContext : StateContext )
	{
		var inStealth : Bool;
		inStealth = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Combat ) == ( ( Int32 )( gamePSMCombat.Stealth ) );
		if( ( ( inStealth && CanWeaponSilentKill( weapon, scriptInterface ) ) && IsNameplateVisible( scriptInterface ) ) && !( stateContext.GetBoolParameter( 'DamagePreviewActive', true ) ) )
		{
			ActivateDamageProjection( true, weapon, scriptInterface, stateContext );
		}
		else if( stateContext.GetBoolParameter( 'DamagePreviewActive', true ) && ( ( !( inStealth ) || !( IsNameplateVisible( scriptInterface ) ) ) || !( CanWeaponSilentKill( weapon, scriptInterface ) ) ) )
		{
			ActivateDamageProjection( false, weapon, scriptInterface, stateContext );
		}
	}

	protected const function CanWeaponSilentKill( weapon : WeaponObject, scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetStatsSystem().GetStatValue( weapon.GetEntityID(), gamedataStatType.CanSilentKill ) > 0.0;
	}

	protected const function UsingJohnnyReplacer( scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( gamePuppetBase )( scriptInterface.executionOwner ) ).GetRecordID() == T"Character.johnny_replacer";
	}

	protected const function IsPlayingAsReplacer( scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ( ( gamePuppetBase )( scriptInterface.executionOwner ) ).GetRecordID() != T"Character.Player_Puppet_Base";
	}

	protected const function IsFastForwardByLine( scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GameplaySettingsSystem.GetIsFastForwardByLine( scriptInterface.executionOwner );
	}

	protected const function CheckIsFastForwardByLine( scriptInterface : StateGameScriptInterface ) : Bool
	{
		var gss : GameplaySettingsSystem;
		gss = ( ( GameplaySettingsSystem )( GameInstance.GetScriptableSystemsContainer( scriptInterface.owner.GetGame() ).Get( 'GameplaySettingsSystem' ) ) );
		return gss.GetIsFastForwardByLine();
	}

	protected const function GetFFParamsForCrouch( scriptInterface : StateGameScriptInterface ) : CName
	{
		var param : CName;
		param = ( ( CheckIsFastForwardByLine( scriptInterface ) ) ? ( 'FFhintActive' ) : ( 'FFHoldLock' ) );
		return param;
	}

	protected function UpdateCameraParams( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var sceneTier : GameplayTier;
		var param : StateResultCName;
		var item : ItemID;
		var consumableStartupFirstFrame : Bool;
		var takedownState : Int32;
		sceneTier = GetCurrentTier( stateContext );
		if( sceneTier == GameplayTier.Tier4_FPPCinematic )
		{
			QueueSetCameraParamsEvent( 'Tier4Scene', scriptInterface );
			return;
		}
		if( sceneTier == GameplayTier.Tier3_LimitedGameplay )
		{
			QueueSetCameraParamsEvent_Tier3Scene( stateContext, scriptInterface );
			return;
		}
		if( stateContext.IsStateMachineActive( 'Vehicle' ) )
		{
			param = stateContext.GetPermanentCNameParameter( 'VehicleCameraParams' );
			if( param.valid && param.value != '' )
			{
				QueueSetCameraParamsEvent( param.value, scriptInterface );
				return;
			}
		}
		consumableStartupFirstFrame = stateContext.GetBoolParameter( 'CameraContext_ConsumableStartup', false );
		if( ( consumableStartupFirstFrame || stateContext.IsStateActive( 'Consumable', 'consumableUse' ) ) || stateContext.IsStateActive( 'Consumable', 'consumableStartup' ) )
		{
			item = GetActiveLeftHandItem( scriptInterface ).GetItemID();
			if( ItemID.IsValid( item ) )
			{
				QueueSetCameraParamsEvent( 'UseConsumable', scriptInterface );
				return;
			}
		}
		param = stateContext.GetPermanentCNameParameter( 'LadderCameraParams' );
		if( param.valid && param.value != '' )
		{
			QueueSetCameraParamsEvent( param.value, scriptInterface );
			return;
		}
		takedownState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Takedown );
		if( ( takedownState != ( ( Int32 )( gamePSMTakedown.Default ) ) ) && ( takedownState != ( ( Int32 )( gamePSMTakedown.Grapple ) ) ) )
		{
			QueueSetCameraParamsEvent( 'WorkspotLocked', scriptInterface );
			return;
		}
		if( stateContext.GetBoolParameter( 'setBodyCarryContext', true ) )
		{
			QueueSetCameraParamsEvent( 'BodyCarry', scriptInterface );
			return;
		}
		if( stateContext.GetBoolParameter( 'setBodyPickUpContext', true ) )
		{
			QueueSetCameraParamsEvent( 'BodyPickUp', scriptInterface );
			return;
		}
		if( stateContext.GetBoolParameter( 'setBodyCarryFriendlyContext', true ) )
		{
			QueueSetCameraParamsEvent( 'BodyCarryFriendly', scriptInterface );
			return;
		}
		if( sceneTier == GameplayTier.Tier2_StagedGameplay && StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'SpaceShuttleInterior' ) )
		{
			QueueSetCameraParamsEvent( 'SpaceShuttleInterior', scriptInterface );
			return;
		}
		param = stateContext.GetPermanentCNameParameter( 'LocomotionCameraParams' );
		if( param.valid )
		{
			QueueSetCameraParamsEvent( param.value, scriptInterface );
		}
	}

	private function QueueSetCameraParamsEvent_Tier3Scene( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		const var sceneTier3Data : SceneTier3Data;
		var cameraSettings : Tier3CameraSettings;
		var setCameraParamsEvent : SetCameraParamsWithOverridesEvent;
		sceneTier3Data = ( ( SceneTier3Data )( GetCurrentSceneTierData( stateContext ) ) );
		cameraSettings = sceneTier3Data.cameraSettings;
		setCameraParamsEvent = new SetCameraParamsWithOverridesEvent;
		setCameraParamsEvent.paramsName = 'Tier3Scene';
		setCameraParamsEvent.yawMaxLeft = cameraSettings.yawLeftLimit;
		setCameraParamsEvent.yawMaxRight = -( cameraSettings.yawRightLimit );
		setCameraParamsEvent.pitchMax = cameraSettings.pitchTopLimit;
		setCameraParamsEvent.pitchMin = -( cameraSettings.pitchBottomLimit );
		setCameraParamsEvent.sensitivityMultX = cameraSettings.yawSpeedMultiplier;
		setCameraParamsEvent.sensitivityMultY = cameraSettings.pitchSpeedMultiplier;
		scriptInterface.executionOwner.QueueEvent( setCameraParamsEvent );
	}

	protected function QueueSetCameraParamsEvent( cameraParams : CName, scriptInterface : StateGameScriptInterface )
	{
		var setCameraParamsEvent : SetCameraParamsEvent;
		setCameraParamsEvent = new SetCameraParamsEvent;
		setCameraParamsEvent.paramsName = cameraParams;
		scriptInterface.executionOwner.QueueEvent( setCameraParamsEvent );
	}

	public virtual function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, value : Float ) {}

	public virtual function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > ) {}

	public virtual function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > ) {}

	public virtual function OnItemEquipped( slot : TweakDBID, item : ItemID ) {}

	public virtual function OnItemUnequipped( slot : TweakDBID, item : ItemID ) {}
}

class GameplayCameraData extends IScriptable
{
	var is_forward_offset : Float;
	default is_forward_offset = 1.0f;
	var upperbody_pitch_weight : Float;
	default upperbody_pitch_weight = 0.0f;
	var forward_offset_value : Float;
	default forward_offset_value = 0.2f;
	var upperbody_yaw_weight : Float;
	default upperbody_yaw_weight = 0.0f;
	var is_pitch_off : Float;
	default is_pitch_off = 0.0f;
	var is_yaw_off : Float;
	default is_yaw_off = 0.0f;
}

class DefaultTransitionStatListener extends ScriptStatsListener
{
	var m_transitionOwner : weak< DefaultTransition >;

	public export override function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, total : Float )
	{
		m_transitionOwner.OnStatChanged( ownerID, statType, diff, total );
	}

}

class DefaultTransitionStatusEffectListener extends ScriptStatusEffectListener
{
	var m_transitionOwner : weak< DefaultTransition >;

	public export virtual function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		m_transitionOwner.OnStatusEffectApplied( statusEffect );
	}

	public export virtual function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		m_transitionOwner.OnStatusEffectRemoved( statusEffect );
	}

}

class DefaultTransitionAttachmentSlotsCallback extends AttachmentSlotsScriptCallback
{
	var m_transitionOwner : weak< DefaultTransition >;

	public export override function OnItemEquipped( slot : TweakDBID, item : ItemID )
	{
		m_transitionOwner.OnItemEquipped( slot, item );
	}

	public export override function OnItemUnequipped( slot : TweakDBID, item : ItemID )
	{
		m_transitionOwner.OnItemUnequipped( slot, item );
	}

}

enum EPlayerMovementDirection
{
	Forward = 0,
	Right = 1,
	Back = 2,
	Left = 3,
}

enum EAimAssistLevel
{
	Off = 0,
	Light = 1,
	Standard = 2,
}

