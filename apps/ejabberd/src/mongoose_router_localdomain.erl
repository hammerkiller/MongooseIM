%%%-------------------------------------------------------------------
%%% @doc
%%% Part of a routing chain: searches for a route registered for the domain,
%%% forwards the messge there, or passes on.
%%% @end
%%%-------------------------------------------------------------------
-module(mongoose_router_localdomain).
-author('bartlomiej.gorny@erlang-solutions.com').

-behaviour(xmpp_router).

-include("ejabberd.hrl").
-include("jlib.hrl").

%% API
%% xmpp_router callback
-export([filter/3, route/3]).

filter(From, To, Packet) ->
    {From, To, Packet}.

route(From, To, Packet) ->
    LDstDomain = To#jid.lserver,
    case mnesia:dirty_read(route, LDstDomain) of
        [] ->
            {From, To, Packet};
        [#route{handler=Handler}] ->
            mongoose_local_delivery:do_route(From, To, Packet,
                LDstDomain, Handler),
            done
    end.
