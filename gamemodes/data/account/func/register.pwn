new IsPlayerCreatingCharacter [ MAX_PLAYERS ] ;

new player_GenderSelection [ MAX_PLAYERS ] ;
new player_RaceSelection [ MAX_PLAYERS ] ;
new player_TownSelection [ MAX_PLAYERS ] ;
new player_SkinSelection [ MAX_PLAYERS ] ;
new player_AgeSelection [ MAX_PLAYERS ] ;

#include "data/account/func/cr/func.pwn"
#include "data/account/func/cr/tds.pwn"
#include "data/account/func/cr/td_func.pwn"
/*
public OnFilterScriptInit() {

	LoadStaticCreationTextDraws ( ) ;

	MySQL_Init () ;

	return true ;
}

public OnFilterScriptExit() {

	for ( new i; i < 1024 ; i ++ ) {

		TextDrawDestroy ( Text: i ) ;
	}

	DestroyCreationTextDraws ( 0 ) ;

	return true ;
}
*/
//CMD:cc(playerid) {

//	return PromptCharacterCreation ( playerid ) ;
//}

CMD:charactercreate(playerid) {

	//gender,race,townspawn,age,name
	if(!IsPlayerCreatingCharacter[playerid]) { return SendServerMessage(playerid,"You can only use this during character creation.",MSG_TYPE_ERROR); }
	HideCreationTextDraws(playerid);
	inline ccGenderSel(pid, dialogid, response, listitem, string: inputtext[]) {
	    
	    #pragma unused pid, dialogid, inputtext

		if(!response) {

			IsPlayerCreatingCharacter[playerid] = false;
			player_GenderSelection[playerid] = 0;
			player_RaceSelection[playerid] = 0;
			player_TownSelection[playerid] = 0;
			player_AgeSelection[playerid] = 8;
			HideCreationTextDraws(playerid);	
			return Account_CharacterCheck(playerid);
		}

		player_GenderSelection[playerid] = listitem;
		inline ccRaceSel(pid0, dialogid0, response0, listitem0, string: inputtext0[]) {

			#pragma unused pid0,dialogid0,inputtext0

			if(!response0) {

				IsPlayerCreatingCharacter[playerid] = false;
				player_GenderSelection[playerid] = 0;
				player_RaceSelection[playerid] = 0;
				player_TownSelection[playerid] = 0;
				player_AgeSelection[playerid] = 8;
				HideCreationTextDraws(playerid);	
				return Account_CharacterCheck(playerid);
			}

			player_RaceSelection[playerid] = listitem0;
			UpdateCreationSkin(playerid,0);

			inline ccTownSel(pid1, dialogid1, response1, listitem1, string: inputtext1[]) {

				#pragma unused pid1,dialogid1,inputtext1

				if(!response1) {

					IsPlayerCreatingCharacter[playerid] = false;
					player_GenderSelection[playerid] = 0;
					player_RaceSelection[playerid] = 0;
					player_TownSelection[playerid] = 0;
					player_AgeSelection[playerid] = 8;
					HideCreationTextDraws(playerid);	
					return Account_CharacterCheck(playerid);
				}

				player_TownSelection[playerid] = listitem1;

				inline ccAgeSel(pid2, dialogid2, response2, listitem2, string: inputtext2[]) {

					#pragma unused pid2,dialogid2,listitem2

					if(!response2) {

						IsPlayerCreatingCharacter[playerid] = false;
						player_GenderSelection[playerid] = 0;
						player_RaceSelection[playerid] = 0;
						player_TownSelection[playerid] = 0;
						player_AgeSelection[playerid] = 8;
						HideCreationTextDraws(playerid);	
						return Account_CharacterCheck(playerid);
					}

					if(!strlen(inputtext2)) { return Dialog_ShowCallback(playerid,using inline ccAgeSel,DIALOG_STYLE_INPUT,"Character Creation - Age","You need to put an age in for your character.\n\nInput your character's age below (8-80).","Select","Exit"); }
					if(!IsNumeric(inputtext2)) { return Dialog_ShowCallback(playerid,using inline ccAgeSel,DIALOG_STYLE_INPUT,"Character Creation - Age","Your character's age needs to be a numeric value.\n\nInput your character's age below (8-80).","Select","Exit"); }
					if(strval(inputtext2) < 8 || strval(inputtext2) > 80) { return Dialog_ShowCallback(playerid,using inline ccAgeSel,DIALOG_STYLE_INPUT,"Character Creation - Age","Your character can not be younger than 8 or older than 80.\n\nInput your character's age below (8-80).","Select","Exit"); }

					player_AgeSelection[playerid] = strval(inputtext2);

					new genders [ ] [ ] = { "Male", "Female" } ;
					new races [ ] [ ] = { "Caucasian", "Hispanic", "African", "Asian", "Native" } ;
					new towns [ ] [ ] = {"Longcreek", "Fremont" } ;
					new string[256];
					string[0] = EOS;

					format(string,sizeof(string),"Current Creation Stats:\n\nGender: %s\nRace: %s\nStarting Town: %s\nAge: %d\n\nIf you want to finish character creation and name your character, click \"Continue\" or if you want to start over, click \"Cancel\".",genders[player_GenderSelection[playerid]][0],races[player_RaceSelection[playerid]][0],towns[player_TownSelection[playerid]][0],player_AgeSelection[playerid]);

					inline ccOverView(pid3, dialogid3, response3, listitem3, string: inputtext3[]) {

						#pragma unused pid3,dialogid3,listitem3,inputtext3

						if(!response3) {

							IsPlayerCreatingCharacter[playerid] = false;
							player_GenderSelection[playerid] = 0;
							player_RaceSelection[playerid] = 0;
							player_TownSelection[playerid] = 0;
							player_AgeSelection[playerid] = 8;
							HideCreationTextDraws(playerid);	
							return Account_CharacterCheck(playerid);
						}
						return NameSelection(playerid);
					}
					Dialog_ShowCallback(playerid,using inline ccOverView,DIALOG_STYLE_MSGBOX,"Character Creation - Overview",string,"Continue","Cancel");
				}
				Dialog_ShowCallback(playerid,using inline ccAgeSel,DIALOG_STYLE_INPUT,"Character Creation - Age","Input your character's age below (8-80).","Select","Exit");
			}
			Dialog_ShowCallback(playerid,using inline ccTownSel,DIALOG_STYLE_LIST,"Character Creation - Starting Town","Longcreek\nFremont","Select","Exit");
		}
		Dialog_ShowCallback(playerid,using inline ccRaceSel,DIALOG_STYLE_LIST,"Character Creation - Race","Caucasian\nHispanic\nAfrican\nAsian\nNative","Select","Exit");
	}
	Dialog_ShowCallback(playerid,using inline ccGenderSel,DIALOG_STYLE_LIST,"Character Creation - Gender","Male\nFemale","Select","Exit");
	return true;
}

