#define FILTERSCRIPT

#include <a_samp>
#include <streamer>
#include <colandreas>

#if !defined IsValidVehicle
	native IsValidVehicle(vehicleid);
#endif

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define TIME_RELOAD 5000    			// Time MS Reload

new CG_Vehicles				[MAX_VEHICLES];
new Text3D:CG_TextReload	[MAX_VEHICLES];
new CG_ShotEffect			[MAX_VEHICLES];
new CG_Reload				[MAX_VEHICLES];
new CG_Attachments			[MAX_VEHICLES][7];
new CG_Rocket				[MAX_VEHICLES];
new CG_Timer;

new VehicleColoursTableARGB[256] = {
	// The existing colours from San Andreas
	0xFF000000, 0xFFF5F5F5, 0xFF2A77A1, 0xFF840410, 0xFF263739, 0xFF86446E, 0xFFD78E10, 0xFF4C75B7, 0xFFBDBEC6, 0xFF5E7072,
	0xFF46597A, 0xFF656A79, 0xFF5D7E8D, 0xFF58595A, 0xFFD6DAD6, 0xFF9CA1A3, 0xFF335F3F, 0xFF730E1A, 0xFF7B0A2A, 0xFF9F9D94,
	0xFF3B4E78, 0xFF732E3E, 0xFF691E3B, 0xFF96918C, 0xFF515459, 0xFF3F3E45, 0xFFA5A9A7, 0xFF635C5A, 0xFF3D4A68, 0xFF979592,
	0xFF421F21, 0xFF5F272B, 0xFF8494AB, 0xFF767B7C, 0xFF646464, 0xFF5A5752, 0xFF252527, 0xFF2D3A35, 0xFF93A396, 0xFF6D7A88,
	0xFF221918, 0xFF6F675F, 0xFF7C1C2A, 0xFF5F0A15, 0xFF193826, 0xFF5D1B20, 0xFF9D9872, 0xFF7A7560, 0xFF989586, 0xFFADB0B0,
	0xFF848988, 0xFF304F45, 0xFF4D6268, 0xFF162248, 0xFF272F4B, 0xFF7D6256, 0xFF9EA4AB, 0xFF9C8D71, 0xFF6D1822, 0xFF4E6881,
	0xFF9C9C98, 0xFF917347, 0xFF661C26, 0xFF949D9F, 0xFFA4A7A5, 0xFF8E8C46, 0xFF341A1E, 0xFF6A7A8C, 0xFFAAAD8E, 0xFFAB988F,
	0xFF851F2E, 0xFF6F8297, 0xFF585853, 0xFF9AA790, 0xFF601A23, 0xFF20202C, 0xFFA4A096, 0xFFAA9D84, 0xFF78222B, 0xFF0E316D,
	0xFF722A3F, 0xFF7B715E, 0xFF741D28, 0xFF1E2E32, 0xFF4D322F, 0xFF7C1B44, 0xFF2E5B20, 0xFF395A83, 0xFF6D2837, 0xFFA7A28F,
	0xFFAFB1B1, 0xFF364155, 0xFF6D6C6E, 0xFF0F6A89, 0xFF204B6B, 0xFF2B3E57, 0xFF9B9F9D, 0xFF6C8495, 0xFF4D8495, 0xFFAE9B7F,
	0xFF406C8F, 0xFF1F253B, 0xFFAB9276, 0xFF134573, 0xFF96816C, 0xFF64686A, 0xFF105082, 0xFFA19983, 0xFF385694, 0xFF525661,
	0xFF7F6956, 0xFF8C929A, 0xFF596E87, 0xFF473532, 0xFF44624F, 0xFF730A27, 0xFF223457, 0xFF640D1B, 0xFFA3ADC6, 0xFF695853,
	0xFF9B8B80, 0xFF620B1C, 0xFF5B5D5E, 0xFF624428, 0xFF731827, 0xFF1B376D, 0xFFEC6AAE, 0xFF000000,
	// SA-MP extended colours (0.3x)
	0xFF177517, 0xFF210606, 0xFF125478, 0xFF452A0D, 0xFF571E1E, 0xFF010701, 0xFF25225A, 0xFF2C89AA, 0xFF8A4DBD, 0xFF35963A,
	0xFFB7B7B7, 0xFF464C8D, 0xFF84888C, 0xFF817867, 0xFF817A26, 0xFF6A506F, 0xFF583E6F, 0xFF8CB972, 0xFF824F78, 0xFF6D276A,
	0xFF1E1D13, 0xFF1E1306, 0xFF1F2518, 0xFF2C4531, 0xFF1E4C99, 0xFF2E5F43, 0xFF1E9948, 0xFF1E9999, 0xFF999976, 0xFF7C8499,
	0xFF992E1E, 0xFF2C1E08, 0xFF142407, 0xFF993E4D, 0xFF1E4C99, 0xFF198181, 0xFF1A292A, 0xFF16616F, 0xFF1B6687, 0xFF6C3F99,
	0xFF481A0E, 0xFF7A7399, 0xFF746D99, 0xFF53387E, 0xFF222407, 0xFF3E190C, 0xFF46210E, 0xFF991E1E, 0xFF8D4C8D, 0xFF805B80,
	0xFF7B3E7E, 0xFF3C1737, 0xFF733517, 0xFF781818, 0xFF83341A, 0xFF8E2F1C, 0xFF7E3E53, 0xFF7C6D7C, 0xFF020C02, 0xFF072407,
	0xFF163012, 0xFF16301B, 0xFF642B4F, 0xFF368452, 0xFF999590, 0xFF818D96, 0xFF99991E, 0xFF7F994C, 0xFF839292, 0xFF788222,
	0xFF2B3C99, 0xFF3A3A0B, 0xFF8A794E, 0xFF0E1F49, 0xFF15371C, 0xFF15273A, 0xFF375775, 0xFF060820, 0xFF071326, 0xFF20394B,
	0xFF2C5089, 0xFF15426C, 0xFF103250, 0xFF241663, 0xFF692015, 0xFF8C8D94, 0xFF516013, 0xFF090F02, 0xFF8C573A, 0xFF52888E,
	0xFF995C52, 0xFF99581E, 0xFF993A63, 0xFF998F4E, 0xFF99311E, 0xFF0D1842, 0xFF521E1E, 0xFF42420D, 0xFF4C991E, 0xFF082A1D,
	0xFF96821D, 0xFF197F19, 0xFF3B141F, 0xFF745217, 0xFF893F8D, 0xFF7E1A6C, 0xFF0B370B, 0xFF27450D, 0xFF071F24, 0xFF784573,
	0xFF8A653A, 0xFF732617, 0xFF319490, 0xFF56941D, 0xFF59163D, 0xFF1B8A2F, 0xFF38160B, 0xFF041804, 0xFF355D8E, 0xFF2E3F5B,
	0xFF561A28, 0xFF4E0E27, 0xFF706C67, 0xFF3B3E42, 0xFF2E2D33, 0xFF7B7E7D, 0xFF4A4442, 0xFF28344
};

