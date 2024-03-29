local pair = {}

-- #@@range_begin(pair_datatype)
pair.match = function(data, pattern)
  return data(pattern);
end

pair.cons = function(left, right)
  return function(pattern)
    return pattern.cons(left, right);
  end
end

pair.right = function(tuple)
  return pair.match(tuple, {
    cons = function(left, right)
      return right;
    end
  })
end

pair.left = function(tuple)
  return pair.match(tuple, {
    cons = function(left, right)
      return left;
    end
  })
end
-- #@@range_end(pair_datatype)


return pair
