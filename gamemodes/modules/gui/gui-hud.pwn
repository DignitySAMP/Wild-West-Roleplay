/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define HUD_VALUES (4)
#define HUD_BULLETS (10)
#define HUD_TEXT_LEN (32)
#define HUD_BORDER_COLOUR (0xD17F5EAA)
#define HUD_MONEY_COLOUR (0x4D6345FF)
#define HUD_VALUE_COLOUR (-555819350)
#define HUD_RED_COLOUR (0xF40000FF)
#define HUD_AMMO_NONE (-1)
#define HUD_AMMO_ITEM (-2)
#define HUD_EMPTY_MODEL (18631)
#define HUD_HORSE_COUNT (9)
#define HUD_STACK_COUNT (17)

enum _:E_HUD_VALUE
{
    E_HUD_VALUE_TEMPERATURE = 0,
    E_HUD_VALUE_HEALTH,
    E_HUD_VALUE_HUNGER,
    E_HUD_VALUE_THIRST,
}

static const Float:s_HudStackGeometry[17][6] =
{
    {630.0000, 249.5000, 0.0000, 18.3999, 590.0000, 0.0000},
    {629.0000, 251.0000, 0.0000, 18.1000, 591.0000, 0.0000},
    {628.0000, 252.5000, 0.0000, 17.7500, 592.0000, 0.0000},
    {625.0000, 291.5000, 0.0000, -0.2500, 595.0000, 0.0000},
    {602.0000, 255.5000, 0.5000, 1.0000, 15.0000, 15.0000},
    {619.5000, 271.0000, 0.2500, 1.0000, 15.0000, 15.0000},
    {622.5000, 279.5000, 0.1000, 0.6999, 10.0000, 10.0000},
    {602.0000, 295.5000, 0.5000, 1.0000, 15.0000, 15.0000},
    {624.0000, 311.0000, 0.2500, 1.0000, 15.0000, 15.0000},
    {625.0000, 333.0000, 0.0000, -0.2500, 595.0000, 0.0000},
    {602.0000, 337.0000, 0.5000, 1.0000, 15.0000, 15.0000},
    {624.0000, 352.5000, 0.2249, 1.0000, 15.0000, 15.0000},
    {625.0000, 374.0000, 0.0000, -0.2500, 595.0000, 0.0000},
    {602.5000, 377.0000, 0.5000, 1.0000, 15.0000, 15.0000},
    {623.5000, 392.5000, 0.2500, 1.0000, 15.0000, 15.0000},
    {623.5000, 238.0000, 0.2500, 1.0000, 0.0000, 0.0000},
    {634.5000, 434.5000, 0.2500, 1.0000, 0.0000, 0.0000}
};

static const s_HudStackProps[17][6] =
{
    {1, 0, -1, 0, 1, 286331391},
    {1, 0, -1, 0, 1, -780181846},
    {1, 0, -1, 0, 1, 286331391},
    {1, 0, -1, 0, 1, -780181761},
    {4, 0, -1, 0, 0, 0},
    {1, 3, -780181761, 0, 0, 0},
    {2, 3, -555819350, 0, 0, 0},
    {4, 0, -1, 0, 0, 0},
    {1, 3, -780181761, 0, 0, 0},
    {1, 0, -1, 0, 1, -780181761},
    {4, 0, -1, 0, 0, 0},
    {1, 3, -780181761, 0, 0, 0},
    {1, 0, -1, 0, 1, -780181761},
    {4, 0, -1, 0, 0, 0},
    {1, 3, -780181761, 0, 0, 0},
    {1, 3, -780181761, 1, 0, 0},
    {1, 3, -780181761, 1, 0, 0}
};

static const s_HudStackTexts[17][48] =
{
    "_",
    "_",
    "_",
    "_",
    "hud:radar_LocoSyndicate",
    "TEMP",
    "o",
    "hud:radar_girlfriend",
    "HEALTH",
    "_",
    "hud:radar_burgerShot",
    "HUNGER",
    "_",
    "hud:radar_dateDrink",
    "THIRST",
    "PLAYER",
    "You can use /hud to show/hide the player hud."
};

