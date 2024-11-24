describe("BatteryState plugin tests", function()
    local MockTime, module, time

    local stat = function() --luacheck: ignore
        return module:new():stat()
    end,

    setup(function()
        require("commonrequire")
        package.unloadAll()
        require("document/canvascontext"):init(require("device"))
        time = require("ui/time")
        MockTime = require("mock_time")
        MockTime:install()
    end)

    teardown(function()
        MockTime:uninstall()
        package.unloadAll()
        require("document/canvascontext"):init(require("device"))
    end)

    before_each(function()
        module = dofile("plugins/batterystat.koplugin/main.lua")
    end)

    it("should record charging time", function()
        local widget = stat()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        widget:resetAll()
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(time.s(1), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onCharging()
        assert.is_true(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        -- Awake charging & discharging time should be reset.
        assert.are.equal(0, widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(0, widget.discharging.time)
        assert.are.equal(time.s(1), widget.charging.time)

        widget:onNotCharging()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        -- awake & discharging time should be reset.
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(time.s(1), widget.discharging.time)
        assert.are.equal(time.s(1), widget.charging.time)

        widget:onCharging()
        assert.is_true(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        -- Awake charging & discharging time should be reset.
        assert.are.equal(0, widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(0, widget.discharging.time)
        assert.are.equal(time.s(1), widget.charging.time)
    end)

    it("should record suspending time", function()
        local widget = stat()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        widget:resetAll()
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(time.s(1), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onSuspend()
        assert.is_false(widget.was_charging)
        assert.is_true(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(time.s(1), widget.sleeping.time)
        assert.are.equal(time.s(2), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onResume()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(2), widget.awake.time)
        assert.are.equal(time.s(1), widget.sleeping.time)
        assert.are.equal(time.s(3), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onSuspend()
        assert.is_false(widget.was_charging)
        assert.is_true(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(2), widget.awake.time)
        assert.are.equal(time.s(2), widget.sleeping.time)
        assert.are.equal(time.s(4), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)
    end)

    it("should not swap the state when several charging events fired", function()
        local widget = stat()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        widget:resetAll()
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(time.s(1), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onCharging()
        assert.is_true(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        -- Awake charging & discharging time should be reset.
        assert.are.equal(0, widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(0, widget.discharging.time)
        assert.are.equal(time.s(1), widget.charging.time)

        widget:onCharging()
        assert.is_true(widget.was_charging)
        assert.is_false(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(0, widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(0, widget.discharging.time)
        assert.are.equal(time.s(2), widget.charging.time)
    end)

    it("should not swap the state when several suspending events fired", function()
        local widget = stat()
        assert.is_false(widget.was_charging)
        assert.is_false(widget.was_suspending)
        widget:resetAll()
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(0, widget.sleeping.time)
        assert.are.equal(time.s(1), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onSuspend()
        assert.is_false(widget.was_charging)
        assert.is_true(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(time.s(1), widget.sleeping.time)
        assert.are.equal(time.s(2), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onSuspend()
        assert.is_false(widget.was_charging)
        assert.is_true(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(time.s(2), widget.sleeping.time)
        assert.are.equal(time.s(3), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)

        widget:onSuspend()
        assert.is_false(widget.was_charging)
        assert.is_true(widget.was_suspending)
        MockTime:increase(1)
        widget:accumulate()
        assert.are.equal(time.s(1), widget.awake.time)
        assert.are.equal(time.s(3), widget.sleeping.time)
        assert.are.equal(time.s(4), widget.discharging.time)
        assert.are.equal(0, widget.charging.time)
    end)
end)
