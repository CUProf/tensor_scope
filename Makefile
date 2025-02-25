PROJECT := tensor_scope


OBJ_DIR := obj
SRC_DIR := src
INC_DIR := include
LIB_DIR := lib
PREFIX := tensor_scope

LIB := $(LIB_DIR)/lib$(PROJECT).so
CUR_DIR := $(shell pwd)

CXX ?= g++

CXX_FLAGS ?=
INCLUDES ?=
LDFLAGS ?=
LINK_LIBS ?=

INCLUDES += -I$(INC_DIR)

TORCH_DIR = $(shell python3 -c "import torch; import os; print(os.path.dirname(torch.__file__))")
INCLUDES += -I$(TORCH_DIR)/include -I$(TORCH_DIR)/include/torch/csrc/api/include 
LDFLAGS += -L$(TORCH_DIR)/lib -Wl,-rpath=$(TORCH_DIR)/lib
LINK_LIBS += -lc10 -ltorch -ltorch_cpu

PYTHON_INCLUDE_DIR = $(shell python3 -c "import sysconfig; print(sysconfig.get_path('include'))")
PYTHON_LIB_DIR = $(shell python3 -c "import sysconfig; print(sysconfig.get_path('stdlib'))")
PYTHON_VERSION = $(shell python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
INCLUDES += -I$(PYTHON_INCLUDE_DIR)
LDFLAGS += -L$(PYTHON_LIB_DIR)/../ -Wl,-rpath=$(PYTHON_LIB_DIR)/../
LINK_LIBS += -lpython$(PYTHON_VERSION)


CXX_FLAGS += -std=c++17

ifeq ($(DEBUG), 1)
	CXX_FLAGS += -g -O0
else
	CXX_FLAGS += -O3
endif

SRCS := $(notdir $(wildcard $(SRC_DIR)/*.cpp $(SRC_DIR)/*/*.cpp))
OBJS := $(addprefix $(OBJ_DIR)/, $(patsubst %.cpp, %.o, $(SRCS)))


all: dirs libs
dirs: $(OBJ_DIR) $(LIB_DIR)
libs: $(LIB)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(LIB_DIR):
	mkdir -p $(LIB_DIR)

$(LIB): $(OBJS)
	$(CXX) $(LDFLAGS) -fPIC -shared -o $@ $^ $(LINK_LIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXX_FLAGS) $(INCLUDES) -fPIC -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/*/%.cpp
	$(CXX) $(CXX_FLAGS) $(INCLUDES) -fPIC -c $< -o $@

.PHONY: clean
clean:
	-rm -rf $(OBJ_DIR) $(LIB_DIR) $(PREFIX)


.PHONY: install
install: all
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	cp -r $(LIB) $(PREFIX)/lib
	cp -r $(INC_DIR)/$(PROJECT).h $(PREFIX)/include
