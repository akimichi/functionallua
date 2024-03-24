local env = {}

env.empty = function(variable)
  return nil;
end

env.lookup = function(name, environment)
  return environment(name);
end

env.extend = function(identifier, value, environment)
  return function(queryIdentifier)
    if(identifier == queryIdentifier) then
      return value;
    else
      return env.lookup(queryIdentifier,environment);
    end
  end;
end



return env
