abstract class WeaponTransition extends DefaultTransition
{
	var m_magazineID : TweakDBID;
	var m_magazineAttack : TweakDBID;
	var m_rangedAttackPackage : RangedAttackPackage_Record;

	protected function ShowAttackPreview( showIfAiming : Bool, weaponObject : WeaponObject, scriptInterface : StateGameScriptInterface, stateContext : StateContext )
	{
		var ricochetEnableStat : Float;
		var techPierceStat : Float;
		var ricochetCount : Float;
		var statSystem : StatsSystem;
		var weaponRecord : WeaponItem_Record;
		var isAiming : Bool;
		var show : Bool;
		show = false;
		isAiming = showIfAiming && stateContext.IsStateActive( 'UpperBody', 'aimingState' );
		if( isAiming )
		{
			statSystem = scriptInterface.GetStatsSystem();
			weaponRecord = weaponObject.GetWeaponRecord();
			if( weaponRecord && weaponRecord.PreviewEffectName() != '' )
			{
				techPierceStat = statSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.TechPierceEnabled );
				if( weaponRecord.PreviewEffectTag() == 'ricochet' )
				{
					ricochetEnableStat = statSystem.GetStatValue( scriptInterface.executionOwnerEntityID, gamedataStatType.CanSeeRicochetVisuals );
					ricochetCount = statSystem.GetStatValue( scriptInterface.executionOwnerEntityID, gamedataStatType.RicochetCount );
					show = ( ricochetEnableStat > 0.0 ) && ( ricochetCount > 0.0 );
				}
				else if( weaponRecord.PreviewEffectTag() == 'pierce' )
				{
					show = techPierceStat > 0.0;
				}
			}
		}
		weaponObject.GetCurrentAttack().SetPreviewActive( show );
	}

	protected function GetDesiredAttackRecord( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Attack_Record
	{
		var weaponObject : WeaponObject;
		var weaponRecord : WeaponItem_Record;
		var rangedAttack : RangedAttack_Record;
		var attackRecord : Attack_Record;
		var weaponCharge : Float;
		var magazine : InnerItemData;
		weaponObject = GetWeaponObject( scriptInterface );
		weaponRecord = weaponObject.GetWeaponRecord();
		if( !( m_rangedAttackPackage ) )
		{
			m_rangedAttackPackage = weaponRecord.RangedAttacks();
		}
		weaponObject.GetItemData().GetItemPart( magazine, T"AttachmentSlots.DamageMod" );
		if( m_magazineID != ItemID.GetTDBID( InnerItemData.GetItemID( magazine ) ) )
		{
			m_magazineID = ItemID.GetTDBID( InnerItemData.GetItemID( magazine ) );
			if( TDBID.IsValid( m_magazineID ) )
			{
				m_magazineAttack = TDBID.Create( TweakDBInterface.GetString( m_magazineID + T".overrideAttack", "" ) );
				m_rangedAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord( m_magazineAttack );
			}
			else
			{
				m_magazineAttack = T"";
			}
		}
		weaponCharge = WeaponObject.GetWeaponChargeNormalized( weaponObject );
		rangedAttack = ( ( weaponCharge >= 1.0 ) ? ( m_rangedAttackPackage.ChargeFire() ) : ( m_rangedAttackPackage.DefaultFire() ) );
		if( scriptInterface.GetTimeSystem().IsTimeDilationActive() && !( weaponRecord.Evolution().Type() == gamedataWeaponEvolution.Tech ) )
		{
			attackRecord = rangedAttack.PlayerTimeDilated();
		}
		else
		{
			attackRecord = rangedAttack.PlayerAttack();
		}
		return attackRecord;
	}

	protected constexpr const function GetBurstTimeRemainingName() : CName
	{
		return 'ShootingSequence.BurstTimeRemaining';
	}

	protected constexpr const function GetBurstCycleTimeName() : CName
	{
		return 'ShootingSequence.BurstCycleTime';
	}

	protected constexpr const function GetCycleTimeRemainingName() : CName
	{
		return 'ShootingSequence.CycleTimeRemaining';
	}

	protected constexpr const function GetBurstShotsRemainingName() : CName
	{
		return 'ShootingSequence.BurstShotsRemaining';
	}

	protected constexpr const function GetShootingStartName() : CName
	{
		return 'ShootingSequence.Start';
	}

	protected constexpr const function GetShootingNumBurstTotalName() : CName
	{
		return 'ShootingSequence.NumBurstTotal';
	}

	protected constexpr const function GetIsDelayFireName() : CName
	{
		return 'ShootingSequence.IsDelayFire';
	}

	protected constexpr const function GetIsChargedFullAutoName() : CName
	{
		return 'ShootingSequence.IsChargedFullAutoSequence';
	}

	protected constexpr const function GetQuestForceShootName() : CName
	{
		return 'questForceShoot';
	}

	protected const function InShootingSequence( stateContext : StateContext ) : Bool
	{
		return stateContext.GetFloatParameter( GetShootingStartName(), true ) > 0.0;
	}

	protected function StartShootingSequence( stateContext : StateContext, scriptInterface : StateGameScriptInterface, fireDelay : Float, burstCycleTime : Float, numShotsBurst : Int32, isFullChargeFullAuto : Bool )
	{
		stateContext.SetPermanentFloatParameter( GetCycleTimeRemainingName(), fireDelay, true );
		stateContext.SetPermanentBoolParameter( GetIsDelayFireName(), fireDelay > 0.0, true );
		stateContext.SetPermanentFloatParameter( GetBurstTimeRemainingName(), burstCycleTime, true );
		stateContext.SetPermanentFloatParameter( GetBurstCycleTimeName(), burstCycleTime, true );
		stateContext.SetPermanentIntParameter( GetBurstShotsRemainingName(), numShotsBurst, true );
		stateContext.SetPermanentIntParameter( GetShootingNumBurstTotalName(), 0, true );
		stateContext.SetPermanentFloatParameter( GetShootingStartName(), EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ), true );
		stateContext.SetPermanentBoolParameter( GetIsChargedFullAutoName(), isFullChargeFullAuto, true );
		GetWeaponObject( scriptInterface ).SetTriggerDown( true );
		GetWeaponObject( scriptInterface ).SetupBurstFireSound( numShotsBurst );
	}

	protected function ShootingSequencePostShoot( stateContext : StateContext )
	{
		var currShotCount : Int32;
		currShotCount = stateContext.GetIntParameter( GetBurstShotsRemainingName(), true );
		currShotCount = currShotCount - 1;
		stateContext.SetPermanentIntParameter( GetBurstShotsRemainingName(), Max( currShotCount, 0 ), true );
		stateContext.SetPermanentFloatParameter( GetBurstTimeRemainingName(), stateContext.GetFloatParameter( GetBurstCycleTimeName(), true ), true );
	}

	protected function SetupNextShootingPhase( stateContext : StateContext, cycleTime : Float, burstCycleTime : Float, numShotsBurst : Int32 )
	{
		var currBurstsInSequenceCount : Int32;
		currBurstsInSequenceCount = stateContext.GetIntParameter( GetShootingNumBurstTotalName(), true );
		stateContext.SetPermanentFloatParameter( GetCycleTimeRemainingName(), cycleTime, true );
		stateContext.SetPermanentFloatParameter( GetBurstTimeRemainingName(), burstCycleTime, true );
		stateContext.SetPermanentIntParameter( GetBurstShotsRemainingName(), numShotsBurst, true );
		stateContext.SetPermanentBoolParameter( GetIsDelayFireName(), false, true );
		stateContext.SetPermanentIntParameter( GetShootingNumBurstTotalName(), currBurstsInSequenceCount + 1, true );
	}

	protected function EndShootingSequence( weapon : WeaponObject, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetPermanentFloatParameter( GetCycleTimeRemainingName(), 0.0, true );
		stateContext.SetPermanentFloatParameter( GetBurstTimeRemainingName(), 0.0, true );
		stateContext.SetPermanentIntParameter( GetBurstShotsRemainingName(), 0, true );
		stateContext.SetPermanentIntParameter( GetShootingNumBurstTotalName(), 0, true );
		stateContext.SetPermanentFloatParameter( GetShootingStartName(), 0.0, true );
		stateContext.SetPermanentBoolParameter( GetIsDelayFireName(), false, true );
		stateContext.SetPermanentBoolParameter( GetIsChargedFullAutoName(), false, true );
		weapon.SetTriggerDown( false );
	}

	protected function ShootingSequenceUpdateCycleTime( timeDelta : Float, stateContext : StateContext )
	{
		var timeRemaining : Float;
		timeRemaining = stateContext.GetFloatParameter( GetCycleTimeRemainingName(), true );
		stateContext.SetPermanentFloatParameter( GetCycleTimeRemainingName(), MaxF( timeRemaining - timeDelta, 0.0 ), true );
	}

	protected function ShootingSequenceUpdateBurstTime( timeDelta : Float, stateContext : StateContext )
	{
		var timeRemaining : Float;
		timeRemaining = stateContext.GetFloatParameter( GetBurstTimeRemainingName(), true );
		stateContext.SetPermanentFloatParameter( GetBurstTimeRemainingName(), timeRemaining - timeDelta, true );
	}

	protected const function CanPerformNextShotInSequence( const weaponObject : WeaponObject, const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var gameInstance : GameInstance;
		var cycleTime : Float;
		var lastShotTime : Float;
		gameInstance = scriptInterface.GetGame();
		cycleTime = GameInstance.GetStatsSystem( gameInstance ).GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTime );
		lastShotTime = stateContext.GetFloatParameter( 'LastShotTime', true );
		return EngineTime.ToFloat( GameInstance.GetSimTime( gameInstance ) ) > ( lastShotTime + cycleTime );
	}

	protected const function CanPerformNextSemiAutoShot( weaponObject : WeaponObject, const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var validTriggerMode : Bool;
		validTriggerMode = false;
		if( CanPerformNextShotInSequence( weaponObject, stateContext, scriptInterface ) )
		{
			validTriggerMode = scriptInterface.IsTriggerModeActive( gamedataTriggerMode.SemiAuto ) || scriptInterface.IsTriggerModeActive( gamedataTriggerMode.Burst );
			return validTriggerMode && !( weaponObject.IsMagazineEmpty() );
		}
		return false;
	}

	protected const function CanPerformNextFullAutoShot( weaponObject : WeaponObject, const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var validTriggerMode : Bool;
		validTriggerMode = false;
		if( CanPerformNextShotInSequence( weaponObject, stateContext, scriptInterface ) )
		{
			validTriggerMode = scriptInterface.IsTriggerModeActive( gamedataTriggerMode.FullAuto ) || ( stateContext.GetBoolParameter( GetIsChargedFullAutoName(), true ) && scriptInterface.IsTriggerModeActive( gamedataTriggerMode.Charge ) );
			return validTriggerMode && !( weaponObject.IsMagazineEmpty() );
		}
		return false;
	}

	protected function SetupStandardShootingSequence( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		var statsSystem : StatsSystem;
		var burstCycleTimeStat : gamedataStatType;
		var burstNumShots : gamedataStatType;
		weaponObject = GetWeaponObject( scriptInterface );
		statsSystem = scriptInterface.GetStatsSystem();
		burstCycleTimeStat = gamedataStatType.CycleTime_Burst;
		burstNumShots = gamedataStatType.NumShotsInBurst;
		if( weaponObject.HasSecondaryTriggerMode() && !( IsPrimaryTriggerModeActive( scriptInterface ) ) )
		{
			burstCycleTimeStat = gamedataStatType.CycleTime_BurstSecondary;
			burstNumShots = gamedataStatType.NumShotsInBurstSecondary;
		}
		StartShootingSequence( stateContext, scriptInterface, statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.PreFireTime ), statsSystem.GetStatValue( weaponObject.GetEntityID(), burstCycleTimeStat ), ( ( Int32 )( statsSystem.GetStatValue( weaponObject.GetEntityID(), burstNumShots ) ) ), false );
	}

	protected const function IsSemiAutoAction( weaponObject : WeaponObject, const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 ) && IsInVisionModeActiveState( stateContext, scriptInterface ) )
		{
			return true;
		}
		return scriptInterface.IsActionJustPressed( 'RangedAttack' );
	}

	protected const function ToSemiAutoTransitionCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		return IsSemiAutoAction( weaponObject, stateContext, scriptInterface ) && CanPerformNextSemiAutoShot( weaponObject, stateContext, scriptInterface );
	}

	protected const function IsFullAutoAction( weaponObject : WeaponObject, const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0;
	}

	protected const function ToFullAutoTransitionCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		return IsFullAutoAction( weaponObject, stateContext, scriptInterface ) && CanPerformNextFullAutoShot( weaponObject, stateContext, scriptInterface );
	}

	protected function ShowDebugText( textToShow : String, scriptInterface : StateGameScriptInterface, out layerId : Uint32 )
	{
		layerId = GameInstance.GetDebugVisualizerSystem( scriptInterface.GetGame() ).DrawText( Vector4( 500.0, 550.0, 0.0, 0.0 ), textToShow, gameDebugViewETextAlignment.Left, Color( 255, 255, 0, 255 ) );
		GameInstance.GetDebugVisualizerSystem( scriptInterface.GetGame() ).SetScale( layerId, Vector4( 1.0, 1.0, 0.0, 0.0 ) );
	}

	protected function ClearDebugText( layerId : Uint32, scriptInterface : StateGameScriptInterface )
	{
		GameInstance.GetDebugVisualizerSystem( scriptInterface.GetGame() ).ClearLayer( layerId );
	}

	protected const function GetWeaponObject( const scriptInterface : StateGameScriptInterface ) : WeaponObject
	{
		return ( ( WeaponObject )( scriptInterface.owner ) );
	}

	protected function PlayEffect( effectName : CName, scriptInterface : StateGameScriptInterface, optional eventTag : CName )
	{
		var spawnEffectEvent : entSpawnEffectEvent;
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		if( weapon )
		{
			spawnEffectEvent = new entSpawnEffectEvent;
			spawnEffectEvent.effectName = effectName;
			spawnEffectEvent.effectInstanceName = eventTag;
			weapon.QueueEventToChildItems( spawnEffectEvent );
		}
	}

	protected function StopEffect( effectName : CName, scriptInterface : StateGameScriptInterface )
	{
		var killEffectEvent : entKillEffectEvent;
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( GetWeaponObject( scriptInterface ) ) );
		if( weapon )
		{
			killEffectEvent = new entKillEffectEvent;
			killEffectEvent.effectName = effectName;
			weapon.QueueEventToChildItems( killEffectEvent );
		}
	}

	protected function GetWeaponTriggerModesNumber( scriptInterface : StateGameScriptInterface ) : Int32
	{
		var item : ItemObject;
		var itemID : ItemID;
		var triggerModesArray : array< weak< TriggerMode_Record > >;
		var weaponRecordData : WeaponItem_Record;
		item = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		itemID = item.GetItemID();
		weaponRecordData = TDB.GetWeaponItemRecord( ItemID.GetTDBID( itemID ) );
		weaponRecordData.TriggerModes( triggerModesArray );
		return triggerModesArray.Size();
	}

	protected const function CompareTimeToPublicSafeTimestamp( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface, timeToCompare : Float ) : Bool
	{
		var exitTimeStamp : Float;
		exitTimeStamp = stateContext.GetFloatParameter( 'TurnOffPublicSafeTimeStamp', true );
		return ( EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) - exitTimeStamp ) > timeToCompare;
	}

	protected const function SwitchTriggerMode( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var evt : WeaponChangeTriggerModeEvent;
		var weapon : WeaponObject;
		var weaponRecord : WeaponItem_Record;
		evt = new WeaponChangeTriggerModeEvent;
		weapon = GetWeaponObject( scriptInterface );
		weaponRecord = weapon.GetWeaponRecord();
		if( IsPrimaryTriggerModeActive( scriptInterface ) )
		{
			evt.triggerMode = weaponRecord.SecondaryTriggerMode().Type();
		}
		else
		{
			evt.triggerMode = weaponRecord.PrimaryTriggerMode().Type();
		}
		weapon.QueueEvent( evt );
	}

	protected const function IsPrimaryTriggerModeActive( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		var weaponRecord : WeaponItem_Record;
		weapon = GetWeaponObject( scriptInterface );
		weaponRecord = weapon.GetWeaponRecord();
		if( weapon.GetCurrentTriggerMode() == weaponRecord.PrimaryTriggerMode() )
		{
			return true;
		}
		return false;
	}

	protected function UpdateInputBuffer( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( scriptInterface.IsActionJustPressed( 'Reload' ) )
		{
			stateContext.SetConditionFloatParameter( 'ReloadInputPressBuffer', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) + 0.2, true );
			stateContext.SetConditionBoolParameter( 'ReloadInputPressed', true, true );
		}
	}

	protected const function CanQuickMelee( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isCarrying : Bool;
		var statusEffectRecordData : weak< StatusEffectPlayerData_Record >;
		var quickMeleeAmmoCost : Uint16;
		var weapon : weak< WeaponObject >;
		if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoQuickMelee' ) )
		{
			return false;
		}
		statusEffectRecordData = GetStatusEffectRecordData( stateContext );
		if( !( ( statusEffectRecordData == NULL ) ) && ( statusEffectRecordData.ForceSafeWeapon() || statusEffectRecordData.JamWeapon() ) )
		{
			return false;
		}
		if( GetStaticBoolParameterDefault( "disable", false ) )
		{
			return false;
		}
		if( GameObject.IsCooldownActive( scriptInterface.owner, 'QuickMelee' ) )
		{
			return false;
		}
		if( ( stateContext.IsStateMachineActive( 'Consumable' ) || stateContext.IsStateMachineActive( 'CombatGadget' ) ) || IsInFocusMode( scriptInterface ) )
		{
			return false;
		}
		isCarrying = scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.Carrying );
		if( isCarrying )
		{
			return false;
		}
		if( IsInSafeSceneTier( scriptInterface ) )
		{
			return false;
		}
		quickMeleeAmmoCost = ( ( Uint16 )( scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.AmmoPerQuickMelee ) ) );
		if( quickMeleeAmmoCost > ( ( Uint16 )( 0 ) ) )
		{
			weapon = ( ( WeaponObject )( scriptInterface.owner ) );
			if( weapon && weapon.IsMagazineEmpty() )
			{
				return false;
			}
		}
		return true;
	}

	public static function GetPlayerSpeed( scriptInterface : StateGameScriptInterface ) : Float
	{
		var speed : Float;
		var velocity : Vector4;
		var player : PlayerPuppet;
		player = ( ( PlayerPuppet )( scriptInterface.executionOwner ) );
		velocity = player.GetVelocity();
		speed = Vector4.Length2D( velocity );
		return speed;
	}

	public static function ServerHasReloadRequest( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var paramRequest : parameterRequestReload;
		paramRequest = ( ( parameterRequestReload )( stateContext.GetTemporaryScriptableParameter( 'serverRequestReload' ) ) );
		if( paramRequest )
		{
			return paramRequest.item == scriptInterface.owner;
		}
		return false;
	}

	protected const function IsHeavyWeaponEmpty( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : weak< WeaponObject >;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		return weapon.IsHeavyWeapon() && weapon.IsMagazineEmpty();
	}

	protected const function GetMaxChargeThreshold( const scriptInterface : StateGameScriptInterface ) : Float
	{
		if( scriptInterface.HasStatFlag( gamedataStatType.CanOverchargeWeapon ) )
		{
			return WeaponObject.GetOverchargeThreshold();
		}
		if( scriptInterface.HasStatFlag( gamedataStatType.CanFullyChargeWeapon ) )
		{
			return WeaponObject.GetFullyChargedThreshold();
		}
		return WeaponObject.GetBaseMaxChargeThreshold();
	}

	protected const function IsReloadDurationComplete( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var owner : weak< GameObject >;
		var ownerID : EntityID;
		var statsSystem : StatsSystem;
		var statValue : Float;
		var logicalDuration : StateResultFloat;
		owner = scriptInterface.owner;
		ownerID = owner.GetEntityID();
		statsSystem = GameInstance.GetStatsSystem( owner.GetGame() );
		logicalDuration = stateContext.GetPermanentFloatParameter( 'ReloadLogicalDuration' );
		if( logicalDuration.valid )
		{
			statValue = logicalDuration.value;
			statValue += statsSystem.GetStatValue( ownerID, gamedataStatType.ReloadEndTime );
			if( GetInStateTime() > statValue )
			{
				return true;
			}
			return false;
		}
		return true;
	}

	protected const function IsReloadUninterruptible( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var uninterruptibleTimeStamp : Float;
		uninterruptibleTimeStamp = stateContext.GetFloatParameter( 'uninterruptibleReloadTimeStamp', true );
		return GetInStateTime() > uninterruptibleTimeStamp;
	}

	protected const function SetUninteruptibleReloadParams( stateContext : StateContext, clearParam : Bool )
	{
		if( clearParam )
		{
			stateContext.RemovePermanentBoolParameter( 'UninteruptibleReload' );
			return;
		}
		stateContext.SetPermanentBoolParameter( 'UninteruptibleReload', true, true );
	}

}

