-module(keywords).
-compile(export_all).

start()->
		Keywords = ["suck", "hate", "like", "anime", "animal", "computer", "school", "hi", "gundam", "great", "love", "yes", "no"],
		spawn(?MODULE, loop, [Keywords]).
		
loop(Keywords)->
		receive
			{From, reset}->
				Keys = ["suck", "hate", "like", "anime", "animal", "computer", "school", "hi", "gundam", "great", "love", "yes", "no"],
				From ! ok,
				loop(Keys);
			{From, pop}->
				if
					Keywords /= []->
						[H|New] = Keywords,
						From ! {ok, H},
						loop(New);
					true->
						From ! error,
						loop(Keywords)
				end;
			{From, push, Data}->
				New = [Data|Keywords],
				From ! ok,
				loop(New);
			{From, top}->
				[H|_T] = Keywords,
				From ! {ok, H},
				loop(Keywords);
			{From, is_empty}->
				if
					Keywords == []->
						From ! true;
					true->
						From ! false
				end;
			{From, stop}->
				From ! ok,
				true;
			_ ->
				io:fwrite("Error!", [])
		end.

push(WordsPid, Data)->
	WordsPid ! {self(), push, Data},
	receive
		Reply->
			Reply
	end.
	
pop(WordsPid)->
	WordsPid ! {self(), pop},
	receive
		{ok,Reply}->
			Reply
	end.

top(WordsPid)->
	WordsPid ! {self(), top},
	receive
		{ok,Reply}->
			Reply
	end.

is_empty(WordsPid)->
	WordsPid ! {self(), is_empty},
	receive
		Reply->
			Reply
	end.
	
stop(WordsPid)->
	WordsPid ! {self(), stop},
	receive
		Reply->
			Reply
	end.
	
reset(WordsPid)->
	WordsPid ! {self(), reset},
	receive
		Reply->
			Reply
	end.
