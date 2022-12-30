import class GameObject extends GameEntity
{
	[ category = "HUD Manager" ]
	protected instanceeditable var m_forceRegisterInHudManager : Bool;
	protected var m_prereqListeners : array< GameObjectListener >;
	protected var m_statusEffectListeners : array< StatusEffectTriggerListener >;
	private var m_lastEngineTime : Float;
	private var m_accumulatedTimePasssed : Float;
	protected var m_scanningComponent : ScanningComponent;
	protected var m_visionComponent : VisionModeComponent;
	protected var m_isHighlightedInFocusMode : Bool;
	protected var m_statusEffectComponent : StatusEffectComponent;
	protected var m_markAsQuest : Bool;
	private var m_e3ObjectRevealed : Bool;
	protected var m_workspotMapper : WorkspotMapperComponent;
	protected var m_stimBroadcaster : StimBroadcasterComponent;
	protected import var uiSlotComponent : SlotComponent;
	protected var m_squadMemberComponent : SquadMemberBaseComponent;
	private var m_sourceShootComponent : SourceShootComponent;
	private var m_targetShootComponent : TargetShootComponent;
	protected var m_receivedDamageHistory : array< DamageHistoryEntry >;
	protected var m_forceDefeatReward : Bool;
	default m_forceDefeatReward = false;
	protected var m_killRewardDisabled : Bool;
	default m_killRewardDisabled = false;
	protected var m_willDieSoon : Bool;
	default m_willDieSoon = false;
	private var m_isScannerDataDirty : Bool;
	private var m_hasVisibilityForcedInAnimSystem : Bool;
	protected var m_isDead : Bool;
	private var m_lastHitInstigatorID : EntityID;
	private var m_hitInstigatorCooldownID : DelayID;

	public import const final function GetName() : CName;
	public import const final function GetGame() : GameInstance;
	public import final function RegisterInputListener( listener : IScriptable, optional name : CName );
	public import final function RegisterInputListenerWithOwner( listener : IScriptable, name : CName );
	public import final function UnregisterInputListener( listener : IScriptable, optional name : CName );
	public import final function GetCurveValue( out x : Float, out y : Float, curveName : CName, isDebug : Bool );
	public import const final function IsSelectedForDebugging() : Bool;
	public import final function GetTracedActionName() : String;
	public import const final function IsPlayerControlled() : Bool;
	public import function GetOwner() : weak< GameObject >;
	public import const final function GetCurrentContext() : CName;
	public import const final function PlayerLastUsedPad() : Bool;
	public import const final function PlayerLastUsedKBM() : Bool;
	public import final function TriggerEvent( eventName : CName, optional data : IScriptable, optional flags : Int32 ) : Bool;
	protected import const virtual function GetPS() : GameObjectPS;
	protected import const function GetBasePS() : GameObjectPS;
	public import const final function HasTag( tag : CName ) : Bool;
	protected import final function EnableTransformUpdates( enable : Bool );

	protected function RegisterToHUDManagerByTask( shouldRegister : Bool )
	{
		var data : HUDManagerRegistrationTaskData;
		data = new HUDManagerRegistrationTaskData;
		data.shouldRegister = shouldRegister;
		GameInstance.GetDelaySystem( GetGame() ).QueueTask( this, data, 'RegisterToHUDManagerTask', gameScriptTaskExecutionStage.Any );
	}

	protected export function RegisterToHUDManagerTask( data : ScriptTaskData )
	{
		var registrationTaskData : HUDManagerRegistrationTaskData;
		registrationTaskData = ( ( HUDManagerRegistrationTaskData )( data ) );
		if( !( registrationTaskData ) )
		{
			return;
		}
		RegisterToHUDManager( registrationTaskData.shouldRegister );
	}

	protected function RegisterToHUDManager( shouldRegister : Bool )
	{
		var register : HUDManagerRegistrationRequest;
		register = new HUDManagerRegistrationRequest;
		register.SetProperties( this, shouldRegister );
		GameInstance.QueueScriptableSystemRequest( GetGame(), 'HUDManager', register );
	}

	protected function HandleDeathByTask( instigator : weak< GameObject > )
	{
		var data : DeathTaskData;
		data = new DeathTaskData;
		data.instigator = instigator;
		GameInstance.GetDelaySystem( GetGame() ).QueueTask( this, data, 'HandleDeathTask', gameScriptTaskExecutionStage.PostPhysics );
	}

	protected export function HandleDeathTask( data : ScriptTaskData )
	{
		var deathData : DeathTaskData;
		deathData = ( ( DeathTaskData )( data ) );
		if( deathData )
		{
			HandleDeath( deathData.instigator );
		}
	}

	protected virtual function HandleDeath( instigator : weak< GameObject > ) {}

	protected event OnDeviceLinkRequest( evt : DeviceLinkRequest )
	{
		var link : DeviceLinkComponentPS;
		link = DeviceLinkComponentPS.CreateAndAcquireDeviceLink( GetGame(), GetEntityID() );
		if( link )
		{
			GameInstance.GetPersistencySystem( GetGame() ).QueuePSEvent( link.GetID(), link.GetClassName(), evt );
		}
	}

	public const virtual function GetDeviceLink() : DeviceLinkComponentPS
	{
		return DeviceLinkComponentPS.AcquireDeviceLink( GetGame(), GetEntityID() );
	}

	protected virtual function OnTransformUpdated();

	public const final function GetPersistentID() : PersistentID
	{
		return GetEntityID();
	}

	public const function GetPSOwnerData() : PSOwnerData
	{
		var psOwnerData : PSOwnerData;
		psOwnerData.id = GetPersistentID();
		psOwnerData.className = GetClassName();
		return psOwnerData;
	}

	public const virtual function GetPSClassName() : CName
	{
		return GetPS().GetClassName();
	}

	protected virtual function SendEventToDefaultPS( evt : Event )
	{
		var persistentState : GameObjectPS;
		persistentState = GetPS();
		if( persistentState == NULL )
		{
			if( !( IsFinal() ) )
			{
				LogError( "[SendEventToDefaultPS] Unable to send event, there is no presistent state on that entity " + ( ( String )( GetEntityID() ) ) );
			}
			return;
		}
		GameInstance.GetPersistencySystem( GetGame() ).QueuePSEvent( persistentState.GetID(), persistentState.GetClassName(), evt );
	}

	public const virtual function IsConnectedToSecuritySystem() : Bool
	{
		return false;
	}

	public const virtual function GetSecuritySystem() : SecuritySystemControllerPS
	{
		return NULL;
	}

	public const virtual function IsTargetTresspassingMyZone( target : GameObject ) : Bool
	{
		return false;
	}

	public static function AddListener( obj : GameObject, listener : GameObjectListener )
	{
		var evt : AddOrRemoveListenerForGOEvent;
		evt = new AddOrRemoveListenerForGOEvent;
		evt.listener = listener;
		evt.shouldAdd = true;
		obj.QueueEvent( evt );
	}

	public static function RemoveListener( obj : GameObject, listener : GameObjectListener )
	{
		var evt : AddOrRemoveListenerForGOEvent;
		evt = new AddOrRemoveListenerForGOEvent;
		evt.listener = listener;
		evt.shouldAdd = false;
		obj.QueueEvent( evt );
	}

	protected event OnAddOrRemoveListenerForGameObject( evt : AddOrRemoveListenerForGOEvent )
	{
		if( evt.shouldAdd )
		{
			m_prereqListeners.PushBack( evt.listener );
		}
		else
		{
			m_prereqListeners.Remove( evt.listener );
		}
	}

	public static function AddStatusEffectTriggerListener( target : GameObject, listener : StatusEffectTriggerListener )
	{
		var evt : AddStatusEffectListenerEvent;
		evt = new AddStatusEffectListenerEvent;
		evt.listener = listener;
		target.QueueEvent( evt );
	}

	public static function RemoveStatusEffectTriggerListener( target : GameObject, listener : StatusEffectTriggerListener )
	{
		var evt : RemoveStatusEffectListenerEvent;
		evt = new RemoveStatusEffectListenerEvent;
		evt.listener = listener;
		target.QueueEvent( evt );
	}

	protected event OnAddStatusEffectTriggerListener( evt : AddStatusEffectListenerEvent )
	{
		m_statusEffectListeners.PushBack( evt.listener );
	}

	protected event OnRemoveStatusEffectTriggerListener( evt : RemoveStatusEffectListenerEvent )
	{
		m_statusEffectListeners.Remove( evt.listener );
		GameInstance.GetStatPoolsSystem( GetGame() ).RequestUnregisteringListener( GetEntityID(), evt.listener.m_statPoolType, evt.listener );
	}

	public import const function GetDisplayName() : String;

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		EntityRequestComponentsInterface.RequestComponent( ri, 'vision', 'gameVisionModeComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'scanning', 'gameScanningComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'workspotMapper', 'WorkspotMapperComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'StimBroadcaster', 'StimBroadcasterComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'SquadMember', 'SquadMemberBaseComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'StatusEffect', 'gameStatusEffectComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'sourceShootComponent', 'gameSourceShootComponent', false );
		EntityRequestComponentsInterface.RequestComponent( ri, 'targetShootComponent', 'gameTargetShootComponent', false );
	}

	protected event OnTakeControl( ri : EntityResolveComponentsInterface )
	{
		m_scanningComponent = ( ( ScanningComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'scanning' ) ) );
		m_visionComponent = ( ( VisionModeComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'vision' ) ) );
		m_workspotMapper = ( ( WorkspotMapperComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'workspotMapper' ) ) );
		m_stimBroadcaster = ( ( StimBroadcasterComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'StimBroadcaster' ) ) );
		m_squadMemberComponent = ( ( SquadMemberBaseComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'SquadMember' ) ) );
		m_statusEffectComponent = ( ( StatusEffectComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'StatusEffect' ) ) );
		m_sourceShootComponent = ( ( SourceShootComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'sourceShootComponent' ) ) );
		m_targetShootComponent = ( ( TargetShootComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'targetShootComponent' ) ) );
	}

	protected event OnPostInitialize( evt : entPostInitializeEvent )
	{
		if( ShouldRegisterToHUD() )
		{
			RegisterToHUDManager( true );
			RestoreRevealState();
			if( IsTaggedinFocusMode() )
			{
				TagObject( this );
			}
		}
	}

	protected event OnPreUninitialize( evt : entPreUninitializeEvent )
	{
		if( ShouldRegisterToHUD() )
		{
			RegisterToHUDManager( false );
		}
	}

	protected event OnGameAttached()
	{
		var evt : GameAttachedEvent;
		evt = new GameAttachedEvent;
		evt.isGameplayRelevant = IsGameplayRelevant();
		evt.displayName = GetDisplayName();
		evt.contentScale = GetContentScale();
		if( ShouldSendGameAttachedEventToPS() )
		{
			SendEventToDefaultPS( evt );
		}
	}

	protected event OnDetach()
	{
		if( m_hasVisibilityForcedInAnimSystem )
		{
			ClearForcedVisibilityInAnimSystem();
		}
	}

	public const function ShouldForceRegisterInHUDManager() : Bool
	{
		return m_forceRegisterInHudManager;
	}

	public const virtual function ShouldRegisterToHUD() : Bool
	{
		if( ( ( m_forceRegisterInHudManager || HasAnyClue() ) || IsQuest() ) || ( m_visionComponent && m_visionComponent.HasStaticDefaultHighlight() ) )
		{
			return true;
		}
		return false;
	}

	protected function RequestHUDRefresh( optional updateData : HUDActorUpdateData )
	{
		var request : RefreshActorRequest;
		request = RefreshActorRequest.Construct( GetEntityID(), updateData );
		GetHudManager().QueueRequest( request );
	}

	protected function RequestHUDRefresh( targetID : EntityID, optional updateData : HUDActorUpdateData )
	{
		var request : RefreshActorRequest;
		request = RefreshActorRequest.Construct( targetID, updateData );
		GetHudManager().QueueRequest( request );
	}

	public const function CanScanThroughWalls() : Bool
	{
		var statValue : Float;
		var player : PlayerPuppet;
		player = GetPlayer( GetGame() );
		if( player )
		{
			if( player.HasAutoReveal() )
			{
				return true;
			}
			statValue = GameInstance.GetStatsSystem( GetGame() ).GetStatValue( player.GetEntityID(), gamedataStatType.AutoReveal );
		}
		return statValue > 0.0;
	}

	public const function IsScannerDataDirty() : Bool
	{
		return m_isScannerDataDirty;
	}

	public function SetScannerDirty( dirty : Bool )
	{
		m_isScannerDataDirty = dirty;
	}

	public const virtual function CanRevealRemoteActionsWheel() : Bool
	{
		return false;
	}

	public const virtual function IsInitialized() : Bool
	{
		return true;
	}

	public const virtual function ShouldReactToTarget( targetID : EntityID ) : Bool
	{
		return false;
	}

	public const virtual function GetSensesComponent() : SenseComponent
	{
		return NULL;
	}

	public export const virtual function GetAttitudeAgent() : AttitudeAgent
	{
		return NULL;
	}

	public const virtual function GetScannerAttitudeTweak() : TweakDBID
	{
		var attitude : EAIAttitude;
		var playerPuppet : PlayerPuppet;
		var recordID : TweakDBID;
		playerPuppet = ( ( PlayerPuppet )( GameInstance.GetPlayerSystem( GetGame() ).GetLocalPlayerMainGameObject() ) );
		attitude = GetAttitudeTowards( playerPuppet );
		switch( attitude )
		{
			case EAIAttitude.AIA_Friendly:
				recordID = T"scanning_devices.attitude_friendly";
			break;
			case EAIAttitude.AIA_Neutral:
				recordID = T"scanning_devices.attitude_neutral";
			break;
			case EAIAttitude.AIA_Hostile:
				recordID = T"scanning_devices.attitude_hostile";
			break;
		}
		return recordID;
	}

	public static function GetAttitudeTowards( const first : GameObject, const second : GameObject ) : EAIAttitude
	{
		var fa, fb : AttitudeAgent;
		if( ( first == NULL ) || ( second == NULL ) )
		{
			return EAIAttitude.AIA_Neutral;
		}
		fa = first.GetAttitudeAgent();
		fb = second.GetAttitudeAgent();
		if( ( fa != NULL ) && ( fb != NULL ) )
		{
			return fa.GetAttitudeTowards( fb );
		}
		else
		{
			return EAIAttitude.AIA_Neutral;
		}
	}

	public const function GetAttitudeTowards( target : GameObject ) : EAIAttitude
	{
		var fa, fb : AttitudeAgent;
		fa = this.GetAttitudeAgent();
		if( target )
		{
			fb = target.GetAttitudeAgent();
		}
		if( ( fa != NULL ) && ( fb != NULL ) )
		{
			return fa.GetAttitudeTowards( fb );
		}
		else
		{
			return EAIAttitude.AIA_Neutral;
		}
	}

	public static function GetAttitudeBetween( first : GameObject, second : GameObject ) : EAIAttitude
	{
		return GameObject.GetAttitudeTowards( first, second );
	}

	public static function IsFriendlyTowardsPlayer( obj : weak< GameObject > ) : Bool
	{
		if( !( obj ) )
		{
			return false;
		}
		if( GameObject.GetAttitudeTowards( obj, GameInstance.GetPlayerSystem( obj.GetGame() ).GetLocalPlayerMainGameObject() ) == EAIAttitude.AIA_Friendly )
		{
			return true;
		}
		if( GameObject.GetAttitudeTowards( obj, GameInstance.GetPlayerSystem( obj.GetGame() ).GetLocalPlayerControlledGameObject() ) == EAIAttitude.AIA_Friendly )
		{
			return true;
		}
		return false;
	}

	public const function HasAttitude( attitude : EAIAttitude ) : Bool
	{
		var playerPuppet : PlayerPuppet;
		playerPuppet = ( ( PlayerPuppet )( GameInstance.GetPlayerSystem( GetGame() ).GetLocalPlayerMainGameObject() ) );
		return GetAttitudeTowards( playerPuppet ) == attitude;
	}

	public const function IsHostile() : Bool
	{
		return HasAttitude( EAIAttitude.AIA_Hostile );
	}

	public const function IsNeutral() : Bool
	{
		return HasAttitude( EAIAttitude.AIA_Neutral );
	}

	public static function ChangeAttitudeToHostile( owner : weak< GameObject >, target : weak< GameObject > )
	{
		var attitudeOwner : AttitudeAgent;
		var attitudeTarget : AttitudeAgent;
		if( !( owner ) || !( target ) )
		{
			return;
		}
		attitudeOwner = owner.GetAttitudeAgent();
		attitudeTarget = target.GetAttitudeAgent();
		if( !( attitudeOwner ) || !( attitudeTarget ) )
		{
			return;
		}
		if( attitudeOwner.GetAttitudeTowards( attitudeTarget ) != EAIAttitude.AIA_Hostile )
		{
			attitudeOwner.SetAttitudeTowards( attitudeTarget, EAIAttitude.AIA_Hostile );
		}
	}

	public static function ChangeAttitudeToNeutral( owner : weak< GameObject >, target : weak< GameObject > )
	{
		var attitudeOwner : AttitudeAgent;
		var attitudeTarget : AttitudeAgent;
		if( !( owner ) || !( target ) )
		{
			return;
		}
		attitudeOwner = owner.GetAttitudeAgent();
		attitudeTarget = target.GetAttitudeAgent();
		if( !( attitudeOwner ) || !( attitudeTarget ) )
		{
			return;
		}
		if( attitudeOwner.GetAttitudeTowards( attitudeTarget ) != EAIAttitude.AIA_Neutral )
		{
			attitudeOwner.SetAttitudeTowards( attitudeTarget, EAIAttitude.AIA_Neutral );
		}
	}

	public const virtual function GetTargetTrackerComponent() : TargetTrackerComponent
	{
		return NULL;
	}

	public static function GetTDBID( object : weak< GameObject > ) : TweakDBID
	{
		var puppet : ScriptedPuppet;
		var device : Device;
		var vehicle : VehicleObject;
		puppet = ( ( ScriptedPuppet )( object ) );
		if( puppet )
		{
			return puppet.GetRecordID();
		}
		device = ( ( Device )( object ) );
		if( device )
		{
			return device.GetTweakDBRecord();
		}
		vehicle = ( ( VehicleObject )( object ) );
		if( vehicle )
		{
			return vehicle.GetRecord().GetID();
		}
		return TDBID.None();
	}

	public static function GetActiveWeapon( object : weak< GameObject > ) : WeaponObject
	{
		var weapon : WeaponObject;
		if( !( object ) || !( object.IsAttached() ) )
		{
			return NULL;
		}
		weapon = ( ( WeaponObject )( GameInstance.GetTransactionSystem( object.GetGame() ).GetItemInSlot( object, T"AttachmentSlots.WeaponRight" ) ) );
		if( weapon )
		{
			return weapon;
		}
		weapon = ( ( WeaponObject )( GameInstance.GetTransactionSystem( object.GetGame() ).GetItemInSlot( object, T"AttachmentSlots.WeaponLeft" ) ) );
		if( weapon )
		{
			return weapon;
		}
		return weapon;
	}

	public static function StartCooldown( self : GameObject, cooldownName : CName, cooldownDuration : Float, optional ignoreTimeDilation : Bool ) : Int32
	{
		var cs : ICooldownSystem;
		var cdRequest : RegisterNewCooldownRequest;
		if( ( cooldownDuration < 0.0 ) || !( IsNameValid( cooldownName ) ) )
		{
			return -1;
		}
		if( cooldownDuration == 0.0 )
		{
			RemoveCooldown( self, cooldownName );
			return -1;
		}
		cs = CSH.GetCooldownSystem( self );
		cdRequest.cooldownName = cooldownName;
		cdRequest.duration = cooldownDuration;
		cdRequest.owner = self;
		cdRequest.affectedByTimeDilation = !( ignoreTimeDilation );
		return cs.Register( cdRequest );
	}

	public static function RemoveCooldown( self : GameObject, cooldownName : CName )
	{
		var cs : ICooldownSystem;
		var cid : Int32;
		if( !( IsNameValid( cooldownName ) ) )
		{
			return;
		}
		cs = CSH.GetCooldownSystem( self );
		cid = cs.GetCIDByOwnerAndName( self, cooldownName );
		if( cs.DoesCooldownExist( cid ) )
		{
			cs.Remove( cid );
		}
	}

	public static function IsCooldownActive( self : GameObject, cooldownName : CName, optional id : Int32 ) : Bool
	{
		var cs : ICooldownSystem;
		cs = CSH.GetCooldownSystem( self );
		if( !( cs ) )
		{
			return false;
		}
		if( id > 0 )
		{
			return cs.DoesCooldownExist( id );
		}
		id = cs.GetCIDByOwnerAndName( self, cooldownName );
		return cs.DoesCooldownExist( id );
	}

	public static function GetTargetAngleInFloat( target : GameObject, owner : GameObject ) : Float
	{
		var localHitDirection : Vector4;
		var forwardLocalToWorldAngle : Float;
		var finalHitDirectionCalculationFloat : Float;
		forwardLocalToWorldAngle = Vector4.Heading( owner.GetWorldForward() );
		localHitDirection = Vector4.RotByAngleXY( target.GetWorldForward(), forwardLocalToWorldAngle );
		finalHitDirectionCalculationFloat = Vector4.Heading( localHitDirection ) + 180.0;
		return finalHitDirectionCalculationFloat;
	}

	public static function GetTargetAngleInInt( target : GameObject, owner : GameObject ) : Int32
	{
		var localHitDirection : Vector4;
		var forwardLocalToWorldAngle : Float;
		var finalHitDirectionCalculationFloat : Float;
		forwardLocalToWorldAngle = Vector4.Heading( target.GetWorldForward() );
		localHitDirection = Vector4.RotByAngleXY( owner.GetWorldForward(), forwardLocalToWorldAngle );
		finalHitDirectionCalculationFloat = Vector4.Heading( localHitDirection ) + 180.0;
		if( ( finalHitDirectionCalculationFloat > 225.0 ) && ( finalHitDirectionCalculationFloat < 275.5 ) )
		{
			return 1;
		}
		else if( ( finalHitDirectionCalculationFloat > 135.0 ) && ( finalHitDirectionCalculationFloat < 225.0 ) )
		{
			return 2;
		}
		else if( ( finalHitDirectionCalculationFloat > 85.0 ) && ( finalHitDirectionCalculationFloat < 135.0 ) )
		{
			return 3;
		}
		else
		{
			return 4;
		}
	}

	public static function GetTargetAngleInInt( target : GameObject, owner : GameObject, out backDirection : Int32 ) : Int32
	{
		var localHitDirection : Vector4;
		var forwardLocalToWorldAngle : Float;
		var finalHitDirectionCalculationFloat : Float;
		forwardLocalToWorldAngle = Vector4.Heading( target.GetWorldForward() );
		localHitDirection = Vector4.RotByAngleXY( owner.GetWorldForward(), forwardLocalToWorldAngle );
		finalHitDirectionCalculationFloat = Vector4.Heading( localHitDirection ) + 180.0;
		backDirection = 0;
		if( ( finalHitDirectionCalculationFloat > 225.0 ) && ( finalHitDirectionCalculationFloat < 275.5 ) )
		{
			return 1;
		}
		else if( ( finalHitDirectionCalculationFloat > 135.0 ) && ( finalHitDirectionCalculationFloat < 225.0 ) )
		{
			if( ( finalHitDirectionCalculationFloat > 135.0 ) && ( finalHitDirectionCalculationFloat < 180.0 ) )
			{
				backDirection = 1;
			}
			else
			{
				backDirection = -1;
			}
			return 2;
		}
		else if( ( finalHitDirectionCalculationFloat > 85.0 ) && ( finalHitDirectionCalculationFloat < 135.0 ) )
		{
			return 3;
		}
		else
		{
			return 4;
		}
	}

	public static function GetAttackAngleInInt( hitEvent : gameHitEvent, optional hitSource : Int32 ) : Int32
	{
		if( hitSource == 0 )
		{
			return GetLocalAngleForDirectionInInt( hitEvent.hitDirection, hitEvent.target );
		}
		else
		{
			return GetTargetAngleInInt( hitEvent.attackData.GetSource(), hitEvent.target );
		}
	}

	public static function GetLocalAngleForDirectionInInt( direction : Vector4, owner : GameObject ) : Int32
	{
		var localHitDirection : Vector4;
		var forwardLocalToWorldAngle : Float;
		var finalHitDirectionCalculationInt : Int32;
		forwardLocalToWorldAngle = Vector4.Heading( owner.GetWorldForward() );
		localHitDirection = Vector4.RotByAngleXY( direction, forwardLocalToWorldAngle );
		finalHitDirectionCalculationInt = RoundMath( ( Vector4.Heading( localHitDirection ) + 180.0 ) / 90.0 );
		return finalHitDirectionCalculationInt;
	}

	public static function GetAttackAngleInFloat( hitEvent : gameHitEvent ) : Float
	{
		var localHitDirection : Vector4;
		var forwardLocalToWorldAngle : Float;
		var finalHitDirectionCalculationfloat : Float;
		forwardLocalToWorldAngle = Vector4.Heading( hitEvent.target.GetWorldForward() );
		localHitDirection = Vector4.RotByAngleXY( hitEvent.hitDirection, forwardLocalToWorldAngle );
		finalHitDirectionCalculationfloat = Vector4.Heading( localHitDirection ) + 180.0;
		return finalHitDirectionCalculationfloat;
	}

	public static function ApplyModifierGroup( self : GameObject, modifierGroupID : Uint64 )
	{
		var objectID : StatsObjectID;
		objectID = self.GetEntityID();
		GameInstance.GetStatsSystem( self.GetGame() ).ApplyModifierGroup( objectID, modifierGroupID );
	}

	public static function RemoveModifierGroup( self : GameObject, modifierGroupID : Uint64 )
	{
		var objectID : StatsObjectID;
		objectID = self.GetEntityID();
		GameInstance.GetStatsSystem( self.GetGame() ).RemoveModifierGroup( objectID, modifierGroupID );
	}

	public static function PlayVoiceOver( self : GameObject, voName : CName, debugInitialContext : CName, optional delay : Float, optional answeringEntityID : EntityID, optional canPlayInVehicle : Bool ) : DelayID
	{
		var evt : SoundPlayVo;
		var delayID : DelayID;
		evt = new SoundPlayVo;
		if( !( self ) )
		{
			return delayID;
		}
		if( VehicleComponent.IsMountedToVehicle( self.GetGame(), self ) && !( canPlayInVehicle ) )
		{
			return delayID;
		}
		if( IsServer() )
		{
			return delayID;
		}
		if( IsNameValid( voName ) )
		{
			evt.voContext = voName;
			if( IsMultiplayer() )
			{
				evt.ignoreFrustumCheck = true;
				evt.ignoreDistanceCheck = true;
			}
			evt.debugInitialContext = debugInitialContext;
			evt.answeringEntityId = answeringEntityID;
			if( delay <= 0.0 )
			{
				self.QueueEvent( evt );
			}
			else
			{
				delayID = GameInstance.GetDelaySystem( self.GetGame() ).DelayEvent( self, evt, delay );
			}
		}
		return delayID;
	}

	public static function PlaySound( self : GameObject, eventName : CName, optional emitterName : CName )
	{
		var objectID : EntityID;
		objectID = self.GetEntityID();
		if( !( EntityID.IsDefined( objectID ) ) )
		{
			GameInstance.GetAudioSystem( self.GetGame() ).Play( eventName, objectID, emitterName );
		}
		else
		{
			PlaySoundEvent( self, eventName );
		}
	}

	public static function PlaySoundWithParams( self : GameObject, eventName : CName, optional emitterName : CName, optional flag : audioAudioEventFlags, optional type : audioEventActionType )
	{
		var objectID : EntityID;
		objectID = self.GetEntityID();
		if( !( EntityID.IsDefined( objectID ) ) )
		{
			GameInstance.GetAudioSystem( self.GetGame() ).Play( eventName, objectID, emitterName );
		}
		else
		{
			PlaySoundEventWithParams( self, eventName, flag, type );
		}
	}

	public static function StopSound( self : GameObject, eventName : CName, optional emitterName : CName )
	{
		var objectID : EntityID;
		objectID = self.GetEntityID();
		if( !( EntityID.IsDefined( objectID ) ) )
		{
			GameInstance.GetAudioSystem( self.GetGame() ).Stop( eventName, objectID, emitterName );
		}
		else
		{
			StopSoundEvent( self, eventName );
		}
	}

	public static function AudioSwitch( self : GameObject, switchName : CName, switchValue : CName, optional emitterName : CName )
	{
		var objectID : EntityID;
		objectID = self.GetEntityID();
		GameInstance.GetAudioSystem( self.GetGame() ).Switch( switchName, switchValue, objectID, emitterName );
	}

	public static function AudioParameter( self : GameObject, parameterName : CName, parameterValue : Float, optional emitterName : CName )
	{
		var objectID : EntityID;
		objectID = self.GetEntityID();
		GameInstance.GetAudioSystem( self.GetGame() ).Parameter( parameterName, parameterValue, objectID, emitterName );
	}

	public static function PlaySoundEvent( self : GameObject, eventName : CName )
	{
		var evt : AudioEvent;
		evt = new AudioEvent;
		if( !( IsNameValid( eventName ) ) )
		{
			return;
		}
		evt.eventName = eventName;
		self.QueueEvent( evt );
	}

	public static function PlaySoundEventWithParams( self : GameObject, eventName : CName, optional flag : audioAudioEventFlags, optional type : audioEventActionType )
	{
		var evt : AudioEvent;
		evt = new AudioEvent;
		if( !( IsNameValid( eventName ) ) )
		{
			return;
		}
		evt.eventName = eventName;
		evt.eventFlags = flag;
		evt.eventType = type;
		self.QueueEvent( evt );
	}

	public static function StopSoundEvent( self : GameObject, eventName : CName )
	{
		var evt : SoundStopEvent;
		evt = new SoundStopEvent;
		if( !( IsNameValid( eventName ) ) )
		{
			return;
		}
		evt.soundName = eventName;
		self.QueueEvent( evt );
	}

	public static function PlayMetadataEvent( self : GameObject, eventName : CName )
	{
		var evt : AudioEvent;
		evt = new AudioEvent;
		evt.eventFlags = audioAudioEventFlags.Metadata;
		evt.eventName = eventName;
		self.QueueEvent( evt );
	}

	public static function SetAudioSwitch( self : GameObject, switchName, switchValue : CName )
	{
		var evt : SoundSwitchEvent;
		evt = new SoundSwitchEvent;
		evt.switchName = switchName;
		evt.switchValue = switchValue;
		self.QueueEvent( evt );
	}

	public static function SetAudioParameter( self : GameObject, paramName : CName, paramValue : Float )
	{
		var evt : SoundParameterEvent;
		evt = new SoundParameterEvent;
		evt.parameterName = paramName;
		evt.parameterValue = paramValue;
		self.QueueEvent( evt );
	}

	public import function QueueReplicatedEvent( evt : Event );

	public final function OnEventReplicated( evt : Event )
	{
		QueueEvent( evt );
	}

	public static function StartReplicatedEffectEvent( self : GameObject, effectName : CName, optional shouldPersist : Bool, optional breakAllOnDestroy : Bool )
	{
		var evt : entSpawnEffectEvent;
		evt = new entSpawnEffectEvent;
		if( IsNameValid( effectName ) )
		{
			evt.effectName = effectName;
			evt.persistOnDetach = shouldPersist;
			evt.breakAllOnDestroy = breakAllOnDestroy;
			self.QueueEvent( evt );
			self.QueueReplicatedEvent( evt );
		}
	}

	public static function BreakReplicatedEffectLoopEvent( self : GameObject, effectName : CName )
	{
		var evt : entBreakEffectLoopEvent;
		evt = new entBreakEffectLoopEvent;
		if( IsNameValid( effectName ) )
		{
			evt.effectName = effectName;
			self.QueueEvent( evt );
			self.QueueReplicatedEvent( evt );
		}
	}

	public static function StopReplicatedEffectEvent( self : GameObject, effectName : CName )
	{
		var evt : entKillEffectEvent;
		evt = new entKillEffectEvent;
		evt.effectName = effectName;
		self.QueueEvent( evt );
		self.QueueReplicatedEvent( evt );
	}

	public static function StopEffectEvent( self : GameObject, id : EntityID, effectName : CName )
	{
		var evt : entKillEffectEvent;
		evt = new entKillEffectEvent;
		evt.effectName = effectName;
		self.QueueEventForEntityID( id, evt );
	}

	public static function SetMeshAppearanceEvent( self : GameObject, appearance : CName )
	{
		var evt : entAppearanceEvent;
		var reactivateHighLightEvt : ForceReactivateHighlightsEvent;
		evt = new entAppearanceEvent;
		evt.appearanceName = appearance;
		self.QueueEvent( evt );
		if( self.IsHighlightedInFocusMode() )
		{
			reactivateHighLightEvt = new ForceReactivateHighlightsEvent;
			self.QueueEvent( reactivateHighLightEvt );
		}
	}

	public function PassUpdate( dt : Float )
	{
		Update( dt );
	}

	protected virtual function Update( dt : Float ) {}

	protected event OnStatusEffectApplied( evt : ApplyStatusEffectEvent )
	{
		StartStatusEffectVFX( evt );
		StartStatusEffectSFX( evt );
		HandleICEBreakerUpdate( evt );
	}

	private function HandleICEBreakerUpdate( evt : ApplyStatusEffectEvent )
	{
		if( ( ( ( evt.staticData.GetID() == T"MinigameAction.ICEBrokenMinigameMinor" ) || ( evt.staticData.GetID() == T"MinigameAction.ICEBrokenMinigameMedium" ) ) || ( evt.staticData.GetID() == T"MinigameAction.ICEBrokenMinigameMajor" ) ) || ( evt.staticData.GetID() == T"MinigameAction.ICEBrokenMinigamePlacide" ) )
		{
			QuickhackModule.RequestRefreshQuickhackMenu( GetGame(), GetEntityID() );
		}
	}

	protected virtual function StartStatusEffectVFX( evt : ApplyStatusEffectEvent )
	{
		var i : Int32;
		var vfxList : array< weak< StatusEffectFX_Record > >;
		evt.staticData.VFX( vfxList );
		for( i = 0; i < vfxList.Size(); i += 1 )
		{
			if( evt.isNewApplication || vfxList[ i ].ShouldReapply() )
			{
				GameObjectEffectHelper.StartEffectEvent( this, vfxList[ i ].Name() );
			}
		}
	}

	protected virtual function StartStatusEffectSFX( evt : ApplyStatusEffectEvent )
	{
		var i : Int32;
		var sfxList : array< weak< StatusEffectFX_Record > >;
		evt.staticData.SFX( sfxList );
		for( i = 0; i < sfxList.Size(); i += 1 )
		{
			if( evt.isNewApplication || sfxList[ i ].ShouldReapply() )
			{
				GameObject.PlaySound( this, sfxList[ i ].Name() );
			}
		}
	}

	protected event OnStatusEffectRemoved( evt : RemoveStatusEffect )
	{
		StopStatusEffectVFX( evt );
		StopStatusEffectSFX( evt );
	}

	protected virtual function StopStatusEffectVFX( evt : RemoveStatusEffect )
	{
		var i : Int32;
		var vfxList : array< weak< StatusEffectFX_Record > >;
		evt.staticData.VFX( vfxList );
		for( i = 0; i < vfxList.Size(); i += 1 )
		{
			if( evt.isFinalRemoval )
			{
				GameObjectEffectHelper.BreakEffectLoopEvent( this, vfxList[ i ].Name() );
			}
		}
	}

	protected virtual function StopStatusEffectSFX( evt : RemoveStatusEffect )
	{
		var i : Int32;
		var sfxList : array< weak< StatusEffectFX_Record > >;
		evt.staticData.SFX( sfxList );
		for( i = 0; i < sfxList.Size(); i += 1 )
		{
			if( evt.isFinalRemoval )
			{
				GameObject.StopSound( this, sfxList[ i ].Name() );
			}
		}
	}

	protected event OnHit( evt : gameHitEvent )
	{
		SetScannerDirty( true );
		ProcessDamagePipeline( evt );
	}

	protected export virtual function DamagePipelineFinalized( evt : gameHitEvent )
	{
		var vehicleHitEvt : gameVehicleHitEvent;
		vehicleHitEvt = ( ( gameVehicleHitEvent )( evt ) );
		if( vehicleHitEvt )
		{
			if( ResolveHitIstigatorCooldown( evt.attackData.GetInstigator().GetEntityID() ) )
			{
				if( ScriptedPuppet.IsAlive( this ) )
				{
					GameObject.PlayVoiceOver( this, 'vo_any_damage_hit', 'Scripts:OnHit' );
					TargetTrackingExtension.OnHit( ( ( ScriptedPuppet )( this ) ), evt );
				}
			}
		}
		else
		{
			HandleStimsOnHit( evt );
		}
	}

	protected function ResolveHitIstigatorCooldown( instigatorID : EntityID ) : Bool
	{
		var returnVal : Bool;
		var evt : HitInstigatorCooldownEvent;
		if( !( EntityID.IsDefined( instigatorID ) ) )
		{
			returnVal = false;
		}
		else if( instigatorID != m_lastHitInstigatorID )
		{
			returnVal = true;
			m_lastHitInstigatorID = instigatorID;
			if( m_hitInstigatorCooldownID != GetInvalidDelayID() )
			{
				GameInstance.GetDelaySystem( GetGame() ).CancelDelay( m_hitInstigatorCooldownID );
				m_hitInstigatorCooldownID = GetInvalidDelayID();
			}
		}
		else if( m_hitInstigatorCooldownID == GetInvalidDelayID() )
		{
			returnVal = true;
		}
		else
		{
			returnVal = false;
		}
		if( returnVal )
		{
			evt = new HitInstigatorCooldownEvent;
			evt.instigatorID = instigatorID;
			m_hitInstigatorCooldownID = GameInstance.GetDelaySystem( GetGame() ).DelayEvent( this, evt, 1.0, false );
		}
		return returnVal;
	}

	protected event OnHitInstigatorCooldown( evt : HitInstigatorCooldownEvent )
	{
		m_hitInstigatorCooldownID = GetInvalidDelayID();
	}

	protected virtual function HandleStimsOnHit( evt : gameHitEvent )
	{
		var hitStim : StimuliEvent;
		if( m_stimBroadcaster )
		{
			if( m_stimBroadcaster.ResolveStimProcessingCooldown( GetEntityID(), gamedataStimType.Invalid, 'HitStim', 1.0 ) )
			{
				hitStim = new StimuliEvent;
				hitStim.name = 'HitStim';
				QueueEvent( hitStim );
			}
		}
	}

	protected event OnVehicleHit( evt : gameVehicleHitEvent )
	{
		var attackContext : AttackInitContext;
		var attack : IAttack;
		attackContext.record = TweakDBInterface.GetAttackRecord( T"Attacks.VehicleCollision" );
		attackContext.instigator = evt.attackData.GetInstigator();
		attackContext.source = evt.attackData.GetSource();
		attack = IAttack.Create( attackContext );
		evt.attackData.SetAttackDefinition( attack );
		evt.attackData.AddFlag( hitFlag.FriendlyFire, 'vehicle_collision' );
		GameInstance.GetDamageSystem( GetGame() ).QueueHitEvent( evt, this );
	}

	protected event OnHitProjection( evt : gameProjectedHitEvent )
	{
		GameInstance.GetDamageSystem( GetGame() ).StartProjectionPipeline( evt );
	}

	protected event OnAttitudeChanged( evt : AttitudeChangedEvent )
	{
		SetScannerDirty( true );
	}

	protected virtual function ProcessDamagePipeline( evt : gameHitEvent )
	{
		GameInstance.GetDamageSystem( GetGame() ).QueueHitEvent( evt, this );
	}

	public virtual function ReactToHitProcess( hitEvent : gameHitEvent )
	{
		var targetGodMode : gameGodModeType;
		if( hitEvent.attackData.HasFlag( hitFlag.WasBlocked ) || hitEvent.attackData.HasFlag( hitFlag.WasDeflected ) )
		{
			OnHitBlockedOrDeflected( hitEvent );
		}
		GetImmortality( hitEvent.target, targetGodMode );
		if( hitEvent.target.IsPlayer() && ( targetGodMode == gameGodModeType.Invulnerable || hitEvent.attackData.HasFlag( hitFlag.DealNoDamage ) ) )
		{
			return;
		}
		OnHitUI( hitEvent );
		if( hitEvent.attackData.HasFlag( hitFlag.DisableNPCHitReaction ) && !( hitEvent.target.IsPlayer() ) )
		{
			return;
		}
		OnHitAnimation( hitEvent );
		OnHitSounds( hitEvent );
		OnHitVFX( hitEvent );
	}

	protected virtual function OnHitBlockedOrDeflected( hitEvent : gameHitEvent );
	protected virtual function OnHitAnimation( hitEvent : gameHitEvent );

	protected virtual function OnHitUI( hitEvent : gameHitEvent )
	{
		var dmgInfos : array< DamageInfo >;
		if( IsClient() )
		{
			return;
		}
		dmgInfos = GameInstance.GetDamageSystem( GetGame() ).ConvertHitDataToDamageInfo( hitEvent );
		DisplayHitUI( dmgInfos );
	}

	public virtual function DisplayHitUI( dmgInfos : array< DamageInfo > )
	{
		var i : Int32;
		for( i = 0; i < dmgInfos.Size(); i += 1 )
		{
			GameInstance.GetTargetingSystem( GetGame() ).GetPuppetBlackboardUpdater().AddDamageInfo( dmgInfos[ i ] );
		}
	}

	public export virtual function DisplayKillUI( killInfo : KillInfo )
	{
		GameInstance.GetTargetingSystem( GetGame() ).GetPuppetBlackboardUpdater().AddKillInfo( killInfo );
	}

	protected virtual function OnHitSounds( hitEvent : gameHitEvent )
	{
		if( hitEvent.attackData.HasFlag( hitFlag.DisableSounds ) )
		{
			return;
		}
	}

	protected virtual function OnHitVFX( hitEvent : gameHitEvent );

	protected event OnDamageReceived( evt : gameDamageReceivedEvent )
	{
		ProcessDamageReceived( evt );
	}

	public const function GetReceivedDamageByPlayerLastTimeStamp() : Float
	{
		var latestTimeStamp : Float;
		var i : Int32;
		for( i = 0; i < m_receivedDamageHistory.Size(); i += 1 )
		{
			if( m_receivedDamageHistory[ i ].source.IsPlayer() )
			{
				if( latestTimeStamp < m_receivedDamageHistory[ i ].timestamp )
				{
					latestTimeStamp = m_receivedDamageHistory[ i ].timestamp;
				}
			}
		}
		return latestTimeStamp;
	}

	protected function ProcessDamageReceived( evt : gameDamageReceivedEvent )
	{
		var damageHistoryEvt : DamageHistoryEntry;
		var instigator : weak< GameObject >;
		var damageInflictedEvent : DamageInflictedEvent;
		instigator = evt.hitEvent.attackData.GetInstigator();
		if( instigator.IsControlledByAnyPeer() )
		{
			if( GameInstance.GetStatPoolsSystem( evt.hitEvent.target.GetGame() ).GetStatPoolValue( evt.hitEvent.target.GetEntityID(), gamedataStatPoolType.Health, false ) <= 0.0 )
			{
				ChatterHelper.TryPlayEnemyKilledChatter( instigator );
			}
			else
			{
				ChatterHelper.TryPlayEnemyDamagedChatter( instigator );
			}
		}
		if( evt.totalDamageReceived > 0.0 )
		{
			if( m_receivedDamageHistory.Size() > 0 )
			{
				if( m_receivedDamageHistory[ ( m_receivedDamageHistory.Size() - 1 ) ].frameReceived < GameInstance.GetFrameNumber( GetGame() ) )
				{
					m_receivedDamageHistory.Clear();
				}
			}
			damageHistoryEvt.hitEvent = evt.hitEvent;
			damageHistoryEvt.frameReceived = GameInstance.GetFrameNumber( GetGame() );
			damageHistoryEvt.timestamp = EngineTime.ToFloat( GameInstance.GetEngineTime( GetGame() ) );
			damageHistoryEvt.totalDamageReceived = evt.totalDamageReceived;
			damageHistoryEvt.source = evt.hitEvent.attackData.GetInstigator();
			damageHistoryEvt.target = evt.hitEvent.target;
			damageHistoryEvt.healthAtTheTime = GameInstance.GetStatPoolsSystem( GetGame() ).GetStatPoolValue( GetEntityID(), gamedataStatPoolType.Health, false );
			m_receivedDamageHistory.PushBack( damageHistoryEvt );
		}
		CoopIrritationDelayCallback.TryCreate( instigator );
		if( instigator )
		{
			damageInflictedEvent = new DamageInflictedEvent;
			instigator.QueueEvent( damageInflictedEvent );
		}
	}

	public virtual function Record1DamageInHistory( source : GameObject )
	{
		var damageHistoryEvt : DamageHistoryEntry;
		if( m_receivedDamageHistory.Size() > 0 )
		{
			if( m_receivedDamageHistory[ ( m_receivedDamageHistory.Size() - 1 ) ].frameReceived < GameInstance.GetFrameNumber( GetGame() ) )
			{
				m_receivedDamageHistory.Clear();
			}
		}
		damageHistoryEvt.frameReceived = GameInstance.GetFrameNumber( GetGame() );
		damageHistoryEvt.timestamp = EngineTime.ToFloat( GameInstance.GetEngineTime( GetGame() ) );
		damageHistoryEvt.totalDamageReceived = 1.0;
		damageHistoryEvt.source = source;
		damageHistoryEvt.target = this;
		damageHistoryEvt.healthAtTheTime = 1.0;
		m_receivedDamageHistory.PushBack( damageHistoryEvt );
	}

	protected event OnRecord1DamageInHistoryEvent( evt : Record1DamageInHistoryEvent )
	{
		Record1DamageInHistory( evt.source );
	}

	public function FindAndRewardKiller( killType : gameKillType, optional instigator : weak< GameObject > )
	{
		var playerDamageData : array< PlayerTotalDamageAgainstHealth >;
		var validKillerPool : array< weak< GameObject > >;
		var reserveKillerPool : array< weak< GameObject > >;
		var isAnyDamageNonlethal : Bool;
		var i, p, randomInt : Int32;
		if( m_receivedDamageHistory.Size() > 0 )
		{
			for( i = 0; i < m_receivedDamageHistory.Size(); i += 1 )
			{
				if( m_receivedDamageHistory[ i ].source != NULL )
				{
					if( !( reserveKillerPool.Contains( m_receivedDamageHistory[ i ].source ) ) )
					{
						reserveKillerPool.PushBack( m_receivedDamageHistory[ i ].source );
						playerDamageData.Resize( reserveKillerPool.Size() );
						p = reserveKillerPool.Size() - 1;
						playerDamageData[ p ].player = m_receivedDamageHistory[ i ].source;
						playerDamageData[ p ].totalDamage = m_receivedDamageHistory[ i ].totalDamageReceived;
						playerDamageData[ p ].targetHealth = m_receivedDamageHistory[ i ].healthAtTheTime;
					}
					else
					{
						p = reserveKillerPool.FindFirst( m_receivedDamageHistory[ i ].source );
						playerDamageData[ p ].totalDamage += m_receivedDamageHistory[ i ].totalDamageReceived;
						if( playerDamageData[ p ].targetHealth > m_receivedDamageHistory[ i ].healthAtTheTime )
						{
							playerDamageData[ p ].targetHealth = m_receivedDamageHistory[ i ].healthAtTheTime;
						}
					}
				}
				if( m_receivedDamageHistory[ i ].hitEvent )
				{
					if( m_receivedDamageHistory[ i ].hitEvent.attackData.HasFlag( hitFlag.Nonlethal ) )
					{
						isAnyDamageNonlethal = true;
					}
				}
			}
			for( i = 0; i < playerDamageData.Size(); i += 1 )
			{
				if( playerDamageData[ i ].totalDamage >= playerDamageData[ i ].targetHealth )
				{
					validKillerPool.PushBack( playerDamageData[ i ].player );
				}
			}
			if( validKillerPool.Size() > 0 )
			{
				randomInt = RandRange( 0, validKillerPool.Size() );
				RewardKiller( validKillerPool[ randomInt ], killType, isAnyDamageNonlethal );
				CheckIfPreventionShouldReact( validKillerPool );
			}
			else if( reserveKillerPool.Size() > 0 )
			{
				randomInt = RandRange( 0, reserveKillerPool.Size() );
				RewardKiller( reserveKillerPool[ randomInt ], killType, isAnyDamageNonlethal );
				CheckIfPreventionShouldReact( reserveKillerPool );
			}
		}
		else if( instigator )
		{
			RewardKiller( instigator, killType, isAnyDamageNonlethal );
			validKillerPool.PushBack( instigator );
			CheckIfPreventionShouldReact( validKillerPool );
		}
	}

	protected virtual function RewardKiller( killer : weak< GameObject >, killType : gameKillType, isAnyDamageNonlethal : Bool )
	{
		var killRewardEvt : KillRewardEvent;
		if( m_killRewardDisabled )
		{
			return;
		}
		if( m_willDieSoon && killType == gameKillType.Normal )
		{
			return;
		}
		killRewardEvt = new KillRewardEvent;
		killRewardEvt.victim = this;
		if( m_forceDefeatReward )
		{
			killRewardEvt.killType = gameKillType.Defeat;
		}
		else if( m_willDieSoon )
		{
			killRewardEvt.killType = gameKillType.Normal;
		}
		else
		{
			killRewardEvt.killType = killType;
		}
		killer.QueueEvent( killRewardEvt );
	}

	public function ForceDefeatReward( value : Bool )
	{
		m_forceDefeatReward = value;
	}

	public function DisableKillReward( value : Bool )
	{
		m_killRewardDisabled = value;
	}

	protected event OnChangeRewardSettingsEvent( evt : ChangeRewardSettingsEvent )
	{
		ForceDefeatReward( evt.forceDefeatReward );
		DisableKillReward( evt.disableKillReward );
	}

	protected event OnWillDieSoonEventEvent( evt : WillDieSoonEvent )
	{
		m_willDieSoon = true;
	}

	private function CheckIfPreventionShouldReact( damageDealers : array< weak< GameObject > > )
	{
		var i : Int32;
		if( PreventionSystem.ShouldPreventionSystemReactToKill( ( ( ScriptedPuppet )( this ) ) ) )
		{
			for( i = 0; i < damageDealers.Size(); i += 1 )
			{
				if( damageDealers[ i ].IsPlayer() )
				{
					PreventionSystem.CreateNewDamageRequest( GetGame(), this, 1.0 );
					return;
				}
			}
		}
	}

	public const virtual function IsVehicle() : Bool
	{
		return false;
	}

	public const virtual function IsPuppet() : Bool
	{
		return false;
	}

	public const virtual function IsPlayer() : Bool
	{
		return false;
	}

	public const virtual function IsReplacer() : Bool
	{
		return false;
	}

	public const virtual function IsVRReplacer() : Bool
	{
		return false;
	}

	public const virtual function IsJohnnyReplacer() : Bool
	{
		return false;
	}

	public const virtual function IsNPC() : Bool
	{
		return false;
	}

	public const virtual function IsContainer() : Bool
	{
		return false;
	}

	public const virtual function IsShardContainer() : Bool
	{
		return false;
	}

	public const virtual function IsPlayerStash() : Bool
	{
		return false;
	}

	public export const virtual function IsDevice() : Bool
	{
		return false;
	}

	public export const virtual function IsSensor() : Bool
	{
		return false;
	}

	public export const virtual function IsTurret() : Bool
	{
		return false;
	}

	public const virtual function IsActive() : Bool
	{
		return false;
	}

	public const virtual function IsPrevention() : Bool
	{
		return false;
	}

	public const virtual function IsDropPoint() : Bool
	{
		return false;
	}

	public const virtual function IsWardrobe() : Bool
	{
		return false;
	}

	public const virtual function IsDrone() : Bool
	{
		return false;
	}

	protected const function IsItem() : Bool
	{
		return ( ( ItemObject )( this ) ) != NULL;
	}

	public const virtual function IsDead() : Bool
	{
		if( GameInstance.GetStatPoolsSystem( GetGame() ).GetStatPoolValue( GetEntityID(), gamedataStatPoolType.Health, false ) <= 0.0 )
		{
			return true;
		}
		return false;
	}

	public const virtual function IsDeadNoStatPool() : Bool
	{
		return IsDead();
	}

	public export virtual function UpdateAdditionalScanningData()
	{
		var stats : GameObjectScanStats;
		var bb : IBlackboard;
		stats.scannerData.entityName = GetDisplayName();
		bb = GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().UI_Scanner );
		if( bb )
		{
			bb.SetVariant( GetAllBlackboardDefs().UI_Scanner.scannerObjectStats, stats );
			bb.SignalVariant( GetAllBlackboardDefs().UI_Scanner.scannerObjectStats );
		}
	}

	protected event OnOutlineRequestEvent( evt : OutlineRequestEvent )
	{
		var appearance : VisionAppearance;
		var visionModeSystem : VisionModeSystem;
		var delayedDiableOutlineEvent : OutlineRequestEvent;
		var delayedDiableOutlineEventData : OutlineData;
		var outlineType : EOutlineType;
		if( IsDead() )
		{
			return false;
		}
		visionModeSystem = GameInstance.GetVisionModeSystem( GetGame() );
		outlineType = evt.outlineRequest.GetRequestType();
		if( outlineType == EOutlineType.NONE )
		{
			visionModeSystem.CancelForceVisionAppearance( this );
		}
		else
		{
			if( outlineType == EOutlineType.GREEN )
			{
				appearance.fill = 4;
				appearance.outline = 1;
			}
			else if( outlineType == EOutlineType.RED )
			{
				appearance.fill = 7;
				appearance.outline = 2;
			}
			appearance.showThroughWalls = true;
			visionModeSystem.ForceVisionAppearance( this, appearance, 0.2 );
			delayedDiableOutlineEvent = new OutlineRequestEvent;
			delayedDiableOutlineEventData.outlineType = EOutlineType.NONE;
			delayedDiableOutlineEvent.outlineRequest = OutlineRequest.CreateRequest( 'OnOutlineRequestEvent', delayedDiableOutlineEventData );
			GameInstance.GetDelaySystem( GetGame() ).DelayEvent( this, delayedDiableOutlineEvent, evt.outlineRequest.GetOutlineDuration() );
		}
	}

	protected event OnDebugOutlineEvent( evt : DebugOutlineEvent )
	{
		var outlineRequestEvent : OutlineRequestEvent;
		var outlineRequest : OutlineRequest;
		var data : OutlineData;
		outlineRequestEvent = new OutlineRequestEvent;
		outlineRequest = new OutlineRequest;
		data.outlineType = evt.type;
		data.outlineOpacity = evt.opacity;
		outlineRequest = OutlineRequest.CreateRequest( 'debug', data, evt.duration );
		outlineRequestEvent.outlineRequest = outlineRequest;
		outlineRequestEvent.flag = false;
		QueueEvent( outlineRequestEvent );
	}

	protected event OnScanningModeChanged( evt : ScanningModeEvent )
	{
		GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().UI_Scanner ).SetVariant( GetAllBlackboardDefs().UI_Scanner.ScannerMode, evt );
	}

	protected event OnScanningLookedAt( evt : ScanningLookAtEvent )
	{
		if( evt.state )
		{
			PurgeScannerBlackboard();
			SetScannerDirty( true );
		}
	}

	protected event OnLookedAtEvent( evt : LookedAtEvent ) {}

	protected event OnPulseEvent( evt : gameVisionModeUpdateVisuals )
	{
		if( ( ( ( IsPlayer() || IsItem() ) || GetNetworkSystem().IsPingLinksLimitReached() ) || GetNetworkSystem().HasActivePing( GetEntityID() ) ) || m_e3ObjectRevealed )
		{
			return false;
		}
		if( evt.pulse )
		{
		}
	}

	protected virtual function PulseNetwork( revealNetworkAtEnd : Bool )
	{
		var request : StartPingingNetworkRequest;
		var duration : Float;
		m_e3ObjectRevealed = true;
		if( GameInstance.GetQuestsSystem( GetGame() ).GetFact( 'pingingNetworkDisabled' ) > 0 )
		{
			return;
		}
		request = new StartPingingNetworkRequest;
		duration = GetNetworkSystem().GetSpacePingDuration();
		request.source = this;
		request.fxResource = GetFxResourceByKey( 'pingNetworkLink' );
		request.duration = duration;
		request.pingType = EPingType.SPACE;
		request.fakeLinkType = ELinkType.FREE;
		request.revealNetworkAtEnd = revealNetworkAtEnd;
		GetNetworkSystem().QueueRequest( request );
	}

	public const function GetTakeOverControlSystem() : TakeOverControlSystem
	{
		return ( ( TakeOverControlSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'TakeOverControlSystem' ) ) );
	}

	public const function GetTaggingSystem() : FocusModeTaggingSystem
	{
		return ( ( FocusModeTaggingSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'FocusModeTaggingSystem' ) ) );
	}

	public static function TagObject( obj : weak< GameObject > )
	{
		var request : TagObjectRequest;
		if( !( obj ) || !( obj.CanBeTagged() ) )
		{
			return;
		}
		request = new TagObjectRequest;
		request.object = obj;
		obj.GetTaggingSystem().QueueRequest( request );
	}

	public static function UntagObject( obj : weak< GameObject > )
	{
		var request : UnTagObjectRequest;
		if( !( obj ) )
		{
			return;
		}
		request = new UnTagObjectRequest;
		request.object = obj;
		obj.GetTaggingSystem().QueueRequest( request );
	}

	public const virtual function CanBeTagged() : Bool
	{
		return true;
	}

	protected event OnTagObjectEvent( evt : TagObjectEvent )
	{
		if( evt.isTagged )
		{
			TagObject( this );
		}
		else
		{
			UntagObject( this );
		}
	}

	public const virtual function GetDefaultHighlight() : FocusForcedHighlightData
	{
		var highlight : FocusForcedHighlightData;
		var outline : EFocusOutlineType;
		if( IsBraindanceBlocked() || IsPhotoModeBlocked() )
		{
			return NULL;
		}
		outline = GetCurrentOutline();
		highlight = new FocusForcedHighlightData;
		highlight.sourceID = GetEntityID();
		highlight.sourceName = GetClassName();
		highlight.priority = EPriority.Low;
		highlight.outlineType = outline;
		if( IsQuest() )
		{
			highlight.highlightType = EFocusForcedHighlightType.QUEST;
			highlight.outlineType = EFocusOutlineType.QUEST;
		}
		else if( IsTaggedinFocusMode() )
		{
			highlight.highlightType = EFocusForcedHighlightType.INTERACTION;
			highlight.outlineType = EFocusOutlineType.INTERACTION;
		}
		else
		{
			highlight = NULL;
		}
		return highlight;
	}

	protected function UpdateDefaultHighlight()
	{
		var updateHighlightEvt : ForceUpdateDefaultHighlightEvent;
		updateHighlightEvt = new ForceUpdateDefaultHighlightEvent;
		QueueEvent( updateHighlightEvt );
	}

	public const virtual function GetCurrentOutline() : EFocusOutlineType
	{
		return EFocusOutlineType.INVALID;
	}

	public const function GetDefaultHighlightType() : EFocusForcedHighlightType
	{
		var data : FocusForcedHighlightData;
		data = GetDefaultHighlight();
		if( data != NULL )
		{
			return data.highlightType;
		}
		return EFocusForcedHighlightType.INVALID;
	}

	public const function HasHighlight( highlightType : EFocusForcedHighlightType, outlineType : EFocusOutlineType ) : Bool
	{
		if( !( m_visionComponent ) )
		{
			return false;
		}
		return m_visionComponent.HasHighlight( highlightType, outlineType );
	}

	public const function HasOutlineOrFill( highlightType : EFocusForcedHighlightType, outlineType : EFocusOutlineType ) : Bool
	{
		if( !( m_visionComponent ) )
		{
			return false;
		}
		return m_visionComponent.HasOutlineOrFill( highlightType, outlineType );
	}

	public const function HasHighlight( highlightType : EFocusForcedHighlightType, outlineType : EFocusOutlineType, sourceID : EntityID ) : Bool
	{
		if( !( m_visionComponent ) )
		{
			return false;
		}
		return m_visionComponent.HasHighlight( highlightType, outlineType, sourceID );
	}

	public const function HasHighlight( highlightType : EFocusForcedHighlightType, outlineType : EFocusOutlineType, sourceID : EntityID, sourceName : CName ) : Bool
	{
		if( !( m_visionComponent ) )
		{
			return false;
		}
		return m_visionComponent.HasHighlight( highlightType, outlineType, sourceID, sourceName );
	}

	public const function HasRevealRequest( data : gameVisionModeSystemRevealIdentifier ) : Bool
	{
		if( !( m_visionComponent ) )
		{
			return false;
		}
		return m_visionComponent.HasRevealRequest( data );
	}

	protected function CancelForcedVisionAppearance( data : FocusForcedHighlightData )
	{
		var evt : ForceVisionApperanceEvent;
		evt = new ForceVisionApperanceEvent;
		evt.forcedHighlight = data;
		evt.apply = false;
		QueueEvent( evt );
	}

	protected function ForceVisionAppearance( data : FocusForcedHighlightData )
	{
		var evt : ForceVisionApperanceEvent;
		evt = new ForceVisionApperanceEvent;
		evt.forcedHighlight = data;
		evt.apply = true;
		QueueEvent( evt );
	}

	public static function ForceVisionAppearance( self : GameObject, data : FocusForcedHighlightData )
	{
		var evt : ForceVisionApperanceEvent;
		evt = new ForceVisionApperanceEvent;
		evt.forcedHighlight = data;
		evt.apply = true;
		self.QueueEvent( evt );
	}

	public static function SetFocusForcedHightlightData( outType : EFocusOutlineType, highType : EFocusForcedHighlightType, prio : EPriority, id : EntityID, className : CName ) : FocusForcedHighlightData
	{
		var newData : FocusForcedHighlightData;
		newData = new FocusForcedHighlightData;
		newData.outlineType = outType;
		newData.highlightType = highType;
		newData.priority = prio;
		newData.sourceID = id;
		newData.sourceName = className;
		return newData;
	}

	protected function SendReactivateHighlightEvent()
	{
		var evt : ForceReactivateHighlightsEvent;
		evt = new ForceReactivateHighlightsEvent;
		QueueEvent( evt );
	}

	public const virtual function GetObjectToForwardHighlight() : array< weak< GameObject > >
	{
		var emptyArray : array< weak< GameObject > >;
		return emptyArray;
	}

	protected event OnHUDInstruction( evt : HUDInstruction )
	{
		if( evt.highlightInstructions.GetState() == InstanceState.ON )
		{
			m_isHighlightedInFocusMode = true;
		}
		else if( evt.highlightInstructions.WasProcessed() )
		{
			m_isHighlightedInFocusMode = false;
		}
	}

	protected function TryOpenQuickhackMenu( shouldOpen : Bool )
	{
		if( shouldOpen )
		{
			shouldOpen = CanRevealRemoteActionsWheel();
		}
		SendQuickhackCommands( shouldOpen );
	}

	protected virtual function SendQuickhackCommands( shouldOpen : Bool ) {}

	protected function SendForceRevealObjectEvent( reveal : Bool, reason : CName, optional instigatorID : EntityID, optional lifetime : Float, optional delay : Float )
	{
		var evt : RevealObjectEvent;
		evt = new RevealObjectEvent;
		evt.reveal = reveal;
		evt.reason.reason = reason;
		evt.reason.sourceEntityId = instigatorID;
		evt.lifetime = lifetime;
		if( delay > 0.0 )
		{
			GameInstance.GetDelaySystem( GetGame() ).DelayEvent( this, evt, delay, true );
		}
		else
		{
			this.QueueEvent( evt );
		}
	}

	public static function SendForceRevealObjectEvent( self : GameObject, reveal : Bool, reason : CName, optional instigatorID : EntityID, optional lifetime : Float, optional delay : Float )
	{
		self.SendForceRevealObjectEvent( reveal, reason, instigatorID, lifetime, delay );
	}

	private function RestoreRevealState()
	{
		var evt : RestoreRevealStateEvent;
		if( IsObjectRevealed() )
		{
			evt = new RestoreRevealStateEvent;
			QueueEvent( evt );
		}
	}

	public const virtual function IsHighlightedInFocusMode() : Bool
	{
		return m_isHighlightedInFocusMode;
	}

	public const function IsScanned() : Bool
	{
		if( m_scanningComponent != NULL )
		{
			return m_scanningComponent.IsScanned();
		}
		else
		{
			return false;
		}
	}

	public const function GetBraindanceLayer() : braindanceVisionMode
	{
		if( m_scanningComponent )
		{
			return m_scanningComponent.GetBraindanceLayer();
		}
		else
		{
			return braindanceVisionMode.Default;
		}
	}

	public const function IsObjectRevealed() : Bool
	{
		if( m_visionComponent == NULL )
		{
			return false;
		}
		return m_visionComponent.IsRevealed();
	}

	protected function GetFastTravelSystem() : FastTravelSystem
	{
		return ( ( FastTravelSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'FastTravelSystem' ) ) );
	}

	protected const function GetNetworkSystem() : NetworkSystem
	{
		return ( ( NetworkSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'NetworkSystem' ) ) );
	}

	public const virtual function CanOverrideNetworkContext() : Bool
	{
		return false;
	}

	public const virtual function IsAccessPoint() : Bool
	{
		return false;
	}

	protected virtual function StartPingingNetwork() {}

	protected virtual function StopPingingNetwork() {}

	public const virtual function GetNetworkLinkSlotName( out transform : WorldTransform ) : CName
	{
		return '';
	}

	public const virtual function GetNetworkLinkSlotName() : CName
	{
		return '';
	}

	public const virtual function GetRoleMappinSlotName() : CName
	{
		return 'roleMappin';
	}

	public const virtual function GetQuickHackIndicatorSlotName() : CName
	{
		return 'uploadBar';
	}

	public const virtual function GetPhoneCallIndicatorSlotName() : CName
	{
		return 'phoneCall';
	}

	public const virtual function IsNetworkLinkDynamic() : Bool
	{
		return false;
	}

	public const virtual function GetNetworkBeamEndpoint() : Vector4
	{
		var beamPos : Vector4;
		beamPos = GetWorldPosition();
		return beamPos;
	}

	public const virtual function IsNetworkKnownToPlayer() : Bool
	{
		return false;
	}

	public const virtual function CanPlayerUseQuickHackVulnerability( data : TweakDBID ) : Bool
	{
		return false;
	}

	public const virtual function IsConnectedToBackdoorDevice() : Bool
	{
		return false;
	}

	public const virtual function IsInIconForcedVisibilityRange() : Bool
	{
		return false;
	}

	public virtual function EvaluateMappinsVisualState()
	{
		var evt : EvaluateMappinsVisualStateEvent;
		evt = new EvaluateMappinsVisualStateEvent;
		QueueEvent( evt );
	}

	public const virtual function IsGameplayRelevant() : Bool
	{
		var role : EGameplayRole;
		role = DeterminGameplayRole();
		return role != EGameplayRole.None && role != EGameplayRole.UnAssigned;
	}

	public const virtual function ShouldSendGameAttachedEventToPS() : Bool
	{
		return true;
	}

	public const virtual function GetContentScale() : TweakDBID
	{
		var id : TweakDBID;
		return id;
	}

	public const virtual function IsGameplayRoleValid( role : EGameplayRole ) : Bool
	{
		return true;
	}

	public const virtual function DeterminGameplayRole() : EGameplayRole
	{
		if( m_scanningComponent && m_scanningComponent.IsAnyClueEnabled() )
		{
			return EGameplayRole.Clue;
		}
		else
		{
			return EGameplayRole.None;
		}
	}

	public const virtual function DeterminGameplayRoleMappinVisuaState( data : SDeviceMappinData ) : EMappinVisualState
	{
		if( HasAnyClue() && IsClueInspected() )
		{
			return EMappinVisualState.Inactive;
		}
		else
		{
			return EMappinVisualState.Default;
		}
	}

	public const virtual function DeterminGameplayRoleMappinRange( data : SDeviceMappinData ) : Float
	{
		return 0.0;
	}

	protected event OnGameplayRoleChangeNotification( evt : GameplayRoleChangeNotification )
	{
		if( evt.newRole == EGameplayRole.None && evt.oldRole != EGameplayRole.None )
		{
			RequestHUDRefresh();
			RegisterToHUDManagerByTask( false );
		}
		else if( evt.newRole != EGameplayRole.None && ( evt.oldRole == EGameplayRole.None || evt.oldRole == EGameplayRole.UnAssigned ) )
		{
			if( ShouldRegisterToHUD() )
			{
				RegisterToHUDManagerByTask( true );
			}
		}
	}

	public const virtual function IsHackingPlayer() : Bool
	{
		return false;
	}

	public const virtual function IsQuickHackAble() : Bool
	{
		return false;
	}

	public const virtual function IsQuickHacksExposed() : Bool
	{
		return false;
	}

	public const virtual function IsBreached() : Bool
	{
		return false;
	}

	public const virtual function IsBackdoor() : Bool
	{
		return false;
	}

	public const virtual function IsActiveBackdoor() : Bool
	{
		return false;
	}

	public const virtual function IsBodyDisposalPossible() : Bool
	{
		return false;
	}

	public const virtual function IsControllingDevices() : Bool
	{
		return false;
	}

	public const virtual function HasAnySlaveDevices() : Bool
	{
		return false;
	}

	public const virtual function IsFastTravelPoint() : Bool
	{
		return false;
	}

	public const virtual function IsExplosive() : Bool
	{
		return false;
	}

	public const virtual function HasImportantInteraction() : Bool
	{
		return false;
	}

	public const virtual function HasAnyDirectInteractionActive() : Bool
	{
		return false;
	}

	public const virtual function ShouldEnableRemoteLayer() : Bool
	{
		return false;
	}

	public const virtual function IsTechie() : Bool
	{
		return false;
	}

	public const virtual function IsSolo() : Bool
	{
		return false;
	}

	public const virtual function IsNetrunner() : Bool
	{
		return false;
	}

	public const function IsAnyPlaystyleValid() : Bool
	{
		return ( IsTechie() || IsSolo() ) || IsNetrunner();
	}

	public const virtual function IsHackingSkillCheckActive() : Bool
	{
		return false;
	}

	public const virtual function IsDemolitionSkillCheckActive() : Bool
	{
		return false;
	}

	public const virtual function IsEngineeringSkillCheckActive() : Bool
	{
		return false;
	}

	public const virtual function CanPassEngineeringSkillCheck() : Bool
	{
		return false;
	}

	public const virtual function CanPassDemolitionSkillCheck() : Bool
	{
		return false;
	}

	public const virtual function CanPassHackingSkillCheck() : Bool
	{
		return false;
	}

	public const virtual function HasDirectActionsActive() : Bool
	{
		return false;
	}

	public const virtual function HasActiveDistraction() : Bool
	{
		return false;
	}

	public const virtual function HasActiveQuickHackUpload() : Bool
	{
		return false;
	}

	public const virtual function IsInvestigating() : Bool
	{
		return false;
	}

	public const virtual function IsInvestigatingObject( targetID : GameObject ) : Bool
	{
		return false;
	}

	public const function IsTaggedinFocusMode() : Bool
	{
		return GameInstance.GetVisionModeSystem( GetGame() ).GetScanningController().IsTagged( this );
	}

	public const virtual function IsQuest() : Bool
	{
		return m_markAsQuest;
	}

	protected event OnSetAsQuestImportantEvent( evt : SetAsQuestImportantEvent )
	{
		ToggleQuestImportance( evt.IsImportant() );
	}

	protected function ToggleQuestImportance( isImportant : Bool )
	{
		if( IsQuest() != isImportant )
		{
			MarkAsQuest( isImportant );
			RequestHUDRefresh();
		}
	}

	protected virtual function MarkAsQuest( isQuest : Bool )
	{
		m_markAsQuest = isQuest;
	}

	public const function IsGrouppedClue() : Bool
	{
		return m_scanningComponent && m_scanningComponent.IsActiveClueLinked();
	}

	public const function HasAnyClue() : Bool
	{
		return m_scanningComponent && m_scanningComponent.HasAnyClue();
	}

	public const function IsClueInspected() : Bool
	{
		return m_scanningComponent && m_scanningComponent.IsClueInspected();
	}

	public const function GetLinkedClueData( clueIndex : Int32 ) : LinkedFocusClueData
	{
		var linkedClueData : LinkedFocusClueData;
		if( m_scanningComponent != NULL )
		{
			m_scanningComponent.GetLinkedClueData( clueIndex, linkedClueData );
		}
		return linkedClueData;
	}

	public const function GetAvailableClueIndex() : Int32
	{
		if( m_scanningComponent != NULL )
		{
			return m_scanningComponent.GetAvailableClueIndex();
		}
		return -1;
	}

	protected function PurgeScannerBlackboard()
	{
		var scannerBlackboard : weak< IBlackboard >;
		scannerBlackboard = GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().UI_ScannerModules );
		if( scannerBlackboard )
		{
			scannerBlackboard.ClearAllFields( false );
		}
	}

	protected event OnlinkedClueTagEvent( evt : linkedClueTagEvent )
	{
		if( evt.tag )
		{
			TagObject( this );
		}
		else
		{
			UntagObject( this );
		}
	}

	public const virtual function CompileScannerChunks() : Bool
	{
		var scannerBlackboard : weak< IBlackboard >;
		var nameChunk : ScannerName;
		var displayName : String;
		var hasValidDisplayName : Bool;
		scannerBlackboard = GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().UI_ScannerModules );
		if( scannerBlackboard )
		{
			displayName = GetDisplayName();
			hasValidDisplayName = IsStringValid( displayName );
			if( !( hasValidDisplayName ) )
			{
				displayName = "";
			}
			if( hasValidDisplayName || ( m_scanningComponent && ( m_scanningComponent.IsAnyClueEnabled() || m_scanningComponent.HasValidObjectDescription() ) ) )
			{
				nameChunk = new ScannerName;
				nameChunk.Set( displayName );
				scannerBlackboard.SetVariant( GetAllBlackboardDefs().UI_ScannerModules.ScannerName, nameChunk, true );
			}
			scannerBlackboard.SetInt( GetAllBlackboardDefs().UI_ScannerModules.ObjectType, ( ( Int32 )( ScannerObjectType.GENERIC ) ), true );
			return true;
		}
		return false;
	}

	protected virtual function FillObjectDescription( out arr : array< ScanningTooltipElementDef > )
	{
		var i : Int32;
		var objectDescription : ObjectScanningDescription;
		var customDescriptionsIDS : array< TweakDBID >;
		var gameplayDescriptionID : TweakDBID;
		var objectData : ScanningTooltipElementDef;
		objectDescription = m_scanningComponent.GetObjectDescription();
		if( objectDescription == NULL )
		{
			return;
		}
		customDescriptionsIDS = objectDescription.GetCustomDesriptions();
		gameplayDescriptionID = objectDescription.GetGameplayDesription();
		if( TDBID.IsValid( gameplayDescriptionID ) )
		{
			objectData.recordID = gameplayDescriptionID;
			arr.PushBack( objectData );
		}
		if( customDescriptionsIDS.Size() != 0 )
		{
			for( i = 0; i < customDescriptionsIDS.Size(); i += 1 )
			{
				objectData.recordID = customDescriptionsIDS[ i ];
				arr.PushBack( objectData );
			}
		}
	}

	public export virtual function GetScannableObjects() : array< ScanningTooltipElementDef >
	{
		var clueIndex : Int32;
		var conclusionData : ScanningTooltipElementDef;
		var arr : array< ScanningTooltipElementDef >;
		if( m_scanningComponent != NULL )
		{
			clueIndex = m_scanningComponent.GetAvailableClueIndex();
			if( clueIndex >= 0 )
			{
				arr = m_scanningComponent.GetScannableDataForSingleClueByIndex( clueIndex, conclusionData );
				ResolveFocusClueExtendedDescription( clueIndex );
				ResolveFocusClueConclusion( clueIndex, conclusionData );
			}
			if( m_scanningComponent.IsObjectDescriptionEnabled() )
			{
				FillObjectDescription( arr );
			}
			if( IsScannerDataDirty() )
			{
				CompileScannerChunks();
				SetScannerDirty( false );
			}
		}
		return arr;
	}

	public const virtual function ShouldShowScanner() : Bool
	{
		if( !( m_scanningComponent ) )
		{
			return false;
		}
		if( GetHudManager().IsBraindanceActive() && !( m_scanningComponent.IsBraindanceClue() ) )
		{
			return false;
		}
		if( m_scanningComponent.IsBraindanceBlocked() || m_scanningComponent.IsPhotoModeBlocked() )
		{
			return false;
		}
		if( !( m_scanningComponent.HasValidObjectDescription() ) && ( !( m_scanningComponent.IsAnyClueEnabled() ) || IsScaningCluesBlocked() ) )
		{
			return false;
		}
		return true;
	}

	public const virtual function IsScaningCluesBlocked() : Bool
	{
		if( m_scanningComponent )
		{
			return m_scanningComponent.IsScanningCluesBlocked();
		}
		return false;
	}

	public const function IsBraindanceBlocked() : Bool
	{
		if( m_scanningComponent )
		{
			return m_scanningComponent.IsBraindanceBlocked();
		}
		return false;
	}

	public const function IsPhotoModeBlocked() : Bool
	{
		return GameInstance.GetPhotoModeSystem( GetGame() ).IsPhotoModeActive();
	}

	private function ResolveFocusClueExtendedDescription( clueIndex : Int32 )
	{
		var i : Int32;
		var clueRecords : array< ClueRecordData >;
		if( m_scanningComponent != NULL )
		{
			clueRecords = m_scanningComponent.GetExtendedClueRecords( clueIndex );
			for( i = 0; i < clueRecords.Size(); i += 1 )
			{
				if( !( clueRecords[ i ].wasInspected ) && ( clueRecords[ i ].percentage >= m_scanningComponent.GetScanningProgress() ) )
				{
					ResolveFacts( clueRecords[ i ].facts );
					m_scanningComponent.SetClueExtendedDescriptionAsInspected( clueIndex, i );
				}
			}
		}
	}

	private function ResolveFocusClueConclusion( clueIndex : Int32, conclusionData : ScanningTooltipElementDef )
	{
		var clue : FocusClueDefinition;
		if( m_scanningComponent != NULL )
		{
			if( clueIndex < 0 )
			{
				return;
			}
			if( !( TDBID.IsValid( conclusionData.recordID ) ) )
			{
				return;
			}
			if( !( m_scanningComponent.WasConclusionShown( clueIndex ) ) && ( conclusionData.timePct >= m_scanningComponent.GetScanningProgress() ) )
			{
				clue = m_scanningComponent.GetClueByIndex( clueIndex );
				ResolveFacts( clue.facts );
				m_scanningComponent.SetConclusionAsShown( clueIndex );
			}
		}
	}

	protected function ResolveFacts( facts : array< SFactOperationData > )
	{
		var i : Int32;
		for( i = 0; i < facts.Size(); i += 1 )
		{
			if( IsNameValid( facts[ i ].factName ) )
			{
				if( facts[ i ].operationType == EMathOperationType.Add )
				{
					AddFact( GetGame(), facts[ i ].factName, facts[ i ].factValue );
				}
				else
				{
					SetFactValue( GetGame(), facts[ i ].factName, facts[ i ].factValue );
				}
			}
		}
	}

	public const function GetFocusClueSystem() : FocusCluesSystem
	{
		return ( ( FocusCluesSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'FocusCluesSystem' ) ) );
	}

	public const function IsAnyClueEnabled() : Bool
	{
		if( m_scanningComponent )
		{
			return m_scanningComponent.IsAnyClueEnabled();
		}
		else
		{
			return false;
		}
	}

	protected const function IsCurrentTarget() : Bool
	{
		var lookedAtObect : GameObject;
		lookedAtObect = GameInstance.GetTargetingSystem( GetGame() ).GetLookAtObject( ( ( PlayerPuppet )( GameInstance.GetPlayerSystem( GetGame() ).GetLocalPlayerMainGameObject() ) ) );
		if( lookedAtObect == NULL )
		{
			return false;
		}
		return lookedAtObect.GetEntityID() == GetEntityID();
	}

	protected const function IsCurrentlyScanned() : Bool
	{
		var blackBoard : IBlackboard;
		var entityID : EntityID;
		blackBoard = GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().UI_Scanner );
		entityID = blackBoard.GetEntityID( GetAllBlackboardDefs().UI_Scanner.ScannedObject );
		return GetEntityID() == entityID;
	}

	public const virtual function GetFreeWorkspotRefForAIAction( aiAction : gamedataWorkspotActionType ) : NodeRef
	{
		var worskpotRef : NodeRef;
		if( m_workspotMapper != NULL )
		{
			worskpotRef = m_workspotMapper.GetFreeWorkspotRefForAIAction( aiAction );
		}
		return worskpotRef;
	}

	public const virtual function GetFreeWorkspotDataForAIAction( aiAction : gamedataWorkspotActionType ) : WorkspotEntryData
	{
		var worskpotData : WorkspotEntryData;
		if( m_workspotMapper != NULL )
		{
			worskpotData = m_workspotMapper.GetFreeWorkspotDataForAIAction( aiAction );
		}
		return worskpotData;
	}

	public const virtual function HasFreeWorkspotForInvestigation() : Bool
	{
		var worskpotData : WorkspotEntryData;
		if( m_workspotMapper != NULL )
		{
			worskpotData = m_workspotMapper.GetFreeWorkspotDataForAIAction( gamedataWorkspotActionType.DeviceInvestigation );
		}
		return worskpotData != NULL;
	}

	public const virtual function GetFreeWorkspotsCountForAIAction( aiAction : gamedataWorkspotActionType ) : Int32
	{
		var numberOfWorkspots : Int32;
		if( m_workspotMapper != NULL )
		{
			numberOfWorkspots = m_workspotMapper.GetFreeWorkspotsCountForAIAction( aiAction );
		}
		return numberOfWorkspots;
	}

	public const virtual function GetNumberOfWorkpotsForAIAction( aiAction : gamedataWorkspotActionType ) : Int32
	{
		var numberOfWorkspots : Int32;
		if( m_workspotMapper != NULL )
		{
			numberOfWorkspots = m_workspotMapper.GetNumberOfWorkpotsForAIAction( aiAction );
		}
		return numberOfWorkspots;
	}

	public const function GetTotalCountOfInvestigationSlots() : Int32
	{
		var count : Int32;
		count = GetNumberOfWorkpotsForAIAction( gamedataWorkspotActionType.DeviceInvestigation );
		if( count == 0 )
		{
			count = 1;
		}
		return count;
	}

	public const function GetStimBroadcasterComponent() : StimBroadcasterComponent
	{
		return m_stimBroadcaster;
	}

	public import const function GetUISlotComponent() : SlotComponent;

	public const function GetSquadMemberComponent() : SquadMemberBaseComponent
	{
		return m_squadMemberComponent;
	}

	public const function GetStatusEffectComponent() : StatusEffectComponent
	{
		return m_statusEffectComponent;
	}

	public const function GetSourceShootComponent() : SourceShootComponent
	{
		return m_sourceShootComponent;
	}

	public const function GetTargetShootComponent() : TargetShootComponent
	{
		return m_targetShootComponent;
	}

	public import final function ReplicateAnimFeature( obj : GameObject, inputName : CName, value : AnimFeature );

	public final function OnAnimFeatureReplicated( inputName : CName, value : AnimFeature )
	{
		AnimationControllerComponent.ApplyFeature( this, inputName, value );
	}

	public import final function ReplicateAnimEvent( obj : GameObject, eventName : CName );

	public final function OnAnimEventReplicated( eventName : CName )
	{
		AnimationControllerComponent.PushEvent( this, eventName );
	}

	public import final function ReplicateInputFloat( obj : GameObject, inputName : CName, value : Float );
	public import final function ReplicateInputBool( obj : GameObject, inputName : CName, value : Bool );
	public import final function ReplicateInputInt( obj : GameObject, inputName : CName, value : Int32 );
	public import final function ReplicateInputVector( obj : GameObject, inputName : CName, value : Vector4 );

	public const virtual function GetPlaystyleMappinLocalPos() : Vector4
	{
		var pos : Vector4;
		return pos;
	}

	public const virtual function GetPlaystyleMappinSlotWorldPos() : Vector4
	{
		return GetWorldPosition();
	}

	public const virtual function GetPlaystyleMappinSlotWorldTransform() : WorldTransform
	{
		var transform : WorldTransform;
		WorldTransform.SetPosition( transform, GetWorldPosition() );
		WorldTransform.SetOrientation( transform, GetWorldOrientation() );
		return transform;
	}

	public const virtual function GetFxResourceByKey( key : CName ) : FxResource
	{
		var resource : FxResource;
		return resource;
	}

	protected event OnDelayPrereqEvent( evt : DelayPrereqEvent )
	{
		evt.m_state.UpdatePrereq();
	}

	protected event OnTriggerAttackEffectorWithDelay( evt : TriggerAttackEffectorWithDelay )
	{
		if( evt.attack )
		{
			evt.attack.StartAttack();
		}
	}

	protected event OnToggleOffMeshConnections( evt : ToggleOffMeshConnections )
	{
		if( evt.enable )
		{
			EnableOffMeshConnections( evt.affectsPlayer, evt.affectsNPCs );
		}
		else
		{
			DisableOffMeshConnections( evt.affectsPlayer, evt.affectsNPCs );
		}
	}

	protected virtual function EnableOffMeshConnections( player : Bool, npc : Bool ) {}

	protected virtual function DisableOffMeshConnections( player : Bool, npc : Bool ) {}

	protected event OnPhysicalDestructionEvent( evt : PhysicalDestructionEvent )
	{
		if( m_stimBroadcaster )
		{
			m_stimBroadcaster.TriggerSingleBroadcast( this, gamedataStimType.SoundDistraction );
		}
	}

	public const function GetHudManager() : HUDManager
	{
		return ( ( HUDManager )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'HUDManager' ) ) );
	}

	protected function TriggerMenuEvent( eventName : CName )
	{
		var currentEventName : CName;
		var blackboard : IBlackboard;
		blackboard = GameInstance.GetBlackboardSystem( GetGame() ).Get( GetAllBlackboardDefs().MenuEventBlackboard );
		if( blackboard )
		{
			currentEventName = blackboard.GetName( GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger );
			if( IsNameValid( currentEventName ) )
			{
				blackboard.SetName( GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, '' );
			}
			blackboard.SetName( GetAllBlackboardDefs().MenuEventBlackboard.MenuEventToTrigger, eventName );
		}
	}

	public const virtual function GetAcousticQuerryStartPoint() : Vector4
	{
		return GetWorldPosition();
	}

	public const virtual function CanBeInvestigated() : Bool
	{
		return true;
	}

	public static function IsVehicle( object : weak< GameObject > ) : Bool
	{
		return ( ( VehicleObject )( object ) ) != NULL;
	}

	public const function GetPreventionSystem() : PreventionSystem
	{
		return ( ( PreventionSystem )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'PreventionSystem' ) ) );
	}

	public const virtual function GetLootQuality() : gamedataQuality
	{
		return gamedataQuality.Invalid;
	}

	public const virtual function GetIsIconic() : Bool
	{
		return false;
	}

	public const function GetAnimationSystemForcedVisibilityManager() : AnimationSystemForcedVisibilityManager
	{
		return ( ( AnimationSystemForcedVisibilityManager )( GameInstance.GetScriptableSystemsContainer( GetGame() ).Get( 'AnimationSystemForcedVisibilityManager' ) ) );
	}

	public static function ToggleForcedVisibilityInAnimSystemEvent( owner : GameObject, sourceName : CName, isVisibe : Bool, optional transitionTime : Float )
	{
		var evt : ToggleVisibilityInAnimSystemEvent;
		if( ( owner == NULL ) || !( IsNameValid( sourceName ) ) )
		{
			return;
		}
		evt = new ToggleVisibilityInAnimSystemEvent;
		evt.isVisible = isVisibe;
		evt.sourceName = sourceName;
		evt.transitionTime = transitionTime;
		owner.QueueEvent( evt );
	}

	protected function ToggleForcedVisibilityInAnimSystem( sourceName : CName, isVisibe : Bool, optional transitionTime : Float, optional entityID : EntityID, optional forcedVisibleOnlyInFrustum : Bool )
	{
		var request : ToggleVisibilityInAnimSystemRequest;
		if( !( IsNameValid( sourceName ) ) )
		{
			return;
		}
		request = new ToggleVisibilityInAnimSystemRequest;
		request.isVisible = isVisibe;
		request.sourceName = sourceName;
		request.transitionTime = transitionTime;
		request.forcedVisibleOnlyInFrustum = forcedVisibleOnlyInFrustum;
		if( EntityID.IsDefined( entityID ) )
		{
			request.entityID = entityID;
		}
		else
		{
			request.entityID = GetEntityID();
		}
		m_hasVisibilityForcedInAnimSystem = isVisibe;
		GetAnimationSystemForcedVisibilityManager().QueueRequest( request );
	}

	protected function ClearForcedVisibilityInAnimSystem()
	{
		var request : ClearVisibilityInAnimSystemRequest;
		request = new ClearVisibilityInAnimSystemRequest;
		request.entityID = GetEntityID();
		GetAnimationSystemForcedVisibilityManager().QueueRequest( request );
		m_hasVisibilityForcedInAnimSystem = false;
	}

	protected function HasVisibilityForcedInAnimSystem() : Bool
	{
		return m_hasVisibilityForcedInAnimSystem || GetAnimationSystemForcedVisibilityManager().HasVisibilityForced( GetEntityID() );
	}

	protected event OnToggleVisibilityInAnimSystemEvent( evt : ToggleVisibilityInAnimSystemEvent )
	{
		ToggleForcedVisibilityInAnimSystem( evt.sourceName, evt.isVisible, evt.transitionTime );
	}

	protected event OnSetGlitchOnUIEvent( evt : SetGlitchOnUIEvent )
	{
		var glitchEvt : AdvertGlitchEvent;
		glitchEvt = new AdvertGlitchEvent;
		glitchEvt.SetShouldGlitch( evt.intensity );
		QueueEvent( glitchEvt );
	}

	protected event OnCustomUIAnimationEvent( evt : CustomUIAnimationEvent )
	{
		evt.ownerID = GetEntityID();
		GameInstance.GetUISystem( GetGame() ).QueueEvent( evt );
	}

	protected event OnSmartGunLockEvent( evt : SmartGunLockEvent )
	{
		if( evt.lockedOnByPlayer )
		{
			SendForceRevealObjectEvent( evt.locked, 'SmartGunLock' );
		}
	}

	protected event OnAutoSaveEvent( evt : AutoSaveEvent )
	{
		if( evt.maxAttempts > 0 )
		{
			evt.maxAttempts -= 1;
		}
		if( !( RequestAutoSave( evt.isForced ) ) && ( evt.maxAttempts > 0 ) )
		{
			GameInstance.GetDelaySystem( GetGame() ).DelayEventNextFrame( this, evt );
		}
	}

	private function RequestAutoSaveWithDelay( value : Float, maxAttempts : Int32, isForced : Bool )
	{
		var evt : AutoSaveEvent;
		if( value <= 0.0 )
		{
			RequestAutoSave( isForced );
		}
		else
		{
			evt = new AutoSaveEvent;
			evt.maxAttempts = maxAttempts;
			evt.isForced = isForced;
			GameInstance.GetDelaySystem( GetGame() ).DelayEvent( this, evt, value, false );
		}
	}

	private function RequestAutoSave( isForced : Bool ) : Bool
	{
		if( isForced )
		{
			return GameInstance.GetAutoSaveSystem( GetGame() ).RequestForcedAutoSave();
		}
		else
		{
			return GameInstance.GetAutoSaveSystem( GetGame() ).RequestCheckpoint();
		}
	}

}

