sti = require('libraries/sti')
map = sti("maps/dev_map.lua")

-- Global Settings ----------------------
love.graphics.setLineStyle("smooth")
love.graphics.setLineWidth(2)
-----------------------------------------

-- Class Player -------------------------
Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.speed = 500
    self.sprite = love.graphics.newImage('assets/arrow.png')
    self.pivotX = self.sprite:getWidth() / 2
    self.pivotY = self.sprite:getHeight() / 2
    self.rotation = 0
    self.size = {50, 50}
    self.playerBody = love.physics.newBody(world, self.x, self.y, "kinematic")
    self.playerShape = love.physics.newPolygonShape(0, -25, 25, 25, -25, 25)
    self.playerFixture = love.physics.newFixture(self.playerBody, self.playerShape)
    self.shootCoolDown = 0.25
    self.shootTime = 0
    return self
end

function Player:movement(dt)
    
    local dx,dy = 0,0

    if love.keyboard.isDown("lshift") then
        player.speed = 250
    else
        player.speed = 500
    end

    if love.keyboard.isDown("d") then
        dx = player.speed
    elseif love.keyboard.isDown("a") then
        dx = -player.speed
    end

    if love.keyboard.isDown("w") then
        dy = -player.speed
    elseif love.keyboard.isDown("s") then 
        dy = player.speed
    end

    -- Set the player velocity
    self.playerBody:setLinearVelocity(dx,dy)

end

function Player:update(dt)

    -- Get the player position
    self.x, self.y = self.playerBody:getPosition()

    -- Player follow the mouse
    self.rotation = math.atan2(self.y - love.mouse.getY(), self.x - love.mouse.getX()) + math.rad(-90)
    self.playerBody:setAngle(self.rotation)

    -- Shoot cooldown
    if self.shootTime > 0 then
        self.shootTime = self.shootTime - dt
    end
end

function Player:shoot()

    if love.mouse.isDown(1) then
        if self.shootTime <= 0 then
            local mouseX, mouseY = love.mouse.getPosition()
            print(love.timer)

            local instance = Bullet.new(player.x, player.y)
            table.insert(bullets, instance)
            instance.body:setAngle(instance.angle - math.rad(90))
            instance.body:setLinearVelocity(-math.cos(instance.angle) * instance.speed, -math.sin(instance.angle) * instance.speed)
            self.shootTime = self.shootCoolDown
        end
    end
end

-- function Player:grab()
--     if love.mouse.isDown(1) then
--         local mouseX, mouseY = love.mouse.getPosition()
--         for _, block in ipairs(blocks) do
--             -- Check if the mouse is over the block
--             if mouseX > block.x and mouseX < block.x + block.size and mouseY > block.y and mouseY < block.y + block.size then
--                 block.grabbed = true
--             end
--             if block.grabbed then
--                 block.x = mouseX - block.size / 2
--                 block.y = mouseY - block.size / 2
--             end
--         end
--     else
--         for _, block in ipairs(blocks) do
--             block.grabbed = false
--         end
--     end
-- end

-----------------------------------------



-- Class Bullet -------------------------
Bullet = {}
Bullet.__index = Bullet

function Bullet.new(playerX, playerY)
    local self = setmetatable({}, Player)
    self.x = playerX
    self.y = playerY
    self.speed = 250
    self.angle = math.atan2(self.y - love.mouse.getY(), self.x - love.mouse.getX())
    self.body = love.physics.newBody(world, self.x, self.y, "kinematic")
    self.shape = love.physics.newPolygonShape(0, -12.5, 12.5, 12.5, -12.5, 12.5)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    return self
end

function Bullet:check(dt)
    for _, instance in ipairs(bullets) do
        instance.x, instance.y = instance.body:getPosition()
        instance.angle = math.atan2(instance.y - love.mouse.getY(), instance.x - love.mouse.getX())
    end
end
-----------------------------------------



-- Class Block --------------------------
Block = {}
Block.__index = Block

function Block.new(x,y,size)
    local self = setmetatable({}, Block)
    self.x = x
    self.y = y
    self.size = size
    self.grabbed = false
    self.blockBody = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.blockShape = love.physics.newRectangleShape(self.size/2,self.size/2,self.size, self.size)
    self.blockFixture = love.physics.newFixture(self.blockBody, self.blockShape)
    self.blockBody:setFixedRotation(true)
    return self
end

function Block:spawn(amount)
    local amount = amount or 10
    
    for i = 1, amount do
        local x = love.math.random(0, love.graphics.getWidth() - 25)
        local y = love.math.random(0, love.graphics.getHeight() - 25)
        local instance = Block.new(x, y, 50)
        table.insert(blocks, instance)
    end
end

function Block:check()
    for _, block in ipairs(blocks) do
        block.x, block.y = block.blockBody:getPosition()
    end
end
-----------------------------------------



function love.load()
    
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0)

    player = Player.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2) -- Place in the center of the screen

    blocks = {}
    Block:spawn(10)

    bullets = {}
end



function love.update(dt)
    
    world:update(dt)

    player:movement(dt)
    player:shoot()
    player:update(dt)

    Block:check()


end



function love.draw()

    map:draw()

    -- Draw player
    love.graphics.draw(player.sprite, player.x, player.y, player.rotation, 0.1, 0.1, player.pivotX, player.pivotY)
    love.graphics.polygon("line", player.playerBody:getWorldPoints(player.playerShape:getPoints()))
    love.graphics.circle("line", player.x, player.y, 5)

    for _, bullet in ipairs(bullets) do
        love.graphics.polygon("line", bullet.body:getWorldPoints(bullet.shape:getPoints()))
    end

    -- Draw blocks
    -- love.graphics.rectangle("line", block.x, block.y, block.size, block.size)
    for _, block in ipairs(blocks) do
        love.graphics.rectangle("line", block.x, block.y, block.size, block.size)
    end

    -- world:draw()

    -- Debug information
    love.graphics.print("Player X: " .. player.x, 10, 10)
    love.graphics.print("Player Y: " .. player.y, 10, 30)
    love.graphics.print("Amount of blocks: " .. #blocks, 10, 50)
end

-----------------------------------------
--- Notes -------------------------------
-----------------------------------------
-- 1. Make colisions with blocks
-- 3. UI
-- 4. Enemies