static const Float:s_HudHorseGeometry[9][6] =
{
    {591.5000, 376.0000, 0.5000, 4.4000, 503.0000, 0.0000},
    {590.0000, 377.5000, 0.5000, 4.0999, 504.0000, 0.0000},
    {589.5000, 379.0000, 0.5000, 3.7999, 505.5000, 0.0000},
    {545.0000, 381.0000, 0.5000, 3.2500, 543.0000, 0.0000},
    {556.5000, 379.5000, 0.5000, 1.0000, 15.0000, 15.0000},
    {548.0000, 394.5000, 0.2500, 1.0000, 0.0000, 0.0000},
    {517.0000, 379.5000, 0.5000, 1.0000, 15.0000, 15.0000},
    {510.5000, 394.5000, 0.2500, 1.0000, 0.0000, 0.0000},
    {506.5000, 365.0000, 0.2300, 1.0000, 750.0000, 0.0000}
};

static const s_HudHorseProps[9][6] =
{
    {1, 0, -1, 0, 1, 286331391},
    {1, 0, -1, 0, 1, -780181846},
    {1, 0, -1, 0, 1, 286331391},
    {1, 0, -1, 0, 1, -780181761},
    {4, 0, -1, 0, 1, -780181761},
    {1, 0, -780181761, 0, 0, 0},
    {4, 0, -1, 0, 1, -780181761},
    {1, 0, -780181761, 0, 0, 0},
    {1, 0, -780181761, 1, 0, 0}
};

static const s_HudHorseTexts[9][48] =
{
    "_",
    "_",
    "_",
    "_",
    "hud:radar_airYard",
    "STAMINA",
    "hud:radar_hostpital",
    "HEALTH",
    "HORSE INFORMATION"
};

static const Float:s_HudValuePositions[HUD_VALUES][2] =
{
    {619.5, 279.0},
    {618.5, 320.5},
    {618.5, 361.5},
    {618.5, 401.0}
};

static Text:s_HudStack[HUD_STACK_COUNT] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_HudHorse[HUD_HORSE_COUNT] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_HudBox[3] = {Text:INVALID_TEXT_DRAW,...};
static Text:s_HudDivider = Text:INVALID_TEXT_DRAW;
static Text:s_HudDate = Text:INVALID_TEXT_DRAW;
static s_HudDateText[64];

static PlayerText:s_HudValues[MAX_PLAYERS][HUD_VALUES];
static PlayerText:s_HudCash[MAX_PLAYERS];
static PlayerText:s_HudGunName[MAX_PLAYERS];
static PlayerText:s_HudGunModel[MAX_PLAYERS];
static PlayerText:s_HudAmmo[MAX_PLAYERS];
static PlayerText:s_HudBullets[MAX_PLAYERS][HUD_BULLETS];
static PlayerText:s_HudHorseValues[MAX_PLAYERS][2];

static bool:s_HudBuilt[MAX_PLAYERS];
static bool:s_HudVisible[MAX_PLAYERS];
static bool:s_HudHidden[MAX_PLAYERS];
static bool:s_HudHorseShown[MAX_PLAYERS];

static s_HudValueText[MAX_PLAYERS][HUD_VALUES][HUD_TEXT_LEN];
static s_HudValueColour[MAX_PLAYERS][HUD_VALUES];
static s_HudCashText[MAX_PLAYERS][HUD_TEXT_LEN];
static s_HudWeaponName[MAX_PLAYERS][HUD_TEXT_LEN];
static s_HudWeaponModel[MAX_PLAYERS];
static Float:s_HudWeaponZoom[MAX_PLAYERS];
static s_HudAmmoText[MAX_PLAYERS][HUD_TEXT_LEN];
static s_HudAmmoCount[MAX_PLAYERS];
static s_HudBulletsShown[MAX_PLAYERS];
static s_HudHorseText[MAX_PLAYERS][2][8];

static const s_HudEngineWeapons[7][2] =
{
    {25,349},
    {26,350},
    {33,357},
    {34,358},
    {24,348},
    {4,335},
    {5,336}
};

