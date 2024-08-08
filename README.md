# jim-mining

FiveM Custom ox mining script by me from scratch

- Highly customisable via config.lua

  - Locations are easily changeable/removable

- Features several ways to get materials

  - Gold Panning - Search specified streams for gold and silver, or trash
  - Mining - Mine to get stones that can be wash or cracked for materials
  - Stone Washing - Wash stone to find rare gems or gold
  - Stone Cracking - Crack open stones to find ores for crafting materials

- Customisable points for mining, stone cracking and gold panning

  - Add a Location for an ore to the config and it will use this location for both qb-target and a prop
  - Can place them anywhere, doesn't have to be just one mining location
  - I opted for a drilling animation as opposed to the pickaxe swinging
  - Nicely animated for better immersion

- NPC's spawn on the blip locations

  - These locations can also give third eye and select ones have context menus for selling points

- NPC's and ore's Spawn at Mineshaft + Quarry so your players can go to either

- Features simplistic built in crafting that uses recipes in the config.lua

- Features Jewel Cutting bench as an attempt to add more than just gold bars and such to sell
  - You can use your gold bars and jewels to craft other items to sell to a Jewellery Buyer

## Video Previews

- Mineshaft Store: https://streamable.com/voay5z
- Multiple ways to mine ore: https://streamable.com/ui5dn2
- Gold Panning: https://streamable.com/zdjluz
- Stone Cracking: https://streamable.com/e6j8h0
- Stone Washing: https://streamable.com/rafnzt
- Smelting Menu: https://streamable.com/sejgfp
- Selling Ore: https://streamable.com/sjbmbo
- Gem Cutting & Jewellery Crafting: https://streamable.com/nmdntz
- Gem and Jewellery Buyer: https://streamable.com/t2jfzc
- K4MB1- Cave Support: https://streamable.com/5hivk9

## Custom Items & Images

