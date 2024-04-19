local List = require("lib/list")

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
-- /* println:: STRING => IO[nil] */
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

local function seq(instanceA)
  return function(instanceB)
    return flatMap(instanceA)(function(a)
      return instanceB;
    end)
  end;
end

local function seqs(alist)
  return List.foldr(alist)(List.empty())(done());
end;

-- /* IO.putc:: CHAR => IO[] */
local function putc(character)
  return function(_)
    process.stdout.write(character);
    return nil;
  end;
end

-- /* IO.puts:: LIST[CHAR] => IO[] */
local function puts(alist)
  return List.match(alist, {
    empty = function()
      return done();
    end,
    cons = function(head, tail)
      return seq(putc(head))(puts(tail));
    end
  });
end

-- /* IO.getc:: IO[CHAR] *
local function getc()
  local continuation = function()
    local chunk = process.stdin.read();
    return chunk;
  end 
  process.stdin.setEncoding('utf8');
  return process.stdin.on('readable', continuation);
end;
        -- /* #@@range_end(io_monad_is_composable) */


return {
  new = new, 
  flatMap = flatMap, 
  done = done, 
  run = run, 
  readFile = readFile, 
  println = println, 
  writeFile = writeFile, 
  seq = seq, 
  seqs = seqs, 
  putc = putc, 
  puts = puts, 
  getc = getc
}

-- #@@range_end(io_monad_definition)
