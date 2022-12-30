class EquipItemLeftDecisions extends DefaultTransition
{

	protected const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetActionValue( 'ItemLeft' ) > 0.0;
	}

}

class EquipItemRightDecisions extends DefaultTransition
{

	protected const function EnterCondition( const stateContext : StateContext, const scriptInterface : StateGameScriptInterface ) : Bool
	{
		return scriptInterface.GetActionValue( 'ItemRight' ) > 0.0;
	}

}

