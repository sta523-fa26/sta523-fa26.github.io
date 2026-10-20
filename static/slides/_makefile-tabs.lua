-- Quarto's revealjs output expands tabs in code, even with preserve-tabs enabled.
-- Keep pandoc's syntax highlighting, then restore each line's original leading
-- whitespace in the browser so copying a recipe keeps its tabs.
local count = 0
function CodeBlock(block)
  if not block.classes:includes("makefile") then return end
  if not (FORMAT:match("html") or FORMAT == "revealjs") then return end

  count = count + 1
  local id = "makefile-example-" .. count
  local html = pandoc.write(pandoc.Pandoc({block}), "html")
  html = html:gsub(' id="cb%d+%-?%d*"', "")
  html = html:gsub('<a href="#cb%d+%-%d+"[^>]*></a>', "")
  html = html:gsub('<code class="sourceCode makefile">',
    '<code id="' .. id .. '" class="sourceCode makefile">', 1)
  -- Escape '<' so source text cannot close the script element.
  local original = pandoc.json.encode(block.text):gsub("<", "\\u003c")
  return pandoc.RawBlock("html", html ..
    '<script>document.addEventListener("DOMContentLoaded", function () {' ..
    'var lines = ' .. original .. '.split("\\n");' ..
    'var code = document.getElementById("' .. id .. '");' ..
    'code.querySelectorAll(":scope > span").forEach(function (line, i) {' ..
    'var lead = (lines[i] || "").match(/^\\s*/)[0]; if (!lead) return;' ..
    'var w = document.createTreeWalker(line, NodeFilter.SHOW_TEXT), n;' ..
    'while ((n = w.nextNode())) { if (!n.nodeValue.trim()) { n.nodeValue = ""; continue; }' ..
    'n.nodeValue = lead + n.nodeValue.replace(/^\\s+/, ""); break; }' ..
    '});});</script>')
end