enum MatrixParts
{
	mp_PITCH,
	mp_ROLL,
	mp_YAW,
	mp_POS
};

enum MatrixIndicator
{
	Float:mi_X,
	Float:mi_Y,
	Float:mi_Z
};


#if defined FILTERSCRIPT
	public OnFilterScriptInit()
	{
	    CarGun_Init();
		return 1;
	}

	public OnFilterScriptExit()
	{
		CarGun_Exit();
		return 1;
	}
#else
	public OnGameModeInit()
	{
	    CarGun_Init();
		return 1;
	}

	public OnGameModeExit()
	{
		CarGun_Exit();
		return 1;
	}
	main(){
		return 1;
	}
#endif

stock CarGun_Exit()
{
	for(new i; i<MAX_VEHICLES; i++)
	{
  		CarGun_Destroy(i);
	}
	KillTimer(CG_Timer);
}

stock CarGun_Init()
{
	print("\n--------------------------------------");
	print(" cargun by @vawylon");
	print("--------------------------------------\n");
 	if(CA_Init())
    {
        printf("[cargun] Collision world create!");
	}
    else
    {
        printf("[cargun] Error collision world create!");
    }
    CG_Timer = SetTimer("CarGun_TimerReload", 100, 1);
}


stock CarGun_StartRocket (vehicleid, modelObject, Float:distance, Float:offsetX, Float:offsetY, Float:offsetZ, Float:speed, Float:offsetRX, Float:offsetRY, Float:offsetRZ)
{
	if(IsValidDynamicObject(CG_Rocket[vehicleid])) return 0;
	
    new
		rocketobjectid,
		Float:startX,
		Float:startY,
		Float:startZ,
		Float:endX,
		Float:endY,
		Float:endZ,
		Float:rx,
		Float:ry,
		Float:rz,
    	Float:ex,
		Float:ey,
		Float:ez;
		
	GetVehicleRotation(vehicleid, rx, ry, rz);
	PositionFromVehicleOffset(vehicleid,offsetX, offsetY, offsetZ, startX, startY, startZ);
	GetXYZInfrontOfVehicle(vehicleid, distance, endX, endY, endZ);
	
	new col = CA_RayCastLine(startX, startY, startZ, endX, endY, endZ, ex, ey, ez);
	rocketobjectid = CreateDynamicObject(modelObject, startX, startY, startZ, rx + offsetRX, ry+offsetRY, rz+offsetRZ);
	if(col != 0)	MoveDynamicObject(rocketobjectid, ex, ey, ez, speed, rx + offsetRX, ry+offsetRY, rz+offsetRZ);
	else			MoveDynamicObject(rocketobjectid, endX, endY, endZ, speed, rx + offsetRX, ry+offsetRY, rz+offsetRZ);
	CG_Rocket[vehicleid] = rocketobjectid;

	return rocketobjectid;

}