static const s_HudEngineNames[7][20] =
{
    "Shotgun",
    "Sawn-off Shotgun",
    "Repeater Rifle",
    "Scoped Rifle",
    "Revolver",
    "Hunting Knife",
    "Baseball Bat"
};

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
static Text:Hud_MakeStatic(const Float:geometry[6],const props[6],const text[])
{
    new Text:textdraw = TextDrawCreate(geometry[0],geometry[1],text);
    TextDrawFont(textdraw,TEXT_DRAW_FONT:props[0]);
    TextDrawLetterSize(textdraw,geometry[2],geometry[3]);

    if (props[1] != 0)
    {
        TextDrawAlignment(textdraw,TEXT_DRAW_ALIGN:props[1]);
    }

    TextDrawColor(textdraw,props[2]);
    TextDrawSetShadow(textdraw,props[3]);
    TextDrawSetOutline(textdraw,0);
    TextDrawBackgroundColor(textdraw,255);
    TextDrawSetProportional(textdraw,true);

    if (props[4])
    {
        TextDrawUseBox(textdraw,true);
        TextDrawBoxColor(textdraw,props[5]);
    }

    if (geometry[4] != -1.0)
    {
        TextDrawTextSize(textdraw,geometry[4],geometry[5]);
    }

    return textdraw;
}

static Text:Hud_MakeBox(Float:x,Float:y,Float:lines,Float:right,colour)
{
    new Text:textdraw = TextDrawCreate(x,y,"_");
    TextDrawLetterSize(textdraw,0.0,lines);
    TextDrawTextSize(textdraw,right,0.0);
    TextDrawBackgroundColor(textdraw,0);
    TextDrawUseBox(textdraw,true);
    TextDrawBoxColor(textdraw,colour);
    return textdraw;
}

static Hud_CreateGlobals()
{
    for (new i = 0;i < HUD_STACK_COUNT;i++)
    {
        s_HudStack[i] = Hud_MakeStatic(s_HudStackGeometry[i],s_HudStackProps[i],s_HudStackTexts[i]);
    }

    for (new i = 0;i < HUD_HORSE_COUNT;i++)
    {
        s_HudHorse[i] = Hud_MakeStatic(s_HudHorseGeometry[i],s_HudHorseProps[i],s_HudHorseTexts[i]);
    }

    s_HudBox[0] = Hud_MakeBox(615.666870,23.485183,8.740530,490.333312,286331391);
    s_HudBox[1] = Hud_MakeBox(614.000061,25.559255,8.291562,492.333343,HUD_BORDER_COLOUR);
    s_HudBox[2] = Hud_MakeBox(613.333374,26.388889,8.117897,493.0,286331391);
    s_HudDivider = Hud_MakeBox(601.0,78.0,-0.278394,550.0,HUD_BORDER_COLOUR);

    s_HudDate = TextDrawCreate(552.0,80.5," ");
    TextDrawLetterSize(s_HudDate,0.12,0.7);
    TextDrawBackgroundColor(s_HudDate,51);
    TextDrawColor(s_HudDate,HUD_BORDER_COLOUR);
    TextDrawFont(s_HudDate,TEXT_DRAW_FONT_2);
}

static PlayerText:Hud_MakeValue(playerid,Float:x,Float:y,const text[],font,Float:letterX,Float:letterY,align,colour,Float:sizeX,Float:sizeY)
{
    new PlayerText:textdraw = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawFont(playerid,textdraw,TEXT_DRAW_FONT:font);
    PlayerTextDrawLetterSize(playerid,textdraw,letterX,letterY);

    if (align != 0)
    {
        PlayerTextDrawAlignment(playerid,textdraw,TEXT_DRAW_ALIGN:align);
    }

    PlayerTextDrawColor(playerid,textdraw,colour);
    PlayerTextDrawSetShadow(playerid,textdraw,0);
    PlayerTextDrawSetOutline(playerid,textdraw,0);
    PlayerTextDrawBackgroundColor(playerid,textdraw,255);
    PlayerTextDrawSetProportional(playerid,textdraw,true);
    PlayerTextDrawTextSize(playerid,textdraw,sizeX,sizeY);
    return textdraw;
}

