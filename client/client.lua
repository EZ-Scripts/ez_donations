RegisterNetEvent("ez_donations:inputRedeem", function()
    --[[local myInput = {
        type = "enableinput", -- dont touch
        inputType = "input", -- or text area for sending messages
        button = "Redeem", -- button name
        placeholder = "tbx-xxxxxxxxxx-xxxxx", --placeholdername
        style = "block", --- dont touch
        attributes = {
            inputHeader = "code", -- header
            type = "text",
            title = "Tebex transaction id",
            style = "border-radius: 10px; background-color: ; border:none;", -- style  the inptup
        }
    }
    TriggerEvent("vorpinputs:advancedInput", json.encode(myInput),function(result)
        if result then
            TriggerServerEvent("ez_donations:redeem", result)
        end
    end)]]

    local inputData = {
        title = "Redeem Tebex Code",
        desc = "Please enter your Tebex transaction ID to redeem your purchase.",
        buttonparam1 = "ACCEPT",
        buttonparam2 = "DECLINE"
    }

    TriggerEvent("tp_inputs:getTextInput", inputData, function(cb)
        if cb == "DECLINE" or cb == "" then
            return
        end
        TriggerServerEvent("ez_donations:redeem", cb)
    end) 
end)

if Config.Command then
TriggerEvent("chat:addSuggestion", "/".. Config.Command, "Redeem a Tebex code", {
    { name = "code", help = "Tebex transaction id" }
})
end