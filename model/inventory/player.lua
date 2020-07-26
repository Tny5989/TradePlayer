local NilInventory = require('model/inventory/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local PlayerInventory = NilInventory:NilInventory()
PlayerInventory.__index = PlayerInventory

--------------------------------------------------------------------------------
function PlayerInventory:PlayerInventory(items)
    local o = NilInventory:NilInventory()
    setmetatable(o, self)
    o._items = items
    return o
end

--------------------------------------------------------------------------------
function PlayerInventory:FreeSlots()
    return self._items.max - self._items.count
end

--------------------------------------------------------------------------------
function PlayerInventory:ItemCount(id)
    local count = 0
    for _, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id then
            count = count + value.count
        end
    end
    return count
end

--------------------------------------------------------------------------------
function PlayerInventory:ItemIndex(id, mincount, excluded_slots)
    mincount = mincount and mincount or 1
    excluded_slots = excluded_slots and excluded_slots or {}
    for key, value in pairs(self._items) do
        if type(value) == 'table' and value.id == id and not excluded_slots[key] and value.count >= mincount then
            return key
        end
    end
    return NilInventory.ItemIndex(self, id)
end

--------------------------------------------------------------------------------
function PlayerInventory:Type()
    return 'PlayerInventory'
end

return PlayerInventory