abstract class WeaponEventsTransition extends WeaponTransition
{

	public export virtual function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ActivateDamageProjection( false, GetWeaponObject( scriptInterface ), scriptInterface, stateContext );
		SetUninteruptibleReloadParams( stateContext, true );
		WeaponTransistionRemoveWeaponTriggerEffects( GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ) );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
	}

	protected function StartWeaponCharge( statPoolsSystem : StatPoolsSystem, weaponEntityID : EntityID )
	{
		var chargeMod : StatPoolModifier;
		statPoolsSystem.GetModifier( weaponEntityID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration, chargeMod );
		chargeMod.enabled = true;
		statPoolsSystem.RequestSettingModifier( weaponEntityID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration, chargeMod );
		statPoolsSystem.RequestResetingModifier( weaponEntityID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay );
	}

	protected function OnEnterNonChargeState( weapon : WeaponObject, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponID : EntityID;
		weapon.GetSharedData().SetVariant( GetAllBlackboardDefs().Weapon.ChargeStep, gamedataChargeStep.Idle );
		if( stateContext.GetBoolParameter( 'WeaponStopChargeRequested', true ) )
		{
			weaponID = weapon.GetEntityID();
			StopPool( scriptInterface.GetStatPoolsSystem(), weaponID, gamedataStatPoolType.WeaponCharge, true );
			stateContext.SetPermanentBoolParameter( 'WeaponStopChargeRequested', false, true );
		}
	}

	protected function SetTriggerEffectCycleTrigger( scriptInterface : StateGameScriptInterface )
	{
		var weapon : weak< WeaponObject >;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		RemoveTriggerEffectCycleTrigger( scriptInterface );
		if( scriptInterface.IsTriggerModeActive( gamedataTriggerMode.Charge ) )
		{
			GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_wea_trigger_charge', 'PSM_CycleTriggerOnExit_Charge' );
			WeaponObject.RegisterChargeStatListener( weapon, true );
		}
		else
		{
			GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_wea_trigger_trigger', 'PSM_CycleTriggerOnExit_fullAuto' );
		}
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( weapon.GetTriggerEffectName(), 'PSM_ReadyOnEnter_aim' );
	}

	protected function RemoveTriggerEffectCycleTrigger( scriptInterface : StateGameScriptInterface )
	{
		var weapon : weak< WeaponObject >;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		WeaponObject.RegisterChargeStatListener( weapon, false );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_Charge' );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_semiAuto' );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_fullAuto' );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_ReadyOnEnter_aim' );
	}

	protected function WeaponTransistionRemoveWeaponTriggerEffects( audioSystem : AudioSystem )
	{
		audioSystem.RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_Charge' );
		audioSystem.RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_semiAuto' );
		audioSystem.RemoveTriggerEffect( 'PSM_CycleTriggerOnExit_fullAuto' );
		audioSystem.RemoveTriggerEffect( 'PSM_ReadyOnEnter_aim' );
		audioSystem.RemoveTriggerEffect( 'PSM_SafeArea_FullForce' );
	}

}

class WeaponReadyListenerTransition extends WeaponTransition
{
	protected var m_executionOwner : weak< GameObject >;
	protected var m_callBackIDs : array< CallbackHandle >;
	protected var m_beingCreated : Bool;
	private var m_statListener : DefaultTransitionStatListener;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_isVaulting : Bool;
	private var m_isDodging : Bool;
	private var m_isInWorkspot : Bool;
	private var m_isSliding : Bool;
	private var m_isSceneAimForced : Bool;
	private var m_isInTakedown : Bool;
	private var m_isUsingCombatGadget : Bool;
	private var m_hasStatusEffectNoCombat : Bool;
	private var m_hasStatusEffectFastForward : Bool;
	private var m_hasStatusEffectVehicleScene : Bool;
	private var m_hasStunnedStatusEffect : Bool;
	private var m_hasJamStatusEffect : Bool;
	private var m_canWeaponShootWhileVaulting : Bool;
	private var m_canShootWhileDodging : Bool;
	private var m_canWeaponShootWhileSliding : Bool;
	private var m_isInSafeSceneTier : Bool;
	protected var m_weaponReadyListenerReturnValue : Bool;