class DeathTaskData extends ScriptTaskData
{
	var instigator : weak< GameObject >;
}

class HitInstigatorCooldownEvent extends Event
{
	var instigatorID : EntityID;
}

class SetGlitchOnUIEvent extends Event
{
	[ rangeMin = "0.f" ][ rangeMax = "1.f" ]
	editable var intensity : Float;

	public constexpr function GetFriendlyDescription() : String
	{
		return "Set Glitch On UI";
	}

}

class AutoSaveEvent extends Event
{
	var maxAttempts : Int32;
	default maxAttempts = 1;
	var isForced : Bool;
}

class ToggleVisibilityInAnimSystemEvent extends Event
{
	var isVisible : Bool;
	var sourceName : CName;
	var transitionTime : Float;
}

class SetLogicReadyEvent extends Event
{
	var isReady : Bool;
}

class ResponseEvent extends Event
{
	var responseData : IScriptable;
}

class FakeUpdateEvent extends TickableEvent
{
}

class ResloveFocusClueDescriptionEvent extends Event
{
}

class Record1DamageInHistoryEvent extends Event
{
	var source : weak< GameObject >;
}

class ChangeRewardSettingsEvent extends Event
{
	var forceDefeatReward : Bool;
	var disableKillReward : Bool;
}

class DebugOutlineEvent extends Event
{
	var type : EOutlineType;
	var opacity : Float;
	var requester : EntityID;
	var duration : Float;
}

