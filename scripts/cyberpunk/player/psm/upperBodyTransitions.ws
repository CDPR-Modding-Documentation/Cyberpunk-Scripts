abstract class UpperBodyTransition extends DefaultTransition
{

	protected const final function EmptyHandsCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( IsInSafeSceneTier( scriptInterface ) && ( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced ) == true || scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced ) == true ) )
		{
			return false;
		}
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.UseUnarmed ) )
		{
			return true;
		}
		if( HasRightWeaponEquipped( scriptInterface ) && stateContext.GetBoolParameter( 'requestWeaponUnequip', false ) )
		{
			return true;
		}
		return false;
	}

	protected const function GetTransactionSystem( const scriptInterface : StateGameScriptInterface ) : TransactionSystem
	{
		var transactionSystem : TransactionSystem;
		transactionSystem = scriptInterface.GetTransactionSystem();
		if( !( transactionSystem ) )
		{
			return NULL;
		}
		return transactionSystem;
	}

	public static function HasLeftWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponLeft" ) ) ) )
		{
			return true;
		}
		return false;
	}

	public static function HasAnyWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( HasLeftWeaponEquipped( scriptInterface ) || HasRightWeaponEquipped( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	public static function HasMeleeWeaponEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			if( scriptInterface.GetTransactionSystem().HasTag( scriptInterface.executionOwner, WeaponObject.GetMeleeWeaponTag(), weapon.GetItemID() ) )
			{
				return true;
			}
		}
		return false;
	}

	public static function HasRangedWeaponEquipped( const executionOwner : weak< GameObject > ) : Bool
	{
		var weapon : WeaponObject;
		var transactionSystem : TransactionSystem;
		transactionSystem = GameInstance.GetTransactionSystem( executionOwner.GetGame() );
		weapon = ( ( WeaponObject )( transactionSystem.GetItemInSlot( executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			if( transactionSystem.HasTag( executionOwner, WeaponObject.GetRangedWeaponTag(), weapon.GetItemID() ) )
			{
				return true;
			}
		}
		return false;
	}

	public static function HasMeleewareEquipped( const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var weapon : WeaponObject;
		weapon = ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			if( scriptInterface.GetTransactionSystem().HasTag( scriptInterface.executionOwner, 'Meleeware', weapon.GetItemID() ) )
			{
				return true;
			}
		}
		return false;
	}

	protected function IsItemMeleeware( item : ItemID ) : Bool
	{
		var itemTags : array< CName >;
		itemTags = TweakDBInterface.GetItemRecord( ItemID.GetTDBID( item ) ).Tags();
		return itemTags.Contains( 'Meleeware' );
	}

	public function StopEffectOnHeldItems( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var leftItem : ItemObject;
		var rightItem : ItemObject;
		var killEffectEvent : entKillEffectEvent;
		leftItem = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponLeft" ) ) );
		rightItem = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		killEffectEvent = new entKillEffectEvent;
		killEffectEvent.effectName = effectName;
		if( leftItem )
		{
			leftItem.QueueEventToChildItems( killEffectEvent );
		}
		if( rightItem )
		{
			rightItem.QueueEventToChildItems( killEffectEvent );
		}
	}

	public function BreakEffectLoopOnHeldItems( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var leftItem : ItemObject;
		var rightItem : ItemObject;
		var BreakEffectLoopEvent : entBreakEffectLoopEvent;
		leftItem = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponLeft" ) ) );
		rightItem = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
		BreakEffectLoopEvent = new entBreakEffectLoopEvent;
		BreakEffectLoopEvent.effectName = effectName;
		if( leftItem )
		{
			leftItem.QueueEventToChildItems( BreakEffectLoopEvent );
		}
		if( rightItem )
		{
			rightItem.QueueEventToChildItems( BreakEffectLoopEvent );
		}
	}

	protected function SendDOFData( scriptInterface : StateGameScriptInterface, dofSetting : String )
	{
		var dofAnimFeature : AnimFeature_DOFControl;
		var prefix : String;
		dofAnimFeature = new AnimFeature_DOFControl;
		prefix = ( "player." + dofSetting ) + ".";
		dofAnimFeature.dofIntensity = TDB.GetFloat( TDBID.Create( prefix + "intensity" ), 0.0 );
		dofAnimFeature.dofNearBlur = TDB.GetFloat( TDBID.Create( prefix + "nearBlur" ), -1.0 );
		dofAnimFeature.dofNearFocus = TDB.GetFloat( TDBID.Create( prefix + "nearFocus" ), -1.0 );
		dofAnimFeature.dofFarBlur = TDB.GetFloat( TDBID.Create( prefix + "farBlur" ), -1.0 );
		dofAnimFeature.dofFarFocus = TDB.GetFloat( TDBID.Create( prefix + "farFocus" ), -1.0 );
		dofAnimFeature.dofBlendInTime = TDB.GetFloat( TDBID.Create( prefix + "dofBlendInTime" ), -1.0 );
		dofAnimFeature.dofBlendOutTime = TDB.GetFloat( TDBID.Create( prefix + "dofBlendOutTime" ), -1.0 );
		scriptInterface.SetAnimationParameterFeature( 'DOFControl', dofAnimFeature );
	}

	protected function SetWeaponHolster( scriptInterface : StateGameScriptInterface, newState : Bool )
	{
		var weaponHolsterAnimFeature : AnimFeature_PlayerCoverActionWeaponHolster;
		weaponHolsterAnimFeature = new AnimFeature_PlayerCoverActionWeaponHolster;
		weaponHolsterAnimFeature.isWeaponHolstered = newState;
		scriptInterface.SetAnimationParameterFeature( 'PlayerCoverWeaponHolstered', weaponHolsterAnimFeature );
	}

	protected function ProcessWeaponSlotInput( scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.IsActionJustReleased( 'WeaponSlot1' ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestWeaponSlot1 );
		}
		else if( scriptInterface.IsActionJustReleased( 'WeaponSlot2' ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestWeaponSlot2 );
		}
		else if( scriptInterface.IsActionJustReleased( 'WeaponSlot3' ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestWeaponSlot3 );
		}
		else if( scriptInterface.IsActionJustReleased( 'WeaponSlot4' ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestWeaponSlot4 );
		}
		return false;
	}

	protected function CheckRangedAttackInput( scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.IsActionJustPressed( 'RangedAttack' ) && !( IsInteractingWithTerminal( scriptInterface ) );
	}

	protected function CheckMeleeStatesForCombatGadget( scriptInterface : StateGameScriptInterface, stateContext : StateContext ) : Bool
	{
		var inQuickmelee : Bool;
		inQuickmelee = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) == ( ( Int32 )( gamePSMRangedWeaponStates.QuickMelee ) );
		if( HasMeleeWeaponEquipped( scriptInterface ) )
		{
			return !( stateContext.GetBoolParameter( 'isAttacking', true ) );
		}
		return !( inQuickmelee );
	}

}

abstract class UpperBodyEventsTransition extends UpperBodyTransition
{
	var m_switchButtonPushed : Bool;
	var m_cyclePushed : Bool;
	var m_delay : Float;
	var m_cycleBlock : Float;
	var m_switchPending : Bool;
	var m_counter : Int32;

