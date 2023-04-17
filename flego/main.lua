local ble = require("ble")

-- ASCII Art
local function show_ascii_art()
    local art = [[
         _              _            _        _            _              _             _     _      _      
        /\ \           /\ \         /\ \     /\ \         /\_\           /\ \     _    /\ \ /_/\    /\ \    
       /  \ \         /  \ \        \ \ \    \_\ \       / / /  _       /  \ \   /\_\ /  \ \\ \ \   \ \_\   
      / /\ \_\       / /\ \ \       /\ \_\   /\__ \     / / /  /\_\    / /\ \ \_/ / // /\ \ \\ \ \__/ / /   
     / / /\/_/      / / /\ \_\     / /\/_/  / /_ \ \   / / /__/ / /   / / /\ \___/ // / /\ \ \\ \__ \/_/    
    / / / ______   / / /_/ / /    / / /    / / /\ \ \ / /\_____/ /   / / /  \/____// / /  \ \_\\/_/\__/\    
   / / / /\_____\ / / /__\/ /    / / /    / / /  \/_// /\_______/   / / /    / / // / /   / / / _/\/__\ \   
  / / /  \/____ // / /_____/    / / /    / / /      / / /\ \ \     / / /    / / // / /   / / / / _/_/\ \ \  
 / / /_____/ / // / /\ \ \  ___/ / /__  / / /      / / /  \ \ \   / / /    / / // / /___/ / / / / /   \ \ \ 
/ / /______\/ // / /  \ \ \/\__\/_/___\/_/ /      / / /    \ \ \ / / /    / / // / /____\/ / / / /    /_/ / 
\/___________/ \/_/    \_\/\/_________/\_\/       \/_/      \_\_\\/_/     \/_/ \/_________/  \/_/     \_\/  
                                                                                                            
    ]]

    local function clear_screen()
        for _ = 1, 25 do
            print("\n")
        end
    end

    local function print_at_position(position)
        if position == "center" then
            print(art)
        elseif position == "bottom_left" then
            for _ = 1, 15 do
                print("\n")
            end
            print(art)
        elseif position == "top_left" then
            print(art)
            for _ = 1, 15 do
                print("\n")
            end
        elseif position == "top_right" then
            local art_lines = {}
            for line in art:gmatch("[^\n]+") do
                table.insert(art_lines, line)
            end
            for _, line in ipairs(art_lines) do
                print(string.rep(" ", 70) .. line)
            end
            for _ = 1, 15 do
                print("\n")
            end
        elseif position == "bottom_right" then
            for _ = 1, 15 do
                print("\n")
            end
            local art_lines = {}
            for line in art:gmatch("[^\n]+") do
                table.insert(art_lines, line)
            end
            for _, line in ipairs(art_lines) do
                print(string.rep(" ", 70) .. line)
            end
        end
    end

    print_at_position("center")
    os.execute("sleep " .. tonumber(1))
    clear_screen()
    print_at_position("bottom_left")
    os.execute("sleep " .. tonumber(0.5))
    clear_screen()
    print_at_position("top_left")
    os.execute("sleep " .. tonumber(0.5))
    clear_screen()
    print_at_position("top_right")
    os.execute("sleep " .. tonumber(0.5))
    clear_screen()
    print_at_position("bottom_right")
    os.execute("sleep " .. tonumber(0.5))
    clear_screen()
    print_at_position("center")
    os.execute("sleep " .. tonumber(0.5))
    clear_screen()
end

-- Call the function to show the ASCII art animation
show_ascii_art()

-- BLE scanning
local function on_device_found(device)
    print("Device found: " .. device.name)
end

local function on_device_lost(device)
    print("Device lost: " .. device.name)
end

print("Starting BLE scan...")
ble.start_scan(on_device_found, on_device_lost)

os.execute("sleep " .. tonumber(10))

print("Stopping BLE scan...")
ble.stop_scan()

for _, device in ipairs(devices) do
    if device.advertisement.manufacturer_data and device.advertisement.manufacturer_data:sub(1, 2) == "\x97\x03" then
        table.insert(lego_devices, device)
        print("Found LEGO device:", device.address, device.advertisement.local_name)
    end
end

if #lego_devices == 0 then
    print("No LEGO devices found.")
    return nil
end

local selected_device = lego_devices[1]

if #lego_devices > 1 then
    print("Select the LEGO device you want to connect to:")
    for i, device in ipairs(lego_devices) do
        print(i .. ":", device.address, device.advertisement.local_name)
    end
    local choice = tonumber(io.read())
    selected_device = lego_devices[choice]
end

return selected_device.address
end

local function drive_mode(hub)
while true do
    display.clear()
    display.print("Drive Mode", 0, 0)
    display.print("Use D-Pad to drive", 0, 1)
    display.print("Press BACK to exit", 0, 2)
    display.update()

    local key = buttons.wait()

    if key == buttons.KEY_UP then
        send_motor_msg(hub, left_motor_port, 50)
        send_motor_msg(hub, right_motor_port, 50)
    elseif key == buttons.KEY_DOWN then
        send_motor_msg(hub, left_motor_port, -50)
        send_motor_msg(hub, right_motor_port, -50)
    elseif key == buttons.KEY_LEFT then
        send_motor_msg(hub, left_motor_port, -50)
        send_motor_msg(hub, right_motor_port, 50)
    elseif key == buttons.KEY_RIGHT then
        send_motor_msg(hub, left_motor_port, 50)
        send_motor_msg(hub, right_motor_port, -50)
    elseif key == buttons.KEY_BACK then
        send_motor_msg(hub, left_motor_port, 0)
        send_motor_msg(hub, right_motor_port, 0)
        break
    end
end
end

local function blade_ripper_mode(hub)
display.clear()
display.print("Blade & Ripper Mode", 0, 0)
display.print("Press 1 to raise", 0, 1)
display.print("Press 2 to lower", 0, 2)
display.print("Press BACK to exit", 0, 3)
display.update()

local key = buttons.wait()

if key == buttons.KEY_1 then
    -- Raise the blade and ripper
elseif key == buttons.KEY_2 then
    -- Lower the blade and ripper
elseif key == buttons.KEY_BACK then
    return
end
end

local function show_menu()
display.clear()
display.print("MENU", 0, 0)
display.print("1: Drive Mode", 0, 1)
display.print("2: Blade & Ripper", 0, 2)
display.print("BACK: Exit", 0, 3)
display.update()
end

local function main()
show_grit()
time.sleep(2)
show_bulldozer_pushing()
time.sleep(2)
show_flego()
time.sleep(2)

local selected_address = scan_and_select_device()
if not selected_address then
    return
end

local hub = ble.connect(selected_address)

while true do
    show_menu()
    local key = buttons.wait()

    if key == buttons.KEY_1 then
        drive_mode(hub)
    elseif key == buttons.KEY_2 then
        blade_ripper_mode(hub)
    elseif key == buttons.KEY_BACK then
        break
    end
end

hub:disconnect()
end

-- Run the script
main()