static bool:Hud_StackShown(playerid)
{
    return s_HudBuilt[playerid] && s_HudVisible[playerid] && !s_HudHidden[playerid];
}

static Hud_ApplyValue(playerid,index,const text[],colour)
{
    new bool:textChanged = strcmp(s_HudValueText[playerid][index],text) != 0, bool:colourChanged = s_HudValueColour[playerid][index] != colour;

    if (!textChanged && !colourChanged)
    {
        return;
    }

    strcopy(s_HudValueText[playerid][index],text,HUD_TEXT_LEN);
    s_HudValueColour[playerid][index] = colour;

    if (!s_HudBuilt[playerid])
    {
        return;
    }

    if (colourChanged)
    {
        PlayerTextDrawColor(playerid,s_HudValues[playerid][index],colour);
    }

    if (textChanged)
    {
        PlayerTextDrawSetString(playerid,s_HudValues[playerid][index],text);
    }

    if (colourChanged && Hud_StackShown(playerid))
    {
        PlayerTextDrawShow(playerid,s_HudValues[playerid][index]);
    }
}

static Hud_NeedColour(value)
{
    if (value <= 25)
    {
        return HUD_RED_COLOUR;
    }

    if (value <= 50)
    {
        return COLOR_YELLOW;
    }

    return HUD_VALUE_COLOUR;
}

stock Hud_SetHealth(playerid,Float:health)
{
    new text[HUD_TEXT_LEN], rounded = floatround(health), colour = HUD_VALUE_COLOUR;
    format(text,sizeof(text),"%.0f",health);

    if (rounded < 40)
    {
        colour = HUD_RED_COLOUR;
    }
    else if (rounded < 70)
    {
        colour = COLOR_YELLOW;
    }

    Hud_ApplyValue(playerid,E_HUD_VALUE_HEALTH,text,colour);
}

stock Hud_SetHunger(playerid,value)
{
    new text[HUD_TEXT_LEN];
    format(text,sizeof(text),"%d",value);
    Hud_ApplyValue(playerid,E_HUD_VALUE_HUNGER,text,Hud_NeedColour(value));
}

stock Hud_SetThirst(playerid,value)
{
    new text[HUD_TEXT_LEN];
    format(text,sizeof(text),"%d",value);
    Hud_ApplyValue(playerid,E_HUD_VALUE_THIRST,text,Hud_NeedColour(value));
}

stock Hud_SetTemperature(playerid,Float:temperature)
{
    new text[HUD_TEXT_LEN];
    format(text,sizeof(text),"%.1f",temperature);
    Hud_ApplyValue(playerid,E_HUD_VALUE_TEMPERATURE,text,HUD_VALUE_COLOUR);
}

stock Hud_SetCash(playerid,cents)
{
    new text[HUD_TEXT_LEN];
    Money_Format(cents,text);

    if (!strcmp(s_HudCashText[playerid],text))
    {
        return;
    }

    strcopy(s_HudCashText[playerid],text,HUD_TEXT_LEN);

    if (s_HudBuilt[playerid])
    {
        PlayerTextDrawSetString(playerid,s_HudCash[playerid],text);
    }
}

stock Hud_SetDate(const text[])
{
    if (!strcmp(s_HudDateText,text))
    {
        return;
    }

    strcopy(s_HudDateText,text);

    if (s_HudDate != Text:INVALID_TEXT_DRAW)
    {
        TextDrawSetString(s_HudDate,text);
    }
}

static Hud_ShowBullets(playerid,count)
{
    for (new i = 0;i < HUD_BULLETS;i++)
    {
        if (i < count && i >= s_HudBulletsShown[playerid])
        {
            PlayerTextDrawShow(playerid,s_HudBullets[playerid][i]);
        }
        else if (i >= count && i < s_HudBulletsShown[playerid])
        {
            PlayerTextDrawHide(playerid,s_HudBullets[playerid][i]);
        }
    }

    s_HudBulletsShown[playerid] = count;
}

