class AnimationsLoaded extends TaggedSignalUserData
{
}

class PreloadAnimationsEvent extends Event
{
	var m_streamingContextName : CName;
	var m_highPriority : Bool;
}

import class AnimationControllerComponent extends IComponent
{
	private import function PushEvent( eventName : CName );
	private import function SetInputFloat( inputName : CName, value : Float );
	private import function SetInputInt( inputName : CName, value : Int32 );
	private import function SetInputBool( inputName : CName, value : Bool );
	private import function SetInputQuaternion( inputName : CName, value : Quaternion );
	private import function SetInputVector( inputName : CName, value : Vector4 );
	private import function SetUsesSleepMode( allowSleepState : Bool );
	private import function ScheduleFastForward();
	public import function PreloadAnimations( streamingContextName : CName, highPriority : Bool ) : Bool;
	private import function ApplyFeature( inputName : CName, value : AnimFeature );
	public import const function GetAnimationDuration( animationName : CName ) : Float;

	protected event OnSetInputVectorEvent( evt : AnimInputSetterVector )
	{
		SetInputVector( evt.key, evt.value );
	}

	public static function ApplyFeature( obj : GameObject, inputName : CName, value : AnimFeature, optional delay : Float )
	{
		var evt : AnimInputSetterAnimFeature;
		var item : ItemObject;
		evt = new AnimInputSetterAnimFeature;
		evt.key = inputName;
		evt.value = value;
		evt.delay = delay;
		obj.QueueEvent( evt );
		item = ( ( ItemObject )( obj ) );
		if( item )
		{
			item.QueueEventToChildItems( evt );
		}
	}

	public static function ApplyFeatureToReplicate( obj : GameObject, inputName : CName, value : AnimFeature, optional delay : Float )
	{
		ApplyFeature( obj, inputName, value, delay );
		obj.ReplicateAnimFeature( obj, inputName, value );
	}

	public static function ApplyFeatureToReplicateOnHeldItems( obj : GameObject, inputName : CName, value : AnimFeature, optional delay : Float )
	{
		var leftItem : ItemObject;
		var rightItem : ItemObject;
		leftItem = ( ( ItemObject )( GameInstance.GetTransactionSystem( obj.GetGame() ).GetItemInSlot( obj, T"AttachmentSlots.WeaponLeft" ) ) );
		rightItem = ( ( ItemObject )( GameInstance.GetTransactionSystem( obj.GetGame() ).GetItemInSlot( obj, T"AttachmentSlots.WeaponRight" ) ) );
		if( leftItem )
		{
			ApplyFeature( leftItem, inputName, value, delay );
			leftItem.ReplicateAnimFeature( leftItem, inputName, value );
		}
		if( rightItem )
		{
			ApplyFeature( rightItem, inputName, value, delay );
			rightItem.ReplicateAnimFeature( rightItem, inputName, value );
		}
	}

	public static function PushEvent( obj : GameObject, eventName : CName )
	{
		var evt : AnimExternalEvent;
		var item : ItemObject;
		evt = new AnimExternalEvent;
		evt.name = eventName;
		obj.QueueEvent( evt );
		item = ( ( ItemObject )( obj ) );
		if( item )
		{
			item.QueueEventToChildItems( evt );
		}
	}

	public static function PushEventToObjAndHeldItems( obj : GameObject, eventName : CName )
	{
		var item : ItemObject;
		if( !( obj ) )
		{
			return;
		}
		PushEvent( obj, eventName );
		item = ( ( ItemObject )( GameInstance.GetTransactionSystem( obj.GetGame() ).GetItemInSlot( obj, T"AttachmentSlots.WeaponLeft" ) ) );
		if( item )
		{
			PushEvent( item, eventName );
		}
		item = ( ( ItemObject )( GameInstance.GetTransactionSystem( obj.GetGame() ).GetItemInSlot( obj, T"AttachmentSlots.WeaponRight" ) ) );
		if( item )
		{
			PushEvent( item, eventName );
		}
	}

	public static function PushEventToReplicate( obj : GameObject, eventName : CName )
	{
		PushEvent( obj, eventName );
		obj.ReplicateAnimEvent( obj, eventName );
	}

	public static function SetInputFloat( obj : GameObject, inputName : CName, value : Float )
	{
		var evt : AnimInputSetterFloat;
		evt = new AnimInputSetterFloat;
		evt.key = inputName;
		evt.value = value;
		obj.QueueEvent( evt );
	}

	public static function SetInputFloatToReplicate( obj : GameObject, inputName : CName, value : Float )
	{
		SetInputFloat( obj, inputName, value );
		obj.ReplicateInputFloat( obj, inputName, value );
	}

	public static function SetInputBool( obj : GameObject, inputName : CName, value : Bool )
	{
		var evt : AnimInputSetterBool;
		evt = new AnimInputSetterBool;
		evt.key = inputName;
		evt.value = value;
		obj.QueueEvent( evt );
	}

	public static function SetInputBoolToReplicate( obj : GameObject, inputName : CName, value : Bool )
	{
		SetInputBool( obj, inputName, value );
		obj.ReplicateInputBool( obj, inputName, value );
	}

	public static function SetInputInt( obj : GameObject, inputName : CName, value : Int32 )
	{
		var evt : AnimInputSetterInt;
		evt = new AnimInputSetterInt;
		evt.key = inputName;
		evt.value = value;
		obj.QueueEvent( evt );
	}

	public static function SetInputIntToReplicate( obj : GameObject, inputName : CName, value : Int32 )
	{
		SetInputInt( obj, inputName, value );
		obj.ReplicateInputInt( obj, inputName, value );
	}

	public static function SetInputVector( obj : GameObject, inputName : CName, value : Vector4 )
	{
		var evt : AnimInputSetterVector;
		evt = new AnimInputSetterVector;
		evt.key = inputName;
		evt.value = value;
		obj.QueueEvent( evt );
	}

	public static function SetInputVectorToReplicate( obj : GameObject, inputName : CName, value : Vector4 )
	{
		SetInputVector( obj, inputName, value );
		obj.ReplicateInputVector( obj, inputName, value );
	}

	public static function SetUsesSleepMode( obj : GameObject, state : Bool )
	{
		var evt : AnimInputSetterUsesSleepMode;
		evt = new AnimInputSetterUsesSleepMode;
		evt.value = state;
		obj.QueueEvent( evt );
	}

	public static function SetAnimWrapperWeight( obj : GameObject, key : CName, value : Float )
	{
		var evt : AnimWrapperWeightSetter;
		var item : ItemObject;
		if( !( IsNameValid( key ) ) )
		{
			return;
		}
		evt = new AnimWrapperWeightSetter;
		evt.key = key;
		evt.value = value;
		obj.QueueEvent( evt );
		item = ( ( ItemObject )( obj ) );
		if( item )
		{
			item.QueueEventToChildItems( evt );
		}
	}

	public static function SetAnimWrapperWeightOnOwnerAndItems( owner : GameObject, key : CName, value : Float )
	{
		var item : ItemObject;
		SetAnimWrapperWeight( owner, key, value );
		item = GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemInSlot( owner, T"AttachmentSlots.WeaponRight" );
		if( item )
		{
			SetAnimWrapperWeight( item, key, value );
		}
		item = GameInstance.GetTransactionSystem( owner.GetGame() ).GetItemInSlot( owner, T"AttachmentSlots.WeaponLeft" );
		if( item )
		{
			SetAnimWrapperWeight( item, key, value );
		}
	}

}

