local discordia = require('discordia')
local class = discordia.class

local Node = require('node')
local Pool, get = class('Pool')
local dump = require('utils').dump
local random_value = require('utils').random_value

local format = string.format


function Pool:__init()
    self._nodes = {}
end

function Pool:create_node(client, options)
    assert(options.identifier, 'Node identifier was not provided.')
    if self._nodes[options.identifier] then
        return false,
            format('Already have node with identifier %s', options.identifier)
    end

    options.pool = self
    local id = options.identifier
    self._nodes[id] = Node(client, options)
end

function Pool:get_node(identifier)
    if self._nodes[identifier] then
        return self._nodes[identifier]
    else
        print("getting random node")
        local node = random_value(self._nodes)
        print(node)
    end
end

function Pool:disconnect()
    for id, node in pairs(self._nodes) do
        node.disconnect()
    end
end

return Pool
