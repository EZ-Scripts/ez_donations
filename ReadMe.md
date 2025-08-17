# EZ Donations - Tebex Integration for RedM/VORP

A donation system for RedM servers using VORP Core that integrates with Tebex to handle automated redemption of purchased items.

## Features

- **Automated Redeem System**: Players can redeem Tebex purchase codes in-game
- **Multiple Redeem Types**: Supporter status, gold currency, reborn tokens, name changes, and character slots
- **Discord Integration**: Automatic notifications for purchases and redemptions
- **Database Storage**: Secure storage of redeem codes and user data
- **Auto-Redeem Support**: Optional automatic redemption for certain items

## Installation

1. Ensure you have the following dependencies installed:
   - `oxmysql` or `mysql-async`
   - `vorp_core`

2. Place the `ez_donations` folder in your server's `resources/[scripts]/[ez]/` directory

3. Add the following to your `server.cfg`:
   ```
   ensure ez_donations
   ```

4. Rename `config.example.lua` to `config.lua` and configure your Discord webhooks and settings in `config.lua`

## Configuration

Edit `config.lua` to customize:
- Command name for redeeming codes
- Discord webhook URLs
- Server profile information

## Adding New Redeem Actions

### Step 1: Add the Function to Config.lua

In the `Config.RedeemActions` table, add your new redeem type:

```lua
Config.RedeemActions = {
    -- Existing actions...
    
    your_new_action = function(character, value, fivemid, src)
        -- Your custom logic here
        
        -- Always validate inputs
        if not character then
            print("Error: character is nil")
            return false, "Character is nil. Contact server admin."
        end
        
        if not src then
            print("Error: src is nil")
            return false, "Source is nil. Contact server admin."
        end
        
        value = tonumber(value) or 0
        
        -- Example: Give an item to the player
        exports.vorp_inventory:addItem(src, "your_item", value or 1)
        
        -- Log the action
        print("Added " .. value .. " of your_item to character ID " .. character.charIdentifier)
        
        -- Return success status and message
        return true, "Successfully added " .. value .. " of your_item"
    end,
}
```

### Step 2: Function Parameters

Each redeem action function receives these parameters:

- `character`: The VORP character object (contains character data and methods)
- `value`: The value/amount from the Tebex purchase
- `fivemid`: The buyer's FiveM identifier
- `src`: The player's server source ID

### Step 3: Return Values

Always return two values:
- `success` (boolean): true if the action succeeded, false if it failed
- `message` (string): Description of what happened (shown to player and logged)

### Step 4: Common Patterns

#### Giving Items
```lua
exports.vorp_inventory:addItem(src, "item_name", quantity)
```

#### Adding Currency
```lua
character.addCurrency(currency_type, amount) -- 0 = cash, 1 = gold
```

#### Database Operations
```lua
MySQL.Async.execute("UPDATE table SET column = @value WHERE id = @id", {
    ["@value"] = value,
    ["@id"] = character.charIdentifier
})
```

#### Player Notifications
```lua
-- This is handled automatically, but you can add custom ones:
TriggerClientEvent("vorp:TipRight", src, "Custom message", 5000)
```

## Tebex Integration

### Setting Up Tebex Commands

1. In your Tebex panel, go to **Game Servers** → **Commands**

2. Create a new command with this format:
   ```
   tebexredeem {"code":"{transaction}","type":"your_action_name","value":{price},"id":"{id}","quantity":"1","autoredeem":"false"}
   ```
   Example:
   ```
   tebexredeem {"code": "{transaction}", "type": "namechange", "value": "{forename} {surname}", "quantity": "1", "id": "{id}"}
   ```

### Command Parameters Explained

- `code`: Unique transaction ID from Tebex
- `type`: Must match your action name in `Config.RedeemActions`
- `value`: The amount/value to give (usually the price or a fixed amount)
- `id`: The buyer's FiveM identifier
- `quantity`: Number of items purchased (multiplied with value)
- `autoredeem`: "true" for immediate redemption, "false" to require manual redemption. Character is nil.

### Example Tebex Commands

#### Supporter Status (Auto-redeem)
```
tebexredeem {"code":"{transaction_id}","type":"supporter","value":1,"id":"{steam_id}","quantity":{quantity},"autoredeem":"true"}
```

#### Gold Currency (Manual redeem)
```
tebexredeem {"code":"{transaction_id}","type":"gold","value":100,"id":"{steam_id}","quantity":{quantity},"autoredeem":"false"}
```

#### Custom Item
```
tebexredeem {"code":"{transaction_id}","type":"your_new_action","value":5,"id":"{steam_id}","quantity":{quantity},"autoredeem":"false"}
```

## Usage

### For Players
Players can redeem their purchase codes using:
```
/redeem <code>
```

### For Admins
Admins can manually add redeem codes via server console:
```
tebexredeem <json_data>
```

## Database Tables

The script automatically creates these tables:
- `redeem`: Stores pending redeem codes
- `supporter`: Stores supporter status (if using supporter system)

## Discord Integration

Configure webhooks in `config.lua`:
- `purchase`: Notifies when new codes are added
- `redeem`: Notifies when codes are redeemed

## Troubleshooting

### Common Issues

1. **"Character is nil" error**: Player isn't spawned or character isn't loaded
2. **"Source is nil" error**: Issue with player connection or server state
3. **"Invalid redeem type"**: Action name doesn't match config
4. **MySQL errors**: Check database connection and table permissions

### Debug Tips

- Check server console for detailed error messages
- Verify Tebex command format matches exactly
- Test with manual console commands first
- Check Discord webhooks are receiving messages

## Example: Adding a Vehicle Redeem Action

```lua
vehicle_spawn = function(character, value, fivemid, src)
    if not character then
        return false, "Character is nil. Contact server admin."
    end
    
    if not src then
        return false, "Source is nil. Contact server admin."
    end
    
    -- Value should be the vehicle model name
    local vehicleModel = tostring(value)
    
    -- Get player position
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    
    -- Spawn vehicle (you'll need a vehicle spawning resource)
    -- This is just an example - adjust for your server's vehicle system
    TriggerEvent("your_vehicle_system:spawnVehicle", src, vehicleModel, playerCoords)
    
    print("Spawned vehicle " .. vehicleModel .. " for character ID " .. character.charIdentifier)
    return true, "Vehicle " .. vehicleModel .. " spawned successfully!"
end,
```

Then in Tebex:
```
tebexredeem {"code":"{transaction_id}","type":"vehicle_spawn","value":"horse_morgan","id":"{steam_id}","quantity":1,"autoredeem":"false"}
```

## Support

For issues or questions:
1. Check the server console for error messages
2. Verify your configuration matches the examples
3. Test with simple actions first before complex ones
4. Make sure all dependencies are properly installed and running