class OnAttachedEvent extends Event
{
}

class ToggleOffMeshConnections extends Event
{
	var enable : Bool;
	var affectsPlayer : Bool;
	var affectsNPCs : Bool;
}

class OutlineRequestEvent extends Event
{
	var outlineRequest : OutlineRequest;
	var flag : Bool;
}

struct OutlineData
{
	var outlineType : EOutlineType;
	var outlineOpacity : Float;
}

class OutlineRequest
{
	private var m_requester : CName;
	private var m_outlineDuration : Float;
	private var m_outlineData : OutlineData;

	public static function CreateRequest( requester : CName, data : OutlineData, optional expectedDuration : Float ) : OutlineRequest
	{
		var newRequest : OutlineRequest;
		newRequest = new OutlineRequest;
		newRequest.m_requester = requester;
		newRequest.m_outlineDuration = expectedDuration;
		data.outlineOpacity = MaxF( data.outlineOpacity, 0.2 );
		expectedDuration = MaxF( expectedDuration, 0.1 );
		newRequest.m_outlineData = data;
		return newRequest;
	}

	public const function GetRequester() : CName
	{
		return m_requester;
	}

	public const function GetData() : OutlineData
	{
		return m_outlineData;
	}

	public const function GetRequestType() : EOutlineType
	{
		return m_outlineData.outlineType;
	}

