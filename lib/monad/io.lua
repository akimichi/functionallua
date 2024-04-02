-- #@@range_begin(io_monad_definition)
-- /* unit:: T => IO[T] */
local function new(any)
  return function(_) -- 外界を明示する必要はない
    return any;
  end 
end

-- /* flatMap:: IO[T] => FUN[T => IO[U]] => IO[U] */
local function flatMap(instanceA)
  return function(actIOnAB) -- actIOnAB:: a -> IO[b]
    return function(_)
      return run(actIOnAB(run(instanceA)));
    end 
  end 
end
-- /* done:: T => IO[T] */
local function done(any)
  return new();
end
-- /* run:: IO[A] => A */
local function run(instance)
  return instance();
end
--
-- /* readFile:: STRING => IO[STRING] */
local function readFile(path)
  return function(_)
    local file = io.open(path, "r")
    -- local fs = require('fs');
    -- local content = fs.readFileSync(path, 'utf8');
    local lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    io.close(file)
    return new(lines)();
  end;
end
-- /* println:: STRING => IO[null] */
local function println(message)
  return function(_)
    print(message);
    return new(nil)();
  end 
end

local function writeFile(path)
  return function(content)
    return function(_)
      -- local fs = require('fs');
      -- fs.writeFileSync(path,content);
      return new(nil)();
    end;
  end 
end 


return {
  new = new, 
  flatMap = flatMap, 
  done = done, 
  run = run, 
  readFile = readFile, 
  println = println, 
  writeFile = writeFile
}

-- #@@range_end(io_monad_definition)
