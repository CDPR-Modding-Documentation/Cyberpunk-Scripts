import struct Box
{
	import var Min : Vector4;
	import var Max : Vector4;

	public static function GetSize( box : Box ) : Vector4
	{
		return box.Max - box.Min;
	}

	public static function GetExtents( box : Box ) : Vector4
	{
		return ( box.Max - box.Min ) * 0.5;
	}

	public static function GetRange( box : Box ) : Float
	{
		var size : Vector4;
		size = Box.GetExtents( box );
		if( ( size.X > size.Y ) && ( size.X > size.Z ) )
		{
			return size.X;
		}
		else if( size.Y > size.Z )
		{
			return size.Y;
		}
		return size.Z;
	}

}