	public const function GetRequestOpacity() : Float
	{
		return m_outlineData.outlineOpacity;
	}

	public const function GetOutlineDuration() : Float
	{
		return m_outlineDuration;
	}

	public function UpdateData( newData : OutlineData )
	{
		m_outlineData = newData;
	}

}

class GameObjectListener
{
	var prereqOwner : PrereqState;
	var e3HackBlock : Bool;

	public function RegisterOwner( owner : PrereqState ) : Bool
	{
		if( !( prereqOwner ) )
		{
			prereqOwner = owner;
			return true;
		}
		return false;
	}

	public function ModifyOwner( owner : PrereqState )
	{
		prereqOwner = owner;
	}

	public function OnRevealAccessPoint( shouldReveal : Bool )
	{
		if( ( ( RevealAccessPointPrereqState )( prereqOwner ) ) )
		{
			prereqOwner.OnChanged( shouldReveal );
		}
	}

	public function OnStatusEffectTrigger( shouldTrigger : Bool )
	{
		if( ( ( StatPoolPrereqState )( prereqOwner ) ) )
		{
			prereqOwner.OnChanged( shouldTrigger );
		}
	}

}

class AddOrRemoveListenerForGOEvent extends Event
{
	var listener : GameObjectListener;
	var shouldAdd : Bool;
}

