
local timesync = require "timesync"

local round_mt = {}
round_mt.__index = round_mt

function round_mt:init()
	self.global = 0
	self.lag = 0
	self.up_lag_rate = 0
	timesync:reset()
end

function round_mt:update_G()
	self.global = timesync.localtime()
end

function round_mt:G1()
	return self.global + self.lag * self.up_lag_rate
end

function round_mt:expect_G()
	return self.global + self.lag
end

function round_mt:send(lag, up)
	self.lag = lag
	self.up_lag_rate = up
	self:update_G()

	local l1 = timesync.localtime()
	local g1 = self:G1()
	local expect = self:expect_G()
	print(self.global)

	print(timesync.localtime())
	timesync.sleep(lag*10)
	print(timesync.localtime())

	print("sync:", expect, timesync.sync(l1, g1))

	return self:check()
end

function round_mt:expect_offset_rate()
	return self.up_lag_rate - 0.5
end

function round_mt:offset_rate()
	local expect, g = self:check()
	return (g - expect) / self.lag
end

function round_mt:check()
	self:update_G()
	return self.global, timesync.globaltime()
end

function round_mt:check_rate()
	return self:expect_offset_rate(), self:offset_rate()
end

return function(g, l)
	local round = setmetatable({}, round_mt)
	round:init()
	return round
end
