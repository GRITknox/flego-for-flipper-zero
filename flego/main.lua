local ble = require("ble")
local display = require("display")

local left_motor_port = "A"
local right_motor_port = "B"

local function send_motor_msg(connection, port, speed)
    local msg = string.char(0x81, string.byte(port), 0x11, 0x51, 0x00, speed)
    connection:writeCharacteristic(0x000E, msg)
end

local function show_grit()
    display.clear()
    display.print("  ____  _   _", 0, 0)
    display.print(" / ___|| |_(_)_ __ ___", 0, 1)
    display.print("| |  _| | __| | '__/ _ \\", 0, 2)
    display.print("| |_| | | |_| | | |  __/", 0, 3)
    display.print(" \\____|_|\\__|_|_|  \\___|", 0, 4)
    display.update()
end

local function show_bulldozer_pushing()
    local bulldozer_art = {
        "____       ",
        "| o | i   / ",
        "####### <|  ",
        "(_______) \\"
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
    local devices = ble.scan(10000)
    local lego_devices = {}

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
