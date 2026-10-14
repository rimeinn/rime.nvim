-- luacheck: ignore 113
---@diagnostic disable: undefined-global
object "Traits" {
  c_source [[
typedef RimeTraits Traits;
]],
  constructor {
    var_in { "char *", "shared_data_dir" },
    var_in { "char *", "user_data_dir" },
    var_in { "char *", "log_dir" },
    var_in { "char *", "distribution_name" },
    var_in { "char *", "distribution_code_name" },
    var_in { "char *", "distribution_version" },
    var_in { "char *", "app_name" },
    var_in { "int", "min_log_level" },
    var_in { "<any>", "modules" },
    c_source [[
RIME_STRUCT(RimeTraits, traits);
const char *modules[64];
size_t n_modules = 0;
size_t len = lua_objlen(L, ${modules::idx});
for (size_t i = 1; i <= len && n_modules < 63; i++) {
  lua_rawgeti(L, ${modules::idx}, i);
  const char *name = lua_tostring(L, -1);
  lua_pop(L, 1);
  if (name) modules[n_modules++] = name;
}
modules[n_modules] = NULL;
traits.modules = modules;
traits.shared_data_dir = ${shared_data_dir};
traits.user_data_dir = ${user_data_dir};
traits.log_dir = ${log_dir};
traits.distribution_name = ${distribution_name};
traits.distribution_code_name = ${distribution_code_name};
traits.distribution_version = ${distribution_version};
traits.app_name = ${app_name};
traits.min_log_level = ${min_log_level};
api->setup(&traits);
api->initialize(&traits);
]]
  },
  destructor "finalize" {
    c_source [[
api->finalize();
]]
  }
}
