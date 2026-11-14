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
#define KEYS_MAX_CONTEXTS (192)
#define KEYS_CHECK_LEN (32)

#define KEYS_PRIO_MENU (30)

#define KEYS_MAX_CHORDS (8)

enum E_KEY_CONTEXT
{
    KEY:E_KEY_CONTEXT_KEY,
    E_KEY_CONTEXT_PRIORITY,
    E_KEY_CONTEXT_CHECK[KEYS_CHECK_LEN],
}

enum E_KEY_CHORD
{
    KEY:E_KEY_CHORD_FIRST_KEY,
    KEY:E_KEY_CHORD_SECOND_KEY,
    E_KEY_CHORD_PRIORITY,
    E_KEY_CHORD_CHECK[KEYS_CHECK_LEN],
}

new g_KeyContexts[KEYS_MAX_CONTEXTS][E_KEY_CONTEXT];
new g_KeyContextCount;
new g_KeyChords[KEYS_MAX_CHORDS][E_KEY_CHORD];
new g_KeyChordCount;

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
stock bool:Keys_RegisterContext(KEY:key, priority, const checkPublic[])
{
    if (g_KeyContextCount >= KEYS_MAX_CONTEXTS)
    {
        Log_Error("keys","context table full - '%s' not registered",checkPublic);
        return false;
    }

    g_KeyContexts[g_KeyContextCount][E_KEY_CONTEXT_KEY] = key;
    g_KeyContexts[g_KeyContextCount][E_KEY_CONTEXT_PRIORITY] = priority;
    format(g_KeyContexts[g_KeyContextCount][E_KEY_CONTEXT_CHECK],KEYS_CHECK_LEN,"%s",checkPublic);
    g_KeyContextCount++;

    return true;
}

stock bool:Keys_RegisterChord(KEY:firstKey, KEY:secondKey, priority, const checkPublic[])
{
    if (g_KeyChordCount >= KEYS_MAX_CHORDS)
    {
        Log_Error("keys","chord table full - '%s' not registered",checkPublic);
        return false;
    }

    g_KeyChords[g_KeyChordCount][E_KEY_CHORD_FIRST_KEY] = firstKey;
    g_KeyChords[g_KeyChordCount][E_KEY_CHORD_SECOND_KEY] = secondKey;
    g_KeyChords[g_KeyChordCount][E_KEY_CHORD_PRIORITY] = priority;
    format(g_KeyChords[g_KeyChordCount][E_KEY_CHORD_CHECK],KEYS_CHECK_LEN,"%s",checkPublic);
    g_KeyChordCount++;

    return true;
}

stock bool:Keys_IsChord(KEY:newkeys, KEY:oldkeys, KEY:firstKey, KEY:secondKey)
{
    return ((newkeys & firstKey) && (newkeys & secondKey) && !((oldkeys & firstKey) && (oldkeys & secondKey)));
}