stock Hud_SetWeapon(playerid,const name[],model,ammo,Float:zoom = 1.0)
{
    new bool:modelChanged = s_HudWeaponModel[playerid] != model || s_HudWeaponZoom[playerid] != zoom, bool:nameChanged = strcmp(s_HudWeaponName[playerid],name) != 0, text[HUD_TEXT_LEN], bullets = 0;

    if (ammo > 0)
    {
        format(text,sizeof(text),"%d BULLETS",ammo);
        bullets = ammo > HUD_BULLETS ? HUD_BULLETS : ammo;
    }
    else if (ammo == 0)
    {
        strcopy(text,"NO AMMO");
    }
    else if (ammo == HUD_AMMO_ITEM)
    {
        strcopy(text,"No ammo");
    }

    new bool:ammoChanged = strcmp(s_HudAmmoText[playerid],text) != 0;
    strcopy(s_HudWeaponName[playerid],name,HUD_TEXT_LEN);
    s_HudWeaponModel[playerid] = model;
    s_HudWeaponZoom[playerid] = zoom;
    strcopy(s_HudAmmoText[playerid],text,HUD_TEXT_LEN);
    s_HudAmmoCount[playerid] = bullets;

    if (!s_HudBuilt[playerid])
    {
        return;
    }

    if (nameChanged)
    {
        PlayerTextDrawSetString(playerid,s_HudGunName[playerid],name);
    }

    if (modelChanged)
    {
        PlayerTextDrawHide(playerid,s_HudGunModel[playerid]);
        PlayerTextDrawSetPreviewModel(playerid,s_HudGunModel[playerid],model);
        PlayerTextDrawSetPreviewRot(playerid,s_HudGunModel[playerid],0.0,model == HUD_EMPTY_MODEL ? 30.0 : -30.0,0.0,zoom);

        if (s_HudVisible[playerid])
        {
            PlayerTextDrawShow(playerid,s_HudGunModel[playerid]);
        }
    }

    if (ammoChanged)
    {
        PlayerTextDrawSetString(playerid,s_HudAmmo[playerid],text[0] == EOS ? (" ") : text);
    }

    if (s_HudVisible[playerid])
    {
        Hud_ShowBullets(playerid,bullets);
    }
}

stock Hud_ClearWeapon(playerid)
{
    Hud_SetWeapon(playerid,"Nothing Equipped",HUD_EMPTY_MODEL,HUD_AMMO_NONE);
}

stock bool:Hud_SetEngineWeapon(playerid,weaponid,ammo)
{
    for (new i = 0;i < sizeof(s_HudEngineWeapons);i++)
    {
        if (s_HudEngineWeapons[i][0] == weaponid)
        {
            new Float:zoom = 1.0;

            if (weaponid == 25 || weaponid == 26 || weaponid == 33 || weaponid == 34)
            {
                zoom = 2.0;
            }
            else if (weaponid == 4 || weaponid == 5)
            {
                zoom = 1.25;
            }

            Hud_SetWeapon(playerid,s_HudEngineNames[i],s_HudEngineWeapons[i][1],weaponid == 4 || weaponid == 5 ? HUD_AMMO_NONE : ammo,zoom);
            return true;
        }
    }

    Hud_ClearWeapon(playerid);
    return false;
}

static Hud_ShowHorsePanel(playerid,bool:show)
{
    for (new i = 0;i < HUD_HORSE_COUNT;i++)
    {
        if (show)
        {
            TextDrawShowForPlayer(playerid,s_HudHorse[i]);
        }
        else
        {
            TextDrawHideForPlayer(playerid,s_HudHorse[i]);
        }
    }

    for (new i = 0;i < 2;i++)
    {
        if (show)
        {
            PlayerTextDrawShow(playerid,s_HudHorseValues[playerid][i]);
        }
        else
        {
            PlayerTextDrawHide(playerid,s_HudHorseValues[playerid][i]);
        }
    }
}

