class sampleSmartBullet extends BaseProjectile
{
	private var m_meshComponent : IComponent;
	private editable var m_effect : EffectRef;
	private var m_countTime : Float;
	default m_countTime = 0;
	private var m_startVelocity : Float;
	private editable var m_lifetime : Float;
	private editable var m_bendTimeRatio : Float;
	private editable var m_bendFactor : Float;
	private editable var m_useParabolicPhase : Bool;
	default m_useParabolicPhase = false;
	private editable var m_parabolicVelocityMin : Float;
	private editable var m_parabolicVelocityMax : Float;
	private editable var m_parabolicDuration : Float;
	private editable var m_parabolicGravity : Vector4;
	private var m_spiralParams : SpiralControllerParams;
	private var m_useSpiralParams : Bool;
	private var m_alive : Bool;
	default m_alive = true;
	private var m_hit : Bool;
	default m_hit = false;
	private var m_trailName : CName;
	var m_statsSystem : StatsSystem;
	var m_weaponID : EntityID;
	var m_parabolicPhaseParams : ParabolicTrajectoryParams;
	var m_followPhaseParams : FollowCurveTrajectoryParams;
	var m_linearPhaseParams : LinearTrajectoryParams;
	var m_targeted : Bool;
	var m_trailStarted : Bool;
	var m_phase : ESmartBulletPhase;
	var m_timeInPhase : Float;
	private var m_randStartVelocity : Float;
	private var m_smartGunMissDelay : Float;
	private var m_smartGunHitProbability : Float;
	private var m_smartGunMissRadius : Float;
	private var m_randomWeaponMissChance : Float;
	private var m_randomTargetMissChance : Float;
	private var m_readyToMiss : Bool;
	private editable var m_stopAndDropOnTargetingDisruption : Bool;
	default m_stopAndDropOnTargetingDisruption = false;
	private var m_shouldStopAndDrop : Bool;
	private var m_targetID : EntityID;
	private var m_ignoredTargetID : EntityID;
	private var m_owner : weak< GameObject >;
	private var m_weapon : weak< GameObject >;
	private var m_startPosition : Vector4;
	private var m_hasExploded : Bool;
	private var m_attack : IAttack;
	private var m_BulletCollisionEvaluator : BulletCollisionEvaluator;

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		super.OnRequestComponents( ri );
		EntityRequestComponentsInterface.RequestComponent( ri, 'MeshComponent', 'IComponent', true );
	}

	protected event OnTakeControl( ri : EntityResolveComponentsInterface )
	{
		super.OnTakeControl( ri );
		m_meshComponent = EntityResolveComponentsInterface.GetComponent( ri, 'MeshComponent' );
		m_spiralParams = new SpiralControllerParams;
		m_spiralParams.rampUpDistanceStart = 0.40000001;
		m_spiralParams.rampUpDistanceEnd = 1.0;
		m_spiralParams.rampDownDistanceStart = 7.5;
		m_spiralParams.rampDownDistanceEnd = 5.0;
		m_spiralParams.rampDownFactor = 1.0;
		m_spiralParams.randomizePhase = true;
	}

	protected event OnProjectileInitialize( eventData : gameprojectileSetUpEvent )
	{
		var velVariance : Float;
		m_projectileComponent.ToggleAxisRotation( true );
		m_projectileComponent.AddAxisRotation( Vector4( 0.0, 1.0, 0.0, 0.0 ), 100.0 );
		m_owner = eventData.owner;
		m_weapon = eventData.weapon;
		m_BulletCollisionEvaluator = new BulletCollisionEvaluator;
		m_projectileComponent.SetCollisionEvaluator( m_BulletCollisionEvaluator );
		if( m_weapon )
		{
			m_statsSystem = GameInstance.GetStatsSystem( m_weapon.GetGame() );
			m_weaponID = m_weapon.GetEntityID();
			m_attack = ( ( WeaponObject )( m_weapon ) ).GetCurrentAttack();
			m_useSpiralParams = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunAddSpiralTrajectory ) > 0.0;
			m_spiralParams.radius = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunSpiralRadius );
			m_spiralParams.cycleTimeMin = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunSpiralCycleTimeMin );
			m_spiralParams.cycleTimeMax = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunSpiralCycleTimeMax );
			m_spiralParams.randomizeDirection = ( ( Bool )( m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunSpiralRandomizeDirection ) ) );
			if( eventData.owner.IsNPC() )
			{
				m_startVelocity = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunNPCProjectileVelocity );
			}
			else if( eventData.owner.IsPlayer() )
			{
				m_startVelocity = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunPlayerProjectileVelocity );
			}
			velVariance = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunProjectileVelocityVariance );
			m_randStartVelocity = RandRangeF( m_startVelocity - ( m_startVelocity * velVariance ), m_startVelocity + ( m_startVelocity * velVariance ) );
			m_randStartVelocity = MaxF( 1.0, m_randStartVelocity );
			m_smartGunHitProbability = ClampF( m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunHitProbability ), 0.0, 1.0 );
			if( m_owner && m_statsSystem )
			{
				m_smartGunHitProbability *= ( 1.0 + m_statsSystem.GetStatValue( m_owner.GetEntityID(), gamedataStatType.SmartGunHitProbabilityMultiplier ) );
				m_smartGunHitProbability = ClampF( m_smartGunHitProbability, 0.0, 1.0 );
			}
			m_smartGunMissDelay = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunMissDelay );
			m_smartGunMissRadius = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.SmartGunMissRadius );
			m_smartGunMissRadius = m_smartGunMissRadius * RandRangeF( 0.66000003, 1.0 );
		}
		else
		{
			m_spiralParams.enabled = false;
			m_spiralParams.radius = 0.01;
			m_spiralParams.cycleTimeMin = 0.1;
			m_spiralParams.cycleTimeMax = 0.1;
			m_randStartVelocity = 50.0;
			m_startVelocity = 50.0;
			m_useSpiralParams = false;
		}
		SetCurrentDamageTrailName();
	}

	private function StartTrailEffect()
	{
		if( !( m_trailStarted ) )
		{
			GameObjectEffectHelper.StartEffectEvent( this, m_trailName, true );
			m_trailStarted = true;
		}
	}

	private function Reset()
	{
		m_countTime = 0.0;
		m_alive = true;
		m_hit = false;
		m_timeInPhase = 0.0;
		m_phase = ESmartBulletPhase.Init;
		m_targeted = false;
		m_trailStarted = false;
		m_readyToMiss = false;
		m_hasExploded = false;
		m_targetID = EMPTY_ENTITY_ID();
		m_ignoredTargetID = EMPTY_ENTITY_ID();
	}

	protected event OnShoot( eventData : gameprojectileShootEvent )
	{
		Reset();
		m_targeted = false;
		m_startPosition = eventData.startPoint;
		SetupCommonParams( eventData.weaponVelocity );
		m_followPhaseParams = new FollowCurveTrajectoryParams;
		StartNextPhase();
		m_projectileComponent.SetOnCollisionAction( gameprojectileOnCollisionAction.Stop );
	}

	private function SetCurrentDamageTrailName()
	{
		var cachedThreshold : Float;
		m_weaponID = m_owner.GetEntityID();
		cachedThreshold = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.PhysicalDamage );
		m_trailName = 'trail';
		if( m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ThermalDamage ) > cachedThreshold )
		{
			cachedThreshold = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ThermalDamage );
			m_trailName = 'trail_thermal';
		}
		if( m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ElectricDamage ) > cachedThreshold )
		{
			cachedThreshold = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ElectricDamage );
			m_trailName = 'trail_electric';
		}
		if( m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ChemicalDamage ) > cachedThreshold )
		{
			cachedThreshold = m_statsSystem.GetStatValue( m_weaponID, gamedataStatType.ChemicalDamage );
			m_trailName = 'trail_chemical';
		}
	}

	protected event OnShootTarget( eventData : gameprojectileShootTargetEvent )
	{
		var slotTransform : WorldTransform;
		var slotComponent : SlotComponent;
		var targetEntity : weak< Entity >;
		Reset();
		m_targeted = true;
		m_startPosition = eventData.startPoint;
		m_randomWeaponMissChance = RandF();
		m_randomTargetMissChance = RandF();
		if( eventData.params.trackedTargetComponent )
		{
			m_targetID = eventData.params.trackedTargetComponent.GetEntity().GetEntityID();
		}
		SetupCommonParams( eventData.weaponVelocity );
		m_followPhaseParams = new FollowCurveTrajectoryParams;
		m_followPhaseParams.targetComponent = eventData.params.trackedTargetComponent;
		m_followPhaseParams.targetPosition = eventData.params.targetPosition;
		slotComponent = ( ( SlotComponent )( eventData.params.trackedTargetComponent ) );
		if( slotComponent )
		{
			slotComponent.GetSlotTransform( 'Head', slotTransform );
			m_followPhaseParams.offset = WorldPosition.ToVector4( WorldTransform.GetWorldPosition( slotTransform ) ) - Matrix.GetTranslation( eventData.params.trackedTargetComponent.GetLocalToWorld() );
		}
		if( m_followPhaseParams.targetComponent )
		{
			targetEntity = m_followPhaseParams.targetComponent.GetEntity();
			if( targetEntity )
			{
				m_targetID = targetEntity.GetEntityID();
				if( ( GetInitialDistanceToTarget() > 4.0 ) && ( m_randomTargetMissChance < ClampF( m_statsSystem.GetStatValue( m_targetID, gamedataStatType.SmartTargetingDisruptionProbability ), 0.0, 1.0 ) ) )
				{
					DisableTargetCollisions( m_targetID );
				}
			}
		}
		m_followPhaseParams.startVelocity = m_randStartVelocity;
		m_followPhaseParams.offsetInPlane = eventData.params.smartGunSpreadOnHitPlane;
		m_followPhaseParams.returnTimeMargin = 0.0;
		m_followPhaseParams.accuracy = 0.01;
		m_followPhaseParams.bendTimeRatio = m_bendTimeRatio;
		m_followPhaseParams.bendFactor = m_bendFactor;
		m_followPhaseParams.interpolationTimeRatio = 0.1;
		m_followPhaseParams.offset += eventData.params.hitPlaneOffset;
		StartNextPhase();
		m_projectileComponent.SetOnCollisionAction( gameprojectileOnCollisionAction.Stop );
	}

	private function SetupCommonParams( weaponVel : Vector4 )
	{
		var randVel : Float;
		randVel = RandRangeF( m_parabolicVelocityMin, m_parabolicVelocityMax );
		m_parabolicPhaseParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams( m_parabolicGravity, Vector4.Length( weaponVel ) + randVel );
		m_linearPhaseParams = new LinearTrajectoryParams;
		m_linearPhaseParams.startVel = m_randStartVelocity;
		m_spiralParams.enabled = false;
		m_projectileComponent.SetSpiral( m_spiralParams );
	}

	private function StartPhase( phase : ESmartBulletPhase )
	{
		var prevPhase : ESmartBulletPhase;
		var missParamsRecord : SmartGunMissParams_Record;
		var missSpiral : SpiralControllerParams;
		var desiredTransform : Transform;
		var localToWorld : Matrix;
		var leftSideMiss : Bool;
		var randomYaw : Float;
		var randomPitch : Float;
		var rotation : EulerAngles;
		if( m_phase != phase )
		{
			prevPhase = m_phase;
			m_phase = phase;
			m_projectileComponent.ClearTrajectories();
			m_timeInPhase = 0.0;
			if( m_phase == ESmartBulletPhase.Parabolic )
			{
				m_projectileComponent.AddParabolic( m_parabolicPhaseParams );
				m_projectileComponent.LockOrientation( true );
			}
			else if( m_phase == ESmartBulletPhase.Follow )
			{
				m_projectileComponent.AddFollowCurve( m_followPhaseParams );
				m_projectileComponent.LockOrientation( false );
				if( m_useSpiralParams )
				{
					m_spiralParams.enabled = true;
					m_projectileComponent.SetSpiral( m_spiralParams );
				}
				StartTrailEffect();
			}
			else if( m_phase == ESmartBulletPhase.Linear )
			{
				m_projectileComponent.AddLinear( m_linearPhaseParams );
				m_projectileComponent.LockOrientation( false );
				StartTrailEffect();
			}
			else if( m_phase == ESmartBulletPhase.Miss )
			{
				missParamsRecord = TweakDBInterface.GetSmartGunMissParamsRecord( T"SmartGun.SmartGunMissParams_Default" );
				if( m_shouldStopAndDrop )
				{
					m_parabolicPhaseParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams( Vector4( 0.0, 0.0, missParamsRecord.Gravity(), 0.0 ), 0.0 );
					m_projectileComponent.AddParabolic( m_parabolicPhaseParams );
					m_projectileComponent.LockOrientation( true );
					m_shouldStopAndDrop = false;
				}
				else
				{
					localToWorld = m_projectileComponent.GetLocalToWorld();
					leftSideMiss = RandRange( 0, 2 ) == 0;
					randomYaw = ( ( leftSideMiss ) ? ( RandRangeF( missParamsRecord.AreaToIgnoreHalfYaw(), missParamsRecord.MaxMissAngleYaw() ) ) : ( RandRangeF( -( missParamsRecord.AreaToIgnoreHalfYaw() ), missParamsRecord.MinMissAngleYaw() ) ) );
					randomPitch = RandRangeF( missParamsRecord.MinMissAnglePitch(), missParamsRecord.MaxMissAnglePitch() );
					rotation = Matrix.GetRotation( localToWorld );
					rotation.Yaw += randomYaw;
					rotation.Pitch += randomPitch;
					Transform.SetPosition( desiredTransform, Matrix.GetTranslation( localToWorld ) );
					Transform.SetOrientationEuler( desiredTransform, rotation );
					m_projectileComponent.SetDesiredTransform( desiredTransform );
					if( m_useSpiralParams )
					{
						missSpiral = new SpiralControllerParams;
						missSpiral.enabled = true;
						missSpiral.rampUpDistanceStart = missParamsRecord.SpiralRampUpDistanceStart();
						missSpiral.rampUpDistanceEnd = missParamsRecord.SpiralRampUpDistanceEnd();
						missSpiral.radius = missParamsRecord.SpiralRadius();
						missSpiral.cycleTimeMin = missParamsRecord.SpiralCycleTimeMin();
						missSpiral.cycleTimeMax = missParamsRecord.SpiralCycleTimeMax();
						missSpiral.rampDownDistanceStart = missParamsRecord.SpiralRampDownDistanceStart();
						missSpiral.rampDownDistanceEnd = missParamsRecord.SpiralRampDownDistanceEnd();
						missSpiral.rampDownFactor = missParamsRecord.SpiralRampDownFactor();
						missSpiral.randomizePhase = missParamsRecord.SpiralRandomizePhase();
						m_projectileComponent.SetSpiral( missSpiral );
						m_linearPhaseParams.startVel = m_linearPhaseParams.startVel * RandRangeF( 0.30000001, 0.5 );
					}
					m_projectileComponent.AddLinear( m_linearPhaseParams );
					m_projectileComponent.LockOrientation( false );
				}
				StartTrailEffect();
			}
			if( prevPhase == ESmartBulletPhase.Parabolic )
			{
				GameObjectEffectHelper.StartEffectEvent( this, 'ignition', true );
			}
		}
	}

	private function StartNextPhase()
	{
		if( m_phase == ESmartBulletPhase.Init )
		{
			if( m_useParabolicPhase )
			{
				StartPhase( ESmartBulletPhase.Parabolic );
			}
			else if( m_targeted )
			{
				StartPhase( ESmartBulletPhase.Follow );
			}
			else
			{
				StartPhase( ESmartBulletPhase.Linear );
			}
		}
		else if( m_phase == ESmartBulletPhase.Parabolic )
		{
			if( m_targeted )
			{
				StartPhase( ESmartBulletPhase.Follow );
			}
			else
			{
				StartPhase( ESmartBulletPhase.Linear );
			}
		}
		else if( m_phase == ESmartBulletPhase.Follow )
		{
			if( m_readyToMiss )
			{
				StartPhase( ESmartBulletPhase.Miss );
			}
			else
			{
				StartPhase( ESmartBulletPhase.Linear );
			}
		}
	}

	protected event OnTick( eventData : gameprojectileTickEvent )
	{
		m_countTime += eventData.deltaTime;
		m_timeInPhase += eventData.deltaTime;
		if( m_alive && m_phase == ESmartBulletPhase.Follow )
		{
			UpdateReadyToMiss();
			if( m_readyToMiss )
			{
				StartNextPhase();
			}
		}
		if( ( m_alive && m_phase == ESmartBulletPhase.Parabolic ) && ( m_timeInPhase >= m_parabolicDuration ) )
		{
			StartNextPhase();
		}
		if( m_countTime >= m_lifetime )
		{
			BulletRelease();
		}
		else if( m_countTime >= 0.0666 )
		{
			m_meshComponent.Toggle( true );
		}
	}

	protected event OnCollision( projectileHitEvent : gameprojectileHitEvent )
	{
		var gameObj : GameObject;
		var explosionAttackRecord : Attack_Record;
		var targetHasJammer : Bool;
		var damageHitEvent : gameprojectileHitEvent;
		var hitInstance : gameprojectileHitInstance;
		var i : Int32;
		targetHasJammer = false;
		damageHitEvent = new gameprojectileHitEvent;
		for( i = 0; i < projectileHitEvent.hitInstances.Size(); i += 1 )
		{
			hitInstance = projectileHitEvent.hitInstances[ i ];
			if( m_alive )
			{
				gameObj = ( ( GameObject )( hitInstance.hitObject ) );
				targetHasJammer = gameObj && gameObj.HasTag( 'jammer' );
				if( !( targetHasJammer ) )
				{
					damageHitEvent.hitInstances.PushBack( hitInstance );
				}
				if( ( !( gameObj.HasTag( 'bullet_no_destroy' ) ) && m_BulletCollisionEvaluator.HasReportedStopped() ) && hitInstance.position == m_BulletCollisionEvaluator.GetStoppedPosition() )
				{
					BulletRelease();
					if( !( m_hasExploded ) && m_attack )
					{
						m_hasExploded = true;
						explosionAttackRecord = IAttack.GetExplosiveHitAttack( m_attack.GetRecord() );
						if( explosionAttackRecord )
						{
							Attack_GameEffect.SpawnExplosionAttack( explosionAttackRecord, ( ( WeaponObject )( m_weapon ) ), m_owner, this, hitInstance.position, 0.05 );
						}
					}
					if( !( targetHasJammer ) && !( gameObj.HasTag( 'MeatBag' ) ) )
					{
						m_countTime = 0.0;
						m_alive = false;
						m_hit = true;
						break;
					}
				}
			}
		}
		if( damageHitEvent.hitInstances.Size() > 0 )
		{
			DealDamage( damageHitEvent );
		}
	}

	protected event OnAcceleratedMovement( eventData : gameprojectileAcceleratedMovementEvent ) {}

	protected event OnLinearMovement( eventData : gameprojectileLinearMovementEvent )
	{
		if( !( m_owner ) || !( m_owner.IsPlayer() ) )
		{
			GameInstance.GetAudioSystem( this.GetGame() ).TriggerFlyby( this.GetWorldPosition(), this.GetWorldForward(), m_projectileSpawnPoint, m_weapon );
		}
	}

	private function DealDamage( eventData : gameprojectileHitEvent )
	{
		var damageEffect : EffectInstance;
		damageEffect = m_projectileComponent.GetGameEffectInstance();
		EffectData.SetVariant( damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, eventData );
		damageEffect.Run();
	}

	protected event OnFollowSuccess( eventData : gameprojectileFollowEvent )
	{
		if( !( m_hit ) )
		{
			StartNextPhase();
		}
	}

	private function BulletRelease()
	{
		m_meshComponent.Toggle( false );
		GameObjectEffectHelper.BreakEffectLoopEvent( this, m_trailName );
		Release();
	}

	private function UpdateReadyToMiss()
	{
		var targetMissProbability : Float;
		var targetPosition : Vector4;
		var distanceToTarget : Float;
		var projectileLocalToWorld : Matrix;
		var bulletDeflectedEvent : SmartBulletDeflectedEvent;
		var weaponRecord : WeaponItem_Record;
		var ammoID : TweakDBID;
		var audioEventName : CName;
		m_readyToMiss = false;
		if( GetInitialDistanceToTarget() > 4.0 )
		{
			m_readyToMiss = m_randomWeaponMissChance > m_smartGunHitProbability;
			if( !( m_readyToMiss ) && EntityID.IsDefined( m_targetID ) )
			{
				targetMissProbability = ClampF( m_statsSystem.GetStatValue( m_targetID, gamedataStatType.SmartTargetingDisruptionProbability ), 0.0, 1.0 );
				if( m_randomTargetMissChance < targetMissProbability )
				{
					projectileLocalToWorld = m_projectileComponent.GetLocalToWorld();
					targetPosition = ( ( m_followPhaseParams.targetComponent ) ? ( Matrix.GetTranslation( m_followPhaseParams.targetComponent.GetLocalToWorld() ) ) : ( m_followPhaseParams.targetPosition ) );
					distanceToTarget = Vector4.Length( targetPosition - Matrix.GetTranslation( projectileLocalToWorld ) );
					if( distanceToTarget < m_smartGunMissRadius )
					{
						m_readyToMiss = true;
						m_shouldStopAndDrop = m_stopAndDropOnTargetingDisruption;
						bulletDeflectedEvent = new SmartBulletDeflectedEvent;
						bulletDeflectedEvent.localToWorld = projectileLocalToWorld;
						bulletDeflectedEvent.instigator = m_owner;
						bulletDeflectedEvent.weapon = m_weapon;
						weaponRecord = TDB.GetWeaponItemRecord( GameObject.GetTDBID( m_weapon ) );
						ammoID = weaponRecord.Ammo().GetID();
						audioEventName = 'unknown_bullet_type';
						if( ammoID == T"Ammo.SmartHighMissile" )
						{
							audioEventName = 'w_gun_flyby_smart_large_jammed';
						}
						else if( ammoID == T"Ammo.SmartLowMissile" )
						{
							audioEventName = 'w_gun_flyby_smart_small_jammed';
						}
						else if( ammoID == T"Ammo.SmartSplitMissile" )
						{
							audioEventName = 'w_gun_flyby_smart_shotgun_jammed';
						}
						GameObject.PlaySoundEvent( this, audioEventName );
						m_followPhaseParams.targetComponent.GetEntity().QueueEvent( bulletDeflectedEvent );
					}
				}
			}
			if( m_readyToMiss )
			{
				DisableTargetCollisions( m_targetID );
			}
			else
			{
				EnableTargetCollisions( m_targetID );
			}
		}
	}

	private function EnableTargetCollisions( targetID : EntityID )
	{
		if( EntityID.IsDefined( targetID ) && ( targetID == m_ignoredTargetID ) )
		{
			m_projectileComponent.RemoveIgnoredEntity( m_ignoredTargetID );
			m_ignoredTargetID = EMPTY_ENTITY_ID();
		}
	}

	private function DisableTargetCollisions( targetID : EntityID )
	{
		if( EntityID.IsDefined( targetID ) && ( targetID != m_ignoredTargetID ) )
		{
			m_ignoredTargetID = targetID;
			m_projectileComponent.AddIgnoredEntity( m_ignoredTargetID );
		}
	}

	private function GetInitialDistanceToTarget() : Float
	{
		var targetPosition : Vector4;
		var distanceToTarget : Float;
		targetPosition = Matrix.GetTranslation( m_followPhaseParams.targetComponent.GetLocalToWorld() );
		distanceToTarget = Vector4.Length( targetPosition - m_startPosition );
		return distanceToTarget;
	}

}

enum ESmartBulletPhase
{
	Init = 0,
	Parabolic = 1,
	Follow = 2,
	Linear = 3,
	Miss = 4,
}

