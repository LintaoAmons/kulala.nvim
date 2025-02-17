local Logger = require("kulala.logger")

local M = {}

local function parse(body)
  local query_string
  local variables_string

  -- Split the body into lines
  local lines = vim.split(body, "\n")
  local in_query = false
  local in_variables = false
  local query = {}
  local variables = {}
  local query_matcher = "query"
  local mutation_matcher = "mutation"
  local variables_matcher = "{"

  for _, line in ipairs(lines) do
    if line:find("^" .. query_matcher) then
      in_query = true
      in_variables = false
    elseif line:find("^" .. mutation_matcher) then
      in_query = true
      in_variables = false
    elseif line:find("^" .. variables_matcher) then
      in_query = false
      in_variables = true
    end

    line = vim.trim(line)

    if in_query then
      table.insert(query, line)
    elseif in_variables then
      table.insert(variables, line)
    end
  end

  if #query == 0 then
    query_string = nil
  else
    query_string = table.concat(query, " ")
  end

  if #variables == 0 then
    variables_string = nil
  else
    variables_string = table.concat(variables, " ")
  end

  return query_string, variables_string
end

M.get_json = function(body)
  local query, variables = parse(body)
  local json = { query = "", variables = "" }

  if not (query and #query > 0) then return end

  json.query = query

  if variables then
    local status, result = pcall(vim.json.decode, variables)

    if status then
      json.variables = result
    else
      Logger.error("Failed to parse query: " .. result)
    end
  end

  return vim.json.encode(json)
end

return M
