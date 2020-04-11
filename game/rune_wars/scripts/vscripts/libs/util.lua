function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  -- print ( string.format ('PrintTable type %s', type(keys)) )
  if t == {} then print("Empty table!") end
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

--=================================================================================================
--TABLE FUNCTIONS
--=================================================================================================

function CombineTables(table1, table2)
  for key,val in pairs(table2) do
    if type(key) ~= "number" then
      table1[key] = val
    else
      table.insert(table1, val)
    end
  end
  return table1
end

function GetTableLength(table)
  local index = 0
  for _,k in pairs(table) do
    index = index + 1
  end
  return index
end

function RemoveItemFromTable(tab, val)
  local newTab = {}
  local index = 0
  for _,v in pairs(tab) do
    if not v:GetName() ~= val:GetName() then
      newTab[index] = v
      index = index + 1
    end
  end
  return newTab
end

function IsEmpty(tab)
  if GetTableLength(tab) == 0 then
    return true
  end
  return false
end

function FindValueInTable(tab, value)
  for _,val in pairs(tab) do
    if val == value then
      return true
    end
  end
  return false
end