local emote = {}

function EmoteStart(data)
    TriggerEvent('animations:client:EmoteCommandStart', {data.emoteName})
end

function emote.cancel()
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
end

return emote