	protected export virtual function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		allBlackboardDef = GetAllBlackboardDefs();
		m_beingCreated = true;
		m_executionOwner = scriptInterface.executionOwner;
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Locomotion, this, 'OnLocomotionChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Takedown, this, 'OnTakedownChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.CombatGadget, this, 'OnCombatGadgetChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.HighLevel, this, 'OnHighLevelChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerBool( allBlackboardDef.PlayerStateMachine.SceneAimForced, this, 'OnSceneAimForcedChanged', true ) );
		m_statListener = new DefaultTransitionStatListener;
		m_statListener.m_transitionOwner = this;
		scriptInterface.GetStatsSystem().RegisterListener( m_executionOwner.GetEntityID(), m_statListener );
		m_canWeaponShootWhileVaulting = scriptInterface.HasStatFlag( gamedataStatType.CanWeaponShootWhileVaulting );
		m_canShootWhileDodging = scriptInterface.HasStatFlag( gamedataStatType.CanShootWhileDodging );
		m_canWeaponShootWhileSliding = scriptInterface.HasStatFlag( gamedataStatType.CanWeaponShootWhileSliding );
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( m_executionOwner.GetEntityID(), m_statusEffectListener );
		UpdateHasNoCombatStatusEffect();
		UpdateHastFastForwardStatusEffect();
		UpdateHasVehicleSceneStatusEffect();
		UpdateHasStunnedStatusEffect();
		UpdateHasJamStatusEffect();
		m_beingCreated = false;
		UpdateWeaponReadyListenerReturnValue();
	}

	protected export virtual function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callBackIDs.Clear();
		m_statusEffectListener = NULL;
		scriptInterface.GetStatsSystem().UnregisterListener( m_executionOwner.GetEntityID(), m_statListener );
	}

	protected virtual function UpdateWeaponReadyListenerReturnValue()
	{
		if( m_beingCreated )
		{
			return;
		}
		m_weaponReadyListenerReturnValue = true;
		if( ( ( ( ( ( ( ( ( ( m_isVaulting && !( m_canWeaponShootWhileVaulting ) ) || ( m_isDodging && !( m_canShootWhileDodging ) ) ) || m_hasStatusEffectVehicleScene ) || ( m_hasStatusEffectNoCombat && !( m_hasStatusEffectFastForward ) ) ) || m_hasStunnedStatusEffect ) || m_isInTakedown ) || m_isUsingCombatGadget ) || m_hasJamStatusEffect ) || ( !( m_canWeaponShootWhileSliding ) && m_isSliding ) ) || ( m_isInSafeSceneTier && !( m_isSceneAimForced ) ) )
		{
			m_weaponReadyListenerReturnValue = false;
		}
	}

	public override function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, value : Float )
	{
		if( statType == gamedataStatType.CanWeaponShootWhileVaulting )
		{
			m_canWeaponShootWhileVaulting = value > 0.0;
		}
		else if( statType == gamedataStatType.CanShootWhileDodging )
		{
			m_canShootWhileDodging = value > 0.0;
		}
		else if( statType == gamedataStatType.CanWeaponShootWhileSliding )
		{
			m_canWeaponShootWhileSliding = value > 0.0;
		}
	}

	protected function UpdateHasNoCombatStatusEffect()
	{
		m_hasStatusEffectNoCombat = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'NoCombat' );
	}

	protected function UpdateHastFastForwardStatusEffect()
	{
		m_hasStatusEffectFastForward = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'FastForward' );
	}

	protected function UpdateHasVehicleSceneStatusEffect()
	{
		m_hasStatusEffectVehicleScene = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'VehicleScene' );
	}

	protected function UpdateHasStunnedStatusEffect()
	{
		m_hasStunnedStatusEffect = StatusEffectSystem.ObjectHasStatusEffectOfType( m_executionOwner, gamedataStatusEffectType.Stunned );
	}

	protected function UpdateHasJamStatusEffect()
	{
		m_hasJamStatusEffect = StatusEffectSystem.ObjectHasStatusEffectOfType( m_executionOwner, gamedataStatusEffectType.Jam );
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( !( m_hasStatusEffectNoCombat ) && statusEffect.GameplayTagsContains( 'NoCombat' ) )
		{
			m_hasStatusEffectNoCombat = true;
			UpdateWeaponReadyListenerReturnValue();
		}
		if( !( m_hasStatusEffectFastForward ) && statusEffect.GameplayTagsContains( 'FastForward' ) )
		{
			m_hasStatusEffectFastForward = true;
			UpdateWeaponReadyListenerReturnValue();
		}
		if( !( m_hasStatusEffectVehicleScene ) && statusEffect.GameplayTagsContains( 'VehicleScene' ) )
		{
			m_hasStatusEffectVehicleScene = true;
			UpdateWeaponReadyListenerReturnValue();
		}
		if( !( m_hasStunnedStatusEffect ) && gamedataStatusEffectType.Stunned == statusEffect.StatusEffectType().Type() )
		{
			m_hasStunnedStatusEffect = true;
			UpdateWeaponReadyListenerReturnValue();
		}
		if( !( m_hasJamStatusEffect ) && gamedataStatusEffectType.Jam == statusEffect.StatusEffectType().Type() )
		{
			m_hasJamStatusEffect = true;
			UpdateWeaponReadyListenerReturnValue();
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_hasStatusEffectNoCombat && statusEffect.GameplayTagsContains( 'NoCombat' ) )
		{
			UpdateHasNoCombatStatusEffect();
			UpdateWeaponReadyListenerReturnValue();
		}
		if( m_hasStatusEffectFastForward && statusEffect.GameplayTagsContains( 'FastForward' ) )
		{
			UpdateHastFastForwardStatusEffect();
			UpdateWeaponReadyListenerReturnValue();
		}
		if( m_hasStatusEffectVehicleScene && statusEffect.GameplayTagsContains( 'VehicleScene' ) )
		{
			UpdateHasVehicleSceneStatusEffect();
			UpdateWeaponReadyListenerReturnValue();
		}
		if( m_hasStunnedStatusEffect && gamedataStatusEffectType.Stunned == statusEffect.StatusEffectType().Type() )
		{
			UpdateHasStunnedStatusEffect();
			UpdateWeaponReadyListenerReturnValue();
		}
		if( m_hasJamStatusEffect && gamedataStatusEffectType.Jam == statusEffect.StatusEffectType().Type() )
		{
			UpdateHasJamStatusEffect();
			UpdateWeaponReadyListenerReturnValue();
		}
	}

	protected event OnSceneAimForcedChanged( value : Bool )
	{
		m_isSceneAimForced = value;
		UpdateWeaponReadyListenerReturnValue();
	}

	protected event OnLocomotionChanged( value : Int32 )
	{
		m_isVaulting = value == ( ( Int32 )( gamePSMLocomotionStates.Vault ) );
		m_isDodging = ( value == ( ( Int32 )( gamePSMLocomotionStates.Dodge ) ) ) || ( value == ( ( Int32 )( gamePSMLocomotionStates.DodgeAir ) ) );
		m_isInWorkspot = value == ( ( Int32 )( gamePSMLocomotionStates.Workspot ) );
		m_isSliding = ( value == ( ( Int32 )( gamePSMLocomotionStates.Slide ) ) ) || ( value == ( ( Int32 )( gamePSMLocomotionStates.SlideFall ) ) );
		UpdateWeaponReadyListenerReturnValue();
	}

	protected event OnTakedownChanged( value : Int32 )
	{
		m_isInTakedown = ( ( value == ( ( Int32 )( gamePSMTakedown.Grapple ) ) ) || ( value == ( ( Int32 )( gamePSMTakedown.Leap ) ) ) ) || ( value == ( ( Int32 )( gamePSMTakedown.Takedown ) ) );
		UpdateWeaponReadyListenerReturnValue();
	}

	protected event OnCombatGadgetChanged( value : Int32 )
	{
		m_isUsingCombatGadget = ( value > ( ( Int32 )( gamePSMCombatGadget.Default ) ) ) && ( value < ( ( Int32 )( gamePSMCombatGadget.WaitForUnequip ) ) );
		UpdateWeaponReadyListenerReturnValue();
	}

	protected event OnHighLevelChanged( value : Int32 )
	{
		m_isInSafeSceneTier = ( value > ( ( Int32 )( gamePSMHighLevel.SceneTier1 ) ) ) && ( value <= ( ( Int32 )( gamePSMHighLevel.SceneTier5 ) ) );
		UpdateWeaponReadyListenerReturnValue();
	}

	protected const function IsWeaponReadyToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( m_weaponReadyListenerReturnValue ) )
		{
			return false;
		}
		if( stateContext.IsStateMachineActive( 'Consumable' ) )
		{
			return false;
		}
		if( IsRightHandInUnequippingState( stateContext ) )
		{
			return false;
		}
		if( m_isInWorkspot )
		{
			if( !( stateContext.GetBoolParameter( 'isInVehCombat', true ) ) && !( stateContext.GetBoolParameter( 'isInDriverCombat', true ) ) )
			{
				return false;
			}
		}
		if( !( IsRightHandInEquippedState( stateContext ) ) )
		{
			return false;
		}
		if( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ).IsAimingAtFriendly() )
		{
			return ShouldIgnoreWeaponSafe( scriptInterface );
		}
		return true;
	}

}

class ReadyDecisions extends WeaponReadyListenerTransition
{

	protected override function UpdateWeaponReadyListenerReturnValue()
	{
		super.UpdateWeaponReadyListenerReturnValue();
		EnableOnEnterCondition( m_weaponReadyListenerReturnValue );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsWeaponReadyToShoot( stateContext, scriptInterface );
	}

}

class ReadyEvents extends WeaponEventsTransition
{
	var m_timeStamp : Float;

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : weak< WeaponObject >;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		OnEnterNonChargeState( weapon, stateContext, scriptInterface );
		EndShootingSequence( weapon, stateContext, scriptInterface );
		stateContext.SetConditionWeakScriptableParameter( 'Weapon', weapon, true );
		scriptInterface.TEMP_WeaponStopFiring();
		if( !( weapon.IsMagazineEmpty() ) )
		{
			SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		}
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Ready ) ) );
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', false, true );
		scriptInterface.SetAnimationParameterFloat( 'safe', 0.0 );
		m_timeStamp = EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_shootBumpCycle_off' );
		SetTriggerEffectCycleTrigger( scriptInterface );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		var attackID : TweakDBID;
		weaponObject = GetWeaponObject( scriptInterface );
		attackID = GetDesiredAttackRecord( stateContext, scriptInterface ).GetID();
		if( weaponObject.GetCurrentAttack().GetRecord().GetID() != attackID )
		{
			weaponObject.SetAttack( attackID );
		}
		ShowAttackPreview( true, weaponObject, scriptInterface, stateContext );
		HandleDamagePreview( weaponObject, scriptInterface, stateContext );
	}

	protected export function OnTick( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var behindCover : Bool;
		var animFeature : AnimFeature_WeaponHandlingStats;
		var gameInstance : GameInstance;
		var currentTime : Float;
		var statsSystem : StatsSystem;
		var ownerID : EntityID;
		gameInstance = scriptInterface.GetGame();
		currentTime = EngineTime.ToFloat( GameInstance.GetSimTime( gameInstance ) );
		behindCover = GameInstance.GetSpatialQueriesSystem( gameInstance ).GetPlayerObstacleSystem().GetCoverDirection( scriptInterface.executionOwner ) != gamePlayerCoverDirection.None;
		if( behindCover )
		{
			m_timeStamp = currentTime;
			stateContext.SetPermanentFloatParameter( 'TurnOffPublicSafeTimeStamp', m_timeStamp, true );
		}
		if( ( GetPlayerSpeed( scriptInterface ) < 0.1 ) && stateContext.IsStateActive( 'Locomotion', 'stand' ) )
		{
			if( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Combat ) != ( ( Int32 )( gamePSMCombat.InCombat ) ) ) && !( behindCover ) )
			{
				if( ( m_timeStamp + GetStaticFloatParameterDefault( "timeBetweenIdleBreaks", 20.0 ) ) <= currentTime )
				{
					scriptInterface.PushAnimationEvent( 'IdleBreak' );
					m_timeStamp = currentTime;
				}
			}
		}
		if( IsHeavyWeaponEmpty( scriptInterface ) && !( stateContext.GetBoolParameter( 'requestHeavyWeaponUnequip', true ) ) )
		{
			stateContext.SetPermanentBoolParameter( 'requestHeavyWeaponUnequip', true, true );
		}
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		ownerID = scriptInterface.ownerEntityID;
		animFeature = new AnimFeature_WeaponHandlingStats;
		animFeature.weaponRecoil = statsSystem.GetStatValue( ownerID, gamedataStatType.RecoilAnimation );
		animFeature.weaponSpread = statsSystem.GetStatValue( ownerID, gamedataStatType.SpreadAnimation );
		scriptInterface.SetAnimationParameterFeature( 'WeaponHandlingData', animFeature, scriptInterface.executionOwner );
	}

	private export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		ActivateDamageProjection( false, GetWeaponObject( scriptInterface ), scriptInterface, stateContext );
	}

}

class NotReadyDecisions extends WeaponReadyListenerTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( IsWeaponReadyToShoot( stateContext, scriptInterface ) );
	}

	protected const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsWeaponReadyToShoot( stateContext, scriptInterface );
	}

}

class NotReadyEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		OnEnterNonChargeState( weaponObject, stateContext, scriptInterface );
		EndShootingSequence( weaponObject, stateContext, scriptInterface );
		ShowAttackPreview( false, weaponObject, scriptInterface, stateContext );
		scriptInterface.TEMP_WeaponStopFiring();
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		ForceUnhideRegularHands( stateContext, scriptInterface );
		scriptInterface.GetStatPoolsSystem().RequestSettingStatPoolMinValue( scriptInterface.ownerEntityID, gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner );
		if( !( scriptInterface.GetQuestsSystem().GetFact( 'block_combat_scripts_tutorials' ) ) )
		{
			TutorialSetFact( scriptInterface, 'ranged_combat_tutorial' );
		}
	}

	protected function ForceUnhideRegularHands( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var animFeature : AnimFeature_MeleeData;
		animFeature = new AnimFeature_MeleeData;
		animFeature.shouldHandsDisappear = false;
		scriptInterface.SetAnimationParameterFeature( 'MeleeData', animFeature );
	}

}

class SafeDecisions extends WeaponTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ShouldEnterSafe( stateContext, scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToPublicSafe( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( EnterCondition( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

}

class SafeEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var broadcaster : StimBroadcasterComponent;
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		OnEnterNonChargeState( weaponObject, stateContext, scriptInterface );
		ShowAttackPreview( false, weaponObject, scriptInterface, stateContext );
		EndShootingSequence( weaponObject, stateContext, scriptInterface );
		scriptInterface.TEMP_WeaponStopFiring();
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', true, true );
		stateContext.SetTemporaryBoolParameter( ZoomTransitionHelper.GetReevaluateZoomName(), true, true );
		scriptInterface.SetAnimationParameterFloat( 'safe', 1.0 );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Safe ) ) );
		broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.WeaponSafe );
		}
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_wea_safe', 'PSM_SafeArea_FullForce' );
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetTemporaryBoolParameter( ZoomTransitionHelper.GetReevaluateZoomName(), true, true );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_SafeArea_FullForce' );
	}

}

class PublicSafeDecisions extends WeaponReadyListenerTransition
{
	private var m_isSprinting : Bool;
	private var m_inKereznikov : Bool;
	private var m_inCombat : Bool;
	private var m_inDangerousZone : Bool;
	private var m_inFocusMode : Bool;
	private var m_isInVehicleCombat : Bool;
	private var m_isInVehTurret : Bool;
	private var m_isAiming : Bool;
	private var m_rangedAttackPressed : Bool;

