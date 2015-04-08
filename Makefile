### Compilation/Linking Tools and Flags ###

LUA_PROJ_RUNNER = love
LUA_PROJ_RUNNER_FLAGS =
LUA_TESTER = busted
LUA_TESTER_FLAGS = --lpath='$(LUA_DIR)/?.lua;$(PROJ_DIR)/?/init.lua;$(TEST_DIR)/?.lua'

### Project Files and Directories ###

PROJ_DIR = .
LUA_DIR = $(PROJ_DIR)/bbg
TEST_DIR = $(PROJ_DIR)/spec

### Build Rules ###

.PHONY : bbg tests %Test

all : bbg

bbg :
	$(LUA_PROJ_RUNNER) $(LUA_PROJ_RUNNER_FLAGS) $(PROJ_DIR)

tests : $(wildcard $(LUA_DIR)/*.lua) $(wildcard $(TEST_DIR)/*.lua)
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='Spec' $(TEST_DIR)

%Test : $(TEST_DIR)/%Spec.lua
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='$(basename $(<F))' $(TEST_DIR)
