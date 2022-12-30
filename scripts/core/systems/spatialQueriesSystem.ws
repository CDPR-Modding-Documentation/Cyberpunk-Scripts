importonly abstract class gameISpatialQueriesSystem extends IGameSystem
{
}

importonly final class SpatialQueriesSystem extends gameISpatialQueriesSystem
{
	public import final function GetPlayerObstacleSystem() : PlayerObstacleSystem;
	public import final function GetGeometryDescriptionSystem() : GeometryDescriptionSystem;
	public import final function Overlap( primitiveDimension : Vector4, position : Vector4, rotation : EulerAngles, optional collisionGroup : CName, out result : TraceResult ) : Bool;
	public import final function SyncRaycastByQueryPreset( start : Vector4, end : Vector4, optional queryPreset : CName, out result : TraceResult, optional staticOnly : Bool, optional dynamicOnly : Bool ) : Bool;
	public import final function SyncRaycastByCollisionPreset( start : Vector4, end : Vector4, optional collisionPreset : CName, out result : TraceResult, optional staticOnly : Bool, optional dynamicOnly : Bool ) : Bool;
	public import final function SyncRaycastByCollisionGroup( start : Vector4, end : Vector4, optional collisionGroup : CName, out result : TraceResult, optional staticOnly : Bool, optional dynamicOnly : Bool ) : Bool;
}

class SpatialQueriesHelper
{

	public static function HasSpaceInFront( const sourceObject : weak< GameObject >, groundClearance : Float, areaWidth : Float, areaLength : Float, areaHeight : Float ) : Bool
	{
		var hasSpace : Bool;
		hasSpace = HasSpaceInFront( sourceObject, sourceObject.GetWorldForward(), groundClearance, areaWidth, areaLength, areaHeight );
		return hasSpace;
	}

	public static function HasSpaceInFront( const sourceObject : weak< GameObject >, queryDirection : Vector4, groundClearance : Float, areaWidth : Float, areaLength : Float, areaHeight : Float ) : Bool
	{
		var overlapSuccessStatic : Bool;
		var overlapSuccessVehicle : Bool;
		var fitTestOvelap : TraceResult;
		var queryPosition : Vector4;
		var boxDimensions : Vector4;
		var boxOrientation : EulerAngles;
		queryDirection.Z = 0.0;
		queryDirection = Vector4.Normalize( queryDirection );
		boxDimensions.X = areaWidth * 0.5;
		boxDimensions.Y = areaLength * 0.5;
		boxDimensions.Z = areaHeight * 0.5;
		queryPosition = sourceObject.GetWorldPosition();
		queryPosition.Z += ( boxDimensions.Z + groundClearance );
		queryPosition += ( boxDimensions.Y * queryDirection );
		boxOrientation = Quaternion.ToEulerAngles( Quaternion.BuildFromDirectionVector( queryDirection ) );
		overlapSuccessStatic = GameInstance.GetSpatialQueriesSystem( sourceObject.GetGame() ).Overlap( boxDimensions, queryPosition, boxOrientation, 'Static', fitTestOvelap );
		overlapSuccessVehicle = GameInstance.GetSpatialQueriesSystem( sourceObject.GetGame() ).Overlap( boxDimensions, queryPosition, boxOrientation, 'Vehicle', fitTestOvelap );
		return !( overlapSuccessStatic ) && !( overlapSuccessVehicle );
	}

	public static function GetFloorAngle( const sourceObject : weak< GameObject >, out floorAngle : Float ) : Bool
	{
		var startPosition, endPosition : Vector4;
		var raycastResult : TraceResult;
		startPosition = sourceObject.GetWorldPosition() + Vector4( 0.0, 0.0, 0.1, 0.0 );
		endPosition = sourceObject.GetWorldPosition() + Vector4( 0.0, 0.0, -0.30000001, 0.0 );
		if( GameInstance.GetSpatialQueriesSystem( sourceObject.GetGame() ).SyncRaycastByCollisionGroup( startPosition, endPosition, 'Static', raycastResult, true, false ) )
		{
			floorAngle = Vector4.GetAngleBetween( ( ( Vector4 )( raycastResult.normal ) ), sourceObject.GetWorldUp() );
			return true;
		}
		return false;
	}

}

