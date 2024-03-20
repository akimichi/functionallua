local list = {}

function list.match =  function(data, pattern)
  return data(pattern)
end


return list
