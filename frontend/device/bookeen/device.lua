local Generic = require("device/generic/device") -- <= look at this file!
local logger = require("logger")

local function yes() return true end
local function no() return false end

local Bookeen = Generic:new{
    model = "Bookeen",
    isBookeen = yes,
    hasKeys = yes,
    hasOTAUpdates = yes,
    canReboot = yes,
    canPowerOff = yes,
    isTouchDevice = yes,
    hasFrontlight = no,
    display_dpi = 212,
}

local EV_ABS = 3
local ABS_X = 00
local ABS_Y = 01
local ABS_MT_POSITION_X = 53
local ABS_MT_POSITION_Y = 54
-- Resolutions from libremarkable src/framebuffer/common.rs
local screen_width = 758 -- unscaled_size_check: ignore
local screen_height = 1024 -- unscaled_size_check: ignore
local mt_width = 767 -- unscaled_size_check: ignore
local mt_height = 1023 -- unscaled_size_check: ignore
local mt_scale_x = screen_width / mt_width
local mt_scale_y = screen_height / mt_height
local adjustTouchEvt = function(self, ev)
    if ev.type == EV_ABS then
        -- Mirror X and scale up both X & Y as touch input is different res from
        -- display
        if ev.code == ABS_MT_POSITION_X then
            ev.value = (mt_width - ev.value) * mt_scale_x
        end
        if ev.code == ABS_MT_POSITION_Y then
            ev.value = (mt_height - ev.value) * mt_scale_y
        end
        -- The Wacom input layer is non-multi-touch and
        -- uses its own scaling factor.
        -- The X and Y coordinates are swapped, and the (real) Y
        -- coordinate has to be inverted.
        if ev.code == ABS_X then
            ev.code = ABS_Y
            ev.value = (wacom_height - ev.value) * wacom_scale_y
        elseif ev.code == ABS_Y then
            ev.code = ABS_X
            ev.value = ev.value * wacom_scale_x
        end
    end
end

function Bookeen:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = logger.dbg}
    self.powerd = require("device/bookeen/powerd"):new{device = self}
    self.input = require("device/input"):new{
        device = self,
        event_map = { },
    }

    self.input.open("/dev/input/event0") -- Wacom
    self.input.open("/dev/input/event1") -- Touchscreen
    self.input.open("/dev/input/event2") -- Buttons
    -- self.input:registerEventAdjustHook(adjustTouchEvt)
    -- USB plug/unplug, battery charge/not charging are generated as fake events
    self.input.open("fake_events")

    local rotation_mode = self.screen.ORIENTATION_PORTRAIT
    self.screen.native_rotation_mode = rotation_mode
    self.screen.cur_rotation_mode = rotation_mode

    Generic.init(self)
end

function Bookeen:supportsScreensaver() return true end

function Bookeen:setDateTime(year, month, day, hour, min, sec)
    -- if hour == nil or min == nil then return true end
    -- local command
    -- if year and month and day then
    --     command = string.format("timedatectl set-time '%d-%d-%d %d:%d:%d'", year, month, day, hour, min, sec)
    -- else
    --     command = string.format("timedatectl set-time '%d:%d'",hour, min)
    -- end
    -- return os.execute(command) == 0
end

function Bookeen:intoScreenSaver()
    -- local Screensaver = require("ui/screensaver")
    -- if self.screen_saver_mode == false then
    --     Screensaver:show()
    -- end
    -- self.powerd:beforeSuspend()
    -- self.screen_saver_mode = true
end

function Bookeen:outofScreenSaver()
    -- if self.screen_saver_mode == true then
    --     local Screensaver = require("ui/screensaver")
    --     Screensaver:close()
    -- end
    -- self.powerd:afterResume()
    -- self.screen_saver_mode = false
end

function Bookeen:suspend()
    -- os.execute("systemctl suspend")
end

function Bookeen:resume()
end

function Bookeen:powerOff()
    os.execute("poweroff")
end

function Bookeen:reboot()
    os.execute("reboot")
end

return Bookeen


