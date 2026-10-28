rockspec_format = '3.0'
description = {
  summary = '',
  detailed = '',
  labels = {},
  homepage = 'https://github.com/rimeinn/rime.nvim',
  license = 'GPL-3.0',
}
package = description.homepage:match('/([^/]+)/?$')
version = 'scm-1'
source = {
  url = description.homepage:gsub('https', 'git')
}

dependencies = { "lua >= 5.1", 'ime >= 0.0.8', 'platformdirs', 'lua-cjson' }
build_dependencies = { "luanativeobjects" }
build = {
  type = 'xmake',
  copy_directories = { 'after' },
  install = {
    bin = {
      rime = 'bin/rime',
    },
  },
}
