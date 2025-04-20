new Text:FurnitureTexturePreview[4],PlayerText:FurnitureTextureName;

LoadFurnTextureTD()
{
	FurnitureTexturePreview[0] = TextDrawCreate(298.000000, 373.000000, "Confirm");
	TextDrawLetterSize(FurnitureTexturePreview[0], 0.301333, 1.293036);
	TextDrawTextSize(FurnitureTexturePreview[0], 337.000000, 6.000000);
	TextDrawAlignment(FurnitureTexturePreview[0], 1);
	TextDrawColor(FurnitureTexturePreview[0], -1);
	TextDrawBoxColor(FurnitureTexturePreview[0], 255);
	TextDrawSetShadow(FurnitureTexturePreview[0], 0);
	TextDrawSetOutline(FurnitureTexturePreview[0], 1);
	TextDrawBackgroundColor(FurnitureTexturePreview[0], 255);
	TextDrawFont(FurnitureTexturePreview[0], 1);
	TextDrawSetProportional(FurnitureTexturePreview[0], 1);
	TextDrawSetShadow(FurnitureTexturePreview[0], 0);
	TextDrawSetSelectable(FurnitureTexturePreview[0], true);

	FurnitureTexturePreview[1] = TextDrawCreate(240.000000, 354.000000, "ld_beat:left");
	TextDrawLetterSize(FurnitureTexturePreview[1], 0.000000, 0.000000);
	TextDrawTextSize(FurnitureTexturePreview[1], 14.000000, 14.000000);
	TextDrawAlignment(FurnitureTexturePreview[1], 1);
	TextDrawColor(FurnitureTexturePreview[1], -1);
	TextDrawSetShadow(FurnitureTexturePreview[1], 0);
	TextDrawSetOutline(FurnitureTexturePreview[1], 0);
	TextDrawBackgroundColor(FurnitureTexturePreview[1], 255);
	TextDrawFont(FurnitureTexturePreview[1], 4);
	TextDrawSetProportional(FurnitureTexturePreview[1], 0);
	TextDrawSetShadow(FurnitureTexturePreview[1], 0);
	TextDrawSetSelectable(FurnitureTexturePreview[1], true);

	FurnitureTexturePreview[2] = TextDrawCreate(384.000000, 354.000000, "ld_beat:right");
	TextDrawLetterSize(FurnitureTexturePreview[2], 0.000000, 0.000000);
	TextDrawTextSize(FurnitureTexturePreview[2], 14.000000, 14.000000);
	TextDrawAlignment(FurnitureTexturePreview[2], 1);
	TextDrawColor(FurnitureTexturePreview[2], -1);
	TextDrawSetShadow(FurnitureTexturePreview[2], 0);
	TextDrawSetOutline(FurnitureTexturePreview[2], 0);
	TextDrawBackgroundColor(FurnitureTexturePreview[2], 255);
	TextDrawFont(FurnitureTexturePreview[2], 4);
	TextDrawSetProportional(FurnitureTexturePreview[2], 0);
	TextDrawSetShadow(FurnitureTexturePreview[2], 0);
	TextDrawSetSelectable(FurnitureTexturePreview[2], true);

	FurnitureTexturePreview[3] = TextDrawCreate(302.000000, 389.000000, "Cancel");
	TextDrawLetterSize(FurnitureTexturePreview[3], 0.301299, 1.292999);
	TextDrawTextSize(FurnitureTexturePreview[3], 334.000000, 6.000000);
	TextDrawAlignment(FurnitureTexturePreview[3], 1);
	TextDrawColor(FurnitureTexturePreview[3], -1);
	TextDrawBoxColor(FurnitureTexturePreview[3], 255);
	TextDrawSetShadow(FurnitureTexturePreview[3], 0);
	TextDrawSetOutline(FurnitureTexturePreview[3], 1);
	TextDrawBackgroundColor(FurnitureTexturePreview[3], 255);
	TextDrawFont(FurnitureTexturePreview[3], 1);
	TextDrawSetProportional(FurnitureTexturePreview[3], 1);
	TextDrawSetShadow(FurnitureTexturePreview[3], 0);
	TextDrawSetSelectable(FurnitureTexturePreview[3], true);
}

LoadPlayerFurnTextureTD(playerid)
{
	FurnitureTextureName = CreatePlayerTextDraw(playerid, 318.666717, 355.096221, "TEXTURE_NAME");
	PlayerTextDrawLetterSize(playerid, FurnitureTextureName, 0.313333, 1.234963);
	PlayerTextDrawTextSize(playerid, FurnitureTextureName, 0.000000, 124.000000);
	PlayerTextDrawAlignment(playerid, FurnitureTextureName, 2);
	PlayerTextDrawColor(playerid, FurnitureTextureName, -1);
	PlayerTextDrawUseBox(playerid, FurnitureTextureName, 1);
	PlayerTextDrawBoxColor(playerid, FurnitureTextureName, 255);
	PlayerTextDrawSetShadow(playerid, FurnitureTextureName, 0);
	PlayerTextDrawSetOutline(playerid, FurnitureTextureName, 0);
	PlayerTextDrawBackgroundColor(playerid, FurnitureTextureName, 255);
	PlayerTextDrawFont(playerid, FurnitureTextureName, 1);
	PlayerTextDrawSetProportional(playerid, FurnitureTextureName, 1);
	PlayerTextDrawSetShadow(playerid, FurnitureTextureName, 0);
	return 1;
}

ShowTextureEditTD(playerid)
{
	for(new i=0; i<sizeof(FurnitureTexturePreview); i++)
	{
		TextDrawShowForPlayer(playerid,FurnitureTexturePreview[i]);
	}
	PlayerTextDrawShow(playerid,FurnitureTextureName);
	PlayerTextDrawSetString(playerid,FurnitureTextureName,FurnitureMaterialInfo[FurnitureBuilder[playerid][furn_builder_edit_td_count]][furniture_texture_name]);
	return 1;
}

HideTextureEditTD(playerid)
{
	for(new i=0; i<sizeof(FurnitureTexturePreview); i++)
	{
		TextDrawHideForPlayer(playerid,FurnitureTexturePreview[i]);	
	}
	PlayerTextDrawHide(playerid,FurnitureTextureName);
	return 1;
}