class AddStatusEffectListenerEvent extends Event
{
	var listener : StatusEffectTriggerListener;
}

class RemoveStatusEffectListenerEvent extends Event
{
	var listener : StatusEffectTriggerListener;
}

class GameAttachedEvent extends Event
{
	var isGameplayRelevant : Bool;
	var displayName : String;
	var contentScale : TweakDBID;
}

importonly final class GameObjectEffectHelper extends IScriptable
{
	public import static function ActivateEffectAction( obj : weak< GameObject >, actionType : gamedataFxActionType, fxName : CName, optional fxBlackboard : worldEffectBlackboard, optional startOnlyIfNotStarted : Bool );
	public import static function StartEffectEvent( obj : GameObject, effectName : CName, optional shouldPersist : Bool, optional blackboard : worldEffectBlackboard, optional startOnlyIfNotStarted : Bool );
	public import static function BreakEffectLoopEvent( obj : GameObject, effectName : CName );
	public import static function StopEffectEvent( obj : GameObject, effectName : CName );
}

enum EOutlineType
{
	NONE = 0,
	GREEN = 1,
	RED = 2,
}

operator+( s : String, o : GameObject ) : String
{
	return s + o.GetDisplayName();
}

operator+( o : GameObject, s : String ) : String
{
	return o.GetDisplayName() + s;
}

