local PAYLOAD_URL = "https://raw.githubusercontent.com/zxcswastik-cyber/XoseCity/refs/heads/main/XOSE_PC_v3.lua"

local function runLoader(deps)
    assert(type(deps) == "table", "XOSE loader dependencies are missing")
    local env = assert(deps.env, "XOSE loader environment is missing")
    local warnFn = type(deps.warn) == "function" and deps.warn or function() end

    if env.XOSE_PANDA_LOADER_ACTIVE == true then
        warnFn("[XOSE] Panda loader is already active; duplicate execution ignored.")
        return false, "duplicate"
    end
    env.XOSE_PANDA_LOADER_ACTIVE = true

    local ok, failure = pcall(function()
        local pandaKey = type(deps.pandaKey) == "function" and deps.pandaKey() or nil
        if (type(env.XOSE_AUTH_KEY) ~= "string" or env.XOSE_AUTH_KEY == "")
            and type(pandaKey) == "string" and pandaKey ~= "" then
            env.XOSE_AUTH_KEY = pandaKey
        end

        local source = assert(deps.httpGet, "XOSE HTTP provider is missing")(PAYLOAD_URL)
        if type(source) ~= "string" or #source < 1000 then
            error("XOSE payload download returned invalid data")
        end

        local chunk, compileError = assert(deps.compile, "XOSE compiler is missing")(source)
        if type(chunk) ~= "function" then
            error("XOSE payload compilation failed: " .. tostring(compileError))
        end
        chunk()
    end)

    env.XOSE_PANDA_LOADER_ACTIVE = nil
    if not ok then
        warnFn("[XOSE] Panda loader failed: " .. tostring(failure))
        error(failure, 0)
    end
    return true
end

return runLoader