PromptCharacterCreation ( playerid ) {

	LoadCreationTextDraws ( playerid ) ;

	SendServerMessage ( playerid, "Loading creation panel, one moment ...", MSG_TYPE_WARN ); 

	defer DelayCharCreator(playerid);

	return true ;
}

timer DelayCharCreator[1000](playerid) {

	return ShowCreationTextDraws ( playerid ) ;
}	

ShowCreationTextDraws ( playerid ) {

	HideCreationTextDraws ( playerid ) ;

	CancelSelectTextDraw ( playerid ) ;
	SelectTextDraw(playerid, 0xA3A3A3FF ) ;

	for ( new i; i < sizeof ( creation_tds_static ); i ++ ) {

		TextDrawShowForPlayer(playerid,  creation_tds_static [ i ] ) ;
	}

	for ( new i; i < sizeof ( creation_tds_player ); i ++ ) {

		PlayerTextDrawShow(playerid,  creation_tds_player [ i ] ) ;
	}

	IsPlayerCreatingCharacter [ playerid ] = true ;
	player_AgeSelection [ playerid ] = 8 ;

	SendServerMessage(playerid,"If you're unable to select the arrows or otherwise cannot complete the character creation, please use /charactercreate.",MSG_TYPE_INFO);
	SendServerMessage(playerid,"Sorry for the inconvenience!",MSG_TYPE_INFO);
	
	UpdateCreationSkin ( playerid ) ;

	return true ;
}

HideCreationTextDraws ( playerid ) {
	CancelSelectTextDraw ( playerid ) ;

	for ( new i; i < sizeof ( creation_tds_static ); i ++ ) {

		TextDrawHideForPlayer(playerid,  creation_tds_static [ i ] ) ;
	}

	for ( new i; i < sizeof ( creation_tds_player ); i ++ ) {

		PlayerTextDrawHide(playerid,  creation_tds_player [ i ] ) ;
	}
}

UpdateCreationSkin ( playerid, td = 1 ) {

	switch ( player_GenderSelection [ playerid ] ) {

		case 0: {

			switch ( player_RaceSelection [ playerid ] ) {

				case 0: player_SkinSelection [ playerid ] = 95 ; // caucasian
				case 1: player_SkinSelection [ playerid ] = 58 ; // Hispanic
				case 2: player_SkinSelection [ playerid ] = 183 ; // African
				case 3: player_SkinSelection [ playerid ] = 210 ; // Asian
				case 4: player_SkinSelection [ playerid ] = 128 ; // Indian
			}
		}

		case 1: {
			switch ( player_RaceSelection [ playerid ] ) {

				case 0: player_SkinSelection [ playerid ] = 157 ; // caucasian
				case 1: player_SkinSelection [ playerid ] = 298 ; // Hispanic
				case 2: player_SkinSelection [ playerid ] = 215 ; // African
				case 3: player_SkinSelection [ playerid ] = 169 ; // Asian
				case 4: player_SkinSelection [ playerid ] = 131 ; // Indian
			}
		}
	}

	if ( IsPlayerCreatingCharacter [ playerid ] && td) {

		PlayerTextDrawHide(playerid, creation_tds_player [ 0 ] ) ;
		PlayerTextDrawSetPreviewModel(playerid, creation_tds_player [ 0 ], player_SkinSelection [ playerid ] ) ;
		PlayerTextDrawShow(playerid, creation_tds_player [ 0 ] ) ;
	}


	return true; 
}