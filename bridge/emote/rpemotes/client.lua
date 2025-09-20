local emote = {}

function emote.start(data)
    exports["rpemotes"]:EmoteCommandStart(data.emoteName, data.textureVariation or 0)
end

function emote.cancel()
    exports["rpemotes"]:EmoteCancel()
end

return emote