stock CarGun_Destroy(vehicleid)
{
	if(! (0<=vehicleid<MAX_VEHICLES)) 	return 0;

	for(new i; i<sizeof(CG_Attachments[]); i++)
	{
	    if(IsValidDynamicObject(CG_Attachments[vehicleid][i])) {
	        DestroyDynamicObject(CG_Attachments[vehicleid][i]);
	    }
	    CG_Attachments[vehicleid][i] = 0;
	}
	
	if(IsValidDynamicObject(CG_Rocket[vehicleid])) {
		DestroyDynamicObject(CG_Rocket[vehicleid]);
	}
	if(IsValidDynamicObject(CG_ShotEffect[vehicleid])) {
		DestroyDynamicObject(CG_ShotEffect[vehicleid]);
	}
	if(IsValidDynamic3DTextLabel(CG_TextReload[vehicleid])) {
        DestroyDynamic3DTextLabel(CG_TextReload[vehicleid]);
	}
		
	CG_Rocket[vehicleid] = 0;
	DestroyVehicle(CG_Vehicles[vehicleid]);
	CG_TextReload[vehicleid] = Text3D:INVALID_STREAMER_ID;
    CG_ShotEffect[vehicleid] = INVALID_STREAMER_ID;
	CG_Vehicles[vehicleid] = INVALID_STREAMER_ID;
	return 1;

}

