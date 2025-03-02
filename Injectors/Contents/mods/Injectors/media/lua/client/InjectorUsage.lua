---@param interval number
---@return number
function Seconds(interval)
    return interval*60
end

---@param value number
---@param ticks number
---@return number
function OverTime(value, ticks)
    return value / ticks
end

function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

TimedEvent = {}

function TimedEvent:new()
    local self  = setmetatable({}, TimedEvent)
    self.ticks  = 0                  -- external time elapsed
    self.stored = {}                 -- stored functions
    return self
end

function TimedEvent:plan(args)
    table.insert(self.stored, {
        mainEvent    = args.mainFunc    or function() end,  -- main action
        postEvent    = args.postFunc    or function() end,  -- post action
        delay        = args.delay       or 1,               -- delay
        duration     = args.duration    or 0,               -- duration
        repeated     = args.repeated                        -- is looped
    })
end

function TimedEvent:process()
    for i, event in ipairs(self.stored) do
        local ticks = self.ticks - event.delay  -- internal time elapsed

        if ticks >= 0 and ticks <= event.duration then
            if event.repeated then
                event.mainEvent()
            else
                if ticks == 0 then
                    event.mainEvent()
                end
            end
        end

        if ticks == event.duration then
            event.postEvent()
        end
    end
end

function TimedEvent:duration()
    local max = 0
    for _, event in ipairs(self.stored) do
        local time = event.delay + event.duration
        if time > max then
            max = time
        end
    end
    return max
end

function TimedEvent:destroy()
    self.stored = {}
    self.ticks = 0
    setmetatable(self, nil)
end