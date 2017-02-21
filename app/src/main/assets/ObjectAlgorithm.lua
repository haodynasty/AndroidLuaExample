--
-- Created by IntelliJ IDEA.
-- User: quhao
-- Date: 2015/10/16
-- Time: 11:41
-- To change this template use File | Settings | File Templates.
-- 基本的尿不湿判断算法

--[[---------------globle var and method-----------------------------------------]]
-- the array max length, you can define
MAX = 7
TAG = "LuaLog"

--[[---------------队列实现-----------------------------------------------------]]
Queue = {}

-- new queue
function Queue:newquene()
    local obj = {first = 0, last = -1}
    self.__index = self
    return setmetatable(obj, self)
end

function Queue:push(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
end

function Queue:pop()
    local first = self.first
    if first > self.last then
        error("Queue is empty")
    end
    local value = self[first]
    self[first] = nil
    self.first = self.first + 1
end

function Queue:size()
    return self.last - self.first + 1
end

--按入队顺序输出,序列从1开始
function Queue:toArray(arr)
    local i=self.first
    if i > self.last then
        error("Queue is empty")
    end
    while self[i] do
        arr[i - self.first + 1] = self[i];
        --Log:i("LuaLog", "index:"..i - self.first.." value:"..self[i])
        --print("index:"..(i - self.first + 1).." value:"..self[i])
        i = i+1
    end
end

--按出队顺序输出,序列从1开始
function Queue:toArrayReverse(arr)
    local i=self.last
    local len = self.last - self.first
    if self.first > i then
        error("Queue is empty")
    end
    while self[i] do
        arr[len - i + self.first + 1] = self[i];
        --Log:i("LuaLog", "index:"..(len - i + self.first).." value:"..self[i])
        --print("index:"..(len - i + self.first + 1).." value:"..self[i])
        i = i-1
    end
end

-----------------test queue---------------
--[[
local que = Queue:newquene()
local arr = {}
for i=1, 9 do
	que:push(i)
end
que:toArray(arr)
print("LuaLog", "size-----"..Queue.size(que))
print("LuaLog", "size-----"..que:size())
--Log:i("LuaLog", "size-----"..que.size())
que:pop()
que:pop()
que:pop()
print("---")
--Log:i("LuaLog", "-----")
que:push(10)
que:toArrayReverse(arr)
--]]

--[[---------------队列实现end-----------------------------------------------------]]

--[[---------------bluetooth data class begin--------------------------------------]]
BlueDataEntity = {}

--you can use like(with params) entity = BlueDataEntity:new{humidity=11.0 temperature=20, capacity=10}
--or default entity = BlueDataEntity:new()
function BlueDataEntity:new(entity)
    local obj = entity
    if (obj == nil) then
        obj = {humidity=0, temperature=0, capacity=0}
    end
    self.__index = self
    return setmetatable(obj, self)
end

--init entity
function BlueDataEntity:init(humidity, temperature, capacity)
    self.humidity = humidity
    self.temperature = temperature
    self.capacity = capacity
end

--[[---------------bluetooth data class end----------------------------------------]]

--[[---------------diapers algorithm begin-----------------------------------------]]
DiapersAlgorithm={}

--contruct method
function DiapersAlgorithm:new()
    local obj = {
        -- globle queue
        queue = Queue:newquene(),
        -- array entity
        array = {},

        isShit = false,
        isUrine = false,
        isNotNormal = false,
        -- air permeability
        airPermeability = 0,
        -- urine capacity
        urineCapacity = 0,
        --[[
        --基本状态
        --BLUETOOTH_OFF(0), --bluetooth is off
        --NORMAL_DAY(1), --normal day(8:00~21:00)
        --NORMAL_NIGHT(2), --normal night(21:01~07:59)
        --URINE_LESS(3), --has urine or shit but not more
        --URINE_MORE(4); --has more urine or shit
        -- --]]
        state = 0
    }
    --怕self被扩展后改写，所以，让其保持原样
    self.__index = self
    --setmetatable这个函数返回的是第一个参数的值,返回对象self类型原型的引用
    return setmetatable(obj, self)
end

--init method(init base environment)
function DiapersAlgorithm:init()
    self.queue = Queue:newquene()
    self.array = {}
    self.airPermeability = 0
    self.urineCapacity = 0
    self.state = 0
    self.isShit = false
    self.isUrine = false
    self.isNotNormal = false
end

--init environment
function DiapersAlgorithm:clean()
    self:init()
end

--get state
function DiapersAlgorithm:getState()
    local state = 0
    local time = os.time();
    --local tab = os.date("*t",time)
    --print(tab.year, tab.month, tab.day, tab.hour, tab.min, tab.sec);
    local hour = os.date("*t",time).hour
    local size = self.queue:size()
    if size == MAX then
        if isNotNormal then
            if self:isNotNormalMore() then
                state = 4
            else
                state = 3
            end

            if self:isChangedUrine() then
                if hour>= 8 and hour <= 21 then
                    state = 1
                else
                    state = 2
                end
            end
        else
            if self:checkIsNotNormal() then
                if self:isNotNormalMore() then
                    state = 4
                else
                    state = 3
                end
            else
                if hour>= 8 and hour <= 21 then
                    state = 1
                else
                    state = 2
                end
            end
        end
    elseif size>0 then
        if hour>= 8 and hour <= 21 then
            state = 1
        else
            state = 2
        end
    else
        state = 0
    end

    return state
end

--get airPermeability
function DiapersAlgorithm:getAirPermeability()
    --100*(RH1-RH4)/(RH3-RH1)
    local size = self.queue:size()
    if size == MAX then
        return 100*(self.array[1].humidity - self.array[4].humidity)/(self.array[3].humidity - self.array[1].humidity)
    end
    return 0
end

--get urine capacity
function DiapersAlgorithm:getUrineCapacity()
    --MeanC = mean(C1+c2+c3)
    --Val = 40*exp(MeanC - 2.3)
    local size = self.queue:size()
    local mean = 0
    if size == MAX and self.isNotNormal then
        mean = (self.array[1].capacity + self.array[2].capacity + self.array[3].capacity)/3
        return 40*(math.exp(mean - 2.3))
    end
    return 0
end

--is shit
function DiapersAlgorithm:checkIsShit()
    --//(RH1-RH5) /(C1- C5 ) - 27 < 0
    local size = self.queue:size()
    if size == MAX then
        if self.isNotNormal then
            local value = ((self.array[1].humidity - self.array[5].humidity)/(self.array[1].capacity - self.array[5].capacity)) - 27
            if value < 0 then
                return true
            end
        end
    end
    return false
end

--is Urine
function DiapersAlgorithm:checkIsUrine()
    --//(RH1-RH5) /(C1- C5 ) - 27 > 0
    local size = self.queue:size()
    if size == MAX then
        if self.isNotNormal == true then
            local value = ((self.array[1].humidity - self.array[5].humidity)/(self.array[1].capacity - self.array[5].capacity)) - 27
            if value > 0 then
                return true
            end
        end
    end
    return false
end

--is can get normal data
function DiapersAlgorithm:isEnable()
    return self.queue:size() == MAX
end

function DiapersAlgorithm:isNotNormalMore()
    --mean(C1+C2)>3 || mean(RH1, RH2) > 85
    local result1 = ((self.array[1].capacity + self.array[2].capacity)/2 - 3) > 0
    local result2 = ((self.array[1].humidity + self.array[2].humidity)/2 - 85) > 0
    if result1 then
        return true
    end
    if result2 then
        return true
    end
    return false
end

function DiapersAlgorithm:checkIsNotNormal()
    --C1-mean(C5,C6,C7) > 0.4 && C2-mean(C5,C6,C7) > 0.3
    local mean = (self.array[5].capacity + self.array[6].capacity + self.array[7].capacity)/3
    local result1 = false

    if (self.array[1].capacity - mean - 0.4) > 0 then
        if (self.array[2].capacity - mean - 0.3) > 0 then
            result1 = true
        end
    end

    --RH1> mean(RH5,RH6,RH7)
    local mean2 = (self.array[5].humidity + self.array[6].humidity + self.array[7].humidity)/3
    --can not change to (self.array[1].humidity) > mean2
    local result2 = (self.array[1].humidity - mean2) > 0
    --Log:i(TAG, "mean:"..mean.." "..mean2.." "..self.array[7].humidity.." "..(self.array[1].humidity - mean2))

    local result = false
    if result1 then
        if result2 then
            self.isNotNormal = true
            result = true
        end
    end

    return result
end

--is changed diaper or not, using check is transfer to normal state
function DiapersAlgorithm:isChangedUrine()
    --C6 - C1 > 0.5 && C7-C2> 0.5
    local result = false
    if (self.array[6].capacity - self.array[1].capacity - 0.5) > 0 then
        if (self.array[7].capacity - self.array[2].capacity - 0.5) > 0 then
            result = true
        end
    end

    if result then
        self.isNotNormal = false
    end
    return result
end



function DiapersAlgorithm:putData(humidity, temperature, capacity)
    local entity = BlueDataEntity:new()
    entity:init(humidity, temperature, capacity)

    if self.queue:size() < MAX then
        self.state = self:getState()
        self.queue:push(entity)
    else
        self.queue:pop()
        self.queue:push(entity)
    end
    if self.queue:size() == MAX then
        self.queue:toArrayReverse(self.array)
        self.state = self:getState()
        self.airPermeability = self:getAirPermeability()
        self.urineCapacity = self:getUrineCapacity()
        self.isShit = self:checkIsShit()
        self.isUrine = self:checkIsUrine()
    end
end


function DiapersAlgorithm:printAll()
    print("airPermeability:"..self.airPermeability.." urineCapacity:"..self.urineCapacity.." state:"..self.state.." size:"..self.queue:size()
            .." isShit:"..(self.isShit and "true" or "false").." isUrine:"..(self.isUrine and "true" or "false")
            .." isNotNormal:"..(self.isNotNormal and "true" or "false").." isEnable:"..(self:isEnable() and "true" or "false"))
	Log:i(TAG, "airPermeability:"..self.airPermeability.." urineCapacity:"..self.urineCapacity.." state:"..self.state.." size:"..self.queue:size()
            .." isShit:"..(self.isShit and "true" or "false").." isUrine:"..(self.isUrine and "true" or "false")
            .." isNotNormal:"..(self.isNotNormal and "true" or "false").." isEnable:"..(self:isEnable() and "true" or "false"))
end

function DiapersAlgorithm:printArray()
    local size = self.queue:size()
    if size <= 0 then
        error("Queue is empty")
    end
    for i=1, size do
        print("index:"..i.." humidity:"..self.array[i].humidity.." temperature:"..self.array[i].temperature.." capacity:"..self.array[i].capacity)
        Log:i(TAG, "index:"..i.." humidity:"..self.array[i].humidity.." temperature:"..self.array[i].temperature.." capacity:"..self.array[i].capacity)
    end
end

--[[--------------test----------------------------]]
--[[
local tmp = DiapersAlgorithm:new()
tmp:init()
tmp:print()
tmp:putData(1.1,2.0,3.0)
tmp:putData(10,20,30)
tmp:putData(11,22,33)
tmp:putData(1.1,2.32,3.43)
tmp:putData(111,22,33)
tmp:putData(1111,22,33)
tmp:putData(11111,22,33)
tmp:putData(111111,22,33)
tmp:print()
tmp:printArray()
--]]

--[[---------------diapers algorithm end-----------------------------------------]]

diapers = DiapersAlgorithm:new()

--input data to array
function insertData(humidity, temperature, capacity)
    diapers:putData(humidity, temperature, capacity)
end

function printResult()
    diapers:printArray()
    diapers:printAll()
    array = getResult()
    for i=1,6 do
        print(array[i])
    end
    print(array)
end

--init environment
function initEnv()
    diapers:clean()
end

--is data available
function isDataEnable()
    return diapers:isEnable() and "true" or "false"
end

function getResult()
    return {diapers.airPermeability,
    diapers.urineCapacity,
    diapers.state,
    diapers.isShit,
    diapers.isUrine,
    diapers.isNotNormal}
end

--[[
diapers:printAll()
insertData(1.1,2.0,3.0)
insertData(10,20,30)
insertData(11,22,33)
insertData(1.1,2.32,3.43)
insertData(111,22,33)
insertData(1111,22,33)
insertData(11111,22,33)
insertData(111111,22,33)
printResult()
array = getResult()
for i=1,6 do
    print(array[i])
end
print(array)
--]]
