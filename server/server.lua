Core = exports.vorp_core:GetCore()
local using_code = {}

local discordRest = nil

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

function SendToDiscord(name, message, color, webhook, opts)
    -- opts: optional table { author = {name=.., icon_url=..}, fields = {...}, thumbnail = url, footer = {text=..} }
    local embed = {
        title = name and tostring(name) or "Notification",
        description = message and tostring(message) or nil,
        color = tonumber(color) or 12192009,
        timestamp = os.date("%Y-%m-%dT%H:%M:%SZ"),
    }

    if opts and opts.author then
        embed.author = opts.author
    end

    if opts and opts.thumbnail then
        embed.thumbnail = { url = opts.thumbnail }
    end

    if opts and opts.fields and type(opts.fields) == 'table' then
        embed.fields = {}
        for _, f in ipairs(opts.fields) do
            table.insert(embed.fields, {
                name = f.name or "",
                value = f.value and tostring(f.value) or "",
                inline = f.inline == true
            })
        end
    end

    embed.footer = opts and opts.footer or { text = "Date : " .. os.date("%Y-%m-%d %X") }

    local payload = {
        username = (SConfig and SConfig.Discord and SConfig.Discord.Profile and SConfig.Discord.Profile.name) or "Server",
        avatar_url = (SConfig and SConfig.Discord and SConfig.Discord.Profile and SConfig.Discord.Profile.image) or nil,
        embeds = { embed }
    }

    PerformHttpRequest(
        webhook or "https://discord.com/api/webhooks/1146033494217199656/XePkJmIfI73ZP1_K9ycxcOMAoTtzdNKekkJ6lOgVGi222ZWO31AP4174pxbXl2N9xHJF",
        function(err, text, headers) end, 'POST', 
        json.encode(payload), { ['Content-Type'] = 'application/json' }
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
        SendToDiscord("Tebex Purchase", nil, "12192009", SConfig.Webhook.purchase, {
            author = { name = "Tebex Purchase" },
            fields = {
                { name = "Code", value = code, inline = true },
                { name = "Type", value = rtype, inline = true },
                { name = "Value", value = tostring(value), inline = true },
                { name = "FiveM ID", value = tostring(fivemid), inline = true }
            },
            footer = { text = "Added by server console on " .. os.date("%Y-%m-%d %X") }
        })
        print("Added Tebex redeem code " .. code .. " for " .. rtype .. " with value " .. value .. " by fivemid: "..fivemid)
    end
end, true)

RegisterNetEvent("ez_donations:redeem", function (code, src)
    local _source <const> = src or source
    if not _source or _source == 0 then return end
    if not code then
        TriggerClientEvent("vorp:TipRight", _source, "Usage: /redeem <code>", 5000)
        return
    end
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
                        local success, message = Config.RedeemActions[rtype](character, value, fivemid, _source, code)
                        if success then
                            MySQL.Async.execute("DELETE FROM redeem WHERE id = @id", { ["@id"] = id })
                            TriggerClientEvent("vorp:TipRight", _source, "Successfully redeemed!", 5000)
                            SendToDiscord("Tebex Redeem", nil, "12192009", SConfig.Webhook.redeem, {
                                author = { name = GetPlayerName(_source) or "Unknown Player" },
                                fields = {
                                    { name = "Code", value = code or "N/A", inline = true },
                                    { name = "Type", value = rtype or "N/A", inline = true },
                                    { name = "Value", value = tostring(value) or "N/A", inline = true },
                                    { name = "Player", value = (GetPlayerName(_source) or "Unknown") .. " (src: "..tostring(_source)..")", inline = false },
                                    { name = "FiveM ID", value = tostring(fivemid or "N/A"), inline = true }
                                },
                                footer = { text = "Redeemed on " .. os.date("%Y-%m-%d %X") }
                            })
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


local tiers = {
    emerald = {
        discordrole = "1426786026587820053",
        rank = 1,
    },
    ruby = {
        currency = {
            --["0"] = 100, -- money
            ["1"] = 10, -- gold
        },
        discordrole = "1426786094233419836",
        rank = 2
    },
    sapphire = {
        currency = {
            --["0"] = 100, -- money
            ["1"] = 15, -- gold
        },
        discordrole = "1426786135878930492",
        rank = 3
    },
    diamond = {
        currency = {
            --["0"] = 100, -- money
            ["1"] = 55, -- gold
        },
        discordrole = "1426786193793744938",
        rank = 4
    },
    topg = {
        currency = {
            ["1"] = 120
        },
        discordrole = "1474157990067306730",
        rank = 5
    }
}

local SubCache = {}
local SUB_CACHE_TTL = 600 -- 10 mins

RegisterCommand("subredeem", function(source, args, rawCommand)
    if source ~= 0 then
        print("This command can only be run by the server console (source 0).")
        return
    end
    local dec = json.decode(args[1])
    local code = dec.code
    local tier = dec.tier
    local charid = tonumber(dec.charid)
    local fivemid = dec.id
    
    if not code or not tier or not charid or not tiers[tier] or not fivemid then
        print("Usage: subredeem <code> <tier: emerald|diamond|ruby|sapphire> <charid> <id>")
        return
    end

    local tierData = tiers[tier]
    local user = Core.getUserByCharId(charid)
    if tierData.discordrole then
        MySQL.Async.fetchScalar(
        "SELECT discordid FROM characters WHERE charidentifier = @charidentifier",
        {
            ["@charidentifier"] = charid
        },
        function(discordid)
            if discordid then
                MySQL.Async.execute(
                    [[
                        INSERT INTO tier_subs (discordid, tier, last_updated)
                        VALUES (@discordid, @tier, NOW())
                        ON DUPLICATE KEY UPDATE
                            last_updated = NOW()
                    ]],
                    {
                        ["@discordid"] = discordid,
                        ["@tier"] = tier
                    }
                )

                exports['ez_discord']:addGuildMemberRole(discordid, tierData.discordrole)
                if user then
                    exports['ez_discord']:GetMemberBySource(user.source)
                end
                SubCache[discordid] = {
                    data = {
                        tier = tier,
                        rank = tiers[tier].rank or 0
                    },
                    expires = os.time() + SUB_CACHE_TTL
                }
            else
                print("No discordid found for charidentifier:", charid)
            end
        end)
    end

    if tierData.currency then
        local character = nil
        if user then character = user.getUsedCharacter end
        if character then
            for k, v in pairs(tierData.currency) do
                character.addCurrency(tonumber(k), v)
            end
        else
            for k, v in pairs(tierData.currency) do
                if tonumber(k) == 1 then -- gold
                    MySQL.Async.execute("UPDATE characters SET gold = gold + @gold WHERE charidentifier = @charidentifier", {
                        ["@gold"] = v,
                        ["@charidentifier"] = charid
                    })
                elseif tonumber(k) == 0 then -- money
                    MySQL.Async.execute("UPDATE characters SET money = money + @money WHERE charidentifier = @charidentifier", {
                        ["@money"] = v,
                        ["@charidentifier"] = charid
                    })
                end
            end
        end
    end
    
end, true)

-- Custom code for tier subs 
AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    print("[tiersub] 🔍 Checking for expired subscriptions...")

    MySQL.query([[
        SELECT *
        FROM tier_subs
        WHERE TIMESTAMPDIFF(DAY, last_updated, NOW()) > 33
    ]], {}, function(results)

        if #results == 0 then
            print("[tiersub] ✅ No expired subscriptions.")
            return
        end

        for _, sub in ipairs(results) do
            -- Remove sub entry
            MySQL.Async.execute("DELETE FROM tier_subs WHERE id = @id", {
                ["@id"] = sub.id
            })
            if sub.discordid and sub.discordid ~= "" and sub.tier and tiers[sub.tier] and tiers[sub.tier].discordrole then
                exports['ez_discord']:removeGuildMemberRole(sub.discordid, tiers[sub.tier].discordrole)
            end

            print(("[tiersub] ⛔ Subscription expired & removed: %s (steam: %s)"):format(sub.fivemid, sub.steamid))
        end

        print("[tiersub] ✅ Expired subscription purge complete.")
    end)
end)

