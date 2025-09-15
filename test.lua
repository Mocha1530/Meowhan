local scriptId = "7a953911595e67e8494c3d3446b8be5b"
local url = "https://api.luarmor.net/files/v3/loaders/" .. scriptId .. ".lua"
local success, content = pcall(game.HttpGet, game, url)
    
if success and content then
    -- Update cache
    if writefile then
        pcall(writefile, "banana.txt", content)
    end
        
    return content
else
    error("Failed to download Luarmor script")
end
