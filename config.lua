Config = {}
Config.Command = "redeem"
Config.GuildId = "1244743098303512618"
Config.RedeemActions = {
    test = function(character, value, fivemid, src)
        SendToDiscord("Tebex Redeem", "Test redeem action executed for data...\nCharacter ID: " .. (character and character.charIdentifier or "") .. "\nValue: " .. (value or "") .. "\nFiveM ID: " .. (fivemid or ""), "12192009", "https://discord.com/api/webhooks/1432583516024995981/lHSjCy4ZbyfMmUbgLQ7ds9uIQb9jKsVsXrEyfrHAEQxOoH5RE-cX3nM6mllTu3hji9gF")
        return true, "Test redeem action executed."
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
    pedscale = function(character, value, fivemid, src)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        if not src then
            print("Error: src is nil")
            return false, "source is nil. Contact server admin."
        end
        value = tonumber(value) or 1
        local skin = character.skin
        skin = json.decode(skin)
        skin.Scale = value
        skin = json.encode(skin)
        character.updateSkin(skin)
        TriggerClientEvent("vorpcharacter:updateCache", src, skin, nil)
        print("Set ped scale to " .. value .. " for character ID " .. character.charIdentifier)
        return true, "Set ped scale to " .. value .. " for character ID " .. character.charIdentifier
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
    vpnaccess = function(character, value, fivemid, src)
        MySQL.Async.execute([[
            INSERT IGNORE INTO vpn_access (fivemid)
            VALUES (@fivemid)
        ]], {
            ["@fivemid"] = fivemid
        })
        return true, "VPN access granted for FiveM ID " .. fivemid
    end,
}