stock CarGun_Create(Float:px, Float: py, Float: pz, Float: rotz, color1, color2) {
	new vehicleid = CreateVehicle(603, px, py, pz, rotz, color1, color2, -1);
	CG_Vehicles[vehicleid] = vehicleid;

	CG_TextReload[vehicleid] = CreateDynamic3DTextLabelEx("", 0x44FF44FF, 0.0, 0.0, 1.0, 5.0, INVALID_PLAYER_ID, vehicleid);

	CG_Attachments[vehicleid][0] = CreateDynamicObjectEx(1044,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][0], vehicleid, 0.009999,1.005000,0.744999,-2.519999,0.180000,180.719894);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][0], 0, -1, "none", "none", 0xFF222222);

	CG_Attachments[vehicleid][1] = CreateDynamicObjectEx(1792,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][1], vehicleid, -0.125000,0.000000,1.049999,90.900016,0.180001,0.000000);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][1], 1, -1, "none", "none", SetColorBrightness (VehicleColoursTableARGB[color1], 0x22));

	CG_Attachments[vehicleid][2] = CreateDynamicObjectEx(11743,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][2], vehicleid, 0.005000,0.000000,0.850000,-90.719978,0.000001,0.000000);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][2], 0, -1, "none", "none", VehicleColoursTableARGB[color1]);

	CG_Attachments[vehicleid][3] = CreateDynamicObjectEx(2750,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][3], vehicleid, -0.075000,0.210000,0.779999,90.539985,-89.099983,-10.800001);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][3], 0, -1, "none", "none", VehicleColoursTableARGB[color1]);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][3], 1, -1, "none", "none", SetColorBrightness (VehicleColoursTableARGB[color1], -0x22));

	CG_Attachments[vehicleid][4] = CreateDynamicObjectEx(2750,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][4], vehicleid, 0.075000,0.210000,0.779999,266.039855,-91.799980,192.599884);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][4], 0, -1, "none", "none", VehicleColoursTableARGB[color1]);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][4], 1, -1, "none", "none", SetColorBrightness (VehicleColoursTableARGB[color1], -0x22));

	CG_Attachments[vehicleid][5] = CreateDynamicObjectEx(2225,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][5], vehicleid, 0.119999,-0.589999,1.069999,90.000022,0.000000,0.000000);
	SetDynamicObjectMaterial(CG_Attachments[vehicleid][5], 2, -1, "none", "none", VehicleColoursTableARGB[color1]);

	CG_Attachments[vehicleid][6] = CreateDynamicObjectEx(2061,0,0,-1000,0,0,0,100);
	AttachDynamicObjectToVehicle(CG_Attachments[vehicleid][6], vehicleid, 0.000000,-1.054999,0.814999,-93.419975,-0.179999,0.000000);

	return vehicleid;
}

stock CarGun_CreateShotEffects(vehicleid) {
	if(!IsValidDynamicObject(CG_ShotEffect[vehicleid])) {
	    CG_ShotEffect[vehicleid] = CreateDynamicObjectEx(18686,0,0,-1000,0,0,0,100);
	}
	AttachDynamicObjectToVehicle(CG_ShotEffect[vehicleid], vehicleid, 0.150000,2.250000,-1.049999,0.000000,0.000000,0.000000);
}

stock CarGun_IsPlayerIn(playerid) {
	return (IsValidVehicle(CG_Vehicles[GetPlayerVehicleID(playerid)]) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER);
}

stock CarGun_IsVehicle(vehicleid)
{
	if(0 <= vehicleid < sizeof CG_Vehicles) {
	    return IsValidVehicle(CG_Vehicles[vehicleid]);
	}
	return 0;
}

stock torgba(rgbacolor, &r, &g, &b, &a) {
	r = (rgbacolor >>> 24);
	g = ((rgbacolor >>> 16) & 0xFF);
	b = ((rgbacolor >>> 8) & 0xFF);
	a = (rgbacolor & 0xFF);
}

stock toargb(argbcolor, &a, &r, &g, &b) {
	torgba(argbcolor, a, r, g, b);
}

