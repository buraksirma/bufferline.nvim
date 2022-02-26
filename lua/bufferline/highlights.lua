local fmt = string.format
---------------------------------------------------------------------------//
-- Highlights
---------------------------------------------------------------------------//
local M = {}

local ERROR = vim.log.levels.ERROR
local notify = vim.notify

function M.hl(item)
  return "%#" .. item .. "#"
end

function M.hl_exists(name)
  return vim.fn.hlexists(name) > 0
end

local keys = { "gui", "guisp", "guibg", "guifg" }

function M.set_one(name, opts)
  if not opts or vim.tbl_isempty(opts) then
    return
  end
  local hls = {}
  for key, value in pairs(opts) do
    if value and value ~= "" and vim.tbl_contains(keys, key) then
      table.insert(hls, fmt("%s=%s", key, value))
    end
  end
  local themable = require("bufferline.config").get("options").themable
  local ok, rsp = pcall(
    vim.cmd,
    fmt("highlight %s %s %s", themable and "default" or "", name, table.concat(hls, " "))
  )
  if not ok then
    notify(
      fmt("Failed setting %s  highlight, something isn't configured correctly: %s", name, rsp),
      ERROR
    )
  end
end

---Generate highlight groups from user
---@param highlight table
function M.add_group(name, highlight)
  -- convert 'bufferline_value' to 'BufferlineValue' -> snake to pascal
  local formatted = "BufferLine" .. name:gsub("_(.)", name.upper):gsub("^%l", string.upper)
  highlight.hl_name = formatted
  highlight.hl = M.hl(formatted)
end

--- Map through user colors and convert the keys to highlight names
--- by changing the strings to pascal case and using those for highlight name
--- @param user_colors table
function M.set_all(user_colors)
  for name, tbl in pairs(user_colors) do
    if not tbl or not tbl.hl_name then
      return notify(
        fmt("Error setting highlight group: no name for %s - %s", name, vim.inspect(tbl)),
        ERROR
      )
    end
    M.set_one(tbl.hl_name, tbl)
  end
end

return M
