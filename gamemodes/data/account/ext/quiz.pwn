enum QuizData {

	q_question [ 64 ],
	q_correct [ 64 ],
	q_wrong [ 64 ],
	q_wrong2 [ 64 ]
} ;

new RP_Quiz [ ] [ QuizData ] = {

	{"What is metagaming?", 							 "Using OOC information IC.", "Using IC information OOC.", "Forcing actions upon another player." },
	{"What is powergaming?", 							 "Forcing actions onto another player.", "Roleplay being powerful.", "Playing to win." },
	{"What is revenge killing?", 						 "Killing a player you've already killed within 30 minutes.", "Killing someone who killed your friend.", "Planning a revenge attack against someone."},
	{"What is deathmatching?", 							 "Killing someone without a roleplay reason.", "Killing someone with a good roleplay reason.", "Duelling to the death."},
	{"What is the aim of roleplaying?",					 "Taking the role of a character.", "Killing everyone you see.", "Doing stuff you can't do in real life."},
	{"What's this server based on?", 					 "The wild west.", "The medieval era.", "Modern day U.S."},
	{"When can I stop roleplaying in the server?", 		 "With an admin's permission.", "Whenever I get bored.", "When people talk in /b."},
	{"Which of the following is grammatically correct?", "I've eaten already today.", "I've eat already today.", "I eat already today."},
	{"Can I sell ingame goods for real life stuff?", 	 "No, never.", "Yes, with an admin's permission.", "Yes, it doesn't matter."},
	{"What's the ruleset on modifications?", 			 "Anything that gives an advantage is disallowed.", "I can use whatever I want, since it's my game I'm customising.", "As long as admins don't catch me, it's fine."},
	{"Can I abuse physics? i.e. bunnyhop, tapping", 	 "No, because that's unrealistic.", "If it's possible in the game, it's possible RP-wise.", "Yes, because horses are too slow."},
	{"Can I rape someone?", 							 "Yes, with their consent and at a private area.", "Yes, with their consent.", "Yes - it's rape for a reason."},
	{"Can I kill someone after robbing them?", 			 "No, I can not.", "Yes, because they will tell the police otherwise.", "It doesn't matter."},
	{"What type of cars can you buy?", 					 "None, cars aren't invented yet.", "Old timers.", "Any car."},
	{"What chat are you allowed to use emoticons?",		 "Local/Global OOC chat.", "Normal IC chat.", "Any chat I want." },
	{"Can I PM an admin to come and assist me?", 		 "No I can't. I must /report.", "Yes, WW-RP admins are friendly.", "Yes, because /report is only for emergencies."},
	{"Which of the following is fully OOC?",			 "Admin Jail.", "An event hosted by an administrator.", "When I'm losing a roleplay scene."},
	{"Which of the following is a proper ad?",			 "Come have some drinks at The Watering Hole!", "PM me for a easy job.", "Selling a horse, contact me on the forums."}

} ; //18

//new quiz_playerQuestion [ MAX_PLAYERS ];
//new quiz_playerGrade [ MAX_PLAYERS ];
new quiz_SelectionList [ MAX_PLAYERS ] ;
new quiz_CurrentQuestion [ MAX_PLAYERS ] ;
new quiz_WrongAnswers [ MAX_PLAYERS ] ;