	protected export override function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		super.OnAttach( stateContext, scriptInterface );
		allBlackboardDef = GetAllBlackboardDefs();
		m_beingCreated = true;
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Locomotion, this, 'OnLocomotionChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Combat, this, 'OnCombatChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Zones, this, 'OnZonesChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vision, this, 'OnVisionChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vehicle, this, 'OnVehicleChanged', true ) );
		m_callBackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.UpperBody, this, 'OnUpperBodyChanged', true ) );
		scriptInterface.executionOwner.RegisterInputListener( this, 'RangedAttack' );
		m_rangedAttackPressed = scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0;
		m_beingCreated = false;
		UpdateShouldOnEnterBeEnabled();
	}

	protected export override function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		super.OnDetach( stateContext, scriptInterface );
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected function UpdateShouldOnEnterBeEnabled()
	{
		if( m_beingCreated )
		{
			return;
		}
		if( ( m_isSprinting || m_inCombat ) || m_inDangerousZone )
		{
			EnableOnEnterCondition( false );
			return;
		}
		if( m_inFocusMode && !( m_rangedAttackPressed ) )
		{
			EnableOnEnterCondition( true );
			return;
		}
		if( ( ( m_inKereznikov || m_isInVehicleCombat ) || m_isInVehTurret ) || m_isAiming )
		{
			EnableOnEnterCondition( false );
			return;
		}
		if( !( m_weaponReadyListenerReturnValue ) && !( ( m_inFocusMode && !( m_rangedAttackPressed ) ) ) )
		{
			EnableOnEnterCondition( false );
			return;
		}
		EnableOnEnterCondition( true );
	}

	protected override function UpdateWeaponReadyListenerReturnValue()
	{
		super.UpdateWeaponReadyListenerReturnValue();
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		m_rangedAttackPressed = ListenerAction.GetValue( action ) > 0.0;
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnLocomotionChanged( value : Int32 )
	{
		m_isSprinting = value == ( ( Int32 )( gamePSMLocomotionStates.Sprint ) );
		m_inKereznikov = value == ( ( Int32 )( gamePSMLocomotionStates.Kereznikov ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnCombatChanged( value : Int32 )
	{
		m_inCombat = value == ( ( Int32 )( gamePSMCombat.InCombat ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnZonesChanged( value : Int32 )
	{
		m_inDangerousZone = value == ( ( Int32 )( gamePSMZones.Dangerous ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnVisionChanged( value : Int32 )
	{
		m_inFocusMode = value == ( ( Int32 )( gamePSMVision.Focus ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnVehicleChanged( value : Int32 )
	{
		m_isInVehicleCombat = value == ( ( Int32 )( gamePSMVehicle.Combat ) );
		m_isInVehTurret = value == ( ( Int32 )( gamePSMVehicle.Turret ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected event OnUpperBodyChanged( value : Int32 )
	{
		m_isAiming = value == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) );
		UpdateShouldOnEnterBeEnabled();
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var equippingFromEmptyHandsWithAttack : StateResultBool;
		if( m_inFocusMode && !( m_rangedAttackPressed ) )
		{
			return true;
		}
		if( stateContext.GetBoolParameter( 'ForceReadyState', true ) )
		{
			return false;
		}
		if( IsSafeStateForced( stateContext, scriptInterface ) )
		{
			return false;
		}
		equippingFromEmptyHandsWithAttack = stateContext.GetPermanentBoolParameter( 'equippingRangedFromEmptyHandsAttack' );
		if( ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 ) && !( ( equippingFromEmptyHandsWithAttack.value && equippingFromEmptyHandsWithAttack.valid ) ) )
		{
			return false;
		}
		if( !( stateContext.GetBoolParameter( 'InPublicZone', true ) ) )
		{
			return false;
		}
		if( !( CompareTimeToPublicSafeTimestamp( stateContext, scriptInterface, GetStaticFloatParameterDefault( "idleTimeToEnter", 1.0 ) ) ) )
		{
			return false;
		}
		if( stateContext.IsStateMachineActive( 'CombatGadget' ) )
		{
			return false;
		}
		if( stateContext.IsStateMachineActive( 'CarriedObject' ) && scriptInterface.HasStatFlag( gamedataStatType.CanShootWhileCarryingBody ) )
		{
			return false;
		}
		if( scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection( scriptInterface.executionOwner ) != gamePlayerCoverDirection.None )
		{
			return false;
		}
		return IsWeaponReadyToShoot( stateContext, scriptInterface );
	}

	protected export const function ToNotReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsWeaponReadyToShoot( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToPublicSafeToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ShouldLeaveSafe( stateContext, scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToNoAmmo( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetWeaponObject( scriptInterface ).IsMagazineEmpty() && WeaponObject.CanReload( GetWeaponObject( scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

	private const function ShouldLeaveSafe( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isAiming : Bool;
		var isKereznikowActive : Bool;
		isAiming = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) );
		isKereznikowActive = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Locomotion ) == ( ( Int32 )( gamePSMLocomotionStates.Kereznikov ) );
		if( IsInFocusMode( scriptInterface ) && ( scriptInterface.IsActionJustPressed( 'RangedAttack' ) || ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 ) ) )
		{
			return true;
		}
		if( IsInFocusMode( scriptInterface ) )
		{
			return false;
		}
		if( stateContext.GetBoolParameter( 'ForceReadyState', true ) )
		{
			return true;
		}
		if( isKereznikowActive )
		{
			return true;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Combat ) == ( ( Int32 )( gamePSMCombat.InCombat ) ) )
		{
			return true;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Zones ) == ( ( Int32 )( gamePSMZones.Dangerous ) ) )
		{
			return true;
		}
		if( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 )
		{
			return true;
		}
		if( isAiming )
		{
			return true;
		}
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.CombatGadget ) >= ( ( Int32 )( gamePSMCombatGadget.Equipped ) ) )
		{
			return true;
		}
		if( scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection( scriptInterface.executionOwner ) != gamePlayerCoverDirection.None )
		{
			return true;
		}
		if( stateContext.IsStateMachineActive( 'CarriedObject' ) && scriptInterface.HasStatFlag( gamedataStatType.CanShootWhileCarryingBody ) )
		{
			return true;
		}
		return false;
	}

}

class PublicSafeEvents extends WeaponEventsTransition
{
	var m_weaponUnequipRequestSent : Bool;
	default m_weaponUnequipRequestSent = false;

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var broadcaster : StimBroadcasterComponent;
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		OnEnterNonChargeState( weaponObject, stateContext, scriptInterface );
		EndShootingSequence( weaponObject, stateContext, scriptInterface );
		ShowAttackPreview( false, weaponObject, scriptInterface, stateContext );
		scriptInterface.TEMP_WeaponStopFiring();
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', true, true );
		scriptInterface.SetAnimationParameterFloat( 'safe', 1.0 );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Safe ) ) );
		broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.WeaponSafe );
		}
		stateContext.SetPermanentBoolParameter( 'equippingRangedFromEmptyHandsAttack', false, true );
		m_weaponUnequipRequestSent = false;
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_wea_safe', 'PSM_SafeArea_FullForce' );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		RequestWeaponUnequipNotifyUpperBody( stateContext, scriptInterface );
	}

	private function RequestWeaponUnequipNotifyUpperBody( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( ( !( m_weaponUnequipRequestSent ) && ( GetStaticFloatParameterDefault( "timeToAutoUnequipWeapon", 0.0 ) > 0.0 ) ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "timeToAutoUnequipWeapon", 0.0 ) ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipWeapon );
			m_weaponUnequipRequestSent = true;
		}
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}

	protected export function OnExitToNotReady( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}
}

class PublicSafeToReadyDecisions extends WeaponTransition
{

	protected export const function ToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() > GetStaticFloatParameterDefault( "transitionDuration", 0.30000001 );
		if( stateContext.IsStateActive( 'UpperBody', 'aimingState' ) )
		{
			return true;
		}
		else
		{
		}
		return false;
	}

}

class PublicSafeToReadyEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.SetAnimationParameterFloat( 'safe', 0.0 );
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', false, true );
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		stateContext.SetPermanentFloatParameter( 'TurnOffPublicSafeTimeStamp', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ), true );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_SafeArea_FullForce' );
	}

}

class QuickMeleeDecisions extends WeaponTransition
{

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.RegisterInputListener( this, 'QuickMelee' );
		EnableOnEnterCondition( false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		EnableOnEnterCondition( ListenerAction.IsButtonJustReleased( action ) );
	}

	protected const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		EnableOnEnterCondition( false );
		if( scriptInterface.IsActionJustTapped( 'QuickMelee' ) )
		{
			return CanQuickMelee( stateContext, scriptInterface );
		}
		return false;
	}

	protected const function ToStandardExit( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( GetInStateTime() >= GetStaticFloatParameterDefault( "duration", 1.0 ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToSemiAuto( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ToSemiAutoTransitionCondition( stateContext, scriptInterface );
	}

	protected const function ToFullAuto( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ToFullAutoTransitionCondition( stateContext, scriptInterface );
	}

	protected const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsPassedCancelWindow( stateContext, scriptInterface );
	}

	protected const function IsPassedCancelWindow( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var cancelWindow : StateResultFloat;
		cancelWindow = stateContext.GetPermanentFloatParameter( 'QuickMeleeCancelWindow' );
		if( cancelWindow.valid && ( EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) >= cancelWindow.value ) )
		{
			return true;
		}
		return false;
	}

}

class QuickMeleeEvents extends WeaponEventsTransition
{
	var m_gameEffect : EffectInstance;
	var m_targetObject : weak< GameObject >;
	var m_targetComponent : IPlacedComponent;
	var m_quickMeleeAttackCreated : Bool;
	default m_quickMeleeAttackCreated = false;
	var m_quickMeleeAttackData : QuickMeleeAttackData;

