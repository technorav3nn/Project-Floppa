--[[local requestFn = nil

if syn and syn.request then
    requestFn = syn.request
elseif http_request then
    requestFn = http_request
else
    requestFn = function(...) 
        return game:GetService("HttpService"):RequestAsync(...)
    end
end

local response, httpError = pcall(function() 
    return requestFn({
        Url = "https://raw.githubusercontent.com/technorav3nn/ProjectFloppa/main/bundle.lua",
        Method = "GET"
    })
end)

if response then
    local code = response.Body
    local success, err = pcall(function()
        loadstring(code)()
    end)
    if success then
        print("Project Floppa loaded successfully!")
    else
        error("Failed to load Project Floppa. Please try again later. Error: " .. err)
    end
else
    error("Failed to load Project Floppa. Please try again later. Error: " .. httpError)
end--]]