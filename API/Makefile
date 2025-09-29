CXX = g++
CXXFLAGS = -std=c++17 -O2 -pthread
TARGET = rest-server
SRC = src/main.cpp

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o build/$(TARGET) $(SRC)

run: all
	./build/$(TARGET) 18080

clean:
	rm -f build/$(TARGET)