local git_ref = '$git_ref'
local modrev = '$modrev'
local specrev = '$specrev'

local repo_url = '$repo_url'

rockspec_format = '3.0'
package = '$package'
version = modrev ..'-'.. specrev

description = {
  summary = '$summary',
  detailed = $detailed_description,
  labels = $labels,
  homepage = '$homepage',
  $license
}

build_dependencies = { "luanativeobjects" }

dependencies = { "lua >= 5.1", 'ime >= 0.0.4', 'platformdirs', 'lua-cjson' }

test_dependencies = $test_dependencies

source = {
  url = repo_url .. '/archive/' .. git_ref .. '.zip',
  dir = '$repo_name-' .. '$archive_dir_suffix',
}

if modrev == 'scm' or modrev == 'dev' then
  source = {
    url = repo_url:gsub('https', 'git')
  }
end

build = {
  type = 'xmake',
  copy_directories = {'after'},
  install = {
    bin = {
      rime = 'bin/rime'
    },
    conf = {
      ['..'] = 'shell.nix',
      ['../scripts/update.sh'] = 'scripts/update.sh',
    },
  },
}
