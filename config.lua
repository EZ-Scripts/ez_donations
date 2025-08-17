Config = {}
Config.Command = "redeem"
Config.RedeemActions = {
    supporter = function(character, value, fivemid, src)
        value = tonumber(value) or 0
        if src == nil or src == 0 or character == nil then
            MySQL.query("SELECT * FROM supporter WHERE fivemid = @fivemid", {
                ["@fivemid"] = fivemid
            }, function(result)
                if #result > 0 then
                    local row = result[1]
                    local steamid = row.steamid
                    if value == 0 then
                        MySQL.Async.execute("DELETE FROM supporter WHERE fivemid = @fivemid", {
                            ["@fivemid"] = fivemid
                        }, function(rowsDeleted)
                        end)
                    else
                        MySQL.Async.execute("UPDATE supporter SET supporter = @supporter WHERE fivemid = @fivemid", {
                            ["@supporter"] = value,
                            ["@fivemid"] = fivemid
                        }, function(rowsUpdated)
                        end)
                    end
                    MySQL.Async.execute("UPDATE characters SET supporter = @supporter WHERE identifier = @steamid", {
                        ["@supporter"] = value,
                        ["@steamid"] = steamid
                    }, function(rowsUpdated)
                    end)
                end
            end)
        else
            if not src then
                print("Error: src is nil")
                return false, "source is nil. Contact server admin."
            end
            local steamid = GetPlayerIdentifierByType(src, 'steam')
            local fivemid_player = GetPlayerIdentifierByType(src, 'fivem')
            if not(fivemid_player and fivemid_player == "fivem:"..fivemid) then
                print("Warning: fivemid " .. fivemid .. " does not match the player's fivem identifier.")
                return false, "fivemid does not match account used to purchase item."
            end
            MySQL.Async.fetchScalar("SELECT COUNT(*) FROM supporter WHERE fivemid = @fivemid", {
                ["@fivemid"] = fivemid
            }, function(exists)
                if exists and exists > 0 then
                    MySQL.Async.execute("UPDATE supporter SET supporter = @supporter WHERE fivemid = @fivemid", {
                        ["@supporter"] = value,
                        ["@fivemid"] = fivemid
                    }, function(rowsUpdated)
                    end)
                else
                    MySQL.Async.execute("INSERT INTO supporter (fivemid, steamid, supporter) VALUES (@fivemid, @steamid, @supporter)", {
                        ["@fivemid"] = fivemid,
                        ["@steamid"] = steamid,
                        ["@supporter"] = value
                    }, function(rowsInserted)
                    end)
                end
                MySQL.Async.execute("UPDATE characters SET supporter = @supporter WHERE identifier = @steamid", {
                    ["@supporter"] = value,
                    ["@steamid"] = steamid
                }, function(rowsUpdated)
                end)
            end)
        end
        return true, "Added supporter status"
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