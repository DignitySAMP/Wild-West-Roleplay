/* Discord Connector
 * Version 0.2.2
 * made by maddinat0r
 */


#if defined dcconnector_included
	#endinput
#endif
#define dcconnector_included



#if !defined E_LOGLEVEL
enum E_LOGLEVEL
{
	NONE = 0,
	DEBUG = 1,
	INFO = 2,
	WARNING = 4,
	ERROR = 8,
	
	ALL = ERROR | WARNING | INFO | DEBUG
};
#endif

enum DCC_ChannelType
{
	GUILD_TEXT = 0,
	DM = 1,
	GUILD_VOICE = 2,
	GROUP_DM = 3,
	GUILD_CATEGORY = 4
};

enum DCC_UserPresenceStatus
{
	INVALID = 0,
	ONLINE = 1,
	IDLE = 2,
	DO_NOT_DISTURB = 3,
	OFFLINE = 4
};


#define DCC_INVALID_CHANNEL DCC_Channel:0
#define DCC_INVALID_USER DCC_User:0
#define DCC_INVALID_ROLE DCC_Role:0
#define DCC_INVALID_GUILD DCC_Guild:0



// natives
//  channels
native DCC_Channel:DCC_FindChannelByName(const channel_name[]);
native DCC_Channel:DCC_FindChannelById(const channel_id[]);

native DCC_GetChannelId(DCC_Channel:channel, dest[], max_size = sizeof dest);
native DCC_GetChannelType(DCC_Channel:channel, &DCC_ChannelType:type);
native DCC_GetChannelGuild(DCC_Channel:channel, &DCC_Guild:guild);
native DCC_GetChannelName(DCC_Channel:channel, dest[], max_size = sizeof dest);
native DCC_GetChannelTopic(DCC_Channel:channel, dest[], max_size = sizeof dest);

native DCC_SendChannelMessage(DCC_Channel:channel, const message[]);


//  users
native DCC_User:DCC_FindUserByName(const user_name[], const user_discriminator[]);
native DCC_User:DCC_FindUserById(const user_id[]);

native DCC_GetUserId(DCC_User:user, dest[], max_size = sizeof dest);
native DCC_GetUserName(DCC_User:user, dest[], max_size = sizeof dest);
native DCC_GetUserDiscriminator(DCC_User:user, dest[], max_size = sizeof dest);
native DCC_GetUserEmail(DCC_User:user, dest[], max_size = sizeof dest);
native DCC_IsUserBot(DCC_User:user, &bool:is_bot);
native DCC_IsUserVerified(DCC_User:user, &bool:is_verified);


//  roles
native DCC_Role:DCC_FindRoleById(const role_id[]);

native DCC_GetRoleId(DCC_Role:role, dest[], max_size = sizeof dest);
native DCC_GetRoleName(DCC_Role:role, dest[], max_size = sizeof dest);
native DCC_GetRoleColor(DCC_Role:role, &color);
stock DCC_GetRoleColour(DCC_Role:role, &colour) // for our British mates
	return DCC_GetRoleColor(role, colour);
native DCC_GetRolePermissions(DCC_Role:role, &perm_high, &perm_low); // 64 bit integer
native DCC_IsRoleHoist(DCC_Role:role, &bool:is_hoist);
native DCC_IsRoleMentionable(DCC_Role:role, &bool:is_mentionable);


//  guilds
native DCC_Guild:DCC_FindGuildByName(const guild_name[]);
native DCC_Guild:DCC_FindGuildById(const guild_id[]);

native DCC_GetGuildId(DCC_Guild:guild, dest[], max_size = sizeof dest);
native DCC_GetGuildName(DCC_Guild:guild, dest[], max_size = sizeof dest);
native DCC_GetGuildOwnerId(DCC_Guild:guild, dest[], max_size = sizeof dest);
native DCC_GetGuildRole(DCC_Guild:guild, offset, &DCC_Role:role);
native DCC_GetGuildRoleCount(DCC_Guild:guild, &count);
native DCC_GetGuildMember(DCC_Guild:guild, offset, &DCC_User:user);
native DCC_GetGuildMemberCount(DCC_Guild:guild, &count);
native DCC_GetGuildMemberNickname(DCC_Guild:guild, DCC_User:user, dest[], max_size = sizeof dest);
native DCC_GetGuildMemberRole(DCC_Guild:guild, DCC_User:user, offset, &DCC_Role:role);
native DCC_GetGuildMemberRoleCount(DCC_Guild:guild, DCC_User:user, &count);
native DCC_HasGuildMemberRole(DCC_Guild:guild, DCC_User:user, DCC_Role:role, &bool:has_role);
native DCC_GetGuildMemberStatus(DCC_Guild:guild, DCC_User:user, &DCC_UserPresenceStatus:status);
native DCC_GetGuildChannel(DCC_Guild:guild, offset, &DCC_Channel:channel);
native DCC_GetGuildChannelCount(DCC_Guild:guild, &count);



// callbacks
//  channels
forward DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[]);
forward DCC_OnChannelCreate(DCC_Channel:channel);
forward DCC_OnChannelUpdate(DCC_Channel:channel);
forward DCC_OnChannelDelete(DCC_Channel:channel);

//  users
forward DCC_OnUserUpdate(DCC_User:user);

//  guilds
forward DCC_OnGuildCreate(DCC_Guild:guild);
forward DCC_OnGuildUpdate(DCC_Guild:guild);
forward DCC_OnGuildDelete(DCC_Guild:guild);

forward DCC_OnGuildMemberAdd(DCC_Guild:guild, DCC_User:user);
forward DCC_OnGuildMemberUpdate(DCC_Guild:guild, DCC_User:user);
forward DCC_OnGuildMemberRemove(DCC_Guild:guild, DCC_User:user);

forward DCC_OnGuildRoleCreate(DCC_Guild:guild, DCC_Role:role);
forward DCC_OnGuildRoleUpdate(DCC_Guild:guild, DCC_Role:role);
forward DCC_OnGuildRoleDelete(DCC_Guild:guild, DCC_Role:role);