	protected function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var broadcaster : StimBroadcasterComponent;
		var quickMeleeAmmoCost : Uint16;
		var consumeEvent : WeaponConsumeMagazineAmmoEvent;
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		m_quickMeleeAttackCreated = false;
		scriptInterface.TEMP_WeaponStopFiring();
		broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.MeleeAttack );
		}
		stateContext.SetPermanentBoolParameter( 'VisionToggled', false, true );
		ForceDisableVisionMode( stateContext );
		stateContext.SetTemporaryBoolParameter( 'InterruptSprint', true, true );
		stateContext.SetPermanentFloatParameter( 'TurnOffPublicSafeTimeStamp', scriptInterface.GetNow(), true );
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', false, true );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.QuickMelee ) ) );
		SendAnimFeature( stateContext, scriptInterface, 1 );
		scriptInterface.PushAnimationEvent( 'QuickMelee' );
		PlayRumble( scriptInterface, GetStaticStringParameterDefault( "rumbleOnEnter", "light_fast" ) );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).SetTriggerEffectModeTimed( 'te_wea_quickmelee', 0.60000002 );
		weapon.SetAttack( GetQuickMeleeAttackTweakID( scriptInterface ) );
		GetAttackParameters( scriptInterface );
		if( m_quickMeleeAttackData.forcePlayerToStand )
		{
			stateContext.SetConditionBoolParameter( 'CrouchToggled', false, true );
		}
		ConsumeStamina( scriptInterface );
		quickMeleeAmmoCost = ( ( Uint16 )( scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.AmmoPerQuickMelee ) ) );
		if( quickMeleeAmmoCost > ( ( Uint16 )( 0 ) ) )
		{
			consumeEvent = new WeaponConsumeMagazineAmmoEvent;
			consumeEvent.amount = quickMeleeAmmoCost;
			weapon.QueueEvent( consumeEvent );
		}
		AdjustPlayerPosition( stateContext, scriptInterface, GetQuickMeleeTarget( scriptInterface, m_quickMeleeAttackData.adjustmentRange ), m_quickMeleeAttackData.adjustmentDuration, m_quickMeleeAttackData.adjustmentRadius, m_quickMeleeAttackData.adjustmentCurve );
		stateContext.SetPermanentFloatParameter( 'QuickMeleeCancelWindow', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) + m_quickMeleeAttackData.duration, true );
	}

	protected function ConsumeStamina( scriptInterface : StateGameScriptInterface )
	{
		var staminaCost : Float;
		var attackRecord : weak< Attack_Melee_Record >;
		var staminaCostMods : array< weak< StatModifier_Record > >;
		attackRecord = ( ( Attack_Melee_Record )( TDB.GetAttack_GameEffectRecord( GetQuickMeleeAttackTweakID( scriptInterface ) ) ) );
		attackRecord.StaminaCost( staminaCostMods );
		staminaCost = RPGManager.CalculateStatModifiers( staminaCostMods, scriptInterface.GetGame(), scriptInterface.owner, scriptInterface.ownerEntityID );
		if( staminaCost > 0.0 )
		{
			PlayerStaminaHelpers.ModifyStamina( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ), -( staminaCost ) );
		}
	}

	protected function InitiateQuickMeleeAttack( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var startPosition : Vector4;
		var endPosition : Vector4;
		var colliderBox : Vector4;
		var attackTime : Float;
		var dir : Vector4;
		startPosition.X = 0.0;
		startPosition.Y = 0.0;
		startPosition.Z = 0.0;
		endPosition.X = 0.0;
		endPosition.Y = m_quickMeleeAttackData.attackRange;
		endPosition.Z = 0.0;
		dir = endPosition - startPosition;
		colliderBox.X = 0.30000001;
		colliderBox.Y = 0.30000001;
		colliderBox.Z = 0.30000001;
		attackTime = m_quickMeleeAttackData.attackGameEffectDuration;
		if( dir.Y != 0.0 )
		{
			endPosition.Y = m_quickMeleeAttackData.attackRange;
		}
		SpawnQuickMeleeGameEffect( stateContext, scriptInterface, startPosition, endPosition, attackTime, colliderBox );
	}

	protected function GetQuickMeleeTarget( scriptInterface : StateGameScriptInterface, optional withinDistance : Float ) : GameObject
	{
		var targetingSystem : TargetingSystem;
		var angleOut : EulerAngles;
		targetingSystem = scriptInterface.GetTargetingSystem();
		m_targetComponent = targetingSystem.GetComponentClosestToCrosshair( scriptInterface.executionOwner, angleOut, TSQ_NPC() );
		m_targetObject = scriptInterface.GetObjectFromComponent( m_targetComponent );
		if( ( ( m_targetObject.IsPuppet() && ScriptedPuppet.IsAlive( m_targetObject ) ) && !( ScriptedPuppet.IsDefeated( m_targetObject ) ) ) && ( GameObject.GetAttitudeTowards( m_targetObject, scriptInterface.executionOwner ) == EAIAttitude.AIA_Neutral || GameObject.GetAttitudeTowards( m_targetObject, scriptInterface.executionOwner ) == EAIAttitude.AIA_Hostile ) )
		{
			if( ( withinDistance <= 0.0 ) || ( Vector4.Distance( scriptInterface.executionOwner.GetWorldPosition(), m_targetObject.GetWorldPosition() ) <= withinDistance ) )
			{
				return m_targetObject;
			}
		}
		return NULL;
	}

	protected function SpawnQuickMeleeGameEffect( stateContext : StateContext, scriptInterface : StateGameScriptInterface, startPosition : Vector4, endPosition : Vector4, attackTime : Float, colliderBox : Vector4 )
	{
		var effect : EffectInstance;
		var attackStartPositionWorld : Vector4;
		var attackEndPositionWorld : Vector4;
		var attackDirectionWorld : Vector4;
		var cameraWorldTransform : Transform;
		var weapon : WeaponObject;
		var attack : Attack_GameEffect;
		var initContext : AttackInitContext;
		cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
		attackStartPositionWorld = Transform.TransformPoint( cameraWorldTransform, startPosition );
		attackStartPositionWorld.W = 0.0;
		attackEndPositionWorld = Transform.TransformPoint( cameraWorldTransform, endPosition );
		attackEndPositionWorld.W = 0.0;
		attackDirectionWorld = attackEndPositionWorld - attackStartPositionWorld;
		weapon = GetWeaponObject( scriptInterface );
		PlaySound( 'Quickmelee_guns', scriptInterface );
		initContext.record = TDB.GetAttack_GameEffectRecord( GetQuickMeleeAttackTweakID( scriptInterface ) );
		initContext.source = scriptInterface.executionOwner;
		initContext.instigator = scriptInterface.executionOwner;
		initContext.weapon = weapon;
		attack = ( ( Attack_GameEffect )( IAttack.Create( initContext ) ) );
		effect = attack.PrepareAttack( scriptInterface.executionOwner );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, colliderBox );
		EffectData.SetFloat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, attackTime );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, attackStartPositionWorld );
		EffectData.SetQuat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation( cameraWorldTransform ) );
		EffectData.SetVector( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize( attackDirectionWorld ) );
		EffectData.SetFloat( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length( attackDirectionWorld ) );
		EffectData.SetVariant( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.fxPackage, weapon.GetFxPackageQuickMelee() );
		EffectData.SetBool( effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.playerOwnedWeapon, true );
		m_gameEffect = effect;
		attack.StartAttack();
		PlayEffect( TDB.GetCName( GetQuickMeleeAttackTweakID( scriptInterface ) + T".vfxName" ), scriptInterface );
	}

	protected function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		UpdateInputBuffer( stateContext, scriptInterface );
		if( !( m_quickMeleeAttackCreated ) && ( GetInStateTime() >= GetStaticFloatParameterDefault( "attackGameEffectDelay", 0.0 ) ) )
		{
			InitiateQuickMeleeAttack( stateContext, scriptInterface );
			m_quickMeleeAttackCreated = true;
		}
		if( m_quickMeleeAttackCreated )
		{
			UpdateGameEffectPosition( stateContext, scriptInterface );
		}
	}

	protected function UpdateGameEffectPosition( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var startPosition : Vector4;
		var endPosition : Vector4;
		var cameraWorldTransform : Transform;
		startPosition.X = 0.0;
		startPosition.Y = 0.0;
		startPosition.Z = 0.0;
		endPosition.X = 0.0;
		endPosition.Y = m_quickMeleeAttackData.attackRange;
		endPosition.Z = 0.0;
		cameraWorldTransform = scriptInterface.GetCameraWorldTransform();
		startPosition = startPosition;
		endPosition = endPosition;
		startPosition = startPosition;
		EffectData.SetVector( m_gameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, Transform.TransformPoint( cameraWorldTransform, startPosition ) );
	}

	protected function GetAttackParameters( scriptInterface : StateGameScriptInterface )
	{
		var recordID : TweakDBID;
		recordID = GetQuickMeleeAttackTweakID( scriptInterface );
		m_quickMeleeAttackData.attackGameEffectDelay = TDB.GetFloat( recordID + T".attackGameEffectDelay" );
		m_quickMeleeAttackData.attackGameEffectDuration = TDB.GetFloat( recordID + T".attackGameEffectDuration" );
		m_quickMeleeAttackData.attackRange = TDB.GetFloat( recordID + T".attackRange" );
		m_quickMeleeAttackData.forcePlayerToStand = TDB.GetBool( recordID + T".forcePlayerToStand" );
		m_quickMeleeAttackData.shouldAdjust = TDB.GetBool( recordID + T".shouldAdjust" );
		m_quickMeleeAttackData.adjustmentRange = TDB.GetFloat( recordID + T".adjustmentRange" );
		m_quickMeleeAttackData.adjustmentDuration = TDB.GetFloat( recordID + T".adjustmentDuration" );
		m_quickMeleeAttackData.adjustmentRadius = TDB.GetFloat( recordID + T".adjustmentRadius" );
		m_quickMeleeAttackData.adjustmentCurve = TDB.GetCName( recordID + T".adjustmentCurve" );
		m_quickMeleeAttackData.cooldown = TDB.GetFloat( recordID + T".cooldown" );
		m_quickMeleeAttackData.duration = TDB.GetFloat( recordID + T".duration" );
	}

	protected function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var attackID : TweakDBID;
		SendAnimFeature( stateContext, scriptInterface, 0 );
		attackID = GetDesiredAttackRecord( stateContext, scriptInterface ).GetID();
		GetWeaponObject( scriptInterface ).SetAttack( attackID );
		GameObject.StartCooldown( scriptInterface.owner, 'QuickMelee', m_quickMeleeAttackData.cooldown );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var attackID : TweakDBID;
		SendAnimFeature( stateContext, scriptInterface, 0 );
		attackID = GetDesiredAttackRecord( stateContext, scriptInterface ).GetID();
		GetWeaponObject( scriptInterface ).SetAttack( attackID );
		GameObject.StartCooldown( scriptInterface.owner, 'QuickMelee', m_quickMeleeAttackData.cooldown );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
	}

	protected function SendAnimFeature( stateContext : StateContext, scriptInterface : StateGameScriptInterface, state : Int32 )
	{
		var animFeature : AnimFeature_QuickMelee;
		animFeature = new AnimFeature_QuickMelee;
		animFeature.state = state;
		scriptInterface.SetAnimationParameterFeature( 'QuickMelee', animFeature );
	}

	protected function GetQuickMeleeAttackTweakID( scriptInterface : StateGameScriptInterface ) : TweakDBID
	{
		var attacks : array< IAttack >;
		var i : Int32;
		var record : Attack_Record;
		var attackName : String;
		attacks = GetWeaponObject( scriptInterface ).GetAttacks();
		for( i = 0; i < attacks.Size(); i += 1 )
		{
			record = attacks[ i ].GetRecord();
			attackName = record.AttackType().Name();
			if( attackName == "QuickMelee" )
			{
				return record.GetID();
			}
		}
		return TDBID.None();
	}

}

class NoAmmoDecisions extends WeaponTransition
{
	private var m_callbackID : CallbackHandle;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		var bb : IBlackboard;
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		bb = weapon.GetSharedData();
		if( bb && weapon )
		{
			allBlackboardDef = GetAllBlackboardDefs();
			m_callbackID = bb.RegisterListenerUint( allBlackboardDef.Weapon.MagazineAmmoCount, this, 'OnAmmoCountChanged' );
			OnAmmoCountChanged( bb.GetUint( allBlackboardDef.Weapon.MagazineAmmoCount ) );
		}
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callbackID = NULL;
	}

	protected event OnAmmoCountChanged( value : Uint32 )
	{
		EnableOnEnterCondition( value == ( ( Uint32 )( 0 ) ) );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isSwitchingItems : Bool;
		isSwitchingItems = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.SwitchItems ) );
		return !( isSwitchingItems );
	}

	protected export const function ToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( GetWeaponObject( scriptInterface ).IsMagazineEmpty() );
	}

	protected const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustTapped( 'QuickMelee' ) && CanQuickMelee( stateContext, scriptInterface ) )
		{
			return true;
		}
		if( !( GetWeaponObject( scriptInterface ).IsMagazineEmpty() ) || !( WeaponObject.CanReload( GetWeaponObject( scriptInterface ) ) ) )
		{
			return false;
		}
		return true;
	}

	protected export const function ToReload( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		if( !( WeaponObject.CanReload( weaponObject ) ) )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSprinting ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Locomotion ) == ( ( Int32 )( gamePSMLocomotionStates.Sprint ) ) ) )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileVaulting ) ) && stateContext.IsStateActive( 'Locomotion', 'vault' ) )
		{
			return false;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSliding ) ) && stateContext.IsStateActive( 'Locomotion', 'slide' ) )
		{
			return false;
		}
		if( scriptInterface.IsActionJustPressed( 'RangedAttack' ) )
		{
			return true;
		}
		if( weaponObject.GetWeaponRecord().ItemType().Type() == gamedataItemType.Wea_SniperRifle )
		{
			return !( stateContext.IsStateActive( 'UpperBody', 'aimingState' ) );
		}
		return GetInStateTime() > GetStaticFloatParameterDefault( "timeToAutoReload", 0.30000001 );
	}

	protected const function ToPublicSafe( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( WeaponObject.CanReload( GetWeaponObject( scriptInterface ) ) );
	}

}

class NoAmmoEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponRecord : WeaponItem_Record;
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		weaponRecord = weaponObject.GetWeaponRecord();
		scriptInterface.TEMP_WeaponStopFiring();
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.NoAmmo ) ) );
		scriptInterface.SetAnimationParameterFloat( 'empty_clip', 1.0 );
		OnEnterNonChargeState( weaponObject, stateContext, scriptInterface );
		ShowAttackPreview( false, weaponObject, scriptInterface, stateContext );
		scriptInterface.GetStatPoolsSystem().RequestSettingStatPoolMinValue( weaponObject.GetEntityID(), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner );
		if( ( weaponObject.GetItemData().HasTag( 'DiscardOnEmpty' ) || weaponRecord.EquipArea().Type() == gamedataEquipmentArea.WeaponHeavy ) && !( stateContext.IsStateActive( 'UpperBody', 'temporaryUnequip' ) ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem, gameEquipAnimationType.Default );
		}
		WeaponObject.TriggerWeaponEffects( ( ( WeaponObject )( scriptInterface.owner ) ), gamedataFxAction.EnterNoAmmo );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var dryFireEvent : AudioEvent;
		if( scriptInterface.IsActionJustPressed( 'RangedAttack' ) )
		{
			dryFireEvent = new AudioEvent;
			dryFireEvent.eventName = 'dry_fire';
			GetWeaponObject( scriptInterface ).QueueEvent( dryFireEvent );
		}
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		WeaponObject.TriggerWeaponEffects( ( ( WeaponObject )( scriptInterface.owner ) ), gamedataFxAction.ExitNoAmmo );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
	}

}

class ReloadDecisions extends WeaponTransition
{

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.RegisterInputListener( this, 'Reload' );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		EnableOnEnterCondition( true );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var inputBuffered : Bool;
		inputBuffered = stateContext.GetConditionBool( 'ReloadInputPressed' ) && ( stateContext.GetConditionFloat( 'ReloadInputPressBuffer' ) > EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ) );
		if( scriptInterface.IsActionJustTapped( 'Reload' ) || inputBuffered )
		{
			if( WeaponObject.CanReload( ( ( WeaponObject )( scriptInterface.owner ) ) ) )
			{
				if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vision ) != ( ( Int32 )( gamePSMVision.Default ) ) )
				{
					return false;
				}
				if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.CombatGadget ) == ( ( Int32 )( gamePSMCombatGadget.Charging ) ) )
				{
					return false;
				}
				if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced ) )
				{
					return false;
				}
				if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSliding ) ) && IsInSlidingState( stateContext ) )
				{
					return false;
				}
				if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileVaulting ) ) && stateContext.IsStateActive( 'Locomotion', 'vault' ) )
				{
					return false;
				}
				if( stateContext.IsStateMachineActive( 'Consumable' ) )
				{
					return false;
				}
				return true;
			}
		}
		else
		{
			EnableOnEnterCondition( false );
		}
		return false;
	}

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( IsReloadDurationComplete( stateContext, scriptInterface ) )
		{
			if( stateContext.GetBoolParameter( 'FinishedReload' ) )
			{
				return true;
			}
		}
		if( stateContext.IsStateMachineActive( 'Consumable' ) || stateContext.IsStateMachineActive( 'CombatGadget' ) )
		{
			return true;
		}
		if( stateContext.GetBoolParameter( 'TryInterruptReload' ) && !( IsReloadUninterruptible( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		if( scriptInterface.IsActionJustPressed( 'RangedAttack' ) && ( ( ( Int32 )( scriptInterface.GetStatsSystem().GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.ReloadAmount ) ) ) > 0 ) )
		{
			if( !( GetWeaponObject( scriptInterface ).IsMagazineEmpty() ) && !( IsReloadUninterruptible( stateContext, scriptInterface ) ) )
			{
				return true;
			}
		}
		if( scriptInterface.IsActionJustPressed( 'QuickMelee' ) && CanQuickMelee( stateContext, scriptInterface ) )
		{
			return true;
		}
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileVaulting ) ) && stateContext.IsStateActive( 'Locomotion', 'vault' ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToReload( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsReloadDurationComplete( stateContext, scriptInterface ) ) )
		{
			return false;
		}
		if( scriptInterface.GetActionValue( 'AttackB' ) > 0.0 )
		{
			return false;
		}
		return WeaponObject.CanReload( GetWeaponObject( scriptInterface ) );
	}

	protected export const function ToSemiAuto( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ToSemiAutoTransitionCondition( stateContext, scriptInterface );
	}

	protected export const function ToFullAuto( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ToFullAutoTransitionCondition( stateContext, scriptInterface );
	}

}

