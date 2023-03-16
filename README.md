# Flare

A fully-featured Lavalink client library for Lua that works seamlessly with Discordia.


## NOTE

This client library is in heavy development and **will** change drastically. Please do not use this production until all bugs have been worked out.


# Installation

To install this library, you must use the `lit` package manager as follows:

```
lit install cloudwithax/flare
```


# Example

Heres a quick example:

```lua
local discordia = require('discordia')
local flare      = require('flare')
local Pool       = flare.Pool
local Player     = flare.Player
local Node       = flare.Node
local client    = discordia.Client()



local node = {
    host = '127.0.0.1',
    port = 2333,
    password = 'youshallnotpass',
    identifier = 'mynode'
}

client:on('ready', function()
    Pool():create_node(client, node)
    print('Logged in as ' .. client.user.username)
end)

client:on('messageCreate', function(message)

    -- handle your commands here

    if command == 'join' then
        local player = Node:create_player(vc)

    elseif command == 'play' then
        local player = Node:get_player(guildid)
        local tracks = player:get_tracks(query)
        local track = tracks[1]
        player:play(track)

    elseif command == 'leave' then
        local player = Node:get_player(guildid)
        player:disconnect()
    end
end)

client:run('Bot <your token here>')

```