	protected virtual function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var switchItemButtonPushed : StateResultBool;
		var switchItemPending : StateResultBool;
		var switchItemDelay : StateResultFloat;
		var counter : StateResultInt;
		var cycleBlock : StateResultFloat;
		var cyclePushed : StateResultBool;
		switchItemButtonPushed = stateContext.GetPermanentBoolParameter( 'switchItemButtonPushed' );
		switchItemPending = stateContext.GetPermanentBoolParameter( 'switchItemPending' );
		switchItemDelay = stateContext.GetPermanentFloatParameter( 'switchItemDelay' );
		counter = stateContext.GetPermanentIntParameter( 'switchCounter' );
		cycleBlock = stateContext.GetPermanentFloatParameter( 'switchCycleBlock' );
		cyclePushed = stateContext.GetPermanentBoolParameter( 'cyclePushed' );
		if( switchItemButtonPushed.valid )
		{
			m_switchButtonPushed = switchItemButtonPushed.value;
			m_switchPending = switchItemPending.value;
			m_delay = switchItemDelay.value;
			m_counter = counter.value;
			m_cycleBlock = cycleBlock.value;
			m_cyclePushed = cyclePushed.value;
		}
		else
		{
			ResetEquipVars( stateContext );
		}
	}

	protected virtual function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SyncEquipVarsToPermanentStorage( stateContext );
	}

	protected virtual function ResetEquipVars( stateContext : StateContext )
	{
		m_switchButtonPushed = false;
		m_switchPending = false;
		m_cyclePushed = false;
		m_delay = 0.0;
		m_counter = 0;
		m_cycleBlock = 0.0;
		SyncEquipVarsToPermanentStorage( stateContext );
	}

	protected virtual function SyncEquipVarsToPermanentStorage( stateContext : StateContext )
	{
		stateContext.SetPermanentBoolParameter( 'switchItemButtonPushed', m_switchButtonPushed, true );
		stateContext.SetPermanentBoolParameter( 'switchItemPending', m_switchPending, true );
		stateContext.SetPermanentFloatParameter( 'switchItemDelay', m_delay, true );
		stateContext.SetPermanentIntParameter( 'switchCounter', m_counter, true );
		stateContext.SetPermanentFloatParameter( 'switchCycleBlock', m_cycleBlock, true );
		stateContext.SetPermanentBoolParameter( 'cyclePushed', m_cyclePushed, true );
	}

	protected function UpdateSwitchItem( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Bool
	{
		var holsterDelay : Float;
		var nextWeaponJustPressed : Bool;
		var previousWeaponJustPressed : Bool;
		var switchItemJustTapped : Bool;
		var holsterButtonJustTapped : Bool;
		holsterDelay = 0.25;
		nextWeaponJustPressed = scriptInterface.IsActionJustPressed( 'NextWeapon' );
		previousWeaponJustPressed = scriptInterface.IsActionJustPressed( 'PreviousWeapon' );
		switchItemJustTapped = scriptInterface.IsActionJustTapped( 'SwitchItem' );
		holsterButtonJustTapped = scriptInterface.IsActionJustReleased( 'HolsterWeapon' );
		if( ( ( ( ( !( m_switchButtonPushed ) && !( m_cyclePushed ) ) && !( nextWeaponJustPressed ) ) && !( previousWeaponJustPressed ) ) && !( switchItemJustTapped ) ) && !( holsterButtonJustTapped ) )
		{
			return false;
		}
		if( ( ( ( ( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoSwitch' ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ShootingRangeCompetition' ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' ) ) || stateContext.IsStateMachineActive( 'Consumable' ) ) || stateContext.IsStateMachineActive( 'CombatGadget' ) ) || CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipping ) )
		{
			return false;
		}
		if( holsterButtonJustTapped && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequip' ) ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipWeapon );
			ResetEquipVars( stateContext );
			return true;
		}
		if( m_cyclePushed )
		{
			m_cycleBlock += timeDelta;
			if( m_cycleBlock > 0.5 )
			{
				m_cycleBlock = 0.0;
				m_cyclePushed = false;
				stateContext.SetPermanentBoolParameter( 'cyclePushed', m_cyclePushed, true );
			}
		}
		if( ( ( ( nextWeaponJustPressed && !( m_cyclePushed ) ) && !( m_switchPending ) ) && HasRightWeaponEquipped( scriptInterface ) ) && CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipped ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem );
			m_cyclePushed = true;
			stateContext.SetPermanentBoolParameter( 'cyclePushed', m_cyclePushed, true );
			return true;
		}
		else if( ( ( ( previousWeaponJustPressed && !( m_cyclePushed ) ) && !( m_switchPending ) ) && HasRightWeaponEquipped( scriptInterface ) ) && CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipped ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.CyclePreviousWeaponWheelItem );
			m_cyclePushed = true;
			stateContext.SetPermanentBoolParameter( 'cyclePushed', m_cyclePushed, true );
			return true;
		}
		if( switchItemJustTapped && !( m_cyclePushed ) )
		{
			m_switchButtonPushed = true;
			m_counter += 1;
		}
		if( m_switchButtonPushed )
		{
			m_delay += timeDelta;
			if( ( ( m_delay < holsterDelay ) && m_switchButtonPushed ) && !( m_switchPending ) )
			{
				if( EquipmentSystem.GetData( scriptInterface.executionOwner ).CycleWeapon( true, true ) != ItemID.None() )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipWeapon );
					m_switchPending = true;
				}
				return false;
			}
			else
			{
				if( m_delay >= holsterDelay )
				{
					if( m_counter == 1 )
					{
						SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem );
					}
					else if( ( ( m_counter > 1 ) && ( EquipmentSystem.GetData( scriptInterface.executionOwner ).CycleWeapon( true, true ) == ItemID.None() ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequip' ) ) )
					{
						SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipWeapon );
					}
					ResetEquipVars( stateContext );
				}
				return true;
			}
		}
		return false;
	}

	protected function CheckSwitchInput( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( stateContext.GetBoolParameter( 'cyclePushed', true ) ) && ( GetInStateTime() > 1.0 ) )
		{
			return scriptInterface.IsActionJustPressed( 'NextWeapon' ) || scriptInterface.IsActionJustPressed( 'PreviousWeapon' );
		}
		else
		{
			return false;
		}
	}

}

class ForceEmptyHandsDecisions extends UpperBodyTransition
{
	const var stateBodyDone : Bool;

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( scriptInterface.CanEquipItem( stateContext ) ) )
		{
			return false;
		}
		if( IsEmptyHandsForced( stateContext, scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

	protected export const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsEmptyHandsForced( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsEmptyHandsForced( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

}

class ForceEmptyHandsEvents extends UpperBodyEventsTransition
{

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var upperBody : PSMStopStateMachine;
		upperBody = new PSMStopStateMachine;
		ResetEquipVars( stateContext );
		SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipAll );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.ForceEmptyHands ) ) );
		if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vehicle ) == ( ( Int32 )( gamePSMVehicle.Driving ) ) )
		{
			upperBody = new PSMStopStateMachine;
			upperBody.stateMachineIdentifier.definitionName = 'UpperBody';
			scriptInterface.executionOwner.QueueEvent( upperBody );
		}
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var dpadAction : DPADActionPerformed;
		var notificationEvent : UIInGameNotificationEvent;
		if( scriptInterface.IsActionJustReleased( 'UseConsumable' ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.DPAD_UP;
			if( ( ( ( !( stateContext.IsStateMachineActive( 'Consumable' ) ) && CheckActiveConsumable( scriptInterface ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && CheckConsumableLootDataCondition( scriptInterface ) ) && !( IsInFocusMode( scriptInterface ) ) )
			{
				if( !( IsUsingConsumableRestricted( scriptInterface ) ) )
				{
					dpadAction.successful = true;
					scriptInterface.GetUISystem().QueueEvent( dpadAction );
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestConsumable );
				}
				else
				{
					notificationEvent = new UIInGameNotificationEvent;
					notificationEvent.m_notificationType = UIInGameNotificationType.ActionRestriction;
					scriptInterface.GetUISystem().QueueEvent( notificationEvent );
				}
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.Default ) ) );
	}

}

class ForceSafeDecisions extends UpperBodyTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( IsSafeStateForced( stateContext, scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsSafeStateForced( stateContext, scriptInterface ) ) || ( ( HasRightWeaponEquipped( scriptInterface ) && ( GetInStateTime() >= 0.44999999 ) ) && EmptyHandsCondition( stateContext, scriptInterface ) ) )
		{
			return true;
		}
		else if( ( ( !( IsMultiplayer() ) && HasRightWeaponEquipped( scriptInterface ) ) && ( GetStaticFloatParameterDefault( "timeToAutoUnequipWeapon", -1.0 ) > 0.0 ) ) && ( stateContext.GetConditionFloat( 'ForceSafeCurrentTimeToAutoUnequip' ) >= ( GetStaticFloatParameterDefault( "timeToAutoUnequipWeapon", -1.0 ) + stateContext.GetConditionFloat( 'ForceSafeTimeStampToAutoUnequip' ) ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( IsSafeStateForced( stateContext, scriptInterface ) ) && HasRightWeaponEquipped( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

}

class ForceSafeEvents extends UpperBodyEventsTransition
{
	var m_safeAnimFeature : AnimFeature_SafeAction;
	var m_weaponObjectID : TweakDBID;

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		stateContext.SetPermanentBoolParameter( 'WeaponInSafe', true, true );
		scriptInterface.SetAnimationParameterFloat( 'safe', 1.0 );
		m_safeAnimFeature = new AnimFeature_SafeAction;
		m_weaponObjectID = TDB.GetWeaponItemRecord( ItemID.GetTDBID( GetActiveWeapon( scriptInterface ).GetItemID() ) ).GetID();
		stateContext.SetConditionFloatParameter( 'ForceSafeTimeStampToAutoUnequip', GetInStateTime(), true );
		stateContext.SetConditionFloatParameter( 'ForceSafeCurrentTimeToAutoUnequip', 0.0, true );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( IsCarryingBody( scriptInterface ) )
		{
			return;
		}
		if( HasRightWeaponEquipped( scriptInterface ) )
		{
			if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel ) == ( ( Int32 )( gamePSMHighLevel.SceneTier2 ) ) )
			{
				UpdateSwitchItem( timeDelta, stateContext, scriptInterface );
			}
			if( scriptInterface.IsActionJustPressed( 'RangedAttack' ) && !( WeaponObject.IsMagazineEmpty( GetActiveWeapon( scriptInterface ) ) ) )
			{
				scriptInterface.PushAnimationEvent( 'SafeAction' );
			}
			else if( scriptInterface.GetActionValue( 'RangedAttack' ) > 0.5 )
			{
				stateContext.SetPermanentBoolParameter( 'TriggerHeld', true, true );
				m_safeAnimFeature.triggerHeld = true;
			}
			else if( scriptInterface.GetActionValue( 'RangedAttack' ) < 0.5 )
			{
				stateContext.SetPermanentBoolParameter( 'TriggerHeld', false, true );
				m_safeAnimFeature.triggerHeld = false;
			}
			else if( scriptInterface.IsActionJustReleased( 'RangedAttack' ) )
			{
				stateContext.SetConditionFloatParameter( 'ForceSafeTimeStampToAutoUnequip', stateContext.GetConditionFloat( 'ForceSafeTimeStampToAutoUnequip' ) + GetStaticFloatParameterDefault( "addedTimeToAutoUnequipAfterSafeAction", 0.0 ), true );
			}
			stateContext.SetConditionFloatParameter( 'ForceSafeCurrentTimeToAutoUnequip', stateContext.GetConditionFloat( 'ForceSafeCurrentTimeToAutoUnequip' ) + timeDelta, true );
			m_safeAnimFeature.safeActionDuration = TDB.GetFloat( m_weaponObjectID + T".safeActionDuration" );
			scriptInterface.SetAnimationParameterFeature( 'SafeAction', m_safeAnimFeature );
			scriptInterface.SetAnimationParameterFeature( 'SafeAction', m_safeAnimFeature, GetActiveWeapon( scriptInterface ) );
		}
		else if( !( HasRightWeaponEquipped( scriptInterface ) ) )
		{
			if( scriptInterface.IsActionJustReleased( 'SwitchItem' ) || CheckRangedAttackInput( scriptInterface ) )
			{
				if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'OneHandedFirearms' ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon );
				}
				else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Melee' ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon );
				}
				else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestFists );
				}
				else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Firearms' ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon );
				}
				else
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon );
				}
			}
		}
	}

}