![General](https://i.imgur.com/g8nqbvN.jpeg)

- Should be easy to understand and add/remove items you want or not

## Dependencies

- ox_lib
- ox_inventory

# How to install

## Minimal

If you want to use your own items or repurpose this script:

- Place in your resources folder
- add the following code to your server.cfg/resources.cfg

```
ensure jim-mining
```

If you want to use my items then:

- Add the images to ox_inventory/web/images

- Put these lines in your ox_inventory/data/items.lua

```lua
-- Stones and Gems
["stone"] = {
    name = "stone",
    label = "Stone",
    weight = 2000,
    stack = true,
    close = false,
    description = "Stone woo",
    client = { image = "stone.png" }
},

["uncut_emerald"] = {
    name = "uncut_emerald",
    label = "Uncut Emerald",
    weight = 100,
    stack = true,
    close = false,
    description = "A rough Emerald",
    client = { image = "uncut_emerald.png" }
},

["uncut_ruby"] = {
    name = "uncut_ruby",
    label = "Uncut Ruby",
    weight = 100,
    stack = true,
    close = false,
    description = "A rough Ruby",
    client = { image = "uncut_ruby.png" }
},

["uncut_diamond"] = {
    name = "uncut_diamond",
    label = "Uncut Diamond",
    weight = 100,
    stack = true,
    close = false,
    description = "A rough Diamond",
    client = { image = "uncut_diamond.png" }
},

["uncut_sapphire"] = {
    name = "uncut_sapphire",
    label = "Uncut Sapphire",
    weight = 100,
    stack = true,
    close = false,
    description = "A rough Sapphire",
    client = { image = "uncut_sapphire.png" }
},

-- Cut Gems
["emerald"] = {
    name = "emerald",
    label = "Emerald",
    weight = 100,
    stack = true,
    close = false,
    description = "An Emerald that shimmers",
    client = { image = "emerald.png" }
},

["ruby"] = {
    name = "ruby",
    label = "Ruby",
    weight = 100,
    stack = true,
    close = false,
    description = "A Ruby that shimmers",
    client = { image = "ruby.png" }
},

["diamond"] = {
    name = "diamond",
    label = "Diamond",
    weight = 100,
    stack = true,
    close = false,
    description = "A Diamond that shimmers",
    client = { image = "diamond.png" }
},

["sapphire"] = {
    name = "sapphire",
    label = "Sapphire",
    weight = 100,
    stack = true,
    close = false,
    description = "A Sapphire that shimmers",
    client = { image = "sapphire.png" }
},

-- Rings
["gold_ring"] = {
    name = "gold_ring",
    label = "Gold Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "gold_ring.png" }
},

["diamond_ring"] = {
    name = "diamond_ring",
    label = "Diamond Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_ring.png" }
},

["ruby_ring"] = {
    name = "ruby_ring",
    label = "Ruby Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_ring.png" }
},

["sapphire_ring"] = {
    name = "sapphire_ring",
    label = "Sapphire Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_ring.png" }
},

["emerald_ring"] = {
    name = "emerald_ring",
    label = "Emerald Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_ring.png" }
},

["silver_ring"] = {
    name = "silver_ring",
    label = "Silver Ring",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "silver_ring.png" }
},

["diamond_ring_silver"] = {
    name = "diamond_ring_silver",
    label = "Diamond Ring Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_ring_silver.png" }
},

["ruby_ring_silver"] = {
    name = "ruby_ring_silver",
    label = "Ruby Ring Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_ring_silver.png" }
},

["sapphire_ring_silver"] = {
    name = "sapphire_ring_silver",
    label = "Sapphire Ring Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_ring_silver.png" }
},

["emerald_ring_silver"] = {
    name = "emerald_ring_silver",
    label = "Emerald Ring Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_ring_silver.png" }
},

-- Chains and Necklaces
["goldchain"] = {
    name = "goldchain",
    label = "Golden Chain",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "goldchain.png" }
},

["diamond_necklace"] = {
    name = "diamond_necklace",
    label = "Diamond Necklace",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_necklace.png" }
},

["ruby_necklace"] = {
    name = "ruby_necklace",
    label = "Ruby Necklace",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_necklace.png" }
},

["sapphire_necklace"] = {
    name = "sapphire_necklace",
    label = "Sapphire Necklace",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_necklace.png" }
},

["emerald_necklace"] = {
    name = "emerald_necklace",
    label = "Emerald Necklace",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_necklace.png" }
},

["silverchain"] = {
    name = "silverchain",
    label = "Silver Chain",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "silverchain.png" }
},

["diamond_necklace_silver"] = {
    name = "diamond_necklace_silver",
    label = "Diamond Necklace Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_necklace_silver.png" }
},

["ruby_necklace_silver"] = {
    name = "ruby_necklace_silver",
    label = "Ruby Necklace Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_necklace_silver.png" }
},

["sapphire_necklace_silver"] = {
    name = "sapphire_necklace_silver",
    label = "Sapphire Necklace Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_necklace_silver.png" }
},

["emerald_necklace_silver"] = {
    name = "emerald_necklace_silver",
    label = "Emerald Necklace Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_necklace_silver.png" }
},

-- Earrings
["goldearring"] = {
    name = "goldearring",
    label = "Golden Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "gold_earring.png" }
},

["diamond_earring"] = {
    name = "diamond_earring",
    label = "Diamond Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_earring.png" }
},

["ruby_earring"] = {
    name = "ruby_earring",
    label = "Ruby Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_earring.png" }
},

["sapphire_earring"] = {
    name = "sapphire_earring",
    label = "Sapphire Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_earring.png" }
},

["emerald_earring"] = {
    name = "emerald_earring",
    label = "Emerald Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_earring.png" }
},

["silverearring"] = {
    name = "silverearring",
    label = "Silver Earrings",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "silverearring.png" }
},

["diamond_earring_silver"] = {
    name = "diamond_earring_silver",
    label = "Diamond Earrings Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "diamond_earring_silver.png" }
},

["ruby_earring_silver"] = {
    name = "ruby_earring_silver",
    label = "Ruby Earrings Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "ruby_earring_silver.png" }
},

["sapphire_earring_silver"] = {
    name = "sapphire_earring_silver",
    label = "Sapphire Earrings Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "sapphire_earring_silver.png" }
},

["emerald_earring_silver"] = {
    name = "emerald_earring_silver",
    label = "Emerald Earrings Silver",
    weight = 200,
    stack = true,
    close = false,
    description = "",
    client = { image = "emerald_earring_silver.png" }
},

-- Ores
["carbon"] = {
    name = "carbon",
    label = "Carbon",
    weight = 1000,
    stack = true,
    close = false,
    description = "Carbon, a base ore.",
    client = { image = "carbon.png" }
},

["ironore"] = {
    name = "ironore",
    label = "Iron Ore",
    weight = 1000,
    stack = true,
    close = false,
    description = "Iron, a base ore.",
    client = { image = "ironore.png" }
},

["copperore"] = {
    name = "copperore",
    label = "Copper Ore",
    weight = 1000,
    stack = true,
    close = false,
    description = "Copper, a base ore.",
    client = { image = "copperore.png" }
},

["goldore"] = {
    name = "goldore",
    label = "Gold Ore",
    weight = 1000,
    stack = true,
    close = false,
    description = "Gold Ore",
    client = { image = "goldore.png" }
},

["silverore"] = {
    name = "silverore",
    label = "Silver Ore",
    weight = 1000,
    stack = true,
    close = false,
    description = "Silver Ore",
    client = { image = "silverore.png" }
},

-- Ingots
["goldingot"] = {
    name = "goldingot",
    label = "Gold Ingot",
    weight = 1000,
    stack = true,
    close = false,
    description = "",
    client = { image = "goldingot.png" }
},

["silveringot"] = {
    name = "silveringot",
    label = "Silver Ingot",
    weight = 1000,
    stack = true,
    close = false,
    description = "",
    client = { image = "silveringot.png" }
},

-- Mining Tools
["pickaxe"] = {
    name = "pickaxe",
    label = "Pickaxe",
    weight = 1000,
    stack = true,
    close = false,
    description = "",
    client = { image = "pickaxe.png" }
},

["miningdrill"] = {
    name = "miningdrill",
    label = "Mining Drill",
    weight = 1000,
    stack = true,
    close = false,
    description = "",
    client = { image = "miningdrill.png" }
},

["mininglaser"] = {
    name = "mininglaser",
    label = "Mining Laser",
    weight = 900,
    stack = true,
    close = false,
    description = "",
    client = { image = "mininglaser.png" }
},

["drillbit"] = {
    name = "drillbit",
    label = "Drill Bit",
    weight = 10,
    stack = true,
    close = false,
    description = "",
    client = { image = "drillbit.png" }
},

-- Miscellaneous Tools
["goldpan"] = {
    name = "goldpan",
    label = "Gold Panning Tray",
    weight = 10,
    stack = true,
    close = false,
    description = "",
    client = { image = "goldpan.png" }
},

-- Recyclable Items
["bottle"] = {
    name = "bottle",
    label = "Empty Bottle",
    weight = 10,
    stack = true,
    close = false,
    description = "A glass bottle",
    client = { image = "bottle.png" }
},

["can"] = {
    name = "can",
    label = "Empty Can",
    weight = 10,
    stack = true,
    close = false,
    description = "An empty can, good for recycling",
    client = { image = "can.png" }
},

-- Others
["steel"] = {
    name = "steel",
    label = "Steel",
    weight = 1000,  -- Assuming a standard weight for steel
    stack = true,
    close = false,
    description = "A strong metal alloy made primarily of iron.",
    client = { image = "steel.png" }
},

["glass"] = {
    name = "glass",
    label = "Glass",
    weight = 1000,  -- Assuming a standard weight for glass
    stack = true,
    close = false,
    description = "Transparent material made from sand, soda ash, and limestone.",
    client = { image = "glass.png" }
},

["aluminum"] = {
    name = "aluminum",
    label = "Aluminum",
    weight = 1000,  -- Assuming a standard weight for aluminum
    stack = true,
    close = false,
    description = "A lightweight, silvery-white metal used in many industries.",
    client = { image = "aluminum.png" }
},

["metalscrap"] = {
    name = "metalscrap",
    label = "Metal Scrap",
    weight = 1000,  -- Assuming a standard weight for metal scrap
    stack = true,
    close = false,
    description = "A pile of various metal scraps, useful for crafting or recycling.",
    client = { image = "metalscrap.png" }
},
```
