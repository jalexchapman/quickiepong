import 'CoreLibs/sprites.lua'
import 'CoreLibs/graphics.lua'

class('Ball').extends(playdate.graphics.sprite)

function Ball:init()
    Ball.super.init(self)

    self.kSize=5
    self.kInitialSpeed = 3.0
    self.kSpeedBoost = 0.3
    self.kLeft = -1
    self.kRight = 1
    self.kVerticalMax = 1.5

    self:setSize(self.kSize, self.kSize)
    self:moveTo(200,120)
    self:setCollideRect(0,0,self:getSize())

    self.vXNorm = self.kRight
    self.vYNorm = (math.random() - 0.5) * 2 * self.kVerticalMax --normed from -2 to 2
    self.speed = self.kInitialSpeed
    self:addSprite()
end

function Ball:reset()
    self.speed = self.kInitialSpeed
    self:moveTo(200, math.random(40,200))
    if (math.random(2) == 2) then
        self.vYNorm *= -1
    end
end

function Ball:draw()
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(0,0,self.kSize,self.kSize)
end

function Ball:update()
    self:moveBy(self.vXNorm * self.speed, self.vYNorm * self.speed)
    --paddle bounce
    if (GameState == KPlayState) then
        local overlap = self:allOverlappingSprites()
        if next(overlap) ~= nil then
            if self.x < 200 and self.vXNorm == self.kLeft then --left paddle
                self:bounce(leftPaddle)
            elseif self.x > 200 and self.vXNorm == self.kRight then --right paddle
                self:bounce(rightPaddle)
            end
        end
    end

    --world bounce
    if (self.y > 240) then
        self.vYNorm = self.vYNorm * -1
        self:moveTo(self.x, 480 - self.y)
    elseif self.y < 0 then
        self.vYNorm = self.vYNorm * -1
        self:moveTo(self.x, -1 * self.y)
    end
    if (self.x > 400) then
        if GameState == KPlayState then
            ScoreLeft()
        else
            self.vXNorm = self.kLeft
            self:moveTo(800-self.x, self.y)
        end
    elseif (self.x < 0) then
        if GameState == KPlayState then
            ScoreRight()
        else
            self.vXNorm = self.kRight
            self:moveTo(-1 * self.x, self.y)
        end
    end
end

function Ball:bounce(paddle)
    self.vXNorm *= -1
    self.speed += self.kSpeedBoost

    --difference/height ranges from -.5 to .5; norm to -2 to 2
    self.vYNorm = 2 * self.kVerticalMax *(self.y - paddle.y)/(paddle.kHeight)
end