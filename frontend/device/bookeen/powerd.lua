local BasePowerD = require("device/generic/powerd")

local base_path = '/sys/class/power_supply/battery/'

local Bookeen_PowerD = BasePowerD:new{
    fl_min = 0,
    fl_max = 255,
    is_charging = nil,
    capacity_file = base_path .. 'capacity',
    status_file = base_path .. 'status',
}

function Bookeen_PowerD:init()
end

function Bookeen_PowerD:frontlightIntensityHW()
    local std_out = io.popen('/bin/frontlight', "r")
    if std_out then
        local output = std_out:read("*all")
        std_out:close()
        return 255 - tonumber(output)
    end
    return 0
end

function Bookeen_PowerD:setIntensityHW(intensity)
    inv_intensity = 255 - intensity
    command = '/bin/frontlight ' .. tostring(inv_intensity)
    io.popen(command)
end

function Bookeen_PowerD:getCapacityHW()
    return self:read_int_file(self.capacity_file)
end

function Bookeen_PowerD:isChargingHW()
    return self:read_str_file(self.status_file) == "Charging\n"
end

return Bookeen_PowerD