class ReloadEvents extends WeaponEventsTransition
{
	var m_statListener : DefaultTransitionStatListener;
	var m_randomSync : AnimFeature_SelectRandomAnimSync;
	var m_animReloadData : AnimFeature_WeaponReload;
	var m_animReloadSpeed : AnimFeature_WeaponReloadSpeedData;
	var m_weaponRecord : WeaponItem_Record;
	var m_animReloadDataDirty : Bool;
	var m_animReloadSpeedDirty : Bool;
	var m_uninteruptibleSet : Bool;
	var m_weaponHasAutoLoader : Bool;
	var m_canReloadWhileSprinting : Bool;
	var m_lastReloadWasEmpty : Bool;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var statsSystem : StatsSystem;
		var weapon : WeaponObject;
		statsSystem = scriptInterface.GetStatsSystem();
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		m_weaponRecord = weapon.GetWeaponRecord();
		m_statListener = new DefaultTransitionStatListener;
		m_statListener.m_transitionOwner = this;
		statsSystem.RegisterListener( scriptInterface.ownerEntityID, m_statListener );
		statsSystem.RegisterListener( scriptInterface.executionOwner.GetEntityID(), m_statListener );
		m_canReloadWhileSprinting = scriptInterface.HasStatFlag( gamedataStatType.CanWeaponReloadWhileSprinting );
		m_weaponHasAutoLoader = scriptInterface.HasStatFlagOwner( gamedataStatType.WeaponHasAutoloader, scriptInterface.owner );
		m_animReloadData = new AnimFeature_WeaponReload;
		m_animReloadSpeed = new AnimFeature_WeaponReloadSpeedData;
		m_animReloadData.amountToReload = ( ( Int32 )( statsSystem.GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.ReloadAmount ) ) );
		m_animReloadData.loopDuration = statsSystem.GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.ReloadTime );
		m_animReloadData.emptyDuration = statsSystem.GetStatValue( scriptInterface.ownerEntityID, gamedataStatType.EmptyReloadTime );
		m_animReloadSpeed.reloadSpeed = GetReloadAnimSpeed( gamedataStatType.ReloadTime, m_weaponRecord );
		m_animReloadSpeed.emptyReloadSpeed = GetReloadAnimSpeed( gamedataStatType.EmptyReloadTime, m_weaponRecord );
		m_animReloadDataDirty = true;
		m_animReloadSpeedDirty = true;
	}

	protected export virtual function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.GetStatsSystem().UnregisterListener( scriptInterface.ownerEntityID, m_statListener );
		scriptInterface.GetStatsSystem().UnregisterListener( scriptInterface.executionOwner.GetEntityID(), m_statListener );
	}

	public override function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, value : Float )
	{
		if( statType == gamedataStatType.WeaponHasAutoloader )
		{
			m_weaponHasAutoLoader = value > 0.0;
		}
		else if( statType == gamedataStatType.ReloadAmount )
		{
			m_animReloadData.amountToReload = ( ( Int32 )( value ) );
			m_animReloadDataDirty = true;
		}
		else if( statType == gamedataStatType.ReloadTime )
		{
			m_animReloadData.loopDuration = value;
			m_animReloadSpeed.reloadSpeed = GetReloadAnimSpeed( gamedataStatType.ReloadTime, m_weaponRecord );
			m_animReloadDataDirty = true;
			m_animReloadSpeedDirty = true;
		}
		else if( statType == gamedataStatType.EmptyReloadTime )
		{
			m_animReloadData.emptyDuration = value;
			m_animReloadSpeed.emptyReloadSpeed = GetReloadAnimSpeed( gamedataStatType.EmptyReloadTime, m_weaponRecord );
			m_animReloadDataDirty = true;
			m_animReloadSpeedDirty = true;
		}
		else if( statType == gamedataStatType.CanWeaponReloadWhileSprinting )
		{
			m_canReloadWhileSprinting = value > 0.0;
		}
	}

	protected const function GetReloadAnimSpeed( const statType : gamedataStatType, weaponRecord : WeaponItem_Record ) : Float
	{
		var baseVal : Float;
		var statVal : Float;
		if( statType == gamedataStatType.ReloadTime )
		{
			baseVal = weaponRecord.BaseReloadTime();
			statVal = m_animReloadData.loopDuration;
		}
		else if( statType == gamedataStatType.EmptyReloadTime )
		{
			baseVal = weaponRecord.BaseEmptyReloadTime();
			statVal = m_animReloadData.emptyDuration;
		}
		if( ( baseVal > 0.0 ) && ( statVal > 0.0 ) )
		{
			return baseVal / statVal;
		}
		return 1.0;
	}

	protected function ActivateReloadAnimData( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( !( m_animReloadData.continueLoop ) )
		{
			scriptInterface.PushAnimationEvent( 'Reload' );
		}
		else
		{
			scriptInterface.PushAnimationEvent( 'ReloadLoop' );
		}
		scriptInterface.SetAnimationParameterBool( 'is_reload_active', true );
		if( m_animReloadDataDirty )
		{
			scriptInterface.SetAnimationParameterFeature( 'ReloadData', m_animReloadData );
			m_animReloadDataDirty = false;
		}
		if( m_animReloadSpeedDirty )
		{
			scriptInterface.SetAnimationParameterFeature( 'ReloadSpeed', m_animReloadSpeed );
			m_animReloadSpeedDirty = false;
		}
	}

	protected function DeactivateReloadAnimData( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.SetAnimationParameterBool( 'is_reload_active', false );
	}

	protected function RefreshReloadPermanentFloats( stateContext : StateContext )
	{
		if( m_animReloadDataDirty )
		{
			if( m_animReloadData.emptyReload )
			{
				stateContext.SetPermanentFloatParameter( 'uninterruptibleReloadTimeStamp', m_weaponRecord.UninterruptibleEmptyReloadStart() / m_animReloadSpeed.emptyReloadSpeed, true );
				stateContext.SetPermanentFloatParameter( 'ReloadLogicalDuration', m_animReloadData.emptyDuration, true );
			}
			else
			{
				stateContext.SetPermanentFloatParameter( 'uninterruptibleReloadTimeStamp', m_weaponRecord.UninterruptibleReloadStart() / m_animReloadSpeed.reloadSpeed, true );
				stateContext.SetPermanentFloatParameter( 'ReloadLogicalDuration', m_animReloadData.loopDuration, true );
			}
		}
	}

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		m_animReloadData.emptyReload = !( m_weaponHasAutoLoader ) && weapon.IsMagazineEmpty();
		if( m_lastReloadWasEmpty != m_animReloadData.emptyReload )
		{
			m_lastReloadWasEmpty = m_animReloadData.emptyReload;
			m_animReloadDataDirty = true;
		}
		ShowAttackPreview( false, weapon, scriptInterface, stateContext );
		m_uninteruptibleSet = false;
		SetUninteruptibleReloadParams( stateContext, true );
		if( m_animReloadData.emptyReload )
		{
			weapon.StartReload( m_animReloadData.emptyDuration );
		}
		else
		{
			weapon.StartReload( m_animReloadData.loopDuration );
		}
		RefreshReloadPermanentFloats( stateContext );
		OnEnterNonChargeState( weapon, stateContext, scriptInterface );
		EndShootingSequence( weapon, stateContext, scriptInterface );
		scriptInterface.TEMP_WeaponStopFiring();
		stateContext.SetConditionBoolParameter( 'ReloadInputPressed', false, true );
		stateContext.SetTemporaryBoolParameter( 'InterruptAiming', true, true );
		if( !( m_canReloadWhileSprinting ) )
		{
			stateContext.SetTemporaryBoolParameter( 'InterruptSprint', true, true );
		}
		if( !( m_randomSync ) )
		{
			m_randomSync = new AnimFeature_SelectRandomAnimSync;
			m_randomSync.value = -1;
		}
		m_randomSync.value = RandDifferent( m_randomSync.value, 3 );
		if( m_randomSync )
		{
			scriptInterface.SetAnimationParameterFeature( 'RandomSync', m_randomSync );
		}
		ActivateReloadAnimData( stateContext, scriptInterface );
		WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.EnterReload );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) ) );
		WeaponTransistionRemoveWeaponTriggerEffects( GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ) );
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_off', 'PSM_ReloadOnEnter_OFF' );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var logicalDuration : StateResultFloat;
		if( !( stateContext.GetBoolParameter( 'FinishedReload' ) ) )
		{
			logicalDuration = stateContext.GetPermanentFloatParameter( 'ReloadLogicalDuration' );
			if( logicalDuration.valid )
			{
				if( GetInStateTime() > logicalDuration.value )
				{
					GetWeaponObject( scriptInterface ).StopReload( gameweaponReloadStatus.Standard );
					stateContext.SetTemporaryBoolParameter( 'FinishedReload', true, true );
				}
			}
		}
		if( IsReloadUninterruptible( stateContext, scriptInterface ) && !( m_uninteruptibleSet ) )
		{
			SetUninteruptibleReloadParams( stateContext, false );
			m_uninteruptibleSet = true;
		}
	}

	protected virtual function OnExitToReload( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( !( m_animReloadData.continueLoop ) )
		{
			m_animReloadData.continueLoop = true;
			m_animReloadDataDirty = true;
		}
	}

	private function OnExitCleanup( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		stateContext.SetPermanentFloatParameter( 'LastReloadTime', EngineTime.ToFloat( GameInstance.GetSimTime( scriptInterface.GetGame() ) ), true );
		scriptInterface.SetAnimationParameterFloat( 'empty_clip', 0.0 );
		scriptInterface.PushAnimationEvent( 'EndReload' );
		if( m_animReloadData.continueLoop )
		{
			m_animReloadData.continueLoop = false;
			m_animReloadDataDirty = true;
		}
		DeactivateReloadAnimData( stateContext, scriptInterface );
		WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.ExitReload );
		WeaponObject.SendAmmoUpdateEvent( scriptInterface.executionOwner, weapon );
		SetUninteruptibleReloadParams( stateContext, true );
		m_uninteruptibleSet = false;
		if( !( stateContext.GetBoolParameter( 'FinishedReload' ) ) )
		{
			scriptInterface.PushAnimationEvent( 'InterruptReload' );
			weapon.StopReload( gameweaponReloadStatus.Interrupted );
		}
		GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).RemoveTriggerEffect( 'PSM_ReloadOnEnter_OFF' );
	}

	protected export virtual function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		OnExitCleanup( stateContext, scriptInterface );
	}

	protected export override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		OnExitCleanup( stateContext, scriptInterface );
		super.OnForcedExit( stateContext, scriptInterface );
	}

}

class ShootDecisions extends WeaponTransition
{
	const var stateBodyDone : Bool;

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

}

class ShootEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		var attackID : TweakDBID;
		var gameInstance : GameInstance;
		var statsSystem : StatsSystem;
		var currentTime : Float;
		var broadcaster : StimBroadcasterComponent;
		gameInstance = scriptInterface.GetGame();
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		currentTime = EngineTime.ToFloat( GameInstance.GetSimTime( gameInstance ) );
		weapon = GetWeaponObject( scriptInterface );
		ForceDisableVisionMode( stateContext );
		ShowAttackPreview( true, weapon, scriptInterface, stateContext );
		if( !( scriptInterface.HasStatFlag( gamedataStatType.CanWeaponShootWhileSprinting ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Locomotion ) == ( ( Int32 )( gamePSMLocomotionStates.Sprint ) ) ) )
		{
			stateContext.SetTemporaryBoolParameter( 'InterruptSprint', true, true );
		}
		stateContext.SetPermanentFloatParameter( 'LastShotTime', currentTime, true );
		attackID = GetDesiredAttackRecord( stateContext, scriptInterface ).GetID();
		weapon.SetAttack( attackID );
		weapon.QueueEvent( new WeaponPreFireEvent );
		stateContext.SetPermanentIntParameter( 'LastChargePressCount', ( ( Int32 )( scriptInterface.GetActionPressCount( 'RangedAttack' ) ) ), true );
		stateContext.SetPermanentFloatParameter( 'TurnOffPublicSafeTimeStamp', currentTime, true );
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', false, true );
		scriptInterface.PushAnimationEvent( 'Shoot' );
		stateContext.SetPermanentFloatParameter( 'StoppedFiringTimestamp', currentTime, true );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Shoot ) ) );
		broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
		if( statsSystem.GetStatValue( weapon.GetEntityID(), gamedataStatType.CanSilentKill ) > 0.0 )
		{
			if( broadcaster )
			{
				broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.IllegalAction );
				broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.SilencedGunshot );
				broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.SilencedGunshot, 8.0, , true );
				if( WeaponObject.GetWeaponType( weapon.GetItemID() ) == gamedataItemType.Wea_SniperRifle )
				{
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.Gunshot, 8.0 );
				}
			}
			WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.SilencedShoot );
			WeaponObject.SendAmmoUpdateEvent( scriptInterface.executionOwner, weapon );
		}
		else
		{
			if( statsSystem.GetStatValue( weapon.GetEntityID(), gamedataStatType.HasMuzzleBrake ) > 0.0 )
			{
				WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.MuzzleBrakeShoot );
				WeaponObject.SendAmmoUpdateEvent( scriptInterface.executionOwner, weapon );
			}
			else
			{
				WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.Shoot );
				WeaponObject.SendAmmoUpdateEvent( scriptInterface.executionOwner, weapon );
			}
			if( broadcaster )
			{
				if( IsEntityInInteriorArea( GetPlayer( gameInstance ) ) )
				{
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.Gunshot, 25.0 );
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.Gunshot, 45.0, , true );
				}
				else
				{
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.Gunshot, GetPlayer( gameInstance ).GetGunshotRange() );
					broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.Gunshot, 50.0, , true );
				}
			}
			PlayerCoverHelper.BlockCoverVisibilityReduction( scriptInterface.executionOwner );
		}
		SendDataTrackingRequest( scriptInterface, ETelemetryData.RangedAttacksMade, 1 );
		ChangeStatPoolValue( scriptInterface, scriptInterface.ownerEntityID, gamedataStatPoolType.WeaponOverheat, GetStaticFloatParameterDefault( "overheatValAdd", 10.0 ) );
		ShootingSequencePostShoot( stateContext );
		GameInstance.GetTelemetrySystem( scriptInterface.owner.GetGame() ).LogWeaponAttackPerformed( weapon );
		if( scriptInterface.IsTriggerModeActive( gamedataTriggerMode.FullAuto ) || scriptInterface.IsTriggerModeActive( gamedataTriggerMode.Burst ) )
		{
			GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).SetTriggerEffectModeTimed( 'te_wea_shoot_bump_auto', 0.2 );
		}
		else
		{
			GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).AddTriggerEffect( 'te_off', 'PSM_shootBumpCycle_off' );
			GameInstance.GetAudioSystem( scriptInterface.owner.GetGame() ).SetTriggerEffectModeTimed( 'te_wea_shoot_bump_single', 0.2 );
		}
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		var statPoolsSystem : StatPoolsSystem;
		var statsSystem : StatsSystem;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		statsSystem = scriptInterface.GetStatsSystem();
		weaponObject = GetWeaponObject( scriptInterface );
		if( statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.FullAutoOnFullCharge ) == 0.0 )
		{
			statPoolsSystem.RequestSettingStatPoolMinValue( weaponObject.GetEntityID(), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner );
		}
	}

}

