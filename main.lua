
-- Class Player -------------------------
Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.speed = 5
    self.sprite = love.graphics.newImage('assets/arrow.png')
    self.pivotX = self.sprite:getWidth() / 2
    self.pivotY = self.sprite:getHeight() / 2
    self.rotation = 0
    return self
end

function Player:grab()
    if love.mouse.isDown(1) then
        local mouseX, mouseY = love.mouse.getPosition()
        for _, block in ipairs(blocks) do
            -- Check if the mouse is over the block
            if mouseX > block.x and mouseX < block.x + block.size and mouseY > block.y and mouseY < block.y + block.size then
                block.grabbed = true
            end
            if block.grabbed then
                block.x = mouseX - block.size / 2
                block.y = mouseY - block.size / 2
            end
        end
    else
        for _, block in ipairs(blocks) do
            block.grabbed = false
        end
    end
end

-----------------------------------------

-- Class Block --------------------------
Block = {}
Block.__index = Block

function Block.new(x, y, size)
    local self = setmetatable({}, Block)
    self.x = x
    self.y = y
    self.size = size
    self.grabbed = false
    return self
end

function Block:spawn(amount)
    local amount = amount or 10
    
    for i = 1, amount do
        local x = math.random(0, love.graphics.getWidth() - 25)
        local y = math.random(0, love.graphics.getHeight() - 25)
        table.insert(blocks, Block.new(x, y, 25))
    end
end
-----------------------------------------

function love.load()

    sti = require 'libraries/sti'
    -- bf = require 'libraries/breezefield'
    map = sti("maps/dev_map.lua")

    -- world = bf.newWorld(0, 90.81, true)
    -- print(world:getGravity())

    player = Player.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2) -- Place in the center of the screen

    blocks = {}
    Block:spawn(10)
end

function love.update(dt)
    
    -- world:update(dt)

    -- player.collider:setPosition(player.x, player.y)

    -- Player movement
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
    end

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
    end

    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
    end

    -- Player follow the mouse
    player.rotation = math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.rad(-90)

    -- Check if the player is grabbing a block
    player:grab()
end

function love.draw()

    map:draw()
    -- world:draw(0,100)

    -- love.graphics.circle("line", player.x, player.y, 25)
    love.graphics.draw(player.sprite, player.x, player.y, player.rotation, 0.1, 0.1, player.pivotX, player.pivotY)
    love.graphics.circle("line", player.x, player.y, 5)

    for _, block in ipairs(blocks) do
        love.graphics.rectangle("line", block.x, block.y, block.size, block.size)
    end

    -- Debug information
    love.graphics.print("Player X: " .. player.x, 10, 10)
    love.graphics.print("Player Y: " .. player.y, 10, 30)
    love.graphics.print("Amount of blocks: " .. #blocks, 10, 50)
end

-----------------------------------------
--- Notes -------------------------------
-----------------------------------------
-- 1. Make colisions with blocks
-- 2. Blocks effected by gravity
-- 3. UI
-- 4. Enemies
-- 5. AI for enemies