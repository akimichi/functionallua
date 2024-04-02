
local function new(a)
  return function(k)
    return k(a);
  end
end

local function flatMap(m)
  return function(f)
    assert(type(f) == "function")
    return function(k)
      return m(function(a)
        return f(a)(k);
      end)
    end 
  end 
end

local function callCC(f)
  return function(k)
    return f(function(a)
      return function(_)
        return k(a);
      end 
    end)(k);
  end 
end 

return {
  new = new, 
  flatMap = flatMap, 
  callCC = callCC
}
