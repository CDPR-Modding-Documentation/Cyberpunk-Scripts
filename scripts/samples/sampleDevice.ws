class SampleDeviceClass extends GameObject
{
}

class SampleDeviceClassPS extends GameObjectPS
{
	protected persistent var m_counter : Int32;
	default m_counter = 0;

	public function OnActionInt( evt : ActionInt ) : EntityNotificationType
	{
		m_counter += 1;
		Log( "sample counter: " + IntToString( m_counter ) );
		return EntityNotificationType.SendThisEventToEntity;
	}

	public function GetAction_ActionInt() : ActionInt
	{
		var action : ActionInt;
		return action;
	}

	public function GetActions() : array< DeviceAction >
	{
		var arr : array< DeviceAction >;
		arr.PushBack( GetAction_ActionInt() );
		return arr;
	}

}

class PSD_DetectorPS extends DeviceComponentPS
{
	protected persistent var m_counter : Int32;
	default m_counter = 0;
	protected persistent var m_toggle : Bool;
	default m_toggle = false;
	protected persistent var m_lastEntityID : EntityID;
	protected persistent var m_lastPersistentID : PersistentID;
	protected persistent var m_name : CName;

	public function GetLastEntityID() : EntityID
	{
		return m_lastEntityID;
	}

	public function GetLastPersistentID() : PersistentID
	{
		return m_lastPersistentID;
	}

	public function GetName() : CName
	{
		return m_name;
	}

	public function ReadTheCounter() : Int32
	{
		return m_counter;
	}

	public function OnBumpTheCounter( evt : SampleBumpEvent ) : EntityNotificationType
	{
		m_counter += evt.m_amount;
		Log( "sample counter: " + IntToString( m_counter ) );
		return EntityNotificationType.SendThisEventToEntity;
	}

	public function OnBumpTheCounter( evt : ActionInt ) : EntityNotificationType
	{
		m_counter += 1;
		Log( ( ( "sample counter: " + IntToString( m_counter ) ) + "  " ) + EntityID.ToDebugString( m_lastEntityID ) );
		return EntityNotificationType.SendThisEventToEntity;
	}

	public function OnLogAction( evt : ActionBool ) : EntityNotificationType
	{
		var boolValue : Bool;
		var nameOnFalse : CName;
		var nameOnTrue : CName;
		if( evt.prop.typeName == 'Bool' )
		{
			DeviceActionPropertyFunctions.GetProperty_Bool( evt.prop, boolValue, nameOnFalse, nameOnTrue );
			m_toggle = boolValue;
			if( m_toggle == true )
			{
				m_counter += 2;
			}
		}
		Log( ( ( ( ( "sample counter: " + IntToString( m_counter ) ) + " ## " ) + NameToString( evt.prop.name ) ) + ": " ) + BoolToString( ( ( Bool )evt.prop.first ) ) );
		return EntityNotificationType.SendThisEventToEntity;
	}

	public function GetAction_BumpTheCounter() : ActionInt
	{
		var action : ActionInt;
		return action;
	}

	public function GetAction_Log() : ActionBool
	{
		var action : ActionBool;
		return action;
	}

	public override function GetActions( out outActions : array< DeviceAction >, context : GetActionsContext ) : Bool
	{
		var action : DeviceAction;
		Log( "Getting Actions!" );
		outActions.PushBack( GetAction_BumpTheCounter() );
		action = GetAction_Log();
		if( Clearance.IsInRange( context.clearance, action.clearanceLevel ) )
		{
			outActions.PushBack( action );
		}
		return true;
	}

}

class PSD_Detector extends DeviceComponent
{

	public function LogID()
	{
		Log( EntityID.ToDebugString( ( ( PSD_DetectorPS )( GetPS() ) ).GetLastEntityID() ) );
		Log( PersistentID.ToDebugString( ( ( PSD_DetectorPS )( GetPS() ) ).GetLastPersistentID() ) );
		Log( NameToString( ( ( PSD_DetectorPS )( GetPS() ) ).GetName() ) );
	}

}

class PSD_Master extends DeviceComponent
{
}

class PSD_MasterPS extends DeviceComponentPS
{
}

