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
#define AUDIO_BASE_URL ""
#define AUDIO_URL_LEN (192)

static s_AudioBase[AUDIO_URL_LEN] = AUDIO_BASE_URL;

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
stock bool:Audio_Enabled()
{
    return s_AudioBase[0] != EOS;
}

stock bool:Audio_Build(const file[],dest[],size = sizeof(dest))
{
    dest[0] = EOS;

    if (s_AudioBase[0] == EOS || file[0] == EOS)
    {
        return false;
    }

    format(dest,size,"%s%s",s_AudioBase,file);
    return true;
}

stock bool:Audio_Play(playerid,const file[],Float:x = 0.0,Float:y = 0.0,Float:z = 0.0,Float:distance = 50.0,bool:usepos = false)
{
    new url[AUDIO_URL_LEN];

    if (!Audio_Build(file,url))
    {
        return false;
    }

    return PlayAudioStreamForPlayer(playerid,url,x,y,z,distance,usepos);
}

stock Audio_Stop(playerid)
{
    if (s_AudioBase[0] != EOS)
    {
        StopAudioStreamForPlayer(playerid);
    }
}