class CycleRoundDecisions extends WeaponTransition
{

	protected constexpr export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		weaponObject = GetWeaponObject( scriptInterface );
		if( weaponObject.IsMagazineEmpty() )
		{
			return true;
		}
		else
		{
			return CanPerformNextShotInSequence( weaponObject, stateContext, scriptInterface );
		}
	}

	protected export const function ToFullAuto( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return ToFullAutoTransitionCondition( stateContext, scriptInterface );
	}

}

class CycleRoundEvents extends WeaponEventsTransition
{
	var m_hasBlockedAiming : Bool;
	var m_blockAimStart : Float;
	var m_blockAimDuration : Float;

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		m_hasBlockedAiming = false;
		m_blockAimStart = scriptInterface.GetStatsSystem().GetStatValue( weapon.GetEntityID(), gamedataStatType.CycleTimeAimBlockStart );
		m_blockAimDuration = scriptInterface.GetStatsSystem().GetStatValue( weapon.GetEntityID(), gamedataStatType.CycleTimeAimBlockDuration );
		if( ( m_blockAimDuration > 0.0 ) && ( m_blockAimStart > 0.0 ) )
		{
			if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.UpperBody ) == ( ( Int32 )( gamePSMUpperBodyStates.Aim ) ) )
			{
				HoldAimingForTime( stateContext, scriptInterface, m_blockAimStart );
			}
		}
		if( GetWeaponObject( scriptInterface ).GetItemData().HasTag( 'AnimCycleRound' ) )
		{
			scriptInterface.PushAnimationEvent( 'CycleRound' );
		}
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Shoot ) ) );
	}

	protected export function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( m_hasBlockedAiming )
		{
			ResetSoftBlockAiming( stateContext, scriptInterface );
		}
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		ShowAttackPreview( true, weapon, scriptInterface, stateContext );
		if( m_blockAimDuration > 0.0 )
		{
			if( !( m_hasBlockedAiming ) && ( m_blockAimStart < GetInStateTime() ) )
			{
				BlockAimingForTime( stateContext, scriptInterface, m_blockAimDuration );
				m_hasBlockedAiming = true;
			}
		}
		ShootingSequenceUpdateCycleTime( timeDelta, stateContext );
		UpdateInputBuffer( stateContext, scriptInterface );
		if( scriptInterface.IsTriggerModeActive( gamedataTriggerMode.FullAuto ) )
		{
			if( ( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 ) || GetWeaponObject( scriptInterface ).IsMagazineEmpty() )
			{
				scriptInterface.TEMP_WeaponStopFiring();
			}
		}
	}

}

class CycleTriggerModeDecisions extends WeaponTransition
{

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		EnableOnEnterCondition( weapon.HasSecondaryTriggerMode() );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( stateContext.IsStateActive( 'UpperBody', 'aimingState' ) && IsPrimaryTriggerModeActive( scriptInterface ) )
		{
			return true;
		}
		else if( !( stateContext.IsStateActive( 'UpperBody', 'aimingState' ) ) && !( IsPrimaryTriggerModeActive( scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() > stateContext.GetConditionFloat( 'CycleTriggerModeStatCycleTime' );
	}

	protected const function ToCharge( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		if( !( scriptInterface.IsTriggerModeActive( gamedataTriggerMode.Charge ) ) )
		{
			return false;
		}
		if( GetInStateTime() < stateContext.GetConditionFloat( 'CycleTriggerModeStatCycleTime' ) )
		{
			return false;
		}
		weapon = GetWeaponObject( scriptInterface );
		return ( !( weapon.IsMagazineEmpty() ) && scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin( weapon.GetEntityID(), gamedataStatPoolType.WeaponCharge ) ) && ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 );
	}

}

class CycleTriggerModeEvents extends WeaponEventsTransition
{

	protected function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var animFeature : AnimFeature_TriggerModeChange;
		var ownerID : StatsObjectID;
		var statCycleTime : Float;
		ownerID = scriptInterface.ownerEntityID;
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.ToggleFireMode ) )
		{
			SetBlackboardBoolVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.ToggleFireMode, false );
		}
		SwitchTriggerMode( stateContext, scriptInterface );
		statCycleTime = scriptInterface.GetStatsSystem().GetStatValue( ownerID, gamedataStatType.CycleTriggerModeTime );
		stateContext.SetConditionFloatParameter( 'CycleTriggerModeStatCycleTime', statCycleTime, true );
		animFeature = new AnimFeature_TriggerModeChange;
		animFeature.cycleTime = statCycleTime;
		scriptInterface.SetAnimationParameterFeature( 'TriggerModeChange', animFeature );
		scriptInterface.PushAnimationEvent( 'SwitchFiremode' );
	}

	protected function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}

	protected function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		UpdateInputBuffer( stateContext, scriptInterface );
	}

}

class SemiAutoDecisions extends WeaponTransition
{
	var m_callBackID : CallbackHandle;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.RegisterInputListener( this, 'RangedAttack' );
		OnRangeAttackInput( scriptInterface.GetActionValue( 'RangedAttack' ) );
		m_callBackID = scriptInterface.localBlackboard.RegisterListenerBool( GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this, 'OnQuestForcedShoot', false );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
		scriptInterface.localBlackboard.UnregisterListenerBool( GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, m_callBackID );
	}

	protected function OnQuestForcedShoot( value : Bool )
	{
		EnableOnEnterCondition( value );
	}

	protected function OnRangeAttackInput( value : Float )
	{
		EnableOnEnterCondition( value > 0.0 );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		OnRangeAttackInput( ListenerAction.GetValue( action ) );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		var questForceShoot : StateResultBool;
		var validTransition : Bool;
		weaponObject = GetWeaponObject( scriptInterface );
		validTransition = false;
		if( CanPerformNextSemiAutoShot( weaponObject, stateContext, scriptInterface ) )
		{
			validTransition = IsSemiAutoAction( weaponObject, stateContext, scriptInterface );
			if( !( validTransition ) )
			{
				questForceShoot = stateContext.GetTemporaryBoolParameter( GetQuestForceShootName() );
				validTransition = questForceShoot.value;
			}
		}
		return validTransition;
	}

	protected export const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isFireDelay : Bool;
		var timeRemaining : Float;
		isFireDelay = stateContext.GetBoolParameter( GetIsDelayFireName(), true );
		timeRemaining = stateContext.GetFloatParameter( GetCycleTimeRemainingName(), true );
		return !( isFireDelay ) || ( timeRemaining <= 0.0 );
	}

}

class SemiAutoEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Shoot ) ) );
		SetupStandardShootingSequence( stateContext, scriptInterface );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ShootingSequenceUpdateCycleTime( timeDelta, stateContext );
	}

}

class FullAutoDecisions extends WeaponTransition
{
	var m_callBackID : CallbackHandle;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callBackID = scriptInterface.localBlackboard.RegisterListenerBool( GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, this, 'OnQuestForcedShoot', false );
		scriptInterface.executionOwner.RegisterInputListener( this, 'RangedAttack' );
		OnRangeAttackInput( scriptInterface.GetActionValue( 'RangedAttack' ) );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
		scriptInterface.localBlackboard.UnregisterListenerBool( GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, m_callBackID );
	}

	protected function OnQuestForcedShoot( value : Bool )
	{
		EnableOnEnterCondition( value );
	}

	protected function OnRangeAttackInput( value : Float )
	{
		EnableOnEnterCondition( value > 0.0 );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		OnRangeAttackInput( ListenerAction.GetValue( action ) );
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weaponObject : WeaponObject;
		var questForceShoot : StateResultBool;
		var validTransition : Bool;
		weaponObject = GetWeaponObject( scriptInterface );
		validTransition = false;
		if( CanPerformNextFullAutoShot( weaponObject, stateContext, scriptInterface ) )
		{
			validTransition = IsFullAutoAction( weaponObject, stateContext, scriptInterface );
			if( !( validTransition ) )
			{
				questForceShoot = stateContext.GetTemporaryBoolParameter( GetQuestForceShootName() );
				validTransition = questForceShoot.value;
			}
		}
		return validTransition;
	}

	protected export const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		var isFireDelay : Bool;
		var timeRemaining : Float;
		var validAmmo : Bool;
		weapon = GetWeaponObject( scriptInterface );
		isFireDelay = stateContext.GetBoolParameter( GetIsDelayFireName(), true );
		timeRemaining = stateContext.GetFloatParameter( GetCycleTimeRemainingName(), true );
		validAmmo = !( weapon.IsMagazineEmpty() );
		return validAmmo && ( !( isFireDelay ) || ( timeRemaining <= 0.0 ) );
	}

	protected export const function ToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isFireDelay : Bool;
		var timeRemaining : Float;
		isFireDelay = stateContext.GetBoolParameter( GetIsDelayFireName(), true );
		timeRemaining = stateContext.GetFloatParameter( GetCycleTimeRemainingName(), true );
		return ( !( isFireDelay ) || ( timeRemaining <= 0.0 ) ) && ( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 );
	}

}

class FullAutoEvents extends WeaponEventsTransition
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		var cycleTimeForShootingPhase : Float;
		var statsSystem : StatsSystem;
		statsSystem = scriptInterface.GetStatsSystem();
		weaponObject = GetWeaponObject( scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Shoot ) ) );
		if( !( InShootingSequence( stateContext ) ) )
		{
			SetupStandardShootingSequence( stateContext, scriptInterface );
		}
		else
		{
			cycleTimeForShootingPhase = CalculateCycleTime( stateContext, scriptInterface );
			SetupNextShootingPhase( stateContext, cycleTimeForShootingPhase, statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTime_Burst ), ( ( Int32 )( statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.NumShotsInBurst ) ) ) );
		}
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		ShootingSequenceUpdateCycleTime( timeDelta, stateContext );
		ShowAttackPreview( true, weapon, scriptInterface, stateContext );
	}

	private function CalculateCycleTime( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Float
	{
		var lerp : Float;
		var statMultiplier : Float;
		var statPeriod : Float;
		var finalMultiplier : Float;
		var cycleTimeStart : Float;
		var gameInstance : GameInstance;
		var currentTime : Float;
		var statsSystem : StatsSystem;
		var weaponObject : WeaponObject;
		var shootingSequenceStartTime : Float;
		finalMultiplier = 1.0;
		gameInstance = scriptInterface.GetGame();
		currentTime = EngineTime.ToFloat( GameInstance.GetSimTime( gameInstance ) );
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		weaponObject = GetWeaponObject( scriptInterface );
		shootingSequenceStartTime = stateContext.GetFloatParameter( GetShootingStartName(), true );
		cycleTimeStart = statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTime );
		statMultiplier = statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTimeShootingMult );
		statPeriod = statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTimeShootingMultPeriod );
		if( statMultiplier != 0.0 )
		{
			if( statPeriod > 0.0 )
			{
				lerp = LerpF( ( currentTime - shootingSequenceStartTime ) / statPeriod, 0.0, 1.0, true );
			}
			else
			{
				lerp = 1.0;
			}
			finalMultiplier = 1.0 + ( lerp * statMultiplier );
		}
		return cycleTimeStart * finalMultiplier;
	}

}

class BurstDecisions extends WeaponTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isBursting : Bool;
		var burstShotRemaining : Int32;
		burstShotRemaining = stateContext.GetIntParameter( GetBurstShotsRemainingName(), true );
		isBursting = burstShotRemaining >= 1;
		return isBursting && !( GetWeaponObject( scriptInterface ).IsMagazineEmpty() );
	}

	protected export const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var validTime : Bool;
		var validAmmo : Bool;
		var timeRemaining : Float;
		timeRemaining = stateContext.GetFloatParameter( GetBurstTimeRemainingName(), true );
		validTime = timeRemaining <= 0.0;
		validAmmo = !( GetWeaponObject( scriptInterface ).IsMagazineEmpty() );
		return validTime && validAmmo;
	}

}

class BurstEvents extends WeaponEventsTransition
{

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		weapon = GetWeaponObject( scriptInterface );
		ShootingSequenceUpdateBurstTime( timeDelta, stateContext );
		ShowAttackPreview( true, weapon, scriptInterface, stateContext );
	}

}

abstract class ChargeEventsAbstract extends WeaponEventsTransition
{
	protected var m_layerId : Uint32;

	protected function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		stateContext.SetPermanentBoolParameter( 'WeaponStopChargeRequested', true, true );
		StopEffect( 'charging', scriptInterface );
		StopEffect( 'charged', scriptInterface );
		ClearDebugText( m_layerId, scriptInterface );
	}

	public override function OnForcedExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		stateContext.SetPermanentBoolParameter( 'WeaponStopChargeRequested', true, true );
		StopEffect( 'charging', scriptInterface );
		StopEffect( 'charged', scriptInterface );
		ClearDebugText( m_layerId, scriptInterface );
	}

	protected virtual function OnExitToShoot( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		OnExit( stateContext, scriptInterface );
	}

	protected export virtual function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ShowAttackPreview( true, GetWeaponObject( scriptInterface ), scriptInterface, stateContext );
	}

	protected function SetupFullChargedShootingSequence( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weaponObject : WeaponObject;
		var statsSystem : StatsSystem;
		weaponObject = GetWeaponObject( scriptInterface );
		statsSystem = scriptInterface.GetStatsSystem();
		StartShootingSequence( stateContext, scriptInterface, 0.0, statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.CycleTime_BurstMaxCharge ), ( ( Int32 )( statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.NumShotsInBurstMaxCharge ) ) ), ( ( Bool )( statsSystem.GetStatValue( weaponObject.GetEntityID(), gamedataStatType.FullAutoOnFullCharge ) ) ) );
	}

}

class ChargeDecisions extends WeaponTransition
{
	private var m_callbackID : CallbackHandle;
	private var m_triggerModeCorrect : Bool;
	private var m_inputPressed : Bool;

