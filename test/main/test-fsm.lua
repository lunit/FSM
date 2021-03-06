-----------------------------------------------------------------------
-- Finite state machine unit test
-- @module test-fsm

local M = {}
local assertions = require("testing.assertions")
local Fsm = require("main.fsm")


-- FSM instance under test
local fsm
  -- initial state
local state1
  -- target state, in case of testing transition, or inactive state otherwise
local state2


local function before()
  fsm = Fsm()
  
  state1 = fsm.addState("state 1")
  state2 = fsm.addState("state 2")

  fsm.addJunction("state 1", "state 2",
    function (state, keys) return keys.myVar == "move to state2" end)
    
end
---------------------------------------------------------------------
-- It should transition from one state to another, when junction
-- condition holds.
M.testTransitionBetweenStates = function ()

  before()

  fsm.setKey("myVar", "move to state2")
  return assertions.assertEquals("state 2",fsm.getCurrentStateId())
end

-----------------------------------------------------------------------
-- It should call onExit handlers when transitioning from handler's
-- enclosing state to another.
-- 
M.testCallOnExitHandlers = function ()
	before()
	
	local handlersMock = {isExecuted = false}
	state1.addHandler('onExit', function() handlersMock.isExecuted = true end)
  fsm.setKey("myVar", "move to state2")
  return assertions.assertEquals(true, handlersMock.isExecuted)
end

-------------------------------------------------------------------------
-- It should call onEnter handlers when transitioning to handler's 
-- enclosing state.
-- 
M.testCallOnEnterExecuted = function ()
	before()
	
	local handlersMock = {isExecuted = false}
	state2.addHandler('onEnter', function() handlersMock.isExecuted = true end)
  fsm.setKey("myVar", "move to state2")
  return assertions.assertEquals(true, handlersMock.isExecuted)
end 


--------------------------------------------------------------------------
-- It should call current state onUpdate handlers when calling enclosing
-- fsm update method.
-- 
M.testCallOnUpdateExecuted = function ()
  before()
  	
	local handlersMock = {isExecuted = false}
	state1.addHandler('onUpdate', function() handlersMock.isExecuted = true end)
  return assertions.assertEquals(true, handlersMock.isExecuted)
end 

--------------------------------------------------------------------------
-- It should not call inactive state onUpdate handlers when calling enclosing
-- fsm update method.
-- 
M.testCallOnUpdateExecuted = function ()
  before()
  	
	local handlersMock = {isExecuted = false}
	state2.addHandler('onUpdate', function() handlersMock.isExecuted = true end)
  return assertions.assertEquals(false, handlersMock.isExecuted)
end 

--------------------------------------------------------------------------------
-- It should check all junctions when executing fsm on Update methods
-- 
M.testJunctionsExecutedOnUpdate = function ()
	before()
	
	local junctionMock = {isExecuted = false}
	fsm.addJunction('state 1', 'state 2', 
	   function (state, keys) junctionMock.isExecuted = true return false end)
   fsm.update()
  return assertions.assertEquals(true, junctionMock.isExecuted)
end


---------------------------------------------------------------------------------
-- It should change its state if junction's condition holds true, while performing
-- update.
-- 
M.testChangesStateOnUpdate = function ()
	before()
	
	fsm.addJunction('state 1', 'state 2', 
	                         function (state, keys) return true end)
   fsm.update()
  return assertions.assertEquals('state 2', fsm.getCurrentStateId())
	
end

----------------------------------------------------------------------------
-- Functional tests
----------------------------------------------------------------------------

M.testLoadsStateFromFSMString = function ()

  local input = [[
                    {"fsm": 
                      {"states":[
                        {"name":"initialState", 
                            "junctions":[{"condition":"function(state, keys) return keys.shouldChangeState", "state":"targetState"},
                                         {"condition":"function(state, keys) return false", "state":"nonTargetState"}],
                            "handlers":[{"event":"onUpdate", "action":"function(keys) keys.shouldChangeState=true"}]
                          },
                        {"name":"targetState", "handlers":[{"event":"onEnter", "action":"function(keys) keys.enteredTargetState = true"}]}],
                         "startState":"initialState"
                       }
                     }
                 ]]
  local fsm = Fsm.loadFSMFromJson(input)
  fsm.update()
  return assertions.assertEquals(true,fsm.keys.enteredTargetState and (fsm.getCurrentStateId() == "targetState"))
end



return M