stock SetColorBrightness (color, brightness=0xFF) {
	new a, r, g, b;
	toargb(color, a, r, g, b);
	if(r + brightness >= 0 && r + brightness <= 255) r += brightness; else if( r + brightness <= 0) r = 0; else r = 255;
	if(g + brightness >= 0 && g + brightness <= 255) g += brightness; else if( g + brightness <= 0) g = 0; else g = 255;
	if(b + brightness >= 0 && b + brightness <= 255) b += brightness; else if( b + brightness <= 0) b = 0; else b = 255;
	return ((a << 24) | (r << 16) | (g << 8) | b);
}

stock GetVehicleMatrix(vehicleid,Mat4x3[MatrixParts][MatrixIndicator]) {

	new
		Float:x,
		Float:y,
		Float:z,
		Float:w,
		Float:Pos[3];

	GetVehicleRotationQuat(vehicleid,w,x,y,z);
	GetVehiclePos(vehicleid,Pos[0],Pos[1],Pos[2]);

	new
		Float:x2 = x * x,
	 	Float:y2 = y * y,
	 	Float:z2 = z * z,
	 	Float:xy = x * y,
	 	Float:xz = x * z,
		Float:yz = y * z,
		Float:wx = w * x,
		Float:wy = w * y,
		Float:wz = w * z;

	Mat4x3[mp_PITCH][mi_X] = 1.0 - 2.0 * (y2 + z2);
	Mat4x3[mp_PITCH][mi_Y] = 2.0 * (xy - wz);
	Mat4x3[mp_PITCH][mi_Z] = 2.0 * (xz + wy);
	Mat4x3[mp_ROLL][mi_X] = 2.0 * (xy + wz);
	Mat4x3[mp_ROLL][mi_Y] = 1.0 - 2.0 * (x2 + z2);
	Mat4x3[mp_ROLL][mi_Z] = 2.0 * (yz - wx);
 	Mat4x3[mp_YAW][mi_X] = 2.0 * (xz - wy);
 	Mat4x3[mp_YAW][mi_Y] = 2.0 * (yz + wx);
 	Mat4x3[mp_YAW][mi_Z] = 1.0 - 2.0 * (x2 + y2);
  	Mat4x3[mp_POS][mi_X] = Pos[0];
  	Mat4x3[mp_POS][mi_Y] = Pos[1];
  	Mat4x3[mp_POS][mi_Z] = Pos[2];

	return 1;
}


stock EulerToQuat(Float:rx,Float:ry,Float:rz,&Float:qw,&Float:qx,&Float:qy,&Float:qz){
	rx /= 2.0;
	ry /= 2.0;
	rz /= 2.0;

	new	Float:cosX = floatcos(rx,degrees),
		Float:cosY = floatcos(ry,degrees),
		Float:cosZ = floatcos(rz,degrees),
		Float:sinX = floatsin(rx,degrees),
		Float:sinY = floatsin(ry,degrees),
		Float:sinZ = floatsin(rz,degrees);

	qw = sinX * sinY * sinZ - cosX * cosY * cosZ;
	qx = sinX * cosY * cosZ - cosX * sinY * sinZ;
	qy = cosX * sinY * cosZ + sinX * cosY * sinZ;
	qz = cosX * cosY * sinZ + sinX * sinY * cosZ;
}

stock QuatToEuler(&Float:rx,&Float:ry,&Float:rz,Float:qw,Float:qx,Float:qy,Float:qz){
	CompRotationFloat(asin(2*qy*qz-2*qx*qw),rx);
	CompRotationFloat(-atan2(qx*qz+qy*qw,0.5-qx*qx-qy*qy),ry);
	CompRotationFloat(-atan2(qx*qy+qz*qw,0.5-qx*qx-qz*qz),rz);
}

stock GetVehicleRotation(vehicleid,&Float:rx,&Float:ry,&Float:rz){
	new Float:qw,Float:qx,Float:qy,Float:qz;
	GetVehicleRotationQuat(vehicleid,qw,qx,qy,qz);
	QuatToEuler(rx,ry,rz,qw,qx,qy,qz);
}


