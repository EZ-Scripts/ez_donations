RegisterNetEvent("ez_donations:inputRedeem", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "show" })
end)

RegisterNUICallback('redeemCode', function(data, cb)
    local code = data.code
    if code and code ~= "" then
        TriggerServerEvent("ez_donations:redeem", code)
    end
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('cancel', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('playSound', function(data, cb)
    local sound    = data.sound    or "SELECT"
    local soundset = data.soundset or "HUD_SHOP_SOUNDSET"
    PlaySoundFrontend(-1, sound, soundset, true)
    cb({})
end)

if Config.Command then
    TriggerEvent("chat:addSuggestion", "/" .. Config.Command, "Redeem a Tebex code", {
    })
    RegisterCommand(Config.Command, function(source, args, rawCommand)
        TriggerEvent("ez_donations:inputRedeem")
    end, false)
end

RegisterCommand("mycharid", function(source, args, rawCommand)
    local cid = LocalPlayer.state.Character.CharId
    if cid then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"Your Character ID is: " .. cid}
        })
        TriggerEvent("vorp:TipRight", "Your Character ID is: " .. cid, 10000)
    end
end, false)

TriggerEvent("chat:addSuggestion", "/mycharid", "Show your character ID", {})
