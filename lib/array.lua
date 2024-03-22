local array = {}

array.reduce = function(seq,  glue,  accumulator)
  if(#seq == 0) then
    return accumulator
  elseif(#seq == 1) then
    return glue(head,  accumulator)
  else
    local head = seq[1]
    print(head)
    local tail = { select(2, table.unpack(seq)) }
    return glue(head,  array.reduce(tail, glue,  accumulator))
  end

end

return array

