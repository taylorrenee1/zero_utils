local emotes = zutils.bridge_loader("emote", "client")
if not emotes then return end

function zutils.emotes.start(data)
    if not data or not data.emoteName then return end
    local emote = emotes[data.emoteName]
    if emote and emote.start then
        emote.start(data)
    else
        printwarn("Emote not found: %s", tostring(data.emoteName))
    end
end

function zutils.emotes.cancel()
    local emote = emotes["cancel"]
    if emote and emote.cancel then
        emote.cancel()
    end
end



zutils.emotes = {}