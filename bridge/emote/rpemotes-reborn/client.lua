local emote = {}

function emote.start(data)
    exports["rpemotes-reborn"]:EmoteCommandStart(data.emoteName, data.textureVariation or 0)
end

function emote.cancel()
    exports["rpemotes-reborn"]:EmoteCancel()
end

return emote