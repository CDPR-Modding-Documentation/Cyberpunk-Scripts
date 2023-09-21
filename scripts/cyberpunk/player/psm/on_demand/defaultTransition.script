class Ground extends DefaultTransition
{

	protected const virtual function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var onGround : Bool;
		onGround = scriptInterface.IsOnGround();
		return onGround;
	}

}

class Air extends DefaultTransition
{

	protected const virtual function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		var onGround : Bool;
		onGround = scriptInterface.IsOnGround();
		return !( onGround );
	}

}

