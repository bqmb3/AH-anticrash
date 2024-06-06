# AH-anticrash
```lua
_G.DisableMeshes = true -- Does not render meshes
_G.GlobalAntiCrash = false -- Applies anti-crash for all players in the server, basically removes all mesh parts
_G.DisableLongName = true -- Does not display long names of Humanoid, also known as fatal, data model crash
_G.DisableEffects = true -- Disables effects such as fire, smoke
_G.DisableSeats = false -- Prevents you from sitting in a seat part. Seat parts are often used for crash portals. You can still sit by clicking on a seat part.
_G.DisableForceViewCam = false -- Prevents :forceviewcam from executed on you
_G.SafeServerHop = true -- Your Roblox client will not render 3D objects until this script is loaded again. This prevents you from getting crashed on !newserver. This script will be automatically ran when you teleport to another server.

-- This does not prevent server crashes/freezes, and this will NOT prevent you from ALL crashes.
_G.antiCrash = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/AH-anticrash/main/main.lua",true))()

-- Include the following if you want a toggle button (on computers, Press V):
loadstring(game:HttpGet("https://gist.githubusercontent.com/bqmb3/3a8eaab8a26bd1939f99dc5326cf994a/raw/79afed28cb8591590306d212bec548794444377b/AH-anticrash-context-button.lua",true))()

```
... btw<br>
the best anticrash method fr 100% already exists:
```lua
game.RunService:Set3dRenderingEnabled(false)
```
^^^^ this exists and works on any game