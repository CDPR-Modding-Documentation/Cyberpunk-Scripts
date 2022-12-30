class sampleGranade extends BaseProjectile
{
	private var m_countTime : Float;
	private editable var m_energyLossFactor : Float;
	private editable var m_startVelocity : Float;
	private editable var m_grenadeLifetime : Float;
	private editable var m_gravitySimulation : Float;
	private var m_trailEffectName : CName;
	default m_trailEffectName = 'trail';
	private var m_alive : Bool;
	default m_alive = true;

	protected event OnProjectileInitialize( eventData : gameprojectileSetUpEvent )
	{
		m_projectileComponent.SetEnergyLossFactor( m_energyLossFactor, m_energyLossFactor );
	}

	private function StartTrailEffect()
	{
		var spawnEffectEvent : entSpawnEffectEvent;
		spawnEffectEvent = new entSpawnEffectEvent;
		spawnEffectEvent.effectName = m_trailEffectName;
		QueueEvent( ( ( Event )( spawnEffectEvent ) ) );
	}

	private function Reset()
	{
		m_countTime = 0.0;
		m_alive = true;
	}

	protected event OnShoot( eventData : gameprojectileShootEvent )
	{
		Reset();
		StartTrailEffect();
	}

	protected event OnShootTarget( eventData : gameprojectileShootTargetEvent )
	{
		var angle : Float;
		var accel : Vector4;
		var target : Vector4;
		var parabolicParams : ParabolicTrajectoryParams;
		Reset();
		m_projectileComponent.ClearTrajectories();
		angle = 45.0;
		accel = Vector4( 0.0, 0.0, -( m_gravitySimulation ), 0.0 );
		target = eventData.params.targetPosition;
		parabolicParams = ParabolicTrajectoryParams.GetAccelTargetAngleParabolicParams( accel, target, angle );
		m_projectileComponent.AddParabolic( parabolicParams );
		StartTrailEffect();
	}

	protected event OnTick( eventData : gameprojectileTickEvent )
	{
		var explosion : EffectInstance;
		m_countTime += eventData.deltaTime;
		if( m_alive )
		{
			if( m_countTime > m_grenadeLifetime )
			{
				explosion = m_projectileComponent.GetGameEffectInstance();
				EffectData.SetVector( explosion.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, eventData.position );
				EffectData.SetFloat( explosion.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 3.0 );
				explosion.Run();
				PlayExplosionSound();
				m_alive = false;
				m_countTime = 0.0;
			}
		}
		else
		{
			if( m_countTime > 0.5 )
			{
				Release();
			}
		}
	}

	protected event OnCollision( eventData : gameprojectileHitEvent ) {}

	private function PlayExplosionSound()
	{
		var audioEvent : SoundPlayEvent;
		audioEvent = new SoundPlayEvent;
		audioEvent.soundName = 'Play_grenade';
		QueueEvent( audioEvent );
	}

}

