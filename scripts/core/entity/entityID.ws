importonly struct EntityID
{
	public import static function IsDefined( id : EntityID ) : Bool;
	public import static function IsDynamic( id : EntityID ) : Bool;
	public import static function IsStatic( id : EntityID ) : Bool;
	public import static function ToDebugString( id : EntityID ) : String;
	public import static function ToDebugStringDecimal( id : EntityID ) : String;
	public import static function GetHash( id : EntityID ) : Uint32;
}

importonly struct PersistentID
{
	public import static function IsDefined( id : PersistentID ) : Bool;
	public import static function IsDynamic( id : PersistentID ) : Bool;
	public import static function IsStatic( id : PersistentID ) : Bool;
	public import static function IsEntity( id : PersistentID ) : Bool;
	public import static function IsComponent( id : PersistentID ) : Bool;
	public import static function GetComponentName( id : PersistentID ) : CName;
	public import static function ToDebugString( id : PersistentID ) : String;
	public import static function ExtractEntityID( id : PersistentID ) : EntityID;
}

importonly struct StatsObjectID
{
	public import static function IsDefined( id : StatsObjectID ) : Bool;
	public import static function IsDynamic( id : StatsObjectID ) : Bool;
	public import static function IsEntity( id : StatsObjectID ) : Bool;
	public import static function ExtractEntityID( id : StatsObjectID ) : EntityID;
}

function EMPTY_ENTITY_ID() : EntityID
{
	var entId : EntityID;
	return entId;
}

import operator==( a : EntityID, b : EntityID ) : Bool;
import operator!=( a : EntityID, b : EntityID ) : Bool;
import operator<( a : EntityID, b : EntityID ) : Bool;
import implicit cast ( a : GlobalNodeID ) : EntityID;
import implicit cast ( a : GlobalNodeRef ) : EntityID;
import implicit cast ( a : GlobalNodeID ) : PersistentID;
import implicit cast ( a : GlobalNodeRef ) : PersistentID;
import implicit cast ( a : EntityID ) : PersistentID;
import function CreatePersistentID( entityID : EntityID, optional componentName : CName ) : PersistentID;
import implicit cast ( a : EntityID ) : StatsObjectID;
import cast ( a : ItemID ) : StatsObjectID;
