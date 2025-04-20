#include <a_samp>
#define MAX_RDR_NAME      ( 36 )

enum RDRNameData {
	rdr_Name [ MAX_RDR_NAME ]
};

new rdr_Names [ ] [ RDRNameData ] = {
	{ "Alwyn Lloyd" },  { "Andreas Müller" },  { "Archibald Andrews" }, { "Benton Manning" }, { "Dell Hopkins" }, { "Emilio Fortuna" },
	{ "Harmon Weinstein" }, { "Leander Holland" }, { "Lucille Billingsgate" }, { "Manolo Santander" }, { "Mel Thaxton" }, { "Miranda Fortuna" },
	{ "Moses Forth" }, { "Muriel Scranton" }, { "Quique Montemayor" }, { "Raul Zubieta" }, { "Victor Melendez" }, { "Walton Lowe" },
	{ "Abner Forsyth" }, { "Aldous Worthington" }, { "Alma Horlick" }, { "Andrew McAllister" }, { "Annabel West" }, { "Billy West" },
	{ "Charles Kinnear" }, { "Clara LaGuerta" }, { "Clyde Evans" }, { "D.S. MacKenna" }, { "Elizabeth Thornton" }, { "Emily Ross" },
	{ "Eva Cortes" }, { "Grace Anderson" }, { "Harold Thornton" }, { "Howard Sawicki" }, { "Jeb Blankenship" }, { "Jenny Hamilton" },
	{ "Jimmy Saint" }, { "Juan de la Vara" }, { "Mario Alcalde" }, { "Nathan Harling" }, { "Oliver Phillips" }, { "Phillip Ross" },
	{ "Ralph Anderson" }, { "Randall Forrester" }, { "Rose Harling" }, { "Sam Odessa" }, { "Silas Spatchcock" }, { "Uriah Tollets" },
	{ "Ada Hibbs" }, { "Addison Barber" }, { "Agusto Palacios" }, { "Alberto Delafuente" }, { "Alfonzo Colmenares" }, { "Alfred Winlock" },
	{ "Alvin Briggs" }, { "Alvin McCready" }, { "Ambrose Glover" }, { "Ambrosio Falcon" }, { "Androcles Ott" }, { "Anselmo Flores" },
	{ "Antonio Villalobos" }, { "Archie Nevers" }, { "Arnett Buchanan" }, { "Barney Nugent" }, { "Basilio Taveras" }, { "Baxter Deaton" },
	{ "Bert Venters" }, { "Bo Vickers" }, { "Bud Sullivan" }, { "Bunk Trimble" }, { "Candido Salinas" }, { "Carnelious Wolfe" },
	{ "Cecil Hubbard" }, { "Chan Chut" }, { "Charlie Bengle" }, { "Chester Finch" }, { "Chi Fung" }, { "Chow Hoy" }, { "Clarence Brewer" },
	{ "Clay Willet" }, { "Cleveland Sharp" }, { "Clifford Ray" }, { "Clifton Ledbetter" }, { "Clint MacKlin" }, { "Clyde Beadle" },
	{ "Clyde Garrison" }, { "Coke Buckley" }, { "Cruz Del Valle" }, { "Damacio Guzman" }, { "Damacio Villaverde" }, { "Danphus Mosley" },
	{ "Delfino Zayas" }, { "Dewey Alcock" }, { "Diarmuid O'Keefe" }, { "Dieter Frommel" }, { "Dimas Colondres" }, { "Earl Driscoll" },
	{ "Eddie Savoy" }, { "Edgar Critchley" }, { "Eduardo Iniesta" }, { "Eli Brockman" }, { "Elvin Coggins" }, { "Elward Swann" },
	{ "Emerson Lang" }, { "Ernest Seahorn" }, { "Errol Buckmaster" }, { "Eudoro de la Barra" }, { "Eusebio Rincon" }, { "Fabian Laralde" },
	{ "Fausto Rivera" }, { "Felix Middleton" }, { "Felix Milner" }, { "Fermin Ichinaga" }, { "Fletcher King" }, { "Fortuno Garrigues" },
	{ "Friday Lee" }, { "Gaston Tidmore" }, { "Gerard Violette" }, { "Gertie Chilcote" }, { "Gilroy Massey" }, { "Giovanni Corbeilinni" },
	{ "Gladys Feaney" }, { "Gonzalo Barajas" }, { "Grady Underwood" }, { "Gregorio Rascon" }, { "Gus McCallum" }, { "Gus McCloud" },
	{ "Hal Pollard" }, { "Harvey Skaggs" }, { "Hector Delpuerto" }, { "Herman Ruff" }, { "Honesto Fonseca" }, { "Hugo Regalado" },
	{ "Humberto Parral" }, { "Ira Shelton" }, { "Jacob Ostenhaus" }, { "Jacques Billeray" }, { "Javier Bracamontes" }, { "Jesse Bryars" },
	{ "Jesus Quintero" }, { "Joaquin Barrios" }, { "Jonas Crawford" }, { "Juan Solorzano" }, { "Julio Pereida" }, { "Jung Fook-Sing" },
	{ "Juventino Sambra" }, { "Kittie Crenshaw" }, { "Kurt Lauterback" }, { "Kwok Seng" }, { "Leandro Morales" }, { "Lee Siu-Lung" },
	{ "Leland Byers" }, { "Leonard Bone" }, { "Lester Stillman" }, { "Lewis Eddins" }, { "Lewis Pickering" }, { "Lewis Shelton" },
	{ "Lloyd Duffy" }, { "Lomax Brewton" }, { "Lonnie Veers" }, { "Luis Espinoza" }, { "Luther Brines" }, { "Manolo Villareal" },
	{ "Mateo Ramoneda" }, { "Maybell Stark" }, { "Milton Riggs" }, { "Morris Snead" }, { "Munroe Dobbs" }, { "Nicolas Robredo" },
	{ "Noah Greenup" }, { "Orpheus Billingsly" }, { "Oscar Farley" }, { "Otis Pope" }, { "Pablo Navarrete" }, { "Ponciano Sandoval" },
	{ "Ralph Bagley" }, { "Ralph Dutton" }, { "Ramiro de la Cueva" }, { "Ramon Maldonado" }, { "Randy Haskins" }, { "Ray Warthington" },
	{ "Reid Kinsey" }, { "Ricardo Godinez" }, { "Robinson Crabb" }, { "Rosalee Glover" }, { "Roy Twaddle" }, { "Rufus Byrd" }, 
	{ "Sam Wah" }, { "Santino Alcalde" }, { "Saul Bundy" }, { "Shelby Bancroft" }, { "Shep Gaston" }, { "Solomon Flake" }, { "Stanley Palmer" },
	{ "Stanley Riddick" }, { "Stonewall Ellington" }, { "Sydney Tanner" }, { "Thao Long" }, { "Theodore Eaves" }, { "Titus Sinclair" },
	{ "Tobias Finkelstein" }, { "Tobias Weldon" }, { "Trent Oxley" }, { "Tripp Lockley" }, { "Vernon Cherry" }, { "Victor Makepeace" },
	{ "Virgil Scoggins" }, { "Wade Rackard" }, { "Walter Bearden" }, { "Walter McAllum" }, { "Warren Dillard" }, { "Wes Quinley" },
	{ "Wesley Cowan" }, { "Whit McSwain" }, { "Willie Henning" }, { "Wilson Benning" }, { "Wilton Glover" }, { "Wong Bing" }, 
	{ "Alden Pearce" }, { "Alden Renshaw" }, { "Arthur Shodlow" }, { "Arsenio Baldizon" }, { "Aurelio Canizales" }, { "Benicio Olivares" },
	{ "Bernard Weaver" }, { "Bert Leverick" }, { "Blake Kingston" }, { "Buford Ackley" }, { "Carlitos Borrego" }, { "Cesar Deguzman" },
	{ "Chico Renovales" }, { "Clay Brannon" }, { "Diego Bocanegra" }, { "Duke Grayson" }, { "Earl Hollingsworth" }, { "Edwin Jeffers" },
	{ "Eli Tucker" }, { "Elton Woolsey" }, { "Enrico Noriega" }, { "Esteban Aguilar" }, { "Esteban La Rosa" }, { "Eva Valentin" },
	{ "Fausto Molinas" }, { "Felipe Carriedo" }, { "Guy Crossfield" }, { "Hank Bellamy" }, { "Isaac Larch" }, { "Isaac McKinnon" },
	{ "Jessie Hargrove" }, { "Juan del Rincon" }, { "Lee Brennand" }, { "Macy Wayman" }, { "Marion Freel" }, { "Monroe Carver" },
	{ "Morgan Sterling" }, { "Nash Stringer" }, { "Paco Baldenegro" }, { "Randolph Knox" }, { "Raul Hernandez" }, { "Reinaldo Sigales" },
	{ "Remedios Jurado" }, { "Rigby Daniels" }, { "Rosario Landeros" }, { "Salvador Vegas" }, { "Sebastian Nolasco" }, { "Sergio Turrieta" },
	{ "Shelton Cole" }, { "Tito Valdezate" }, { "Vern Timmons" }, { "Victor Mansilla" }, { "Victor Ortega" }, { "Waylon Myles" },
	{ "Wesley Hubbard" }, { "Wilfredo Arrabal" }, { "Alfie Scruggs" }, { "Arcadio Gamboa" }, { "Digby Haskins" }, { "Easter Durdon" },
	{ "Elmore Vinnis" }, { "Fletch Hillard" }, { "Granville Berry" }, { "Mickey Brunson" }, { "Pinky Wilson" }, { "Rafael Jaspeado" },
	{ "Rufus Starkey" }, { "Spike Haggerty" }, { "Werner Cobb" }, { "Wesley Allen" }, { "Woody Swenson" }, { "Yago Alejandres" },
	{ "Americus Roe" }, { "Benito Penagarza" }, { "Cesar Higueras" }, { "Charlie Hinkle" }, { "Charlie Mash" }, { "Cristo Bustamante" },
	{ "Clark Hatfield" }, { "Cody Witlow" }, { "Cooper Reed" }, { "Dale Chesson" }, { "Geraldo Elisaldez" }, { "Harlan Forbes" }, 
	{ "Hestor Frith" }, { "Irvin Pennick" }, { "Isaiah Greeley" }, { "Jorge Reynoso" }, { "Julian Coronado" }, { "Julius Grimes" }, 
	{ "Lester Dugan" }, { "Link Huston" }, { "Mateo Clisante" }, { "Maurice Sweet" }, { "Melvin Spinney" }, { "Mo van Barr" }, 
	{ "Perry Rose" }, { "Quinn Malloy" }, { "Ralph Stricker" }, { "Ramiro de la Torre" }, { "Raul Ontiveros" }, { "Rigoberto Artiz" },
	{ "Roscoe Duffy" }, { "Rufus Higbee" }, { "Selestino Herrada" }, { "Sergio Abelda" }, { "Sid Winkler" }, { "Slink Bradshaw" }, 
	{ "Wade Bassett" }, { "Zebedee Nash" }, { "Arsenio Baldizon" }, { "Claude Banfield" }, { "Clay Pettiford" }, { "Errol Hewitt" },
	{ "Floyd Brogles" }, { "Hugh Leathers" }, { "Leon Galindo" }, { "Rafael Vallerino" }, { "Thurlow Reese" }, { "Alejandro Duarte" },
	{ "Angel Palomares" }, { "Benjamin Dupuis" }, { "Cyril Purvis" }, { "Dewey Greenwood" }, { "E.H. Kretzschmar" }, { "Eldin Grubb" },
	{ "Elmer Purdy" }, { "Everett Knox" }, { "Fannie Howard" }, { "Francis Gallagher" }, { "Herbert Moon" }, { "Jeb Murphy" }, 
	{ "Lyle Mouton" }, { "Marcos Pichardo" }, { "Milford Weaver" }, { "Nathanial Johnston" }, { "Norris Laskey" }, { "Porfirio Gutierrez" },
	{ "Santos Guardado" }, { "Unseen/Deceased" }, { "Aiden O'Leary" }, { "Burt Sackett" }, { "Elenora Riddick" }, { "Farmer MacGuffin" },
	{ "Heidi McCourt" }, { "Ike Bollard" }, { "Joseph Scranton" }, { "Josephine Byrd" }, { "Ignacio Sanchez" }, { "Nate Johns" },
	{ "Patrick MacFarlane" }, { "Peter Turner" }, { "Priscilla Johnson" }, { "Willie Bollard" }, { "Rev. Adair Agatha" }, 
	{ "Butcher Brothers" }, { "Cecil Perkins" }, { "Dr. Charles L. Helden" }, { "Cole Brannigan" }, { "Earl Errington" }, 
	{ "Florence Snyder" }, { "Francis Leonard Errington" }, { "Gertrude Singer" }, { "H.R. Putnan" }, { "Dr. Hayden Precent" }, 
	{ "Horace L. Curtiss" }, { "Jeremiah Somerset Esq." }, { "Johnny West" }, { "Dr. Lawrence Mariani" }, { "'One-Lung' Lester Riley" },
	{ "Lionel Fortisque" }, { "Dr. Lydia T. Pinkerton" }, { "Mary Shackleford" }, { "Melvin Brannigan" }, { "Mollie Brannigan" }, 
	{ "Two Crows Boys" }, { "Dr. Wesley Arthurs" }, { "Wildcat Willie" }, { "Willie Feaney" }, { "Adrienne Lachance" }, { "Chu Fook" }, 
	{ "Grover Boone" }, { "Lydia Morales" }, { "Mary Lou" }, { "Merche Coronado" }, { "Millicent Waterbury" }, { "Mintie Cummings" }, 
	{ "Orison Pratt" }, { "Rafael Carillo" }, { "Ramon Alvares" }, { "Santiago Valenzuela" }, { "Silas Gaskell" }, 
	{ "Willis Lassiter" }, { "Winona Picket" }, { "Harry Dobbing" }, { "Kent Gallaway" }, { "Stanley Mund" }, { "Sirus Habersham" },
	{ "Connie MacTavish" }, { "Mordecai Robbard" }, { "Willie Oats" }, { "Moses Lowson" }, { "Prof. Hector L. Burgess" }, { "Wyatt Driggers" },
	{ "Rufus Edding" }, { "Louis Granger" }, { "Betsie Errington" }, { "Ella Brannigan" }
} ;

ReturnRDRName ( arrayid ) {
	new ar_Name [ MAX_RDR_NAME ] ;
	
	format ( ar_Name, sizeof ar_Name, "%s", actorNames [ arrayid ] [ actorName ] ) ;
	return ar_Name ;
}