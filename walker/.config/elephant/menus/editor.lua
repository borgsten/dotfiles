Name = "workspaces"
NamePretty = "Open Workspace"
Icon = "applications-other"
Cache = true
HideFromProviderlist = false
Match = "Fuzzy"


local data_path = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
local workspace_path = data_path .. "/elephant/workspaces.lua"

local function substitute_env(str)
  return (str:gsub("%${([%w_]+)}", os.getenv)
    :gsub("%$([%w_]+)", os.getenv))
end

--- @class Workspace
--- @field name string
--- @field path string
--- @field source string

--- Create the edit command for workspace entry.
--- @param workspace Workspace
local function MakeEditCmd(workspace)
  return string.format("xdg-terminal-exec --dir=%s source_and_run.sh nvim %s", workspace.path,
    workspace.source and workspace.source or "")
end

--- Create the open command for workspace entry.
--- @param workspace Workspace
--- @return string: The command to open the workspace in a terminal.
local function MakeOpenCmd(workspace)
  return string.format("xdg-terminal-exec --dir=%s", workspace.path)
end

--- Get the list of workspaces from a Lua file.
--- The workspace file should return a table of Workspace.
--- @return Workspace[]|nil: A list of workspaces or nil if file does not exist.
local function GetWorkspaces()
  local ok, workspaces = pcall(dofile, workspace_path)
  if not ok or type(workspaces) ~= "table" then
    return nil
  end

  for _, workspace in ipairs(workspaces) do
    if workspace.path then
      workspace.path = substitute_env(workspace.path)
    end
  end
  return workspaces
end

function GetEntries()
  local workspaces = GetWorkspaces()

  if workspaces == nil then
    return {
      {
        Text = "No workspaces in state file",
      },
    }
  end
  local entries = {}
  for _, workspace in ipairs(workspaces) do
    table.insert(entries, {
      Text = workspace.name,
      Actions = {
        open = MakeOpenCmd(workspace),
        edit = MakeEditCmd(workspace),
      }
    })
  end

  return entries
end
