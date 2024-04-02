
-- #@@range_begin(identity_monad)
-- /* unit:: T => ID[T] */
local function new(value)  -- 単なる identity関数と同じ
  return value;
end

-- /* flatMap:: ID[T] => FUN[T => ID[T]] => ID[T] */
local function flatMap(instanceM)
  return function(transform)
    return transform(instanceM); -- 単なる関数適用と同じ
  end;
end

-- #@@range_end(identity_monad)
local function compose(f, g)
  return function(x)
    return ID.flatMap(f(x))(g);
  end
end


return {
  new = new, 
  flatMap = flatMap, 
  compose = compose
}

