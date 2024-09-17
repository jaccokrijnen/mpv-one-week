-- List of chapters
local chapters = nil
local input_buffer = ""

-- Function to get the chapter list with titles
function update_chapters()
    chapters = mp.get_property_native("chapter-list")
end

-- Function to jump to the chapter by title
function jump_to_chapter(title)
    if not chapters then
        update_chapters()
    end
    for i, chapter in ipairs(chapters) do
        if chapter.title and chapter.title == title then
            mp.set_property("chapter", i - 1) -- MPV chapters are zero-indexed
            mp.osd_message("Jumped to chapter: " .. title)
            return
        end
    end
    mp.msg.warn("Chapter with title '" .. title .. "' not found!")
    mp.osd_message("Chapter with title '" .. title .. "' not found!")
end

-- Function to handle user input (e.g., "1A", "3C")
function handle_input()
    -- Input buffer should have exactly two characters: a number and a letter
    if #input_buffer == 2 then
        local num = tonumber(input_buffer:sub(1, 1)) -- first character (number)
        local letter = input_buffer:sub(2, 2):upper() -- second character (letter)

        -- Check if the number is valid and the letter is alphabetical
        if num and num >= 1 and num <= 4 and letter:match("%a") then
            -- Create the chapter title by repeating the letter 'num' times
            local chapter_title = string.rep(letter, num)
            jump_to_chapter(chapter_title)
        else
            mp.osd_message("Invalid input: " .. input_buffer)
        end
        -- Clear the input buffer after processing
        input_buffer = ""
    else
        mp.osd_message("Incomplete input, expecting a number followed by a letter")
    end
end

-- Function to capture the number input (1-4)
function number_input(number)
    input_buffer = number -- start input with the number
    mp.osd_message("Selected number: " .. number)
end

-- Function to capture the letter input (A-Z)
function letter_input(letter)
    input_buffer = input_buffer .. letter:upper() -- append the letter
    mp.osd_message("Selected letter: " .. letter:upper())
    handle_input() -- process the input after both number and letter are given
end

-- Bindings for numbers (1-4)
mp.add_key_binding("1", "input_number_1", function() number_input("1") end)
mp.add_key_binding("2", "input_number_2", function() number_input("2") end)
mp.add_key_binding("3", "input_number_3", function() number_input("3") end)
mp.add_key_binding("4", "input_number_4", function() number_input("4") end)

-- Bindings for letters (A-Z)
for i = 65, 90 do -- ASCII codes for A-Z
    local letter = string.char(i)
    mp.add_key_binding(letter:lower(), "input_letter_" .. letter, function() letter_input(letter) end)
end

-- Automatically update chapter list when a new file is loaded
mp.register_event("file-loaded", update_chapters)

mp.register_script_message("display-chapter", function()
    local chapter = mp.get_property_number("chapter")
    if chapter ~= nil then
        local chapter_name = mp.get_property("chapter-metadata/title")
        mp.osd_message(string.format("%s", chapter_name or "Unknown"), 10)
    end
end)

-- Display chapter information every time a new chapter starts
mp.observe_property("chapter", "number", function(name, value)
    mp.command("script-message display-chapter")
end)
