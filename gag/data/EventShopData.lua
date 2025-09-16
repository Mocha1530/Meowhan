local module = {}
module.Turnip = {
    SeedName = "Turnip";
    SeedRarity = "Common";
    StockChance = 1;
    StockAmount = {5, 7};
    Price = 10000000;
    PurchaseID = 3401533643;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 10;
    ItemType = "Seed";
    Stack = 1;
    Description = "";
    ShopIndex = 1;
    FallbackPrice = 129;
}
local tbl_13 = {
    SeedName = "Parsley";
    SeedRarity = "Uncommon";
    StockChance = 3;
    StockAmount = {3, 5};
    Price = 20000000;
    PurchaseID = 3401533790;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 2 Times";
    LayoutOrder = 20;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 477
    return true
end
tbl_13.CanBuy = CanBuy
tbl_13.Description = ""
tbl_13.FallbackPrice = 169
module.Parsley = tbl_13
local tbl_2 = {
    SeedName = "Meyer Lemon";
    SeedRarity = "Rare";
    StockChance = 4;
    StockAmount = {1, 2};
    Price = 50000000;
    PurchaseID = 3401533943;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 4 Times";
    LayoutOrder = 30;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 504
    return true
end
tbl_2.CanBuy = CanBuy
tbl_2.Description = ""
tbl_2.FallbackPrice = 247
module["Meyer Lemon"] = tbl_2
local tbl_18 = {
    SeedName = "Carnival Pumpkin";
    SeedRarity = "Legendary";
    StockChance = 6;
    StockAmount = {1, 1};
    Price = 100000000;
    PurchaseID = 3401534101;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 5 Times";
    LayoutOrder = 40;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 531
    return true
end
tbl_18.CanBuy = CanBuy
tbl_18.Description = ""
tbl_18.FallbackPrice = 479
module["Carnival Pumpkin"] = tbl_18
local tbl_30 = {
    SeedName = "Kniphofia";
    SeedRarity = "Mythical";
    StockChance = 18;
    StockAmount = {1, 1};
    Price = 450000000;
    PurchaseID = 3401534268;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 10 Times";
    LayoutOrder = 50;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 558
    return true
end
tbl_30.CanBuy = CanBuy
tbl_30.Description = ""
tbl_30.FallbackPrice = 659
module.Kniphofia = tbl_30
local tbl_25 = {
    SeedName = "Golden Peach";
    SeedRarity = "Divine";
    StockChance = 30;
    StockAmount = {1, 1};
    Price = 900000000;
    PurchaseID = 3401534430;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 13 Times";
    LayoutOrder = 60;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 585
    return true
end
tbl_25.CanBuy = CanBuy
tbl_25.Description = ""
tbl_25.FallbackPrice = 719
module["Golden Peach"] = tbl_25
local tbl_27 = {
    SeedName = "Maple Resin";
    SeedRarity = "Transcendent";
    StockChance = 60;
    StockAmount = {1, 1};
    Price = 1500000000;
    PurchaseID = 3401534643;
    DisplayInShop = true;
    ShowOdds = true;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 17 Times";
    LayoutOrder = 70;
    ItemType = "Seed";
    Stack = 1;
    ShopIndex = 1;
}
local function CanBuy(arg1, arg2) -- Line 612
    return true
end
tbl_27.CanBuy = CanBuy
tbl_27.Description = ""
tbl_27.FallbackPrice = 999
module["Maple Resin"] = tbl_27
local tbl_15 = {
    SeedName = "Firefly Jar";
    SeedRarity = "Common";
    StockChance = 1;
    StockAmount = {5, 8};
    Price = 500000;
    PurchaseID = 3401535051;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 10;
}
local function CanBuy(arg1, arg2) -- Line 634
    return true
end
tbl_15.CanBuy = CanBuy
tbl_15.ItemType = "Gear"
tbl_15.Description = ""
tbl_15.ShopIndex = 2
tbl_15.Stack = 1
tbl_15.FallbackPrice = 37
module["Firefly Jar"] = tbl_15
local tbl = {
    SeedName = "Sky Lantern";
    SeedRarity = "Uncommon";
    StockChance = 1;
    StockAmount = {2, 4};
    Price = 1000000;
    PurchaseID = 3401535228;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 20;
}
local function CanBuy(arg1, arg2) -- Line 658
    return true
end
tbl.CanBuy = CanBuy
tbl.ItemType = "Gear"
tbl.Description = ""
tbl.ShopIndex = 2
tbl.Stack = 1
tbl.FallbackPrice = 39
module["Sky Lantern"] = tbl
local tbl_24 = {
    SeedName = "Maple Leaf Kite";
    SeedRarity = "Uncommon";
    StockChance = 2;
    StockAmount = {1, 3};
    Price = 15000000;
    PurchaseID = 3401535375;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 30;
}
local function CanBuy(arg1, arg2) -- Line 681
    return true
end
tbl_24.CanBuy = CanBuy
tbl_24.ItemType = "Gear"
tbl_24.Description = ""
tbl_24.ShopIndex = 2
tbl_24.Stack = 1
tbl_24.FallbackPrice = 49
module["Maple Leaf Kite"] = tbl_24
local tbl_23 = {
    SeedName = "Leaf Blower";
    SeedRarity = "Rare";
    StockChance = 3;
    StockAmount = {1, 3};
    Price = 35000000;
    PurchaseID = 3401535500;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 40;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 2 Times";
}
local function CanBuy(arg1, arg2) -- Line 707
    return true
end
tbl_23.CanBuy = CanBuy
tbl_23.ItemType = "Gear"
tbl_23.Description = ""
tbl_23.ShopIndex = 2
tbl_23.Stack = 1
tbl_23.FallbackPrice = 89
module["Leaf Blower"] = tbl_23
local tbl_22 = {
    SeedName = "Maple Syrup";
    SeedRarity = "Rare";
    StockChance = 1;
    StockAmount = {2, 4};
    Price = 50000000;
    PurchaseID = 3401535642;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 50;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 5 Times";
}
local function CanBuy(arg1, arg2) -- Line 733
    return true
end
tbl_22.CanBuy = CanBuy
tbl_22.ItemType = "Gear"
tbl_22.Description = ""
tbl_22.ShopIndex = 2
tbl_22.Stack = 1
tbl_22.FallbackPrice = 39
module["Maple Syrup"] = tbl_22
local tbl_20 = {
    SeedName = "Maple Sprinkler";
    SeedRarity = "Legendary";
    StockChance = 5;
    StockAmount = {1, 1};
    Price = 250000000;
    PurchaseID = 3401535950;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 60;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 9 Times";
}
local function CanBuy(arg1, arg2) -- Line 759
    return true
end
tbl_20.CanBuy = CanBuy
tbl_20.ItemType = "Gear"
tbl_20.Description = ""
tbl_20.ShopIndex = 2
tbl_20.Stack = 1
tbl_20.FallbackPrice = 189
module["Maple Sprinkler"] = tbl_20
local tbl_26 = {
    SeedName = "Bonfire";
    SeedRarity = "Mythical";
    StockChance = 8;
    StockAmount = {1, 1};
    Price = 500000000;
    PurchaseID = 3401536118;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 70;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 10 Times";
}
local function CanBuy(arg1, arg2) -- Line 785
    return true
end
tbl_26.CanBuy = CanBuy
tbl_26.ItemType = "Gear"
tbl_26.Description = ""
tbl_26.ShopIndex = 2
tbl_26.Stack = 1
tbl_26.FallbackPrice = 259
module.Bonfire = tbl_26
local tbl_4 = {
    SeedName = "Harvest Basket";
    SeedRarity = "Divine";
    StockChance = 15;
    StockAmount = {1, 1};
    Price = 750000000;
    PurchaseID = 3401536271;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 80;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 12 Times";
}
local function CanBuy(arg1, arg2) -- Line 811
    return true
end
tbl_4.CanBuy = CanBuy
tbl_4.ItemType = "Gear"
tbl_4.Description = ""
tbl_4.ShopIndex = 2
tbl_4.Stack = 1
tbl_4.FallbackPrice = 67
module["Harvest Basket"] = tbl_4
local tbl_14 = {
    SeedName = "Maple Leaf Charm";
    SeedRarity = "Legendary";
    StockChance = 25;
    StockAmount = {1, 1};
    Price = 100000000;
    PurchaseID = 3401535789;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 90;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 13 Times";
}
local function CanBuy(arg1, arg2) -- Line 837
    return true
end
tbl_14.CanBuy = CanBuy
tbl_14.ItemType = "Gear"
tbl_14.Description = ""
tbl_14.ShopIndex = 2
tbl_14.Stack = 1
tbl_14.FallbackPrice = 195
module["Maple Leaf Charm"] = tbl_14
module["Golden Acorn"] = {
    SeedName = "Golden Acorn";
    SeedRarity = "Prismatic";
    StockChance = 40;
    StockAmount = {1, 1};
    Price = 10000000000;
    PurchaseID = 3401536371;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 100;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 17 Times";
    CanBuy = function(arg1, arg2) -- Line 863, Named "CanBuy"
        return true
    end;
    ItemType = "Gear";
    Description = "";
    ShopIndex = 2;
    Stack = 1;
    FallbackPrice = 239;
}
module["Fall Egg"] = {
    SeedName = "Fall Egg";
    SeedRarity = "Mythical";
    StockChance = 1;
    StockAmount = {1, 1};
    Price = 90000000;
    PurchaseID = 3401534851;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 440;
    ItemType = "Egg";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 149;
}
module.Chipmunk = {
    SeedName = "Chipmunk";
    SeedRarity = "Common";
    StockChance = 3;
    StockAmount = {1, 1};
    Price = 150000000;
    PurchaseID = 3401548923;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 450;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 4 Times";
    ItemType = "Pet";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 299;
}
module["Red Squirrel"] = {
    SeedName = "Red Squirrel";
    SeedRarity = "Rare";
    StockChance = 6;
    StockAmount = {1, 1};
    Price = 400000000;
    PurchaseID = 3401549019;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 460;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 7 Times";
    ItemType = "Pet";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 219;
}
module.Marmot = {
    SeedName = "Marmot";
    SeedRarity = "Legendary";
    StockChance = 12;
    StockAmount = {1, 1};
    Price = 700000000;
    PurchaseID = 3401537209;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 470;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 10 Times";
    ItemType = "Pet";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 459;
}
module["Sugar Glider"] = {
    SeedName = "Sugar Glider";
    SeedRarity = "Mythical";
    StockChance = 24;
    StockAmount = {1, 1};
    Price = 900000000;
    PurchaseID = 3401537342;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 480;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 13 Times";
    ItemType = "Pet";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 568;
}
module["Space Squirrel"] = {
    SeedName = "Space Squirrel";
    SeedRarity = "Divine";
    StockChance = 50;
    StockAmount = {1, 1};
    Price = 1250000000;
    PurchaseID = 3401549137;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 490;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 17 Times";
    ItemType = "Pet";
    Stack = 1;
    Description = "";
    ShopIndex = 3;
    FallbackPrice = 659;
}
module["Fall Crate"] = {
    SeedName = "Fall Crate";
    SeedRarity = "Legendary";
    StockChance = 1;
    StockAmount = {1, 1};
    Price = 50000000;
    PurchaseID = 3401536497;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 1;
    ItemType = "Crate";
    Stack = 1;
    Description = "";
    ShopIndex = 4;
    FallbackPrice = 179;
}
module["Fall Leaf Chair"] = {
    SeedName = "Fall Leaf Chair";
    SeedRarity = "Common";
    StockChance = 1;
    StockAmount = {1, 1};
    Price = 10000000;
    PurchaseID = 3401536663;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 10;
    ItemType = "Cosmetic";
    Stack = 1;
    Description = "";
    ShopIndex = 4;
    FallbackPrice = 79;
}
module["Maple Flag"] = {
    SeedName = "Maple Flag";
    SeedRarity = "Rare";
    StockChance = 2;
    StockAmount = {1, 1};
    Price = 15000000;
    PurchaseID = 3401536754;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 20;
    ItemType = "Cosmetic";
    Stack = 1;
    Description = "";
    ShopIndex = 4;
    FallbackPrice = 119;
}
module["Flying Kite"] = {
    SeedName = "Flying Kite";
    SeedRarity = "Legendary";
    StockChance = 3;
    StockAmount = {1, 1};
    Price = 25000000;
    PurchaseID = 3401536894;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 30;
    ItemType = "Cosmetic";
    Stack = 1;
    Description = "";
    ShopIndex = 4;
    FallbackPrice = 139;
}
module["Fall Fountain"] = {
    SeedName = "Fall Fountain";
    SeedRarity = "Divine";
    StockChance = 30;
    StockAmount = {1, 1};
    Price = 1000000000;
    PurchaseID = 3401537019;
    DisplayInShop = true;
    ShowOdds = true;
    LayoutOrder = 40;
    LockedInShop = true;
    UnlockText = "Contribute to Fall Bloom 10 Times";
    ItemType = "Cosmetic";
    Stack = 1;
    Description = "";
    ShopIndex = 4;
    FallbackPrice = 279;
}
return module
