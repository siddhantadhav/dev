-- Build & run for competitive programming C++.
--
--   <leader>cc  compile current file (errors land in quickfix)
--   <leader>cr  compile & run: stdin < input.txt, stdout > output.txt

local flags = { "-std=c++23", "-O2", "-Wall", "-Wextra", "-DLOCAL" }
local bin_dir = vim.fn.stdpath("cache") .. "/cpp-build"
local timeout_ms = 10000      -- kill runaway loops
local auto_open_output = true -- open output.txt in a vsplit if not visible
local uv = vim.uv or vim.loop

-- Binary named after the source file so different problems don't clobber
-- each other within a contest directory.
local function bin_path(src)
  return bin_dir .. "/" .. vim.fn.fnamemodify(src, ":t:r")
end

local function sibling(src, name)
  return vim.fn.fnamemodify(src, ":h") .. "/" .. name
end

local function compile(src, on_success)
  vim.cmd("silent write")
  vim.fn.mkdir(bin_dir, "p")
  local cmd = { "g++" }
  vim.list_extend(cmd, flags)
  vim.list_extend(cmd, { src, "-o", bin_path(src) })
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.fn.setqflist({}, " ", {
          title = "g++ " .. vim.fn.fnamemodify(src, ":t"),
          lines = vim.split(res.stderr or "", "\n", { trimempty = true }),
          efm = "%f:%l:%c: %m,%-G%.%#",
        })
        vim.cmd("copen")
        vim.notify("Compilation failed", vim.log.levels.ERROR)
        return
      end
      vim.cmd("cclose")
      if on_success then
        on_success(bin_path(src))
      else
        vim.notify("Compiled OK")
      end
    end)
  end)
end

local function find_buf(path)
  local target = vim.fn.fnamemodify(path, ":p")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
        and vim.api.nvim_buf_get_name(buf) == target then
      return buf
    end
  end
end

-- Push text straight into the buffer; the file on disk already matches, so
-- clearing 'modified' afterwards keeps the buffer in sync without a write.
-- Beats :checktime here because that defers reloading a non-current buffer
-- until you next enter it.
local function set_buf_text(buf, text)
  if not vim.bo[buf].modifiable then
    return
  end
  local lines = vim.split(text, "\n")
  if lines[#lines] == "" then
    table.remove(lines)     -- trailing newline isn't a final empty line
  end

  local views = {}
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false

  for win, view in pairs(views) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_call(win, function()
        vim.fn.winrestview(view)
      end)
    end
  end
end

local function show_output(path, text)
  local buf = find_buf(path)
  if buf then
    if vim.bo[buf].modified then
      vim.notify("output.txt has unsaved edits — not reloading", vim.log.levels.WARN)
    else
      set_buf_text(buf, text)
    end
    return
  end
  if auto_open_output then
    local cur = vim.api.nvim_get_current_win()
    vim.cmd("vsplit " .. vim.fn.fnameescape(path))
    vim.bo.autoread = true
    vim.api.nvim_set_current_win(cur)
  end
end

local function run_with_files(src)
  local input = sibling(src, "input.txt")
  local output = sibling(src, "output.txt")
  compile(src, function(bin)
    local stdin_data = ""
    if vim.fn.filereadable(input) == 1 then
      -- binary read + "\n" join round-trips the file byte for byte
      stdin_data = table.concat(vim.fn.readfile(input, "b"), "\n")
    else
      vim.notify("No input.txt — running with empty stdin", vim.log.levels.WARN)
    end

    local started = uv.hrtime()
    vim.system({ bin }, {
      stdin = stdin_data,
      text = true,
      timeout = timeout_ms,
      cwd = vim.fn.fnamemodify(src, ":h"),
    }, function(res)
      local ms = (uv.hrtime() - started) / 1e6
      vim.schedule(function()
        local out = res.stdout or ""
        vim.fn.writefile(vim.split(out, "\n"), output, "b")
        show_output(output, out)

        local err = vim.trim(res.stderr or "")
        if res.signal ~= 0 or ms >= timeout_ms then
          vim.notify(("TLE / killed after %.0f ms"):format(ms), vim.log.levels.ERROR)
        elseif res.code ~= 0 then
          vim.notify(("Runtime error (exit %d, %.0f ms)%s")
            :format(res.code, ms, err ~= "" and "\n" .. err or ""),
            vim.log.levels.ERROR)
        elseif err ~= "" then
          vim.notify(("Done in %.0f ms (stderr)\n%s"):format(ms, err), vim.log.levels.WARN)
        else
          vim.notify(("Done in %.0f ms"):format(ms))
        end
      end)
    end)
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function(event)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "C++: " .. desc })
    end

    map("<leader>cc", function()
      compile(vim.api.nvim_buf_get_name(event.buf))
    end, "Compile")

    map("<leader>cr", function()
      run_with_files(vim.api.nvim_buf_get_name(event.buf))
    end, "Compile & run (input.txt → output.txt)")
  end,
})
