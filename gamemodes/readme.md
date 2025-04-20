Beard system
 - Never hooked into production, but is a semi finalised system.
 - You dynamically grow a beard over time, inspired by RDR-2.

Lasso system
 - You need to be part of law enforcement
 - You can throw a lasso at somebody to pull them off their horse
 - You can tie people up with your lasso

Traps
 - You can place traps around and catch players and animals
 - Triggers bleeding on players
 - RPG-like elements: arming, disarming, examining, ...

Custom mapping
 - Custom map on login/register screen
 - Custom spawn area
 - Las Barrancas and El Quebrados are completely remapped with custom models
 - Bayside was added in WW-RP V2 - snow area. You need thermal protection or you will freeze. "Endgame" town.
 - Foliage system procedurally generated across the entire map
 - Custom prison map (more info below)
 - Tons of interior maps that fit the aesthetic
 - Has remnants of Medieval Roleplay's models, which if you're interested in it, you can access here too.
 - All roads are changed to sand or mud variants for immersion
 - Blocks out unused areas of the minimap by adding black gangzones
 - Custom 'zone' messages that pop up and can be detected serverside

Donation system
 - Work in progress, very bare bones.
 - Different donation levels
 - Private donation chat
 - You earn more money per paycheck
 - Donator only horse
 - Automatic donator removal


Account system
 - Basic randomized RP quiz (different options on every attempt)
 - Basic tutorial (currently not used, but should still work. Outdated as of WW-RP V2).
 - Basic new player task system which replaced the tutorial system 
 - Basic experience / level system.
 - Interactive textdraws on registration where you choose gender, race, town, skin and age.
 - Spawn selection method that automatically puts you into ajail, prison, crash position, predefined spawnpoint (house, business, town, ...)
 - Master account system (multiple characters with custom textdraws for selection)
 - Namechange system (character/account) 
 - /relog (/logout)

Primary needs system
 - Hunger system
 - Thirst system
 - Temperature system (you get cold if you go too far north, use campfires or thermal clothing to combat hypothermia)
 - GUI that covers the default GTA SA HUD to display these

Dynamic actors
 - Predefined types for business types
 - Actors can be completely customised by admins (set anim, set facing pos, create, delete, edit, ...)
 - You can interact with actors by pressing H (boilerplate set up, no functionality (yet).

WIP farm system
 - Able to plant soil
 - Able to plant a variety of plants
 - Soil states (empty, dug, seeded, growing, grown)
 - Water states (dehydrated, moderated, watered)
 - Health states (dead, diseases, thirsty, healthy)

Inventory system
 - Fully textdraw based
 - Cooking system (predefined campfire locations)
 - Backpack sizes (ability to upgrade slots)
 - Item rarities like in World of Warcraft
 - Can show items to other players by using /showitems
 - Dropping and picking up items (has some dupe fixes, but not recommended for use)
 - Lots of predefined (hardcoded) items
 - Item discarding
 - Item usage method
 - Helper methods for decreases (including sub-methods for per params), increases, and more

Dynamic points system (Businesses)
 - Predefined types (general, firearms, clothing, barber, liquor, saloon, hunting, bank, postal, sheriff, blacksmith, stablemaster)
 - Renting at points
 - Storing weapons in points
 - Basic till system (hardcoded item buy prices)
 - Motels for new players to rent at for a cheap price
 - Furniture system (textdraw based)
 - Advertisement system
 - Telegram system (letter system: send mail from business A to business B)

Dynamic posse system (Factions)
 - Kiosks (weapon lockers) can be set up for any posse, but default to sheriff faction
 - Charge system for sheriffs
 - Prison system for sheriffs
 - Intuitive radio system - uses transmission poles that jumble up the text based on range (fictional telephone signal towers)
 - Tackle system for sheriffs
 - Different chat color based on types (Default, law, government, gang)
 - Ability to view a list of all posses and their online members

Wanted poster system
 - Textdraw for wanted posters
 - Police can create wanted posters at any location (using object editing)

RPG skill system
 - Ability to level up different 'skills' to improve your gameplay experience
   - Weapon movement (weapon skill level)
   - Aim skill (shaking when aiming)
   - Holster skill (time needed to (un)holster weapons)
   - Job skills: fishing, woodcutting, mining, hunting, farming, blacksmithing
   - Swimming (swimming has to be unlocked, different tiers make you able to swim longer else you pass out and wash up on the shore, eventually you can swim freely)
   - Health (unused)
   - Fight style
   - Unarmed damage
   - Knife usage
   - Knife throwing

Admin system
 - Management tier (able to create stuff dynamically, assign roles, ...)
 - Admin tier (moderation, anti ban evading system, ...)
 - Helper tier (able to recieve and answer questions, sub-groups such as developer, event, faction and mappers)
 - Admin records and admin notes
 - Center on Cell command for teleportation (inspired by Skyrim)
 - Staff island mapping (/staffisland)
 - Many more commands to make moderation intuitive

Weapon system
 - All weapons are custom, there is a GUI showing unholstered weapon and bullets in the chamber
 - Bullets are tracked serverside - intuitive reload system. You can run out of bullets but keep your weapon.
 - Bullet shells are dropped when a gun is fired, can be investigated by a sheriff
 - Holstering system that plays in with the GUI (holster in pocket, on back or on gun belt). This is visible on the player.
 - Blacksmithing system where you can craft guns (including rare weapons) using mining ores
 - Ability to pass and drop/pickup weapons
 - Ability to switch equipped weapon with one that is holstered
 - Ability to modify attachment position of holstered weapons
 - Weapon skill must be learned - as a new player you will shake when you aim, move slowly and unholster slowly. You level individual skills to improve by spending experience points.

Money system 
 - Supports 'change' (i.e. $12.75).
 - Realistic values inspired by RDR-2 (if you have $100, you are essentially upper class).

Revision system
 - Ability to track updates using /updates
 - You get informed of updates when you log in

Animation system
 - Lots of small animations to make your roleplaying experience immersive (/anims)
 - Preloading animations

Anticheat system
 - This is EXTREMELY outdated (<2016). Don't expect anything to work.
 - Detects the following:
   - Money hacks
   - Health hacks
   - Weapon hacks
   - Ammo hacks
   - Airbreaking
   - C-bugging
   - Autobans disallowed weapons
   - Ban evasion
   - Teleport hacks
   - Speed hacking

Attachment system
 - Ability to buy attachments at different points
 - Ability to modify the position of attachments
 - Ability to modify the attached bone of attachmnets
 - Some attachments provide better protection against health when going to a winter area

Campfire system
 - Used to increase the 'temperate' character trait
 - Can add fuel to prolong the time and increase heat.

Damage system
 - Bleeding system (blood trail following you) - use bandage to prevent
 - Visible blood splatters on screen (textdraws) when you get damaged
 - Serverside explosions and fire damage
 - Broken leg system (can't sprint or jump, you will tumble)
 - Dying will create a corpse that can be carried/burried/burned) - used for sheriff's and/or crime RP.
 - Taking damage dismounts you from riding a horse
 - /showinjuries to show current damage
 - /showwounds to show open wounds

Job system
 - Fishing
 - Chopping trees
 - Mining ore
 - Uses the same principle: a progress bar shows up and you need to 'fight' it by spam clicking, gets harder over time depending on skill level and node difficulty)
 - Goes hand in hand with the skill system - upgrade skills to unlock better nodes.
 - All of the fish, lumber or ores go hand in hand with other systems (furniture, creating guns, cooking food, ...)
 - Uses custom textdraws (action panel) that is reused throughout all jobs and activities creating a familiar and intuitive interaction window
 - You sell job supplies in specific stores for money, sort of like deliveries