stock Hud_SetHorse(playerid,Float:stamina,Float:health)
{
    new first[8], second[8];
    format(first,sizeof(first),"%.0f",stamina);
    format(second,sizeof(second),"%.0f",health);

    if (s_HudBuilt[playerid])
    {
        if (strcmp(s_HudHorseText[playerid][0],first) != 0)
        {
            PlayerTextDrawSetString(playerid,s_HudHorseValues[playerid][0],first);
        }

        if (strcmp(s_HudHorseText[playerid][1],second) != 0)
        {
            PlayerTextDrawSetString(playerid,s_HudHorseValues[playerid][1],second);
        }
    }

    strcopy(s_HudHorseText[playerid][0],first,8);
    strcopy(s_HudHorseText[playerid][1],second,8);

    if (!s_HudHorseShown[playerid])
    {
        s_HudHorseShown[playerid] = true;

        if (s_HudBuilt[playerid])
        {
            Hud_ShowHorsePanel(playerid,true);
        }
    }
}

stock Hud_HideHorse(playerid)
{
    if (!s_HudHorseShown[playerid])
    {
        return;
    }

    s_HudHorseShown[playerid] = false;

    if (s_HudBuilt[playerid])
    {
        Hud_ShowHorsePanel(playerid,false);
    }
}

static Hud_ShowStack(playerid,bool:show)
{
    for (new i = 0;i < HUD_STACK_COUNT;i++)
    {
        if (show)
        {
            TextDrawShowForPlayer(playerid,s_HudStack[i]);
        }
        else
        {
            TextDrawHideForPlayer(playerid,s_HudStack[i]);
        }
    }

    for (new i = 0;i < HUD_VALUES;i++)
    {
        if (show)
        {
            PlayerTextDrawShow(playerid,s_HudValues[playerid][i]);
        }
        else
        {
            PlayerTextDrawHide(playerid,s_HudValues[playerid][i]);
        }
    }
}

stock Hud_Show(playerid)
{
    if (!s_HudBuilt[playerid])
    {
        return;
    }

    s_HudVisible[playerid] = true;

    if (!s_HudHidden[playerid])
    {
        Hud_ShowStack(playerid,true);
    }

    for (new i = 0;i < 3;i++)
    {
        TextDrawShowForPlayer(playerid,s_HudBox[i]);
    }

    TextDrawShowForPlayer(playerid,s_HudDivider);
    TextDrawShowForPlayer(playerid,s_HudDate);
    PlayerTextDrawShow(playerid,s_HudCash[playerid]);
    PlayerTextDrawShow(playerid,s_HudGunName[playerid]);
    PlayerTextDrawShow(playerid,s_HudGunModel[playerid]);
    PlayerTextDrawShow(playerid,s_HudAmmo[playerid]);
    s_HudBulletsShown[playerid] = 0;
    Hud_ShowBullets(playerid,s_HudAmmoCount[playerid]);

    if (s_HudHorseShown[playerid])
    {
        Hud_ShowHorsePanel(playerid,true);
    }
}

stock Hud_Hide(playerid)
{
    if (!s_HudBuilt[playerid])
    {
        return;
    }

    s_HudVisible[playerid] = false;
    Hud_ShowStack(playerid,false);

    for (new i = 0;i < 3;i++)
    {
        TextDrawHideForPlayer(playerid,s_HudBox[i]);
    }

    TextDrawHideForPlayer(playerid,s_HudDivider);
    TextDrawHideForPlayer(playerid,s_HudDate);
    PlayerTextDrawHide(playerid,s_HudCash[playerid]);
    PlayerTextDrawHide(playerid,s_HudGunName[playerid]);
    PlayerTextDrawHide(playerid,s_HudGunModel[playerid]);
    PlayerTextDrawHide(playerid,s_HudAmmo[playerid]);

    for (new i = 0;i < HUD_BULLETS;i++)
    {
        PlayerTextDrawHide(playerid,s_HudBullets[playerid][i]);
    }

    s_HudBulletsShown[playerid] = 0;
    Hud_ShowHorsePanel(playerid,false);
}

