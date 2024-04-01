local IO = {}
--
-- /* unit:: T => IO[T] */
IO.unit = function(any)
  return function(_) -- 外界を明示する必要はない
    return any;
  end 
end

-- /* flatMap:: IO[T] => FUN[T => IO[U]] => IO[U] */
IO.flatMap = function(instanceA)
  return function(actIOnAB) -- actIOnAB:: a -> IO[b]
    return function(_)
      return IO.run(actIOnAB(IO.run(instanceA)));
    end 
  end 
end
-- 間違った定義
-- flatMap: (instanceA) => {
--   return (actIOnAB) => { -- actIOnAB:: A => IO[B]
--     return actIOnAB(IO.run(instanceA)); 
--   };
-- },
-- /* done:: T => IO[T] */
IO.done = function(any)
  return IO.unit();
end
-- /* run:: IO[A] => A */
IO.run = function(instance)
  return instance();
end
-- /* readFile:: STRING => IO[STRING] */
IO.readFile = function(path)
  return function(_)
    local file = io.open(path, "r")
    -- local fs = require('fs');
    -- local content = fs.readFileSync(path, 'utf8');
    local lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    io.close(file)
    return IO.unit(lines)();
  end;
end
-- /* println:: STRING => IO[null] */
IO.println = function(message)
  return function(_)
    print(message);
    return IO.unit(nil)();
  end 
end

IO.writeFile = function(path)
  return function(content)
    return function(_)
      local fs = require('fs');
      fs.writeFileSync(path,content);
      return IO.unit(null)();
    end;
  end 
end 




return IO
