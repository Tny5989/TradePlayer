local OfferDialogue = require('model/dialogue/offer')
local NilDialogue = require('model/dialogue/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local DialogueFactory = {}

--------------------------------------------------------------------------------
function DialogueFactory.CreateOfferDialogue(npc, player, items)
    if not npc or npc:Type() == 'NilEntity' then
        log('Unable to find npc')
        return NilDialogue:NilDialogue()
    end

    if not player or player:Type() == 'NilEntity' then
        log('Unable to find player')
        return NilDialogue:NilDialogue()
    end

    if npc:Distance() > settings.config.maxdistance then
        log('Player too far away')
        return NilDialogue:NilDialogue()
    end

    if not items or items == {} then
        log('No items being traded')
        return NilDialogue:NilDialogue()
    end

    if player:Bag():FreeSlots() < 1 then
        log('Inventory full')
        return NilDialogue:NilDialogue()
    end

    local slots = {}
    for _, data in pairs(items) do
        local c = tonumber(data.count)
        local item = data.item
        if player:Bag():ItemCount(tonumber(item.id)) < c then
            log('Not enough items('..data.item.en..')')
            return NilDialogue:NilDialogue()
        end

        local stack_size = tonumber(item.stack)
        while c > stack_size do
            table.insert(slots, { count = stack_size, item = item })
            c = c - stack_size
        end
        if c > 0 then
            table.insert(slots, { count = c, item = item })
        end
    end

    if #slots > 8 then
        log('Attempting to trade too many items')
        return NilDialogue:NilDialogue()
    end

    return OfferDialogue:OfferDialogue(npc, player, items)
end

return DialogueFactory
