exec function LogPlayerPositionAndName( gameInstance : GameInstance )
{
	var playerObject : GameObject;
	var worldPosition : Vector4;
	playerObject = GameInstance.GetPlayerSystem( gameInstance ).GetLocalPlayerMainGameObject();
	if( playerObject )
	{
		worldPosition = playerObject.GetWorldPosition();
		Log( "Player Position:: " + Vector4.ToString( worldPosition ) );
		Log( "Player Name:: " + NameToString( playerObject.GetName() ) );
	}
}

exec function ParameterTest1( gameInstance : GameInstance, param1 : String )
{
	Log( "param1:: " + param1 );
}

exec function ParameterTest5( gameInstance : GameInstance, param1 : String, param2 : String, param3 : String, param4 : String, param5 : String )
{
	Log( "param1:: " + param1 );
	Log( "param2:: " + param2 );
	Log( "param3:: " + param3 );
	Log( "param4:: " + param4 );
	Log( "param5:: " + param5 );
}

exec function ToIntTest( gameInstance : GameInstance, toInt : String )
{
	var fromString : Int32;
	fromString = StringToInt( toInt );
	fromString += 100;
	Log( IntToString( fromString ) );
}

