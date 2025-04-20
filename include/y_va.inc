/*----------------------------------------------------------------------------*\
					==============================
					 y_va - Enhanced vararg code!
					==============================
Description:
	This library currently provides two functions - va_printf and va_format
	which perform printf and format using variable arguments passed to another
	function.
	
	This is bsed on the variable parameter passing method based on code by Zeex.
	See page 15 of the code optimisations topic.
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the YSI vararg include.
	
	The Initial Developer of the Original Code is Alex "Y_Less" Cole.
	Portions created by the Initial Developer are Copyright (C) 2011
	the Initial Developer. All Rights Reserved.
	
	Contributors:
		ZeeX, koolk, JoeBullet/Google63, g_aSlice/Slice
	
	Thanks:
		JoeBullet/Google63 - Handy arbitrary ASM jump code using SCTRL.
		ZeeX - Very productive conversations.
		koolk - IsPlayerinAreaEx code.
		TheAlpha - Danish translation.
		breadfish - German translation.
		Fireburn - Dutch translation.
		yom - French translation.
		50p - Polish translation.
		Zamaroht - Spanish translation.
		Dracoblue, sintax, mabako, Xtreme, other coders - Producing other modes
			for me to strive to better.
		Pixels^ - Running XScripters where the idea was born.
		Matite - Pestering me to release it and using it.
	
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
	
Version:
	1.0
Changelog:
	02/05/11:
		First version.
Functions:
	Public:
		-
	Core:
		-
	Stock:
		-
	Static:
		-
	Inline:
		-
	API:
		-
Callbacks:
	-
Definitions:
	-
Enums:
	-
Macros:
	-
Tags:
	-
Variables:
	Global:
		-
	Static:
		-
Commands:
	-
Compile options:
	-
Operators:
	-
\*----------------------------------------------------------------------------*/

#include <YSI\internal\y_version>
#include <YSI\internal\y_funcinc>

//#define va_args<%0> %0
#define va_args<%0> {Float,File,Bit,PlayerText3D,Text,Text3D,Menu,DB,DBResult,Style,XML,Bintree,Group,_}:...
#define va_start<%0> (va_:(%0))

stock va_printf(fmat[], va_:STATIC_ARGS)
{
	new
		num_args,
		arg_start,
		arg_end;
	// Get the pointer to the number of arguments to the last function.
	#emit LOAD.S.pri   0
	#emit ADD.C        8
	#emit MOVE.alt
	// Get the number of arguments.
	#emit LOAD.I
	#emit STOR.S.pri   num_args
	// Get the variable arguments (end).
	#emit ADD
	#emit STOR.S.pri   arg_end
	// Get the variable arguments (start).
	#emit LOAD.S.pri   STATIC_ARGS
	#emit SMUL.C       4
	#emit ADD
	#emit STOR.S.pri   arg_start
	// Using an assembly loop here screwed the code up as the labels added some
	// odd stack/frame manipulation code...
	while (arg_end != arg_start)
	{
		#emit MOVE.pri
		#emit LOAD.I
		#emit PUSH.pri
		#emit CONST.pri    4
		#emit SUB.alt
		#emit STOR.S.pri   arg_end
	}
	// Push the additional parameters.
	#emit PUSH.S       fmat
	// Push the argument count.
	#emit LOAD.S.pri   num_args
	#emit ADD.C        4
	#emit LOAD.S.alt   STATIC_ARGS
	#emit XCHG
	#emit SMUL.C       4
	#emit SUB.alt
	#emit PUSH.pri
	#emit MOVE.alt
	// This gets confused if you have a local variable of the same name as it
	// seems to factor in them first, so you get the offset of the local
	// variable instead of the index of the native.
	#emit SYSREQ.C     printf
	// Clear the stack.
	#emit CONST.pri    4
	#emit ADD
	#emit MOVE.alt
	// The three lines above get the total stack data size, now remove it.
	#emit LCTRL        4
	#emit ADD
	#emit SCTRL        4
	// Now do the real return.
}

stock va_format(out[], size, fmat[], va_:STATIC_ARGS)
{
	new
		num_args,
		arg_start,
		arg_end;
	// Get the pointer to the number of arguments to the last function.
	#emit LOAD.S.pri   0
	#emit ADD.C        8
	#emit MOVE.alt
	// Get the number of arguments.
	#emit LOAD.I
	#emit STOR.S.pri   num_args
	// Get the variable arguments (end).
	#emit ADD
	#emit STOR.S.pri   arg_end
	// Get the variable arguments (start).
	#emit LOAD.S.pri   STATIC_ARGS
	#emit SMUL.C       4
	#emit ADD
	#emit STOR.S.pri   arg_start
	// Using an assembly loop here screwed the code up as the labels added some
	// odd stack/frame manipulation code...
	while (arg_end != arg_start)
	{
		#emit MOVE.pri
		#emit LOAD.I
		#emit PUSH.pri
		#emit CONST.pri    4
		#emit SUB.alt
		#emit STOR.S.pri   arg_end
	}
	// Push the additional parameters.
	#emit PUSH.S       fmat
	#emit PUSH.S       size
	#emit PUSH.S       out
	// Push the argument count.
	#emit LOAD.S.pri   num_args
	#emit ADD.C        12
	#emit LOAD.S.alt   STATIC_ARGS
	#emit XCHG
	#emit SMUL.C       4
	#emit SUB.alt
	#emit PUSH.pri
	#emit MOVE.alt
	// This gets confused if you have a local variable of the same name as it
	// seems to factor in them first, so you get the offset of the local
	// variable instead of the index of the native.
	#emit SYSREQ.C     format
	// Clear the stack.
	#emit CONST.pri    4
	#emit ADD
	#emit MOVE.alt
	// The three lines above get the total stack data size, now remove it.
	#emit LCTRL        4
	#emit ADD
	#emit SCTRL        4
	// Now do the real return.
}