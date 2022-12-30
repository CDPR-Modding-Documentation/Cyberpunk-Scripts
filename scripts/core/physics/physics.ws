import struct SimulationFilter
{
	public import static function SimulationFilter_BuildFromPreset( out f : SimulationFilter, preset : CName );
	public import static function ALL() : SimulationFilter;
	public import static function ZERO() : SimulationFilter;
}

import struct QueryFilter
{
	public import static function ALL() : QueryFilter;
	public import static function ZERO() : QueryFilter;
	public import static function AddGroup( out filter : QueryFilter, group : CName );
}

import struct TraceResult
{
	import var position : Vector3;
	import var normal : Vector3;
	import var material : CName;

	public import static function IsValid( self : TraceResult ) : Bool;
}

import struct ControllerHit
{
	import var worldPos : Vector4;
	import var worldNormal : Vector4;
}

import function PvdClientConnect( const server : ref< String > );
import function PvdFileDumpConnect( const filePath : ref< String > );
