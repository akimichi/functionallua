local ID = {}

-- #@@range_begin(identity_monad)
-- /* unit:: T => ID[T] */
ID.unit = function(value)  -- 単なる identity関数と同じ
  return value;
end

-- /* flatMap:: ID[T] => FUN[T => ID[T]] => ID[T] */
ID.flatMap = function(instanceM)
  return function(transform)
    return transform(instanceM); -- 単なる関数適用と同じ
  end;
end

-- #@@range_end(identity_monad)
ID.compose = function(f, g)
  return function(x)
    return ID.flatMap(f(x))(g);
  end
end


return ID

