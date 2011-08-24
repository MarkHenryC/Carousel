-- Carousel animation demo.
-- Mark H Carolan 2010
-- Simulate depth in 2D on Corona platform.

local nImages = 8
local range = 360
local sectionSize = range / nImages
local xCentre = display.contentWidth / 2
local yCentre = display.contentHeight / 2
local diameter = display.contentWidth - xCentre/2
local r = diameter / 2
local points = {}
local images = {}
local visual = display.newGroup()
local lastTime = system.getTimer()
local interval = 30
local yRotScale = 0.375
local yScale = 1.25
local xScale = 1.25
local depthCounter = 0

-- Just a visual cue

local pole

pole = display.newRect(0, 0, 100, 400)
pole:setReferencePoint(display.CenterReferencePoint)
pole.x = display.contentWidth/2
pole.y = display.contentHeight/2
pole:setFillColor(48, 64, 128)
pole:setStrokeColor(128, 128, 128)
pole.strokeWidth = 3

display.setStatusBar(display.HiddenStatusBar)

local function sort()

	table.sort(images,  
		function(a, b)
			return a.y < b.y
		end
	)
	
	--
	-- Just re-insert. Removing firstly seems to destroy DisplayObjects,
	-- even if the return value from remove() is put into a table.
	--
	
	for i = 1, #images do
		visual:insert(images[i])

		if i == math.floor(nImages/2) then
			visual:insert(pole)
		end
		
	end
	
end

local function rotate()

	for i = 1, #images do
					
		local img = images[i]
		local cntr = img.counter
		local xy = points[cntr]
		
		img.width = img.origWidth
		img.height = img.origHeight
		img.x = xy[1]
		img.y = xy[2] * yRotScale
		local s = xy[2] / (yCentre + r)
		img.xScale = s * xScale
		img.yScale = s * yScale
		cntr = cntr + 1
		
		if cntr > range then
			cntr = 1
		end
		
		images[i].counter = cntr
		
	end		
		
end

-- Defaults to first-in, furthest-back. Reverse i for opposite:

local counter = 1
for i = 1, nImages do

	local img = display.newGroup()
	
	local rect = display.newRoundedRect(-30, -30, 64, 64, 5)
	rect:setFillColor(64, 64, 64)
	rect:setStrokeColor(255, 140, 0)
	rect.strokeWidth = 5
	img:insert(rect)
	
	local str = i <= 9 and "0"..i or i
	local t = display.newText(str, -28, -28, nil, 46)
	t:setReferencePoint(display.CenterReferencePoint)
	t:setTextColor(200, 200, 200)
	img:insert(t)
	
	img.counter = counter
	img.origWidth = img.width
	img.origHeight = img.height
	images[#images + 1] = img
	counter = counter + sectionSize -- placement in pairs array
	
end

for i = 1, range do

	local x = r * math.cos(math.rad(i))
	local y = r * math.sin(math.rad(i))
	points[#points + 1] = {x + xCentre, y + yCentre}
	
end

sort()

--
-- Depending on layout (number of images), may need to call this 
-- after a few beats in case image is about to overlap at start.
--

rotate() 

local function onFrame(event)

	local curTime = system.getTimer()

	if curTime - lastTime >= interval then		
		rotate()
		lastTime = curTime	
	end
	
	-- Don't sort every frame.
	-- sectionSize is granularity of sorting.
	
	if depthCounter % sectionSize == 0 then
		sort()
	end
		
	depthCounter = depthCounter + 1
	
end
	
Runtime:addEventListener("enterFrame", onFrame)

local function onTouch(self, event)
	if event.phase == "began" then
		self.startX = event.x
		self.startY= event.y
		display.getCurrentStage():setFocus(self)
	elseif event.phase == "moved" then
		local movedX = event.x - self.startX
		local movedY = event.y - self.startY
		print(movedX, movedY)
		self.x = self.x + movedX
		self.y = self.y + movedY
		self.startX = event.x
		self.startY = event.y
	elseif event.phase == "ended" then
		display.getCurrentStage():setFocus(nil)
	end		
end

visual.touch = onTouch
visual:addEventListener("touch", visual)