	protected function UpdateOnEnterConditionEnabled()
	{
		EnableOnEnterCondition( m_triggerModeCorrect && m_inputPressed );
	}

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var bb : IBlackboard;
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		bb = weapon.GetSharedData();
		if( bb && weapon )
		{
			m_callbackID = bb.RegisterListenerVariant( GetAllBlackboardDefs().Weapon.TriggerMode, this, 'OnTriggerModeChanged' );
			UpdateTriggerMode( weapon.GetCurrentTriggerMode().Type() );
		}
		scriptInterface.executionOwner.RegisterInputListener( this, 'RangedAttack' );
		UpdateRangedAttackInput( scriptInterface.GetActionValue( 'RangedAttack' ) );
		UpdateOnEnterConditionEnabled();
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		var bb : IBlackboard;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		bb = weapon.GetSharedData();
		scriptInterface.executionOwner.UnregisterInputListener( this );
		if( weapon && bb )
		{
			bb.UnregisterListenerVariant( GetAllBlackboardDefs().Weapon.TriggerMode, m_callbackID );
		}
		m_callbackID = NULL;
	}

	protected function UpdateRangedAttackInput( value : Float )
	{
		m_inputPressed = value >= 0.5;
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		UpdateRangedAttackInput( ListenerAction.GetValue( action ) );
		UpdateOnEnterConditionEnabled();
	}

	protected function UpdateTriggerMode( modeType : gamedataTriggerMode )
	{
		m_triggerModeCorrect = modeType == gamedataTriggerMode.Charge;
	}

	protected event OnTriggerModeChanged( value : Variant )
	{
		var record : TriggerMode_Record;
		record = ( ( TriggerMode_Record )value );
		UpdateTriggerMode( record.Type() );
		UpdateOnEnterConditionEnabled();
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		var actionPressCount : Uint32;
		var lastChargePressCount : StateResultInt;
		actionPressCount = scriptInterface.GetActionPressCount( 'RangedAttack' );
		lastChargePressCount = stateContext.GetPermanentIntParameter( 'LastChargePressCount' );
		if( lastChargePressCount.valid && ( lastChargePressCount.value == ( ( Int32 )( actionPressCount ) ) ) )
		{
			EnableOnEnterCondition( false );
			return false;
		}
		weapon = GetWeaponObject( scriptInterface );
		return !( weapon.IsMagazineEmpty() ) && scriptInterface.GetStatPoolsSystem().HasStatPoolValueReachedMin( weapon.GetEntityID(), gamedataStatPoolType.WeaponCharge );
	}

	protected export const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var chargeParameter : Float;
		var readyPercentageParameter : Float;
		var fireWhenReadyParameter : Bool;
		var gameInstance : GameInstance;
		var statsSystem : StatsSystem;
		var weapon : WeaponObject;
		var weaponID : EntityID;
		weapon = GetWeaponObject( scriptInterface );
		weaponID = weapon.GetEntityID();
		gameInstance = scriptInterface.GetGame();
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		weaponID = weapon.GetEntityID();
		chargeParameter = WeaponObject.GetWeaponChargeNormalized( weapon );
		readyPercentageParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeReadyPercentage );
		fireWhenReadyParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeShouldFireWhenReady ) > 0.0;
		if( ( fireWhenReadyParameter && ( chargeParameter >= readyPercentageParameter ) ) || ( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToChargeReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var chargeParameter : Float;
		var readyPercentageParameter : Float;
		var fireWhenReadyParameter : Bool;
		var gameInstance : GameInstance;
		var statsSystem : StatsSystem;
		var weapon : WeaponObject;
		var weaponID : EntityID;
		weapon = GetWeaponObject( scriptInterface );
		weaponID = weapon.GetEntityID();
		gameInstance = scriptInterface.GetGame();
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		chargeParameter = WeaponObject.GetWeaponChargeNormalized( weapon );
		readyPercentageParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeReadyPercentage );
		fireWhenReadyParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeShouldFireWhenReady ) > 0.0;
		if( ( !( fireWhenReadyParameter ) && ( chargeParameter >= readyPercentageParameter ) ) && ( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.0 ) )
		{
			return true;
		}
		return false;
	}

}

class ChargeEvents extends ChargeEventsAbstract
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var actionPressCount : Uint32;
		var weapon : WeaponObject;
		var weaponID : EntityID;
		var maxCharge : Float;
		weapon = GetWeaponObject( scriptInterface );
		weaponID = weapon.GetEntityID();
		maxCharge = GetMaxChargeThreshold( scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Charging ) ) );
		actionPressCount = scriptInterface.GetActionPressCount( 'RangedAttack' );
		stateContext.SetPermanentIntParameter( 'LastChargePressCount', ( ( Int32 )( actionPressCount ) ), true );
		PlayEffect( 'charging', scriptInterface );
		weapon.SetMaxChargeThreshold( maxCharge );
		StartPool( scriptInterface.GetStatPoolsSystem(), weaponID, gamedataStatPoolType.WeaponCharge, maxCharge, GetChargeValuePerSec( scriptInterface ) );
		WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.EnterCharge );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Charging ) ) );
		GetWeaponObject( scriptInterface ).GetSharedData().SetVariant( GetAllBlackboardDefs().Weapon.ChargeStep, gamedataChargeStep.Charging );
	}

	protected export virtual function OnExitToChargeReady( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ClearDebugText( m_layerId, scriptInterface );
	}

	protected function GetChargeValuePerSec( scriptInterface : StateGameScriptInterface ) : Float
	{
		var weapon : WeaponObject;
		var chargeDuration : Float;
		var statsSystem : StatsSystem;
		statsSystem = scriptInterface.GetStatsSystem();
		if( !( statsSystem ) )
		{
			return -1.0;
		}
		weapon = GetWeaponObject( scriptInterface );
		if( !( weapon ) )
		{
			return -1.0;
		}
		chargeDuration = statsSystem.GetStatValue( weapon.GetEntityID(), gamedataStatType.ChargeTime );
		if( chargeDuration <= 0.0 )
		{
			return -1.0;
		}
		return 100.0 / chargeDuration;
	}

	protected export override function OnExitToShoot( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetupStandardShootingSequence( stateContext, scriptInterface );
		super.OnExitToShoot( stateContext, scriptInterface );
	}

}

class ChargeReadyDecisions extends WeaponTransition
{

	protected export const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0;
	}

	protected export const function ToChargeMax( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var statPoolsSystem : StatPoolsSystem;
		var weaponID : EntityID;
		var statPoolPerc : Float;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		weaponID = GetWeaponObject( scriptInterface ).GetEntityID();
		statPoolPerc = statPoolsSystem.GetStatPoolValue( weaponID, gamedataStatPoolType.WeaponCharge );
		if( statPoolPerc >= GetMaxChargeThreshold( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

}

class ChargeReadyEvents extends ChargeEventsAbstract
{

	protected export function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Charging ) ) );
		GetWeaponObject( scriptInterface ).GetSharedData().SetVariant( GetAllBlackboardDefs().Weapon.ChargeStep, gamedataChargeStep.Charged );
	}

	protected export override function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ShowAttackPreview( true, GetWeaponObject( scriptInterface ), scriptInterface, stateContext );
	}

	protected export override function OnExitToShoot( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetupStandardShootingSequence( stateContext, scriptInterface );
		super.OnExitToShoot( stateContext, scriptInterface );
	}

	protected virtual function OnExitToChargeMax( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		StopEffect( 'charging', scriptInterface );
		ClearDebugText( m_layerId, scriptInterface );
	}

}

class ChargeMaxDecisions extends WeaponTransition
{

	protected const function ToShoot( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var timeInStateMaxParameter : Float;
		var timeInState : Float;
		var statsSystem : StatsSystem;
		var weaponID : EntityID;
		statsSystem = scriptInterface.GetStatsSystem();
		weaponID = GetWeaponObject( scriptInterface ).GetEntityID();
		if( scriptInterface.HasStatFlag( gamedataStatType.CanControlFullyChargedWeapon ) && ( statsSystem.GetStatValue( weaponID, gamedataStatType.FullAutoOnFullCharge ) == 0.0 ) )
		{
			if( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 )
			{
				return true;
			}
			return false;
		}
		timeInStateMaxParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeMaxTimeInChargedState );
		timeInState = GetInStateTime();
		if( ( timeInState >= timeInStateMaxParameter ) || ( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 ) )
		{
			return true;
		}
		return false;
	}

}

class ChargeMaxEvents extends ChargeEventsAbstract
{

	protected function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Charging ) ) );
		PlayEffect( 'charged', scriptInterface );
		GetWeaponObject( scriptInterface ).GetSharedData().SetVariant( GetAllBlackboardDefs().Weapon.ChargeStep, gamedataChargeStep.Overcharging );
	}

	protected override function OnExitToShoot( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		PlayEffect( 'discharge', scriptInterface );
		SetupFullChargedShootingSequence( stateContext, scriptInterface );
		super.OnExitToShoot( stateContext, scriptInterface );
	}

}

class DischargeDecisions extends WeaponTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var chargeParameter : Float;
		var readyPercentageParameter : Float;
		var gameInstance : GameInstance;
		var statPoolsSystem : StatPoolsSystem;
		var statsSystem : StatsSystem;
		var weaponID : EntityID;
		gameInstance = scriptInterface.GetGame();
		statPoolsSystem = GameInstance.GetStatPoolsSystem( gameInstance );
		statsSystem = GameInstance.GetStatsSystem( gameInstance );
		weaponID = GetWeaponObject( scriptInterface ).GetEntityID();
		chargeParameter = statPoolsSystem.GetStatPoolValue( weaponID, gamedataStatPoolType.WeaponCharge );
		readyPercentageParameter = statsSystem.GetStatValue( weaponID, gamedataStatType.ChargeReadyPercentage );
		if( ( chargeParameter < readyPercentageParameter ) && ( scriptInterface.GetActionValue( 'RangedAttack' ) <= 0.0 ) )
		{
			return true;
		}
		return false;
	}

	protected const function ToReady( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var statPoolsSystem : StatPoolsSystem;
		var weaponID : EntityID;
		statPoolsSystem = scriptInterface.GetStatPoolsSystem();
		weaponID = GetWeaponObject( scriptInterface ).GetEntityID();
		return statPoolsSystem.HasStatPoolValueReachedMin( weaponID, gamedataStatPoolType.WeaponCharge );
	}

}

class DischargeEvents extends WeaponEventsTransition
{
	var layerId : Uint32;
	private var m_statPoolsSystem : StatPoolsSystem;
	private var m_statsSystem : StatsSystem;
	private var m_weaponID : EntityID;

	protected function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var gameInstance : GameInstance;
		var chargeMod : StatPoolModifier;
		var weapon : WeaponObject;
		gameInstance = scriptInterface.GetGame();
		weapon = GetWeaponObject( scriptInterface );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Charging ) ) );
		ShowDebugText( "<<<DISCHARGING>>>", scriptInterface, layerId );
		m_statPoolsSystem = GameInstance.GetStatPoolsSystem( gameInstance );
		m_statsSystem = GameInstance.GetStatsSystem( gameInstance );
		m_weaponID = weapon.GetEntityID();
		StopEffect( 'charging', scriptInterface );
		StopEffect( 'charged', scriptInterface );
		m_statPoolsSystem.GetModifier( m_weaponID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay, chargeMod );
		chargeMod.enabled = true;
		m_statPoolsSystem.RequestResetingModifier( m_weaponID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Regeneration );
		m_statPoolsSystem.RequestSettingModifier( m_weaponID, gamedataStatPoolType.WeaponCharge, gameStatPoolModificationTypes.Decay, chargeMod );
		WeaponObject.TriggerWeaponEffects( weapon, gamedataFxAction.EnterDischarge );
		weapon.GetSharedData().SetVariant( GetAllBlackboardDefs().Weapon.ChargeStep, gamedataChargeStep.Discharging );
	}

	protected function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface ) {}

	protected virtual function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		ClearDebugText( layerId, scriptInterface );
		WeaponObject.TriggerWeaponEffects( GetWeaponObject( scriptInterface ), gamedataFxAction.ExitDischarge );
	}

}

class OverheatDecisions extends WeaponTransition
{
	private var m_callbackID : CallbackHandle;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		var bb : IBlackboard;
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.owner ) );
		bb = weapon.GetSharedData();
		if( bb && weapon )
		{
			allBlackboardDef = GetAllBlackboardDefs();
			m_callbackID = bb.RegisterListenerBool( allBlackboardDef.Weapon.IsInForcedOverheatCooldown, this, 'OnForcedOverheatCooldownChanged' );
			EnableOnEnterCondition( bb.GetBool( allBlackboardDef.Weapon.IsInForcedOverheatCooldown ) );
		}
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		m_callbackID = NULL;
	}

	protected event OnForcedOverheatCooldownChanged( value : Bool )
	{
		EnableOnEnterCondition( value );
	}

	protected constexpr const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return true;
	}

	protected const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var isOverheated : Bool;
		isOverheated = GetWeaponObject( scriptInterface ).GetSharedData().GetBool( GetAllBlackboardDefs().Weapon.IsInForcedOverheatCooldown );
		if( !( isOverheated ) )
		{
			return GetInStateTime() > GetStaticFloatParameterDefault( "overheatDuration", 5.0 );
		}
		else
		{
			return false;
		}
	}

}

class OverheatEvents extends WeaponEventsTransition
{

	protected function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.TEMP_WeaponStopFiring();
		stateContext.SetTemporaryBoolParameter( 'InterruptAiming', true, true );
		scriptInterface.PushAnimationEvent( 'Overheat' );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Overheat ) ) );
		WeaponObject.TriggerWeaponEffects( GetWeaponObject( scriptInterface ), gamedataFxAction.ExitOverheat );
	}

	protected virtual function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		WeaponObject.TriggerWeaponEffects( GetWeaponObject( scriptInterface ), gamedataFxAction.ExitOverheat );
	}

}

struct QuickMeleeAttackData
{
	var attackGameEffectDelay : Float;
	var attackGameEffectDuration : Float;
	var attackRange : Float;
	var forcePlayerToStand : Bool;
	var shouldAdjust : Bool;
	var adjustmentRange : Float;
	var adjustmentDuration : Float;
	var adjustmentRadius : Float;
	var adjustmentCurve : CName;
	var cooldown : Float;
	var duration : Float;
}