class EmptyHandsDecisions extends UpperBodyTransition
{
	const var stateBodyDone : Bool;

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( !( scriptInterface.CanEquipItem( stateContext ) ) )
		{
			return false;
		}
		if( !( HasRightWeaponEquipped( scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ExitCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return stateBodyDone;
	}

	protected export const function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return HasRightWeaponEquipped( scriptInterface );
	}

}

class EmptyHandsEvents extends UpperBodyEventsTransition
{

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		scriptInterface.ActivateCameraSetting( 'weapon' );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.Default ) ) );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, ( ( Int32 )( gamePSMRangedWeaponStates.Default ) ) );
		SetWeaponHolster( scriptInterface, true );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var dpadAction : DPADActionPerformed;
		if( ( IsInTakedownState( stateContext ) || ( GetSceneTier( scriptInterface ) > 2 ) ) || CheckBodyCarryingConditions( stateContext, scriptInterface ) )
		{
			return;
		}
		if( ( !( CheckGenericEquipItemConditions( stateContext, scriptInterface ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequipNoSwitch' ) ) || StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ShootingRangeCompetition' ) )
		{
			return;
		}
		ProcessCombatGadgetActionInputCaching( scriptInterface, stateContext );
		if( ( ( ( ( ( ( scriptInterface.IsActionJustReleased( 'SwitchItem' ) || CheckRangedAttackInput( scriptInterface ) ) || scriptInterface.IsActionJustReleased( 'HolsterWeapon' ) ) || CheckSwitchInput( stateContext, scriptInterface ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( stateContext.IsStateMachineActive( 'Consumable' ) ) ) && !( stateContext.IsStateMachineActive( 'LeftHandCyberware' ) ) ) && ( !( IsCarryingBody( scriptInterface ) ) || ( IsCarryingBody( scriptInterface ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'NoCombat' ) ) ) ) )
		{
			if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'OneHandedFirearms' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon );
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Melee' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon );
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestFists );
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Firearms' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon );
			}
			else
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon );
			}
		}
		else if( ( !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) && !( IsCarryingBody( scriptInterface ) ) ) && ProcessWeaponSlotInput( scriptInterface ) )
		{
			return;
		}
		else if( scriptInterface.IsActionJustReleased( 'UseConsumable' ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.DPAD_UP;
			if( ( ( ( ( ( ( ( ( ( !( stateContext.IsStateMachineActive( 'Consumable' ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( stateContext.IsStateMachineActive( 'LeftHandCyberware' ) ) ) && CheckActiveConsumable( scriptInterface ) ) && !( IsInUpperBodyState( stateContext, 'temporaryUnequip' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && CheckConsumableLootDataCondition( scriptInterface ) ) && !( IsInFocusMode( scriptInterface ) ) ) && !( IsCarryingBody( scriptInterface ) ) ) && !( IsUsingConsumableRestricted( scriptInterface ) ) )
			{
				dpadAction.successful = true;
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestConsumable );
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
		else if( scriptInterface.IsActionJustPressed( 'UseCombatGadget' ) || stateContext.GetBoolParameter( 'cgCached', true ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.RB;
			if( ( ( ( ( ( ( ( IsUsingLeftHandAllowed( scriptInterface ) && !( stateContext.IsStateMachineActive( 'Consumable' ) ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && !( IsInSafeZone( scriptInterface ) ) ) && ( GetInStateTime() > 0.30000001 ) ) && !( IsCarryingBody( scriptInterface ) ) ) && !( IsInWorkspot( scriptInterface ) ) )
			{
				dpadAction.successful = true;
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
				if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Gadget ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
				}
				else if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Cyberware ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					stateContext.RemovePermanentBoolParameter( 'cgCached' );
				}
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
		else
		{
			UpdateSwitchItem( timeDelta, stateContext, scriptInterface );
		}
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
	}

	protected const function CheckBodyCarryingConditions( stateContext : StateContext, scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( scriptInterface.HasStatFlag( gamedataStatType.CanShootWhileCarryingBody ) )
		{
			return ( CompareLocalBlackboardInt( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, ( ( Int32 )( gamePSMBodyCarrying.PickUp ) ) ) || CompareLocalBlackboardInt( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, ( ( Int32 )( gamePSMBodyCarrying.Dispose ) ) ) ) || CompareLocalBlackboardInt( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying, ( ( Int32 )( gamePSMBodyCarrying.Drop ) ) );
		}
		else
		{
			return IsCarryingBody( scriptInterface );
		}
	}

}

class SingleWieldDecisions extends UpperBodyTransition
{

	protected const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( HasRightWeaponEquipped( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var broadcaster : StimBroadcasterComponent;
		if( !( HasRightWeaponEquipped( scriptInterface ) ) || ( ( GetInStateTime() >= 0.44999999 ) && EmptyHandsCondition( stateContext, scriptInterface ) ) )
		{
			broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
			if( broadcaster )
			{
				broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.WeaponHolstered );
			}
			return true;
		}
		else if( HasRightWeaponEquipped( scriptInterface ) && stateContext.GetBoolParameter( 'requestWeaponUnequip', false ) )
		{
			broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
			if( broadcaster )
			{
				broadcaster.TriggerSingleBroadcast( scriptInterface.executionOwner, gamedataStimType.WeaponHolstered );
			}
			return true;
		}
		return false;
	}

}

class SingleWieldEvents extends UpperBodyEventsTransition
{
	var m_hasInstantEquipHackBeenApplied : Bool;

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnEnter( stateContext, scriptInterface );
		m_hasInstantEquipHackBeenApplied = false;
		if( scriptInterface.executionOwner.IsControlledByAnotherClient() )
		{
			InstantEquipHACK( stateContext, scriptInterface );
		}
		SetWeaponHolster( scriptInterface, false );
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		super.OnExit( stateContext, scriptInterface );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var isCPOControlScheme : Bool;
		var rhIden : StateMachineIdentifier;
		var dpadAction : DPADActionPerformed;
		var isPerformingMeleeAttack : Bool;
		( ( PlayerPuppet )( scriptInterface.executionOwner ) ).ReevaluateLookAtTarget();
		if( scriptInterface.executionOwner.IsControlledByAnotherClient() && !( m_hasInstantEquipHackBeenApplied ) )
		{
			InstantEquipHACK( stateContext, scriptInterface );
		}
		if( IsInTakedownState( stateContext ) || ( GetSceneTier( scriptInterface ) > 2 ) )
		{
			return;
		}
		if( stateContext.GetConditionBool( 'AimingInterrupted' ) && ( ( scriptInterface.GetActionValue( 'CameraAim' ) < 0.5 ) || ( GetInStateTime() > 1.0 ) ) )
		{
			stateContext.SetConditionBoolParameter( 'AimingInterrupted', false, true );
		}
		rhIden.definitionName = 'Equipment';
		rhIden.referenceName = 'RightHand';
		if( !( stateContext.GetBoolParameter( 'isAttacking', true ) ) && stateContext.IsStateActiveWithIdentifier( rhIden, 'unequipCycle' ) )
		{
			MeleeTransition.UpdateMeleeInputBuffer( stateContext, scriptInterface, true );
		}
		if( !( CheckGenericEquipItemConditions( stateContext, scriptInterface ) ) )
		{
			return;
		}
		if( scriptInterface.IsActionJustReleased( 'UseConsumable' ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.DPAD_UP;
			if( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Melee ) == ( ( Int32 )( gamePSMMelee.Attack ) ) )
			{
				isPerformingMeleeAttack = true;
			}
			if( ( ( ( ( ( ( ( ( ( ( !( stateContext.IsStateMachineActive( 'Consumable' ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( stateContext.IsStateMachineActive( 'LeftHandCyberware' ) ) ) && CheckActiveConsumable( scriptInterface ) ) && CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipped ) ) && !( IsInUpperBodyState( stateContext, 'temporaryUnequip' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && CheckConsumableLootDataCondition( scriptInterface ) ) && !( IsInFocusMode( scriptInterface ) ) ) && !( IsUsingConsumableRestricted( scriptInterface ) ) ) && !( isPerformingMeleeAttack ) )
			{
				dpadAction.successful = true;
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestConsumable );
				return;
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
		ProcessCombatGadgetActionInputCaching( scriptInterface, stateContext );
		if( scriptInterface.IsActionJustPressed( 'UseCombatGadget' ) || stateContext.GetBoolParameter( 'cgCached', true ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.RB;
			if( ( ( ( ( ( ( ( ( ( IsUsingLeftHandAllowed( scriptInterface ) && !( stateContext.IsStateMachineActive( 'Consumable' ) ) ) && !( IsInUpperBodyState( stateContext, 'temporaryUnequip' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipped ) ) && CheckMeleeStatesForCombatGadget( scriptInterface, stateContext ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && ( GetInStateTime() > 0.30000001 ) ) && !( IsInSafeZone( scriptInterface ) ) ) && !( IsInWorkspot( scriptInterface ) ) )
			{
				dpadAction.successful = true;
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
				if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Gadget ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					return;
				}
				else if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Cyberware ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					stateContext.RemovePermanentBoolParameter( 'cgCached' );
					return;
				}
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
		isCPOControlScheme = GameInstance.GetRuntimeInfo( scriptInterface.executionOwner.GetGame() ).IsMultiplayer() || scriptInterface.GetPlayerSystem().IsCPOControlSchemeForced();
		if( isCPOControlScheme && ( scriptInterface.IsActionJustReleased( 'SwitchItem' ) || ( scriptInterface.GetActionValue( 'SwitchItemMW' ) != 0.0 ) ) )
		{
			SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.CycleWeaponWheelItem );
		}
		else if( !( isCPOControlScheme ) && UpdateSwitchItem( timeDelta, stateContext, scriptInterface ) )
		{
			return;
		}
		else if( ( ( !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequipNoSwitch' ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoSwitch' ) ) ) && !( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ShootingRangeCompetition' ) ) ) && ProcessWeaponSlotInput( scriptInterface ) )
		{
			return;
		}
	}

	public function InstantEquipHACK( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var rightHandItemHandling : AnimFeature_EquipUnequipItem;
		var weaponID : ItemID;
		var weaponRecData : WeaponItem_Record;
		var weapon : WeaponObject;
		weapon = GetActiveWeapon( scriptInterface );
		if( weapon )
		{
			weaponID = weapon.GetItemID();
			weaponRecData = TDB.GetWeaponItemRecord( ItemID.GetTDBID( weaponID ) );
			rightHandItemHandling = new AnimFeature_EquipUnequipItem;
			rightHandItemHandling.itemState = 2;
			rightHandItemHandling.stateTransitionDuration = 0.0;
			rightHandItemHandling.itemType = weaponRecData.ItemType().AnimFeatureIndex();
			scriptInterface.SetAnimationParameterFeature( 'rightHandItemHandling', rightHandItemHandling );
			m_hasInstantEquipHackBeenApplied = true;
		}
	}

}

class AimingStateDecisions extends UpperBodyTransition
{
	private var m_callbackIDs : array< CallbackHandle >;
	private var m_executionOwner : weak< GameObject >;
	private var m_statListener : DefaultTransitionStatListener;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_attachmentSlotListener : AttachmentSlotsScriptListener;
	private var m_sceneTier : Int32;
	private var m_vehicleState : Int32;
	private var m_highLevelState : Int32;
	private var m_combatGadgetState : Int32;
	private var m_takedownState : Int32;
	private var m_weaponState : Int32;
	private var m_cameraAimPressed : Bool;
	private var m_sceneAimForced : Bool;
	private var m_shouldAim : Bool;
	private var m_hasRightHandItemEquipped : Bool;
	private var m_isDead : Bool;
	private var m_isWeaponBlockingAiming : Bool;
	private var m_visionModeActive : Bool;
	private var m_isDodging : Bool;
	private var m_hasThrowableMeleeWeapon : Bool;
	private var m_canAimWhileDodging : Bool;
	private var m_canThrowWeapon : Bool;
	private var m_aimForced : Bool;
	private var m_beingCreated : Bool;
	private var m_mouseZoomLevel : Float;
	default m_mouseZoomLevel = 100000.f;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var allBlackboardDef : AllBlackboardDefinitions;
		var attachmentSlotCallback : DefaultTransitionAttachmentSlotsCallback;
		m_beingCreated = true;
		m_executionOwner = scriptInterface.executionOwner;
		scriptInterface.executionOwner.RegisterInputListener( this, 'CameraAim' );
		m_cameraAimPressed = scriptInterface.GetActionValue( 'CameraAim' ) > 0.0;
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( scriptInterface.owner.GetEntityID(), m_statusEffectListener );
		m_aimForced = StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ForceAim' );
		allBlackboardDef = GetAllBlackboardDefs();
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.SceneTier, this, 'OnSceneTierChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vehicle, this, 'OnVehicleChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.HighLevel, this, 'OnHighLevelChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerBool( allBlackboardDef.PlayerStateMachine.SceneAimForced, this, 'OnSceneAimForcedChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vitals, this, 'OnVitalsChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Takedown, this, 'OnTakedownChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.CombatGadget, this, 'OnCombatGadgetChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Vision, this, 'OnVisionChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Weapon, this, 'OnWeaponStateChanged', true ) );
		m_callbackIDs.PushBack( scriptInterface.localBlackboard.RegisterListenerInt( allBlackboardDef.PlayerStateMachine.Locomotion, this, 'OnLocomoatoinStateChanged', true ) );
		attachmentSlotCallback = new DefaultTransitionAttachmentSlotsCallback;
		attachmentSlotCallback.m_transitionOwner = this;
		attachmentSlotCallback.slotID = T"AttachmentSlots.WeaponRight";
		m_attachmentSlotListener = scriptInterface.GetTransactionSystem().RegisterAttachmentSlotListener( m_executionOwner, attachmentSlotCallback );
		m_statListener = new DefaultTransitionStatListener;
		m_statListener.m_transitionOwner = this;
		scriptInterface.GetStatsSystem().RegisterListener( m_executionOwner.GetEntityID(), m_statListener );
		m_canThrowWeapon = scriptInterface.HasStatFlag( gamedataStatType.CanThrowWeapon );
		m_canAimWhileDodging = scriptInterface.HasStatFlag( gamedataStatType.CanAimWhileDodging );
		m_beingCreated = false;
		UpdateEnterConditionEnabled();
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.executionOwner.UnregisterInputListener( this );
		m_statusEffectListener = NULL;
		m_callbackIDs.Clear();
		scriptInterface.GetTransactionSystem().UnregisterAttachmentSlotListener( m_executionOwner, m_attachmentSlotListener );
		scriptInterface.GetStatsSystem().UnregisterListener( m_executionOwner.GetEntityID(), m_statListener );
	}

	private function GetShouldAimValue() : Bool
	{
		if( m_aimForced )
		{
			return true;
		}
		if( m_sceneTier > 3 )
		{
			return false;
		}
		if( ( ( m_sceneTier < 3 ) && ( m_vehicleState != ( ( Int32 )( gamePSMVehicle.Default ) ) ) ) && ( m_vehicleState != ( ( Int32 )( gamePSMVehicle.Combat ) ) ) )
		{
			return false;
		}
		if( m_cameraAimPressed )
		{
			return true;
		}
		if( ( ( m_highLevelState > ( ( Int32 )( gamePSMHighLevel.SceneTier1 ) ) ) && ( m_highLevelState <= ( ( Int32 )( gamePSMHighLevel.SceneTier5 ) ) ) ) && m_sceneAimForced )
		{
			return true;
		}
		return false;
	}

	private function ShouldCheckEnterCondition() : Bool
	{
		if( m_isDead )
		{
			return false;
		}
		if( ( ( m_highLevelState != ( ( Int32 )( gamePSMHighLevel.SceneTier1 ) ) ) && ( m_highLevelState != ( ( Int32 )( gamePSMHighLevel.SceneTier2 ) ) ) ) && ( m_highLevelState != ( ( Int32 )( gamePSMHighLevel.SceneTier3 ) ) ) )
		{
			return false;
		}
		if( ( ( m_takedownState == ( ( Int32 )( gamePSMTakedown.Grapple ) ) ) || ( m_takedownState == ( ( Int32 )( gamePSMTakedown.Leap ) ) ) ) || ( m_takedownState == ( ( Int32 )( gamePSMTakedown.Takedown ) ) ) )
		{
			return false;
		}
		if( ( ( m_combatGadgetState > ( ( Int32 )( gamePSMCombatGadget.Default ) ) ) && ( m_combatGadgetState < ( ( Int32 )( gamePSMCombatGadget.WaitForUnequip ) ) ) ) && !( m_visionModeActive ) )
		{
			return false;
		}
		if( m_isWeaponBlockingAiming )
		{
			return false;
		}
		if( m_hasThrowableMeleeWeapon && !( m_canThrowWeapon ) )
		{
			return false;
		}
		if( !( m_canAimWhileDodging ) && m_isDodging )
		{
			return false;
		}
		return true;
	}

	private function UpdateEnterConditionEnabled()
	{
		if( m_beingCreated )
		{
			return;
		}
		m_shouldAim = GetShouldAimValue();
		EnableOnEnterCondition( m_shouldAim && ShouldCheckEnterCondition() );
	}

	protected event OnAction( action : ListenerAction, consumer : ListenerActionConsumer )
	{
		m_cameraAimPressed = ListenerAction.GetValue( action ) > 0.0;
		UpdateEnterConditionEnabled();
	}

	protected event OnSceneTierChanged( value : Int32 )
	{
		m_sceneTier = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnVehicleChanged( value : Int32 )
	{
		m_vehicleState = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnHighLevelChanged( value : Int32 )
	{
		m_highLevelState = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnSceneAimForcedChanged( value : Bool )
	{
		m_sceneAimForced = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnVitalsChanged( value : Int32 )
	{
		m_isDead = value == ( ( Int32 )( gamePSMVitals.Dead ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnTakedownChanged( value : Int32 )
	{
		m_takedownState = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnCombatGadgetChanged( value : Int32 )
	{
		m_combatGadgetState = value;
		UpdateEnterConditionEnabled();
	}

	protected event OnVisionChanged( value : Int32 )
	{
		m_visionModeActive = value == ( ( Int32 )( gamePSMVision.Focus ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnWeaponStateChanged( value : Int32 )
	{
		m_weaponState = value;
		m_isWeaponBlockingAiming = ( ( value == ( ( Int32 )( gamePSMRangedWeaponStates.QuickMelee ) ) ) || ( value == ( ( Int32 )( gamePSMRangedWeaponStates.Overheat ) ) ) ) || ( value == ( ( Int32 )( gamePSMRangedWeaponStates.Reload ) ) );
		UpdateEnterConditionEnabled();
	}

	protected event OnLocomoatoinStateChanged( value : Int32 )
	{
		m_isDodging = ( value == ( ( Int32 )( gamePSMLocomotionStates.Dodge ) ) ) || ( value == ( ( Int32 )( gamePSMLocomotionStates.DodgeAir ) ) );
		UpdateEnterConditionEnabled();
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( !( m_aimForced ) )
		{
			if( statusEffect.GameplayTagsContains( 'ForceAim' ) )
			{
				m_aimForced = true;
				UpdateEnterConditionEnabled();
			}
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_aimForced )
		{
			if( statusEffect.GameplayTagsContains( 'ForceAim' ) )
			{
				m_aimForced = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'ForceAim' );
				if( !( m_aimForced ) )
				{
					UpdateEnterConditionEnabled();
				}
			}
		}
	}

	public override function OnStatChanged( ownerID : StatsObjectID, statType : gamedataStatType, diff : Float, value : Float )
	{
		if( statType == gamedataStatType.CanThrowWeapon )
		{
			m_canThrowWeapon = value > 0.0;
			UpdateEnterConditionEnabled();
		}
		if( statType == gamedataStatType.CanAimWhileDodging )
		{
			m_canAimWhileDodging = value > 0.0;
			UpdateEnterConditionEnabled();
		}
	}

	public override function OnItemEquipped( slot : TweakDBID, item : ItemID )
	{
		var tarnsactioSystem : TransactionSystem;
		tarnsactioSystem = GameInstance.GetTransactionSystem( m_executionOwner.GetGame() );
		m_hasRightHandItemEquipped = true;
		m_hasThrowableMeleeWeapon = tarnsactioSystem.HasTag( m_executionOwner, WeaponObject.GetMeleeWeaponTag(), item ) && tarnsactioSystem.HasTag( m_executionOwner, 'Throwable', item );
		UpdateEnterConditionEnabled();
	}

	public override function OnItemUnequipped( slot : TweakDBID, item : ItemID )
	{
		m_hasRightHandItemEquipped = false;
		m_hasThrowableMeleeWeapon = false;
		UpdateEnterConditionEnabled();
	}

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var pendingAdjust : Bool;
		if( IsRightHandInUnequippingState( stateContext ) || IsLeftHandInUnequippingState( stateContext ) )
		{
			return false;
		}
		if( IsPlayerInBraindance( scriptInterface ) )
		{
			return false;
		}
		if( stateContext.GetConditionBool( 'AimingInterrupted' ) || IsAimingSoftBlocked( stateContext, scriptInterface ) )
		{
			return false;
		}
		if( IsAimingBlockedForTime( stateContext, scriptInterface ) )
		{
			return false;
		}
		if( stateContext.IsStateMachineActive( 'Consumable' ) )
		{
			return false;
		}
		if( IsInItemWheelState( stateContext ) )
		{
			return false;
		}
		pendingAdjust = stateContext.GetTemporaryScriptableParameter( 'adjustTransform' );
		return !( pendingAdjust );
	}

	protected export const function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( m_weaponState == ( ( Int32 )( gamePSMRangedWeaponStates.QuickMelee ) ) )
		{
			return true;
		}
		if( !( m_shouldAim ) )
		{
			return true;
		}
		if( IsAimingBlockedForTime( stateContext, scriptInterface ) )
		{
			return true;
		}
		if( IsAimingHeldForTime( stateContext, scriptInterface ) )
		{
			return false;
		}
		if( m_isWeaponBlockingAiming )
		{
			return true;
		}
		if( !( m_hasRightHandItemEquipped ) || !( IsRightHandInEquippedState( stateContext ) ) )
		{
			return false;
		}
		if( stateContext.GetBoolParameter( 'InterruptAiming', false ) )
		{
			stateContext.SetConditionBoolParameter( 'AimingInterrupted', true, true );
			return true;
		}
		if( stateContext.IsStateMachineActive( 'Consumable' ) )
		{
			return true;
		}
		return false;
	}

	protected export const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( m_shouldAim ) && !( m_hasRightHandItemEquipped );
	}

	protected export const function ToForceEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var emptyHandsForced : Bool;
		emptyHandsForced = IsEmptyHandsForced( stateContext, scriptInterface );
		if( m_hasRightHandItemEquipped && emptyHandsForced )
		{
			return true;
		}
		return !( m_shouldAim ) && emptyHandsForced;
	}

	protected export const function ToForceSafe( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return !( m_shouldAim ) && IsSafeStateForced( stateContext, scriptInterface );
	}

}

class AimingStateEvents extends UpperBodyEventsTransition
{
	private var m_aim : AnimFeature_AimPlayer;
	private var m_posAnimFeature : AnimFeature_ProceduralIronsightData;
	private var m_statusEffectListener : DefaultTransitionStatusEffectListener;
	private var m_weapon : weak< WeaponObject >;
	private var m_executionOwner : weak< GameObject >;
	private var m_mouseZoomLevel : Float;
	default m_mouseZoomLevel = 100000.f;
	private var m_zoomLevelNum : Int32;
	private var m_numZoomLevels : Int32;
	private var m_delayAimSnap : Int32;
	private var m_isAiming : Bool;
	private var m_aimInTimeRemaining : Float;
	default m_aimInTimeRemaining = 0.0f;
	private var m_aimBroadcast : Bool;
	private var m_zoomLevel : Float;
	private var m_finalZoomLevel : Float;
	private var m_previousZoomLevel : Float;
	private var m_currentZoomLevel : Float;
	private var timeToBlendZoom : Float;
	private var time : Float;
	private var m_speed : Float;
	private var m_itemChanged : Bool;
	private var m_firearmsNoUnequipNoSwitch : Bool;
	private var m_shootingRangeCompetition : Bool;
	private var m_weaponHasPerfectAim : Bool;
	private var m_attachmentSlotListener : AttachmentSlotsScriptListener;

	protected export function OnAttach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		var attachmentSlotCallback : DefaultTransitionAttachmentSlotsCallback;
		m_posAnimFeature = new AnimFeature_ProceduralIronsightData;
		m_aim = new AnimFeature_AimPlayer;
		m_executionOwner = scriptInterface.executionOwner;
		attachmentSlotCallback = new DefaultTransitionAttachmentSlotsCallback;
		attachmentSlotCallback.m_transitionOwner = this;
		attachmentSlotCallback.slotID = T"AttachmentSlots.WeaponRight";
		m_attachmentSlotListener = scriptInterface.GetTransactionSystem().RegisterAttachmentSlotListener( scriptInterface.executionOwner, attachmentSlotCallback );
		m_statusEffectListener = new DefaultTransitionStatusEffectListener;
		m_statusEffectListener.m_transitionOwner = this;
		scriptInterface.GetStatusEffectSystem().RegisterListener( scriptInterface.owner.GetEntityID(), m_statusEffectListener );
		m_firearmsNoUnequipNoSwitch = StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'FirearmsNoUnequipNoSwitch' );
		m_shootingRangeCompetition = StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'ShootingRangeCompetition' );
	}

	protected export function OnDetach( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface )
	{
		scriptInterface.GetTransactionSystem().UnregisterAttachmentSlotListener( scriptInterface.executionOwner, m_attachmentSlotListener );
		m_statusEffectListener = NULL;
	}

	public override function OnItemEquipped( slot : TweakDBID, item : ItemID )
	{
		m_itemChanged = true;
	}

	public override function OnItemUnequipped( slot : TweakDBID, item : ItemID )
	{
		m_itemChanged = true;
	}

	public override function OnStatusEffectApplied( statusEffect : weak< StatusEffect_Record > )
	{
		if( !( m_firearmsNoUnequipNoSwitch ) )
		{
			if( statusEffect.GameplayTagsContains( 'FirearmsNoUnequipNoSwitch' ) )
			{
				m_firearmsNoUnequipNoSwitch = true;
			}
		}
		if( !( m_shootingRangeCompetition ) )
		{
			if( statusEffect.GameplayTagsContains( 'ShootingRangeCompetition' ) )
			{
				m_shootingRangeCompetition = true;
			}
		}
	}

	public override function OnStatusEffectRemoved( statusEffect : weak< StatusEffect_Record > )
	{
		if( m_firearmsNoUnequipNoSwitch )
		{
			if( statusEffect.GameplayTagsContains( 'FirearmsNoUnequipNoSwitch' ) )
			{
				m_firearmsNoUnequipNoSwitch = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'FirearmsNoUnequipNoSwitch' );
			}
		}
		if( m_shootingRangeCompetition )
		{
			if( statusEffect.GameplayTagsContains( 'ShootingRangeCompetition' ) )
			{
				m_shootingRangeCompetition = StatusEffectSystem.ObjectHasStatusEffectWithTag( m_executionOwner, 'ShootingRangeCompetition' );
			}
		}
	}

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var player : PlayerPuppet;
		player = ( ( PlayerPuppet )( scriptInterface.executionOwner ) );
		super.OnEnter( stateContext, scriptInterface );
		if( m_itemChanged )
		{
			m_weapon = GetWeaponObject( scriptInterface );
			m_weaponHasPerfectAim = scriptInterface.GetTransactionSystem().HasTag( scriptInterface.executionOwner, 'PerfectAim', m_weapon.GetItemID() );
		}
		stateContext.SetConditionBoolParameter( 'AimingInterrupted', false, true );
		scriptInterface.SetAnimationParameterBool( 'has_scope', m_weapon.HasScope() );
		stateContext.SetTemporaryBoolParameter( 'InterruptSprint', true, true );
		stateContext.SetConditionBoolParameter( 'SprintToggled', false, true );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.Aim ) ) );
		player.OnEnterAimState();
		PlayEffectOnHeldItems( scriptInterface, 'lightswitch' );
		OnAimStartBegin( stateContext, scriptInterface );
		m_numZoomLevels = GetStaticIntParameterDefault( "maxNumberOfZoomLevels", 1 );
		if( m_itemChanged )
		{
			UpdateWeaponOffsetPosition( scriptInterface );
		}
		m_itemChanged = false;
	}

	protected function OnAimStartBegin( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var usingCover : Bool;
		scriptInterface.GetTargetingSystem().OnAimStartBegin( scriptInterface.owner );
		if( m_weapon )
		{
			m_aimInTimeRemaining = scriptInterface.GetStatsSystem().GetStatValue( m_weapon.GetEntityID(), gamedataStatType.AimInTime );
		}
		else
		{
			m_aimInTimeRemaining = 0.0;
			scriptInterface.GetTargetingSystem().OnAimStartEnd( scriptInterface.owner );
		}
		usingCover = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection( scriptInterface.executionOwner ) != gamePlayerCoverDirection.None;
		if( usingCover )
		{
			m_delayAimSnap = 2;
		}
		else
		{
			m_delayAimSnap = 0;
			EvaluateAimSnap( stateContext, scriptInterface );
		}
		NotifyWeaponObject( scriptInterface, true );
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var dpadAction : DPADActionPerformed;
		var weapon : WeaponObject;
		var broadcaster : StimBroadcasterComponent;
		( ( PlayerPuppet )( scriptInterface.executionOwner ) ).ReevaluateLookAtTarget();
		if( stateContext.GetBoolParameter( 'ReevaluateAiming', false ) )
		{
			scriptInterface.GetTargetingSystem().OnAimStop( scriptInterface.owner );
			OnAimStartBegin( stateContext, scriptInterface );
			return;
		}
		if( m_aimInTimeRemaining > 0.0 )
		{
			m_aimInTimeRemaining -= timeDelta;
			if( m_aimInTimeRemaining <= 0.0 )
			{
				scriptInterface.GetTargetingSystem().OnAimStartEnd( scriptInterface.owner );
			}
		}
		if( m_delayAimSnap > 0 )
		{
			m_delayAimSnap -= 1;
			if( m_delayAimSnap == 0 )
			{
				EvaluateAimSnap( stateContext, scriptInterface );
			}
		}
		UpdateAimAnimFeature( stateContext, scriptInterface );
		UpdateAimDownSightsSfx( stateContext, scriptInterface );
		UpdateZoomVfx( scriptInterface );
		if( ( ( ( ( ( m_firearmsNoUnequipNoSwitch || m_shootingRangeCompetition ) || IsInTakedownState( stateContext ) ) || ( GetSceneTier( scriptInterface ) > 2 ) ) || IsSafeStateForced( stateContext, scriptInterface ) ) || !( CheckGenericEquipItemConditions( stateContext, scriptInterface ) ) ) || IsEmptyHandsForced( stateContext, scriptInterface ) )
		{
			return;
		}
		if( !( m_weapon ) && ( scriptInterface.IsActionJustReleased( 'SwitchItem' ) || scriptInterface.IsActionJustPressed( 'RangedAttack' ) ) )
		{
			if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'OneHandedFirearms' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon );
				return;
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Melee' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon );
				return;
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Fists' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestFists );
				return;
			}
			else if( StatusEffectSystem.ObjectHasStatusEffectWithTag( scriptInterface.executionOwner, 'Firearms' ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon );
				return;
			}
			else
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon );
				return;
			}
		}
		else if( m_weapon && UpdateSwitchItem( timeDelta, stateContext, scriptInterface ) )
		{
			return;
		}
		ProcessCombatGadgetActionInputCaching( scriptInterface, stateContext );
		if( scriptInterface.IsActionJustPressed( 'UseCombatGadget' ) || stateContext.GetBoolParameter( 'cgCached', true ) )
		{
			dpadAction = new DPADActionPerformed;
			dpadAction.action = EHotkey.RB;
			if( ( ( ( ( ( ( ( IsUsingLeftHandAllowed( scriptInterface ) && !( stateContext.IsStateMachineActive( 'Consumable' ) ) ) && !( IsInUpperBodyState( stateContext, 'temporaryUnequip' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && CheckMeleeStatesForCombatGadget( scriptInterface, stateContext ) ) && ( CheckEquipmentStateMachineState( stateContext, EEquipmentSide.Right, EEquipmentState.Equipped ) || CompareSMState( 'CoverAction', 'activateCover', stateContext ) ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && !( IsInSafeZone( scriptInterface ) ) ) && !( IsInWorkspot( scriptInterface ) ) )
			{
				dpadAction.successful = true;
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
				if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Gadget ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					return;
				}
				else if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Cyberware ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					stateContext.RemovePermanentBoolParameter( 'cgCached' );
					return;
				}
			}
			else
			{
				scriptInterface.GetUISystem().QueueEvent( dpadAction );
			}
		}
		if( ( ( m_aimInTimeRemaining < 0.0 ) && !( m_aimBroadcast ) ) && ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Weapon ) != ( ( Int32 )( gamePSMRangedWeaponStates.Safe ) ) ) )
		{
			weapon = GetWeaponObject( scriptInterface );
			if( !( WeaponObject.IsFists( weapon.GetItemID() ) ) && weapon.IsRanged() )
			{
				m_aimBroadcast = true;
				broadcaster = scriptInterface.owner.GetStimBroadcasterComponent();
				if( broadcaster )
				{
					broadcaster.AddActiveStimuli( scriptInterface.owner, gamedataStimType.CrowdIllegalAction, -1.0 );
				}
			}
		}
	}

	public function PlayEffectOnHeldItems( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var leftItem : ItemObject;
		var spawnEffectEvent : entSpawnEffectEvent;
		leftItem = ( ( ItemObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponLeft" ) ) );
		spawnEffectEvent = new entSpawnEffectEvent;
		spawnEffectEvent.effectName = effectName;
		if( leftItem )
		{
			leftItem.QueueEventToChildItems( spawnEffectEvent );
		}
		if( m_weapon )
		{
			m_weapon.QueueEventToChildItems( spawnEffectEvent );
		}
	}

	protected function GetWeaponObject( scriptInterface : StateGameScriptInterface ) : WeaponObject
	{
		return ( ( WeaponObject )( scriptInterface.GetTransactionSystem().GetItemInSlot( scriptInterface.executionOwner, T"AttachmentSlots.WeaponRight" ) ) );
	}

	protected function EvaluateAimSnap( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var perfectAimSnapParams : AimRequest;
		var weaponRecData : WeaponItem_Record;
		var isInvalidMeleeWeapon : Bool;
		var aimSnapEnabledInSetting : Bool;
		var itemType : gamedataItemType;
		var player : PlayerPuppet;
		aimSnapEnabledInSetting = true;
		weaponRecData = m_weapon.GetWeaponRecord();
		itemType = weaponRecData.ItemType().Type();
		isInvalidMeleeWeapon = m_weapon.IsMelee() && itemType != gamedataItemType.Cyb_NanoWires;
		if( !( isInvalidMeleeWeapon ) && weaponRecData.Evolution().Type() != gamedataWeaponEvolution.Smart )
		{
			if( m_weapon.IsRanged() )
			{
				player = ( ( PlayerPuppet )( scriptInterface.executionOwner ) );
				aimSnapEnabledInSetting = player.IsAimSnapEnabled();
			}
			if( aimSnapEnabledInSetting )
			{
				if( m_weaponHasPerfectAim )
				{
					perfectAimSnapParams = GetPerfectAimSnapParams();
					scriptInterface.GetTargetingSystem().LookAt( scriptInterface.owner, perfectAimSnapParams );
				}
				else
				{
					scriptInterface.GetTargetingSystem().AimSnap( scriptInterface.owner );
				}
			}
		}
	}

	protected function GetVehicleAimSnapParams() : AimRequest
	{
		var aimSnapParams : AimRequest;
		aimSnapParams.duration = 0.25;
		aimSnapParams.adjustPitch = true;
		aimSnapParams.adjustYaw = true;
		aimSnapParams.endOnTargetReached = false;
		aimSnapParams.endOnCameraInputApplied = true;
		aimSnapParams.endOnTimeExceeded = false;
		aimSnapParams.cameraInputMagToBreak = 0.5;
		aimSnapParams.precision = 0.1;
		aimSnapParams.maxDuration = 0.0;
		aimSnapParams.easeIn = true;
		aimSnapParams.easeOut = true;
		aimSnapParams.checkRange = true;
		aimSnapParams.processAsInput = true;
		return aimSnapParams;
	}

	protected function GetPerfectAimSnapParams() : AimRequest
	{
		var aimSnapParams : AimRequest;
		aimSnapParams.duration = 0.25;
		aimSnapParams.adjustPitch = true;
		aimSnapParams.adjustYaw = true;
		aimSnapParams.endOnAimingStopped = true;
		aimSnapParams.precision = 0.1;
		aimSnapParams.easeIn = true;
		aimSnapParams.easeOut = true;
		aimSnapParams.checkRange = true;
		aimSnapParams.processAsInput = true;
		aimSnapParams.bodyPartsTracking = true;
		aimSnapParams.bptMaxDot = 0.5;
		aimSnapParams.bptMaxSwitches = -1.0;
		aimSnapParams.bptMinInputMag = 0.5;
		aimSnapParams.bptMinResetInputMag = 0.1;
		return aimSnapParams;
	}

	protected function UpdateAimAnimFeature( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var stats : StatsSystem;
		if( stateContext.GetBoolParameter( 'WeaponInSafe', true ) && !( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced ) ) )
		{
			m_aim.SetAimState( animAimState.Unaimed );
		}
		else
		{
			m_aim.SetAimState( animAimState.Aimed );
		}
		stats = scriptInterface.GetStatsSystem();
		m_aim.SetZoomState( animAimState.Aimed );
		m_aim.SetAimInTime( stats.GetStatValue( m_weapon.GetEntityID(), gamedataStatType.AimInTime ) );
		m_aim.SetAimOutTime( stats.GetStatValue( m_weapon.GetEntityID(), gamedataStatType.AimOutTime ) );
		scriptInterface.SetAnimationParameterFeature( 'AnimFeature_AimPlayer', m_aim );
		scriptInterface.SetAnimationParameterFeature( 'AnimFeature_AimPlayer', m_aim, m_weapon );
	}

	protected function UpdateAimDownSightsSfx( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		if( stateContext.GetBoolParameter( 'WeaponInSafe', true ) )
		{
			if( m_isAiming )
			{
				m_isAiming = false;
				ToggleAudioAimDownSights( m_weapon, m_isAiming );
			}
		}
		else
		{
			if( !( m_isAiming ) )
			{
				m_isAiming = true;
				ToggleAudioAimDownSights( m_weapon, m_isAiming );
			}
		}
	}

	protected function UpdateZoomVfx( scriptInterface : StateGameScriptInterface )
	{
		if( m_finalZoomLevel >= 2.0 )
		{
			StartZoomEffect( scriptInterface, 'zoom' );
		}
		else
		{
			BreakEffectLoop( scriptInterface, 'zoom' );
		}
	}

	protected function StartZoomEffect( scriptInterface : StateGameScriptInterface, effectName : CName )
	{
		var blackboard : worldEffectBlackboard;
		var maxZoom : Float;
		var normalizedZoom : Float;
		maxZoom = GetStaticFloatParameterDefault( ( "noWeaponZoomLevel" + "" ) + m_numZoomLevels, 1.0 );
		normalizedZoom = m_finalZoomLevel / maxZoom;
		blackboard = new worldEffectBlackboard;
		blackboard.SetValue( 'zoomValue', normalizedZoom );
		GameObjectEffectHelper.StartEffectEvent( scriptInterface.owner, 'zoom', false, blackboard );
	}

	protected function UpdateWeaponOffsetPosition( scriptInterface : StateGameScriptInterface )
	{
		var stats : StatsSystem;
		var addedPosition : Vector3;
		stats = scriptInterface.GetStatsSystem();
		m_posAnimFeature.isEnabled = m_weapon.GetWeaponRecord().IsIKEnabled();
		m_posAnimFeature.hasScope = m_weapon.HasScope();
		if( m_posAnimFeature.hasScope )
		{
			m_posAnimFeature.position = m_weapon.GetScopeOffset();
		}
		else
		{
			m_posAnimFeature.position = m_weapon.GetIronSightOffset();
		}
		addedPosition = m_weapon.GetWeaponRecord().IkOffset();
		m_posAnimFeature.position += Vector4.Vector3To4( addedPosition );
		m_posAnimFeature.offset = stats.GetStatValue( m_weapon.GetEntityID(), gamedataStatType.AimOffset );
		m_posAnimFeature.scopeOffset = stats.GetStatValue( m_weapon.GetEntityID(), gamedataStatType.ScopeOffset );
		scriptInterface.SetAnimationParameterFeature( 'ProceduralIronsightData', m_posAnimFeature );
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var weapon : WeaponObject;
		var broadcaster : StimBroadcasterComponent;
		super.OnExit( stateContext, scriptInterface );
		weapon = GetWeaponObject( scriptInterface );
		m_aim.SetAimState( animAimState.Unaimed );
		m_aim.SetZoomState( animAimState.Unaimed );
		m_isAiming = false;
		scriptInterface.SetAnimationParameterFeature( 'AnimFeature_AimPlayer', m_aim );
		scriptInterface.SetAnimationParameterFeature( 'AnimFeature_AimPlayer', m_aim, weapon );
		if( !( stateContext.GetBoolParameter( 'WeaponInSafe', true ) ) )
		{
			TriggerZoomExitSfx( scriptInterface );
		}
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.Default ) ) );
		scriptInterface.GetTargetingSystem().OnAimStop( scriptInterface.owner );
		BreakEffectLoopOnHeldItems( scriptInterface, 'lightswitch' );
		broadcaster = scriptInterface.owner.GetStimBroadcasterComponent();
		if( broadcaster )
		{
			m_aimBroadcast = false;
			broadcaster.RemoveActiveStimuliByName( scriptInterface.owner, gamedataStimType.CrowdIllegalAction );
		}
		NotifyWeaponObject( scriptInterface, false );
	}

	protected function TriggerZoomExitSfx( scriptInterface : StateGameScriptInterface )
	{
		ToggleAudioAimDownSights( GetActiveWeapon( scriptInterface ), m_isAiming );
	}

	protected function NotifyWeaponObject( scriptInterface : StateGameScriptInterface, isAiming : Bool )
	{
		var weapon : WeaponObject;
		var evt : gameweaponeventsOwnerAimEvent;
		weapon = GetWeaponObject( scriptInterface );
		if( weapon )
		{
			evt = new gameweaponeventsOwnerAimEvent;
			evt.isAiming = isAiming;
			weapon.QueueEvent( evt );
		}
	}

}

class TemporaryUnequipDecisions extends UpperBodyTransition
{

	protected const function IsTemporaryUnequipRequested( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var locomotionDetailedState : Int32;
		if( stateContext.GetBoolParameter( 'forcedTemporaryUnequip', true ) || stateContext.GetBoolParameter( 'forceTempUnequipWeapon', true ) )
		{
			return true;
		}
		if( GetLocomotionState( stateContext ) == 'workspot' )
		{
			if( GetPlayerPuppet( scriptInterface ).HasWorkspotTag( 'Grab' ) )
			{
				return true;
			}
		}
		locomotionDetailedState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed );
		if( ( ( ( ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.Climb ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.Ladder ) ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.LadderSprint ) ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.LadderSlide ) ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.VeryHardLand ) ) ) )
		{
			return true;
		}
		if( IsInHighLevelState( stateContext, 'swimming' ) )
		{
			return true;
		}
		if( ( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice ) || scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice ) ) || scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice ) )
		{
			return true;
		}
		if( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vitals ) == ( ( Int32 )( gamePSMVitals.Dead ) ) ) || ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.Vitals ) == ( ( Int32 )( gamePSMVitals.Resurrecting ) ) ) )
		{
			return true;
		}
		return false;
	}

	protected export const virtual function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return IsTemporaryUnequipRequested( stateContext, scriptInterface );
	}

	protected export const virtual function ToWaitForEquip( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( ( IsTemporaryUnequipRequested( stateContext, scriptInterface ) || stateContext.GetBoolParameter( 'cgCached', true ) ) || ( ( scriptInterface.GetActionValue( 'UseCombatGadget' ) != 0.0 ) && !( stateContext.GetBoolParameter( 'invalidTempUnequipThrow', true ) ) ) ) || !( stateContext.GetConditionBool( 'TemporaryUnequipHasUnequippedWeapon' ) ) )
		{
			if( !( stateContext.GetBoolParameter( 'ChargeCancelled', true ) ) )
			{
				return false;
			}
		}
		if( IsInLocomotionState( stateContext, 'knockdown' ) || StatusEffectSystem.ObjectHasStatusEffectOfType( scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown ) )
		{
			return false;
		}
		return !( GetItemInRightHandSlot( scriptInterface ) );
	}

	protected export const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( stateContext.GetBoolParameter( 'cgCached', true ) || ( ( scriptInterface.GetActionValue( 'UseCombatGadget' ) != 0.0 ) && !( stateContext.GetBoolParameter( 'invalidTempUnequipThrow', true ) ) ) ) || IsTemporaryUnequipRequested( stateContext, scriptInterface ) )
		{
			if( !( stateContext.GetBoolParameter( 'ChargeCancelled', true ) ) )
			{
				return false;
			}
		}
		return !( stateContext.GetConditionBool( 'TemporaryUnequipHasUnequippedWeapon' ) );
	}

	protected export const function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( stateContext.GetBoolParameter( 'cgCached', true ) || ( ( scriptInterface.GetActionValue( 'UseCombatGadget' ) != 0.0 ) && !( stateContext.GetBoolParameter( 'invalidTempUnequipThrow', true ) ) ) )
		{
			if( !( stateContext.GetBoolParameter( 'ChargeCancelled', true ) ) )
			{
				return false;
			}
		}
		return !( IsTemporaryUnequipRequested( stateContext, scriptInterface ) ) && GetItemInRightHandSlot( scriptInterface );
	}

}

class TemporaryUnequipEvents extends UpperBodyEventsTransition
{
	private var m_forceOpen : Bool;

	protected export override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var equipAnimType : gameEquipAnimationType;
		var locomotionDetailedState : Int32;
		var isInInstantEquipPSMState : Bool;
		m_forceOpen = false;
		ResetEquipVars( stateContext );
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.TemporaryUnequip ) ) );
		if( !( IsRightHandInUnequippedState( stateContext ) ) || !( IsLeftHandInUnequippedState( stateContext ) ) )
		{
			equipAnimType = gameEquipAnimationType.Instant;
			locomotionDetailedState = scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed );
			isInInstantEquipPSMState = ( ( ( ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.Climb ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.Ladder ) ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.LadderSprint ) ) ) ) || ( locomotionDetailedState == ( ( Int32 )( gamePSMDetailedLocomotionStates.LadderSlide ) ) ) ) || ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.HighLevel ) == ( ( Int32 )( gamePSMHighLevel.Swimming ) ) );
			if( isInInstantEquipPSMState || stateContext.GetBoolParameter( 'forcedTemporaryUnequip', true ) )
			{
				equipAnimType = gameEquipAnimationType.Instant;
			}
			else
			{
				equipAnimType = gameEquipAnimationType.Default;
			}
			if( stateContext.GetBoolParameter( 'forceTempUnequipWeapon', true ) )
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipWeapon, equipAnimType );
			}
			else
			{
				SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.UnequipAll, equipAnimType );
			}
			stateContext.SetConditionBoolParameter( 'TemporaryUnequipHasUnequippedWeapon', true, true );
		}
		else
		{
			stateContext.SetConditionBoolParameter( 'TemporaryUnequipHasUnequippedWeapon', false, true );
			stateContext.RemovePermanentBoolParameter( 'ChargeCancelled' );
		}
	}

	protected export function OnUpdate( timeDelta : Float, stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var locomotionState : CName;
		if( scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsForceOpeningDoor ) )
		{
			if( !( m_forceOpen ) )
			{
				ForceEquipStrongArms( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ) );
			}
			stateContext.SetPermanentBoolParameter( 'invalidTempUnequipThrow', true, true );
			return;
		}
		locomotionState = GetLocomotionState( stateContext );
		if( ( ( ( ( ( ( ( ( ( ( ( locomotionState == 'climb' || locomotionState == 'ladder' ) || locomotionState == 'ladderSprint' ) || locomotionState == 'ladderSlide' ) || locomotionState == 'veryHardLand' ) || locomotionState == 'knockdown' ) || locomotionState == 'vehicleKnockdown' ) || locomotionState == 'forcedKnockdown' ) || IsInHighLevelState( stateContext, 'swimming' ) ) || IsInTakedownState( stateContext ) ) || scriptInterface.localBlackboard.GetBool( GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice ) ) || StatusEffectSystem.ObjectHasStatusEffectOfType( scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown ) ) || stateContext.IsStateMachineActive( 'LeftHandCyberware' ) )
		{
			stateContext.SetPermanentBoolParameter( 'invalidTempUnequipThrow', true, true );
			return;
		}
		ProcessCombatGadgetActionInputCaching( scriptInterface, stateContext );
		if( ( GetCancelChargeButtonInput( scriptInterface ) && ( ( scriptInterface.localBlackboard.GetInt( GetAllBlackboardDefs().PlayerStateMachine.CombatGadget ) == ( ( Int32 )( gamePSMCombatGadget.Charging ) ) ) && stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) || stateContext.IsStateMachineActive( 'LeftHandCyberware' ) )
		{
			stateContext.SetPermanentBoolParameter( 'ChargeCancelled', true, true );
		}
		else if( ( stateContext.GetBoolParameter( 'ChargeCancelled', true ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( stateContext.IsStateMachineActive( 'LeftHandCyberware' ) ) )
		{
			stateContext.RemovePermanentBoolParameter( 'ChargeCancelled' );
		}
		if( ( scriptInterface.IsActionJustPressed( 'UseCombatGadget' ) || stateContext.GetBoolParameter( 'cgCached', true ) ) && IsLeftHandInUnequippedState( stateContext ) )
		{
			if( ( ( ( ( IsUsingLeftHandAllowed( scriptInterface ) && !( stateContext.IsStateMachineActive( 'Consumable' ) ) ) && !( IsInUpperBodyState( stateContext, 'forceEmptyHands' ) ) ) && !( AreChoiceHubsActive( scriptInterface ) ) ) && !( IsInSafeZone( scriptInterface ) ) ) && !( IsInWorkspot( scriptInterface ) ) )
			{
				if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Gadget ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					stateContext.SetPermanentBoolParameter( 'forceTempUnequipWeapon', true, true );
					stateContext.SetPermanentBoolParameter( 'gadgetRequested', true, true );
				}
				else if( CheckItemCategoryInQuickWheel( scriptInterface, gamedataItemCategory.Cyberware ) )
				{
					SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.RequestGadget );
					stateContext.RemovePermanentBoolParameter( 'cgCached' );
					stateContext.SetPermanentBoolParameter( 'gadgetRequested', true, true );
				}
			}
		}
		if( ( ( ( stateContext.GetBoolParameter( 'gadgetRequested', true ) && ( scriptInterface.GetActionValue( 'UseCombatGadget' ) == 0.0 ) ) && !( stateContext.GetBoolParameter( 'cgCached', true ) ) ) && !( stateContext.IsStateMachineActive( 'CombatGadget' ) ) ) && !( stateContext.IsStateMachineActive( 'LeftHandCyberware' ) ) )
		{
			stateContext.RemovePermanentBoolParameter( 'forceTempUnequipWeapon' );
		}
	}

	protected export override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SetBlackboardIntVariable( scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, ( ( Int32 )( gamePSMUpperBodyStates.Default ) ) );
		if( m_forceOpen )
		{
			ForceUnequipStrongArms( ( ( PlayerPuppet )( scriptInterface.executionOwner ) ) );
		}
		stateContext.RemovePermanentBoolParameter( 'ChargeCancelled' );
		stateContext.RemovePermanentBoolParameter( 'invalidTempUnequipThrow' );
		stateContext.RemovePermanentBoolParameter( 'gadgetRequested' );
	}

	protected function ForceEquipStrongArms( player : PlayerPuppet )
	{
		if( RPGManager.ForceEquipStrongArms( player ) )
		{
			m_forceOpen = true;
		}
	}

	protected function ForceUnequipStrongArms( player : PlayerPuppet )
	{
		RPGManager.ForceUnequipStrongArms( player );
	}

}

