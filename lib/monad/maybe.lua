
-- #@@range_begin(maybe_monad)
local function match(exp, pattern)
  return exp(pattern);
end

local function just(value)
  return function(pattern)
    return pattern.just(value);
  end;
end

local function nothing(_)
  return function(pattern)
    return pattern.nothing(_);
  end
end 

local function new(value)
  return just(value);
end

-- /* flatMap:: MAYBE[T] => FUN[T => MAYBE[U]] => MAYBE[U] */
local function flatMap(instanceM)
  return function(transform)
    return match(instanceM,{
      -- /* 正常な値の場合は、transform関数を計算する */
      just = function(value)
        return transform(value);
      end,
      -- /* エラーの場合は、何もしない */
      nothing = function(_)
        return nothing();
      end 
    });
  end 
end

-- /* ヘルパー関数  */
local function getOrElse(instanceM)
  return function(alternate)
    return match(instanceM,{
      just = function(value)
        return value;
      end,
      nothing = function(_)
        return alternate;
      end 
    });
  end;
end
-- #@@range_end(maybe_monad)


return {
  match = match, 
  just = just, 
  nothing = nothing, 
  new = new, 
  flatMap = flatMap, 
  getOrElse = getOrElse
}