StartRPQuiz ( playerid )  {

	new answer_randomizer , titlestring [ 128 ], string [ 256 ] ;

	if ( quiz_SelectionList [ playerid ] == -1 ) { quiz_SelectionList [ playerid ] = randomEx ( 1, 3 ) ; }

	if ( quiz_CurrentQuestion [ playerid ] == -1 ) {

		switch ( quiz_SelectionList [ playerid ] ) {

			case 1: {

				quiz_CurrentQuestion [ playerid ] = 0 ;
			}

			case 2: {

				quiz_CurrentQuestion [ playerid ] = 1 ;
			}

			case 3: {

				quiz_CurrentQuestion [ playerid ] = 2 ;
			}
		}
	}

	quiz_Start:

	switch ( quiz_CurrentQuestion [ playerid ] ) {

		case 15, 16, 17: {

			if ( ! quiz_WrongAnswers [ playerid ] ) {

				new query [ 128 ] ;

				format(string,sizeof(string),"{DEDEDE}\
				Do you agree to follow the rules whenever you feel like it along with using commands\n\
				such as /report and /helpme as a way to directly communicate with staff whenever you want?");

				inline RuleCheck(pid,dialogid,response,listitem,string:inputtext[]) {

					#pragma unused pid,dialogid,listitem,inputtext

					if(response) { 

						mysql_format(mysql,query,sizeof(query),"UPDATE master_accounts SET account_rulecheck = 1 WHERE account_id = %d",Account[playerid][account_id]);
						mysql_tquery(mysql,query);

						Account[playerid][account_rulecheck] = 1; 

						//format(string,sizeof(string),"Master Account %s (%d) has been flagged as a \"Potential Rulebreaker\".",ReturnUserName(playerid),playerid);

						//SendModeratorWarning ( string, MOD_WARNING_MED );

						WriteLog(playerid,"register/rulecheck",string);
					}

					string[0] = EOS;

					format ( string, sizeof ( string ), "{DEDEDE}\
					You passed the server quiz!\n\nYou are on your way on becoming a full pledged member of \
					the server.\n\nYou will be taken to the character creation screen momentarily.\nIn order to continue, \
					press \"Continue\".\n\nThanks and good luck!"); 

					inline QuizResult(pid1, dialogid1, response1, listitem1, string:inputtext1[] ) { 
						#pragma unused pid1, dialogid1, response1, listitem1, inputtext1

						///////////////////////////////////////////////

						mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_registerquiz = 1 WHERE account_id = %d ", Account [ playerid ] [ account_id ] );
						mysql_tquery ( mysql, query ) ;

						Account [ playerid ] [ account_registerquiz ] = true ;

						///////////////////////////////////////////////

						quiz_WrongAnswers [ playerid ] = 0 ;
						quiz_CurrentQuestion [ playerid ] = -1 ;
						quiz_SelectionList [ playerid ] = -1 ;

						SendServerMessage ( playerid, "You have passed the quiz! Enter your password once again to finish it.", MSG_TYPE_INFO ) ;

						return Account_Authenticate ( playerid ) ;
					}

			 		return Dialog_ShowCallback(playerid, using inline QuizResult, DIALOG_STYLE_MSGBOX, "Passed server quiz", string, "Continue" ) ;
				}

				return Dialog_ShowCallback(playerid,using inline RuleCheck,DIALOG_STYLE_MSGBOX,"{FF6347}WARNING: PLEASE READ",string,"Yes","No");
			}

			else {

				SendServerMessage ( playerid, sprintf("You have failed the quiz with %i wrong %s.", quiz_WrongAnswers [ playerid ], (quiz_WrongAnswers [ playerid ] == 1) ? ("answer") : ("answers") ), MSG_TYPE_ERROR ) ;
				return KickPlayer ( playerid ) ;
			}
		}

		default: {

			quiz_CurrentQuestion [ playerid ] += 3 ;

			answer_randomizer = randomEx ( 0, 2 ) ;

			switch ( answer_randomizer ) {

				case 0: {

					format ( string, sizeof ( string ), "%s\n%s\n%s", RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_correct ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong2 ] ) ;
				}

				case 1: {

					format ( string, sizeof ( string ), "%s\n%s\n%s", RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_correct ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong2 ] ) ;
				}

				case 2: {

					format ( string, sizeof ( string ), "%s\n%s\n%s", RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_wrong2 ], RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_correct ] ) ;
				}
			}
		}
	}

	inline QuizHandler(pid, dialogid, response, listitem, string:inputtext[] ) { 
		#pragma unused pid, dialogid, inputtext

		if ( ! response ) { KickPlayer ( playerid ) ; }

		else {

			if ( listitem != answer_randomizer ) {

				quiz_WrongAnswers [ playerid ] ++ ;
			}

			goto quiz_Start ;

		}

	}

	format ( titlestring, sizeof ( titlestring ), "%s", RP_Quiz [ quiz_CurrentQuestion [ playerid ] ] [ q_question ] ) ;
 	Dialog_ShowCallback(playerid, using inline QuizHandler, DIALOG_STYLE_LIST, titlestring, string, "Select", "Exit" ) ;

	/*

	quiz_Start:

	new quiz_id = quiz_playerQuestion [ playerid ];
	new answer_select, string [ 512 ], titlestring [ 64 ], query [ 128 ] ; 

	if ( quiz_playerQuestion [ playerid ] >= sizeof ( RP_Quiz ) ) {

		quiz_playerQuestion [ playerid ] = 0 ;

		if ( quiz_playerGrade [ playerid ] == sizeof ( RP_Quiz ) ) {

			format ( string, sizeof ( string ), "{DEDEDE}\
			You passed the server quiz!\n\nYou are on your way on becoming a full pledged member of \
			the server.\n\nYou will be taken to the character creation screen momentarily.\nIn order to continue, \
			press \"Continue\".\n\nThanks and good luck!", sizeof ( RP_Quiz ), quiz_playerGrade [ playerid ]); 

			inline QuizResult(pid, dialogid, response, listitem, string:inputtext[] ) { 
			#pragma unused pid, dialogid, response, listitem, inputtext

				///////////////////////////////////////////////

				mysql_format ( mysql, query, sizeof ( query ), "UPDATE master_accounts SET account_registerquiz = 1 WHERE account_id = %d ", Account [ playerid ] [ account_id ] );
				mysql_tquery ( mysql, query ) ;

				Account [ playerid ] [ account_registerquiz ] = true ;

				///////////////////////////////////////////////

				quiz_playerGrade [ playerid ] = 0 ;

				SendServerMessage ( playerid, "You have passed the quiz! Enter your password once again to finish it.", MSG_TYPE_INFO ) ;

				return Account_Authenticate ( playerid ) ;
			}

 			return Dialog_ShowCallback(playerid, using inline QuizResult, DIALOG_STYLE_MSGBOX, "Passed server quiz", string, "Continue" ) ;
		}

		else {
			format ( string, sizeof ( string ), "{DEDEDE}\
				You have failed the server quiz!\n\nYou have to score the maximum (%d) in order to pass. \
				You had %d.\n\nWe advice you to read up on the rules and try to learn a little\nbit more about the server\
				concept and rules before continuing.\n\nBetter luck next time!", sizeof ( RP_Quiz ), quiz_playerGrade [ playerid ]); 

			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Failed server quiz", string, "Quit") ;

			quiz_playerGrade [ playerid ] = 0 ;

			
			return KickPlayer ( playerid) ;
			// Return Kick ;
		} 
	}

	answer_select = random ( 2 ) ;

	if ( ! isnull ( RP_Quiz [ quiz_id ] [ q_question_tip ] ) ) {

		if ( answer_select ) {
			format ( string, sizeof ( string ), "{00A6FF}Question %d{DEDEDE}: \"%s\" \n{C42D2D}TIP:{DEDEDE} %s \n \n{00A6FF}A: {DEDEDE} %s\n{00A6FF}B: {DEDEDE}%s", quiz_id, RP_Quiz [ quiz_id ] [ q_question ], RP_Quiz [ quiz_id ] [ q_question_tip ], RP_Quiz [ quiz_id ] [ q_correct ], RP_Quiz [ quiz_id ] [ q_wrong] );
		}

		else format ( string, sizeof ( string ), "{00A6FF}Question %d{DEDEDE}: \"%s\" \n{C42D2D}TIP:{DEDEDE} %s \n \n{00A6FF}A: {DEDEDE} %s\n{00A6FF}B: {DEDEDE}%s", quiz_id, RP_Quiz [ quiz_id ] [ q_question ], RP_Quiz [ quiz_id ] [ q_question_tip ], RP_Quiz [ quiz_id ] [ q_wrong ], RP_Quiz [ quiz_id ] [ q_correct ] );
	}

	else {

		if ( answer_select ) {
			format ( string, sizeof ( string ), "{00A6FF}Question %d{DEDEDE}: \"%s\" \n \n{00A6FF}A: {DEDEDE} %s\n{00A6FF}B: {DEDEDE}%s", quiz_id, RP_Quiz [ quiz_id ] [ q_question ], RP_Quiz [ quiz_id ] [ q_correct ], RP_Quiz [ quiz_id ] [ q_wrong] );
		}

		else format ( string, sizeof ( string ), "{00A6FF}Question %d{DEDEDE}: \"%s\" \n \n{00A6FF}A: {DEDEDE} %s\n{00A6FF}B: {DEDEDE}%s", quiz_id, RP_Quiz [ quiz_id ] [ q_question ], RP_Quiz [ quiz_id ] [ q_wrong ], RP_Quiz [ quiz_id ] [ q_correct ]  );

	}

	inline QuizHandler(pid, dialogid, response, listitem, string:inputtext[] ) { 
		#pragma unused pid, dialogid, response, listitem, inputtext

		switch ( response ) {

			case 0 : {
				switch ( answer_select ) {
					case false : quiz_playerGrade [ playerid ] ++ ; 
				}
			}

			case 1 : {
				switch ( answer_select ) {
					case true : quiz_playerGrade [ playerid ] ++ ; 
				}
			}
		}

		if ( quiz_playerQuestion [ playerid ] < sizeof ( RP_Quiz ) ) {

			quiz_playerQuestion [ playerid ] ++ ;
			goto quiz_Start ;
		}

		else if ( quiz_playerQuestion [ playerid ] == sizeof ( RP_Quiz ) ) {
			goto quiz_Start ;		
		}
	}

	format ( titlestring, sizeof ( titlestring ), "{DEDEDE} Server Quiz: {00A6FF}(%d/%d)", quiz_playerGrade [ playerid ], sizeof ( RP_Quiz ) ) ;
 	Dialog_ShowCallback(playerid, using inline QuizHandler, DIALOG_STYLE_LIST, titlestring, string, "Answer A", "Answer B" ) ;

 	*/

	return true ;
}