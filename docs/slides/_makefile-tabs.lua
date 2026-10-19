-- Quarto expands tabs in rendered HTML code, even with preserve-tabs enabled.
-- Restore the original text in the browser so copying a recipe keeps its tabs.
local count = 0
function CodeBlock(block)
  if not block.classes:includes("makefile") then return end
  if not (FORMAT:match("html") or FORMAT == "revealjs") then return end

  count = count + 1
  local id = "makefile-example-" .. count
  local escaped = block.text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  -- Escape '<' so source text cannot close the script element.
  local original = pandoc.json.encode(block.text):gsub("<", "\\u003c")
  return pandoc.RawBlock("html",
    '<div class="sourceCode"><pre class="sourceCode makefile">' ..
    '<code id="' .. id .. '" class="sourceCode makefile">' .. escaped ..
    '</code></pre></div>\n<script>' ..
    'document.addEventListener("DOMContentLoaded", function () {' ..
    'document.getElementById("' .. id .. '").textContent = ' .. original .. ';' ..
    '});</script>')
end