stock CompRotationFloat(Float:rotation,&Float:crotation){
	crotation = rotation;
	while(crotation < 0.0) crotation += 360.0;
	while(crotation >= 360.0) crotation -= 360.0;
}

stock PositionFromVehicleOffset(vehicle,Float:offX,Float:offY,Float:offZ,&Float:x,&Float:y,&Float:z)
{
	new Mat4x3[MatrixParts][MatrixIndicator];

    GetVehicleMatrix(vehicle,Mat4x3);

	x = offX * Mat4x3[mp_PITCH][mi_X] + offY * Mat4x3[mp_ROLL][mi_X] + offZ * Mat4x3[mp_YAW][mi_X] + Mat4x3[mp_POS][mi_X];
	y = offX * Mat4x3[mp_PITCH][mi_Y] + offY * Mat4x3[mp_ROLL][mi_Y] + offZ * Mat4x3[mp_YAW][mi_Y] + Mat4x3[mp_POS][mi_Y];
	z = offX * Mat4x3[mp_PITCH][mi_Z] + offY * Mat4x3[mp_ROLL][mi_Z] + offZ * Mat4x3[mp_YAW][mi_Z] + Mat4x3[mp_POS][mi_Z];

	return 1;
}


stock GetXYZInfrontOfVehicle(vehid,Float:distance, &Float:x, &Float:y, &Float:z)
{
    new Float:Quaternion[4];
    new Float:transformationmatrix[4][4];

    GetVehicleRotationQuat(vehid, Quaternion[0], Quaternion[1], Quaternion[2], Quaternion[3]);

    new Float:xx = Quaternion[0] * Quaternion[0];
    new Float:xy = Quaternion[0] * Quaternion[1];
    new Float:xz = Quaternion[0] * Quaternion[2];
    new Float:xw = Quaternion[0] * Quaternion[3];
    new Float:yy = Quaternion[1] * Quaternion[1];
    new Float:yz = Quaternion[1] * Quaternion[2];
    new Float:yw = Quaternion[1] * Quaternion[3];
    new Float:zz = Quaternion[2] * Quaternion[2];
    new Float:zw = Quaternion[2] * Quaternion[3];

    transformationmatrix[0][0] = 1 - 2 * ( yy + zz );
    transformationmatrix[0][1] =     2 * ( xy - zw );
    transformationmatrix[0][2] =     2 * ( xz + yw );
    transformationmatrix[0][3] = 0.0;

    transformationmatrix[1][0] =     2 * ( xy + zw );
    transformationmatrix[1][1] = 1 - 2 * ( xx + zz );
    transformationmatrix[1][2] =     2 * ( yz - xw );
    transformationmatrix[1][3] = 0.0;

    transformationmatrix[2][0] =     2 * ( xz - yw );
    transformationmatrix[2][1] =     2 * ( yz + xw );
    transformationmatrix[2][2] = 1 - 2 * ( xx + yy );
    transformationmatrix[2][3] = 0;

    transformationmatrix[3][0] = 0;
    transformationmatrix[3][1] = 0;
    transformationmatrix[3][2] = 0;
    transformationmatrix[3][3] = 1;
    GetVehiclePos(vehid,x,y,z);

    z +=( -1 * transformationmatrix[0][1] + transformationmatrix[0][3])*distance;
    y +=( -1 * transformationmatrix[1][1] + transformationmatrix[1][3])*distance;
    x +=( -(-1 * transformationmatrix[2][1] + transformationmatrix[2][3]))*distance;
}


stock CarGun_BackKick(vehicleid, Float:speed)
{
	new Float: p[3], Float: v[3];
	GetXYZInfrontOfVehicle(vehicleid, speed, p[0], p[1], p[2]);
	GetVehiclePos(vehicleid, v[0], v[1], v[2]);
    p[0] = p[0] - v[0];
    p[1] = p[1] - v[1];
    p[2] = p[2] - v[2];
	GetVehicleVelocity(vehicleid, v[0], v[1], v[2]);
	v[0] = v[0] - p[0];
	v[1] = v[1] - p[1];
	v[2] = v[2] - p[2];
	SetVehicleVelocity(vehicleid, v[0], v[1], v[2]);
	return 1;
}

