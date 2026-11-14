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
#define ACTOR_NAME_LEN (36)
#define ACTOR_ANIM_LEN (32)
#define ACTOR_LABEL_RANGE (7.5)
#define ACTOR_INTERACT_RANGE (5.0)
#define ACTOR_TYPES (5)
#define ACTOR_RED (0xCF4040FF)
#define ACTOR_BLUE (0x00A4DBAA)
#define ACTOR_ORANGE (0xFFA600FF)
#define ACTOR_GREY (0xC4C4C4FF)
#define ACTOR_NONE (-1)
#define ACTOR_SEED_X (-1019.6578)
#define ACTOR_SEED_Y (-643.4897)
#define ACTOR_SEED_Z (32.0078)
#define ACTOR_SEED_A (244.4535)

forward Actors_Load();
forward Actor_OnInteract(playerid,id);

enum
{
    ACTOR_TYPE_CHARACTER,
    ACTOR_TYPE_SHOPKEEPER_GENERAL,
    ACTOR_TYPE_SHOPKEEPER_ARMS,
    ACTOR_TYPE_SHOPKEEPER_FARM,
    ACTOR_TYPE_SHOPKEEPER_TOYS
}

enum e_ACTOR
{
    E_ACTOR_HOLDER,
    E_ACTOR_LABEL,
    E_ACTOR_NAME[ACTOR_NAME_LEN],
    E_ACTOR_TYPE,
    E_ACTOR_SKIN,
    E_ACTOR_WORLD,
    Float:E_ACTOR_X,
    Float:E_ACTOR_Y,
    Float:E_ACTOR_Z,
    Float:E_ACTOR_A,
    E_ACTOR_ANIMLIB[ACTOR_ANIM_LEN],
    E_ACTOR_ANIMNAME[ACTOR_ANIM_LEN]
}

static Map:s_Actors;

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
stock bool:Actor_IsValidSkin(skin)
{
    return skin >= 0 && skin <= 311 && skin != 74;
}

stock bool:Actor_IsValidAnim(const library[])
{
    for (new i = 0;i < ANIM_LIBS;i++)
    {
        if (!strcmp(library,g_AnimLibraries[i],true))
        {
            return true;
        }
    }

    return false;
}

stock bool:Actor_Exists(id)
{
    return map_valid(s_Actors) && map_has_key(s_Actors,id);
}

stock Actor_Count()
{
    return map_valid(s_Actors) ? map_size(s_Actors) : 0;
}

stock bool:Actor_Get(id,actor[e_ACTOR])
{
    if (!Actor_Exists(id))
    {
        return false;
    }

    map_get_arr(s_Actors,id,actor);
    return true;
}

static Actor_Put(id,const actor[e_ACTOR])
{
    map_set_arr(s_Actors,id,actor);
}

static Actor_Label(id,actor[e_ACTOR])
{
    new line[192];

    switch (actor[E_ACTOR_TYPE])
    {
        case ACTOR_TYPE_SHOPKEEPER_GENERAL:
        {
            format(line,sizeof(line),"[NPC] (%d) %s\n\n\n\n\n\n{BA8957}General Shopkeeper{FFFFFF}\nType /shop to interact",id,actor[E_ACTOR_NAME]);
        }
        case ACTOR_TYPE_SHOPKEEPER_ARMS:
        {
            format(line,sizeof(line),"[NPC] (%d) %s\n\n\n\n\n\n{5E5E5E}Weaponry Shopkeeper{FFFFFF}\nType /shop to interact",id,actor[E_ACTOR_NAME]);
        }
        case ACTOR_TYPE_SHOPKEEPER_FARM:
        {
            format(line,sizeof(line),"[NPC] (%d) %s\n\n\n\n\n\n{9BBA57}Farming Shopkeeper{FFFFFF}\nType /shop to interact",id,actor[E_ACTOR_NAME]);
        }
        case ACTOR_TYPE_SHOPKEEPER_TOYS:
        {
            format(line,sizeof(line),"[NPC] (%d) %s\n\n\n\n\n\n{5798BA}Clothing Shopkeeper{FFFFFF}\nType /shop to interact",id,actor[E_ACTOR_NAME]);
        }
        default:
        {
            format(line,sizeof(line),"[NPC] (%d) %s",id,actor[E_ACTOR_NAME]);
        }
    }

    if (actor[E_ACTOR_LABEL] != 0)
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:actor[E_ACTOR_LABEL]);
    }

    actor[E_ACTOR_LABEL] = _:CreateDynamic3DTextLabel(line,0xE6E6E6FF,actor[E_ACTOR_X],actor[E_ACTOR_Y],actor[E_ACTOR_Z] + 1.0,ACTOR_LABEL_RANGE,.worldid = actor[E_ACTOR_WORLD]);
}

