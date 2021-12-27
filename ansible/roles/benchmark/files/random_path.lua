local paths = {
  "/foo",
  "/bar"
}

math.randomseed(os.time())

randomPath = function()
  local path = math.random(1,table.getn(paths))
  return paths[path]
end

request = function()
  path = randomPath()
  return wrk.format(nil, path)
end