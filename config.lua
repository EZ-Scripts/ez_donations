Config = {}
Config.Command = "redeem"
Config.GuildId = "1244743098303512618"
Config.RedeemActions = {
    test = function(character, value, fivemid, src, code)
        SendToDiscord("Tebex Redeem", "Test redeem action executed for data...\nCharacter ID: " .. (character and character.charIdentifier or "") .. "\nValue: " .. (value or "") .. "\nFiveM ID: " .. (fivemid or ""), "12192009", "https://discord.com/api/webhooks/1432583516024995981/lHSjCy4ZbyfMmUbgLQ7ds9uIQb9jKsVsXrEyfrHAEQxOoH5RE-cX3nM6mllTu3hji9gF")
        return true, "Test redeem action executed."
    end,
    gold = function(character, value, fivemid, src, code)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        value = tonumber(value) or 0
        character.addCurrency(1, value)
        print("Added " .. value .. " gold to character ID " .. character.charIdentifier)
        return true, "Added " .. value .. " gold to character ID " .. character.charIdentifier
    end,
    cash = function(character, value, fivemid, src, code)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        value = tonumber(value) or 0
        character.addCurrency(0, value)
        print("Added " .. value .. " cash to character ID " .. character.charIdentifier)
        return true, "Added " .. value .. " cash to character ID " .. character.charIdentifier
    end,
    bundle = function(character, value, fivemid, src, code)
        local bundles = {
            ["longhorn"] = {
                items = {
                    { item = "WEAPON_REPEATER_WINCHESTER", amount = 1},
                    { item = "WEAPON_REVOLVER_NAVY", amount = 2},
                    { item = "stim", amount = 5},
                    { item = "p_bag_voodoo01x", amount = 1},
                    { item = "consumable_bundle_caviar", amount = 10},
                    { item = "consumable_bundle_whitechampagne", amount = 10},
                    { item = "cigar_bundle_goldmoney", amount = 10},
                },
                currency = {
                    ["0"] = 2500,
                },
            },
            ["outlaw"] = {
                items = {
                    { item = "WEAPON_RIFLE_BOLTACTION", amount = 1},
                    { item = "consumable_bundle_caviar", amount = 25},
                    { item = "consumable_bundle_whitechampagne", amount = 25},
                },
                currency = {
                    ["0"] = 6000,
                    ["1"] = 25
                },
                inventoryincrease = 50
            },
            ["gunslinger"] = {
                items = {
                    { item = "WEAPON_PISTOL_M1899", amount = 2},
                    { item = "consumable_bundle_caviar", amount = 50},
                    { item = "consumable_bundle_whitechampagne", amount = 50},
                    { item = "cigar_bundle_goldmoney", amount = 25},
                    { item = "medical_gold_bandage", amount = 25},
                },
                currency = {
                    ["0"] = 20000,
                    ["1"] = 150
                },
                wagon = {
                    model = "wagonarmoured01x",
                    name = "Armored Wagon"
                }
            },
            ["seasonal"] = {
                items = {
                },
                currency = {
                    ["0"] = 0,
                    ["1"] = 0
                },
            },
        }

        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end

        local bundle = bundles[value]
        if not bundle then
            return false, "Invalid bundle selected."
        end

        -- Give items
        local VORPInv = exports.vorp_inventory
        for _, itemData in ipairs(bundle.items) do
            if string.sub(itemData.item, 1, string.len("WEAPON_")) == "WEAPON_" then
                local canCarry = VORPInv:canCarryWeapons(src, itemData.amount, nil, itemData.item)
                if not canCarry then
                    return false, "You cannot carry all the weapons in this bundle."
                end
            else
                local itemCheck = VORPInv:getItemDB(itemData.item)
                local canCarry = VORPInv:canCarryItems(src, itemData.amount)       --can carry inv space
                local canCarry2 = VORPInv:canCarryItem(src, itemData.item, itemData.amount) --cancarry item limit

                if not itemCheck or not canCarry or not canCarry2 then
                    return false, "You cannot carry all the items in this bundle."
                end
            end
        end
        for _, itemData in ipairs(bundle.items) do
            if string.sub(itemData.item, 1, string.len("WEAPON_")) == "WEAPON_" then
                for i=1, itemData.amount do
                    local sa = character.charIdentifier .. "-" .. itemData.item .. "-" .. i .. "-" .. code
                    VORPInv:createWeapon(src, itemData.item, {}, {}, {}, function(success)
                    end, sa)
                end
            else
                VORPInv:addItem(src, itemData.item, itemData.amount, itemData.metadata)
            end
        end

        -- Give currency
        for currencyId, amount in pairs(bundle.currency) do
            character.addCurrency(tonumber(currencyId) or 0, amount)
        end

        -- Give inventory increase (if applicable)
        if bundle.inventoryincrease then
            character.updateInvCapacity(bundle.inventoryincrease)
        end

        if bundle.wagon then
            TriggerEvent('kd_stable:server:AddNewWagon', src, "blackwater", bundle.wagon.model, bundle.wagon.name)
        end

        return true, "Bundle redeemed successfully."
    end,
    addphonograph = function(character, value, fivemid, src, code)
        local itemName = "phonograph"
        local VORPInv = exports.vorp_inventory
        local itemCheck = VORPInv:getItemDB(itemName)
        local canCarry = VORPInv:canCarryItems(src, tonumber(value) or 1)       --can carry inv space
        local canCarry2 = VORPInv:canCarryItem(src, itemName, tonumber(value) or 1) --cancarry item limit

        if not itemCheck or not canCarry or not canCarry2 then
            return false, "You cannot carry all the items in this bundle."
        end

        VORPInv:addItem(src, itemName, tonumber(value) or 1, nil)
    end,
    inventoryincrease = function(character, value, fivemid, src, code)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        if not src then
            print("Error: src is nil")
            return false, "source is nil. Contact server admin."
        end
        value = tonumber(value) or 1
        character.updateInvCapacity(value)
        print("Increased inventory capacity by " .. value .. " for character ID " .. character.charIdentifier)
        return true, "Increased inventory capacity by " .. value .. " for character ID " .. character.charIdentifier
    end,
    charslot = function(character, value, fivemid, src, code)
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        value = tonumber(value) or 0
        local user = Core.getUser(src)
        if not user then
            print("Error: user is nil")
            return false, "User is nil. Contact server admin."
        end
        local charNum = user.getCharperm
        if charNum + 1 > 5 then return false, "You cannot have more than 5 character slots" end
        user.setCharperm(charNum + 1)
        print("Set character slot to " .. (charNum + 1) .. " for user ID " .. src)
        return true, "Set character slot to " .. (charNum + 1) .. " for user ID " .. src
    end,
    pedscale = function(character, value, fivemid, src, code)
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
    reborn = function(character, value, fivemid, src, code)
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
    namechange = function(character, value, fivemid, src, code)
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
    addchar = function(character, value, fivemid, src, code)
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
    vpnaccess = function(character, value, fivemid, src, code)
        MySQL.Async.execute([[
            INSERT IGNORE INTO vpn_access (fivemid)
            VALUES (@fivemid)
        ]], {
            ["@fivemid"] = fivemid
        })
        return true, "VPN access granted for FiveM ID " .. fivemid
    end,
}