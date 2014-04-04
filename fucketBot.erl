-module(fucketBot).
-export([start/0, connect/2, recv_loop/4, keyword/3]).

-define(SERVER_NAME,"FucketBot").
-define(LISTEN_PORT,9000).
-define(TCP_OPTS,[binary,{packet,raw},{nodelay,true},{reuseaddr,true},{active,once}]).

start() ->
    case gen_tcp:listen(?LISTEN_PORT, ?TCP_OPTS) of
        {ok, Listen} ->
			WordsPid = keywords:start(),
			spawn(?MODULE,connect,[Listen, WordsPid]),
            io:fwrite(?SERVER_NAME ++ " started on ~p.~n", [erlang:localtime()]);
		Error ->
            io:fwrite("Error: ~p.~n", [Error])
    end.

	
connect(Listen, WordsPid) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    inet:setopts(Socket,?TCP_OPTS),
    spawn(fun() -> connect(Listen, WordsPid) end),
	gen_tcp:send(Socket, "\n\rHi! I am FucketBot! Nice to meet you weakling."),
	gen_tcp:send(Socket, "\n\rtype in .quit , obviously to QUIT."),
	SocketOwner = "Guest",
	gen_tcp:send(Socket, "\n\n\rGuest> "),
    recv_loop(WordsPid,Socket,SocketOwner,[]),
    gen_tcp:close(Socket),
	gen_tcp:send(Socket, "FucketBot is now offline.\n\r").

	
recv_loop(WordsPid,Socket,SocketOwner,DataReceivedSoFar) ->
    inet:setopts(Socket, [{active, once}]),

    receive
        {tcp,Socket,Data} ->
			CRNLPos = binary:match(Data,<<"\r\n">>),
			if
				CRNLPos =/= nomatch ->
					Data1 = binary:split(Data,<<"\r\n">>,[trim]),
					DataReceivedSoFar1 = DataReceivedSoFar ++ Data1,
					BinData = binary:list_to_bin(DataReceivedSoFar1),
					StrData = binary:bin_to_list(BinData),
					StrDataLen = string:len(StrData),
					IsCmd = string:chr(StrData,$.) == 1,
					if
						IsCmd ->
						    CmdLine = string:tokens(StrData," "),
							[Cmd|Params] = CmdLine,
						    case Cmd of
							    ".lol" ->
									NumParams = length(Params),
									if
										NumParams == 0 ->
											gen_tcp:send(Socket,"FucketBot laughs out loud.\n\r"),
											gen_tcp:send(Socket, "\nGuest> "),
											recv_loop(WordsPid,Socket,SocketOwner,[]);
										true ->
											gen_tcp:send(Socket,"\nGuest> "),
											recv_loop(WordsPid,Socket,SocketOwner,[])		
									end;
									
								".quit" ->
									gen_tcp:send(Socket,"\n\rBye.\n\r");
								true ->
									gen_tcp:send(Socket,"\n\rError: unknown command!\n\r"),
									gen_tcp:send(Socket,"\nGuest> "),
									recv_loop(WordsPid,Socket,SocketOwner,[])
							end;
						true ->
							if 
								StrDataLen > 0 ->
												Test = keyword(StrData, WordsPid, 13),
												case Test of
													{ok, anime}->
		gen_tcp:send(Socket,"\n\rFucketBot says: Wow! Cool! I'd love it if we can watch anime together!\n\r");
	{ok, hi}->
															gen_tcp:send(Socket,"\n\rFucketBot says: Hello!\n\r");
	{ok, gundam}->
		gen_tcp:send(Socket,"\n\rFuckerBot says: I love gundams too!\n\r");
	{ok, animal}->
		gen_tcp:send(Socket,"\n\rFucketBot says: What about animals?\n\r");
	{ok, computer}->
															gen_tcp:send(Socket,"\n\rFucketBot says: Computer is man's best invention, after me. haha..\n\r");
	{ok, school}->
		gen_tcp:send(Socket,"\n\rFucketBot says: School rocks!\n\r");
	{ok, hate}->
															gen_tcp:send(Socket,"\n\rFucketBot says: uhh.. So mean.\n\r");
	{ok, love}->
															gen_tcp:send(Socket,"\n\rFucketBot says: You're quite the loving person eh?\n\r");
													{ok, great}->
															gen_tcp:send(Socket,"\n\rFucketBot says: Yeah, I agree.\n\r");
													{ok, yes}->
															gen_tcp:send(Socket,"\n\rFucketBot says: As I expected.\n\r");
													{ok, no}->
															gen_tcp:send(Socket,"\n\rFucketBot says: Why'd you say that?\n\r");
													{ok, like}->
															gen_tcp:send(Socket,"\n\rFucketBot says: That's great!\n\r");
													{ok, suck}->
															gen_tcp:send(Socket,"\n\rFucketBot says: That's kinda mean.. \n\r");
													no_keyword->
															gen_tcp:send(Socket,"\n\rFucketBot says: What the heck?\n\r")
												end;
								true ->
									true
							end,					
							gen_tcp:send(Socket,"\nGuest> "),
							recv_loop(WordsPid,Socket,SocketOwner,[])
					end;
				true ->
					io:format("~p ~p ~p~n", [inet:peername(Socket), erlang:localtime(), Data]),
					recv_loop(WordsPid,Socket,SocketOwner,DataReceivedSoFar ++ [Data])
			end;
		{tcp_closed,Socket} ->
			io:fwrite("Client disconnected on ~p.~n", [erlang:localtime()])
	end.
	
keyword(_StrData, WordsPid, N) when N == 0->
	keywords:reset(WordsPid),
	no_keyword;
	
	
keyword(StrData, WordsPid, N) when N =< 13->
	S = keywords:pop(WordsPid),
	Key = string:str(StrData, S),
	Is_empty = N-1,
	if
		S == "great"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, great};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "love"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, love};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "yes"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, yes};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "no"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, no};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "suck"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, suck};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "hate"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, hate};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "like"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, like};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "anime"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, anime};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "animal"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, animal};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "computer"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, computer};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "school"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, school};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "hi"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, hi};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end;
		S == "gundam"->
			if
			Key /= 0->
				keywords:reset(WordsPid),
				{ok, gundam};
			true ->
				keyword(StrData, WordsPid,Is_empty)
			end
		
	end.
