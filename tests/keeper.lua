--
-- KEEPER.LUA
--
-- Test program for Lua Lanes
--

local lanes = require "lanes".configure{ with_timers = false, nb_keepers = 200}

do
    print "Linda names test:"
    local unnamedLinda = lanes.linda()
    local unnamedLinda2 = lanes.linda("")
    local veeeerrrryyyylooongNamedLinda= lanes.linda( "veeeerrrryyyylooongNamedLinda", 1)
    print(unnamedLinda, unnamedLinda2, veeeerrrryyyylooongNamedLinda)
end

local print_id = 0
local PRINT = function(...)
    print_id = print_id + 1
    print("main", print_id .. ".", ...)
end

local function keeper(linda)
    local mt= {
        __index= function( _, key )
            return linda:get( key )
        end,
        __newindex= function( _, key, val ) 
            linda:set( key, val )
        end
    }
    return setmetatable( {}, mt )
end

--
local lindaA= lanes.linda( "A", 1)
local A= keeper( lindaA )

local lindaB= lanes.linda( "B", 2)
local B= keeper( lindaB )

local lindaC= lanes.linda( "C", 3)
local C= keeper( lindaC )
print("Created", lindaA, lindaB, lindaC)

A.some= 1
PRINT("A.some == " .. A.some )
assert( A.some==1 )

B.some= "hoo"
PRINT("B.some == " .. B.some )
assert( B.some=="hoo" )
assert( A.some==1 )
assert( C.some==nil )

function lane()
    local print_id = 0
    local PRINT = function(...)
        print_id = print_id + 1
        print("lane", print_id .. ".", ...)
    end
    
    local a= keeper(lindaA)
    PRINT("a.some == " .. a.some )
    assert( a.some==1 )
    a.some= 2
    assert( a.some==2 )
    PRINT("a.some == " .. a.some )

    local c = keeper(lindaC)
    assert( c.some==nil )
    PRINT("c.some == " .. tostring(c.some))
    c.some= 3
    assert( c.some==3 )
    PRINT("c.some == " .. c.some)
end

PRINT("lane started")
local h= lanes.gen( "io", lane )()
PRINT("lane joined:", h:join())

PRINT("A.some = " .. A.some )
assert( A.some==2 )
PRINT("C.some = " .. C.some )
assert( C.some==3 )
lindaC:set("some")
assert( C.some==nil )
