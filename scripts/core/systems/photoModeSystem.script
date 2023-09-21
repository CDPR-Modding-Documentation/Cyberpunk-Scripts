importonly abstract class IPhotoModeSystem extends IGameSystem
{
}

importonly final abstract class PhotoModeSystem extends IPhotoModeSystem
{
	public import function UnlockPhotoModeItem( stickerID : TweakDBID ) : Bool;
	public import function IsExitLocked() : Bool;
	public import function IsPhotoModeActive() : Bool;
	public import function CanPhotoModeBeEnabled() : Bool;
	public import function GetCameraLocation( location : WorldPosition );
}

importonly class PhotoModeEnableEvent extends Event
{
	public import function SetEnable( enable : Bool );
	public import function GetEnable() : Bool;
}

