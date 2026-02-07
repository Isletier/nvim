vim.env.DAP_executable = "empty"

function ClearCachedELF()
    print("Cleared cashed ELF: " .. vim.env.DAP_executable)
    vim.env.DAP_executable = "empty"

end function CheckFile(file_path)
    -- Check if file exists
    local file_exists = os.execute("test -e " .. file_path)
    if file_exists ~= 0 then
        print("File does not exist.")
        return false
    end

    -- Check if file has execute permissions local has_execute_permission = os.execute("test -x " .. file_path)
    local has_execute_permission = os.execute("test -x " .. file_path)
    if has_execute_permission ~= 0 then
        print("File does not have execute permissions.")
        return false
    end

    -- Check if the file contains "debug_info"
    local contains_debug_info = os.execute("grep -q 'debug_info' " .. file_path)
    if contains_debug_info ~= 0 then
        print("File does not contain 'debug_info'.")
        return false
    end

    return true
end

function LaunchELFExecutable()
    local executable = vim.env.DAP_executable

    if(CheckFile(executable)) then print("Founded cached debug executable: " .. executable)
        return executable
    end

    executable = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    if(CheckFile(executable)) then
        vim.env.DAP_executable = executable
        return executable
    end

    print("Didn't found executable file or file doesnt have debug symbols")
    vim.env.DAP_executable = "empty"
    return "empty"

end

function ConfigureDAP()
    local dap = require("dap")
    local path_to_codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

    dap.adapters.gdb = {
          type = "executable",
          command = "gdb",
    }

    dap.configurations.cpp = {
        {
            name = "Launch file",
            type = "gdb",
            request = "launch",
            program = LaunchELFExecutable,
            cwd = vim.fn.getcwd(),
            stopOnEntry = false,
        },
    }

    dap.configurations.c = dap.configurations.cpp

    dap.adapters.delve = function(callback, config)
        if config.mode == 'remote' and config.request == 'attach' then
            callback({
                type = 'server',
                host = config.host or '127.0.0.1',
                port = config.port or '38697',
                options = {
                    initialize_timeout_sec = 30
                }
            })
        else
            callback({
                type = 'server',
                port = '${port}',
                executable = {
                    command = 'dlv',
                    args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
                    detached = vim.fn.has("win32") == 0,
                },
                options = {
                    initialize_timeout_sec = 30
                },
            })
        end
    end

    dap.configurations.go = {
        {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "${file}",
            outputMode = "remote",
--            args = {
--            }
        },
        {
            type = "delve",
            name = "Debug test", -- configuration for debugging test files
            request = "launch",
            mode = "test",
            program = "${file}",
            outputMode = "remote"
        },
        {
            type = "delve",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
            outputMode = "remote"
        }
    }

    local dapui = require("dap-view")

    dapui.setup({
        windows = {
            terminal = {
                hide = { "delve" }
            },
        },
    })

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.after.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.after.event_exited["dapui_config"] = function()
        dapui.close()
    end

    vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
    vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
    vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
    vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
    vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)

    vim.keymap.set('n', '<Leader>de', function()
        require('dap').close()
        dapui.close()
    end)

    vim.keymap.set('n', '<Leader>dt', function()
        dapui.toggle()
    end)

    vim.keymap.set('n', '<Leader>dc', function()
        ClearCachedELF()
        require('dap').clear_breakpoints()
    end)


end

ConfigureDAP()

