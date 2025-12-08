local M = {}

local current_session = nil
local function find_sessions()
    local cwd = vim.uv.cwd()
    local sessions = {}
    if not cwd then
        return
    end
    for name, type in vim.fs.dir(cwd) do
        if type == "file" then
            local contents = io.open(name, "r")
            if contents then
                for line in contents:lines("*l") do
                    if line == "let SessionLoad = 1" then
                        table.insert(sessions, name)
                    else
                        break
                    end
                end
                contents:close()
            end
        end
    end
    if #sessions > 0 then
        return sessions
    else
        return nil
    end
end
local function notify_sessions()
    local sessions = find_sessions()
    if sessions then
        local msg = "Found available sessions:"
        for _, sess in ipairs(sessions) do
            msg = msg .. "\n\t" .. sess
        end
        vim.notify(msg)
    end
end
function M.load_session()
    local sessions = find_sessions()
    if not sessions then
        vim.notify("No sessions found")
        return
    end
    if #sessions > 0 then
        vim.ui.select(sessions, { prompt = "Select Session to load" }, function(choice)
            if choice then
                vim.cmd("source " .. choice)
                current_session = choice
            end
        end)
    end
end
function M.save_session()
    if current_session then
        vim.cmd("mks! " .. current_session)
    else
        vim.ui.input("Session name", function(name)
            if name then
                vim.cmd("mks " .. name)
                vim.notify(name .. " saved")
            end
        end)
    end
end
function M.setup()
    vim.api.nvim_create_autocmd({ "DirChanged" }, {
        callback = notify_sessions,
    })
    notify_sessions()
end

return M
