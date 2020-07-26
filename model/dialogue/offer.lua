local NilDialogue = require('model/dialogue/nil')
local NilMenu = require('model/menu/nil')
local AddTradeItem = require('model/interaction/addtradeitem')
local FinishTrade = require('model/interaction/finishtrade')
local OfferTrade = require('model/interaction/offertrade')
local NilInteraction = require('model/interaction/nil')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local OfferDialogue = NilDialogue:NilDialogue()
OfferDialogue.__index = OfferDialogue

--------------------------------------------------------------------------------
function OfferDialogue:OfferDialogue(target, player, items)
    local o = NilDialogue:NilDialogue()
    setmetatable(o, self)
    o._target = target
    o._player = player
    o._type = 'OfferDialogue'
    o._menu = NilMenu:NilMenu()
    o._interactions = {}
    o._idx = 1

    o._end = NilInteraction:NilInteraction()
    o._end:SetSuccessCallback(function() o._on_success() end)
    o._end:SetFailureCallback(function() o._on_success() end)

    setmetatable(o._interactions, { __index = function() return o._end end })

    o:_AppendInteraction(NilInteraction:NilInteraction())
    o:_AppendInteraction(OfferTrade:OfferTrade(o._target:Id()))
    for slot, data in pairs(items) do
        o:_AppendInteraction(AddTradeItem:AddTradeItem(data.item.id, data.count, slot))
    end
    o:_AppendInteraction(FinishTrade:FinishTrade(o._target:Id()))

    return o
end

--------------------------------------------------------------------------------
function OfferDialogue:OnIncomingData(id, pkt)
    return (self._interactions[self._idx]:OnIncomingData(id, pkt))
end

--------------------------------------------------------------------------------
function OfferDialogue:OnOutgoingData(id, pkt)
    return self._interactions[self._idx]:OnOutgoingData(id, pkt)
end

--------------------------------------------------------------------------------
function OfferDialogue:Start()
    log('Offering Trade')
    self:_OnSuccess()
end

--------------------------------------------------------------------------------
function OfferDialogue:_AppendInteraction(interaction)
    interaction:SetSuccessCallback(function() self:_OnSuccess() end)
    interaction:SetFailureCallback(function() self._on_failure() end)
    table.insert(self._interactions, interaction)
end

--------------------------------------------------------------------------------
function OfferDialogue:_OnSuccess()
    self._idx = self._idx + 1
    local option = self._menu:OptionFor()
    local menu_id = self._menu:Id()
    local next = self._interactions[self._idx]

    local data = { target = self._target, menu = menu_id, choice = option.option,
                   automated = option.automated, uk1 = option.uk1, player = self._player }
    next(data)
end

return OfferDialogue