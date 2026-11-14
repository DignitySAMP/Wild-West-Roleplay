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
#define COC_NAME_LEN (44)
#define COC_PAGE (20)
#define COC_BODY (2048)
#define COC_COUNT (78)
#define COC_SOUND (1085)

enum e_COC_CELL
{
    E_COC_NAME[COC_NAME_LEN],
    Float:E_COC_X,
    Float:E_COC_Y,
    Float:E_COC_Z,
}

static const s_CocCells[COC_COUNT][e_COC_CELL] =
{
    {"longcreek",-1440.1512,2619.6345,55.9187},
    {"fremont",-803.9954,1557.5048,26.7484},
    {"fort_earp",-1095.2559,2111.1040,87.3796},
    {"sheldon's shack (illegal gun creation area)",-1202.6761,1820.9307,41.7365},
    {"tb_bank3",1480.4208,1807.0251,10.8984},
    {"tb_lcgunsmith1",1563.6171,1454.8481,10.9095},
    {"tb_lcsaloon3",1408.0886,1601.7379,12.1144},
    {"house interior 1",1517.47961,1287.28503,10.60803},
    {"house interior 2",1536.11572,1287.26563,10.41645},
    {"house interior 3",1555.10193,1287.31311,10.53857},
    {"houseint_small",1011.9269,-1365.7354,13.3938},
    {"houseint_med",973.7335,-1285.1542,13.5719},
    {"houseint_large",975.3348,-1363.4771,21.7412},
    {"houseint_huge",1122.9906,-1357.7478,25.4623},
    {"longcreek_bank",-153.5868,1135.6215,3048.4385},
    {"longcreek_barber",411.4393,-21.4243,1001.3918},
    {"longcreek_cantina",1435.50195,1573.02502,10.44727},
    {"longcreek_church",1434.6119,1406.9423,10.5067},
    {"longcreek_drugs",1433.1719,1639.8480,10.4469},
    {"longcreek_hotel",-881.8845,1533.5083,1693.1853},
    {"longcreek_town_office",1436.7253,1308.5220,10.4427},
    {"longcreek_post_office",1437.5437,1485.0376,10.5789},
    {"longcreek_restaurant",1544.1324,1324.0225,19.0341},
    {"longcreek_sheriff",1433.3518,1702.7734,14.5530},
    {"ajail",-868.2317,2308.8345,160.9069},
    {"tierra_station",-833.5486,1089.6021,33.6405},
    {"train_interior",2014.7944,-23.2693,3.2962},
    {"aldea maldava",-1291.7527,2484.1301,86.7558},
    {"bayside_mine",-1918.7581,2353.6953,48.3926},
    {"prison",1642.5297,-1032.7646,23.7681},
    {"horse_ranch",1961.5240,-2281.2795,13.1615},
    {"horse_ranch_empty",177.9504,1747.5643,18.6807},
    {"barber1",957.5284,2205.1208,10.8970},
    {"barber2",1073.6851,2412.8086,10.8982},
    {"clothing1",-239.1692,1220.1761,19.8194},
    {"clothing2",1078.1964,2323.9573,10.9018},
    {"gen_store1",-2052.6104,-2512.5173,33.9302},
    {"gen_store2",2171.0186,-1799.2922,13.4502},
    {"hunting_store",1175.2909,2615.6201,10.6632},
    {"hunting_store2",-1328.8107,-591.4532,17.9513},
    {"hunting_store3",-334.7599,1042.4633,25.7103},
    {"liquor_store1",303.2332,2055.2053,17.6594},
    {"liquor_store2",-1325.4744,-27.4872,14.1799},
    {"sheriff1",1336.4110,-1874.9554,22.7998},
    {"sheriff2",571.7567,1665.0562,7.5449},
    {"sheriff3",2817.5288,731.8538,23.9329},
    {"weapon_store",-316.7060,1298.4343,60.2147},
    {"weapon_store2",-219.6203,-227.9839,1.5120},
    {"weapon_store3",-2904.4045,478.6131,4.9380},
    {"empty house int",1142.8990,-1810.0664,33.2668},
    {"david_house",1670.5298,1376.1134,21.4383},
    {"reyo_house",2032.2625,-2046.1571,34.7395},
    {"reyo_house2",1841.3446,-1147.5005,54.8089},
    {"dignity_house",1253.3739,-2015.6667,59.5656},
    {"pinta_house",1141.6179,1266.7310,10.4945},
    {"post_office",306.4180,2022.2731,17.4144},
    {"post_office2",1328.9047,-1548.9105,85.2555},
    {"blacksmith",576.1747,-1636.7098,38.1969},
    {"blacksmith2",2765.4272,-1451.5586,66.5569},
    {"blacksmith3",2582.5034,-1335.0302,62.8364},
    {"bank1",1922.9739,1616.9777,199.3454},
    {"bank2",1128.1350,-1796.3439,33.2576},
    {"saloon1",1563.0435,-2645.1775,13.1680},
    {"saloon2",2608.2205,-1271.9708,80.7746},
    {"saloon2 small",2608.2205,-1271.9708,80.7746},
    {"saloon3",1509.2162,-1480.1608,63.5773},
    {"church1",1283.9452,-1213.4783,13.3579},
    {"church2",1009.67352,-1663.92871,26.93190},
    {"church2_conf_priest",1019.6225,-1688.2217,29.6165},
    {"church2_conf_sinner",1016.4417,-1688.2490,29.6165},
    {"church3",1558.2579,-1257.0980,277.4514},
    {"courthouse",1397.6018,-2437.4070,13.5890},
    {"bakery1",1536.8920,1584.6854,10.5655},
    {"bakery2",-8.5545,-301.6842,4.6495},
    {"bakery3",-223.1016,-222.8111,1.1637},
    {"deusvult",1788.6831,-2026.6042,16.3917},
    {"clinic",1515.9843,-1531.5354,67.6177},
    {"reyo_saloon",1950.1370,744.5520,18.3776}
};

