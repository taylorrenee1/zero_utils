zutils.draw = {}
function zutils.draw.text3D(coords, text, options)
    options = options or {}
    local font = options.font or 0
    local color = options.color or { r = 255, g = 255, b = 255, a = 255 }
    local scale = options.scale or 0.3

    local drawing = {
        running = false
    }
    function drawing:draw()
        if self.running then
            return
        end
        self.running = true
        CreateThread(function()
            while self.running do
                Wait(0)
                local on_screen, _, _ = World3dToScreen2d(coords.x, coords.y, coords.z)
                if on_screen then
                    SetTextFont(font)
                    SetTextScale(scale, scale)
                    SetTextColour(color.r, color.g, color.b, color.a)
                    SetTextEntry("STRING")
                    SetTextCentre(true)
                    AddTextComponentString(text)
                    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
                    EndTextCommandDisplayText(0, 0)
                end
            end
        end)
    end

    function drawing:stop()
        self.running = false
    end

    function drawing:updateText(newText)
        text = newText
    end

    if options.distance then
        zutils.points.addPoint(coords.xyz, {
            distance = options.distance,
            onEnter = function()
                drawing:draw()
                if options.onEnter then
                    options.onEnter()
                end
            end,
            onExit = function()
                drawing:stop()
            end
        })
    else
        drawing:draw()
    end

    return drawing
end

return zutils.draw