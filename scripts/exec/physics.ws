exec function Pvd( server : String )
{
	PvdClientConnect( server );
}

exec function PvdDump( filePath : String )
{
	PvdFileDumpConnect( filePath );
}

