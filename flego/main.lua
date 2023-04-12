-- main.lua

local ble = require("ble")
local display = require("display")


local left_motor_port = "A"
local right_motor_port = "B"

local function send_motor_msg(connection, port, speed)
    local msg = string.char(0x81, string.byte(port), 0x11, 0x51, 0x00, speed)
    connection:writeCharacteristic(0x000E, msg)
end

local function show_gritknox()
    display.clear()
    display.print("GRITknox", 0, 1)
    display.update()
end

local function show_bulldozer_pushing()
    local bulldozer_art = {
        "______  ",
        "_/  (0)\\___ ",
        "//\\_______/o\\",
        "'\"\"\"\"\"\"\"\"\"\"\"\"\"`"
    }

    for i = 0, 8 do
        display.clear()
        for j, line in ipairs(bulldozer_art) do
            display.print(line:sub(-i), i, j)
        end
        display.update()
        time.sleep(0.15)
    end
end

local function show_flego()
    display.clear()
    display.print("FLEGO", 0, 1)
    display.update()
end

local function scan_and_select_device()
    -- ... (same as previous version)
end

local function drive_mode(hub)
    -- ... (same as previous version)
end

local function blade_ripper_mode(hub)
    -- ... (same as previous version)
end

local function show_menu()
    -- ... (same as previous version)
end

local function main()
    show_gritknox()
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
