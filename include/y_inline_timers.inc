/*

 -- WRITTEN BY Y_LESS, COMPILED INTO AN INCLUDE BY SATORI_KOMEIJI AKA MIONE AUCHINDOUN.

	** EXAMPLE:

public OnGameModeInit()
{
	new c = 42;
	inline F(a, b, string:d[])
	{
		printf("%d %d, %d %s", a, b, c, d);
	}
	printf("CALL");
	SetTimerEx2(using inline F, 1000, 0, "iis", 50, 11, "hi there");
	inline G()
	{
		printf("G");
	}
	printf("CALL");
	new
		r = SetTimer2(using inline G, 1000, 1);
	inline K()
	{
		KillTimer2(r);
	}
	printf("CALL");
	SetTimer2(using inline K, 10000, 0);
	printf("DONE");
	return 1;
}

This declares three new functions: "SetTimer2", "SetTimerEx2" and "KillTimer2" - they are exactly the same as their standard counterparts, 
but take an inline function instead. Also note that this uses the VERY latest version of YSI uploaded about 2 minutes ago!  The odd thing 
is, the new "Callback_Block" function that this uses is actually faster than using standard inline functions.

http://forum.sa-mp.com/showthread.php?t=400771

*/


#tryinclude <YSI\y_inline>
#tryinclude <YSI\y_malloc>

stock CompressFormat(const data[])
{
	// This function encodes the data format in to a single cell.  The format is:
	//  
	//  1111111001
	//  
	// Leading 1s indicate no data.  The 0 immediately following the leading 1s
	// indicates the start of the format section (but is not PART of the format
	// section).  The remaining bits represent either strings (1) or non-strings
	// (0).  For example "(a, string:b, c)" would be:
	//  
	//  1..10010
	//  
	// Where "1..1" indicates full-cell padding of 1s.  From this it is known that
	// the function takes three parameters: non-string, string, non-string.  In
	// addition, as strings in inline functions MUST use the "string:" tag, it is
	// known that ALL strings will ALWAYS be 128 (or "YSI_MAX_STRING") cells big.
	new
		pos = 0,
		total = 1;
	for ( ; ; )
	{
		// Now matchs the compile-time code much closer.
		switch (data[pos++])
		{
			case '\0':
			{
				break;
			}
			case 's':
			{
				total <<= 1;
			}
			default:
			{
				total = (total << 1) | 1;
			}
		}
	}
	// Store the compressed format, also instantly end the string.
	return ~total;
}

forward @SetTimer2(repeat, e_CALLBACK_FLAGS:cF, cP, cX, Alloc:cA, Alloc:a);

public @SetTimer2(repeat, e_CALLBACK_FLAGS:cF, cP, cX, Alloc:cA, Alloc:a)
{
	new
		ret[E_CALLBACK_DATA];
	ret[E_CALLBACK_DATA_FLAGS] = cF;
	ret[E_CALLBACK_DATA_POINTER] = cP;
	ret[E_CALLBACK_DATA_FORMAT] = cX;
	ret[E_CALLBACK_DATA_ALLOC] = cA;
	Callback_Block(ret, Malloc_GetData(a, 2), Malloc_GetSlotSize(a) - 2);
	if (!repeat)
	{
		free(cA);
		free(a);
	}
}

stock KillTimer2(t)
{
	KillTimer(Malloc_Get(Alloc:t, 0));
	free(Alloc:Malloc_Get(Alloc:t, 1));
	free(Alloc:t);
}

stock SetTimerEx2(callback:callback, delay, repeat, const type[], GLOBAL_TAG_TYPES:...)
{
	new
		ret[E_CALLBACK_DATA],
		mem = CompressFormat(type);
	if (!Callback_Get(callback, ret))
	{
		return 0;
	}
	if (!(ret[E_CALLBACK_DATA_FLAGS] & e_CALLBACK_FLAGS_PUBLIC) && mem != ret[E_CALLBACK_DATA_FORMAT])
	{
		P:E("Format specifier didn't match on inline function %s: %04x%04x != %04x%04x", callback, mem >>> 16, mem & 0xFFFF, ret[E_CALLBACK_DATA_FORMAT] >>> 16, ret[E_CALLBACK_DATA_FORMAT] & 0xFFFF);
		Callback_Release(ret);
		return 0;
	}
	mem = 2;
	// Allocate enough memory to store all the parameters.
	for (new i = 0; ; ++i)
	{
		switch (type[i])
		{
			case '\0':
			{
				break;
			}
			case 'i', 'd':
			{
				++mem;
			}
			case 's':
			{
				mem += YSI_MAX_STRING;
			}
			case 'a':
			{
				P:E("y_inline doesn't support arrays.");
				return 0;
			}
		}
	}
	new
		Alloc:a = malloc(mem);
	if (a == NO_ALLOC)
	{
		Callback_Release(ret);
		return 0;
	}
	// Copy all the data to an array.
	//mem = 2;
	for (new i = 0, j = 4; ; ++i, ++j)
	{
		switch (type[i])
		{
			case '\0':
			{
				break;
			}
			case 'i', 'd':
			{
				// Set variable argument string.
				--mem;
				Malloc_Set(a, mem, getarg(j));
			}
			case 's':
			{
				// Set variable argument string.
				mem -= YSI_MAX_STRING;
				Malloc_SetVAS(a, mem, j);
				//Malloc_Set(a, mem - 1, '\0');
			}
		}
	}
	// Now call the handler.
	Malloc_Set(a, 1, _:ret[E_CALLBACK_DATA_ALLOC]);
	Malloc_Set(a, 0, SetTimerEx("@SetTimer2", delay, repeat, "iiiiii", repeat, _:ret[E_CALLBACK_DATA_FLAGS], ret[E_CALLBACK_DATA_POINTER], ret[E_CALLBACK_DATA_FORMAT], _:ret[E_CALLBACK_DATA_ALLOC], _:a));
	return _:a;
}

stock SetTimer2(callback:callback, delay, repeat)
{
	new
		ret[E_CALLBACK_DATA];
	if (!Callback_Get(callback, ret))
	{
		return 0;
	}
	new
		Alloc:a = malloc(2);
	if (a == NO_ALLOC)
	{
		Callback_Release(ret);
		return 0;
	}
	// Now call the handler.
	Malloc_Set(a, 1, _:ret[E_CALLBACK_DATA_ALLOC]);
	Malloc_Set(a, 0, SetTimerEx("@SetTimer2", delay, repeat, "iiiiii", repeat, _:ret[E_CALLBACK_DATA_FLAGS], ret[E_CALLBACK_DATA_POINTER], ret[E_CALLBACK_DATA_FORMAT], _:ret[E_CALLBACK_DATA_ALLOC], _:a));
	return _:a;
}