forward CarGun_TimerReload();
public CarGun_TimerReload()
{
	for ( new vehicleid = 1 , j = GetVehiclePoolSize ( ) ; vehicleid <= j; vehicleid ++ )
    {
	    if( ! CarGun_IsVehicle(vehicleid)) continue;
     	if(CG_Reload[vehicleid] <  100) continue;
     	
        CG_Reload[vehicleid] -= 100;
        if(CG_Reload[vehicleid]<= 0)
        {
            EndReload(vehicleid);
            continue;
        }
        CG_UpdateText3D(vehicleid);
	}
}

stock CG_UpdateText3D(vehicleid)
{
	new str[36];
 	str = 		"";
	new Float: u = 20.0/TIME_RELOAD;
	new pos = floatround(20.0 - u*CG_Reload[vehicleid], floatround_ceil);
	strins (str, "{226622}" , pos) ;
	format(str, sizeof(str), "%s %.0f\%", str, 100.0 - ((100.0 / TIME_RELOAD)*CG_Reload[vehicleid]));
	UpdateDynamic3DTextLabelText(CG_TextReload[vehicleid], 0x44FF44FF, str);
	return 1;
}

stock CarGun_IsReload(vehicleid) {
    return (CarGun_IsVehicle(vehicleid) && CG_Reload[vehicleid] >= 100);
}

stock EndReload(vehicleid) {
    UpdateDynamic3DTextLabelText(CG_TextReload[vehicleid], 0x44FF44FF, "");
}

public OnVehicleDeath(vehicleid, killerid) {
    CarGun_Destroy(vehicleid);
    return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/create_cargun", cmdtext) == 0)
	{
		new Float:x,Float:y,Float:z;
		new Float:facing;
		new Float:distance;

	    GetPlayerPos(playerid, x, y, z);
	    GetPlayerFacingAngle(playerid, facing);

	    new Float:size_x,Float:size_y,Float:size_z;
		GetVehicleModelInfo(603, VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);

		distance = size_x + 0.5;

	  	x += (distance * floatsin(-facing, degrees));
	    y += (distance * floatcos(-facing, degrees));

		facing += 90.0;
		if(facing > 360.0) facing -= 360.0;
	    CarGun_Create(x, y, z + (size_z * 0.25), facing, random(255), random(255));
	    return 1;
	}
	return 0;
}

public OnDynamicObjectMoved(objectid)
{
	for(new vehicleid; vehicleid < sizeof CG_Rocket; vehicleid++)
	{
	    if(CG_Rocket[vehicleid] != objectid) continue;
	    
	    new Float:x,  Float:y,  Float:z;
	    GetDynamicObjectPos(objectid, x, y, z);
		CreateExplosion(x, y, z, 12, 4);
		CG_Rocket[vehicleid] = 0;
		DestroyDynamicObject(objectid);
	}
	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
 	if(PRESSED(KEY_FIRE))
	{
		if(CarGun_IsPlayerIn(playerid))
		{
		    if(CarGun_IsReload(GetPlayerVehicleID(playerid))) {
		        SendClientMessage(playerid, 0xFF4444FF, " — Gun reload");
		    }
			else
			{
				CG_Reload[GetPlayerVehicleID(playerid)] = TIME_RELOAD;
				CarGun_CreateShotEffects(GetPlayerVehicleID(playerid));
				CarGun_BackKick(GetPlayerVehicleID(playerid), 0.08);
				CarGun_StartRocket(GetPlayerVehicleID(playerid), 345, 300.0, 0.000,2.250000,1.049999, 25.0, 0.0, -90.0, 0.0);
	            PlayerPlaySound(playerid, 17003, 0.0, 0.0, 0.0);
			}
		}
	}
}




