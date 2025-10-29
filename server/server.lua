Core = exports.vorp_core:GetCore()
local using_code = {}

-- Create the redeem table in the database if it doesn't exist
CreateThread(function()
    MySQL.ready(function()
        MySQL.Async.execute([[CREATE TABLE IF NOT EXISTS `redeem` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `code` VARCHAR(255) NOT NULL COLLATE 'utf8mb3_general_ci',
            `type` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
            `value` TEXT NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
            `fivemid` INT(11) NULL DEFAULT NULL,
            PRIMARY KEY (`id`) USING BTREE
        )]])
    end)
end)

function SendToDiscord(name, message, color, webhook)
    local connect = {
        {
            ["color"] = color or "12192009",
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Date : " .. os.date("%Y-%m-%d %X"),
            },
        },
    }
    PerformHttpRequest(
        webhook or "https://discord.com/api/webhooks/1146033494217199656/XePkJmIfI73ZP1_K9ycxcOMAoTtzdNKekkJ6lOgVGi222ZWO31AP4174pxbXl2N9xHJF",
        function(err, text, headers) end, 'POST', 
        json.encode({
            username = SConfig.Discord.Profile.name, 
            embeds = connect, 
            avatar_url = SConfig.Discord.Profile.image
        }), { ['Content-Type'] = 'application/json' }
    )
end

-- Command to add a Tebex transaction to the redeem table
RegisterCommand("tebexredeem", function(source, args, rawCommand)
    if source ~= 0 then
        print("This command can only be run by the server console (source 0).")
        return
    end
    local dec = json.decode(args[1])
    local code = dec.code
    local rtype = dec.type
    local value = dec.value
    local fivemid = dec.id
    local quantity = 1 --tonumber(dec.quantity)
    local autoredeem = dec.autoredeem
    
    if not code or not rtype or not value or not Config.RedeemActions[rtype] or not fivemid then
        print("Usage: tebexredeem <code> <type: supporter|gold> <value> <id>")
        return
    end

    if quantity and tonumber(value) then 
        if quantity > 1 then
            value = tonumber(value) * quantity
        end
    end

    if autoredeem and autoredeem == "true" then
        if Config.RedeemActions[rtype] then
            local success, message = Config.RedeemActions[rtype](nil, value, fivemid, nil)
            if success then
                print("Successfully autoredeemed!")
            else
                print("Error: "..message)
            end
        else
            print("Error: Invalid redeem type. Contact server admin.")
        end
    else
        MySQL.Async.execute("INSERT INTO redeem (code, type, value, fivemid) VALUES (@code, @type, @value, @fivemid)", {
            ["@code"] = code,
            ["@type"] = rtype,
            ["@value"] = value,
            ["@fivemid"] = fivemid
        })
        SendToDiscord("Tebex Purchase", "Added Tebex redeem code " .. code .. " for " .. rtype .. " with value " .. value .. " by fivemid: "..fivemid, "12192009", SConfig.Webhook.purchase)
        print("Added Tebex redeem code " .. code .. " for " .. rtype .. " with value " .. value .. " by fivemid: "..fivemid)
    end
end, true)

RegisterNetEvent("ez_donations:redeem", function (code, src)
    local _source <const> = src or source
    if not _source or _source == 0 then return end
    local User = Core.getUser(_source)
    if not User then
        TriggerClientEvent("vorp:TipRight", _source, "Error retrieving user data.", 5000)
        return
    end
    local character = User.getUsedCharacter
    if not character then
        TriggerClientEvent("vorp:TipRight", _source, "Error retrieving character data.", 5000)
        return
    end
    if not using_code[_source] then
        using_code[code] = true
        MySQL.Async.fetchAll("SELECT * FROM redeem WHERE code = @code", { ["@code"] = code }, function(result)
            if #result > 0 then
                for _, row in pairs(result) do
                    local rtype = row.type
                    local value = row.value
                    local fivemid = row.fivemid
                    local id = row.id
                    
                    if Config.RedeemActions[rtype] then
                        local success, message = Config.RedeemActions[rtype](character, value, fivemid, _source)
                        if success then
                            MySQL.Async.execute("DELETE FROM redeem WHERE id = @id", { ["@id"] = id })
                            TriggerClientEvent("vorp:TipRight", _source, "Successfully redeemed!", 5000)
                            SendToDiscord("Tebex Redeem", "Redeemed Tebex code " .. code .. " for " .. rtype .. " with value " .. value, "12192009", SConfig.Webhook.redeem)
                        else
                            TriggerClientEvent("vorp:TipRight", _source, "Error: "..message, 5000)
                        end
                    else
                        TriggerClientEvent("vorp:TipRight", _source, "Error: Invalid redeem type. Contact server admin.", 5000)
                    end
                end
            else
                TriggerClientEvent("vorp:TipRight", _source, "Error: Invalid or already used code.", 5000)
            end
        end)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Error: Already used.", 5000)
    end
end)

-- Command for players to redeem their Tebex codes
if Config.Command then
    RegisterCommand(Config.Command, function(source, args, rawCommand)
        local code = args[1]
        if not code then
            TriggerClientEvent("vorp:TipRight", source, "Usage: "..Config.Command.." <code>", 5000)
            return
        end
        TriggerEvent("ez_donations:redeem", code, source)
    end, false)
end


-- Custom code for tier subs 
AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    local defaultCharLimit = 3

    print("[tiersub] 🔍 Checking for expired subscriptions...")

    MySQL.query([[
        SELECT fivemid, steamid, charidentifier
        FROM tier_subs
        WHERE TIMESTAMPDIFF(DAY, last_updated, NOW()) > 30
    ]], {}, function(results)

        if #results == 0 then
            print("[tiersub] ✅ No expired subscriptions.")
            return
        end

        for _, sub in ipairs(results) do
            -- Remove sub entry
            MySQL.Async.execute("DELETE FROM tier_subs WHERE fivemid = @fivemid", {
                ["@fivemid"] = sub.fivemid
            })

            -- Restore default character limit
            MySQL.Async.execute("UPDATE users SET char = @char WHERE identifier = @steamid", {
                ["@char"] = defaultCharLimit,
                ["@steamid"] = sub.steamid
            })

            print(("[tiersub] ⛔ Subscription expired & removed: %s (steam: %s)"):format(sub.fivemid, sub.steamid))
        end

        print("[tiersub] ✅ Expired subscription purge complete.")
    end)
end)
