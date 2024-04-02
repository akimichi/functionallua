local Pair = require("../pair.lua")
local List = require("../list.lua")

local function new(a)
  return {
    run = function(_)
      return Pair.cons(List.empty(),a);
    end 
  };
end 

local function flatMap(writer)
  local writerPair = writer.run();
  local v = Pair.left(writerPair);
  local a = Pair.right(writerPair);
  return function(f)
    local newPair = f(a).run();
    local v_ = Pair.left(newPair);
    local b = Pair.right(newPair);
    return {
      run = function() 
        return Pair.cons(List.append(v)(v_),b);
      end 
    };
  end
end 

local function tell(s)
  return {
    run = function(_)
      return Pair.cons(s, List.empty());
    end 
  };
end 

return {
  new = new, 
  flatMap = flatMap, 
  tell = tell

}