forward Coc_ListDeferred(playerid,token);

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
stock Coc_GetCount()
{
    return COC_COUNT;
}

stock Coc_GetName(index,dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (index >= 0 && index < COC_COUNT)
    {
        strcopy(dest,s_CocCells[index][E_COC_NAME],size);
    }
}

stock bool:Coc_Teleport(playerid,index)
{
    if (index < 0 || index >= COC_COUNT || !Player_IsReady(playerid))
    {
        return false;
    }

    new line[96];
    PlayerPlaySound(playerid,COC_SOUND,0.0,0.0,0.0);
    Fade_In(playerid);
    format(line,sizeof(line),"Teleported to cell (%d) %s.",index,s_CocCells[index][E_COC_NAME]);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    SetPlayerPos(playerid,s_CocCells[index][E_COC_X],s_CocCells[index][E_COC_Y],s_CocCells[index][E_COC_Z]);
    SetPlayerVirtualWorld(playerid,0);
    SetPlayerInterior(playerid,0);
    pawn_call_public("Staff_OnTeleported","dd",playerid,INVALID_PLAYER_ID);
    return true;
}

static Coc_List(playerid)
{
    yield 1;

    new token = Account_GetToken(playerid), page = 0, pages = (COC_COUNT + COC_PAGE - 1) / COC_PAGE;

    for (;;)
    {
        new body[COC_BODY] = "Cell ID \t Cell Name\n", first = page * COC_PAGE, last = first + COC_PAGE, response[DIALOG_RESPONSE], title[48];

        if (last > COC_COUNT)
        {
            last = COC_COUNT;
        }

        for (new i = first;i < last;i++)
        {
            new line[COC_NAME_LEN + 16];
            format(line,sizeof(line),"(%d) %s\n",i,s_CocCells[i][E_COC_NAME]);
            strcat(body,line,sizeof(body));
        }

        new bool:hasNext = last < COC_COUNT;

        if (hasNext)
        {
            strcat(body,"Next Page >>",sizeof(body));
        }

        format(title,sizeof(title),"Center on Cells: Page %d of %d",page + 1,pages);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,title,body,"Teleport","Close");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new pick = response[DIALOG_RESPONSE_LISTITEM];

        if (hasNext && pick == last - first)
        {
            page++;
            continue;
        }

        if (pick >= 0 && pick < last - first)
        {
            Coc_Teleport(playerid,first + pick);
        }

        return;
    }
}

forward Coc_List_Deferred(playerid,token);

public Coc_List_Deferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token))
    {
        Coc_List(playerid);
    }

    return 1;
}

static Coc_List_Defer(playerid)
{
    SetTimerEx("Coc_List_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
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
CMD:coc(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_IsModerator(playerid))
    {
        SendServerMessage(playerid,"You're not a moderator.",MSG_TYPE_ERROR);
        return 1;
    }

    SendServerMessage(playerid,"Click on a listed item to teleport to it. Use ESC to cancel.",MSG_TYPE_ERROR);
    SetTimerEx("Coc_ListDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Coc_ListDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && Staff_IsModerator(playerid))
    {
        Coc_List_Defer(playerid);
    }

    return 1;
}