class WaitForEquipDecisions extends UpperBodyTransition
{

	protected const virtual function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetActiveWeapon( scriptInterface );
	}

	protected const function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return GetInStateTime() > 2.0;
	}

}

class WaitForEquipEvents extends UpperBodyEventsTransition
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		SendEquipmentSystemWeaponManipulationRequest( scriptInterface, EquipmentManipulationAction.ReequipWeapon );
	}

}

class AdHocAnimationDecisions extends UpperBodyEventsTransition
{

	protected export const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var blackboardSystem : BlackboardSystem;
		var blackboard : IBlackboard;
		blackboardSystem = scriptInterface.GetBlackboardSystem();
		blackboard = blackboardSystem.Get( GetAllBlackboardDefs().AdHocAnimation );
		if( blackboard.GetBool( GetAllBlackboardDefs().AdHocAnimation.IsActive ) )
		{
			return true;
		}
		return false;
	}

	protected const virtual function ToSingleWield( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( GetInStateTime() > GetStaticFloatParameterDefault( "animDuration", 2.0 ) ) && HasRightWeaponEquipped( scriptInterface ) )
		{
			return true;
		}
		return false;
	}

	protected const virtual function ToEmptyHands( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		if( ( GetInStateTime() > GetStaticFloatParameterDefault( "animDuration", 2.0 ) ) && !( HasRightWeaponEquipped( scriptInterface ) ) )
		{
			return true;
		}
		return false;
	}

}