static Actor_Animate(const actor[e_ACTOR])
{
    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID && Actor_IsValidAnim(actor[E_ACTOR_ANIMLIB]))
    {
        ApplyActorAnimation(actor[E_ACTOR_HOLDER],actor[E_ACTOR_ANIMLIB],actor[E_ACTOR_ANIMNAME],4.1,true,false,false,false,0);
    }
}

static Actor_Spawn(id,actor[e_ACTOR])
{
    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID && IsValidActor(actor[E_ACTOR_HOLDER]))
    {
        DestroyActor(actor[E_ACTOR_HOLDER]);
    }

    actor[E_ACTOR_HOLDER] = CreateActor(actor[E_ACTOR_SKIN],actor[E_ACTOR_X],actor[E_ACTOR_Y],actor[E_ACTOR_Z],actor[E_ACTOR_A]);

    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID)
    {
        SetActorFacingAngle(actor[E_ACTOR_HOLDER],actor[E_ACTOR_A]);
        SetActorVirtualWorld(actor[E_ACTOR_HOLDER],actor[E_ACTOR_WORLD]);
        SetActorInvulnerable(actor[E_ACTOR_HOLDER],true);
    }

    Actor_Animate(actor);
    Actor_Label(id,actor);
}

static Actor_Register(id,const name[],type,skin,world,Float:x,Float:y,Float:z,Float:a,const library[],const animation[])
{
    new actor[e_ACTOR];
    strcopy(actor[E_ACTOR_NAME],name,ACTOR_NAME_LEN);
    actor[E_ACTOR_TYPE] = type;
    actor[E_ACTOR_SKIN] = skin;
    actor[E_ACTOR_WORLD] = world;
    actor[E_ACTOR_X] = x;
    actor[E_ACTOR_Y] = y;
    actor[E_ACTOR_Z] = z;
    actor[E_ACTOR_A] = a;
    strcopy(actor[E_ACTOR_ANIMLIB],library,ACTOR_ANIM_LEN);
    strcopy(actor[E_ACTOR_ANIMNAME],animation,ACTOR_ANIM_LEN);
    actor[E_ACTOR_HOLDER] = INVALID_ACTOR_ID;
    Actor_Spawn(id,actor);
    Actor_Put(id,actor);
}

static Actor_Quote(const text[],dest[],size = sizeof(dest))
{
    new at;

    for (new i = 0;text[i] != EOS && at < size - 2;i++)
    {
        dest[at++] = text[i];

        if (text[i] == '\'')
        {
            dest[at++] = '\'';
        }
    }

    dest[at] = EOS;
}

