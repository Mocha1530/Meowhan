local Games = {
  [126884695634066] = "https://raw.githubusercontent.com/Mocha1530/Meowhan/main/gag.lua"
}
local Url = Games[game.PlaceId]
if Url then 
  loadstring(game:HttpGet(Url, true))()
else
  loadstring(game:HttpGet(""))()
end
