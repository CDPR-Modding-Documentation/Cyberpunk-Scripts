import struct Color
{
	import var Red : Uint8;
	import var Green : Uint8;
	import var Blue : Uint8;
	import var Alpha : Uint8;

	public static function ToHDRColorDirect( color : Color ) : HDRColor
	{
		return HDRColor( ( ( Float )( color.Red ) ) / 255.0, ( ( Float )( color.Green ) ) / 255.0, ( ( Float )( color.Blue ) ) / 255.0, ( ( Float )( color.Alpha ) ) / 255.0 );
	}

}

import struct HDRColor
{
	import var Red : Float;
	import var Green : Float;
	import var Blue : Float;
	import var Alpha : Float;
}