Dynamic label system
 - Admins can create 3d text labels on demand.
 - Players can request 3d text labels that admins can approve (used for roleplay scenes, inspired by VWH-RP).

Rudimentary lottery system
 - Buying tickets add to the pot
 - Uses default random() for RNG
 - Multiple winners possible - pot is automatically split

Miscalleneous systems
 - Anti spam (command)
 - Attributes system (/examine, /attribute) for roleplay
 - Fading system (/blindfold and fadein/fadeout used throughout the script)
 - Mask system (attached object that can be changed, /editmask to change the position)
 - Message of the day system (hardcoded)
 - Pause detection
 - Shake hands system (/shakehand)
 - Basic serverside time handler (custom time: 1 ingame day = 288 irl minutes)
 - Frisking system
 - /coin and /rolldice
 - Custom nametags (3d text labels) to hide health bar
 - Roleplaying commands and chat animations
 - Accent system
 - Dynamite system (serverside explosions, can only be given by admins, kills players depending on radius and creates serverside fires)
 - Session tracking
 - Fast travel points (transport system)

Dynamic gate system
 - Can be bound to players, factions or be for public use
 - Created by admins, uses /gate and dynamic objects

Minigames
 - Poker (taken from LorenC's SF-CNR, edited to fit the WW-RP aesthetic)
 - Blackjack (basic textdraws, multi player support VS house)

Horse script
 - The 'infamous' horse script from Medieval Roleplay
 - Different horse models, all are animated serverside
 - Completely removes the need for vehicles, essentially a 'custom' vehicle
 - Dismounted ("parked") horses can be damaged.
 - Custom sounds for horses (but the files are lost to time, alas...)
 - Textdraws for horse speed and health

Hunting script
 - Deers dynamically roam the map. Very basic AI (they will avoid mapping and not collide with anything, dynamically turn around. Every path is 'unique' in that regard).
 - Deers are custom models and are animated in the same way horses are - using a basic frame script.
 - You shoot deers, some weapons do more damage than others.
 - Shot deers can be skinned, giving you stuff to sell in the general stores and food.
 - Skinned deers turn bloody and despawn over time, inspired by RDR-2.
 - Basic skinning animation, you need a hunting knife for this. This is an endgame job.