class PSD_Trigger extends GameObject
{
	instanceeditable var m_ref : NodeRef;
	instanceeditable var m_className : CName;
	default m_className = 'PSD_DetectorPS';

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		EntityRequestComponentsInterface.RequestComponent( ri, 'interaction', 'InteractionComponent', true );
	}

	protected event OnInteraction( interaction : InteractionChoiceEvent )
	{
		var targetEntityID : EntityID;
		var objPS : GameComponentPS;
		var actions : array< DeviceAction >;
		var i : Int32;
		var j : Int32;
		var propertyArr : array< DeviceActionProperty >;
		var context : GetActionsContext;
		i = 0;
		j = 0;
		targetEntityID = ResolveNodeRefWithEntityID( m_ref, GetEntityID() );
		objPS = ( ( GameComponentPS )( GameInstance.GetPersistencySystem( GetGame() ).GetConstAccessToPSObject( targetEntityID, m_className ) ) );
		( ( PSD_DetectorPS )( objPS ) ).GetActions( actions, context );
		Log( ( ( "Device PS: " + NameToString( m_className ) ) + ", number of actions: " ) + IntToString( actions.Size() ) );
		for( i = 0; i < actions.Size(); i += 1 )
		{
			propertyArr = actions[ i ].GetProperties();
			for( j = 0; j < propertyArr.Size(); j += 1 )
			{
				if( propertyArr[ j ].typeName == 'Bool' )
				{
					propertyArr[ j ].first = !( ( ( Bool )propertyArr[ j ].first ) );
				}
			}
			GameInstance.GetPersistencySystem( GetGame() ).QueuePSDeviceEvent( actions[ i ] );
		}
	}

}

class Slave_Test extends GameObject
{
	var deviceComponent : PSD_Detector;

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		EntityRequestComponentsInterface.RequestComponent( ri, 'detector', 'PSD_Detector', true );
		EntityRequestComponentsInterface.RequestComponent( ri, 'interaction', 'InteractionComponent', true );
	}

	protected event OnTakeControl( ri : EntityResolveComponentsInterface )
	{
		deviceComponent = ( ( PSD_Detector )( EntityResolveComponentsInterface.GetComponent( ri, 'detector' ) ) );
	}

	protected event OnInteraction( interaction : InteractionChoiceEvent )
	{
		deviceComponent.LogID();
	}

}

class Master_Test extends GameObject
{
	var deviceComponent : MasterDeviceComponent;

	protected event OnRequestComponents( ri : EntityRequestComponentsInterface )
	{
		EntityRequestComponentsInterface.RequestComponent( ri, 'master', 'MasterDeviceComponent', true );
		EntityRequestComponentsInterface.RequestComponent( ri, 'interaction', 'InteractionComponent', true );
	}

	protected event OnTakeControl( ri : EntityResolveComponentsInterface )
	{
		deviceComponent = ( ( MasterDeviceComponent )( EntityResolveComponentsInterface.GetComponent( ri, 'master' ) ) );
	}

	protected event OnInteraction( interaction : InteractionChoiceEvent )
	{
		var actions : array< DeviceAction >;
		var i : Int32;
		var j : Int32;
		var propertyArr : array< DeviceActionProperty >;
		var context : GetActionsContext;
		context.clearance = deviceComponent.clearance;
		i = 0;
		j = 0;
		Log( "Works" );
		deviceComponent.GetActionsOfConnectedDevices( actions, context );
		Log( IntToString( actions.Size() ) );
		for( i = 0; i < actions.Size(); i += 1 )
		{
			Log( NameToString( actions[ i ].actionName ) );
			propertyArr = actions[ i ].GetProperties();
			for( j = 0; j < propertyArr.Size(); j += 1 )
			{
				if( propertyArr[ j ].typeName == 'Bool' )
				{
					propertyArr[ j ].first = !( ( ( Bool )propertyArr[ j ].first ) );
				}
			}
			GameInstance.GetPersistencySystem( GetGame() ).QueuePSDeviceEvent( actions[ i ] );
		}
	}

	protected event OnSlaveChanged( evt : PSDeviceChangedEvent )
	{
		Log( ( ( ( EntityID.ToDebugString( GetEntityID() ) + " notified by " ) + PersistentID.ToDebugString( evt.persistentID ) ) + " of class " ) + NameToString( evt.className ) );
	}

}

