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
    c_source [[
      RIME_STRUCT(RimeTraits, traits);
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
