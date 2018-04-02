%% Allow convertion back and forth between mochijson and jiffy encodings.

-module(jiffy_mochijson_bridge).


-export([jiffy_to_mochijson/1, mochijson_to_jiffy/1]).

jiffy_to_mochijson({List}) when is_list(List)->
    {struct, [{K, jiffy_to_mochijson(V)} || {K, V} <- List]};
jiffy_to_mochijson(List) when is_list(List) ->
    [jiffy_to_mochijson(X) || X <- List];
jiffy_to_mochijson(Obj) ->
    Obj.

mochijson_to_jiffy({struct, KVList}) ->
    {[{to_jiffy_string(K), mochijson_to_jiffy(V)} || {K,V} <- KVList]};
mochijson_to_jiffy([{K,_}|_] = Props) when (K =/= struct andalso
                                            K =/= array andalso
                                            K =/= json) ->
    %% taken from dmochijson2:json_encode/2. Proplists with these conditions
    %% are encoded as json objects.
    mochijson_to_jiffy({struct, Props});
mochijson_to_jiffy(Atom) when is_atom(Atom) ->
    atom_to_binary(Atom, utf8);
mochijson_to_jiffy(List) when is_list(List) ->
    [mochijson_to_jiffy(X) || X <- List];
mochijson_to_jiffy(Obj) ->
    Obj.

to_jiffy_string(B) when is_binary(B) ->
    B;
to_jiffy_string(B) when is_integer(B) ->
    integer_to_binary(B);
to_jiffy_string(B) when is_atom(B) ->
    atom_to_binary(B, utf8);
to_jiffy_string(B) when is_list(B) ->
    unicode:characters_to_binary(B).


-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

conversion_test() ->
    JiffyDoc = {[{<<"Items">>,
   [{[{<<"ul">>,{[{<<"S">>,<<"1595674">>}]}},
      {<<"ts">>,{[{<<"N">>,<<"1510058202">>}]}}]},
    {[{<<"ul">>,{[{<<"S">>,<<"1742092">>}]}},
      {<<"ts">>,{[{<<"N">>,<<"1515771751">>}]}}]},
    {[{<<"ul">>,{[{<<"S">>,<<"2117971">>}]}},
      {<<"ts">>,{[{<<"N">>,<<"1510058202">>}]}}]},
    {[{<<"ul">>,{[{<<"S">>,<<"2323037">>}]}},
      {<<"ts">>,{[{<<"N">>,<<"1510058197">>}]}}]}]},
  {<<"Count">>,8}]},

    Doc = jiffy:encode(JiffyDoc),
    JiffyDoc = jiffy:decode(Doc),
    MochiDoc = dmochijson2:decode(Doc),
    ?assertEqual(MochiDoc, jiffy_to_mochijson(JiffyDoc)),
    ?assertEqual(JiffyDoc, mochijson_to_jiffy(MochiDoc)),
    ok.

-endif.
