importonly struct EntityGameInterface
{
	public import static function Destroy( self : EntityGameInterface );
	public import static function IsValid( self : EntityGameInterface ) : Bool;
	public import static function IsStatic( self : EntityGameInterface ) : Bool;
	public import static function GetEntity( self : EntityGameInterface ) : Entity;
	public import static function UnbindTransform( self : EntityGameInterface );
	public import static function BindToComponent( self, target : EntityGameInterface, componentName : CName, optional slotName : CName, optional keepWorldTransform : Bool );
	public import static function ToggleSelectionEffect( self : EntityGameInterface, enable : Bool );
}

import struct EntityRequestComponentsInterface
{
	public import static function RequestComponent( self : EntityRequestComponentsInterface, componentName : CName, componentType : CName, mandatory : Bool );
}

import struct EntityResolveComponentsInterface
{
	public import static function GetComponent( self : EntityResolveComponentsInterface, componentName : CName ) : IComponent;
}

