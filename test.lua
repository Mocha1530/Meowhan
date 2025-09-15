-- Data Service Access
local DataService = require(game:GetService("ReplicatedStorage").Modules.DataService)

-- Data Client Functions
local DataClient = {}
DataClient.GetData = function()
    local data = DataService:GetData()
    return data
end

DataClient.GetPet_Data = function(petUUID)
    local playerData = DataClient.GetData()
    local petsData = playerData and playerData.PetsData
    local petInventory = petsData and petsData.PetInventory.Data
    return petInventory[petUUID]
end

DataClient.GetSaved_Data = function()
    local playerData = DataClient.GetData()
    local saveSlots = playerData and playerData.SaveSlots
    return saveSlots and saveSlots.AllSlots[saveSlots.SelectedSlot].SavedObjects
end

-- Usage in ESP function
local function PetEggESP()
    -- Get physical objects folder
    local objectsFolder = game:GetService("Workspace").Farm.Farm.Important.Objects_Physical
    
    -- Get player's saved data
    local playerData = DataClient.GetSaved_Data()
    
    for _, egg in ipairs(objectsFolder:GetChildren()) do
        -- Check if egg is ready to hatch
        if egg:GetAttribute("OWNER") == game.Players.LocalPlayer.Name and
           egg:GetAttribute("READY") and
           egg:GetAttribute("TimeToHatch") <= 0 then
            
            -- Get egg data using UUID
            local uuid = egg:GetAttribute("OBJECT_UUID")
            local eggData = playerData[uuid]
            
            if eggData then
                -- Extract egg information
                local eggInfo = eggData.Data
                local eggType = eggInfo.Type
                local baseWeight = eggInfo.BaseWeight or 1
                local currentWeight = Data.Calculator.CurrentWeight(baseWeight, 1)
                local formattedWeight = Functions.DecimalNumberFormat(currentWeight)
                    
                    -- Get additional pet information
                local petTime = Data.GetPetTime(uuid)
                local timeResult = petTime and petTime.Result or "N/A"
                local passiveAbility = petTime and petTime.Passive and petTime.Passive[1] or "N/A"
                local mutationName = Data.GetPetMutationName(eggType) or "N/A"
                    
                    -- Determine size category
                local sizeCategory
                if currentWeight > 9 then
                    sizeCategory = "Titanic"
                elseif currentWeight >= 6 then
                    sizeCategory = "Semi Titanic"
                elseif currentWeight > 3 then
                    sizeCategory = "Huge"
                else
                    sizeCategory = "Small"
                end

                local existingESP = egg:FindFirstChild("ESP")
                if not existingESP then
                    ESP.CreateESP(egg, {
                        Color = Color3.fromRGB(92, 247, 240),
                        Text = string.format([[Pets: %s
Time: %s
Passive: %s
Mutation: %s
Weight: %s KG (%s)]],
                            eggType,
                            timeResult,
                            passiveAbility,
                            mutationName,
                            formattedWeight,
                            sizeCategory)
                    })
                else
                    -- Update existing ESP
                    local billboard = existingESP:FindFirstChild("BillboardGui")
                    local textLabel = billboard and billboard:FindFirstChild("TextLabel")
                    if textLabel then
                        textLabel.Text = string.format([[Pets: %s
Time: %s
Passive: %s
Mutation: %s
Weight: %s KG (%s)]],
                            eggType,
                            timeResult,
                            passiveAbility,
                            mutationName,
                            formattedWeight,
                            sizeCategory
                        )
                    end
                end
            end
        end
    end
end