static Actors_Read()
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_new("SELECT actor_id, actor_name, actor_type, actor_skinid, actor_vw, actor_x_pos, actor_y_pos, actor_z_pos, actor_a_pos, actor_animlib, actor_animname FROM actors"),false);

    if (cache_num_rows() == 0)
    {
        new query[4096] = "INSERT INTO actors (actor_name, actor_type, actor_skinid, actor_x_pos, actor_y_pos, actor_z_pos, actor_a_pos) VALUES ", chunk;

        for (new i = 0;i < ACTOR_SEED_NAMES;i++)
        {
            new skin = 1 + random(311), step = random(10), row[200], safe[ACTOR_NAME_LEN * 2];
            Actor_Quote(g_ActorSeedNames[i],safe);

            if (skin == 74)
            {
                skin = 75;
            }

            format(row,sizeof(row),"%s('%s', 0, %d, %f, %f, %f, %f)",chunk > 0 ? (", ") : (""),safe,skin,ACTOR_SEED_X + float(step),ACTOR_SEED_Y + float(step),ACTOR_SEED_Z,ACTOR_SEED_A + float(step));

            if (strlen(query) + strlen(row) >= sizeof(query) - 2)
            {
                await mysql_aquery_s(g_Mysql,str_new(query),false);
                strcopy(query,"INSERT INTO actors (actor_name, actor_type, actor_skinid, actor_x_pos, actor_y_pos, actor_z_pos, actor_a_pos) VALUES ");
                chunk = 0;
                format(row,sizeof(row),"('%s', 0, %d, %f, %f, %f, %f)",safe,skin,ACTOR_SEED_X + float(step),ACTOR_SEED_Y + float(step),ACTOR_SEED_Z,ACTOR_SEED_A + float(step));
            }

            strcat(query,row);
            chunk++;
        }

        await mysql_aquery_s(g_Mysql,str_new(query),false);

        await mysql_aquery_s(g_Mysql,str_new("SELECT actor_id, actor_name, actor_type, actor_skinid, actor_vw, actor_x_pos, actor_y_pos, actor_z_pos, actor_a_pos, actor_animlib, actor_animname FROM actors"),false);
    }

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, name[ACTOR_NAME_LEN], type, skin, world, Float:x, Float:y, Float:z, Float:a, library[ACTOR_ANIM_LEN], animation[ACTOR_ANIM_LEN];
        cache_get_value_name_int(i,"actor_id",id);
        cache_get_value_name(i,"actor_name",name,ACTOR_NAME_LEN);
        cache_get_value_name_int(i,"actor_type",type);
        cache_get_value_name_int(i,"actor_skinid",skin);
        cache_get_value_name_int(i,"actor_vw",world);
        cache_get_value_name_float(i,"actor_x_pos",x);
        cache_get_value_name_float(i,"actor_y_pos",y);
        cache_get_value_name_float(i,"actor_z_pos",z);
        cache_get_value_name_float(i,"actor_a_pos",a);
        cache_get_value_name(i,"actor_animlib",library,ACTOR_ANIM_LEN);
        cache_get_value_name(i,"actor_animname",animation,ACTOR_ANIM_LEN);

        if (id < 1 || Actor_Exists(id))
        {
            continue;
        }

        if (!Actor_IsValidSkin(skin))
        {
            skin = 1;
        }

        Actor_Register(id,name,type >= 0 && type < ACTOR_TYPES ? type : ACTOR_TYPE_CHARACTER,skin,world,x,y,z,a,library,animation);
    }

    Log_Info("actors","Loaded %d actors",Actor_Count());
    Boot_LoaderDone();
}

#pragma warning push
#pragma warning disable 204
public Actors_Load()
{
    Actors_Read();
    return 1;
}
#pragma warning pop

public Actor_OnInteract(playerid,id)
{
    return 1;
}

static Actor_Near(playerid)
{
    if (!map_valid(s_Actors))
    {
        return ACTOR_NONE;
    }

    for (new Iter:it = map_iter(s_Actors);iter_inside(it);iter_move_next(it))
    {
        new actor[e_ACTOR], id = iter_get_key(it);
        map_get_arr(s_Actors,id,actor);

        if (actor[E_ACTOR_WORLD] == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfPoint(playerid,ACTOR_INTERACT_RANGE,actor[E_ACTOR_X],actor[E_ACTOR_Y],actor[E_ACTOR_Z]))
        {
            return id;
        }
    }

    return ACTOR_NONE;
}

