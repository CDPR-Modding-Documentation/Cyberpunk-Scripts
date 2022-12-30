importonly abstract class ICameraSystem extends IGameSystem
{
}

importonly class CameraSystem extends ICameraSystem
{
	public import final function PrepareBlendCamera();
	public import final function AbandonBlendCamera();
	public import final function GetActiveCameraWorldTransform( transform : Transform ) : Bool;
	public import final function GetActiveCameraData() : CameraData;
	public import final function GetActiveCameraFOV() : Float;
	public import final function GetAspectRatio() : Float;
	public import final function GetActiveCameraRight() : Vector4;
	public import final function GetActiveCameraForward() : Vector4;
	public import final function GetActiveCameraUp() : Vector4;
	public import final function ProjectPoint( worldSpacePoint : Vector4 ) : Vector4;
	public import final function UnprojectPoint( screenSpacePoint : Vector2 ) : Vector4;
	public import final function IsInCameraFrustum( targetObject : GameObject, objectHeight : Float, objectRadius : Float ) : Bool;
}

