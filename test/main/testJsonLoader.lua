lunit = require("lunit")
jsonStateLoader = require("jsonStateLoader")

local M = {}

local function main()
	print(string.format("Load obj from string test:\t%s", M.testStringStructure() and "O.K." or "Failed"))
	print(string.format("Recognize conditions test:\t%s", M.testRecognizeConditions() and "O.K." or "Failed"))
	print(string.format("Recognize handlers test:\t%s", M.testRecognizeHandlers() and "O.K." or "Failed"))
end

--- It should create object with structure, specified in json string
function M.testStringStructure()

  local testString = 
  [[{"FSM": {
      "States":[{"Name":"init"}, {"name":"zombie"}, {"name":"running"}],
      "StartState":"init"
    }}
  ]]
	local resultObj = jsonStateLoader.loadJsonData(testString)
	return lunit.assertEquals(true, #resultObj.states == 3 and resultObj.startstate == "init")
end

--- It should recognize conditions, that stored in json fields
function M.testRecognizeConditions()

  local fsm = {
          states={
                {name = "state 1", junctions = {{condition = "true", state = "state 2"}}},
                {name = "state 2"}
                }
              }
  
	return lunit.assertEquals(true,(jsonStateLoader.recognizeConditions(fsm)).states[1].junctions[1].condition())
	
end

-- It should recognize handlers correctly
function M.testRecognizeHandlers()
  handlermock = {actionPerformed = false}
  local fsm = {
          states={
                {name = "state 1", junctions = {{condition = "true", state = "state 2"}}},
                {name = "state 2", handlers={{event="onenter", action = "handlermock.actionPerformed = true"}}}
                }
              }
  fsm = jsonStateLoader.recognizeHandlers(fsm) 
  fsm.states[2].handlers[1].action()           
	return lunit.assertEquals(true,handlermock.actionPerformed)
end




--main()
return M