static bool:Actor_Gate(playerid,id,actor[e_ACTOR])
{
    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return false;
    }

    if (!Actor_Get(id,actor))
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} This actor isn't valid.");
        return false;
    }

    return true;
}

static Actor_Note(playerid,const text[])
{
    new line[200];
    format(line,sizeof(line),"[i]{B5B5B5} Note:{ffffff} %s",text);
    SendClientMessage(playerid,ACTOR_BLUE,line);
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
CMD:actorhelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    SendClientMessage(playerid,ACTOR_ORANGE,"Actor commands available to you");
    SendClientMessage(playerid,ACTOR_GREY,"/actorgoto, /actormove, /actorsetangle");
    SendClientMessage(playerid,ACTOR_GREY,"/actorsettype, /actorsetskin, /actorsetvw");
    return 1;
}

CMD:actorsetanim(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, library[ACTOR_ANIM_LEN], animation[ACTOR_ANIM_LEN], actor[e_ACTOR];

    if (sscanf(params,"is[32]s[32]",id,library,animation))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorsetanim [id] [animlib] [animname]");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    if (!Actor_IsValidAnim(library))
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} The animation you entered isn't valid.");
        return 1;
    }

    new line[160];
    strcopy(actor[E_ACTOR_ANIMLIB],library,ACTOR_ANIM_LEN);
    strcopy(actor[E_ACTOR_ANIMNAME],animation,ACTOR_ANIM_LEN);
    Actor_Animate(actor);
    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_animlib = '%e', actor_animname = '%e' WHERE actor_id = %d",library,animation,id));
    format(line,sizeof(line),"Succesfully adjusted actor ID %d's animation to \"%s\", \"%s\"",id,library,animation);
    Actor_Note(playerid,line);
    return 1;
}

CMD:actorgoto(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, actor[e_ACTOR];

    if (sscanf(params,"i",id))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorgoto [id]");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    SetPlayerVirtualWorld(playerid,actor[E_ACTOR_WORLD]);
    AC_SetPlayerPos(playerid,actor[E_ACTOR_X],actor[E_ACTOR_Y],actor[E_ACTOR_Z]);
    return 1;
}

CMD:actormove(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, actor[e_ACTOR];

    if (sscanf(params,"i",id))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actormove [id]");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    new Float:x, Float:y, Float:z, world = GetPlayerVirtualWorld(playerid), line[96];
    GetPlayerPos(playerid,x,y,z);
    actor[E_ACTOR_X] = x;
    actor[E_ACTOR_Y] = y;
    actor[E_ACTOR_Z] = z;
    actor[E_ACTOR_WORLD] = world;

    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID)
    {
        SetActorPos(actor[E_ACTOR_HOLDER],x,y,z);
        SetActorVirtualWorld(actor[E_ACTOR_HOLDER],world);
    }

    Actor_Label(id,actor);
    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_x_pos = %f, actor_y_pos = %f, actor_z_pos = %f, actor_vw = %d WHERE actor_id = %d",x,y,z,world,id));
    format(line,sizeof(line),"Succesfully moved actor ID %d to your location.",id);
    Actor_Note(playerid,line);
    Actor_Note(playerid,"You can use /actorsetangle to adjust the actor's facing angle.");
    return 1;
}

CMD:actorsetangle(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, Float:angle, actor[e_ACTOR];

    if (sscanf(params,"if",id,angle))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorsetangle [id] [angle]");
        return 1;
    }

    if (angle < 0.0 || angle > 360.0)
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} Angle can't be less than 0 or more than 360.");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    new line[96];
    actor[E_ACTOR_A] = angle;

    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID)
    {
        SetActorFacingAngle(actor[E_ACTOR_HOLDER],angle);
    }

    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_a_pos = %f WHERE actor_id = %d",angle,id));
    format(line,sizeof(line),"Succesfully adjusted actor ID %d's facing angle to %f",id,angle);
    Actor_Note(playerid,line);
    return 1;
}