stock Hud_Destroy(playerid)
{
    if (!s_HudBuilt[playerid])
    {
        return;
    }

    Hud_Hide(playerid);

    for (new i = 0;i < HUD_VALUES;i++)
    {
        PlayerTextDrawDestroy(playerid,s_HudValues[playerid][i]);
        s_HudValues[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < HUD_BULLETS;i++)
    {
        PlayerTextDrawDestroy(playerid,s_HudBullets[playerid][i]);
        s_HudBullets[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < 2;i++)
    {
        PlayerTextDrawDestroy(playerid,s_HudHorseValues[playerid][i]);
        s_HudHorseValues[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    PlayerTextDrawDestroy(playerid,s_HudCash[playerid]);
    PlayerTextDrawDestroy(playerid,s_HudGunName[playerid]);
    PlayerTextDrawDestroy(playerid,s_HudGunModel[playerid]);
    PlayerTextDrawDestroy(playerid,s_HudAmmo[playerid]);
    s_HudCash[playerid] = s_HudGunName[playerid] = s_HudGunModel[playerid] = s_HudAmmo[playerid] = PlayerText:INVALID_TEXT_DRAW;
    s_HudBuilt[playerid] = false;
}

static Hud_ResetState(playerid)
{
    for (new i = 0;i < HUD_VALUES;i++)
    {
        s_HudValueText[playerid][i][0] = EOS;
        s_HudValueColour[playerid][i] = HUD_VALUE_COLOUR;
    }

    s_HudCashText[playerid][0] = EOS;
    s_HudWeaponName[playerid][0] = EOS;
    s_HudWeaponModel[playerid] = 0;
    s_HudWeaponZoom[playerid] = 0.0;
    s_HudAmmoText[playerid][0] = EOS;
    s_HudAmmoCount[playerid] = 0;
    s_HudBulletsShown[playerid] = 0;
    s_HudHorseShown[playerid] = false;
    s_HudHorseText[playerid][0][0] = EOS;
    s_HudHorseText[playerid][1][0] = EOS;
    s_HudHidden[playerid] = false;
    s_HudVisible[playerid] = false;
    Hud_ApplyValue(playerid,E_HUD_VALUE_TEMPERATURE,"98.6",HUD_VALUE_COLOUR);
    Hud_ApplyValue(playerid,E_HUD_VALUE_HEALTH,"100",HUD_VALUE_COLOUR);
    Hud_ApplyValue(playerid,E_HUD_VALUE_HUNGER,"100",HUD_VALUE_COLOUR);
    Hud_ApplyValue(playerid,E_HUD_VALUE_THIRST,"100",HUD_VALUE_COLOUR);
    Hud_SetCash(playerid,0);
    Hud_ClearWeapon(playerid);
}

stock Hud_Build(playerid)
{
    Hud_Destroy(playerid);

    for (new i = 0;i < HUD_VALUES;i++)
    {
        s_HudValues[playerid][i] = Hud_MakeValue(playerid,s_HudValuePositions[i][0],s_HudValuePositions[i][1],s_HudValueText[playerid][i],2,0.25,1.0,3,s_HudValueColour[playerid][i],10.0,10.0);
    }

    s_HudCash[playerid] = CreatePlayerTextDraw(playerid,500.0,85.0,s_HudCashText[playerid]);
    PlayerTextDrawLetterSize(playerid,s_HudCash[playerid],0.2,0.9);
    PlayerTextDrawBackgroundColor(playerid,s_HudCash[playerid],51);
    PlayerTextDrawColor(playerid,s_HudCash[playerid],HUD_MONEY_COLOUR);
    PlayerTextDrawFont(playerid,s_HudCash[playerid],TEXT_DRAW_FONT_2);

    s_HudGunName[playerid] = CreatePlayerTextDraw(playerid,553.5,29.5,s_HudWeaponName[playerid]);
    PlayerTextDrawLetterSize(playerid,s_HudGunName[playerid],0.268333,1.114666);
    PlayerTextDrawBackgroundColor(playerid,s_HudGunName[playerid],51);
    PlayerTextDrawColor(playerid,s_HudGunName[playerid],HUD_BORDER_COLOUR);
    PlayerTextDrawFont(playerid,s_HudGunName[playerid],TEXT_DRAW_FONT_2);
    PlayerTextDrawAlignment(playerid,s_HudGunName[playerid],TEXT_DRAW_ALIGN_CENTER);

    s_HudGunModel[playerid] = CreatePlayerTextDraw(playerid,495.5,37.5,"hp_gunmodel_box");
    PlayerTextDrawTextSize(playerid,s_HudGunModel[playerid],52.5,52.5);
    PlayerTextDrawUseBox(playerid,s_HudGunModel[playerid],true);
    PlayerTextDrawBackgroundColor(playerid,s_HudGunModel[playerid],0);
    PlayerTextDrawBoxColor(playerid,s_HudGunModel[playerid],0);
    PlayerTextDrawFont(playerid,s_HudGunModel[playerid],TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawSetPreviewModel(playerid,s_HudGunModel[playerid],s_HudWeaponModel[playerid]);
    PlayerTextDrawSetPreviewRot(playerid,s_HudGunModel[playerid],0.0,s_HudWeaponModel[playerid] == HUD_EMPTY_MODEL ? 30.0 : -30.0,0.0,s_HudWeaponZoom[playerid]);

    s_HudAmmo[playerid] = CreatePlayerTextDraw(playerid,552.5,62.0,s_HudAmmoText[playerid][0] == EOS ? (" ") : s_HudAmmoText[playerid]);
    PlayerTextDrawLetterSize(playerid,s_HudAmmo[playerid],0.24,1.114666);
    PlayerTextDrawBackgroundColor(playerid,s_HudAmmo[playerid],51);
    PlayerTextDrawColor(playerid,s_HudAmmo[playerid],HUD_BORDER_COLOUR);
    PlayerTextDrawFont(playerid,s_HudAmmo[playerid],TEXT_DRAW_FONT_2);

    for (new i = 0;i < HUD_BULLETS;i++)
    {
        new PlayerText:bullet = CreatePlayerTextDraw(playerid,540.0 + 5.0 * i,40.0,"hp_gunbullet_box");
        PlayerTextDrawTextSize(playerid,bullet,25.0,25.0);
        PlayerTextDrawUseBox(playerid,bullet,true);
        PlayerTextDrawBackgroundColor(playerid,bullet,0);
        PlayerTextDrawFont(playerid,bullet,TEXT_DRAW_FONT_MODEL_PREVIEW);
        PlayerTextDrawBoxColor(playerid,bullet,0);
        PlayerTextDrawSetPreviewModel(playerid,bullet,2061);
        PlayerTextDrawSetPreviewRot(playerid,bullet,0.0,0.0,90.0,1.25);
        s_HudBullets[playerid][i] = bullet;
    }

    for (new i = 0;i < 2;i++)
    {
        s_HudHorseValues[playerid][i] = Hud_MakeValue(playerid,i == 0 ? 566.0 : 525.0,403.0,s_HudHorseText[playerid][i],2,0.25,1.0,2,HUD_VALUE_COLOUR,0.0,0.0);
    }

    s_HudBuilt[playerid] = true;
    Hud_Show(playerid);
}

stock bool:Hud_IsBuilt(playerid)
{
    return s_HudBuilt[playerid];
}

stock bool:Hud_IsHidden(playerid)
{
    return s_HudHidden[playerid];
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:hud(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!s_HudHidden[playerid])
    {
        s_HudHidden[playerid] = true;

        if (s_HudBuilt[playerid])
        {
            Hud_ShowStack(playerid,false);
        }

        SendServerMessage(playerid,"HUD has been turned off.",MSG_TYPE_INFO);
        return 1;
    }

    s_HudHidden[playerid] = false;

    if (s_HudBuilt[playerid] && s_HudVisible[playerid])
    {
        Hud_ShowStack(playerid,true);
    }

    SendServerMessage(playerid,"HUD has been turned on.",MSG_TYPE_INFO);
    return 1;
}

ALT:toghud=CMD:hud;

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnGameModeInit()
{
    Hud_CreateGlobals();
}

hook OnPlayerConnect(playerid)
{
    s_HudBuilt[playerid] = false;
    Hud_ResetState(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Hud_Destroy(playerid);
}

hook Character_OnUnload(playerid,characterid)
{
    Hud_Destroy(playerid);
    Hud_ResetState(playerid);
}

hook Player_OnReady(playerid)
{
    Hud_Build(playerid);
}

hook Money_OnChange(playerid,slot,before,after)
{
    if (slot == E_MONEY_SLOT_HAND)
    {
        Hud_SetCash(playerid,after);
    }
}
