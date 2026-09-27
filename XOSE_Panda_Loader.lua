--// XOSE PandaAuth lightweight bootstrap
--// Upload and protect this file in PandaAuth. Do not upload XOSE_PC_v3.lua.
do
    local env = _G
    if type(getgenv) == "function" then
        local envOk, resolvedEnv = pcall(getgenv)
        if envOk and type(resolvedEnv) == "table" then env = resolvedEnv end
    end

    local coreUrl = "https://raw.githubusercontent.com/zxcswastik-cyber/XoseCity/refs/heads/main/XOSE_Panda_Loader_Core.lua"
    local coreSource = game:HttpGet(coreUrl)
    if type(coreSource) ~= "string" or #coreSource < 500 then
        error("XOSE Panda loader core download returned invalid data")
    end

    local coreChunk, coreCompileError = loadstring(coreSource)
    if type(coreChunk) ~= "function" then
        error("XOSE Panda loader core compilation failed: " .. tostring(coreCompileError))
    end

    local runLoader = coreChunk()
    if type(runLoader) ~= "function" then
        error("XOSE Panda loader core returned an invalid entry point")
    end

    runLoader({
        env = env,
        pandaKey = function()
            local key = type(_G) == "table" and rawget(_G, "PandaKey") or nil
            if type(key) ~= "string" or key == "" then key = rawget(env, "PandaKey") end
            return key
        end,
        httpGet = function(url) return game:HttpGet(url) end,
        compile = loadstring,
        warn = warn,
    })
end

