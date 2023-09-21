import class LightComponent extends IVisualComponent
{
	public import function SetTemperature( temperature : Float );
	public import function SetColor( color : Color );
	public import function SetRadius( radius : Float );
	public import function SetIntensity( intensity : Float );
	public import function SetFlickerParams( strength : Float, period : Float, offset : Float );

	protected event OnForceFlicker( evt : FlickerEvent )
	{
		SetFlickerParams( evt.strength, evt.duration, evt.offset );
	}

	protected event OnToggleLight( evt : ToggleLightEvent )
	{
		Toggle( evt.toggle );
	}

	protected event OnToggleLightByName( evt : ToggleLightByNameEvent )
	{
		var fullComponentName : String;
		fullComponentName = NameToString( GetName() );
		if( StrContains( fullComponentName, NameToString( evt.componentName ) ) )
		{
			Toggle( evt.toggle );
		}
	}

}