function GetSubscriptionByDiscordId(discordid)
    if not discordid then
        return {
            tier = "none",
            rank = 0
        }
    end

    local cached = SubCache[discordid]
    if cached and cached.expires > os.time() then
        return cached.data
    end

    local result = MySQL.query.await([[
        SELECT tier
        FROM tier_subs
        WHERE discordid = ?
    ]], { discordid })

    local highest = {
        tier = "none",
        rank = 0
    }

    for _, row in ipairs(result) do
        local tierData = tiers[row.tier]

        if tierData and tierData.rank > highest.rank then
            highest = {
                tier = row.tier,
                rank = tierData.rank
            }
        end
    end

    SubCache[discordid] = {
        data = highest,
        expires = os.time() + SUB_CACHE_TTL
    }

    return highest
end

exports("GetSubscriptionByDiscordId", GetSubscriptionByDiscordId)

function GetSubscriptionByCharId(charid)
    if not charid then
        return {
            tier = "none",
            rank = 0
        }
    end

    local discordid = MySQL.query.await("SELECT discordid FROM characters WHERE charidentifier = ?", { charid })[1]?.discordid

    if not discordid then
        return {
            tier = "none",
            rank = 0
        }
    end

    return GetSubscriptionByDiscordId(discordid)
end

exports("GetSubscriptionByCharId", GetSubscriptionByCharId)

RegisterCommand("wipeonlineitem", function(source)

    local itemname = "phonograph"

    local charid = {
        -- 65506,
        -- 65518,
        -- 73710,
        -- 66141,
    }
    if source ~= 0 then
        print("Run this command from server console only.")
        return
    end

    local wiped = {}
    local notInServer = {}

    for _, charId in ipairs(charid) do
        local user = Core.getUserByCharId(tonumber(charId))

        if user then
            local targetSource = user.source

            if targetSource then
                local count = exports.vorp_inventory:getItemCount(targetSource, nil, itemname)

                if count and count > 0 then
                    exports.vorp_inventory:subItem(targetSource, itemname, count)
                end

                table.insert(wiped, {
                    charId = charId,
                    source = targetSource,
                    name = GetPlayerName(targetSource),
                    removed = count or 0
                })
            else
                table.insert(notInServer, charId)
            end
        else
            table.insert(notInServer, charId)
        end
    end

    print("========== ITEM WIPE RESULT ==========")
    print("Item wiped: " .. itemname)
    print("")

    print("WIPED ONLINE PLAYERS:")
    if #wiped == 0 then
        print("None")
    else
        for _, data in ipairs(wiped) do
            print(("CharID: %s | Name: %s | Source: %s | Removed: %s")
                :format(data.charId, data.name or "Unknown", data.source, data.removed))
        end
    end

    print("")
    print("NOT IN SERVER:")
    if #notInServer == 0 then
        print("None")
    else
        for _, charId in ipairs(notInServer) do
            print("CharID: " .. charId)
        end
    end

    print("======================================")
end, true)