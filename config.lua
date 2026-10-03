Config = {}
Config.Command = false
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
            --[[["seasonal"] = { -- 4th of July
                items = {
                    {
                        item = "WEAPON_SNIPERRIFLE_CARCANO",
                        amount = 1,
                        label = 'LIBERTY',
                        description = '"This nation will remain the land of the free only so long as it is the home of the brave."',
                        comps = '{"BARREL_RIFLING":"COMPONENT_LONGARM_BARREL_RIFLING_1","CYLINDER_MATERIAL":"COMPONENT_LONGARM_CYLINDER_MATERIAL_10","BARREL_MATERIAL":"COMPONENT_LONGARM_BARREL_MATERIAL_10","GRIPSTOCK_TINT":"COMPONENT_LONGARM_GRIPSTOCK_TINT_PEARL","GRIP":"COMPONENT_RIFLE_CARCANO_GRIP_ENGRAVED","FRAME_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_FRAME_ENGRAVING_MATERIAL_12","WRAP_TINT":"COMPONENT_LONGARM_WRAP_TINT_C_6","TRIGGER_MATERIAL":"COMPONENT_LONGARM_TRIGGER_MATERIAL_10","FRAME_MATERIAL":"COMPONENT_LONGARM_FRAME_MATERIAL_4","HAMMER_MATERIAL":"COMPONENT_LONGARM_HAMMER_MATERIAL_10","WRAP_MATERIAL":"COMPONENT_LONGARM_WRAP_MATERIAL_LEATHER","FRAME_ENGRAVING":"COMPONENT_LONGARM_FRAME_ENGRAVING_4","CYLINDER_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_CYLINDER_ENGRAVING_MATERIAL_12","STRAP":"COMPONENT_RIFLE_CS_STRAP01","CYLINDER_ENGRAVING":"COMPONENT_LONGARM_CYLINDER_ENGRAVING_1","BARREL_ENGRAVING":"COMPONENT_LONGARM_BARREL_ENGRAVING_4","WRAP":"COMPONENT_RIFLE_CARCANO_WRAP6","SIGHT":"COMPONENT_RIFLE_CARCANO_SIGHT_WIDE","BARREL_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_BARREL_ENGRAVING_MATERIAL_12","CLIP":"COMPONENT_RIFLE_CARCANO_CLIP_EMPTY"}',
                        serial_number = "1776"
                    },
                    {
                        item = "WEAPON_SHOTGUN_SEMIAUTO",
                        amount = 1,
                        label = 'DECLARATION',
                        description = '"We hold these truths to be self-evident, that all men are created equal..."',
                        comps = '{"SIGHT_MATERIAL":"COMPONENT_LONGARM_SIGHT_MATERIAL_10","CYLINDER_MATERIAL":"COMPONENT_LONGARM_CYLINDER_MATERIAL_10","BARREL_MATERIAL":"COMPONENT_LONGARM_BARREL_MATERIAL_3","GRIPSTOCK_TINT":"COMPONENT_LONGARM_GRIPSTOCK_TINT_PEARL","GRIP":"COMPONENT_SHOTGUN_SEMIAUTO_GRIP","FRAME_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_FRAME_ENGRAVING_MATERIAL_12","WRAP_TINT":"COMPONENT_LONGARM_WRAP_TINT_B_5","TRIGGER_MATERIAL":"COMPONENT_LONGARM_TRIGGER_MATERIAL_10","FRAME_MATERIAL":"COMPONENT_LONGARM_FRAME_MATERIAL_4","HAMMER_MATERIAL":"COMPONENT_LONGARM_HAMMER_MATERIAL_4","GRIPSTOCK_ENGRAVING":"COMPONENT_LONGARM_GRIPSTOCK_ENGRAVING_3","FRAME_ENGRAVING":"COMPONENT_SHOTGUN_FRAME_ENGRAVING_4","CYLINDER_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_CYLINDER_ENGRAVING_MATERIAL_13","BARREL":"COMPONENT_SHOTGUN_SEMIAUTO_BARREL_LONG","BARREL_RIFLING":"COMPONENT_LONGARM_BARREL_RIFLING_1","SIGHT":"COMPONENT_SHOTGUN_SEMIAUTO_SIGHT_WIDE","WRAP":"COMPONENT_SHOTGUN_SEMIAUTO_WRAP2","CYLINDER_ENGRAVING":"COMPONENT_SHOTGUN_CYLINDER_ENGRAVING_3","BARREL_ENGRAVING_MATERIAL":"COMPONENT_LONGARM_BARREL_ENGRAVING_MATERIAL_14","BARREL_ENGRAVING":"COMPONENT_SHOTGUN_BARREL_ENGRAVING_3"}',
                        serial_number = "1776"
                    },
                    { item = "seasonal_stim_liberty_boost", amount = 20},
                    { item = "seasonal_star_spangled_spritz", amount = 20},
                    { item = "seasonal_cigar_firecracker", amount = 20},
                    --{ item = "firework_small", amount = 5},
                    --{ item = "firework_big", amount = 5},
                },
                currency = {
                    ["0"] = 2500,
                    ["1"] = 0
                },
            },]]
            ["seasonal"] = {
                items = {
                    { item = "consumable_vampireshot_halloween", amount = 10},
                    { item = "consumable_halloween_cakepop", amount = 10},
                    { item = "cigar_halloween", amount = 10},
                    { item = "stimapple_halloween", amount = 10},
                    { item = "weapon_melee_lantern_halloween", amount = 1},
                    { item = "wearable_pumpkin1", amount = 1},
                },
                currency = {
                    ["0"] = 2500, -- Cash
                    ["1"] = 0 -- Gold
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
                    local sa =  (itemData.serial_number or itemData.item) .. "-char" .. character.charIdentifier .. "-" .. i .. "-" .. code .. "-" .. math.random(100000, 999999)
                    VORPInv:createWeapon(src, itemData.item, {}, {}, json.decode(itemData.comps or "[]") or {}, function(success)
                    end, nil, sa, itemData.label or nil, itemData.description or nil)
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
        return true, "Given phonograph"
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