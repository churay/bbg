### Project Files and Directories ###

PROJ_DIR = .
BIN_DIR = $(PROJ_DIR)/bin
OPT_DIR = $(PROJ_DIR)/opt
SRC_DIR = $(PROJ_DIR)/bbg
TEST_DIR = $(PROJ_DIR)/spec

BBG_DIST = $(BIN_DIR)/bbg
BBG_EXE = $(BIN_DIR)/bbg/bbg.exe
BBG_LOVE = $(BIN_DIR)/bbg.love

# NOTE(JRC): The current path works since it just directly loads all files in the
# 'bbg' module.  The commented path is the ideal solution as it loads the 'bbg'
# module wholesale, but it doesn't work due to recursive module loading problems.
LUA_PPATH = $(LUA_PATH);$(SRC_DIR)/?.lua;$(OPT_DIR)/?.lua
# LUA_PPATH = $(LUA_PATH);$(SRC_DIR)/init.lua;$(OPT_DIR)/?.lua

### Compilation/Linking Tools and Flags ###

LUA_RUNNER = env LUA_PATH='$(LUA_PPATH)' love
LUA_RUNNER_FLAGS =
LUA_TESTER = busted
LUA_TESTER_FLAGS = --lpath='$(LUA_PPATH)'

### Build Rules ###

.PHONY : dist love main specs %_spec clean

all : main

$(BBG_DIST) dist : $(BBG_LOVE)
	wget -O $(BIN_DIR)/love.zip https://bitbucket.org/rude/love/downloads/love-0.10.0-win32.zip
	unzip -d $(BIN_DIR) $(BIN_DIR)/love.zip
	mv $(BIN_DIR)/love-0.10.0-win32 $(BBG_DIST)
	cat $(BBG_DIST)/love.exe $(BBG_LOVE) > $(BBG_EXE)

$(BBG_LOVE) love : $(wildcard $(PROJ_DIR)/*.lua) $(wildcard $(SRC_DIR)/*.lua) | $(BIN_DIR)
	zip -9 -q -r $(BBG_LOVE) $(PROJ_DIR)

main :
	$(LUA_RUNNER) $(LUA_RUNNER_FLAGS) $(PROJ_DIR)

specs : $(wildcard $(SRC_DIR)/*.lua) $(wildcard $(TEST_DIR)/*.lua)
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='_spec' $(TEST_DIR)

%_spec : $(TEST_DIR)/%_spec.lua
	$(LUA_TESTER) $(LUA_TESTER_FLAGS) --pattern='$(basename $(<F))' $(TEST_DIR)

$(BIN_DIR) $(OPT_DIR) :
	mkdir $@

clean :
	rm -rf $(BIN_DIR)
