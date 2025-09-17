-- luacheck: ignore 113
---@diagnostic disable: undefined-global
object "Session" {
  c_source [[
typedef RimeSessionId Session;
#define BUFFER_SIZE 1024
]],
  constructor {
    c_call "Session>1" "api->create_session" {}
  },
  destructor "destroy" {
    c_method_call "bool" "api->destroy_session" {}
  },
  method "get_current_schema" {
    var_out { "char *", "result" },
    c_source [[
              char schema_id[BUFFER_SIZE];
              if(!api->get_current_schema(${this}, schema_id, BUFFER_SIZE))
                return 0;
              ${result} = schema_id;
            ]]
  },
  method "select_schema" {
    c_method_call "bool" "api->select_schema" { "char *", "schema_id" }
  },
  method "process_key" {
    c_method_call "bool" "api->process_key" { "int", "key", "int", "mask?" }
  },
  method "get_context" {
    var_out { "<any>", "result" },
    c_source [[
              RIME_STRUCT(RimeContext, context);
              if (!api->get_context(${this}, &context))
                return 0;
              lua_createtable(L, 0, 2);
              lua_createtable(L, 0, 5);
              lua_pushinteger(L, context.composition.length);
              lua_setfield(L, -2, "length");
              lua_pushinteger(L, context.composition.cursor_pos);
              lua_setfield(L, -2, "cursor_pos");
              lua_pushinteger(L, context.composition.sel_start);
              lua_setfield(L, -2, "sel_start");
              lua_pushinteger(L, context.composition.sel_end);
              lua_setfield(L, -2, "sel_end");
              lua_pushstring(L, context.composition.preedit);
              lua_setfield(L, -2, "preedit");
              lua_setfield(L, -2, "composition");
              lua_createtable(L, 0, 7);
              lua_pushinteger(L, context.menu.page_size);
              lua_setfield(L, -2, "page_size");
              lua_pushinteger(L, context.menu.page_no);
              lua_setfield(L, -2, "page_no");
              lua_pushboolean(L, context.menu.is_last_page);
              lua_setfield(L, -2, "is_last_page");
              lua_pushinteger(L, context.menu.highlighted_candidate_index);
              lua_setfield(L, -2, "highlighted_candidate_index");
              lua_pushinteger(L, context.menu.num_candidates);
              lua_setfield(L, -2, "num_candidates");
              lua_pushstring(L, context.menu.select_keys);
              lua_setfield(L, -2, "select_keys");
              lua_newtable(L);
              for (int i = 0; i < context.menu.num_candidates; ++i) {
                lua_createtable(L, 0, 2);
                lua_pushstring(L, context.menu.candidates[i].text);
                lua_setfield(L, -2, "text");
                lua_pushstring(L, context.menu.candidates[i].comment);
                lua_setfield(L, -2, "comment");
                lua_rawseti(L, -2, i + 1);
              }
              lua_setfield(L, -2, "candidates");
              lua_setfield(L, -2, "menu");
              api->free_context(&context);
            ]]
  },
  method "get_commit" {
    var_out { "<any>", "result" },
    c_source [[
              RIME_STRUCT(RimeCommit, commit);
              if(!api->get_commit(${this}, &commit))
                return 0;
              lua_createtable(L, 0, 1);
              lua_pushstring(L, commit.text);
              lua_setfield(L, -2, "text");
              api->free_commit(&commit);
            ]]
  },
  method "commit_composition" {
    c_method_call "bool" "api->commit_composition" {}
  },
  method "clear_composition" {
    c_method_call "void" "api->clear_composition" {}
  },
}
