local inventory = {
    items = {}, -- Will store collected items
    equippedItems = {}, -- Will track which items are equipped
    slots = {
        "ability1", -- For spring
        "ability2"  -- For jetpack
    },
    visible = false -- Toggle inventory visibility
}

-- Initialize the inventory
function inventory.init()
    -- Pre-define item properties 
    inventory.itemDefinitions = {
        spring = {
            name = "Spring",
            description = "Allows jumping with Space",
            icon = nil, -- We'll set this in love.load
            slot = "ability1"
        },
        jetpack = {
            name = "Jetpack",
            description = "Allows flying with W",
            icon = nil, -- We'll set this in love.load
            slot = "ability2"
        }
    }
end

-- Add an item to inventory
function inventory.addItem(itemId)
    if not inventory.items[itemId] and inventory.itemDefinitions[itemId] then
        inventory.items[itemId] = true
        return true
    end
    return false
end

-- Check if player has an item
function inventory.hasItem(itemId)
    return inventory.items[itemId] == true
end

-- Toggle whether an item is equipped
function inventory.toggleEquip(itemId)
    if not inventory.hasItem(itemId) then return false end
    
    local slot = inventory.itemDefinitions[itemId].slot
    
    -- If item is already equipped, unequip it
    if inventory.equippedItems[slot] == itemId then
        inventory.equippedItems[slot] = nil
        return false -- return false to indicate it's now unequipped
    else
        -- Otherwise, equip it (replacing any item in that slot)
        inventory.equippedItems[slot] = itemId
        return true -- return true to indicate it's now equipped
    end
end

-- Check if an item is equipped
function inventory.isEquipped(itemId)
    for _, equippedId in pairs(inventory.equippedItems) do
        if equippedId == itemId then
            return true
        end
    end
    return false
end

-- Toggle inventory visibility
function inventory.toggleVisibility()
    inventory.visible = not inventory.visible
end

-- Draw the inventory UI
function inventory.draw()
    if not inventory.visible then
        -- Just show a small indicator when inventory is closed
        love.graphics.setColor(0.3, 0.3, 0.3, 0.7)
        love.graphics.rectangle("fill", 10, 10, 150, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press I for Inventory", 20, 15)
        return
    end
    
    -- Draw inventory background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 100, 100, 600, 400)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("line", 100, 100, 600, 400)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("INVENTORY", 350, 120, 0, 1.5, 1.5)
    
    -- Draw items
    local y = 170
    for itemId, itemDef in pairs(inventory.itemDefinitions) do
        -- Only show collected items
        if inventory.hasItem(itemId) then
            local equipped = inventory.isEquipped(itemId)
            
            -- Background highlight for equipped items
            if equipped then
                love.graphics.setColor(0.3, 0.8, 0.3, 0.5)
                love.graphics.rectangle("fill", 120, y-5, 560, 50)
            end
            
            -- Draw item icon (scaled down to fit in the inventory)
            love.graphics.setColor(1, 1, 1)
            local iconScale = 0.04 -- Scale down to 50% of original size
            love.graphics.draw(itemDef.icon, 130, y, 0, iconScale, iconScale)
            
            -- Draw item name and description
            love.graphics.print(itemDef.name, 200, y, 0, 1.2, 1.2)
            love.graphics.print(itemDef.description, 200, y + 25)
            
            -- Draw equip/unequip button
            love.graphics.setColor(0.4, 0.4, 0.8)
            love.graphics.rectangle("fill", 550, y, 120, 30)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(equipped and "Unequip" or "Equip", 580, y + 8)
            
            y = y + 70
        end
    end
    
    -- Draw instructions
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Click items to equip/unequip. Press I to close.", 250, 460)
end

-- Handle mouse clicks in inventory
function inventory.mousepressed(x, y, button)
    if not inventory.visible or button ~= 1 then return end
    
    local itemY = 170
    for itemId, _ in pairs(inventory.itemDefinitions) do
        if inventory.hasItem(itemId) then
            -- Check if button area was clicked
            if x >= 550 and x <= 670 and y >= itemY and y <= itemY + 30 then
                inventory.toggleEquip(itemId)
                return true -- Handled click
            end
            itemY = itemY + 70
        end
    end
    
    return false -- Click not handled
end

return inventory