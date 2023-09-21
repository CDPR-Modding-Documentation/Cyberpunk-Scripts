import struct GlobalNodeID
{
	public import static function IsDefined( id : GlobalNodeID ) : Bool;
	public import static function GetRoot() : GlobalNodeID;
}

import struct GlobalNodeRef
{
	public import static function IsDefined( id : GlobalNodeRef ) : Bool;
}

import function ResolveNodeRef( id : NodeRef, context : GlobalNodeRef ) : GlobalNodeRef;
import function ResolveNodeRefWithEntityID( id : NodeRef, context : EntityID ) : GlobalNodeRef;
import function IsNodeRefDefined( id : NodeRef ) : Bool;
import implicit cast ( a : GlobalNodeID ) : GlobalNodeRef;