exec function ForceOutline( gameInstance : GameInstance, color : String, opacity : String )
{
	var targetSystem : TargetingSystem;
	var target : GameObject;
	var distance : EulerAngles;
	var dbgOutlineEvent : DebugOutlineEvent;
	var opacityValue : Float;
	var localPlayerObject : GameObject;
	dbgOutlineEvent = new DebugOutlineEvent;
	opacityValue = StringToFloat( opacity );
	targetSystem = GameInstance.GetTargetingSystem( gameInstance );
	localPlayerObject = GameInstance.GetPlayerSystem( gameInstance ).GetLocalPlayerMainGameObject();
	target = targetSystem.GetObjectClosestToCrosshair( localPlayerObject, distance, TSQ_NPC() );
	if( StrLower( color ) == "green" )
	{
		dbgOutlineEvent.type = EOutlineType.GREEN;
	}
	else if( StrLower( color ) == "red" )
	{
		dbgOutlineEvent.type = EOutlineType.RED;
	}
	else if( StrLower( color ) == "none" || StrLower( color ) == "false" )
	{
		dbgOutlineEvent.type = EOutlineType.NONE;
	}
	dbgOutlineEvent.opacity = opacityValue;
	dbgOutlineEvent.requester = localPlayerObject.GetEntityID();
	dbgOutlineEvent.duration = 2.0;
	target.QueueEvent( dbgOutlineEvent );
}

exec function PlayRumble( gameInstance : GameInstance, presetName : String )
{
	var rumbleName : CName;
	rumbleName = TDB.GetCName( TDBID.Create( "rumble.local." + presetName ) );
	GameObject.PlaySound( ( ( PlayerPuppet )( GameInstance.GetPlayerSystem( gameInstance ).GetLocalPlayerMainGameObject() ) ), rumbleName );
}

