-- #@@range_begin(array_module)

local function reduce(anArray,  callback,  accumulator)
  if(#anArray == 0) then
    return accumulator
  else
    local head = anArray[1]
    -- assert(head)
    local tail = { select(2, table.unpack(anArray)) }
    return callback(head,  reduce(tail, callback,  accumulator))
  end

end

return {
  reduce = reduce
}

-- #@@range_end(array_module)
