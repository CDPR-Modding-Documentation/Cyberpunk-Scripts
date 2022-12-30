importonly abstract class gameITeleportationFacility extends IGameSystem
{
}

importonly final class TeleportationFacility extends gameITeleportationFacility
{
	public import final function Teleport( objectToTeleport : GameObject, position : Vector4, orientation : EulerAngles );
	public import final function TeleportToNode( objectToTeleport : GameObject, nodeRef : NodeRef );
}

exec function TeleportPlayerToPosition( gi : GameInstance, xStr : String, yStr : String, zStr : String )
{
	var playerPuppet : GameObject;
	var position : Vector4;
	var rotation : EulerAngles;
	playerPuppet = GameInstance.GetPlayerSystem( gi ).GetLocalPlayerMainGameObject();
	position.X = StringToFloat( xStr );
	position.Y = StringToFloat( yStr );
	position.Z = StringToFloat( zStr );
	GameInstance.GetTeleportationFacility( gi ).Teleport( playerPuppet, position, rotation );
}