class AdHocAnimationEvents extends TemporaryUnequipEvents
{

	protected override function OnEnter( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var adHocFeature : AnimFeature_AdHocAnimation;
		var blackboardSystem : BlackboardSystem;
		var blackboard : IBlackboard;
		blackboardSystem = scriptInterface.GetBlackboardSystem();
		blackboard = blackboardSystem.Get( GetAllBlackboardDefs().AdHocAnimation );
		adHocFeature = new AnimFeature_AdHocAnimation;
		adHocFeature.useBothHands = true;
		adHocFeature.isActive = true;
		adHocFeature.animationIndex = blackboard.GetInt( GetAllBlackboardDefs().AdHocAnimation.AnimationIndex );
		if( !( blackboard.GetBool( GetAllBlackboardDefs().AdHocAnimation.UseBothHands ) ) )
		{
			adHocFeature.useBothHands = false;
		}
		if( blackboard.GetBool( GetAllBlackboardDefs().AdHocAnimation.UnequipWeapon ) )
		{
			super.OnEnter( stateContext, scriptInterface );
		}
		scriptInterface.SetAnimationParameterFeature( 'AdHoc', adHocFeature );
	}

	protected override function OnExit( stateContext : StateContext, scriptInterface : StateGameScriptInterface )
	{
		var adHocFeature : AnimFeature_AdHocAnimation;
		var blackboardSystem : BlackboardSystem;
		var blackboard : IBlackboard;
		blackboardSystem = scriptInterface.GetBlackboardSystem();
		blackboard = blackboardSystem.Get( GetAllBlackboardDefs().AdHocAnimation );
		if( blackboard.GetBool( GetAllBlackboardDefs().AdHocAnimation.UnequipWeapon ) )
		{
			super.OnExit( stateContext, scriptInterface );
		}
		adHocFeature = new AnimFeature_AdHocAnimation;
		adHocFeature.isActive = false;
		scriptInterface.SetAnimationParameterFeature( 'AdHoc', adHocFeature );
		blackboard.SetBool( GetAllBlackboardDefs().AdHocAnimation.IsActive, false );
	}

}

