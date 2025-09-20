local emote = {}

function emote.start(data)
  exports.scully_emotemenu:playEmoteByCommand(data.emoteName)
end

function emote.cancel()
    exports.scully_emotemenu:cancelEmote()
end


return emote