CMD:actorsettype(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, type, actor[e_ACTOR];

    if (sscanf(params,"ii",id,type))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorsettype [id] [type]");
        return 1;
    }

    if (type < 0 || type >= ACTOR_TYPES)
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} Type can't be less than 0 or more than 4.");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    new line[96];
    actor[E_ACTOR_TYPE] = type;
    Actor_Label(id,actor);
    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_type = %d WHERE actor_id = %d",type,id));
    format(line,sizeof(line),"Succesfully adjusted actor ID %d's type to %d",id,type);
    Actor_Note(playerid,line);
    return 1;
}

CMD:actorsetskin(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, skin, actor[e_ACTOR];

    if (sscanf(params,"ii",id,skin))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorsetskin [id] [skin]");
        return 1;
    }

    if (!Actor_IsValidSkin(skin))
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} The skin ID you entered isn't valid.");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    new line[96];
    actor[E_ACTOR_SKIN] = skin;
    Actor_Spawn(id,actor);
    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_skinid = %d WHERE actor_id = %d",skin,id));
    format(line,sizeof(line),"Succesfully adjusted actor ID %d's skin to %d",id,skin);
    Actor_Note(playerid,line);
    return 1;
}

CMD:actorsetvw(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id, world, actor[e_ACTOR];

    if (sscanf(params,"ii",id,world))
    {
        SendClientMessage(playerid,ACTOR_RED,"[!]{B5B5B5} Syntax:{ffffff} /actorsetvw [id] [vw]");
        return 1;
    }

    if (world < 0)
    {
        SendClientMessage(playerid,ACTOR_BLUE,"[i]{B5B5B5} Note:{ffffff} The virtual world has to be higher than 0.");
        return 1;
    }

    if (!Actor_Gate(playerid,id,actor))
    {
        return 1;
    }

    new line[96];
    actor[E_ACTOR_WORLD] = world;

    if (actor[E_ACTOR_HOLDER] != INVALID_ACTOR_ID)
    {
        SetActorVirtualWorld(actor[E_ACTOR_HOLDER],world);
    }

    Actor_Label(id,actor);
    Actor_Put(id,actor);
    mysql_pquery_s(g_Mysql,str_format("UPDATE actors SET actor_vw = %d WHERE actor_id = %d",world,id));
    format(line,sizeof(line),"Succesfully adjusted actor ID %d's virtual world to %d",id,world);
    Actor_Note(playerid,line);
    return 1;
}

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

hook OnMigrationRun()
{
    Migration_Add("actors-1-actors","CREATE TABLE IF NOT EXISTS actors (actor_id INT UNSIGNED NOT NULL AUTO_INCREMENT, actor_name VARCHAR(40) NOT NULL DEFAULT '', actor_type INT NOT NULL DEFAULT 0, actor_skinid INT NOT NULL DEFAULT 1, actor_vw INT NOT NULL DEFAULT 0, actor_x_pos FLOAT NOT NULL DEFAULT 0, actor_y_pos FLOAT NOT NULL DEFAULT 0, actor_z_pos FLOAT NOT NULL DEFAULT 0, actor_a_pos FLOAT NOT NULL DEFAULT 0, actor_animlib VARCHAR(32) NOT NULL DEFAULT '', actor_animname VARCHAR(32) NOT NULL DEFAULT '', PRIMARY KEY (actor_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnGameModeInit()
{
    s_Actors = map_new();
    Boot_RegisterLoader("Actors_Load");
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_CTRL_BACK) || (oldkeys & KEY_CTRL_BACK))
    {
        return;
    }

    new id = Actor_Near(playerid);

    if (id != ACTOR_NONE)
    {
        pawn_call_public("Actor_OnInteract","dd",playerid,id);
    }
}
