local array = {}

array.reduce = function(anArray,  callback,  accumulator)
  if(#anArray == 0) then
    return accumulator
  else
    local head = anArray[1]
    assert(head)
    -- print(head)
    local tail = { select(2, table.unpack(anArray)) }
    return callback(head,  array.reduce(tail, callback,  accumulator))
  end

end

return array

