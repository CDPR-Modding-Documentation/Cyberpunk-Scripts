class JumpPod extends GameObject
{
	private var m_activationLight : IVisualComponent;
	private var m_activationTrigger : IComponent;
	editable var impulseForward : Float;
	editable var impulseRight : Float;
	editable var impulseUp : Float;

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		EntityRequestComponentsInterface.RequestComponent( ri, 'activationLight', 'entLightComponent', true );
		EntityRequestComponentsInterface.RequestComponent( ri, 'activator', 'gameStaticTriggerAreaComponent', true );
	}

	protected event OnTakeControl( ri : EntityResolveComponentsInterface )
	{
		m_activationLight = ( ( IVisualComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'activationLight' ) ) );
		m_activationTrigger = ( ( IComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'activator' ) ) );
		m_activationLight.Toggle( false );
	}

	protected event OnAreaEnter( trigger : AreaEnteredEvent )
	{
		ApplyImpulse( trigger.activator );
	}

	protected event OnAreaExit( trigger : AreaExitedEvent ) {}

	private function ApplyImpulse( activator : EntityGameInterface )
	{
		var ev : PSMImpulse;
		var impulseInLocalSpace : Vector4;
		ev = new PSMImpulse;
		ev.id = 'impulse';
		impulseInLocalSpace = GetWorldForward() * impulseForward;
		impulseInLocalSpace += ( GetWorldRight() * impulseRight );
		impulseInLocalSpace += ( GetWorldUp() * impulseUp );
		ev.impulse = impulseInLocalSpace;
		EntityGameInterface.GetEntity( activator ).QueueEvent( ev );
	}

}

