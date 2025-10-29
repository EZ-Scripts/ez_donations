Config = {}
Config.Command = "redeem"
Config.RedeemActions = {
    test = function(character, value, fivemid, src)
        SendToDiscord("Tebex Redeem", "Test redeem action executed for data...\nCharacter ID: " .. (character and character.charIdentifier or "") .. "\nValue: " .. (value or "") .. "\nFiveM ID: " .. (fivemid or ""), "12192009", "https://discord.com/api/webhooks/1432583516024995981/lHSjCy4ZbyfMmUbgLQ7ds9uIQb9jKsVsXrEyfrHAEQxOoH5RE-cX3nM6mllTu3hji9gF")
        return true, "Test redeem action executed."
    end,
    tier_subs = function(character, value, fivemid, src)
        local defaultCharLimit = 3
        local tiers = {
            ruby = { gold = 10 },
            sapphire = { charlimit = 4, gold = 25 },
            emerald = {  },
            diamond = { charlimit = 5, gold = 80 }
        }

        -- Validate input
        if not value or (value ~= "remove" and not tiers[value]) then
            print("[tiersub] ❌ Invalid tier value:", value)
            return false, "Invalid tier type."
        end
        local isRemove = (value == "remove")
        local tierData = isRemove and {} or tiers[value]

        if not fivemid then
            print("[tiersub] ❌ Missing FiveM ID.")
            return false, "Missing fivemid."
        end

        -- DB Remove
        local function removeSub(steamid, fivemid)
            MySQL.Async.execute("DELETE FROM tier_subs WHERE fivemid = @fivemid", {
                ["@fivemid"] = fivemid
            })
            MySQL.Async.execute("UPDATE users SET char = @char WHERE identifier = @steamid", {
                ["@char"] = defaultCharLimit,
                ["@steamid"] = steamid
            })
            print("[tiersub] 🗑 Removed subscription for:", fivemid)
            return true, "Subscription removed successfully."
        end

        -- DB operation for offline renewal/removal
        local function applyOffline(result, tierData, isRemove)
            if isRemove then return removeSub(result.steamid, result.fivemid) else
                MySQL.Async.execute([[
                    INSERT INTO tier_subs (fivemid, steamid, tier, charidentifier)
                    VALUES (@fivemid, @steamid, @tier, @charidentifier)
                    ON DUPLICATE KEY UPDATE 
                        tier = VALUES(tier),
                        last_updated = CURRENT_TIMESTAMP
                ]], {
                    ["@fivemid"] = result.fivemid,
                    ["@steamid"] = result.steamid,
                    ["@tier"] = value,
                    ["@charidentifier"] = result.charidentifier
                })

                if tierData.charlimit and tierData.charlimit > defaultCharLimit then
                    MySQL.Async.execute("UPDATE users SET char = @char WHERE identifier = @steamid", {
                        ["@char"] = tierData.charlimit,
                        ["@steamid"] = result.steamid
                    })
                end
                if tierData.gold and tierData.gold > 0 then
                    local user = Core.getUserByCharId(result.charidentifier)
                    if user then character = user.getUsedCharacter end
                    if character and character.charidentifier == result.charidentifier then
                        character.addCurrency(1, tierData.gold)
                    else
                        MySQL.Async.execute("UPDATE characters SET gold = gold + @gold WHERE charidentifier = @charidentifier", {
                            ["@gold"] = tierData.gold,
                            ["@charidentifier"] = result.charidentifier
                        })
                    end
                end
                print("[tiersub] 🔁 Offline renewal applied for:", fivemid)
            end
        end

        -- Handle offline renewals/removals (no src)
        if not src or src == 0 then
            MySQL.query("SELECT * FROM tier_subs WHERE fivemid = @fivemid", {
                ["@fivemid"] = fivemid
            }, function(result)
                if #result > 0 then
                    applyOffline(result[1], tierData, isRemove)
                else
                    print("[tiersub] ⚠ No record found for renewal/removal:", fivemid)
                end
            end)
            return true, "Subscription updated (offline)."
        end

        -- Online player handling
        local steamid = GetPlayerIdentifierByType(src, "steam")
        local fivemid_player = GetPlayerIdentifierByType(src, "fivem")

        if not (fivemid_player and fivemid_player == "fivem:" .. fivemid) then
            print("[tiersub] ⚠ FiveM ID mismatch for src:", src)
            return false, "CFX ID mismatch. Please sign in or use the same cfx account used to purchase."
        end

        if not character then
            print("[tiersub] ❌ Character data not found for src:", src)
            return false, "Character data not found."
        end

        -- Apply for online players
        if isRemove then return removeSub(steamid, fivemid) else
            -- Create or update sub record
            MySQL.Async.execute([[
                INSERT INTO tier_subs (fivemid, steamid, tier, charidentifier)
                VALUES (@fivemid, @steamid, @tier, @charidentifier)
                ON DUPLICATE KEY UPDATE 
                    tier = VALUES(tier),
                    last_updated = CURRENT_TIMESTAMP
            ]], {
                ["@fivemid"] = fivemid,
                ["@steamid"] = steamid,
                ["@tier"] = value,
                ["@charidentifier"] = character.charidentifier
            })

            if tierData.charlimit then
                MySQL.Async.execute("UPDATE users SET char = @char WHERE identifier = @steamid", {
                    ["@char"] = tierData.charlimit,
                    ["@steamid"] = steamid
                })
            end
            if tierData.gold then
                character.addCurrency(1, tierData.gold)
            end

            print(("[tiersub] 💎 Applied %s tier to %s (added %d gold, char limit %d)"):format(
                value, fivemid, tierData.gold or 0, tierData.charlimit or defaultCharLimit
            ))

            return true, ("Redeemed %s tier successfully!"):format(value)
        end
    end,
    gold = function(character, value, fivemid, src)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        value = tonumber(value) or 0
        character.addCurrency(1, value)
        print("Added " .. value .. " gold to character ID " .. character.charIdentifier)
        return true, "Added " .. value .. " gold to character ID " .. character.charIdentifier
    end,
    reborn = function(character, value, fivemid, src)
        value = tonumber(value) or 0
        if not src then
            print("Error: src is nil")
            return false, "source is nil. Contact server admin."
        end
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        exports.vorp_inventory:addItem(src, "reborntoken", value or 1)
        print("Added reborn token to character ID " .. character.charIdentifier)
        return true, "Added reborn token to character ID " .. character.charIdentifier
    end,
    namechange = function(character, value, fivemid, src)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        -- Split the value into first and last name
        local names = {}
        for word in string.gmatch(value, "%S+") do
            table.insert(names, word)
        end
        local firstName = names[1] or ""
        local lastName = names[2] or ""
        if string.match(firstName, "^[a-zA-Z]+$") and string.match(lastName, "^[a-zA-Z]+$") and #firstName >= 3 and #lastName >= 3 then
            character.setFirstname(firstName)
            character.setLastname(lastName)
        else
            print("Error: Invalid name format")
            return false, "Invalid name format. Contact server admin."
        end
        print("Changed name to " .. firstName .. " " .. lastName .. " for character ID " .. character.charIdentifier)
        return true, "Changed name to " .. firstName .. " " .. lastName .. " for character ID " .. character.charIdentifier
    end,
    addchar = function(character, value, fivemid, src)
        local max_chars = 5 -- Change this to your desired max characters
        local value = tonumber(value) or 1
        MySQL.query("SELECT char FROM users WHERE identifier = @identifier", {
            ["@identifier"] = character.identifier
        }, function(result)
            if #result > 0 then
                local row = result[1]
                if row.char > max_chars + value then
                    print("Error: Maximum character limit reached")
                    return false, "Maximum character limit reached. Contact server admin."
                end
                row.char = row.char + value
                MySQL.update("UPDATE users SET char = @char WHERE identifier = @identifier", {
                    ["@char"] = row.char,
                    ["@identifier"] = character.identifier
                }, function(rowsUpdated)
                    if rowsUpdated > 0 then
                        print("Added character slot for " .. character.identifier)
                        return true, "Added character slot for " .. character.identifier
                    else
                        print("Error: Failed to update character slot")
                        return false, "Failed to update character slot. Contact server admin."
                    end
                end)
            end
        end)
        return false, "Character slot addition not processed. Contact server admin."
    end,
}